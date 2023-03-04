// Weather repeater - overhead flashes if not using prim lightning
//  Version 1.0     10 October 2022

string  thunderFx = "thunderfx";
integer flashCount = 0;
    
on()
{
    llSetPrimitiveParams([PRIM_POINT_LIGHT, TRUE, <0.418, 0.582, 0.551>, 1.0, 10, 0.1, PRIM_FULLBRIGHT, ALL_SIDES,1, PRIM_GLOW, ALL_SIDES, 1.0]);
}
    
off()
{
    llSetPrimitiveParams([PRIM_POINT_LIGHT, FALSE, <1,1,1>, 1.0, 10, 0.1, PRIM_FULLBRIGHT, ALL_SIDES,0, PRIM_GLOW, ALL_SIDES, 0.0]);
}

    
default
{
    link_message(integer sender_num, integer num, string str, key id)
    {
        list tk = llParseString2List(str, ["|"], []);
        string cmd = llList2String(tk, 0);

        if ((cmd == "LIGHTNING") && (num == -1))
        {
            flashCount = 0;
            state flash;
        }
        else if (cmd == "RESET")
        {
            llSetTimerEvent(0);
            flashCount = 0;
        }
    }
}
    
state flash
{
    state_entry()
    {
        flashCount = 0;
        llSetTimerEvent(0.1);
    }
    
    timer()
    {
        if (flashCount == 0) llSetTimerEvent(0.1);
        flashCount++;
        if (flashCount < 25)
        {
            if (llFrand(50) < 10) on();  else off(); 
        }
        else
        {
            // Generate suffix of either 1 or 0
            integer rndNum = (integer)llFrand(2.5);
            // Random selection of playing thunderFx0 or thunderFx2
            llPlaySound(thunderFx+(string)rndNum, 1.0);
            llSetTimerEvent(25);
            off();
            flashCount = 0;
        }    
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        list tk = llParseString2List(str, ["|"], []);
        string cmd = llList2String(tk, 0);

        if (cmd == "RESET")
        {
            llSetTimerEvent(0);
            off(); 
            llStopSound();
            state default;
        }
    }
        
}
