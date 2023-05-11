/**
 * display-text.lsl
 *
 * ViviSim HUD - Float text anchor
 * Generates float text so as to be positioned nicely over background screen prim
**/

float version = 6.03;   //  1 April 2023

integer DEBUGMODE = FALSE;

debug(string text)
{
    if ((DEBUGMODE == TRUE) || (systemDebug == TRUE)) llOwnerSay("DB_" + llGetScriptName() + ": " + text);
}

list    textBuffer = [];
integer displayTime = 3;
integer systemDebug = FALSE;
integer lastTs;


/**
 *  displayText is:   [text|colour|priority] [text|colour|priority] ...
 */
showText()
{
    string displayText = llList2String(textBuffer, 0);
    vector colour = llList2Vector(textBuffer, 1);
    integer shortOnly = llList2Integer(textBuffer, 2);

	if (llStringLength(displayText) > 40)
	{
		llMessageLinked(LINK_ALL_CHILDREN, 1, "ROT270", "");
	}
	else
	{
		llMessageLinked(LINK_ALL_CHILDREN, 1, "ROT000", "");
	}

    llSetText(displayText, colour, 1);

    if (llGetListLength(textBuffer) >3)
    {
        // Update list by removing first 3 entries
        textBuffer = llList2List(textBuffer, 3, -1);
    }
    else
    {
        textBuffer = [];
    }

    if (shortOnly) llSetTimerEvent(0.2);
}

default
{

    state_entry()
    {
        llSetTimerEvent(0);
        llSetText("", ZERO_VECTOR, 0.0);
        llMessageLinked(LINK_ALL_OTHERS, 0, "SCREENOFF", "");
        lastTs = -1;
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        list tk = llParseStringKeepNulls(msg , ["|"], []);
        string cmd = llList2String(tk, 0);

        if (cmd == "SHOWTEXT")
        {
            string ourMsg = llStringTrim(llList2String(tk, 1), STRING_TRIM);

            if (llStringLength(ourMsg) != 0)
            {
                vector ourColr = llList2Vector(tk, 2);
                integer priority = llList2Integer(tk, 3);
                integer buffSize = llGetListLength(textBuffer);

                debug("SHOWTEST |" +ourMsg +"|" +(string)ourColr +"|" +(string)priority +" (" +(string)buffSize +")");

                float ourTime = displayTime - (llGetUnixTime() - lastTs);
                if (ourTime < 0.1) ourTime = 0.1;

                textBuffer = textBuffer + [ourMsg] + [ourColr] + [priority];

                debug("Elapsed time=" +(string)(llGetUnixTime() - lastTs) +" setTimer=" +(string)ourTime);

                llSetTimerEvent(ourTime);
            }
        }
        else if (cmd == "SCREENOFF")
        {
            llSetText("", ZERO_VECTOR, 0.0);
        }
		else if (cmd == "DISPLAY_TIME")
		{
			displayTime = llList2Integer(tk, 1);
		}
        else if (cmd == "CMD_DEBUG")
        {
            systemDebug = llList2Integer(tk, 1);
        }
    }

    timer()
    {
        debug("\n===\ntextBuffer:\n" +llDumpList2String(textBuffer, "|") +"\n===\n" );

        if (llGetListLength(textBuffer) != 0)
        {
            llSetTimerEvent(displayTime);
            showText();
            lastTs = llGetUnixTime();
        }
        else
        {
            llSetTimerEvent(0);
            llSetText("", ZERO_VECTOR, 0.0);
            llMessageLinked(LINK_ALL_OTHERS, 0, "SCREENOFF", "");
            lastTs = -1;
        }

    }

    on_rez(integer num)
    {
        llResetScript();
    }

}
