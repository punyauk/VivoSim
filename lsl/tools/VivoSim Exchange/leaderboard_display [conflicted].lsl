// ----------------------------------------
//  VivoSim Exchange - 'Leaderboard' Display board
//  leaderboard_display.lsl
// ----------------------------------------

float VERSION = 6.01;	// 27 March 2023

integer DEBUGMODE = FALSE;
debug(string text)
{
	if (DEBUGMODE == TRUE) llOwnerSay("DEBUG:" + llToUpper(llGetScriptName()) + " " + text);
}

// Server URL
string BASEURL = "";
string fontName = "Arial"; // Arial is the default font used, if unspecified

string txt_name = "Name";
string txt_score = "Score";
string txt_topten = "Leaderboard";
string langName = "en-GB";

vector GREEN       = <0.180, 0.800, 0.251>;
vector YELLOW      = <1.000, 0.863, 0.000>;
vector WHITE       = <1.0, 1.0, 1.0>;

integer quinActive;
integer  useBeta = FALSE;
key farmHTTP = NULL_KEY;
key owner;
integer FACE = 4;
string PASSWORD = "*";
list motdList;
string MOTD;
integer useHTTPS;


showTopTen(list scores)
{
	string body = "width:1024,height:1024,Alpha:0";
	string CommandList = "";  // Storage for our drawing commands
	string statusColour;
	// Set the font to use
	CommandList = osSetFontName(CommandList, fontName);
	// Draw a border
	if (quinActive == FALSE) {statusColour = "crimson";} else if (useBeta == TRUE) {statusColour = "gold";} else {statusColour = "chartreuse";}
	CommandList = osSetPenSize(CommandList, 50 );
	CommandList = osSetPenColor(CommandList, statusColour);
	CommandList = osMovePen(CommandList, 0,0);
	CommandList = osDrawRectangle(CommandList, 1020,1020);
	// Put header
	CommandList = osSetPenColor(CommandList, "green");
	CommandList = osSetFontSize(CommandList, 30);
	vector Extents = osGetDrawStringSize( "vector", txt_topten, "Arial", 30);
	integer xpos = 512 - ((integer) Extents.x >> 1);        // Center the text horizontally
	CommandList = osMovePen(CommandList, xpos, 30);         // Position the text
	CommandList = osDrawText(CommandList, txt_topten);      // Place the text
	//
	CommandList = osSetPenColor(CommandList, "oldlace");
	CommandList = osSetFontSize(CommandList, 26);
	CommandList = osMovePen(CommandList, 150,100);
	CommandList = osDrawText(CommandList, txt_name);
	CommandList = osMovePen(CommandList, 750,100);
	CommandList = osDrawText(CommandList, txt_score);
	CommandList = osSetFontSize(CommandList, 22);
	// Draw horizontal seperator line
	CommandList = osSetPenSize(CommandList, 3);
	CommandList = osDrawLine(CommandList, 60, 150, 990, 150);
	// Display table
	integer offset = 0;
	integer i;
	for (0; i<llGetListLength(scores)-1; i+=3)
	{
		// Name
		CommandList = osMovePen(CommandList, 150, (165 + offset));
		CommandList = osDrawText(CommandList, llList2String(scores, i));
		// Score
		CommandList = osMovePen(CommandList, 760, (165 + offset));
		CommandList = osDrawText(CommandList, (string)llList2Integer(scores, i+1));
		// Icon
		CommandList = osMovePen(CommandList, 85, (162 + offset));
		CommandList = osDrawImage(CommandList, 58, 58, llList2String(scores, i+2));  // Display small logo
		offset += 62;
	}
	// Put it all together and display on the prim face
	osSetDynamicTextureDataBlendFace("", "vector", CommandList, body, FALSE, 2, 0, 255, FACE);
	// Show MOTD
	showMOTD();
}

showMOTD()
{
	integer index = llListFindList(motdList, langName);
	if (index != -1)
	{
		MOTD = llList2String(motdList, index+1);
	}
	else
	{
		MOTD = llList2String(motdList, 1);
	}

	string body = "width:1024,height:1024,Alpha:0";
	string CommandList = "";  // Storage for our drawing commands
	string statusColour;
	// Set the font to use
	CommandList = osSetFontName(CommandList, fontName);
	// Check if there is a MOTD to display
	if (MOTD != "")
	{
		// Show MOTD background box
		CommandList = osSetPenSize( CommandList, 3 );
		CommandList = osSetPenColor( CommandList, "antiquewhite" );
		CommandList = osMovePen( CommandList, 100, 900 );
		CommandList = osDrawFilledRectangle( CommandList, 850, 80 );   // Size in pixels
		// Show MOTD text
		CommandList = osSetFontSize(CommandList, 25);
		CommandList = osSetPenColor(CommandList, "olivedrab");
		CommandList = osMovePen(CommandList, 125, 920);
		CommandList = osDrawText(CommandList, MOTD);
	}
	// Put it all together and display on the prim face
	osSetDynamicTextureDataBlendFace("", "vector", CommandList, body, TRUE, 2, 0, 255, FACE);
}

