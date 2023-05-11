
// addon-mailbox.lsl
//  Set the transparency of the prims called 'full' and 'empty'.
//  Version 1.0  15 March 2023

default
{
	
	link_message(integer l, integer n, string m, key id)
	{
		list tok = llParseString2List(m, ["|"], []);
		string cmd = llList2String(tok, 0);

		if (cmd == "MAIL")
		{
			integer i;
	
			for (i=1; i <= llGetNumberOfPrims(); i++)
			{
				if (llGetLinkName(i) == "full")
				{
					llSetLinkAlpha(i, n, ALL_SIDES);
				}
				
				if (llGetLinkName(i) == "empty")
				{
					llSetLinkAlpha(i, !n, ALL_SIDES);
				}
			}
		}
	}

}
