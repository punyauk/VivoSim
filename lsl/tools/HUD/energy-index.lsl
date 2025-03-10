// -------------------------------------------
/*  energy-index.lsl
 *
 *  QUINTONIA FARM HUD - Energy index display
 *  Shows percentage level for energy
*/

float version = 6.0.3;    // 2 April 2023

string cmd = "ENERGY";
float level;
integer face =3;

vector veryGreen = <0.117, 1.000, 0.117>;
vector semiGreen = <0.719, 1.000, 0.719>;
vector white = <1.000, 1.000, 1.000>;

default
{

    state_entry()
    {
        llSetLinkPrimitiveParams(LINK_THIS,[PRIM_SLICE,<0.0, 0.0, 0.0>]);
		llSetColor(white, face);
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if (msg == cmd)
        {
            level = num / 100.0;
            llSetLinkPrimitiveParams(LINK_THIS,[PRIM_SLICE,<0.0, level, 0.0>]);

			if (level > 0.8)
			{
				llSetColor(veryGreen, face);
			}
			else if (level > 0.5)
			{
				llSetColor(semiGreen, face);
			}
			else
			{
				llSetColor(white, face);
			}
        }
    }
}
