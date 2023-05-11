/**
 * mailbox.lsl
 *
 * Mailbox that allows people to send a message direct to the owner
 */

float   VERSION = 1.00;		// 15 March 2023

// Default values that can be overidden from config notecard
integer accessMode = 0;				// ACCESS_MODE		; Can be used by  0=Everyone, 1=Group, 2=Local residents
integer sendMode = 0;				// RECIPIENT=self	; Send messages to  self  or  coop 
string  languageCode = "en-GB";		// LANG=en-GB		; Default language to use

// Language strings
string TXT_IDLE = "Ready";
string TXT_GROUP_ONLY = "Sorry, only members of the group can use me";
string TXT_LOCAL_ONLY = "Sorry, local residents can use me";
string TXT_NOT_AVAILABLE = "Sorry, not able to accept messages";
string TXT_ENTER_MESSAGE = "Please type your message for";
string TXT_TIMEOUT = "Sorry, timed out waiting for your message";
string TXT_TALKING_TO_SERVER = "Talking to server...";
string TXT_MSG_SENT = "Your message has been sent";

string SUFFIX = "M4";		// For language notecard selection

key ownerID;
string ownerName;
key toucherID;
string toucherName;
key coopID;
string coopName;
string blockListNC = "bnls";	// Notecard with any avatar UUID's that are not allowed
list blockList; 				// List of avatar ID's that can not use this
list blockNames = [];
integer timeOut = 15;			// How long to wait for comms to return a value
integer listener;				// ID for active listener
string status;
key farmHTTP = NULL_KEY;

// Colours
vector RED      = <1.000, 0.255, 0.212>;
vector GREEN    = <0.180, 0.800, 0.251>;
vector PURPLE   = <0.694, 0.051, 0.788>;

integer chan(key u)
{
	return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

string generateID(integer private)
{
	string result = (string)llGetUnixTime();

	if (private == TRUE)
	{
		result = "PRV" + result;
	}

	return result;
}

postMessage(string msg)
{
	farmHTTP = llGetKey();
	llMessageLinked(LINK_SET, 1, "CMD_POST|"+msg, farmHTTP);
	llSetTimerEvent(timeOut);
}

floatText(string msg, vector colour)
{
	llSetText(msg, colour, 1.0);
}

integer blocked(key userID)
{
	integer blockFlag = FALSE;
	integer i;
	integer count;
	count = llGetListLength(blockNames);
	string name = llKey2Name(userID);
	string shortName = llList2String(llParseString2List(name, [" "], []), 0);

	for (i = 0; i < count; i++)
	{
		if (llToLower(shortName) == llToLower(llList2String(blockNames, i)) )
		{
			blockFlag = TRUE;
		}
	}

	return blockFlag;
}

loadConfig()
{
	// Load values from config notecard
	if (llGetInventoryType("config") == INVENTORY_NOTECARD)
	{
		list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
		integer i;
		for (i=0; i < llGetListLength(lines); i++)
		{
			list tok = llParseString2List(llList2String(lines,i), ["="], []);
			if (llList2String(tok,1) != "")
			{
				string cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
				string val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

					 if (cmd == "ACCESS_MODE") accessMode = (integer)val;
				else if (cmd == "LANG") languageCode = val;
				else if (cmd == "RECIPIENT")
				{
					// 0 for 'self'  1 for 'coop' 
					if (llToLower(val) == "coop") sendMode = 1; else sendMode = 0;
				}
			}
		}
	}
}

loadBlockList()
{
    blockNames = [];
    integer index;

    if (llGetInventoryType(blockListNC) == INVENTORY_NOTECARD)
    {
        list lines = llParseStringKeepNulls(osGetNotecard(blockListNC), ["\n"], []);

        for (index = 0; index < llGetListLength(lines); index++)
        {
            string line = llList2String(lines, index);
            blockNames += line;
        }
    }
}

loadLanguage(string langCode)
{
	// optional language notecard
	string languageNC = langCode + "-lang" + SUFFIX;
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
							if (cmd == "TXT_IDLE") TXT_IDLE = val;
					else if (cmd == "TXT_GROUP_ONLY") TXT_GROUP_ONLY = val;
					else if (cmd = "TXT_LOCAL_ONLY") TXT_LOCAL_ONLY = val;
					else if (cmd = "TXT_NOT_AVAILABLE") TXT_NOT_AVAILABLE = val;
					else if (cmd = "TXT_ENTER_MESSAGE") TXT_ENTER_MESSAGE = val;
					else if (cmd = "TXT_TIMEOUT") TXT_TIMEOUT = val;
					else if (cmd = "TXT_TALKING_TO_SERVER") TXT_TALKING_TO_SERVER = val;
					else if (cmd = "TXT_MSG_SENT") TXT_MSG_SENT = val;
				}
			}
		}
	}
}

