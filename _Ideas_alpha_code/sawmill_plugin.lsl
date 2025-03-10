// sawmill_plugin.lsl
// Version 1.0  14 March 2022

float interval = 0.1;
float volume = 0.1;
float rate = 30.0;
float turnspeed = 20.0;

float   originalsize = 26.775;
float   scale;
vector  size;
integer running = FALSE;
vector  wind;
float   windspeed;
float   targetwindangle;
float   diff;
float   windangle;
float   sailangle;
float   lastsawz;
vector  saw1posoffset;
integer upsawing;
integer downsawing;

integer maxsawsteps = 600;
integer sawsteps = 600; //maxsawsteps
integer maxwaitingsteps = 30;
integer waitingsteps;

list showlog =    [PRIM_TEXTURE, 0, "LogEnd - HUD", <1.000000, 1.000000, 0.000000>, <0.000000, 0.000000, 0.000000>, 0.000000, PRIM_TEXTURE, 1, "Log Texture HUD", <1.000000, 1.000000, 0.000000>, <0.000000, 0.000000, 0.000000>, 0.000000, PRIM_TEXTURE, 2, "Log Cut End", <1.000000, 1.000000, 0.000000>, <0.000000, 0.000000, 0.000000>, 0.000000];
list showstock =  [PRIM_TEXTURE, 0, "Plank", <256.000000, 4.000000, 0.000000>, <0.500015, 0.500015, 0.000000>, 0.000000];
list showboards = [PRIM_TEXTURE, 0, "Plank", <256.000000, 4.000000, 0.000000>, <0.500015, 0.500015, 0.000000>, 0.000000];

list hidelog =    [PRIM_TEXTURE, 0, TEXTURE_TRANSPARENT, <1.000000, 1.000000, 0.000000>, <0.000000, 0.000000, 0.000000>, 0.000000, PRIM_TEXTURE, 1, TEXTURE_TRANSPARENT, <1.000000, 1.000000, 0.000000>, <0.000000, 0.000000, 0.000000>, 0.000000, PRIM_TEXTURE, 2, TEXTURE_TRANSPARENT, <1.000000, 1.000000, 0.000000>, <0.000000, 0.000000, 0.000000>, 0.000000];
list hidestock =  [PRIM_TEXTURE, 0, TEXTURE_TRANSPARENT, <256.000000, 4.000000, 0.000000>, <0.500015, 0.500015, 0.000000>, 0.000000];
list hideboards = [PRIM_TEXTURE, 0, TEXTURE_TRANSPARENT, <256.000000, 4.000000, 0.000000>, <0.500015, 0.500015, 0.000000>, 0.000000];

integer saw0;
integer sawcrank0;
integer sawconnectingrod0;
integer sawconnectingrod1;
integer drive0;
integer sawcrank1;
integer drive1;
integer downshaft;
integer downshaft0;
integer downshaft1;
integer sawedstock;
integer boardsfalling;
integer log;
integer saw1;
integer driveshaft;
integer rotor;
integer cap;
integer sails;
integer boardsstationary;
integer sawconnectingrod0toppivot;
integer sawconnectingrod0bottompivot;

findparts()
{
    integer i;
    for(i = 2; i < llGetNumberOfPrims() + 1; i++)
    {
        string name = llGetLinkName(i);

        if(name == "saw0")
            saw0 = i;
        else if(name == "saw1")
            saw1 = i;
        else if(name == "sawcrank0")
            sawcrank0 = i;
        else if(name == "sawconnectingrod0")
            sawconnectingrod0 = i;
        else if(name == "sawconnectingrod1")
            sawconnectingrod1 = i;
        else if(name == "drive0")
            drive0 = i;
        else if(name == "sawcrank1")
            sawcrank1 = i;
        else if(name == "drive1")
            drive1 = i;
        else if(name == "downshaft")
            downshaft = i;
        else if(name == "downshaft0")
            downshaft0 = i;
        else if(name == "downshaft1")
            downshaft1 = i;
        else if(name == "sawedstock")
            sawedstock = i;
        else if(name == "boardsfalling")
            boardsfalling = i;
        else if(name == "driveshaft")
            driveshaft = i;
        else if(name == "rotor")
            rotor = i;
        else if(name == "cap")
            cap = i;
        else if(name == "sails")
            sails = i;
        else if(name == "boardsstationary")
            boardsstationary = i;
        else if(name == "sawconnectingrod0toppivot")
            sawconnectingrod0toppivot = i;
        else if(name == "sawconnectingrod0bottompivot")
            sawconnectingrod0bottompivot = i;
        else if(name == "log")
            log = i;
        else if(name == "sawedstock")
            sawedstock = i;
    }
}

