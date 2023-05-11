/**
 * NOT USE NOW - REPLACED BY display-txt.lsl

 * ViviSim HUD - Float text anchor
 * Generates float text so as to be positioned nicely over background screen prim
**/

float version = 6.0;   //  24 March 2023

string  lastText;
integer screenTs;

floatText(string msg, vector colour, integer raw)
{
	string sendMsg = "";

	if (msg != lastText)
	{
		if (llStringLength(msg) == 0)
		{
			txt_off();
			lastText = "";
			screenTs = -1;
		}
		else
		{
			// Get the time stamp for when we put a message up, so can allow time for it to be read
			screenTs = llGetUnixTime();

			if (llStringLength(msg) > 40)
			{
				llMessageLinked(LINK_ALL_CHILDREN, 1, "ROT270", "");
			}
			else
			{
				llMessageLinked(LINK_ALL_CHILDREN, 1, "ROT000", "");
			}

			if (raw == TRUE) sendMsg = wasSpaceWrap(msg, "\n", 64) +"|" +(string)colour; else sendMsg = msg +"|" +(string)colour;

			llMessageLinked(LINK_ALL_CHILDREN, 1, "SHOWTEXT|"+sendMsg, "");
			lastText = msg;
		}
	}
}

txt_off()
{
	// If something was on the screen we should wait at least 30 seconds before clearing it
	if ((llGetUnixTime() - screenTs > 30) || (screenTs == -1))
	{
		llSetText("", ZERO_VECTOR, 0);
		llMessageLinked(LINK_SET, 1, "SCREENOFF", "");
		lastText = "";
		screenTs = -1;
	}
}

string wasSpaceWrap(string txt, string delimiter, integer column)
{
	/* Takes a string, delimiter & column number and outputs string split at the first space after column
	Copyright (C) 2011 Wizardry and Steamworks https://grimore.org/fuss/lsl#character_handling  */
	string ret = llGetSubString(txt, 0, 0);
	integer len = llStringLength(txt);
	integer itra=1;
	integer itrb=1;
	do {
		if(itrb % column == 0) {
			while(llGetSubString(txt, itra, itra) != " ") {
				ret += llGetSubString(txt, itra, itra);
				if(++itra>len) return ret;
			}
			ret += delimiter;
			itrb = 1;
			jump next;
		}
		ret += llGetSubString(txt, itra, itra);
		++itrb;
@next;
	} while(++itra<len);
	return ret;
}

default
{

    state_entry()
    {
        llSetTimerEvent(0);
        llSetText("", ZERO_VECTOR, 0.0);
		lastText = "";
		screenTs = -1;
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        list tk = llParseStringKeepNulls(msg , ["|"], []);
        string cmd = llList2String(tk, 0);

        if (cmd == "SHOWTEXT")
        {
            //llSetText(llList2String(tk, 1), llList2Vector(tk, 2), 1.0);
			floatText(llList2String(tk, 1), llList2Vector(tk, 2), num);

            // Set a timeout to clear any text
            llSetTimerEvent(45);
        }
        else if (cmd == "SCREENOFF")
        {
            llSetText("", ZERO_VECTOR, 0.0);
        }
    }

    timer()
    {
        llSetTimerEvent(0);
        llSetText("", ZERO_VECTOR, 0.0);
        llMessageLinked(LINK_ALL_OTHERS, 0, "SCREENOFF", "");
    }

}
