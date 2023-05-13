// tasker.lsl
//
// Used to send data about tasks to VivoSim server

float   VERSION = 6.02;   // 12 May 2023

integer DEBUGMODE = FALSE;

string  TXT_TASK_COMPLETED = "Congratulations! You have completed the task";
string  TXT_FAULTY_PRODUCT = "Sorry, this product is faulty";

string  PREFIX = "";				// RCODE=WINDMILL        ; For working out the machine type
integer verb = 1;					// MAKE_VERB=1            ; Set to 1 to use 'make' or 0 to use 'do'
string  privFlag = "0";				// HIDE_RESULTS=0        ; Set to 0 for activity etc to be posted on the VivoSim website, 1 to prevent
string  languageCode = "en-GB";		// LANG=en-GB            ; Default language

string  PASSWORD = "*";
integer timeOut = 60;
string  user;
string  ownerID;
key     farmHTTP;

// Assume in a machine but should get correct suffix later
string SUFFIX = "M1"; 


debug(string text)
{
	if (DEBUGMODE == TRUE) llOwnerSay("DEBUG_" + llToUpper(llGetScriptName()) + " " + text);
}

loadConfig()
{
	PASSWORD = osGetNotecardLine("sfp", 0);

	if (llGetInventoryType("config") == INVENTORY_NOTECARD)
	{
		string line;
		string firstChar;
		list tok = [];
		string cmd;
		string val;

		list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
		integer i;

		for (i = 0; i < llGetListLength(lines); i++)
		{
			line = llStringTrim(llList2String(lines, i), STRING_TRIM);
			firstChar = llGetSubString(line, 0, 0);

			// Comment lines can start with either  #  or  ;
			if ((firstChar != "#") && (firstChar != ";"))
			{
				tok = llParseStringKeepNulls(line, ["="], []);
				cmd = llList2String(tok, 0);
				val = llList2String(tok, 1);

					 if (cmd == "RCODE") PREFIX = val;
				else if (cmd == "HIDE_RESULTS") privFlag = val;
				else if (cmd == "LANG") languageCode = val;
				else if (cmd == "MAKE_VERB")
				{
					// Should be 0 or 1, anything else default to 1
					verb = llAbs((integer)val);
					if (verb > 1) verb = 1;
				}

			}
		}
	}
}

loadLanguage(string langCode)
{
	// optional language notecard
	string languageNC = langCode + "-lang" + SUFFIX;

	if (llGetInventoryType(languageNC) == INVENTORY_NOTECARD)
	{
		string line;
		string firstChar;
		string cmd;
		string val;
		list tok;

		list lines = llParseStringKeepNulls(osGetNotecard(languageNC), ["\n"], []);
		integer i;

		for (i = 0; i < llGetListLength(lines); i++)
		{
			line = llList2String(lines, i);
			firstChar = llGetSubString(line, 0, 0);

			// A comment line can start with either  #  or  ;
			if ((firstChar != "#") && (firstChar != ";"))
			{
				tok = llParseString2List(line, ["="], []);

				if (llList2String(tok,1) != "")
				{
					cmd = llStringTrim(llList2String(tok, 0), STRING_TRIM);
					val = llStringTrim(llList2String(tok, 1), STRING_TRIM);

					// Remove start and end " marks
					val = llGetSubString(val, 1, -2);

					// Now check for language translations
						 if (cmd == "TXT_TASK_COMPLETED") TXT_TASK_COMPLETED = val;
					else if (cmd == "TXT_FAULTY_PRODUCT") TXT_FAULTY_PRODUCT = val;
				}
			}
		}
	}
}

postMessage(string msg)
{
	farmHTTP = llGetKey();
	llMessageLinked(LINK_SET, 1, "CMD_POST|"+msg, farmHTTP);
	llSetTimerEvent(timeOut);
}


default
{
	state_entry()
	{
		ownerID = (string)llGetOwner();
		loadConfig();
	}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY)
		{
			loadConfig();
		}
	}

	link_message(integer sender, integer num, string m, key id)
	{
		debug("link_message: " + m);
		list tok = llParseString2List(m, ["|"], []);
		string cmd = llList2String(tok,0);

		if (cmd == "REZ_PRODUCT")
		{
			// REZ_PRODUCT|farm|c838f4f7-9a2f-43e9-8bbc-49969b406e5a|SF Cheese

			if (llList2String(tok, 1) == PASSWORD)
			{
				user = llList2String(tok, 2);

				string action;
				if (verb == 1) action = "MAKE"; else action = "DO";

				string product = llList2String(tok, 3);

				// Remove prefix and convert to all caps
				product = llToUpper(llGetSubString(product, 3, -1));

				//                                                                 eg MAKE;DRYRACK;SALT
				postMessage("task=actions&data1=" +llList2String(tok, 2) +"&data2=" +action +";" +PREFIX +";" +product +"&data3=" +ownerID);
			}
			else
			{
				llRegionSayTo(user, 0, TXT_FAULTY_PRODUCT);
			}
		}
		else if (cmd == "HTTP_RESPONSE")
		{
			if (id == farmHTTP)
			{
				string jsonTxt = llList2String(tok, 1);
				tok = [];
				tok = llJson2List(jsonTxt);
				cmd = llList2String(tok, 0);

				if (cmd == "ACTIONS")
				{
					string info =llList2String(tok, 1);

					if (info == "COMPLETE")
					{
						/*
							ACTIONS
							COMPLETE
							DESC
							WC Test task
							ID
							5
						*/
						string description = llList2String(tok, 3);
						string taskID = llList2String(tok, 5);

						// Tell user they have completed a task
						llRegionSayTo(user, 0, TXT_TASK_COMPLETED +": " +description);

						// Credit them 5 XP
						postMessage("task=creditxp&data1=" +user +"&data2=" +description +";" +taskID + "&data3=5&data4=" +privFlag);

					}
					else if (info == PREFIX)
					{
						// Sleep for a short period as tasks shouldn't be done to rapidly!
						state sleeper;
					}
					else if (info == "")
					{
						// No task was found to be done
					}
					else if (info == "NOID")
					{
						// USER DOESN'T HAVE AN ACCOUNT LINKED TO THIS AVATAR
					}
				}
				else if (cmd == "PLUSXP")
				{
					// Sleep for a short period as tasks shouldn't be done to rapidly!
					state sleeper;
				}
			}
		}
		else if (cmd == "SET-LANG")
		{
			languageCode = llList2String(tok, 1);
			loadLanguage(languageCode);
		}
		else if (cmd == "MENU_LANGS")
		{
			SUFFIX = llList2String(tok, 2);
		}
		else if (cmd == "LANGUAGE-REPLY")
		{
			SUFFIX = llList2String(tok, 3);
		}
	}

	on_rez(integer n)
	{
		llResetScript();
	}

}

// After handling a task we sleep for about a minute so as not to accidently re-triggering the task reporting
//
state sleeper
{
	state_entry()
	{
		llSetTimerEvent(65);
		debug("Entering sleep state");
	}

	timer()
	{
		llSetTimerEvent(0);
		debug("Leaving sleep state");

		state default;
	}

	on_rez(integer n)
	{
		llResetScript();
	}

}
