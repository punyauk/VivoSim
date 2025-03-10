// coin.lsl
//

float version = 6.02;   //  29 March 2024

integer DEBUGMODE = FALSE;
debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DEBUG_" + llToUpper(llGetScriptName()) + " " + text);
}

integer COIN_FACE  = 0;
integer coinTotal;

showCoins(string total)
{
    string sData = "";
    integer fontSize;
    sData = osSetPenColor(sData, "mistyrose");
    sData = osSetFontName(sData, "Arial");

	// As number gets larger, reduce font size so still fits on coin!
    if ((integer)total >99999)
	{
		fontSize = 19;
	}
	else if ((integer)total >9999)
	{
		fontSize = 23;
	}
	else
	{
		fontSize = 26;
	}

	sData = osSetFontSize(sData, fontSize);
    sData += "FontProp B;";

	vector Extents = osGetDrawStringSize( "vector", total, "Arial", fontSize);
    integer xpos = 64 - ((integer) Extents.x >> 1);  // Center the text horizontally
    sData = osMovePen(sData, xpos, 43);
    sData = osDrawText(sData, total);

	// Now draw it out
    osSetDynamicTextureDataBlendFace("", "vector", sData, "width:128,height:128,Alpha:32", FALSE, 2, 0, 255, COIN_FACE);
}

indicatorReset()
{
    llSetAlpha(0.25, COIN_FACE);
    llSetTexture("quintoCoin", COIN_FACE);
	showCoins("-");
}

default
{

    attach(key id)
    {
        indicatorReset();
        llSetTimerEvent(10);
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        debug("link_message:" + msg);
        list tk = llParseStringKeepNulls(msg, ["|"], []);
        string cmd = llList2String(tk,0);

        if (cmd == "CMD_COINS")
        {
            showCoins(llList2String(tk, 1));
            coinTotal = llList2Integer(tk,1);
            llSetObjectDesc((string)coinTotal + ";" + (string)llGetUnixTime());
            llSetAlpha(0.9, COIN_FACE);
        }
        else if (cmd == "COIN_CLEAR")
        {
            indicatorReset();
        }
		else if (cmd == "NOW_LINKED")
		{
			indicatorReset();
		}
    }

	touch_end( integer num_detected )
	{
		llMessageLinked(LINK_ALL_OTHERS, 0, "CMD_COIN_CHECK|*|" +(string)llGetOwner(), "");
	}

    timer()
    {
        llSetTimerEvent(0);
        llMessageLinked(LINK_ALL_OTHERS, 0, "CMD_COIN_CHECK|*|" +(string)llGetOwner(), "");
    }

	changed(integer change)
	{
		if (change & CHANGED_OWNER)
		{
			// Clear the XP indicator until we know how many they have
			showCoins("0");
		}
	}

}
