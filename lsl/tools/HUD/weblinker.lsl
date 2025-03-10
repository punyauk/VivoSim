// weblinker.lsl
// Allows user to link their existing avatar from any grid, to a VivoSim Joomla web account

float version = 6.01;    // 26 March 2023

integer DEBUGMODE = FALSE;
debug(string text)
{
	if (DEBUGMODE == TRUE) llOwnerSay("DEBUG_" + llToUpper(llGetScriptName()) + " " + text);
}

// Multilingual support
string TXT_REGISTRATION="Registration";
string TXT_INSTRUCTION1="Log in to your VivoSim account and go to your profile page https://vivosim.net/profile";
string TXT_INSTRUCTION2="Copy the code under 'Your HUD link key' in the Link Key box on the right, then paste the code in here";
string TXT_CODE_ERROR="Sorry, code not recognised";
string TXT_VERIFY_ERROR="Sorry, unable to verify with server";
string TXT_TALKING_TO_SERVER="Talking to server...";
string TXT_CLOSE="CLOSE";
//
string languageCode = "";
//
integer dialogChannel;
key userToPay;
key req_id2 = NULL_KEY;
string code;    // The activation code we give them
vector RED      = <1.000, 0.255, 0.212>;
vector PURPLE   = <0.694, 0.051, 0.788>;

integer chan(key u)
{
	return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

integer listener = -1;
integer listenTs;

startListen()
{
	if (listener<0)
	{
		listener = llListen(chan(llGetKey()), "", "", "");
		listenTs = llGetUnixTime();
	}
}

checkListen()
{
	if (listener > 0 && llGetUnixTime() - listenTs > 300)
	{
		llListenRemove(listener);
		listener = -1;
	}
}

refresh()
{
	llListenRemove(listener);
	listener = -1;
}

postMessage(string msg)
{
	req_id2 = llGetKey();
	llMessageLinked(LINK_SET, 1, "CMD_POST|"+msg, req_id2);
}

floatText(string msg, vector colour)
{
	llMessageLinked(LINK_SET, 1 , "TEXT|" + msg + "|" + (string)colour + "|", NULL_KEY);
}

loadConfig()
{
	if (llGetInventoryType("config") == INVENTORY_NOTECARD)
	{
		list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
		integer i;
		for (i=0; i < llGetListLength(lines); i++)
		{
			string line = llStringTrim(llList2String(lines, i), STRING_TRIM);

			if (llGetSubString(line, 0, 0) != ";")
			{
				list tok = llParseStringKeepNulls(line, ["="], []);
				string cmd = llList2String(tok, 0);
				string val = llList2String(tok, 1);
				if (cmd == "LANG") languageCode = val;
			}
		}
	}
}

loadLanguage(string langCode)
{
	// optional language notecard
	string languageNC = langCode + "-lang";
	if (llGetInventoryType(languageNC) == INVENTORY_NOTECARD)
	{
		list lines = llParseStringKeepNulls(osGetNotecard(languageNC), ["\n"], []);
		integer i;
		for (i=0; i < llGetListLength(lines); i++)
		{
			string line = llList2String(lines, i);
			if (llGetSubString(line, 0, 0) != ";")
			{
				list tok = llParseString2List(line, ["="], []);
				if (llList2String(tok,1) != "")
				{
					string cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
					string val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

					// Remove start and end " marks
					val = llGetSubString(val, 1, -2);

					// Now check for language translations
						 if (cmd == "TXT_REGISTRATION") TXT_REGISTRATION = val;
					else if (cmd == "TXT_INSTRUCTION1") TXT_INSTRUCTION1 = val;
					else if (cmd == "TXT_INSTRUCTION2") TXT_INSTRUCTION2 = val;
					else if (cmd == "TXT_INSTRUCTION2") TXT_INSTRUCTION2 = val;
					else if (cmd == "TXT_CODE_ERROR") TXT_CODE_ERROR = val;
					else if (cmd == "TXT_VERIFY_ERROR") TXT_VERIFY_ERROR = val;
					else if (cmd == "TXT_TALKING_TO_SERVER") TXT_TALKING_TO_SERVER = val;
					else if (cmd == "TXT_CLOSE") TXT_CLOSE = val;
				}
			}
		}
	}
}

// --- STATE DEFAULT -- //

default
{

	state_entry()
	{
		listener=-1;
		loadConfig();
		loadLanguage(languageCode);
	}

	link_message(integer sender_num, integer num, string msg, key id)
	{
		debug("link_message:"+msg);
		list tok = llParseStringKeepNulls(msg, ["|"], []);
		string cmd = llList2String(tok,0);

		if (cmd == "CMD_LANG")
		{
			languageCode=llList2String(tok, 1);
			loadLanguage(languageCode);
			refresh();
		}
		else if (cmd == "CMD_LINKACC")
		{
			userToPay = id;
			if (userToPay == NULL_KEY) userToPay = llGetOwner();
			listener = llListen( dialogChannel, "", "", "");
			llTextBox(id, "\n" +TXT_INSTRUCTION1+"\n \n" +TXT_INSTRUCTION2 +":", dialogChannel);
		}
		else if (cmd == "HTTP_RESPONSE")
		{
			floatText("", PURPLE);
			string jsonTxt = llList2String(tok, 1);
			tok = [];
			tok = llJson2List(jsonTxt);
			cmd = llList2String(tok, 0);

			if (cmd == "LINKED")
			{
				if (llList2String(tok, 1) == "INVALID-J")
				{
					llMessageLinked(LINK_SET, -1, "CMD_LINKRESULT", llList2Key(tok, 3));
				}
				else
				{
					llMessageLinked(LINK_SET, 1, "CMD_LINKRESULT", llList2Key(tok, 3));
					llMessageLinked(LINK_SET, 0, "NOW_LINKED", userToPay);
				}
			}
			else if ((cmd == "REJECT") || (cmd == "DISABLE"))
			{
				llOwnerSay(TXT_VERIFY_ERROR);
				llMessageLinked(LINK_SET, 0, "CMD_LINKRESULT", userToPay);
				llResetScript();
			}
		}
	}

	timer()
	{
		refresh();
		llSetTimerEvent(600);
		checkListen();
	}

	listen(integer c, string nm, key id, string m)
	{
		// code should be xxx-yyy or xxx-yyyy  where y is joomlaID  e.g. key-1037
		if (llStringLength(m) < 7)
		{
			// Error, key code not correct format
			floatText(TXT_CODE_ERROR, RED);
		}
		else
		{
			floatText(TXT_TALKING_TO_SERVER, PURPLE);
			string jStr = llGetSubString(m, 4, llStringLength(m));
			postMessage("task=adduser&data1=" + jStr + "&data2=" + (string)userToPay);
		}

		refresh();

	}


}