run()
{
    vector globalrot = llRot2Euler(llGetRot())*RAD_TO_DEG;
    float zangle = globalrot.z;

    size = llList2Vector(llGetLinkPrimitiveParams(1, [PRIM_SIZE]), 0);
    scale = size.x/originalsize;

    wind = llWind(ZERO_VECTOR);
    windspeed = llVecMag(wind);
    targetwindangle = llAtan2(wind.y, wind.x)*RAD_TO_DEG - zangle;
    diff = targetwindangle - windangle;

    if(diff > 180.0)
        diff -= 360.0;

    if(diff < -180.0)
        diff += 360.0;

    if(diff > turnspeed)
        diff = turnspeed;
    else if(diff < -turnspeed)
        diff = -turnspeed;

    windangle += diff/(turnspeed/2.0);

    if(windangle > 180.0)
        windangle -= 360.0;
    if(windangle < -180.0)
        windangle += 360.0;
    float milliseconds = (float)llGetSubString(llGetTimestamp(), -8, -2);
    sailangle = rate * (-llGetWallclock() - milliseconds);

    vector sailspos = <-9.603130, -6.503815, 14.016800>*scale;
    vector cappos = <-9.603130, -6.503815, 14.016800>*scale;
    vector driveshaftpos = <-7.400833, -6.503845, 13.921772>*scale;
    vector rotorpos = <-6.259853, -6.503845, 15.059261>*scale;
    vector downshaftpos = <-9.587891, -6.489517, 9.256889>*scale;
    vector downshaft0pos = <-9.611298, -7.365715, 5.111568>*scale;
    vector downshaft1pos = <-9.587891, -6.489479, 2.517475>*scale;
    vector drive0pos = <-9.589020, -4.762558, 2.384998>*scale;
    vector drive1pos = <-4.093628, -6.486023, 3.845921>*scale;

    rotation sailrot = llEuler2Rot(<sailangle + windangle - 8.0, 0, 0>*DEG_TO_RAD);
    rotation windrot = llEuler2Rot(<0, 0, windangle>*DEG_TO_RAD);
    rotation downshaftrot = llEuler2Rot(<0, 0, -sailangle + 11.25>*DEG_TO_RAD);
    rotation downshaft0rot = llEuler2Rot(<0, 0, sailangle*4.0 + 11.25>*DEG_TO_RAD);
    rotation downshaft1rot = llEuler2Rot(<0, 0, -sailangle*16.0 + 11.25>*DEG_TO_RAD);
    vector driveshaftposoffset = cappos + (driveshaftpos - cappos)*windrot;
    vector rotorposoffset = cappos + (rotorpos - cappos)*windrot;

    vector sawcrank0pos = <-9.589050, -3.054321, 3.665714>*scale;
    vector sawconnectingrod0pos = <-9.589188, -2.126236, 3.156208>*scale;
    vector saw0pos = <-9.589294, -2.125839, 1.819374>*scale;
    vector sawconnectingrod0toppivotpos = <-9.589130, -2.126846, 3.455544>*scale;
    vector sawconnectingrod0bottompivotpos = <-9.589130, -2.126846, 2.852192>*scale;
    float  saw1xoff = 0.065;
    vector sawcrank1pos = <1.492035 + saw1xoff, -6.468704, 3.847298>*scale;
    vector sawconnectingrod1pos = <1.491867 + saw1xoff, -7.688461, 3.658497>*scale;
    vector saw1pos = <1.491821 + saw1xoff, -7.688507, 2.184929>*scale;
    vector sawconnectingrod1toppivotpos = <1.491867 + saw1xoff, -7.691345, 4.120731>*scale;
    vector sawconnectingrod1bottompivotpos = <1.491867 + saw1xoff, -7.691345, 3.189350>*scale;

    float driveshaftangleoffset = 0.0;
    rotation driveshaftrot = llEuler2Rot(<0, 0, windangle*8.0 + driveshaftangleoffset>*DEG_TO_RAD);
    rotation rotorrot = llEuler2Rot(<0, 0, -windangle*8.0 - driveshaftangleoffset>*DEG_TO_RAD);
    rotation drive0rot = llEuler2Rot(<0, sailangle*16, 0>*DEG_TO_RAD);
    rotation sawcrank0rot = llEuler2Rot(<0, -sailangle*2.0*16 + 11.25, 0>*DEG_TO_RAD);

    rotation drive1rot = llEuler2Rot(<-sailangle*16, 0, 0>*DEG_TO_RAD);
    rotation sawcrank1rot = llEuler2Rot(<0, -sailangle*16 - 11.25, 0>*DEG_TO_RAD);
    ////////// saw0
    vector sawconnectingrod0toppivotposoffset = sawcrank0pos + (sawconnectingrod0toppivotpos - sawcrank0pos)*sawcrank0rot;
    vector sawconnectingrod0bottompivotposoffset = sawconnectingrod0bottompivotpos;
    float r = sawconnectingrod0toppivotpos.z - sawconnectingrod0bottompivotpos.z;
    float x = sawconnectingrod0toppivotposoffset.x - sawconnectingrod0bottompivotpos.x;
    float z = llSqrt(r*r - x*x);
    sawconnectingrod0bottompivotposoffset.z = sawconnectingrod0toppivotposoffset.z - z;

    vector sawconnectingrod0posoffset = sawconnectingrod0toppivotposoffset - (sawconnectingrod0toppivotposoffset - sawconnectingrod0bottompivotposoffset)/2.0;
    vector v = llVecNorm(sawconnectingrod0toppivotposoffset - sawconnectingrod0bottompivotposoffset);
    rotation sawconnectingrod0rot = llRotBetween(<0, 0, 1>, v);

    vector saw0posoffset = saw0pos;
    saw0posoffset.z = saw0pos.z + (sawconnectingrod0bottompivotposoffset.z - sawconnectingrod0bottompivotpos.z);

    ////////// saw1
    vector sawconnectingrod1toppivotposoffset = sawcrank1pos + (sawconnectingrod1toppivotpos - sawcrank1pos)*sawcrank1rot;
    vector sawconnectingrod1bottompivotposoffset = sawconnectingrod1bottompivotpos;
    r = sawconnectingrod1toppivotpos.z - sawconnectingrod1bottompivotpos.z;
    x = sawconnectingrod1toppivotposoffset.x - sawconnectingrod1bottompivotpos.x;
    z = llSqrt(r*r - x*x);
    sawconnectingrod1bottompivotposoffset.z = sawconnectingrod1toppivotposoffset.z - z;

    vector sawconnectingrod1posoffset = sawconnectingrod1toppivotposoffset - (sawconnectingrod1toppivotposoffset - sawconnectingrod1bottompivotposoffset)/2.0;
    v = llVecNorm(sawconnectingrod1toppivotposoffset - sawconnectingrod1bottompivotposoffset);
    rotation sawconnectingrod1rot = llRotBetween(<0, 0, 1>, v);

    lastsawz = saw1posoffset.z;
    saw1posoffset = saw1pos;
    saw1posoffset.z = saw1pos.z + (sawconnectingrod1bottompivotposoffset.z - sawconnectingrod1bottompivotpos.z);

    if(lastsawz > saw1posoffset.z && !downsawing && sawsteps)
    {
        downsawing = TRUE;
        upsawing = FALSE;
        llMessageLinked(saw1, 0, "downsaw", llGetKey());
    }

    if(saw1posoffset.z > lastsawz && !upsawing && sawsteps)
    {
        upsawing = TRUE;
        downsawing = FALSE;
        llMessageLinked(saw1, 0, "upsaw", llGetKey());
    }

    llSetLinkPrimitiveParamsFast(sawconnectingrod0, [PRIM_POSITION, sawconnectingrod0posoffset, PRIM_ROT_LOCAL, <-0.000000, 0.000000, 0.707106, 0.707106>*sawconnectingrod0rot]);
    llSetLinkPrimitiveParamsFast(saw0, [PRIM_POSITION, saw0posoffset, PRIM_ROT_LOCAL, <-0.000000, 0.000000, 0.707106, 0.707106>]);
    llSetLinkPrimitiveParamsFast(sawconnectingrod1, [PRIM_POSITION, sawconnectingrod1posoffset, PRIM_ROT_LOCAL, <-0.000000, 0.000000, 0.707106, 0.707106>*sawconnectingrod1rot]);
    llSetLinkPrimitiveParamsFast(saw1, [PRIM_POSITION, saw1posoffset, PRIM_ROT_LOCAL, <-0.000000, 0.000000, 0.707106, 0.707106>]);

    vector logpos = <4.175869, -7.688538, 1.705509>*scale;
    vector logsize = <0.722, 0.722, 5.0>*scale;
    vector sawedstocksize = <0.731, 0.731, 5.0>*scale;

    if(!waitingsteps)
    {
        if(sawsteps)
        {
            if(sawsteps == maxsawsteps)
                llMessageLinked(saw1, 0, "sawsound, 1", llGetKey());

            vector logposoffset = logpos;
            float ratio = (float)(maxsawsteps - sawsteps)/(float)maxsawsteps;
            logposoffset.x -= ratio*logsize.z;

            vector sawedstockposoffset = logposoffset;
            sawedstockposoffset.x -= logsize.z/2.0 - ratio*logsize.z/2.0;
            vector sawed = sawedstocksize;
            sawed.z = ratio*sawedstocksize.z;

            llSetLinkPrimitiveParamsFast(log, [PRIM_POSITION, logposoffset, PRIM_SLICE, <ratio, 1.0, 0.0>]);
            llSetLinkPrimitiveParamsFast(sawedstock, [PRIM_POSITION, sawedstockposoffset, PRIM_SIZE, sawed]);

            sawsteps--;

            if(!sawsteps)
            {
                waitingsteps = maxwaitingsteps;
                llMessageLinked(saw1, 0, "sawsound, 0", llGetKey());
                llMessageLinked(saw1, 0, "notsawing", llGetKey());
            }
        }
    }

    if(waitingsteps)
    {
        if(waitingsteps == maxwaitingsteps)
        {
            llSetLinkPrimitiveParamsFast(log, hidelog + [PRIM_POS_LOCAL, logpos, PRIM_SLICE, <0.0, 1.0, 0.0>]);
            llSetLinkPrimitiveParamsFast(sawedstock, hidestock + [PRIM_POS_LOCAL, <logpos.x - logsize.z/2.0, logpos.y, logpos.z>, PRIM_SIZE, <sawedstocksize.x, sawedstocksize.y, 0.01>]);
            llSetLinkPrimitiveParamsFast(boardsfalling, showboards);
            llMessageLinked(boardsfalling, 0, "strike", llGetKey());
        }

        if(waitingsteps == 10)
        {
            llSetLinkPrimitiveParamsFast(boardsfalling, hideboards);
        }

        if(waitingsteps == 1)
        {
            llSetLinkPrimitiveParamsFast(log, showlog);
            llSetLinkPrimitiveParamsFast(sawedstock, showstock);
        }

        waitingsteps--;
        if(!waitingsteps)
        {
            sawsteps = maxsawsteps;
            llMessageLinked(saw1, 0, "sawing", llGetKey());
        }
    }


    //llOwnerSay("sawsteps: "+(string)sawsteps +"  milliseconds: ");
}

