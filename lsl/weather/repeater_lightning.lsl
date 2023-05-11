// Weather repeater - prim lightning
//  Version 1.0   11 December 2022

float   glow = 0.30;
string  thunderFxBase = "thunder";
//
vector  fullSizeA = <26.18600, 33.48831, 34.13793>;   // Main lightning prim
vector  fullSizeB = <19.73479, 19.73479, 25.28120>;   // Secondary lightning prim
vector  fullSize;
integer fxActive = FALSE;



stopFx()
{
    llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, 0.0]);
    llStopSound();
    llSetScale(<0.01, 0.01, 0.01>);
    fxActive = FALSE;
}

doFX()
{
    string thunderFx = thunderFxBase +(string)(1+(integer)llFrand(3));   
    llSetScale(fullSize);
    llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, glow]);
    llStopSound();
    llPlaySound(thunderFx, 1.0);
    fxActive = TRUE;
    llSetTimerEvent(1);
}

tryLightning()
{
    if (llFrand(15.0)>8)
    {
        doFX();
    }
    else
    {
        stopFx();
        llSetTimerEvent(20);
    }
}


default
{
    state_entry()
    {
        if (llGetObjectDesc() == "lightning-a") fullSize = fullSizeA; else fullSize = fullSizeB;
        stopFx();
        llSetTimerEvent(0);
    }

    on_rez(integer num)
    {
        llResetScript();
    }

    link_message(integer sender_num, integer num, string message, key id)
    {       
        if (message == "LIGHTNING")
        {
            if (num == 1)
            {
                tryLightning();
            }
            else if (num == -1)
            {
                // DO FLASHES
            }
            else
            {
                stopFx();
            }
        }
        else if (message == "RESET")
        {
            llResetScript();
        }
        else if (message == "DEBUG")
        {
            if (num == 1)
            {
                llSetScale(fullSize);
                llSetAlpha(0.5, ALL_SIDES);
            }
            else
            {
                llSetScale(<0.01, 0.01, 0.01>);
                llSetAlpha(0.0, ALL_SIDES);
            }
        }
    }

    timer()
    {
        if (fxActive == TRUE)
        {
            llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, 0.0]);
            llStopSound();
            llSetScale(<0.01, 0.01, 0.01>);
            fxActive = FALSE;
        }
        else tryLightning();
    }


}
