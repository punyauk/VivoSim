//  Weather system repeater - listens on the farm channel for weather related messages
//   WR_SOUND,  WR_RAIN, WR_CLOUDS, WR_FXEND, WR_RESET, WR_DEBUG
//
// Version 1.0      11 December 2022

// Can be changed via config notecard
integer primRain = FALSE;
integer primLightning = TRUE;
vector  rainPrimSize = <20.0, 20.0, 35.0>;
integer fogAge = 120;                           // FOG_AGE=120          # Adjusts extent of fog coverage - larger value makes larger area
float   primAlpha = 0.9;                        // ALPHA=9              # Set transparency (alpha) integer value from 0=Solid to 10=Clear

integer DEBUGMODE = FALSE;

debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DEBUG:" + llToUpper(llGetScriptName()) + " " + text);
//    if ((DEBUGMODE == TRUE) || (debugActive == TRUE)) llOwnerSay("DEBUG:" + llToUpper(llGetScriptName()) + " " + text);
}

float   volume = 0;
float   lastVol = 0;
string  rainSound = "RAIN";
integer raining = FALSE;
integer FARM_CHANNEL = -911201;
integer listenHandle = -1;
string  PASSWORD = "*";
key     owner;
integer visible;
integer active;
string  status;
integer debugActive;

integer IsVector(string s)
{
    // See https://wiki.secondlife.com/wiki/Category:LSL_Vector
    list split = llParseString2List(s, [" "], ["<", ">", ","]);
    if(llGetListLength(split) != 7)//we must check the list length, or the next test won't work properly.
        return FALSE;
    return !((string)((vector)s) == (string)((vector)((string)llListInsertList(split, ["-"], 5))));
}

loadConfig()
{
    integer i;
    //config Notecard
    if (llGetInventoryType("config") == INVENTORY_NOTECARD)
    {
        list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
        for (i=0; i < llGetListLength(lines); i++)
        {
            string line = llStringTrim(llList2String(lines, i), STRING_TRIM);
            if (llGetSubString(line, 0, 0) != "#")
            {
                list   tok = llParseStringKeepNulls(line, ["="], []);
                string cmd = llList2String(tok, 0);
                string val = llList2String(tok, 1);
                     if (cmd == "PRIM_RAIN") primRain = (integer)val;  
                else if (cmd == "PRIM_LIGHTNING") primLightning = (integer)val;
                else if (cmd == "PRIM_SIZE")
                {
                    if (IsVector(val) == FALSE) rainPrimSize = <20.0, 20.0, 35.0>; else rainPrimSize = (vector)val;
                }
                else if (cmd == "FOG_AGE")
                {
                    fogAge = (integer)val;
                    if (fogAge < 5) fogAge = 5;
                    llMessageLinked(LINK_SET, fogAge, "FOG-AGE", "");
                }
                else if (cmd == "ALPHA")
                {
                    primAlpha = (float)val/10;
                    primAlpha = 1 - primAlpha;
                    if (primAlpha > 1.0) primAlpha = 1.0;
                }
            }
        }
    }
}

makeRain()
{
    if (raining == FALSE)
    {
        raining == TRUE;
        llStopSound();
        llLoopSound(rainSound, volume);
        llSetColor(<0,0,1>, ALL_SIDES);
        if (primLightning == TRUE) llMessageLinked(LINK_SET, 1, "LIGHTNING", ""); else llMessageLinked(LINK_SET, -1, "LIGHTNING", "");            
        if (primRain == FALSE)
        {
            llParticleSystem( [
            PSYS_SRC_TEXTURE,
            NULL_KEY,
            PSYS_PART_START_SCALE, <0.1,0.5, 0>,
            PSYS_PART_END_SCALE, <0.05,1.5, 0>,
            PSYS_PART_START_COLOR, <1,1,1>,
            PSYS_PART_END_COLOR, <1,1,1>,
            PSYS_PART_START_ALPHA, 0.8,
            PSYS_PART_END_ALPHA, 0.6,
            PSYS_SRC_BURST_PART_COUNT, 15,
            PSYS_SRC_BURST_RATE, 0.00,
            PSYS_PART_MAX_AGE, 10.00,
            PSYS_SRC_MAX_AGE, 0.0,
            PSYS_SRC_PATTERN, 8,
            PSYS_SRC_ACCEL, <0.0,0.0, -7.2>,
            PSYS_SRC_BURST_RADIUS, 20.0,
            PSYS_SRC_BURST_SPEED_MIN, 0.0,
            PSYS_SRC_BURST_SPEED_MAX, 0.0,
            PSYS_SRC_ANGLE_BEGIN, 0*DEG_TO_RAD,
            PSYS_SRC_ANGLE_END, 180*DEG_TO_RAD,
            PSYS_SRC_OMEGA, <0,0,0>,
            PSYS_PART_FLAGS, ( 0
                | PSYS_PART_INTERP_COLOR_MASK
                | PSYS_PART_INTERP_SCALE_MASK
                | PSYS_PART_WIND_MASK
            ) ] );
        }
        else
        {
            // PRIM RAIN
            llMessageLinked(LINK_SET, 1, "RAIN", "");
        } 
    }
}