default
{
	state_entry()
	{
		ownerID = llGetOwner();
		ownerName = llKey2Name(ownerID);
		loadConfig();
		loadLanguage(languageCode);
		loadBlockList();

		// Set coop ID to be same as owner ID for now as will update later if there is a valid coopID
		coopID = ownerID;
		
		// Set everything as read, no mail
		floatText(TXT_IDLE, GREEN);
		llMessageLinked(LINK_SET, 0, "MAIL", "");
	}

	touch_end(integer num)
	{
		toucherID = llDetectedKey(0);

		// Owner always allowed!
		if (toucherID != ownerID)
		{
			if (blocked(toucherID) == TRUE)
			{
				llRegionSayTo(toucherID, 0, TXT_NOT_AVAILABLE);
				return;
			}

			// 0=Everyone, 1=Group, 2=Local residents
			if (accessMode != 0)
			{
				if (accessMode == 1)
				{
					if (llDetectedGroup(0) == FALSE)
					{
						llRegionSayTo(toucherID, 0, TXT_GROUP_ONLY);
						return;
					}
				}
				else if (osGetAvatarHomeURI(toucherID) != osGetGridHomeURI())
				{
					llRegionSayTo(toucherID, 0, TXT_LOCAL_ONLY);
					return;
				}
			}
		}

		// If they get here they are allowed to use the mailbox		
		if (toucherID == ownerID)
		{
			// Touched by owner so reset to no mail state
			llMessageLinked(LINK_SET, 0, "MAIL", "");
		}
		else
		{
			listener = llListen(chan(llGetKey()), "", "", "");
			status = "waitMessageText";
			llTextBox(toucherID, TXT_ENTER_MESSAGE +" " +ownerName +"\n", chan(llGetKey()));
			llSetTimerEvent(timeOut);
		}
	}

	listen(integer channel, string name, key id, string message)
	{
		if (status == "waitMessageText")
		{
			floatText(TXT_TALKING_TO_SERVER, PURPLE);
			status = "";
			toucherName = llKey2Name(toucherID);
			
			string recipient;

			if (sendMode == 0) recipient = (string)ownerID; else recipient = (string)coopID;

			postMessage("task=msgadd&data1=" +message +"\n(" +toucherName +")"  +"&data2=" +generateID(TRUE) +"&data3=" +recipient);
		}
	}

	timer()
	{
		llSetTimerEvent(0);

		if (status == "waitMessageText")
		{
			// Timed out waiting for dialog box response
			status = "";
			llRegionSayTo(toucherID, 0, TXT_TIMEOUT);
			llListenRemove(listener);
		}
		else
		{
			floatText(TXT_IDLE, GREEN);
		}
	}

	link_message(integer sender_num, integer num, string msg, key id)
	{
		list tok = llParseStringKeepNulls(msg, ["|"], []);
		string cmd = llList2String(tok,0);

		if (cmd == "HTTP_RESPONSE")
		{
			if (id == farmHTTP)
			{
				list dataStream = llParseStringKeepNulls(msg , ["|"], []);
				list tk = llJson2List(llList2String(dataStream, 1));
				cmd = llList2String(tk, 0);

				if (cmd == "MSGADD")
				{
					floatText(TXT_MSG_SENT, GREEN);
					status = "";
					
					// Send message to any indicators that we have mail
					llMessageLinked(LINK_SET, 1, "MAIL", "");
					llSetTimerEvent(5);
				}
			}
		}
	}

}
