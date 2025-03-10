/*
 * terminal-messages_indicator.lsl
 * Message manager for VivoSim - Indicator
 * @version    6.05
 * @date    29 March 2024
*/

integer xpFace = 0;                 // XP_FACE            ; Set to -1 if not used
integer msgFace = 2;                // MSG_FACE           ; Set to -1 if not used
string  fontName = "Tahoma";        // FONT=Tahoma        ; Also Arial or Georgia etc. See https://www.w3schools.com/cssref/css_websafe_fonts.php
integer fontSize = 90;
string  noMsgIcon = "icon_msg-white";
string  newMsgIcon = "icon_msg-green";
string  logoIcon = "vslogo";

integer newMsgCount = 0;
string ourXPMain = "-";
string ourXPSub = "-";

integer DEBUGMODE = FALSE;

debug(string text)
{
	if (DEBUGMODE == TRUE) llOwnerSay("DB_" + llToUpper(llGetScriptName()) + " " + text);
}

// displayNumber(integer num, integer face)
displayNumber(string numVal, integer face)
{
	if (face != -1)
	{
		integer num = llRound((float)numVal);
		vector size;
		string body = "width:256,height:256,Alpha:2";
		string commandList = "";

		// Set up font details
		commandList = osSetFontName(commandList, fontName);

		// Move pen and set colour
		if (face == msgFace)
		{
			// Set colour indicator for unread/read message count
			if (num >0)
			{
				llSetTexture(newMsgIcon, face);
				commandList = osSetPenColor(commandList, "GreenYellow" );
			}
			else
			{
				llSetTexture(noMsgIcon, face);
				commandList = osSetPenColor(commandList, "White" );
			}

			commandList = osMovePen(commandList, 150, 70);
			commandList = osSetFontSize(commandList, fontSize);

			// Set font to Bold
			commandList += "FontProp B;";
		}
		else
		{
			llSetTexture(logoIcon, face);
			commandList = osSetPenColor(commandList, "Gold" );
			commandList = osSetFontSize(commandList, fontSize - 40);

			// Center the text horizontally
			vector Extents = osGetDrawStringSize( "vector", numVal, fontName, fontSize - 40);
			integer xpos = 128 - ((integer) Extents.x >> 1);
			commandList = osMovePen(commandList, xpos, 165 );
		}

		// Set font to Bold
		commandList += "FontProp B;";

		// Write text
		commandList = osDrawText(commandList, numVal);

		// Output the result
		osSetDynamicTextureDataBlendFace("", "vector", commandList, body, TRUE, 2, 0, 255, face);
	}
}

saveData()
{
	llSetObjectDesc("V;" +(string)newMsgCount +";" +(string)ourXPMain);
}

default
{
	on_rez(integer n)
	{
		llResetScript();
	}

	state_entry()
	{
		list descValues = llParseString2List(llGetObjectDesc(), [";"], [""]);

		if (msgFace != -1) llSetTexture(noMsgIcon, msgFace);

		if (llList2String(descValues, 0) == "V")
		{
			newMsgCount = llList2Integer(descValues, 1);
			ourXPMain = llList2String(descValues, 2);
		}
		else
		{
			saveData();
		}

		displayNumber((string)ourXPMain, xpFace);

		displayNumber((string)newMsgCount, msgFace);
	}

	link_message(integer sender_num, integer num, string msg, key id)
	{
		debug("link_message:" + msg +" NUM=" +(string)num +"  From:" +(string)sender_num);
		list tok = llParseStringKeepNulls(msg, ["|"], []);
		string cmd = llList2String(tok,0);

		if (cmd == "NEW_MESSAGE")
		{
			newMsgCount = num;
			saveData();
			displayNumber((string)num, msgFace);
		}
		else if ((cmd == "CMD_XP") || (cmd == "XP"))
		{
			ourXPMain = llList2String(tok, 1);
			saveData();
			displayNumber((string)ourXPMain, xpFace);
		}
		else if (cmd == "TOUCHED")
		{
			newMsgCount = 0;
			saveData();
			displayNumber((string)newMsgCount, msgFace);
		}
		else if (cmd == "CMD_DEBUG")
		{
			DEBUGMODE = llList2Integer(tok, 1);
		}
	}

	changed(integer change)
	{
		if (change & CHANGED_OWNER)
		{
			// Clear the XP indicator until we know how many they have
			displayNumber("0", xpFace);
		}
	}

}
