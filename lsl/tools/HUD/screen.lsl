/**
 * screen.lsl
 *
 * VIVOSIM HUD - Screen control
 *  Controls the positioning of the background screen
 *  (used to make float text more readable
*/

float version = 6.0;   //  23 March 2023

vector rot000 = <270, 0, 0>;
vector rot270 = <0, 0,0>;
float  onAlpha = 0.75;

default
{

    state_entry()
    {
       //Rotate 0 degrees about Y-axis
        llSetLocalRot(llEuler2Rot(rot000 * DEG_TO_RAD));
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        list tk = llParseStringKeepNulls(msg , ["|"], []);
        string cmd = llList2String(tk, 0);

        if (cmd == "SCREENOFF")
        {
            llSetAlpha(0, ALL_SIDES);
        }
        else if (cmd == "ROT270")
        {
            //Rotate 270 degrees about Y-axis
            llSetLocalRot(llEuler2Rot(rot270 * DEG_TO_RAD));
            llSetAlpha(onAlpha, ALL_SIDES);
        }
        else if (cmd == "ROT000")
        {
            //Rotate 0 degrees about Y-axis
            llSetLocalRot(llEuler2Rot(rot000 * DEG_TO_RAD));
            llSetAlpha(onAlpha, ALL_SIDES);
        }
    }

}
