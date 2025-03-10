/*
 hud-ring.lsl

 VIVOSIM FARM HUD - Ring status display
  Shows the status of either HUNGER, THIRST, BLADDER, HYGIENE
  or HEALTH as a circular scale.
   Note that the script should be names to match the function (so hunger, thirst etc)
*/

float version = 6.03;        // 1 April 2023

vector RED       = <1.000, 0.255, 0.212>;
vector ORANGE    = <1.000, 0.522, 0.106>;
vector YELLOW    = <1.000, 0.863, 0.000>;
vector TEAL      = <0.004, 0.606, 0.395>;
vector GREEN     = <0.204, 0.343, 0.171>;
vector GRAY      = <0.667, 0.667, 0.667>;
vector BLACK     = <0, 0, 0>;
vector WHITE     = <1, 1, 1>;

integer FACE = 1;

string  cmd;
vector  dialcolour;
float   level;
integer active;
integer levelTeal;
integer levelYellow;
integer levelOrange;
integer levelRed;
integer amDead = FALSE;
integer showNumbers = TRUE;

updateIndicator()
{
    llSetPrimitiveParams([PRIM_TYPE,
          PRIM_TYPE_CYLINDER,
          PRIM_HOLE_DEFAULT,   // hole_shape
          <0.0, 1, 1>,         // cut
          0.0,                 // hollow
          <0.0, 0.0, 0.0>,     // twist
          <1.5, 0.4, 0.0>,    // top_size (taper)
          <0.5, 0.0, 0.0>,     // top_Shear
          PRIM_SLICE,<0.0, level, 0.0>,
          PRIM_COLOR, FACE, dialcolour, 0.75
    ]);
}

default
{

    state_entry()
    {
        cmd = llToUpper(llGetScriptName());
        dialcolour = GRAY;
        level = 0.0;
        active = TRUE;
        updateIndicator();
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if (msg == cmd)
        {
            if (active == TRUE)
            {
                dialcolour = GREEN;

                if ((cmd == "HUNGER") || (cmd == "THIRST"))
                {
                    levelTeal = 40;
                    levelYellow = 50;
                    levelOrange = 70;
                    levelRed = 75;
                }
                else
                {
                    levelTeal = 20;
                    levelYellow = 45;
                    levelOrange = 65;
                    levelRed = 70;
                }
                if (num > levelTeal)
                {
                    dialcolour = TEAL;
                }
                if (num > levelYellow)
                {
                    dialcolour = YELLOW;
                }
                if (num > levelOrange)
                {
                    dialcolour = ORANGE;
                }
                if (num > levelRed)
                {
                    dialcolour = RED;
                }

                level = num / 100.0;
                updateIndicator();

                if (showNumbers == TRUE)
                {
					if (num < 0) num = 0;
                    llSetText((string)num +"\n  ", WHITE, 1.0);
                }
            }
        }
        else if (msg == cmd+"OFF")
        {
            llSetAlpha(0.1, ALL_SIDES);
			llSetText("", ZERO_VECTOR, 0.0);
            active = FALSE;
        }
        else if (msg == cmd+"ON")
        {
            llSetAlpha(1.0, ALL_SIDES);
            active = TRUE;
            dialcolour = GRAY;
            level = 0.0;
            updateIndicator();
        }
        else if (msg == "RINGNUMS")
        {
            showNumbers = num;
            if (showNumbers == FALSE) llSetText("", ZERO_VECTOR, 0.0);
        }
        else if (msg =="AM_DEAD")
        {
            if (num == 0)
            {
                if (amDead == FALSE)
                {
                    amDead = TRUE;
                    llSetAlpha(1.0, ALL_SIDES);
                    dialcolour = BLACK;
                    level = 1.0;
                    llSetColor(BLACK, ALL_SIDES);
                }
            }
            else if (num == 1)
            {
                dialcolour = GRAY;
                level = 0.0;
                llSetAlpha(1.0, ALL_SIDES);
                llSetColor(GRAY, ALL_SIDES);
            }
            else
            {
                amDead = FALSE;
                llSetColor(WHITE, ALL_SIDES);
                llResetScript();
            }
            updateIndicator();
        }
        else if (msg == "RESET")
        {
            llSetAlpha(1.0, ALL_SIDES);
            llSetColor(WHITE, ALL_SIDES);
            llResetScript();
        }
    }
}