postMessage(string msg)
{
	debug("postMessage: " + msg +" to:"+BASEURL);
	if (BASEURL != "") farmHTTP = llHTTPRequest(BASEURL, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded", HTTP_BODY_MAXLENGTH, 16384], msg);
}


// --- STATE DEFAULT -- //

default
{

	on_rez(integer n)
	{
		llResetScript();
	}

	state_entry()
	{
		owner = llGetOwner();
		llPassTouches(1);
	}

	link_message(integer sender_num, integer num, string msg, key id)
	{
		debug("link_message: " + msg);

		list tk = llParseStringKeepNulls(msg, ["|"], []);
		string cmd = llList2String(tk,0);

		if (cmd == "LANG_TOPTEN")
		{
			txt_name = llList2String(tk, 1);
			txt_score = llList2String(tk, 2);
			txt_topten = llList2String(tk, 3);
			langName = llList2String(tk, 4);
		}
        else if (cmd == "CMD_INIT")
        {
			if (num ==1)
			{
				// PASSWORD|VERSION|RSTATE|ExchangeID|joomlaID|BASEURL|useBeta|fontName
				PASSWORD = llList2String(tk, 1);
				VERSION  = llList2Integer(tk, 2);
				VERSION  = (VERSION/100);
				BASEURL  = llList2String(tk, 6);
				useBeta  = llList2Integer(tk, 7);
				if (llList2String(tk, 8) != "") fontName = llList2String(tk, 8);
			}
			else
			{
				PASSWORD = llList2String(tk, 1);
			}
			quinActive = TRUE;
			llSetTimerEvent(1);
        }
		else if (cmd == "CMD_STOP")
		{
			quinActive = FALSE;
			llSetTimerEvent(0);
		}
		else if (cmd == "CMD_REFRESH")
		{
			// Call timer event right away to do a refresh
			llSetTimerEvent(0.1);
		}
		else if (cmd == "SETHTTPS")
		{
			BASEURL = llList2String(tk,1);
		}
		else if (cmd == "RESET")
		{
			llResetScript();
		}
	}

	timer()
	{
		if (quinActive == TRUE)
		{
			llSetTimerEvent(3500);
			postMessage("task=topten&data1=" + (string)owner);
		}
	}

	http_response(key request_id, integer Status, list metadata, string body)
	{
		debug("http_response - Status: " + Status + "\nbody: " + body);
		if (request_id == farmHTTP)
		{
			llSetColor(WHITE, 4);
		 	list tok = llJson2List(body);
			string cmd = llList2String(tok, 0);

			if (cmd == "TOPTEN")
			{
				llMessageLinked(LINK_SET, 1, "TOPTEN_OK", "");
                string steamData = llList2String(tok, 1);
				list streamValues = llParseStringKeepNulls(steamData, ["|"], []);
				showTopTen(streamValues);

				// Request the current release version of Exchange
				postMessage("task=chkver&data1=" + (string)owner);
			}
			else if (cmd == "TENFAIL")
			{
				llMessageLinked(LINK_SET, 0, "TOPTEN_ERROR", "");
				quinActive = FALSE;
				llSetTimerEvent(0);
			}
			else if (cmd = "VEREX")
			{
				// array('VEREX' => $verExch, 'MOTD' => trim($motd));
				llMessageLinked(LINK_SET, llList2Integer(tok, 1), "VERINFO|", "");
				// Create list of the language variations of MOTD
				motdList = llParseStringKeepNulls(llList2String(tok, 3), ["\n", "="], []);
				showMOTD();
			}
			else
			{
				debug(" == "+llList2String(tok,1));
			}
		}
		else
		{
			// Response not for this script
		}
	}

	dataserver( key id, string m)
	{
		debug("dataserver: " +m);
		list tk = llParseStringKeepNulls(m, ["|"], []);
		string cmd = llList2String(tk,0);
		integer i;
		//for updates
		if (cmd == "VERSION-CHECK")
		{
			string answer = "VERSION-REPLY|" + PASSWORD + "|";
			answer += (string)llGetKey() + "|" + (string)((integer)(VERSION*100)) + "|";
			integer len = llGetInventoryNumber(INVENTORY_OBJECT);
			while (len--)
			{
				answer += llGetInventoryName(INVENTORY_OBJECT, len) + ",";
			}
			len = llGetInventoryNumber(INVENTORY_SCRIPT);
			string me = llGetScriptName();
			while (len--)
			{
				string item = llGetInventoryName(INVENTORY_SCRIPT, len);
				if (item != me)
				{
					answer += item + ",";
				}
			}
			answer += me;
			osMessageObject(llList2Key(tk, 2), answer);
		}
		else if (cmd == "DO-UPDATE")
		{
			if (llGetOwnerKey(id) != llGetOwner())
			{
				llMessageLinked(LINK_SET, 0, "UPDATE-FAILED", "");
				return;
			}
			string me = llGetScriptName();
			string sRemoveItems = llList2String(tk, 3);
			list lRemoveItems = llParseString2List(sRemoveItems, [","], []);
			integer delSelf = FALSE;
			integer d = llGetListLength(lRemoveItems);
			while (d--)
			{
				string item = llList2String(lRemoveItems, d);
				if (item == me) delSelf = TRUE;
				else if (llGetInventoryType(item) != INVENTORY_NONE)
				{
					llRemoveInventory(item);
				}
			}
			integer pin = llRound(llFrand(1000.0));
			llSetRemoteScriptAccessPin(pin);
			osMessageObject(llList2Key(tk, 2), "DO-UPDATE-REPLY|"+PASSWORD+"|"+(string)llGetKey()+"|"+(string)pin+"|"+sRemoveItems);
			if (delSelf)
			{
				llRemoveInventory(me);
			}
			llSleep(10.0);
			llResetScript();
		}
	}

}
