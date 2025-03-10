// -------------------------------------------
//  VivoSim Exchange - Secondary display
//  secondary_display.lsl
// -------------------------------------------

float   VERSION = 6.00;    // 13 February 2023

integer DEBUGMODE = FALSE;
debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DEBUG:" + llToUpper(llGetScriptName()) + " " + text);
}

integer FACE = 4;
string  profileCover = "";
string  lastCover = "";

// --- STATE DEFAULT -- //

default
{

    on_rez(integer n)
    {
        llResetScript();
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        debug("link_message: " + msg +"  Num="+(string)num);
        list tk = llParseStringKeepNulls(msg, ["|"], []);
        string cmd = llList2String(tk,0);

        if (cmd == "SHOW_IMAGE")
        {
			profileCover = llList2String(tk, 1);

			if ((profileCover != "") && (profileCover != lastCover))
			{
				
				string CommandList = "";  // Storage for our drawing commands
				
				// Position image on prim face
				CommandList = osMovePen(CommandList, 0, 0);
				CommandList = osDrawImage(CommandList, 256, 256, profileCover);  

				// Put it all together and display on the prim face
				osSetDynamicTextureDataBlendFace("", "vector", CommandList, "width:256,height:256", FALSE, 1, 0, 255, FACE);

				// Keep a track of this cover so we don't need to re-draw it if it doesn't change
				lastCover = profileCover;
			}						
        }
		else if (cmd == "CMD_INIT")
		{
			profileCover = "";
			lastCover = "";
		}
        else if (cmd == "RESET")
        {
            llResetScript();
        }
    }

}