inittextures()
{
    llSetLinkPrimitiveParamsFast(log, showlog);
    llSetLinkPrimitiveParamsFast(sawedstock, showstock);
    llSetLinkPrimitiveParamsFast(boardsfalling, hideboards);
}


default
{
    state_entry()
    {
        findparts();
        llStopSound();
        inittextures();
        llSetText("", <1, 1, 1>, 1);
        llMessageLinked(downshaft, 0, "sound, 0", llGetKey());
        llMessageLinked(LINK_ALL_OTHERS, 0, "status", "");
        llSetTimerEvent(0.1);
    }

    timer()
    {
        if(!running)
            return;

        run();
    }

    link_message(integer link, integer num, string msg, key id)
    {
        list msgs = llCSV2List(msg);
        string command = llList2String(msgs, 0);

        if (command == "run")
        {
            running = !running;
            llMessageLinked(downshaft, 0, "sound, " + (string)running, llGetKey());
            llMessageLinked(LINK_ALL_OTHERS, running, "status", "");
        }
        else
        {
            list tok = llParseString2List(msg, ["|"], []);
            string cmd = llList2String(tok, 0);

            if (command == "STARTCOOKING")
            {
                running = TRUE;
                llMessageLinked(downshaft, 0, "sound, " + (string)running, llGetKey());
                llMessageLinked(LINK_ALL_OTHERS, running, "status", "");
            }
            else if (cmd == "ENDCOOKING")
            {
                running = FALSE;
                llMessageLinked(downshaft, 0, "sound, " + (string)running, llGetKey());
                llMessageLinked(LINK_ALL_OTHERS, running, "status", "");
            }
        }

    }

}