fxOff()
{
    llLinkParticleSystem(LINK_SET, []);
    llStopSound();
    raining = FALSE;
    llMessageLinked(LINK_SET, 0, "RESET", "");
}

init()
{
    fxOff();
    owner = llGetOwner();
    PASSWORD = osGetNotecardLine("sfp", 0);
    loadConfig();
    raining = FALSE;
    active = TRUE;
    debugActive = FALSE;
    listenHandle = llListen(FARM_CHANNEL, "", "", "");
}


default
{
    on_rez(integer p)
    {
        llResetScript();
    }

    state_entry()
    {
        llSetText("_-_", <0,0,1>, 1.0);
        // Check if weather_plugin script exists, if not we are a stand-alone repeater
        if (llGetInventoryType("weather_plugin") != INVENTORY_SCRIPT)
        {
            init();
            // Set root prim to dark blue
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0.0, 1.0, 0.5>, 0.5]);
            llSetText("-- READY --", <1,1,1>, 1.0);
            visible = TRUE;
            llMessageLinked(LINK_SET, 1, "PRIM_SIZE", (key)rainPrimSize);
            status = "";
        }
        else
        {
            llListenRemove(listenHandle);
            active = FALSE;
        }
    }

    touch_end(integer num)
    {
        if (visible == TRUE)
        {
            llSetAlpha(primAlpha, ALL_SIDES);
            llSetText("", ZERO_VECTOR, 0);
        }
        else
        {
            llSetAlpha(1.0, ALL_SIDES);
            llSetText("-- READY --", <1,1,1>, 1.0);
        }
        visible = !visible;
    }

    listen(integer channel, string name, key id, string message)
    {
        if (active == TRUE)
        {
            debug("listen="+message +"  Chan="+(string)channel);
            if (channel == FARM_CHANNEL)
            {
                list tk = llParseString2List(message, ["|"], []);
                string cmd = llList2String(tk, 0);
                //  0     1        2     3 ...
                // CMD|PASSWORD|OwnerID|data...
                if ((llList2String(tk, 1) == PASSWORD) && (llList2Key(tk, 2) == owner ))
                {
                    if (cmd == "WR_SOUND")
                    {
                        string tmpStr =llList2String(tk, 3);
                        if (llGetInventoryType(tmpStr) == INVENTORY_SOUND)
                        {
                            llStopSound();
                            llPlaySound(tmpStr, 1.0);
                        }
                        llMessageLinked(LINK_SET, 1, "SOUND", "");
                    }
                    else if (cmd == "WR_RAIN")
                    {
                        llStopSound();
                        volume = llList2Float(tk,3);
                        makeRain();
                    }
                    else if (cmd == "WR_CLOUDS")
                    {
                        if (debugActive == FALSE) llMessageLinked(LINK_SET, llList2Integer(tk,3), "CLOUDS", "");
                    }
                    else if (cmd == "WR_FOG")
                    {
                        if (debugActive == FALSE)
                        {
                            llMessageLinked(LINK_SET, llList2Integer(tk,3), "FOG", "");
                            llMessageLinked(LINK_SET, 0, "LIGHTNING", "");
                        }
                    }
                    if (cmd == "WR_FXEND")
                    {
                        if (debugActive == FALSE) 
                        {
                            // use timer to slowly fade out rain sound
                            status = "turnOff";
                            lastVol = volume;
                            llSetTimerEvent(0.5);
                        }
                    }
                    else if (cmd == "WR_RESET")
                    {
                        init();
                    }
                    else if (cmd == "WR_DEBUG")
                    {
                        integer val = llList2Integer(tk, 3);
                        if (val == 1)
                        {
                            llSetAlpha(1.0, ALL_SIDES);
                            debugActive = TRUE;
                        }
                        else
                        {
                            llSetAlpha(0.0, ALL_SIDES);
                            llSetText("", ZERO_VECTOR, 0.0);
                            debugActive = FALSE;
                        }
                        llMessageLinked(LINK_SET, val, "DEBUG", "");
                        llSetText("DEBUG:"+(string)val, <1,1,1>, 1.0);
                    }
                }
            }
        }
    }

    timer()
    {
        debug("timer status="+status);
        if (status == "turnOff")
        {
            lastVol = lastVol - 0.1;
            if (lastVol > 0)
            {
                llLoopSound(rainSound, lastVol);
            }
            else
            {
                status = "";
                llSetTimerEvent(0);
                fxOff();
            }
        }   
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        debug("link_message="+str +"  Num="+(string)num);
        if (str == "REPEATER")
        {
            active = num;
            if (active == TRUE) init();
        }
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
        else if (change & CHANGED_INVENTORY)
        {
            if (active == TRUE) init();
        }
    }

}



