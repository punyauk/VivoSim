/*
 * CHANGE LOG
    * Added self destruct feature if HUD is rezzed not attached
	* Added decimal point to HUD
	* Removed check for osMakeNotecard
*/
// CHANGED TEXT  (from WARNING to CAUTION)

float  VERSION = 6.07;        // 31 March 2024
string subVersion = "";       // Set to "" for release
string NAME = "VivoSim-HUD";

integer DEBUGMODE = FALSE;    // Set this if you want to force debug mode
string  debugLevel = "MIN";   // Set to MIN  or  MAX

debug(string text)
{
   // if ((DEBUGMODE == TRUE) || (systemDebug == TRUE)) llOwnerSay("DB_" + llGetScriptName() + ": " + text);
     if ((DEBUGMODE == TRUE) || (systemDebug == TRUE)) llSay(DEBUG_CHANNEL, "DB_" + llGetScriptName() + ": " + text);
}

// Links to web pages
string webForumURL = "https://vivosim.net/help/forum/";
string userGuideURL = "https://vivosim.net/help/guides/user-guide";
//
// These values can be overridden with config notecard unless already stored in description
integer useEffects = TRUE;                  // EFFECTS                   Default is 1  i.e. effects are on
integer useXtremeFX = TRUE;                 // FUNNY_FX=1                Set to 0 for standard sound effects even in extreme conditions
integer showNums = TRUE;                    // SHOW_NUMS=1               1 to show percentage on HUD face, 0 to hide
string  indicatorColour = "AUTO";           // INDICATOR_COLOR=AUTO      Set to AUTO to have float text on VivoStatus-Ind coloured matching status, or set to a vector for fixed coloured text
float   fxVolume = 1.0;                     // VOLUME=10                 Volume, 0 to 10
integer echoChat = FALSE;                   // ECHO_CHAT                 Default is 0  i.e. don't echo in local chat all messages to screen
string  timeRateDisp = "M";                 // METABOLIC_RATE=M          Sets your metabolic rate. Can be L (low), M (medium) or H (high)
integer timeRate = 5400;                    // setTimeRate(timeRateDisp);
/*
 string  timeRateDisp = "90";                // EAT_INTERVAL             Default eat approx every 90 minutes i.e. 5400 seconds
 integer timeRate = 5400;                    //  setTimeRate("90");
*/
integer displayTime = 5;                    // DISPLAY_TIME              Time in seconds (approx) to keep messages on the HUD screen
integer scanRange = 96;                     // SCAN_RANGE                How far to scan for items to use/store
integer radius = 10;                        // SENSOR_DISTANCE           Default scan radius when eating/adding to store
vector  rezzPosition = <0.0, 0.0, 0.5>;     // REZ_POSITION              Offset for rezzing items
string  provBoxName = "SF Provisions Box";  // BOX_NAME                  Provisions box name
string  SF_WOOD = "SF Wood";                // WOOD_NAME=Wood            Full name of Wood item for storing
string  SF_POWER = "SF kWh";                // POWER_NAME=kWh            Full name of power item for storing e.g. SF kWh, SF kJ etc
integer healthMode = 1;                     // HEALTH_MODE=1             Set to 0 to disable health mode by default
string  collector = "Pitchfork";            // COLLECTOR=Pitchfork       Set to short name of item to wear to collect things
integer usePoints = TRUE;                   // USE_POINTS=1              Set to 0 to disbale points mode (e.g. for critters)
integer MY_HUD = TRUE;                      // MY_HUD=1                  Set to 0 if this HUD is worn by e.g baby rather than you
string  critterName = "Baby";               // CRITTER=Baby              Name of attached critter e.g. Baby
list    targets = [];                       // TARGETS=                  Comma/semicolon seperated list of items baby can go to when not attached. On rez will go to first one in list
integer useAge = FALSE;                     // USE_AGE=0                 Set to 1 to use age ranges in products
integer baseAge = 10;                       // BASE_AGE=Adult            Can be Adult, Child, Baby, Sim or an actual number between 1 & 10
integer allowDeath = FALSE;                 // ALLOW_DEATH=0             Set to 1 to enable 'death mode' if your health drops to zero
integer useOsExtra = FALSE;                 // USE_OSEXTRA=0             Set to 1 to allow extra os functions such as osDropAttachment()
string  SF_PREFIX = "SF";                   // SF_PREFIX=SF              Omit the SF part
integer hidePost = FALSE;                   // HIDE_RESULTS=0            Set to 0 for activity etc to be posted on the VivoSim website, 1 to prevent
string  languageCode = "en-GB";             // LANG

//
// Mulitlingual support
string TXT_ACCOUNT="Account";
string TXT_ADVANCED="ADVANCED";
string TXT_AFK="AFK";
string TXT_AVG_HAPPY="Average happiness";
string TXT_AVG_HUNGER="Average hunger level";
string TXT_AVG_THIRST="Average thirst level";
string TXT_BACKPACK="Backpack";
string TXT_BAD_PASSWORD = "Faulty product";
string TXT_BLADDER = "Bladder";
string TXT_BONUS="Bonus";
string TXT_BOOZE="Booze";
string TXT_CAUTION="CAUTION: HUD is not in same group as you";
string TXT_CHAT_ON="Chat messages and Sounds will be used";
string TXT_CLOSE="CLOSE";
string TXT_CONSUME="Use";
string TXT_CONSUMED="Used";
string TXT_CONSUMING="Using";
string TXT_CREDITED = "You have been credited";
string TXT_CURRENT_VALUE="Current value is";
string TXT_DATA_ERROR="Sorry, unable to get data from the server at this time";
string TXT_DEBUG="DEBUG";
string TXT_DEBUG_VALUES="Debug values";
string TXT_DRINK="Drink";
string TXT_DRINK_NOW="Drink something fast!";
string TXT_DRUNK="Drunk";
string TXT_EAT_NOW="Eat something!";
string TXT_ECHO_TEXT="Echo status";
string TXT_EFFECTS="Effects";
string TXT_ENERGY="Energy";
string TXT_ERROR="Error!";
string TXT_FEMALES="Females";
string TXT_FETCHING="Fetching";
string TXT_FOOD="Food";
string TXT_GETTING_INFO="Getting information...";
string TXT_HAPPY="happy";
string TXT_HEALTH="Health";
string TXT_HEALTH_MODE="HealthMode";
string TXT_HELP="HELP";
string TXT_HIGH="High";
string TXT_HUNGRY="Hungry";
string TXT_HYGIENE="Hygiene";
string TXT_INFORMATION="Guide";
string TXT_INSPECT = "Inspect";
string TXT_INTERACTION = "Interaction";
string TXT_LESS_BOOZE="Stop drinking so much alcohol!";
string TXT_LESS_FOOD="You don't need to eat so much!";
string TXT_LESS_LIQUIDS="You don't need to drink so many liquids!";
string TXT_LEVELS="Levels";
string TXT_LOADING_VALUES="Loading values...";
string TXT_LOCK="Lock";
string TXT_LOCKED="Locked";
string TXT_LOW="Low";
string TXT_MALES="Males";
string TXT_MEDICINE="Medicine";
string TXT_MEDIUM="Medium";
string TXT_MENU_HELP="Help menu";
string TXT_MENU_MAIN="MAIN MENU";
string TXT_MENU_OPTIONS="Options menu";
string TXT_MENU_PROVISIONS="Provisions menu";
string TXT_METABOLIC="Metabolic rate";
string TXT_MINUTES="minutes";
string TXT_MODE="Mode";
string TXT_NO_KEY="Sorry, you don't have the key";
string TXT_NO_PROVISIONS="You don't have any stored provisions";
string TXT_NOT_ENOUGH="Not enough";
string TXT_NOT_FOUND="Nothing found nearby!";
string TXT_NOT_STORABLE="Nothing storable found in";
string TXT_NUTRITION="Nutrition";
string TXT_OFF="OFF";
string TXT_ON="ON";
string TXT_OOC="OOC";
string TXT_OPTIONS="OPTIONS";
string TXT_PAUSE="Pause";
string TXT_PAUSED="PAUSED";
string TXT_PROGRESS="Progress";
string TXT_PROVISIONS="Provisions";
string TXT_PROVISIONS_BOX="Provisions Box";
string TXT_PROVISIONS_TRANSFERRED="Provisions transferred to";
string TXT_RADIUS="radius";
string TXT_RANGE="Range";
string TXT_REATTACH="Remove and re-attach recommended";
string TXT_REQUESTING_INFO="Requesting info...";
string TXT_RESET="RESET";
string TXT_RESET_CONFIRM="!RESET!";
string TXT_RESUME="RESUME";
string TXT_REZ_BOX="Rez box";
string TXT_REZ_WOOD="Rez wood";
string TXT_SCAN="Scan";
string TXT_SCAN_RANGE="Scan range";
string TXT_SCANNING="Scanning";
string TXT_SEASON_CHANGE="Season has just changed to";
string TXT_SELECT_CONSUME="Select item to use";
string TXT_SELECT_INSPECT="Select item to inspect";
string TXT_SELECT_STORE="Select item to store";
string TXT_SICK="Sick";
string TXT_SPACING_1="Single";
string TXT_SPACING_2="Double";
string TXT_STATUS="Status";
string TXT_STATUS_HUD="Status text";
string TXT_STOP_ANIM="Stop Anim";
string TXT_STORAGE="Storage";
string TXT_STORE_ITEM="Store item";
string TXT_STORE_LEVELS="Store levels";
string TXT_STORED="Stored";
string TXT_STUNG="Stung!";
string TXT_TALKING_TO_SERVER="Talking to server...";
string TXT_THIRSTY="Thirsty";
string TXT_TOTAL="Total";
string TXT_TOUCH_RESUME="Touch to resume...";
string TXT_UNITS="Units";
string TXT_UNLOCK="Unlock";
string TXT_UNLOCKED="Unlocked";
string TXT_VERSION="version";
string TXT_VISIT_LAVATORY = "You really should visit a lavatory!";
string TXT_VISIT_WEBSITE="Visit the Farming forum...";
string TXT_WARNING_RESET = "CAUTION - The key for your locked provision boxes will be reset and you won't be able to open any that are locked after this reset...";
string TXT_WEBSITE="Forum";
string TXT_WELLBEING = "Wellbeing";
string TXT_WHAT_USE="What would you like to use?";
string TXT_WHICH_ANIMAL="Query which animal";
string TXT_WOOD="Wood";
string TXT_YOU_ARE_SICK="You are sick!";
string TXT_FULFILMENT="Fulfilment";
string TXT_FUSTRATION = "Frustration";
string TXT_AGE_BABY="Baby";
string TXT_AGE_CHILD="Child";
string TXT_AGE_ADULT="Adult";
string TXT_BABY="BABY";
string TXT_TOUCH="Touch";
string TXT_DEAD="DEAD";
string TXT_RIP="R I P";
string TXT_SLEEPING="Sleeping";
string TXT_RELOAD="Retrieve";
string TXT_LANGUAGE="@";
string TXT_REZ_POWER="Rez Power";   // was string TXT_REZ_KWH="Rez kWh";
string TXT_NOT_CONSUMABLE="Nothing useable found in";
string TXT_SAVE      = "Save";
string TXT_SAVING    = "Saving";
string TXT_LOAD      = "Load";
string TXT_SERVER    = "Server";
string TXT_FROM      = "From";
string TXT_BACKUP    = "Backup";
string TXT_XP        = "XP";
string TXT_POWER     = "Power";
//
string TXT_STATUS_HUD_STATE="Status HUD";
string TXT_TESTER = "TESTER";                    // For testing purposes
//
vector GREEN     = <0.180, 0.800, 0.251>;        // 100%
vector OLIVE     = <0.239, 0.600, 0.439>;        // Okay
vector TEAL      = <0.004, 0.606, 0.395>;        // Be aware
 // vector TEAL      = <0.547, 0.615, 0.220>;    // Be aware
vector YELLOW    = <1.000, 0.863, 0.000>;        // Caution
vector ORANGE    = <1.000, 0.522, 0.106>;        // Warning
vector RED       = <1.000, 0.255, 0.212>;        // Danger
vector BLACK     = <0.010, 0.010, 0.010>;        // DEAD!!
vector PURPLE    = <0.669, 0.336, 1.000>;        // Status change / Comms
vector WHITE     = <1.000, 1.000, 1.000>;        // General information, notification etc
//
string user_nc =    "DATA_USERVALS";
string values_nc =  "VDATA_VALUES";
string valuesHash;
string animals_nc = "VDATA_ANIMALS";
string animalsHash;
string statusNC =   "VSDATA";                    // Used to save data to notecard rather than server but not implemented yet
//
string INDHUDNAME_MAIN  = "VivoStatus-Ind";
string INDHUDNAME_BABY  = "VivoStatus-Ind";
string statusIndicator;
//
// FX animations
string wealthAnim   = "anim_ching";
string drunkAnim    = "anim_drunk";
string faintAnim    = "anim_faint";
string sickAnim     = "anim_sick";
string deadAnim     = "anim_dead";
    // string drownedAnim  = "anim_drowned";
//
// FX sounds
string beesSound    = "sound_bees";
string lockSound    = "sound_lock";
string unlockSound  = "sound_unlock";
    // string wealthSound  = "sound_ching";
string actionSound  = "sound_gotit";
string xpSound      = "sound_xp";
//
float   healthRate = 2.5;
float   hygieneRate = 4.0;
float   thirstRate = 0.75;                        // Time between drinking is (eatInterval / thirstRate)
float   hungerRate = 0.95;                        // Time between eating is (eatInterval / thirstRate)
float   bladderRate = 0.65;                        // Time between going to toilet is (eatInterval / bladderRate)
integer trigLevel = 79;                            // Above this percent the hud will start to warn you to eat/drink and the points for time count will decrease.
//
string  PASSWORD = "*";
integer FARM_CHANNEL = -911201;
string  SUFFIX ="H1";
integer listener = -1;
integer listenTs;
integer listenerFarm;
integer isDead;
float   drunk   = 0.0;
float   thirsty = 0.0;
float   hungry  = 0.0;
float   health  = 10.0;
float   hygiene = 10.0;
float   bladder = 0.0;
float   energy = 75.0;
float   point = 0.0;
integer wellbeing;
integer fulfilment = 0;
integer frustration = 0;
integer userXP = -1;
integer foodStore = 0;
integer drinkStore = 0;
integer boozeStore = 0;
integer medicineStore = 0;
integer woodStore = 0;
integer energyStore = 0;
integer provLocked = FALSE;
integer hudSpacing;
string  pubKey = "-";
string  privKey = "-";
integer AFK = FALSE;
integer OOC = FALSE;
integer active = TRUE;
list    animals = [];
list    screenLines;
list    lastFoundKeys;
float   elapsedTime;                            // Total elapsed time since script was reset
integer storedTime;                                // Accumulated time stored from previous sessions
integer lastHealthTs;                            // Used to control increase/decrease of health & drunkeness
integer lastEatTs;                                // Used to control increase/decrease of hunger
integer lastDrinkTs;                            // Used to control increase/decrease of thirst
integer lastBladderTs;                            // Used to control increase/decrease of bladder
integer alertTs;                                // Used to count time between playing animations/sending health alerts
integer pollTs;                                    // Used to trigger a 'poll' link message at regular intervals
integer screenTs = -1;                            // Aims to make sure screen isn't cleared to quickly
integer animTs;
string  lastNetCheck;
string  lastText;
string  status;
integer systemDebug = FALSE;
string  lookingFor;
integer itemFound;
integer lookingForPercent;
string  consumeType;
string  curAnim;
vector  borderColour;
key     req_id2 = NULL_KEY;
key     indicatorKey = NULL_KEY;
key     critterKey = NULL_KEY;
key     userID = NULL_KEY;
key     owner_age_query = NULL_KEY;
integer statusHudVisible = TRUE;
integer safetyCheck = TRUE;
string  thisRegion;
string  mainTarget;
integer sleeping = FALSE;

integer chan(key u)
{
    return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

//allows string output of a float in a tidy text format
//rnd (rounding) should be set to TRUE for rounding, FALSE for no rounding
string qsFloat2String ( float num, integer places, integer rnd)
{
    if (rnd)
    {
        float f = llPow( 10.0, places );
        integer i = llRound(llFabs(num) * f);
        string s = "00000" + (string)i; // number of 0s is (value of max places - 1 )

        if(num < 0.0)
            return "-" + (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
        return (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
    }

    if (!places)
        return (string)((integer)num );
    if ( (places = (places - 7 - (places < 1) ) ) & 0x80000000)
        return llGetSubString((string)num, 0, places);

    return (string)num;
}

float checkPercent(float num)
{
    // rounds up/down to keep percentage with 0.0 to 100.0 range
    if (num <0.0) return 0.0;
     else if (num >100.0) return 100.0;
      else return num;
}

startListen()
{
    if (listener<0)
    {
        listener = llListen(chan(llGetKey()), "", "", "");
        listenTs = llGetUnixTime();
    }
}

checkListen(integer force)
{
    if ( (listener > 0 && llGetUnixTime() - listenTs > 300) || (force == TRUE) )
    {
        llListenRemove(listener);
        listener = -1;
    }
}

messageObj(key objId, string msg)
{
    list check = llGetObjectDetails(objId, [OBJECT_NAME]);

    if (llList2String(check, 0) != "") osMessageObject(objId, msg);
}

integer checkIndicator(string indName)
{
    integer result = FALSE;
    key keycheck = checkAttached(indName);

    if (keycheck != indicatorKey)
    {
        if (keycheck != NULL_KEY)
        {
            indicatorKey = keycheck;
            messageObj(indicatorKey, "INIT|" +PASSWORD+"|" +(string)llGetKey());
            result = TRUE;
        }
        else
        {
            indicatorKey = NULL_KEY;
        }
    }
    else
    {
        result = TRUE;
    }

    if (indName == statusIndicator)
    {
        if (result == FALSE) llMessageLinked(LINK_ALL_CHILDREN, 0, "COMMS|INDICATOR|0", ""); else llMessageLinked(LINK_ALL_CHILDREN, 0, "COMMS|INDICATOR|1", "");
    }

    return result;
}

key checkAttached(string objName)
{
    integer i;

    if (MY_HUD == TRUE)
    {
        key found = NULL_KEY;
        list attached = llGetAttachedList(userID);
        integer count = llGetListLength(attached);

        for (i=0; i < count; i++)
        {
            if (llKey2Name(llList2Key(attached, i)) == objName)
            {
                found = llList2Key(attached, i);
            }
        }

        return found;
    }
    else
    {
        i = getLinkNum(objName);

        if (i != -1)
        {
            return llGetLinkKey(i);
        }
        else
        {
            return NULL_KEY;
        }
    }
}

postMessage(string msg)
{
    req_id2 = llGetKey();
    llMessageLinked(LINK_SET, 1, "CMD_POST|"+msg, req_id2);
}

setTimeRate(string val)
{

    // just need uppercase first letter
    val = llToUpper(llGetSubString(val, 0, 0));

    if (val == "H")
    {
        timeRateDisp = TXT_HIGH;
        timeRate = 5400;     // 5400 is 1.5 hours
    }
    else if (val == "L")
    {
        timeRateDisp = TXT_LOW;
        timeRate = 14400;     // 14400 is 4 hours
    }
    else
    {
        timeRateDisp = TXT_MEDIUM;
        timeRate = 9000;     // 9000 is 2.5 hours
    }
}

string getTimeRate()
{
    string result = "M";

    if (timeRateDisp == TXT_HIGH) result = "H"; else if (timeRateDisp == TXT_LOW) result = "L";

    return result;
}

setConfig(string line)
{
    list tok = llParseString2List(line, ["="], []);
    if (llList2String(tok,1) != "")
    {
        string cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
        string val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

             if (cmd == "EFFECTS")         useEffects = (integer)val;
        else if (cmd == "FUNNY_FX")        useXtremeFX = (integer)val;
        else if (cmd == "SHOW_NUMS")       showNums = (integer)val;
        else if (cmd == "VOLUME")          fxVolume =   0.1 * (float)val;
        else if (cmd == "ECHO_CHAT")       echoChat = (integer)val;
        else if (cmd == "REZ_POSITION")    rezzPosition = (vector)val;
        else if (cmd == "SENSOR_DISTANCE") radius = (integer)val;   // How far to look for products e.g. food
        else if (cmd == "SCAN_RANGE")      scanRange = (integer)val; // How far to scan for e.g animals
        else if (cmd == "BOX_NAME")        provBoxName = val;
        else if (cmd == "WOOD_NAME")       SF_WOOD = val;
        else if (cmd == "POWER_NAME")      SF_POWER = val;
        else if (cmd == "HEALTH_MODE")     healthMode = (integer)val;
        else if (cmd == "COLLECTOR")       collector = val;
        else if (cmd == "USE_POINTS")      usePoints = (integer)val;
        else if (cmd == "MY_HUD")          MY_HUD = (integer)val;
        else if (cmd == "CRITTER")         critterName = val;
        else if (cmd == "TARGETS")         targets = llParseString2List(val, [",",";"], []);
        else if (cmd == "USE_OSEXTRA")     useOsExtra = (integer)val;
        else if (cmd == "USE_AGE")         useAge = (integer)val;
        else if (cmd == "ALLOW_DEATH")     allowDeath = (integer)val;
        else if (cmd == "HIDE_RESULTS")    hidePost = (integer)val;
        else if (cmd == "LANG")            languageCode = val;
        else if (cmd == "METABOLIC_RATE")  setTimeRate(val);
        else if (cmd == "INDICATOR_COLOR") indicatorColour = val;
        else if (cmd == "DISPLAY_TIME")
        {
            displayTime = (integer)val;
            if (displayTime < 1) displayTime = 1;
        }
        else if (cmd == "BASE_AGE")
        {
            // Can be Adult, Child, Baby, Sim or an actual number between 1 & 10
            val = llToUpper(val);
                 if (val == "ADULT") baseAge = 10;
            else if (val == "CHILD") baseAge = 5;
            else if (val == "BABY")  baseAge = 0;
            else if (val == "SIM")
            {
                baseAge = -1;
                owner_age_query = llRequestAgentData(userID, DATA_BORN);
                status = "waitAge";
            }
            else
            {
                baseAge = (integer)val;
                if (baseAge == 0) baseAge =10; else if (baseAge >10) baseAge = 10;
            }
        }
        else if (cmd == "DEBUG")
        {
            systemDebug = (integer)val;
        }

        // Let status HUD know if to use the 'extreme' sounds
        llMessageLinked(LINK_SET, useXtremeFX, "EXTREME_FX", "");

        // Let display screen now how long to show messages
        llMessageLinked(LINK_SET, 1, "DISPLAY_TIME|"+(string)displayTime, "");

        // Let display know if to also show %age numbers on indicators
        llMessageLinked(LINK_SET, showNums, "RINGNUMS", "");

        // Send baby targets
        llMessageLinked(LINK_SET, useOsExtra, "B_TARGETS|"+SF_PREFIX+"|"+llDumpList2String(targets, "|"), "");

        // Check for invalid values for sound volume
        if ((useEffects == TRUE) && (fxVolume < 0.1)) fxVolume = 0.1;
    }
}

loadConfig()
{
    list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
    integer i;

    for (i=0; i < llGetListLength(lines); i++)
    {
        if (llGetSubString(llList2String(lines,i), 0, 0) != "#")
        {
            setConfig(llList2String(lines,i));
        }
    }

    if (MY_HUD == TRUE)
    {
        statusIndicator = INDHUDNAME_MAIN;
        SUFFIX = "H1";
    }
    else
    {
        statusIndicator = INDHUDNAME_BABY;
        SUFFIX = "B2";
    }
}

setVals(list descValues)
{
    hungry = llList2Float(descValues, 1);
    thirsty = llList2Float(descValues, 2);
    hygiene = llList2Float(descValues, 3);
    health = llList2Float(descValues, 4);
    point = llList2Float(descValues, 5);
    foodStore = llList2Integer(descValues, 6);
    drinkStore = llList2Integer(descValues, 7);
    boozeStore = llList2Integer(descValues, 8);
    medicineStore = llList2Integer(descValues, 9);
    useEffects = llList2Integer(descValues, 10);
    scanRange = llList2Integer(descValues, 11);
    bladder = llList2Float(descValues, 12);
    privKey = llList2String(descValues, 13);
    provLocked = llList2Integer(descValues, 14);
    woodStore = llList2Integer(descValues, 15);
    setTimeRate(llList2String(descValues, 16));
    healthMode =  llList2Integer(descValues, 17);
    energy =  llList2Float(descValues, 18);
    OOC =  llList2Integer(descValues, 19);
    languageCode = llList2String(descValues, 20);
    hudSpacing = llList2Integer(descValues, 21);
    echoChat = llList2Integer(descValues, 22);
    statusHudVisible = llList2Integer(descValues, 23);
    energyStore = llList2Integer(descValues, 24);
    storedTime = llList2Integer(descValues, 25);

    if (provLocked == TRUE) borderColour = YELLOW; else borderColour = WHITE;

    // We need to use percentages from last session to adjust the related timestamps
    // So for 10% stored, we take of the time equivelant to 10% etc
    lastEatTs = llRound(lastEatTs - ((hungry / 100) * timeRate));
    lastDrinkTs = llRound(lastDrinkTs - ((thirsty / 100) * timeRate));
    lastBladderTs = llRound(lastBladderTs - ( (bladder / 100) * timeRate));

    string result = vals2Desc();
    debug("SETVALS:"+result);
}

// Load values and settings from description
loadStoredVals()
{
    if (safetyCheck == FALSE)
    {
        list descValues = llParseString2List(llGetObjectDesc(), [";"], [""]);

        if (llGetListLength(descValues) >0)
        {
            // Transfer values from description to relavent varibales
            setVals(descValues);
            updateIndicator("", WHITE);
        }
        else
        {
            postMessage("task=gethudbak&data1="+(string)userID);
            status = "waitLoadHUDbak";
            llSetTimerEvent(30.0);
        }
    }
}

string vals2Desc()
{
    string result = "";

    if (safetyCheck == FALSE)
    {
        result = "H;" +(string)llRound(hungry) +";" +(string)llRound(thirsty) +";" +(string)llRound(hygiene) +";" +(string)llRound(health) +";"
            +(string)llRound(point) +";" +(string)llRound(foodStore) +";" +(string)llRound(drinkStore) +";" +(string)llRound(boozeStore) +";"
            +(string)llRound(medicineStore) +";" +(string)useEffects +";" +(string)scanRange +";" +(string)llRound(bladder) +";"
            +privKey+ ";" +(string)provLocked +";" +(string)woodStore +";" +getTimeRate() +";"     +(string)healthMode +";"
            +llRound(energy) +";" +(string)OOC +";" +languageCode +";" +(string)hudSpacing +";" +(string)echoChat +";"
             +(string)statusHudVisible +";" +(string)energyStore +";" +(string)llRound(elapsedTime);

        llSetObjectDesc(result);
    }

    return result;
}

// Save the current settings and values
saveState()
{
    if (safetyCheck == FALSE)
    {
        // SAVE TO SERVER
        postMessage("task=sethudbak&data1="+(string)userID +"&data2="+vals2Desc());
        llSleep(0.5);
        showStatus(getVersionText());
    }
}

loadLanguage(string langCode)
{
    // optional language notecard
    string languageNC = langCode + "-lang" + SUFFIX;
    debug("loadLanguage asked for " + TXT_LANGUAGE + " " +languageNC);

    if (llGetInventoryType(languageNC) == INVENTORY_NOTECARD)
    {
        string line;
        list tok;
        list lines = llParseStringKeepNulls(osGetNotecard(languageNC), ["\n"], []);
        integer i;

        for (i=0; i < llGetListLength(lines); i++)
        {
            line = llList2String(lines, i);

            if (llGetSubString(line, 0, 0) != ";")
            {
                tok = llParseString2List(line, ["="], []);

                if (llList2String(tok,1) != "")
                {
                    string cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
                    string val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

                    // Remove start and end " marks
                    val = llGetSubString(val, 1, -2);

                    // Now check for language translations
                         if (cmd == "TXT_ADVANCED")         TXT_ADVANCED = val;
                    else if (cmd == "TXT_AFK")              TXT_AFK = val;
                    else if (cmd == "TXT_AGE_ADULT")        TXT_AGE_ADULT = val;
                    else if (cmd == "TXT_AGE_BABY")         TXT_AGE_BABY = val;
                    else if (cmd == "TXT_AGE_CHILD")        TXT_AGE_CHILD = val;
                    else if (cmd == "TXT_OOC")              TXT_OOC = val;
                    else if (cmd == "TXT_AVG_HAPPY")        TXT_AVG_HAPPY = val;
                    else if (cmd == "TXT_AVG_HUNGER")       TXT_AVG_HUNGER = val;
                    else if (cmd == "TXT_AVG_THIRST")       TXT_AVG_THIRST = val;
                    else if (cmd == "TXT_BABY")             TXT_BABY = val;
                    else if (cmd == "TXT_BACKPACK")         TXT_BACKPACK = val;
                    else if (cmd == "TXT_BAD_PASSWORD")     TXT_BAD_PASSWORD = val;
                    else if (cmd == "TXT_BACKUP")           TXT_BACKUP = val;
                    else if (cmd == "TXT_BLADDER")          TXT_BLADDER = val;
                    else if (cmd == "TXT_BONUS")            TXT_BONUS = val;
                    else if (cmd == "TXT_BOOZE")            TXT_BOOZE = val;
                    else if (cmd == "TXT_CAUTION")          TXT_CAUTION = val;
                    else if (cmd == "TXT_CHAT_ON")          TXT_CHAT_ON = val;
                    else if (cmd == "TXT_CLOSE")            TXT_CLOSE = val;
                    else if (cmd == "TXT_CONSUME")          TXT_CONSUME = val;
                    else if (cmd == "TXT_CONSUMED")         TXT_CONSUMED = val;
                    else if (cmd == "TXT_CONSUMING")        TXT_CONSUMING = val;
                    else if (cmd == "TXT_CREDITED")         TXT_CREDITED = val;
                    else if (cmd == "TXT_CURRENT_VALUE")    TXT_CURRENT_VALUE = val;
                    else if (cmd == "TXT_DATA_ERROR")       TXT_DATA_ERROR = val;
                    else if (cmd == "TXT_DEAD")             TXT_DEAD = val;
                    else if (cmd == "TXT_DEBUG")            TXT_DEBUG = val;
                    else if (cmd == "TXT_DEBUG_VALUES")     TXT_DEBUG_VALUES = val;
                    else if (cmd == "TXT_DRINK_NOW")        TXT_DRINK_NOW = val;
                    else if (cmd == "TXT_DRINK")            TXT_DRINK = val;
                    else if (cmd == "TXT_DRUNK")            TXT_DRUNK = val;
                    else if (cmd == "TXT_EAT_NOW")          TXT_EAT_NOW = val;
                    else if (cmd == "TXT_ECHO_TEXT")        TXT_ECHO_TEXT = val;
                    else if (cmd == "TXT_EFFECTS")          TXT_EFFECTS = val;
                    else if (cmd == "TXT_ENERGY")           TXT_ENERGY = val;
                    else if (cmd == "TXT_ERROR")            TXT_ERROR = val;
                    else if (cmd == "TXT_FEMALES")          TXT_FEMALES = val;
                    else if (cmd == "TXT_FETCHING")         TXT_FETCHING = val;
                    else if (cmd == "TXT_FOOD")             TXT_FOOD = val;
                    else if (cmd == "TXT_FROM")             TXT_FROM = val;
                    else if (cmd == "TXT_GETTING_INFO")     TXT_GETTING_INFO = val;
                    else if (cmd == "TXT_HAPPY")            TXT_HAPPY = val;
                    else if (cmd == "TXT_HEALTH")           TXT_HEALTH = val;
                    else if (cmd == "TXT_HEALTH_MODE")      TXT_HEALTH_MODE = val;
                    else if (cmd == "TXT_HELP")             TXT_HELP = val;
                    else if (cmd == "TXT_HIGH")             TXT_HIGH = val;
                    else if (cmd == "TXT_HUNGRY")           TXT_HUNGRY = val;
                    else if (cmd == "TXT_HYGIENE")          TXT_HYGIENE = val;
                    else if (cmd == "TXT_INFORMATION")      TXT_INFORMATION = val;
                    else if (cmd == "TXT_INSPECT")          TXT_INSPECT = val;
                    else if (cmd == "TXT_INTERACTION")      TXT_INTERACTION = val;
                    else if (cmd == "TXT_LESS_BOOZE")       TXT_LESS_BOOZE = val;
                    else if (cmd == "TXT_LESS_FOOD")        TXT_LESS_FOOD = val;
                    else if (cmd == "TXT_LESS_LIQUIDS")     TXT_LESS_LIQUIDS = val;
                    else if (cmd == "TXT_LEVELS")           TXT_LEVELS = val;
                    else if (cmd == "TXT_LOAD")             TXT_LOAD = val;
                    else if (cmd == "TXT_LOADING_VALUES")   TXT_LOADING_VALUES = val;
                    else if (cmd == "TXT_LOW")              TXT_LOW = val;
                    else if (cmd == "TXT_MALES")            TXT_MALES = val;
                    else if (cmd == "TXT_MEDICINE")         TXT_MEDICINE = val;
                    else if (cmd == "TXT_MEDIUM")           TXT_MEDIUM = val;
                    else if (cmd == "TXT_MENU_HELP")        TXT_MENU_HELP = val;
                    else if (cmd == "TXT_MENU_MAIN")        TXT_MENU_MAIN = val;
                    else if (cmd == "TXT_MENU_PROVISIONS")  TXT_MENU_PROVISIONS = val;
                    else if (cmd == "TXT_MENU_OPTIONS")     TXT_MENU_OPTIONS = val;
                    else if (cmd == "TXT_METABOLIC")        TXT_METABOLIC = val;
                    else if (cmd == "TXT_MINUTES")          TXT_MINUTES = val;
                    else if (cmd == "TXT_MODE")             TXT_MODE = val;
                    else if (cmd == "TXT_NO_PROVISIONS")    TXT_NO_PROVISIONS = val;
                    else if (cmd == "TXT_NOT_CONSUMABLE")   TXT_NOT_CONSUMABLE = val;
                    else if (cmd == "TXT_NOT_ENOUGH")       TXT_NOT_ENOUGH = val;
                    else if (cmd == "TXT_NOT_FOUND")        TXT_NOT_FOUND = val;
                    else if (cmd == "TXT_NOT_STORABLE")     TXT_NOT_STORABLE = val;
                    else if (cmd == "TXT_NUTRITION")        TXT_NUTRITION = val;
                    else if (cmd == "TXT_OFF")              TXT_OFF = val;
                    else if (cmd == "TXT_ON")               TXT_ON = val;
                    else if (cmd == "TXT_OPTIONS")          TXT_OPTIONS = val;
                    else if (cmd == "TXT_PAUSE")            TXT_PAUSE = val;
                    else if (cmd == "TXT_PAUSED")           TXT_PAUSED = val;
                    else if (cmd == "TXT_ACCOUNT")          TXT_ACCOUNT = val;
                    else if (cmd == "TXT_POWER")            TXT_POWER = val;
                    else if (cmd == "TXT_PROGRESS")         TXT_PROGRESS = val;
                    else if (cmd == "TXT_PROVISIONS_BOX")   TXT_PROVISIONS_BOX = val;
                    else if (cmd == "TXT_PROVISIONS_TRANSFERRED") TXT_PROVISIONS_TRANSFERRED = val;
                    else if (cmd == "TXT_PROVISIONS")        TXT_PROVISIONS = val;
                    else if (cmd == "TXT_RADIUS")            TXT_RADIUS = val;
                    else if (cmd == "TXT_RANGE")             TXT_RANGE = val;
                    else if (cmd == "TXT_REATTACH")          TXT_REATTACH = val;
                    else if (cmd == "TXT_REQUESTING_INFO")   TXT_REQUESTING_INFO = val;
                    else if (cmd == "TXT_RESET_CONFIRM")     TXT_RESET_CONFIRM = val;
                    else if (cmd == "TXT_RESET")             TXT_RESET = val;
                    else if (cmd == "TXT_RESUME")            TXT_RESUME = val;
                    else if (cmd == "TXT_REZ_BOX")           TXT_REZ_BOX = val;
                    else if (cmd == "TXT_REZ_KWH")           TXT_REZ_POWER = val;
                    else if (cmd == "TXT_REZ_POWER")         TXT_REZ_POWER = val;
                    else if (cmd == "TXT_REZ_WOOD")          TXT_REZ_WOOD = val;
                    else if (cmd == "TXT_RIP")               TXT_RIP = val;
                    else if (cmd == "TXT_SAVE")              TXT_SAVE = val;
                    else if (cmd == "TXT_SAVING")            TXT_SAVING = val;
                    else if (cmd == "TXT_SCAN_RANGE")        TXT_SCAN_RANGE = val;
                    else if (cmd == "TXT_SCAN")              TXT_SCAN = val;
                    else if (cmd == "TXT_SCANNING")          TXT_SCANNING = val;
                    else if (cmd == "TXT_SEASON_CHANGE")     TXT_SEASON_CHANGE = val;
                    else if (cmd == "TXT_SELECT_CONSUME")    TXT_SELECT_CONSUME = val;
                    else if (cmd == "TXT_SELECT_INSPECT")    TXT_SELECT_INSPECT = val;
                    else if (cmd == "TXT_SELECT_STORE")      TXT_SELECT_STORE = val;
                    else if (cmd == "TXT_SERVER")            TXT_SERVER = val;
                    else if (cmd == "TXT_SICK")              TXT_SICK = val;
                    else if (cmd == "TXT_SLEEPING")          TXT_SLEEPING = val;
                    else if (cmd == "TXT_SPACING_1")         TXT_SPACING_1 = val;
                    else if (cmd == "TXT_SPACING_2")         TXT_SPACING_2 = val;
                    else if (cmd == "TXT_STATUS")            TXT_STATUS = val;
                    else if (cmd == "TXT_STATUS_HUD")        TXT_STATUS_HUD = val;
                    else if (cmd == "TXT_STORAGE")           TXT_STORAGE = val;
                    else if (cmd == "TXT_STORE_ITEM")        TXT_STORE_ITEM = val;
                    else if (cmd == "TXT_STORE_LEVELS")      TXT_STORE_LEVELS = val;
                    else if (cmd == "TXT_STORED")            TXT_STORED = val;
                    else if (cmd == "TXT_STUNG")             TXT_STUNG = val;
                    else if (cmd == "TXT_TALKING_TO_SERVER") TXT_TALKING_TO_SERVER = val;
                    else if (cmd == "TXT_THIRSTY")           TXT_THIRSTY = val;
                    else if (cmd == "TXT_TOTAL")             TXT_TOTAL = val;
                    else if (cmd == "TXT_TOUCH")             TXT_TOUCH = val;
                    else if (cmd == "TXT_TOUCH_RESUME")      TXT_TOUCH_RESUME = val;
                    else if (cmd == "TXT_UNITS")             TXT_UNITS = val;
                    else if (cmd == "TXT_VERSION")           TXT_VERSION = val;
                    else if (cmd == "TXT_VISIT_LAVATORY")    TXT_VISIT_LAVATORY = val;
                    else if (cmd == "TXT_VISIT_WEBSITE")     TXT_VISIT_WEBSITE = val;
                    else if (cmd == "TXT_WARNING_RESET")     TXT_WARNING_RESET = val;
                    else if (cmd == "TXT_WEBSITE")           TXT_WEBSITE = val;
                    else if (cmd == "TXT_WELLBEING")         TXT_WELLBEING = val;
                    else if (cmd == "TXT_WHAT_USE")          TXT_WHAT_USE = val;
                    else if (cmd == "TXT_WHICH_ANIMAL")      TXT_WHICH_ANIMAL = val;
                    else if (cmd == "TXT_YOU_ARE_SICK")      TXT_YOU_ARE_SICK = val;
                    else if (cmd == "TXT_LANGUAGE")          TXT_LANGUAGE = val;
                    else if (cmd == "TXT_LOCK")              TXT_LOCK = val;
                    else if (cmd == "TXT_UNLOCK")            TXT_UNLOCK = val;
                    else if (cmd == "TXT_LOCKED")            TXT_LOCKED = val;
                    else if (cmd == "TXT_UNLOCKED")          TXT_UNLOCKED = val;
                    else if (cmd == "TXT_NO_KEY")            TXT_NO_KEY = val;
                    else if (cmd == "TXT_WOOD")              TXT_WOOD = val;
                    else if (cmd == "TXT_XP")                TXT_XP = val;
                    else if (cmd == "TXT_FULFILMENT")        TXT_FULFILMENT = val;
                    else if (cmd == "TXT_FUSTRATION")        TXT_FUSTRATION = val;
                    else if (cmd == "TXT_RELOAD")            TXT_RELOAD = val;
                    else if (cmd == "TXT_STOP_ANIM")         TXT_STOP_ANIM = val;
                }
            }
        }

        llMessageLinked(LINK_THIS, 1, "CMD_LANG|"+langCode, NULL_KEY);
    }
}

integer getNotecardVer(string ncName)
{
    integer noteCardVer = -1;

    if (llGetInventoryType(ncName) == INVENTORY_NOTECARD)
    {
        list ltok = llParseString2List(osGetNotecard(ncName), ["\n"], []);
        integer l;

        for (l=0; l < llGetListLength(ltok); l++)
        {
            string line = llList2String(ltok, l);

            if (llGetSubString(line, 0, 0) == "@")
            {
                noteCardVer = llList2Integer(llParseString2List(line, ["="], []), 1);

                return noteCardVer;
            }
        }
    }

    return noteCardVer;
}

string fixedStrLen(string value, integer length)
{
    string returnStr = value;
    while (llStringLength(returnStr) < length)
    {
        returnStr = " " + returnStr;
    }

    if (llStringLength(returnStr) > length)
    {
        returnStr = llGetSubString(value, 0, length-1);
    }

    return returnStr;
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

integer getLinkNum(string name)
{
    integer i;

    for (i=1; i <=llGetNumberOfPrims(); i++)
        if (llGetLinkName(i) == name) return i;
    return -1;
}

string getVersionText()
{
    return "[VivoSim HUD " +TXT_VERSION +" " +subVersion +" " +qsFloat2String(VERSION, 2, FALSE) +"]";
}

startAnim(string anim)
{
    debug("curAnim="+curAnim + "  requested anim=" +anim);
    debug("Hygiene="+llRound(hygiene) +": Bladder="+llRound(bladder) +" : Health="+llRound(health) +" : Drunk="+llRound(drunk) +" : Energy="+llRound(energy) +"\nWellbeing="+ (string)wellbeing);

    if (curAnim != anim)
    {
        llStopAnimation(curAnim);
        curAnim = anim;

        if (curAnim != "")
        {
            animTs = llGetUnixTime();

            if (useEffects == TRUE)
            {
                llStartAnimation(curAnim);
                llSetTimerEvent(2.0);
            }
        }
    }
}

floatText(string msg, vector colour, integer raw)
{

    debug("floatText - Raw="+(string)raw + "  msg=|"+msg+"|\n");
    string sendMsg = "";

    if (msg != lastText)
    {
        string shortOnly = "0";

        if (msg == TXT_TALKING_TO_SERVER) shortOnly = "1";

        if (MY_HUD == TRUE)
        {
            if (raw == TRUE) sendMsg = wasSpaceWrap(msg, "\n", 64) +"|" +(string)colour; else sendMsg = msg +"|" +(string)colour;
            sendMsg += "|" +shortOnly;

            llMessageLinked(LINK_ALL_CHILDREN, 1, "SHOWTEXT|"+sendMsg, "");
        }

        lastText = msg;
        vals2Desc();

        if (echoChat == TRUE) llRegionSayTo(userID, 0, msg);

    }
}

string trimPrefix(string name)
{
    // Assumes prefix is always 2 digits and a space
    return llGetSubString(name, 3, -1);
}

txt_off()
{
    // If something was on the screen we should wait at least 30 seconds before clearing it
    if ((llGetUnixTime() - screenTs > 30) || (screenTs == -1))
    {
        if (MY_HUD == TRUE) llSetText("", ZERO_VECTOR, 0);
        llMessageLinked(LINK_SET, 1, "SCREENOFF", "");
        lastText = "";
        screenTs = -1;
    }
}

updateIndicator(string msg, vector colour)
{
    // Send updated information to display etc
    llMessageLinked(LINK_ALL_CHILDREN, (integer)hungry, "HUNGER", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)thirsty, "THIRST", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)drunk, "DRUNK", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)bladder, "BLADDER", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)energy, "ENERGY", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)fulfilment, "FULFILMENT", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)frustration, "FRUSTRATION", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)point, "POINT", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)(100-health), "HEALTH", "");
    llMessageLinked(LINK_ALL_CHILDREN, (integer)(100-hygiene), "HYGIENE", "");
    llMessageLinked(LINK_ALL_CHILDREN, llRound(wellbeing/7), "WELLBEING", "");  // wellbeing goes from 0 to 700

    if (checkIndicator(statusIndicator) == TRUE)
    {
        if (healthMode == TRUE)
        {
            llMessageLinked(LINK_ALL_CHILDREN, 0, "COMMS|INDICATOR|1", "");
            messageObj(indicatorKey, "TEXT|" +PASSWORD +"|" +msg +"|" +(string)colour);

            if ((hygiene < 51) && (useEffects == TRUE))
            {
                messageObj(indicatorKey, "DIRTY|" +PASSWORD +"|" +llRound(-1*(hygiene-50)));
            }
            else
            {
                messageObj(indicatorKey, "CLEAN|" +PASSWORD);
            }

            if ((bladder > 61) && (useEffects == TRUE))
            {
                messageObj(indicatorKey, "BURSTING|" +PASSWORD +"|" +llRound(-1*(bladder-60)));
            }
            else
            {
                messageObj(indicatorKey, "RELIEVED|" +PASSWORD);
            }
        }
        else
        {
            messageObj(indicatorKey, "TEXT|" +PASSWORD +"|. .|" +(string)WHITE);
        }
    }
}

setHealthMode(integer level)
{
    healthMode = level;

    if (healthMode == 0)
    {
        floatText(TXT_HEALTH_MODE +": " + TXT_OFF +"\n ", PURPLE, 1);
        llMessageLinked(LINK_SET, 0, "HYGIENEOFF", "");
        llMessageLinked(LINK_SET, 0, "BLADDEROFF", "");
        if (checkIndicator(statusIndicator) == TRUE) messageObj(indicatorKey, "OFF|" +PASSWORD);
    }
    else
    {
        floatText(TXT_HEALTH_MODE +": " + TXT_ON +"\n ", PURPLE, 1);
        llMessageLinked(LINK_SET, 0, "HYGIENEON", "");
        llMessageLinked(LINK_SET, 0, "BLADDERON", "");
        refresh();
        updateIndicator("()", PURPLE);
        showStatus(getVersionText());
    }

    checkIndicator(statusIndicator);
}

refresh()
{
    if ((safetyCheck == TRUE) || (status == "waitLoadHUDbak")) return;

    if ((checkIndicator(statusIndicator) == TRUE) && (healthMode == TRUE))
    {
        if (AFK == TRUE)
        {
            if (llGetAgentInfo(userID) & AGENT_AWAY == FALSE)
            {
                AFK = FALSE;
                // llStopAnimation("away");
            }
        }
    }

    // Check for indicator HUD, either ours or one that is part of an attached critter such as baby
    if (MY_HUD == FALSE)
    {
        if (checkIndicator(statusIndicator) == TRUE)
        {
            llOwnerSay("HUD_CHK");
        }
    }
    else
    {
        if (healthMode == FALSE) energy = 100; else checkIndicator(statusIndicator);
    }

    if (active == TRUE)
    {
        if (sleeping == FALSE)
        {
            string str;
            string sa = "";

            // Get time stamp for 'now'
            integer ts = llGetUnixTime();

            // Elapsed time from last zeroing of script timer plus any from previous session
            elapsedTime = llGetTime() + storedTime;

            // Award point every (timeRate * 3) elapsed minutes
            point = (elapsedTime / (timeRate * 3)) * 100;

            // Goes from 0 at lastEatTs being same as ts, to 100 at lastEatTs being same as timeRate
            integer elapsedEatTime = ts - lastEatTs;
            hungry = (elapsedEatTime / (timeRate/hungerRate)) * 100;

            integer elapsedDrinkTime = ts - lastDrinkTs;
            thirsty = (elapsedDrinkTime / (timeRate/thirstRate) ) * 100;

            integer elapsedBladderTime = ts - lastBladderTs;
            bladder = (elapsedBladderTime / (timeRate/bladderRate)) * 100;


            if (hungry > 100.0) hungry = 100.0;

            if (thirsty > 100.0) thirsty = 100.0;

            if ( (hungry > trigLevel) || (thirsty > trigLevel) )
            {
                point -= 0.5;
                if (point < 5) point = 5.0;

                energy -= 0.5;
                if (energy <0) energy =0;
            }

            if (drunk > 0.0)
            {
                drunk -= (float)(ts - lastHealthTs)/20.0;

                if (drunk < 0.0)
                {
                    drunk = 0.0;
                }
            }

            health += (float)(ts - lastHealthTs)/(timeRate*healthRate);

            if (health >100.0)
             {
                health = 100.0;
            }

            if (healthMode == TRUE)
            {
                hygiene -= (float)(elapsedTime)/(timeRate*hygieneRate);

                if (hygiene <0.0)
                {
                    hygiene = 0.0;
                }

                if ((health + hygiene) < 100.0)
                {
                    point -= 0.5;
                }

                bladder += (float)(elapsedTime)/(timeRate*bladderRate);

                if (bladder >100.0)
                {
                    bladder = 100.0;
                }

                if (bladder > 75.0 )
                {
                    point -= 1.5;
                }
            }

            // Send updated information to display etc
            updateIndicator(TXT_LOADING_VALUES, PURPLE);

            lastHealthTs = ts;

            if (hungry > trigLevel)
            {
                sa = "faint";
                floatText(TXT_EAT_NOW +"\n ", ORANGE, 1);

                if (hungry > 95.0)
                {
                    hungry = 90.0;
                    health -=0.5;
                    
                    if (health <1.0)
                    {
                        health = 1.0;
                    }
                }
            }
            else if (hungry <5.0)
            {
                if (hungry <0.0) hungry = 0.0;
            }

            if (thirsty>trigLevel)
            {
                sa = "faint";
                floatText(TXT_DRINK_NOW +"\n ", ORANGE, 1);

                if (thirsty >95.0)
                {
                    thirsty = 90.0;
                    health -=0.5;
                    
                    if (health <1.0)
                    {
                        health = 1.0;
                    }
                }
            }
            else if (thirsty < 0.0)
            {
                thirsty = 0.0;
            }

            if (drunk >90.0)
            {
                sa = "drunk";
                floatText(TXT_LESS_BOOZE +"\n ", TEAL, 1);
                health -=10.0;
                
                if (health <1.0)
                {
                    health = 1.0;
                }
            }
            else
            {
                if (drunk < 0.0)
                {
                    drunk = 0.0;
                }
            }

            if (health <25.0)
            {
                sa = "sick";
                floatText(TXT_YOU_ARE_SICK +"\n ", OLIVE, 1);
            }

            if (bladder >90.0)
            {
                floatText(TXT_VISIT_LAVATORY +"\n ", OLIVE, 1);
            }

            if (point > 99.5)
            {
                // Reset point count, elapsed script time & give energy
                energy += 25;
                point = 0.0;
                storedTime = 0;
                llResetTime();
                vals2Desc();

                if ((MY_HUD == TRUE))
                {
                    integer award = 1;

                    if (usePoints == TRUE)
                    {
                        llMessageLinked(LINK_THIS, award, "CMD_PLUSPNT|" +(string)hidePost, userID);
                        startAnim(wealthAnim);

                        if (useEffects == TRUE) llPlaySound(xpSound, fxVolume);
                        llSleep(2);
                        startAnim("");
                    }
                }

                if (energy >100) energy = 100;

                //refresh();
                floatText(TXT_REQUESTING_INFO +"\n ", ORANGE, 1);

                if ((lastNetCheck == "animals") || (lastNetCheck == ""))
                {
                    postMessage("task=verreq&data1="+values_nc);
                    status = "waitvaluesver";
                }
                else
                {
                    postMessage("task=verreq&data1="+animals_nc);
                    status = "waitanimalsver";
                }

                llSetTimerEvent(30);
            }

            if (ts - alertTs > 29)
            {
                if (sa == "faint")
                {
                    startAnim(faintAnim);
                    llSetTimerEvent(3.0);
                }
                else if (sa == "sick")
                {
                    startAnim(sickAnim);
                    llSetTimerEvent(3.0);
                }
                else if (sa == "drunk")
                {
                    startAnim(drunkAnim);
                    llSetTimerEvent(3.0);
                }
                else
                {
                    startAnim("");
                }

                alertTs = ts;
            }

            if (hungry > trigLevel || thirsty > trigLevel || drunk > trigLevel || health < trigLevel)
            {
                str = "";

                if (ts - alertTs > 50)
                {
                    if (hungry > trigLevel)
                    {
                        str += TXT_HUNGRY+" " +(string)llRound(hungry)+"%\n";
                    }

                    if (thirsty > trigLevel)
                    {
                    str += TXT_THIRSTY+" " +(string)llRound(thirsty)+"%\n";
                    }

                    if (drunk > trigLevel)
                    {
                        str += TXT_DRUNK+" " +(string)llRound(drunk)+"%\n";
                    }

                    if (health < trigLevel)
                    {
                        str += TXT_HEALTH+" " +(string)llRound(health)+"%";
                    }

                    str += "\n ";
                    floatText(str, ORANGE, 1);
                }

                alertTs = ts;
            }

            hungry = checkPercent(hungry);
            thirsty = checkPercent(thirsty);
            drunk = checkPercent(drunk);
            health = checkPercent(health);
            hygiene = checkPercent(hygiene);
            bladder = checkPercent(bladder);
            energy = checkPercent(energy);
            point = checkPercent(point);

            // wellbeing goes from 0 to 700
            if (wellbeing >700)
            {
                wellbeing =700;
            }
            
            if (wellbeing <0)
            {
                wellbeing =0;
            }

            vals2Desc();

            if (indicatorKey != NULL_KEY)
            {
                vector txtColour = OLIVE;
                string spacing = "\n";

                if (hudSpacing == 2) spacing = "\n \n";

                str = TXT_HUNGRY + ": " +llRound(hungry) + "%\t" + TXT_THIRSTY +": " +llRound(thirsty) +"%" +spacing;

                if (healthMode == 0)
                {
                    str += TXT_HEALTH +": "+(string)llRound(health)+"%\n";
                }
                else
                {
                    wellbeing = llRound(hungry +thirsty +drunk +bladder +(100-hygiene) +(100-health) +(100-energy));  // 0 is perfect wellbeing, 700 dead!
                    if (hygiene < 60) wellbeing += 50;
                    if (health < 50) wellbeing += 50;
                    if (bladder > 50) wellbeing += 50;
                    if (energy <10) wellbeing += 50;
                    if (hungry > 75) wellbeing += 50;
                    if (thirsty > 75) wellbeing += 50;

                    debug("Hygiene="+llRound(hygiene) +": Bladder="+llRound(bladder) +" : Health="+llRound(health) +" : Drunk="+llRound(drunk) +" : Energy="+llRound(energy) +"\nWellbeing="+ (string)wellbeing);

                    if (AFK == FALSE)
                    {
                        if (OOC == TRUE) str = "## " +TXT_OOC + " ##" +spacing + str;

                        str += TXT_BLADDER +": " +llRound(bladder) +"\t";
                        str += TXT_HYGIENE +": " +llRound(hygiene) +"%"+spacing;
                        str += TXT_HEALTH  +": " +llRound(health)  +"\t";
                        str += TXT_ENERGY  +": " +llRound(energy) +"%"+spacing;

                        if (MY_HUD == TRUE)
                        {
                            if (userXP != -1)
                            {
                                str += TXT_XP +": " +(string)userXP+"\t \t";
                            } 
                            else
                            {
                                str += TXT_XP +": ~\t \t";
                            }
                        }
                        else
                        {
                            str += "\t ";
                        }

                        integer wellDispNum = (integer)(100 - (wellbeing/7) );
                        string indy = "*";

                        if (wellDispNum <85) indy = "+";
                        if (wellDispNum <65) indy = "-";
                        if (wellDispNum <40) indy = ".";

                        str += llToUpper(TXT_WELLBEING) +" " +(string)wellDispNum +"% " +indy;

                        if (wellbeing >675)
                        {
                            txtColour = BLACK;

                            if (wellbeing >695)
                            {
                                if (isDead == FALSE)
                                {
                                    llStopAnimation(curAnim);
                                    startAnim(deadAnim);

                                    if (allowDeath == TRUE)
                                    {
                                        isDead = TRUE;
                                        str = "\n \n"+TXT_DEAD+"\t"+TXT_RIP+"\t"+TXT_DEAD+"\n  \n ";
                                        floatText(str, RED, 1);
                                        llSleep(5);

                                        if (MY_HUD == TRUE)
                                        {
                                            llTeleportAgentHome(userID);
                                        }

                                        state Dead;
                                    }
                                    else
                                    {
                                        systemReset(TRUE);
                                    }
                                }
                            }
                        }

                        if ((hygiene < 50) || (health < 60) || (bladder > 75) || (energy <5) || (hungry > 85) || (thirsty > 85) || (wellbeing > 650)) txtColour = RED;
                         else if ((hygiene < 60) || (health < 50) || (bladder > 50) || (energy <10) || (hungry > 75) || (thirsty > 75) || (wellbeing > 500)) txtColour = ORANGE;
                         else if ((hygiene < 70) || (health < 40) || (bladder > 40) || (energy <25) || (hungry > 50) || (thirsty > 50) || (wellbeing > 250)) txtColour = YELLOW;
                         else if ((hygiene < 80) || (health < 30) || (bladder > 25) || (energy <50) || (hungry > 35) || (thirsty > 35) || (wellbeing > 100)) txtColour = TEAL;
                        else txtColour = GREEN;

                        if (ts - alertTs > 40)
                        {
                            if (wellbeing > 600)
                            {
                                if (curAnim != sickAnim)
                                {
                                    startAnim(sickAnim);
                                    startAnim("");
                                    curAnim = sickAnim;
                                }
                            }
                            else if (wellbeing > 330)
                            {
                                if (curAnim != faintAnim)
                                {   startAnim(faintAnim);
                                    startAnim("");
                                    curAnim = faintAnim;
                                }
                            }

                            alertTs = ts;
                        }
                    }
                    else
                    {
                        str = "**  " +TXT_AFK + "  **";
                        txtColour = PURPLE;
                        floatText(str, PURPLE, 1);
                    }
                }

                updateIndicator(str, txtColour);
            }
        }
        else
        {
            // sleeping
            updateIndicator(TXT_SLEEPING, PURPLE);
        }

        // Update stored values in description
        vals2Desc();
    }
    else
    {
        floatText(TXT_PAUSED, RED, 1);
    }
}

provisionsMenu()
{
    debug("PROV MENU");
    list opts = [];
    opts += TXT_BOOZE;
    opts += TXT_MEDICINE;
    opts += TXT_CLOSE;
    opts += TXT_FOOD;
    opts += TXT_DRINK;
    startListen();
    llDialog(userID, "\n" +TXT_PROVISIONS_BOX +"\n \n" + TXT_WHAT_USE , opts, chan(llGetKey()));
    llSetTimerEvent(300);

    if (status == "provMenu") status = "waitProvType"; else status = "waitProvTypeRez";
}

integer startOffset=0;

multiPageMenu(key id, string message, list opt)
{
    integer l = llGetListLength(opt);
    integer ch = chan(llGetKey());

    if (l < 12)
    {
        llDialog(id, message, [TXT_CLOSE]+opt, ch);

        return;
    }

    if (startOffset >= l) startOffset = 0;

    list its = llList2List(opt, startOffset, startOffset + 9);
    llDialog(id, message, [TXT_CLOSE]+its+[">>"], ch);
}

// consume=1 for eat, 0 for store in provisions   apply = 0 if inspecting, 1 if using
integer handleValues(list tok, integer consume, integer apply)
{
    debug("handleValues:" +llDumpList2String(tok, "|") +"  Percent=" +(string)lookingForPercent +"%");

    // Set up store for the various 'nutrition' vales
    integer valueHungry       = 0;
    integer valueThirsty      = 0;
    integer valueDrunk        = 0;
    integer valueHealth       = 0;
    integer valueBladder      = 0;
    integer valueHygiene      = 0;
    integer valueEnergy       = 0;
    integer valueUserXP       = 0;
    integer valueFulfilment   = 0;
    integer valueFrustration  = 0;
    integer valueAgeMin       = 0;
    integer valueAgeMax       = 0;
    integer ret = 0;
    string  msg = "";
    string  data;
    float   itemValue;
    integer count = llGetListLength(tok);
    integer n;
    float   percent = (float)lookingForPercent / 100.0;
    float   totalValue = llList2Float(tok, 1);

    // If no value was given, default to using 100% of product
    if (totalValue == 0) totalValue = 100;

    totalValue = 100.0 / totalValue;

    // Add the name of the product
    if (consume == TRUE) msg += llList2String(tok,0) +"\n \n";

    /**
     * Extract each nutrition type from the data string. It's name, total percent to use then all the values
     *                0    1     2     3    4     5
     * e.g.        Apples|25| Thirsty|-5| Hungry|-20"
     */
    for (n = 1; n < count; n++)
    {
        data = llList2String(tok, n);   // Thirsty
        itemValue = totalValue * llList2Float(tok, n+1);

        if (data == "Hungry")
        {
            if (consume == TRUE)
            {
                valueHungry += llList2Integer(tok, n+1);
            }
            else
            {
                // Adjust to match percentage still in the product.
                foodStore -= llRound(itemValue * percent);
            }
            ret ++;
        }
        else if (data == "Thirsty")
        {
            if (consume == TRUE)
            {
                valueThirsty += llList2Integer(tok, n+1);
            }
            else
            {
                drinkStore -= llRound(itemValue * percent);
            }
            ret ++;
        }
        else if (data == "Drunk")
        {
            if (consume == TRUE)
            {
                valueDrunk += llList2Integer(tok, n+1);
                valueHealth -=  (integer)(llList2Integer(tok, n+1)*0.1);
            }
            else
            {
                boozeStore -= llRound(itemValue * percent);
            }
            ret ++;
        }
        else if (data == "Health")
        {
            if (consume == TRUE)
            {
                valueHealth += llList2Integer(tok, n+1);
            }
            else
            {
                medicineStore -= llRound(itemValue * percent);
            }
            ret ++;
        }
        else if (data == "Sick")
        {
            if (consume == TRUE)
            {
                valueHealth -= llList2Integer(tok, n+1);
            }
            else
            {
                medicineStore += llRound(-itemValue * percent);
            }
            ret ++;
        }
        else if (data == "Energy")
        {
                valueEnergy += llList2Integer(tok, n+1);
                ret ++;
        }
        else if (data == "Hygiene")
        {
                valueHygiene += llList2Integer(tok, n+1);
                ret ++;
        }
        else if (data == "Bladder")
        {
                valueBladder += llList2Integer(tok, n+1);
                ret ++;
        }
        else if (data == "Fulfilment")
        {
            valueFulfilment += llList2Integer(tok, n+1);
            ret ++;
        }
        else if (data == "Frustration")
        {
            valueFrustration += llList2Integer(tok, n+1);
            ret ++;
        }
        else if (data == "MinAge")
        {
            valueAgeMin  = llList2Integer(tok, n+1);
        }
        else if (data == "MaxAge")
        {
            valueAgeMax  = llList2Integer(tok, n+1);
        }
    }

    // Now tot up all the values
    if (valueHungry != 0)
    {
        if (apply == TRUE)
        {
            lastEatTs = llRound(llGetUnixTime() - ((hungry + valueHungry) * (timeRate/hungerRate) / 100));
            checkPercent(hungry);
        }

        msg += TXT_HUNGRY   +"\t" +(string)valueHungry+"\n";
    }

    if (valueThirsty != 0)
    {
        if (apply == TRUE)
        {
            lastDrinkTs = llRound(llGetUnixTime() - ((thirsty + valueThirsty) * (timeRate/thirstRate) / 100));
            thirsty = checkPercent(thirsty);
        }

        msg += TXT_THIRSTY  +"\t" +(string)valueThirsty+"\n";
    }

    if (valueDrunk != 0)
    {
        if (apply == TRUE)
        {
            drunk += valueDrunk;
            drunk = checkPercent(drunk);
        }

        msg += TXT_DRUNK    +"\t" +(string)valueDrunk+"\n";
    }

    if (valueHealth != 0)
    {
        if (apply == TRUE)
        {
            health += valueHealth;
            health = checkPercent(health);
        }

        msg += TXT_HEALTH   +"\t" +(string)valueHealth+"\n";
    }

    if (valueBladder != 0)
    {
        if (apply == TRUE)
        {
            lastBladderTs = llRound(llGetUnixTime() - ((bladder + valueBladder) * (timeRate/bladderRate) / 100));
            bladder = checkPercent(bladder);
        }

        msg += TXT_BLADDER  +"\t" +(string)valueBladder+"\n";
    }

    if (valueHygiene != 0)
    {
        if (apply == TRUE)
        {
            hygiene += valueHygiene;
            hygiene = checkPercent(hygiene);
        }

        msg += TXT_HYGIENE  +"\t" +(string)valueHygiene+"\n";
    }

    if (valueEnergy != 0)
    {
        if (apply == TRUE)
        {
            energy += valueEnergy;
            energy = checkPercent(energy);
        }

        msg += TXT_ENERGY   +"\t" +(string)valueEnergy+"\n";
    }

    if (valueFulfilment != 0)
    {
        if (apply == TRUE)
        {
            fulfilment += valueFulfilment;
        }

        msg += TXT_FULFILMENT  +"\t" +(string)valueFulfilment+"\n";
    }

    if (valueFrustration != 0)
    {
        if (apply == TRUE)
        {
            frustration += valueFrustration;
        }

        msg += TXT_FULFILMENT  +"\t" +(string)valueFrustration+"\n";
    }

    if (valueUserXP != 0)
    {
        if (apply == TRUE)
        {
            userXP += valueUserXP;
        }

        msg += TXT_XP  +"\t" +(string)valueUserXP+"\n";
    }

    refresh();

    if (apply == TRUE) msg = TXT_CONSUME +": "  +msg; else msg = TXT_INSPECT +": " +(string)lookingForPercent +"% " + msg;

    msg += "\n \n";
    floatText(msg, WHITE, 0);

    return ret;
}

showNutritionInfo()
{
    string tmpStr = "";
    list tmpLst;
    list ltok = llParseString2List(osGetNotecard(user_nc), ["\n"], []);
    integer l;
    llRegionSayTo(userID, 0, "----------- " +TXT_NUTRITION +" -----------");

    for (l=0; l < llGetListLength(ltok); l++)
    {
        string line = llList2String(ltok, l);

        if ( (llGetSubString(line, 0, 0) != "#") && (llGetSubString(line, 0, 0) != "@"))
        {
            //  Chocolate milkshake|50|Hungry-30|Thirsty-10
            tmpLst = llParseString2List(line, ["|"], []);
            tmpStr = llList2String(tmpLst, 0) +" " +llList2String(tmpLst, 1)+"%  |" +llDumpList2String(llList2List(tmpLst, 2, llGetListLength(tmpLst)), "|");
            llRegionSayTo(userID, 0, tmpStr);
        }
    }

    llRegionSayTo(userID, 0, "__");
    ltok = llParseString2List(osGetNotecard(values_nc ), ["\n"], []);

    for (l=0; l < llGetListLength(ltok); l++)
    {
        string line = llList2String(ltok, l);

        if ( (llGetSubString(line, 0, 0) != "#") && (llGetSubString(line, 0, 0) != "@"))
        {
            tmpLst = llParseString2List(line, ["|"], []);
            tmpStr = llList2String(tmpLst, 0) +" " +llList2String(tmpLst, 1)+"%  |" +llDumpList2String(llList2List(tmpLst, 2, llGetListLength(tmpLst)), "|");
            llRegionSayTo(userID, 0, tmpStr);
        }
    }

    llRegionSayTo(userID, 0, "----------- " +TXT_NUTRITION +" -----------");

    // Since we are here, ask server for any updated notecards
    debug("lastNetCheck=" +lastNetCheck);

    if ((lastNetCheck == "animals") || (lastNetCheck == ""))
    {
        postMessage("task=verreq&data1="+values_nc);
        status = "waitvaluesver";
    }
    else
    {
        postMessage("task=verreq&data1="+animals_nc);
        status = "waitanimalsver";
    }
}

list getAnimalList()
{
    list returnList = [];
    list ltok = llParseString2List(osGetNotecard(animals_nc), ["\n"], []);
    string line;
    integer i;

    // For notecards we should have the version number on first line as e.g.  @6
    string safetyCheck = llList2String(ltok, 0);

    if (llGetSubString(safetyCheck, 0, 0) == "@")
    {
        for (i = 0; i < llGetListLength(ltok); i++)
        {
            line = llList2String(ltok, i);

            if ( (llGetSubString(line, 0, 0) != "#") && (llGetSubString(line, 0, 0) != "@"))
            {
                returnList += line;
            }
        }
    }
    else
    {
        // Assume notecard is corrupt so delete and then we will get a fresh one from server
        llRemoveInventory(animals_nc);
        postMessage("task=verreq&data1="+animals_nc);
        status = "waitanimalsver";
    }

    return returnList;
}

list valuesFromNotecard(string itemName, string ncName)
{
    string line;
    string stub;
    string name;
    list tok = [];

    list ltok = llParseString2List(osGetNotecard(ncName), ["\n"], []);
    integer i;

    for (i=0; i < llGetListLength(ltok); i++)
    {
        line = llList2String(ltok, i);
        stub = llGetSubString(line, 0, 0);

        if ( (stub != "#") && (stub != "@") && (stub != ";"))
        {
            tok = llParseString2List(line, ["|", ":"], []);
            name = llList2String(tok,0);

            if (llToUpper(name) == llToUpper(itemName))
            {
                debug("valuesFromNotecard_line:" +line +"  name:" +name +"\n" + llDumpList2String(tok, "¦"));

                return tok;
            }
        }
    }
    return [];
}

showStoreLevels()
{
    string str = "\n\n** " +TXT_STORE_LEVELS +"**\n \n";

    if (provLocked == TRUE)
    {
        str += TXT_LOCKED+"\n";
    }
    else
    {
        str += TXT_UNLOCKED+"\n \n";
    }

    str += TXT_FOOD+": "+(string)llRound(foodStore)+" " +TXT_UNITS +"\t \t";
    str += TXT_DRINK+": "+(string)llRound(drinkStore)+" "+TXT_UNITS + "\n \n";
    str += TXT_BOOZE+": "+(string)llRound(boozeStore)+" " +TXT_UNITS +"\t \t";
    str += TXT_MEDICINE+": "+(string)llRound(medicineStore)+" "+TXT_UNITS + "\n \n";
    str += TXT_WOOD+": "+(string)llRound(woodStore)+" "+TXT_UNITS + "\t \t";
    str += SF_POWER+": "+(string)llRound(energyStore)+" "+TXT_UNITS + "\n";
    floatText(str+"\n ", WHITE, 0);
    string data2 = (string)llRound(foodStore)+";"+(string)llRound(drinkStore)+";"+(string)llRound(boozeStore)+";"+(string)llRound(medicineStore)+";"+(string)llRound(woodStore)+";"+(string)llRound(energyStore)+";"+pubKey+";"+privKey;
    llMessageLinked(LINK_SET, 1, "CMD_POST|"+"task=setprovs&data1="+(string)userID+"&data2="+data2, "");
}

showStatus(string extraInfo)
{
    if (healthMode == TRUE)
    {
        checkIndicator(statusIndicator);
    }

    //refresh();
    updateIndicator("", WHITE);
    string str = "";

    if (AFK == TRUE) str += "** "+TXT_AFK+" **\t";

    if (OOC == TRUE) str += "## "+TXT_OOC+" ##\t";

    string spacing = "\n \n";
    str += extraInfo + "\n \n";

    if (healthMode == 0)
    {
        str += TXT_HUNGRY+": "+(string)llRound(hungry)+"%\t \t";
        str += TXT_THIRSTY+": "+(string)llRound(thirsty)+"%" +spacing;
        str += TXT_HEALTH +": "+(string)llRound(health)+"%\t \t";
       // if (MY_HUD == TRUE) str += TXT_BONUS+": "+(string)llRound(point)+"%";
    }
    else
    {
        str += TXT_HUNGRY+": "+(string)llRound(hungry)+"%\t \t";
        str += TXT_THIRSTY+": "+(string)llRound(thirsty)+"%" +spacing;
        str += TXT_BLADDER +": "+(string)llRound(bladder)+"%\t \t";
        str += TXT_HYGIENE +": "+(string)llRound(hygiene)+"%" +spacing;
        str += TXT_HEALTH +": "+(string)llRound(health)+"%\t \t";
        str += TXT_ENERGY +" " +(string)llRound(energy)+"%" +spacing;
       // if (MY_HUD == TRUE) str += TXT_BONUS+": "+(string)llRound(point) +"." +llRound(bonus/10) +"%\t \t";
        integer wellDispNum = (integer)(100 - (wellbeing/7));
        string indy = "■";

        if (wellDispNum <85) indy = "≡";
        if (wellDispNum <65) indy = "=";
        if (wellDispNum <40) indy = "-";

        str += llToUpper(TXT_WELLBEING) +" " +(string)wellDispNum +"% " +indy;
    }

    str += "\n \n";
    floatText(str, WHITE, 0);
}

systemReset(integer full)
{
    // Don't let anything disturb us
    llSetTimerEvent(0);

    // Show we are doing a reset
    floatText(TXT_RESET +"\n ", PURPLE, 1);
    setBorder(PURPLE);

    // Set default values
    drunk   = 0.0;
    thirsty = 0.0;
    hungry  = 0.0;
    health = 100.0;
    hygiene = 100.0;
    bladder = 0.0;
    energy = 75.0;
    point = 0.0;
    foodStore = 0;
    drinkStore = 0;
    boozeStore = 0;
    medicineStore = 0;
    woodStore = 0;
    energyStore = 0;
    setTimeRate("M");
    fulfilment = 0;
    frustration = 0;
    userXP = -1;
    provLocked =FALSE;
    hudSpacing = 1;
    healthMode = TRUE;
    isDead = FALSE;
    safetyCheck = FALSE;
    storedTime = 0;
    elapsedTime = 0.0;
    llResetTime();

    integer ts = llGetUnixTime();
    lastEatTs = ts;
    lastDrinkTs = ts;
    lastBladderTs = ts;

    // Load notecard values
    loadConfig();
    loadLanguage(languageCode);

    // Update the object description
    vals2Desc();

    // Now do a reset to get things going again
    if (full == TRUE)
    {
        llSleep(0.5);
        llResetScript();
    }
    else
    {
        borderColour = WHITE;
    }
}

makeKeySet()
{
    pubKey = llGenerateKey();
    pubKey = llGetSubString(pubKey, 4, 12);
    privKey = llSHA1String(pubKey);
    privKey = llGetSubString(privKey, 4, 12);
    refresh();
}

integer unLock(string theKey)
{
    if (privKey == llGetSubString(llSHA1String(theKey), 4, 12)) return TRUE; else return FALSE;
}

setBorder(vector colour)
{
   llSetColor(colour, 1);   llSetColor(colour, 2);
   llSetColor(colour, 3);   llSetColor(colour, 4);
}

setPaused()
{
   llSetTimerEvent(0);
   llMessageLinked(LINK_SET, 1, "PAUSED", "");
   active = FALSE;
   llSetColor(WHITE,0);
   floatText(TXT_PAUSED +"\n \n" +TXT_TOUCH_RESUME +"\n \n", RED, 1);
   setBorder(RED);
   statusHudVisible = FALSE;

   if (checkIndicator(statusIndicator) == TRUE)
   {
        messageObj(indicatorKey, "VISIBILITY|" +PASSWORD+ "|0" +"|" +indicatorColour);
   }

   messageObj(indicatorKey, "PAUSED|" +PASSWORD +"|1");
   refresh();
}

startUp()
{
    // Saftey check okay so start things running
    listener = -1;
    AFK = FALSE;
    safetyCheck = FALSE;
    isDead = FALSE;
    PASSWORD = llStringTrim(osGetNotecard("sfp"), STRING_TRIM);
    animals = getAnimalList();
    animals = ["DEAD"] + animals;
    userID = llGetOwner();
    active = TRUE;
    listenerFarm = llListen(FARM_CHANNEL, "", "", "");

    // First character in object description should be 'H'
    if (llGetSubString(llGetObjectDesc(), 0, 0) != "H") systemReset(TRUE);

    loadConfig();
    loadLanguage(languageCode);
    llMessageLinked(LINK_THIS, 1, "LANG_MENU|" + SUFFIX, "");

    // Set all interval timestamps and main elapsed timer, to current unixTime
    llResetTime();
    pollTs = lastEatTs = lastDrinkTs = lastBladderTs = lastHealthTs = alertTs = llGetUnixTime();

    loadStoredVals();
    refresh();

    if (pubKey == "-") makeKeySet();

    setBorder(borderColour);

    if (healthMode == TRUE)
    {
        llMessageLinked(LINK_SET, 0, "HYGIENEON", "");
        llMessageLinked(LINK_SET, 0, "BLADDERON", "");
    }
    else
    {
        llMessageLinked(LINK_SET, 0, "HYGIENEOFF", "");
        llMessageLinked(LINK_SET, 0, "BLADDEROFF", "");
    }

    llMessageLinked(LINK_SET, 1, "STARTUP", "");
    llMessageLinked(LINK_SET, 0, "CMD_DEBUG|" +(string)systemDebug ,"");

    if (checkIndicator(statusIndicator) == TRUE)  messageObj(indicatorKey, "VISIBILITY|" +PASSWORD+ "|"+(string)statusHudVisible +"|" +indicatorColour);

    integer i = llRound(fxVolume*10);
    llMessageLinked(LINK_SET, useEffects, "CMD_CHATTY|"+(string)i, "");

    if (MY_HUD == FALSE)
    {
        mainTarget = llList2String(targets, 0);
        integer result = llGetAttached();
        llMessageLinked(LINK_SET, result, "CRITTER_STATUS", "");

        if (result == 0) llMessageLinked(LINK_SET, 1, "SEEK_SURFACE|"+SF_PREFIX +" "+mainTarget, "");
    }

    if (llGetAttached() != 0) llRequestPermissions(userID, PERMISSION_TRIGGER_ANIMATION); //asks the owner's permission to do animations

    llSetTimerEvent(2);
}

doTouch(key toucher)
{
    status = "";
    string tmpStr = "";
    list opts = [];

    if (llDetectedLinkNumber(0) == getLinkNum("Screen"))
    {
        // Force screen turn off
        screenTs = -1;
        lastText = "";
        txt_off();
    }
    else if (llDetectedLinkNumber(0) == getLinkNum("Message_indicator"))
    {
        llMessageLinked(LINK_SET, 1, "MSG_MENU", userID);
    }
    else
    {
        if (safetyCheck == FALSE)
        {
            checkIndicator(statusIndicator);
            if (llSameGroup(userID) == FALSE) floatText("\n" + TXT_CAUTION +"\n \n" +TXT_REATTACH +"\n \n", YELLOW, 1);

            checkListen(TRUE);

            if (active == TRUE)
            {
                if (MY_HUD == TRUE)
                {
                    opts += [TXT_HELP, TXT_OPTIONS ,TXT_CLOSE];
                    opts += [TXT_STATUS, TXT_ACCOUNT, TXT_SCAN];
                    opts += [TXT_CONSUME, TXT_INSPECT, TXT_PROVISIONS];

                    // Check if they are wearing backpack
                    key result = checkAttached(SF_PREFIX+" "+TXT_BACKPACK);

                    if (result != NULL_KEY) opts += TXT_BACKPACK;

                    // Check if they are wearing storage device eg pitchfork
                    result = checkAttached(SF_PREFIX+" "+collector);

                    if (result != NULL_KEY) opts += collector;

                    // Check if they are wearing a critter
                    result = checkAttached(SF_PREFIX+" "+critterName);

                    if (result != NULL_KEY)
                    {
                        opts+= [critterName];
                        critterKey = result;
                    }
                }
                else
                {
                    opts += [TXT_HELP, TXT_OPTIONS ,TXT_CLOSE];
                    opts += [TXT_TOUCH, TXT_STATUS, TXT_INTERACTION];
                    opts += [TXT_CONSUME, TXT_INSPECT, TXT_PROVISIONS];
                }
            }
            else
            {
                opts += [TXT_RESUME, TXT_CLOSE];
            }

            if (MY_HUD == TRUE)
            {
                tmpStr += TXT_RANGE+": " +scanRange + "m " +TXT_RADIUS +"\t";
            }

            tmpStr += "\t"+TXT_MODE +": ";

            if (useEffects == TRUE)
            {
                tmpStr += TXT_EFFECTS +": " +TXT_ON;
            }
            else
            {
                tmpStr += TXT_EFFECTS +": " +TXT_OFF;
            }
        }
        else
        {
            opts = TXT_RESET;
        }

        userID = toucher;
        startListen();
        llDialog(userID, "\n"+TXT_MENU_MAIN+" - "+NAME+"\n \n" +tmpStr, opts, chan(llGetKey()));
        llSetTimerEvent(180);
    }
}



default
{

    listen(integer c, string nm, key id, string m)
    {
        if (c == FARM_CHANNEL)
        {
            debug("farm_chan-listen:\n" +m);
        }
        else
        {
            debug("dialog-listen: Message=" +m +"  Status=" +status);
        }

        key result;

        if (c == FARM_CHANNEL)
        {
            list cmd = llParseStringKeepNulls(m, ["|"] , []);
            string item = llList2String(cmd,0);

            if ((item == "Spring") || (item =="Summer") || (item =="Autumn") || (item == "Winter"))
            {
                floatText(TXT_SEASON_CHANGE + " " + item, PURPLE, 1);

                return;
            }
            else if (item == "INDICATOR_HELLO")
            {
                indicatorKey = id;
                llSay(FARM_CHANNEL, "PING|" +PASSWORD +"|VSFHUD|" +(string)llGetOwner());

                return;
            }
            else if (item == "INDICATOR_INIT")
            {
                if (llList2Key(cmd, 1) == userID)
                {
                    messageObj(indicatorKey, "INIT|" + PASSWORD + "|"+(string)llGetKey());
                    llMessageLinked(LINK_ALL_CHILDREN, 0, "COMMS|INDICATOR|1", "");
                    refresh();
                    showStatus(getVersionText());
                }

                return;
            }
            else if (item == "PING")
            {
                debug("Heard PING from " + nm + " "+(string)id);

                return;
            }

            // These commands need valid password
            if (llList2String(cmd,1) != PASSWORD)
            {
                debug("listen_event: " + TXT_BAD_PASSWORD + " |" +item +"|  ID:" +(string)id);

                return;
            }

            if (((item == "STUNG") && (llList2Key(cmd,2) == userID)) == TRUE)
            {
                if (useEffects == TRUE)
                {
                    llPlaySound(beesSound,fxVolume);
                }
                else
                {
                    floatText(TXT_STUNG +"\n ", RED, 1);
                }

                health -= 5;
                showStatus(TXT_HEALTH +": -5");
            }
            else if (item == "PROGRESS")
            {
                if (llList2Key(cmd, 2) == userID)
                {
                    floatText(TXT_PROGRESS +": " +llList2String(cmd, 4) +"%  " +llList2String(cmd, 3) +"\n \n" , YELLOW, 1);
                }
            }
            else if (item == "COINCHK")
            {
                if (llList2Key(cmd, 2) == userID)
                {
                    llMessageLinked(LINK_THIS, 0, "CMD_COIN_CHECK|" +PASSWORD +"|" +(string)userID, "");
                }
            }
            else if (item == "HEALTH")
            {
                if (llList2Key(cmd, 2) == userID)
                {
                    if (llList2String(cmd, 3) == "CQ")
                    {
                        messageObj(id, "HEALTH|" +PASSWORD +"|ENERGY|" +(string)userID +"|" + (string)energy);

                        return;
                    }

                    if (llGetListLength(cmd) >3)
                    {
                        integer valueHungry  = 0;
                        integer valueThirsty = 0;
                        integer valueDrunk   = 0;
                        integer valueHealth  = 0;
                        integer valueBladder = 0;
                        integer valueHygiene = 0;
                        integer valueEnergy  = 0;
                        integer n;
                        string msg;

                        for (n=3; n < llGetListLength(cmd); n=n+2)
                        {
                                 if (llList2String(cmd, n) == "Hungry") valueHungry += llList2Integer(cmd, n+1);
                            else if (llList2String(cmd, n) == "Thirsty") valueThirsty += llList2Integer(cmd, n+1);
                            else if (llList2String(cmd, n) == "Drunk") valueDrunk += llList2Integer(cmd, n+1);
                            else if (llList2String(cmd, n) == "Health") valueHealth += llList2Integer(cmd, n+1);
                            else if (llList2String(cmd, n) == "Sick") valueHealth -= llList2Integer(cmd, n+1);
                            else if (llList2String(cmd, n) == "Energy") valueEnergy += llList2Integer(cmd, n+1);
                            else if (llList2String(cmd, n) == "Hygiene") valueHygiene += llList2Integer(cmd, n+1);
                            else if (llList2String(cmd, n) == "Bladder") valueBladder += llList2Integer(cmd, n+1);
                        }

                        if (valueHungry != 0)
                        {
                            lastEatTs = llRound(llGetUnixTime() - ((hungry + valueHungry) * (timeRate/hungerRate) / 100));
                            hungry = checkPercent(hungry);
                            msg += TXT_HUNGRY   +"\t" +(string)valueHungry+"\n";
                        }

                        if (valueThirsty != 0)
                        {
                            lastDrinkTs = llRound(llGetUnixTime() - ((thirsty + valueHungry) * (timeRate/thirstRate) / 100));
                            thirsty = checkPercent(thirsty);
                            msg += TXT_THIRSTY  +"\t" +(string)valueThirsty+"\n";
                        }

                        if (valueDrunk != 0)
                        {
                            drunk += valueDrunk;
                            drunk = checkPercent(drunk);
                            msg += TXT_DRUNK    +"\t" +(string)valueDrunk+"\n";
                        }

                        if (valueHealth != 0)
                        {
                            health += valueHealth;
                            health = checkPercent(health);
                            msg += TXT_HEALTH   +"\t" +(string)valueHealth+"\n";
                        }

                        if (valueBladder != 0)
                        {
                            lastBladderTs = llRound(llGetUnixTime() - ((bladder + valueBladder) * (timeRate/bladderRate) / 100));
                            bladder = checkPercent(bladder);
                            msg += TXT_BLADDER  +"\t" +(string)valueBladder+"\n";
                        }

                        if (valueHygiene != 0)
                        {
                            hygiene += valueHygiene;
                            hygiene = checkPercent(hygiene);
                            msg += TXT_HYGIENE  +"\t" +(string)valueHygiene+"\n";
                        }

                        if (valueEnergy != 0)
                        {
                            energy += valueEnergy;
                            energy = checkPercent(energy);
                            msg += TXT_ENERGY   +"\t" +(string)valueEnergy+"\n";
                        }

                        msg += "\n \n";
                        floatText(msg, WHITE,0);
                    }
                }

                refresh();

                return;
            }
            else if (item == "BACKUP-REQ")
            {
                if (MY_HUD == TRUE)
                {
                    if (llList2Key(cmd, 2) == userID)
                    {
                        critterKey = checkAttached(SF_PREFIX+" "+critterName);

                        if (critterKey != NULL_KEY)
                        {
                            messageObj(critterKey, "SEND-STATUSNC|"+PASSWORD+"|"+llList2String(cmd, 3));
                        }
                    }
                }
            }
            else if (item == "RESTORE-REQ")
            {
                if (llList2Key(cmd, 2) == llGetOwner())
                {
                    if (MY_HUD == TRUE)
                    {
                        critterKey = checkAttached(SF_PREFIX+" "+critterName);

                        if (critterKey != NULL_KEY)
                        {
                            messageObj(critterKey, "KILL-STATUSNC|"+PASSWORD+"|"+llList2String(cmd, 3));
                        }
                    }
                    else
                    {
                        updateIndicator(TXT_LOADING_VALUES, PURPLE);
                    }
                }
            }
            else if (item == "UPGRADE-REQ")
            {
                if (MY_HUD == TRUE)
                {
                    if (llList2Key(cmd, 2) == userID)
                    {
                        critterKey = checkAttached(SF_PREFIX+" "+critterName);

                        if (critterKey != NULL_KEY)
                        {
                            messageObj(critterKey, "VERSION-CHECK|"+PASSWORD+"|"+llList2String(cmd, 3));
                        }

                    }
                }
            }
        }
        else
        {
            // DIALOG CHANNEL //
            if (m == TXT_CLOSE)
            {
                status = "";
                checkListen(TRUE);
            }
            else if (m == TXT_RESET_CONFIRM)
            {
                if (getNotecardVer(values_nc) == -1)
                {
                    systemReset(FALSE);
                    floatText(TXT_GETTING_INFO +"\n ", PURPLE, 1);
                    status = "waitvaluesver_reset";
                    postMessage("task=verreq&data1="+values_nc);
                }
                else
                {
                    state systemReset;
                }
            }
            else if (m == TXT_DEBUG_VALUES)
            {
                llOwnerSay("SETTING DEBUG VALUES");
                llSetObjectDesc("-");
                floatText(TXT_DEBUG_VALUES +"\n ", PURPLE, 1);
                setBorder(PURPLE);
                drunk   = 50.0;
                thirsty = 50.0;
                hungry  = 50.0;
                health = 50.0;
                hygiene = 50.0;
                bladder = 50.0;
                energy = 50.0;
                point = 50.0;
                foodStore = 40;
                drinkStore = 40;
                boozeStore = 40;
                medicineStore = 40;
                woodStore = 40;
                energyStore = 40;
                provLocked =FALSE;
                storedTime = 300;
                borderColour = WHITE;
                vals2Desc();
                llSleep(0.2);
                loadStoredVals();
                refresh();
                isDead = FALSE;
                llResetScript();
            }
            else if (m ==">>")
            {
                startOffset += 10;
                multiPageMenu(id, TXT_WHICH_ANIMAL +":\n \n" + TXT_SCAN_RANGE +": " + scanRange + "m " + TXT_RADIUS, animals);
            }
            else if (m == TXT_PAUSE)
            {
                state paused;
            }
            else if (m == TXT_RESUME)
            {
                active = TRUE;
                llSetColor(WHITE,0);
                statusHudVisible = TRUE;
                
                if (checkIndicator(statusIndicator) == TRUE)
                {
                    messageObj(indicatorKey, "VISIBILITY|" +PASSWORD+ "|1|" +indicatorColour);
                }

                refresh();
            }
            else if (m == TXT_STATUS)
            {
                showStatus(getVersionText());
                list opts = [];

                if (AFK == TRUE) opts += "-"+TXT_AFK; else opts += "+"+TXT_AFK;
                if (OOC == TRUE) opts += "-"+TXT_OOC; else opts += "+"+TXT_OOC;

                opts += [TXT_CLOSE];

                if (statusHudVisible == TRUE)
                {
                    opts += "-"+TXT_STATUS_HUD_STATE;
                }
                else
                {
                    opts +="+"+TXT_STATUS_HUD_STATE;
                }

                opts += [TXT_STOP_ANIM];

                if (checkIndicator(statusIndicator) == TRUE)
                {
                    messageObj(indicatorKey, "VISIBILITY|" +PASSWORD+ "|"+(string)statusHudVisible +"|" +indicatorColour);
                }

                status = "statusMenu";
                startListen();
                llDialog(id, "\n"+TXT_STATUS, opts, chan(llGetKey()));
                llSetTimerEvent(300);
            }
            else if (m == TXT_HELP)
            {
                list opts = [];
                opts += [TXT_INFORMATION, TXT_WEBSITE, TXT_CLOSE, TXT_NUTRITION];
                status = "helpMenu";
                startListen();
                llDialog(id, "\n"+TXT_MENU_HELP, opts, chan(llGetKey()));
                llSetTimerEvent(300);
            }
            else if (m == TXT_INFORMATION)
            {
                llLoadURL(userID, TXT_VISIT_WEBSITE, userGuideURL);
            }
            else if (m == TXT_STOP_ANIM)
            {
                // force any animation off
                llStartAnimation("turn_180");
                llStopAnimation("turn_180");
                startAnim("");
            }
            else if (m == TXT_ACCOUNT)
            {
                status = "ExchangePoints";
                llListenRemove(listener);
                llMessageLinked(LINK_THIS, 1, "CMD_POINTS", id);
            }
            else if (m == TXT_NUTRITION)
            {
                showNutritionInfo();
                status = "";
            }
            else if (m == TXT_WEBSITE)
            {
                llLoadURL(userID, TXT_VISIT_WEBSITE, webForumURL);
            }
            else if (m == TXT_OPTIONS)
            {
                list opts = [];
                opts += [TXT_PAUSE, TXT_SAVE, TXT_LOAD, TXT_ADVANCED, TXT_LANGUAGE];

                if (healthMode == 1) opts += "-"+TXT_HEALTH_MODE; else opts += "+"+TXT_HEALTH_MODE;

                if (useEffects == TRUE) opts += "-"+TXT_EFFECTS; else opts += "+"+TXT_EFFECTS;
                opts += TXT_STATUS_HUD;

                if (MY_HUD == TRUE) opts += TXT_SCAN_RANGE;
                opts += TXT_METABOLIC;

                if (echoChat == TRUE) opts += "-" +TXT_ECHO_TEXT; else opts += "+" +TXT_ECHO_TEXT;
                string info_txt = "";

                if (MY_HUD == TRUE) info_txt += TXT_SCAN_RANGE+": " +llRound(scanRange) +"m";
                info_txt += "\t" +TXT_METABOLIC+": "+ timeRateDisp +"\n \n" + TXT_HEALTH_MODE+": ";

                if (healthMode == 1) info_txt += TXT_ON; else info_txt += TXT_OFF;
                info_txt+= "\t " + TXT_EFFECTS + ": ";

                if (useEffects == 1) info_txt += TXT_ON; else info_txt += TXT_OFF;
                info_txt += "\t";

                if (hudSpacing == 1)
                {
                    info_txt += TXT_STATUS_HUD +": " +TXT_SPACING_1;
                }
                else
                {
                    info_txt += TXT_STATUS_HUD +": " +TXT_SPACING_2;
                }

                opts += TXT_CLOSE;
                status = "optionsMenu";
                startListen();
                llDialog(id, "\n"+TXT_MENU_OPTIONS+"\n \n"+info_txt, opts, chan(llGetKey()));
                llSetTimerEvent(300);
            }
            else if (m == TXT_ADVANCED)
            {
                list opts = [];

                if (systemDebug == 1)
                {
                    opts +="-"+TXT_DEBUG;
                    opts += TXT_DEBUG_VALUES;
                }
                else
                {
                    opts +="+"+TXT_DEBUG;
                }

                opts += [TXT_RESET, TXT_CLOSE];

                if (systemDebug == TRUE) opts += TXT_TESTER;

                status = "advancedMenu";
                startListen();
                llDialog(id, "\n"+TXT_ADVANCED, opts, chan(llGetKey()));
                llSetTimerEvent(300);
            }
            else if (m == TXT_STATUS_HUD)
            {
                if (hudSpacing == 1)
                {
                    hudSpacing = 2;
                    floatText(TXT_STATUS_HUD +": " +TXT_SPACING_2+"\n \n", WHITE, 1);
                    refresh();
                }
                else
                {
                    hudSpacing = 1;
                    floatText(TXT_STATUS_HUD +": " +TXT_SPACING_1+"\n \n", WHITE, 1);
                    refresh();
                }
            }
            else if (m == TXT_RESET)
            {
                list opts = [TXT_RESET_CONFIRM, TXT_CLOSE];
                startListen();
                llDialog(id, "\n"+TXT_WARNING_RESET, opts, chan(llGetKey()));
                llSetTimerEvent(300);
            }
            else if (m == TXT_LOAD)
            {
                list opts = [];

                if (llGetInventoryType(statusNC) == INVENTORY_NOTECARD) opts += [TXT_STORED];

                if (llGetInventoryType(statusNC+"-OLD") == INVENTORY_NOTECARD) opts += [TXT_BACKUP];

                opts += [TXT_SERVER, TXT_CLOSE];
                startListen();
                llDialog(id, TXT_LOAD+"\n ", opts, chan(llGetKey()));
                llSetTimerEvent(300);
            }
            else if (m == TXT_SERVER)
            {
                llSetTimerEvent(0);
                systemReset(FALSE);

                updateIndicator(" ", WHITE);
                setBorder(WHITE);

                floatText(TXT_LOADING_VALUES +"...\n ", WHITE, 0);
                postMessage("task=gethudbak&data1="+(string)userID);
                status = "waitLoadHUDbak";
            }
            else if ((m == TXT_STORED) || (m == TXT_BACKUP))
            {
                llOwnerSay("Sorry, not available yet.");
            }
            else if (m == TXT_SAVE)
            {
                floatText(TXT_SAVING +"...\n ", WHITE, 0);
                saveState();
                llSleep(0.5);
                postMessage("task=sethudbak&data1="+(string)userID +"&data2="+vals2Desc());
            }
            else if (m == collector)
            {
                result = checkAttached(SF_PREFIX +" " +collector);

                if (result != NULL_KEY)
                {
                    messageObj(result, "CMD_COLLECTOR|" +PASSWORD+"|" +(string)userID);
                }
                else
                {
                    floatText(TXT_NOT_FOUND, YELLOW, 1);
                }
            }
            else if (m == TXT_BACKPACK)
            {
                result = checkAttached(SF_PREFIX +" " +TXT_BACKPACK);

                if (result != NULL_KEY)
                {
                    messageObj(result, "CMD_BACKPACK|" +PASSWORD+"|" +(string)userID);
                }
                else
                {
                    floatText(TXT_NOT_FOUND, YELLOW, 1);
                }
            }
            else if (m == TXT_PROVISIONS)
            {
                list opts = [];

                if (provLocked==TRUE)
                {
                    opts += TXT_UNLOCK;
                }
                else
                {
                    opts += TXT_LOCK;
                }

                opts += [TXT_LEVELS, TXT_RELOAD, TXT_CLOSE];
                opts += [TXT_STORE_ITEM, TXT_REZ_BOX, TXT_CONSUME];

                if (woodStore > 4) opts += TXT_REZ_WOOD;

                if (energyStore > 4) opts += TXT_REZ_POWER;

                status = "provMenu";
                string lockStr;

                if (provLocked == TRUE)
                {
                    lockStr = TXT_LOCKED;
                }
                else
                {
                    lockStr = TXT_UNLOCKED;
                }

                startListen();
                llDialog(id, "\n"+TXT_MENU_PROVISIONS +"\n \n" +TXT_FOOD+"\t" +TXT_DRINK+"\t"  +TXT_BOOZE+"\t" +TXT_MEDICINE+"\t"+trimPrefix(SF_WOOD)+"\t"+"\t"+TXT_POWER+"\n"    +fixedStrLen((string)foodStore, 5) +"\t" +fixedStrLen((string)drinkStore, 5) +"\t" +fixedStrLen((string)boozeStore, 5) +"\t \t" +fixedStrLen((string)medicineStore, 5) +"\t \t" +fixedStrLen((string)woodStore, 5)
                +"\t \t" +fixedStrLen((string)energyStore, 5) + "\n \n"  +TXT_MODE+ "\t\t" +lockStr, opts, chan(llGetKey()));
                llSetTimerEvent(300);
            }
            else if (m == TXT_RELOAD)
            {
                postMessage("task=getprovs&data1="+(string)userID);
                //llMessageLinked(LINK_SET, 1, "CMD_POST|"+"task=getprovs&data1="+(string)userID, "");
            }
            else if (m == TXT_STORE_ITEM)
            {
                status = "WaitSearchStore";
                llSensor("", "",SCRIPTED,  radius, PI);
            }
            else if (m == TXT_REZ_BOX)
            {
                if ((foodStore + drinkStore + boozeStore + medicineStore) >0)
                {
                    if (useEffects == TRUE)
                    {
                        llPlaySound(actionSound, fxVolume);
                    }

                    llMessageLinked(LINK_SET, provLocked, "REZ_PRODUCT|" +PASSWORD +"|" +(string)id +"|" +provBoxName +"|" +llRound(foodStore) +"|" +llRound(drinkStore) +"|" +llRound(boozeStore) +"|" +llRound(medicineStore), pubKey);
                }
                else floatText(TXT_NO_PROVISIONS +"\n ", RED, 1);
            }
            else if (m == TXT_REZ_WOOD)
            {
                if (useEffects == TRUE)
                {
                    llPlaySound(actionSound, fxVolume);
                }

                llMessageLinked(LINK_SET, 0, "REZ_PRODUCT|" +PASSWORD +"|" +(string)id +"|" +SF_WOOD, NULL_KEY);
            }
            else if (m == TXT_REZ_POWER)
            {
                if (useEffects == TRUE)
                {
                    llPlaySound(actionSound, fxVolume);
                }

                llMessageLinked(LINK_SET, 0, "REZ_PRODUCT|" +PASSWORD +"|" +(string)id +"|" +SF_POWER, NULL_KEY);
            }
            else if (m == TXT_LEVELS)
            {
                showStoreLevels();
            }
            else if (m == TXT_CONSUME)
            {
                if (status == "provMenu")
                {
                    provisionsMenu();
                }
                else
                {
                    status = "WaitSearchConsume";
                    llSensor("", "",SCRIPTED,  radius, PI);
                }
            }
            else if (m == TXT_METABOLIC)
            {
                status = "waitConsumeInterval";
                string message = "\n" +TXT_METABOLIC +" (" +TXT_CURRENT_VALUE +": " +timeRateDisp +")";
                llDialog(id, message, [TXT_LOW, TXT_MEDIUM, TXT_HIGH, TXT_CLOSE], chan(llGetKey()));
            }
            else if (m == TXT_INSPECT)
            {
                status = "WaitSearchInspect";
                llSensor("", "",SCRIPTED,  radius, PI);
            }
            else if (m == TXT_SCAN)
            {
                status = "animalListen";
                startListen();
                startOffset = 0;
                multiPageMenu(id, TXT_WHICH_ANIMAL + ":\n \n" + TXT_SCAN_RANGE + ": " + scanRange + "m " + TXT_RADIUS, animals);
                llSetTimerEvent(1000);
            }
            else if (m == TXT_SCAN_RANGE)
            {
                status = "waitRange";
                llTextBox(id, TXT_SCAN_RANGE +" (1m to 96m)\n(" + TXT_CURRENT_VALUE +": " +scanRange + " m " +TXT_RADIUS +")", chan(llGetKey()));
            }
            else if (m == TXT_LANGUAGE)
            {
                checkListen(1);
                status = "";
                llMessageLinked(LINK_THIS, 1, "MENU_LANGS|" + languageCode +"|" +SUFFIX, id);
            }
            else if (m == "+"+TXT_ECHO_TEXT)
            {
                echoChat = TRUE;
                floatText(TXT_ECHO_TEXT +": " +TXT_ON, WHITE, 1);
            }
            else if (m == "-"+TXT_ECHO_TEXT)
            {
                echoChat = FALSE;
                floatText(TXT_ECHO_TEXT +": " +TXT_OFF, WHITE, 1);
            }
            else if (m == "-"+TXT_STATUS_HUD_STATE)
            {
                statusHudVisible = FALSE;
                floatText(TXT_STATUS_HUD_STATE +": " +TXT_OFF +"\n ", WHITE, 1);

                if (checkIndicator(statusIndicator) == TRUE)
                {
                    messageObj(indicatorKey, "VISIBILITY|" +PASSWORD+ "|0" +"|" +indicatorColour);
                }

                refresh();
            }
            else if (m == "+"+TXT_STATUS_HUD_STATE)
            {
                statusHudVisible = TRUE;
                floatText(TXT_STATUS_HUD_STATE +": " +TXT_ON +"\n ", WHITE, 1);

                if (checkIndicator(statusIndicator) == TRUE)
                {
                    messageObj(indicatorKey, "VISIBILITY|" +PASSWORD+ "|1"+"|" +indicatorColour);
                }

                refresh();
            }
            else if (m == "+"+TXT_EFFECTS)
            {
                useEffects = TRUE;
                integer i = llRound(fxVolume*10);
                llMessageLinked(LINK_SET, 1, "CMD_CHATTY|"+(string)i, "");
                refresh();
                floatText(TXT_EFFECTS +": " + TXT_ON +"\n ", WHITE, 1);
            }
            else if (m == "-"+TXT_EFFECTS)
            {
                useEffects = FALSE;
                integer i = llRound(fxVolume*10);
                llMessageLinked(LINK_SET, 1, "CMD_CHATTY|"+(string)i, "");

                if (checkIndicator(statusIndicator) == TRUE)
                {
                    messageObj(indicatorKey, "OFF|" +PASSWORD);
                }

                floatText(TXT_EFFECTS +": " + TXT_OFF +"\n ", WHITE, 1);
                refresh();
                showStatus(getVersionText());
            }
            else if (m == TXT_LOCK)
            {
                provLocked = TRUE;
                llPlaySound(lockSound, fxVolume);
                borderColour = YELLOW;
                setBorder(borderColour);
                vals2Desc();
            }
            else if (m == TXT_UNLOCK)
            {
                provLocked = FALSE;
                llPlaySound(unlockSound, fxVolume);
                borderColour = WHITE;
                setBorder(borderColour);
                vals2Desc();
            }
            else if (m == "-"+TXT_HEALTH_MODE)
            {
                setHealthMode(0);
            }
            else if (m == "+"+TXT_HEALTH_MODE)
            {
                setHealthMode(1);
            }
            else if (m == "-"+TXT_AFK)
            {
                AFK = FALSE;
                setBorder(borderColour);
                llStopAnimation("away");
                refresh();
                showStatus(getVersionText());
            }
            else if (m == "+"+TXT_AFK)
            {
                AFK = TRUE;
                setBorder(PURPLE);
                llStartAnimation("away");
                refresh();
                showStatus(getVersionText());
            }
            else if (m == "-"+TXT_OOC)
            {
                OOC = FALSE;
                setBorder(borderColour);
                refresh();
                showStatus(getVersionText());
            }
            else if (m == "+"+TXT_OOC)
            {
                OOC = TRUE;
                setBorder(PURPLE);
                refresh();
                showStatus(getVersionText());
            }
            else if (m == "-"+TXT_DEBUG)
            {
                systemDebug = FALSE;
                floatText(TXT_DEBUG +" " +TXT_OFF +"\n \n", PURPLE, 1);
                setBorder(borderColour);
                llMessageLinked(LINK_SET, 0, "CMD_DEBUG|0", "");

                if (checkIndicator(statusIndicator) == TRUE)
                {
                    messageObj(indicatorKey, "DEBUG|" +PASSWORD +"|0");
                }

                refresh();
            }
            else if (m == "+"+TXT_DEBUG)
            {
                systemDebug = TRUE;
                floatText(TXT_DEBUG +" " +TXT_ON +"\n \n", PURPLE, 1);
                setBorder(YELLOW);
                llMessageLinked(LINK_SET, 0, "CMD_DEBUG|1", "");

                if (checkIndicator(statusIndicator) == TRUE)
                {
                    messageObj(indicatorKey, "DEBUG|" +PASSWORD +"|1");
                }

                refresh();
            }
            else if (m == TXT_TESTER)
            {
                status = "TesterPoints";
                llListenRemove(listener);
                llMessageLinked(LINK_THIS, 1, "CMD_TEST", "");
            }
            else if (m == TXT_TOUCH)
            {
                llMessageLinked(LINK_SET, 1, "ANIMALTOUCH", id);
            }
            else if (m == TXT_INTERACTION)
            {
                llMessageLinked(LINK_SET, 1, "dotouch", id);
            }
            else if (m == critterName)
            {
                messageObj(critterKey, "HUD_TOUCH|"+PASSWORD+"|"+(string)id);
            }
            // status based actions
            else if (status =="waitRange")
            {
                status = "";
                integer tmpVal = (integer)m;

                if (tmpVal >96)
                {
                    scanRange = 96;
                }
                else if (tmpVal <1)
                {
                    scanRange = 1;
                }
                else
                {
                    scanRange = tmpVal;
                }

                floatText(TXT_RANGE +": " +scanRange + "m " + TXT_RADIUS, PURPLE, 1);
            }
            else if (status =="waitConsumeInterval")
            {
                status = "";
                setTimeRate(m);
                refresh();
                floatText(TXT_METABOLIC +": " +timeRateDisp +"\n ", PURPLE, 1);
            }
            else if (status == "WaitSelectionConsume")
            {
                if (m == provBoxName)
                {
                    provisionsMenu();
                }
                else
                {
                    list toks =[];

                    // assume 100% used unless we find a value in notecards
                    lookingForPercent = 100;

                    // first check for user custom value
                    toks = valuesFromNotecard(m, user_nc);

                    if (llGetListLength(toks) != 0)
                    {
                        lookingForPercent = llList2Integer(toks,1);
                    }
                    else
                    {
                        // check in master notecard
                        toks = valuesFromNotecard(m, values_nc);

                        if (llGetListLength(toks)) lookingForPercent = llList2Integer(toks,1);
                    }

                    lookingFor = SF_PREFIX +" "+m;
                    status = "WaitItemConsume";
                    llSensor(lookingFor, "",SCRIPTED,  radius, PI);
                }
            }
            else if (status == "WaitSelectionStore")
            {
                // Query the product
                integer index = llListFindList(lastFoundKeys, [m]);

                if (index == -1)
                {
                    floatText(TXT_NOT_CONSUMABLE +": " +m +"\n \n", YELLOW, 1);
                    status = "";
                }
                else
                {
                    list  descValues = llParseString2List(llList2String(llGetObjectDetails(llList2Key(lastFoundKeys, index+1), [OBJECT_DESC]), 0), [";"], [""]);
                    lookingForPercent = llList2Integer(descValues, 1);
                }

                lookingFor = SF_PREFIX +" "+m;
                status = "WaitItemStore";
                llSensor(lookingFor, "",SCRIPTED,  radius, PI);
            }
            else if (status == "WaitSelectionInspect")
            {
                list toks;
                toks = valuesFromNotecard(m, user_nc);

                if (llGetListLength(toks) != 0)
                {
                    lookingForPercent = llList2Integer(toks,1);
                    handleValues(toks, TRUE,  FALSE);
                }
                else if (llGetListLength(valuesFromNotecard(m, values_nc)) != 0)
                {
                    toks = valuesFromNotecard(m, values_nc);

                    if (llGetListLength(toks) != 0)
                    {
                        lookingForPercent = llList2Integer(toks,1);
                        handleValues(toks, TRUE,  FALSE);
                    }
                }
                else
                {
                    lookingFor = m;

                    // Query the product
                    integer index = llListFindList(lastFoundKeys, [m]);

                    if (index == -1)
                    {
                        floatText(TXT_NOT_CONSUMABLE +": " +m +"\n \n", YELLOW, 1);
                        status = "";
                    }
                    else
                    {
                        llList2Key(lastFoundKeys, index+1);
                        messageObj(llList2Key(lastFoundKeys, index+1), "QUERYVALUES|" +PASSWORD +"|" +(string)llGetKey());
                    }
                }
            }
            else if (status == "waitProvTypeRez")
            {
                lookingFor = provBoxName;
                status = "WaitProvUse_" + m;
                llSensor(lookingFor, "",SCRIPTED,  radius, PI);
            }
            else if (status == "waitProvType")
            {
                // m = food, drink, booze, medicine
                if (m == TXT_FOOD)
                {
                    if (foodStore - 20 >= 0)
                    {
                        foodStore -= 20;
                        lastEatTs = llRound(llGetUnixTime() - ((hungry - 20) * (timeRate/hungerRate) / 100));
                        hungry = checkPercent(hungry);

                        if (useEffects == TRUE)
                        {
                            llPlaySound(actionSound, fxVolume);
                        }

                        showStoreLevels();
                    }
                    else
                    {
                        floatText(TXT_PROVISIONS +": " +TXT_NOT_ENOUGH+" "+TXT_FOOD +"\n \n", RED, 1);
                    }
                }
                else if (m == TXT_DRINK)
                {
                    if (drinkStore - 20 >= 0)
                    {
                        drinkStore -= 20;
                        lastDrinkTs = llRound(llGetUnixTime() - ((thirsty - 20) * (timeRate/thirstRate) / 100));
                        thirsty = checkPercent(thirsty);

                        if (useEffects == TRUE)
                        {
                            llPlaySound(actionSound, fxVolume);
                        }

                        showStoreLevels();
                    }
                    else
                    {
                        floatText(TXT_PROVISIONS +": " +TXT_NOT_ENOUGH+" "+TXT_DRINK +"\n \n", RED, 1);
                    }
                }
                else if (m == TXT_BOOZE)
                {
                    if (boozeStore -20 >= 0)
                    {
                        boozeStore -= 20;
                        drunk += 20;
                        drunk = checkPercent(drunk);

                        if (useEffects == TRUE)
                        {
                            llPlaySound(actionSound, fxVolume);
                        }

                        showStoreLevels();
                    }
                    else
                    {
                        floatText(TXT_PROVISIONS +": " +TXT_NOT_ENOUGH+" "+TXT_BOOZE +"\n \n", RED, 1);
                    }
                }
                else if (m == TXT_MEDICINE)
                {
                    if (medicineStore -20 >= 0)
                    {
                        medicineStore -= 20;
                        health += 20;
                        health = checkPercent(health);

                        if (useEffects == TRUE)
                        {
                            llPlaySound(actionSound, fxVolume);
                        }

                        showStoreLevels();
                    }
                    else
                    {
                        floatText(TXT_PROVISIONS +": " +TXT_NOT_ENOUGH+" "+TXT_MEDICINE +"\n \n", RED, 1);
                    }
                }
                vals2Desc();
                refresh();
                status = "provMenu";
                provisionsMenu();
            }
            else if (status == "animalListen")
            {
                floatText("\n --- " + TXT_SCANNING +" " +scanRange + "m " + TXT_RADIUS + "---\n \n", ORANGE, 1);
                llMessageLinked(LINK_THIS, 1, "CMD_SCAN|" + SF_PREFIX +" " + m + "|" + (string)scanRange, userID);
                lookingFor = m;
            }
        }
    }

    sensor(integer n)
    {
        if ((status == "WaitSearchConsume") || (status == "WaitSearchStore") || (status == "WaitSearchInspect"))
        {
            lastFoundKeys = [];
            string objName;
            itemFound=1;
            integer i;
            list descValues = [];
            list foundList = [];

            for (i=0; i < 10; i++)
            {
                if (llGetSubString(llDetectedName(i),0, 1) == SF_PREFIX)
                {
                    descValues = llParseString2List(llList2String(llGetObjectDetails(llDetectedKey(i), [OBJECT_DESC]), 0), [";"], [""]);

                    if (llList2String(descValues, 0) == "P")
                    {
                        // Take out the prefix e.g. SF Apples becomes Apples
                        objName =llGetSubString(llDetectedName(i), 3,-1);

                        if (llListFindList(foundList, [objName]) == -1)
                        {
                            foundList += objName;
                            lastFoundKeys += [objName, llDetectedKey(i)];
                        }
                    }
                }
            }

            if (llGetListLength(foundList) == 0)
            {
                floatText(TXT_NOT_FOUND +"\n \n", RED, 1);
                status = "";
            }
            else if (status == "WaitSearchConsume")
            {
                llDialog(userID,  "\n" +TXT_SELECT_CONSUME, [TXT_CLOSE] + foundList, chan(llGetKey()));
                status = "WaitSelectionConsume";
            }
            else if (status == "WaitSearchStore")
            {
                llDialog(userID,  "\n"+TXT_SELECT_STORE, [TXT_CLOSE] + foundList, chan(llGetKey()));
                status = "WaitSelectionStore";
            }
            else
            {
                llDialog(userID,  "\n"+TXT_SELECT_INSPECT, [TXT_CLOSE] + foundList, chan(llGetKey()));
                status = "WaitSelectionInspect";
            }
        }
        else if (status == "WaitItemConsume")
        {
            floatText(TXT_CONSUMING+" " +(string)lookingForPercent +"% - "+llDetectedName(0) +"...\n ", WHITE, 1);
            messageObj(llDetectedKey(0), "DIE|"+llGetKey()+"|"+(string)lookingForPercent);
        }
        else if (status == "WaitItemStore")
        {
            string itemName = llDetectedName(0);

            if (itemName == (provBoxName))
            {
                floatText(TXT_FETCHING +" " +trimPrefix(itemName) +"..." +"\n \n ", WHITE, 1);
                status = "waitAccess";
                messageObj(llDetectedKey(0), "ACCESS|" + PASSWORD +"|" +llGetKey());
            }
            else
            {
                floatText(TXT_STORE_ITEM+": " +itemName +" (" +(string)lookingForPercent +"%)...\n \n", WHITE, 1);
                messageObj(llDetectedKey(0), "DIE|" +llGetKey() +"|" +(string)lookingForPercent);
            }
        }
        else if (llGetSubString(status, 0, 11) == "WaitProvUse_")
        {
            consumeType =  llGetSubString(status, 12, llStringLength(status));
            if (consumeType == TXT_FOOD) consumeType = "Food";
            else if (consumeType == TXT_DRINK) consumeType = "Drink";
            else if (consumeType == TXT_BOOZE) consumeType = "Booze";
            else if (consumeType == TXT_MEDICINE) consumeType = "Medicine";
            messageObj(llDetectedKey(0), "USE|" +PASSWORD +"|" + consumeType +"|" +llGetKey());
            status = "waitProvConfirm";
        }
    }

    no_sensor()
    {
        if (status == "WaitSearchConsume" || status == "WaitSearchStore")
        {
            floatText(TXT_NOT_FOUND +"\n ", RED, 1);
        }
        else
        {
            floatText(TXT_ERROR+" - "+lookingFor+" "+TXT_NOT_FOUND +"\n ", RED, 1);
        }
    }

    timer()
    {
        if (llGetAttached() == 0)
        {
            // We are not attached so switch to paused state
            state paused;
        }
        else
        {
            if (curAnim != "") startAnim("");

            if (status == "waitLoadHUDbak")
            {
                status = "";
                vals2Desc();
            }

            refresh();
            checkListen(FALSE);
            checkIndicator(statusIndicator);

            if (AFK == FALSE)
            {
                if (lastText != "") lastText = "";
            }

            if ( (llGetUnixTime()-pollTs) > 300)
            {
                pollTs = llGetUnixTime();
                llMessageLinked(LINK_SET, 1, "CMD_DOPOLL", userID);
            }

            llSetTimerEvent(30);
        }
    }

    touch_start(integer n)
    {
        doTouch(llDetectedKey(0));
    }

    dataserver(key query_id, string m)
    {
        if (owner_age_query == query_id )
        {
            status = "";
            string Data = m;

            // date as a string in ISO 8601 format of  YYYY-MM-DD
            // The following variables are set to account for leap years and assume
            // the days evenly distributed amongst the 12 months of a year.
            float YrDays = 365.25;
            float MnDays = YrDays / 12;
            float DyInc = 1 / MnDays;

            // This is the user's birthdate.
            integer uYr = (integer)llGetSubString(Data,0,3);
            integer uMn = (integer)llGetSubString(Data,5,6);
            integer uDy = (integer)llGetSubString(Data,8,9);
            float uXVal = uYr * YrDays + (uMn - 1) * MnDays + uDy * DyInc;

            // This is today's date
            Data = llGetDate();
            integer Yr = (integer)llGetSubString(Data,0,3);
            integer Mn = (integer)llGetSubString(Data,5,6);
            integer Dy = (integer)llGetSubString(Data,8,9);
            float XVal = Yr * YrDays + (Mn - 1) * MnDays + Dy * DyInc;

            // We calculate the difference between those two dates to get the number of days.
            integer DDiff = (integer)(XVal - uXVal);

            // Adjust age based on max age (10) being 10 real years old or more.
            baseAge = (integer)(DDiff/365);

            if (baseAge >10)
            {
                baseAge = 10;
            }
        }
        else
        {
            list tk = llParseStringKeepNulls(m, ["|", ":"], []);
            string itemName = llList2String(tk,0);
            debug("dataserver: " + m + "   status: " + status +"  CMD=" +itemName);

            if (itemName == "LANG_REPLY")
            {
                string ncName = llList2String(tk, 3)+"-lang-P";

                if (llGetInventoryType(ncName) != -1)
                {
                    llGiveInventory(llList2Key(tk, 2), ncName);
                }
                
                llSleep(1.0);
                messageObj(llList2String(tk,2), "SETLANG|" +PASSWORD+"|"+llList2String(tk,3));
            }
            else if (itemName == "KEYCODE")
            {
                if ((llList2String(tk, 3) == "#") || (unLock(llList2String(tk, 3)) == TRUE))
                {
                    messageObj(llList2Key(tk, 2),"RETRIEVE|" + PASSWORD +"|" +llGetKey());
                    status = "waitAccess";
                }
                else
                {
                    floatText(TXT_NO_KEY +"\n \n", RED, 1);
                    status = "";
                    refresh();
                }
            }
            else if (itemName == "MYVALS")
            {
                // e.g. we got:  MYVALS|farm|Thirsty|-50|Bladder|15  so remove first 2 items
                list vals = llList2List(tk, 2, -1);

                // e.g. vals is now:  Thirsty|-50|Bladder|15
                if  (llGetListLength(vals) >1)
                {
                    // For values read from products notecard we always use 100%
                    lookingForPercent = 100;
                    vals = lookingForPercent + vals;

                    // Now add name of produce e.g. becomes:  Water|Thirsty|-50|Bladder|15
                    vals = lookingFor + vals;
                    handleValues(vals, TRUE, FALSE);
                }
                else
                {
                    floatText(TXT_NOT_CONSUMABLE +": " +lookingFor +"\n \n", YELLOW, 0);
                }

                status = "";
            }
            else if (itemName == "HUD_TOUCH")
            {
                doTouch(llList2Key(tk,2));
            }

            // status based items
            else if (status == "ExchangePoints")
            {
                status =  "";
                // Item will issue a "consumed" message if food so we ignore and assumed exchanged for points instead
            }
            else if ((status == "WaitItemConsume") || (status == "WaitItemStore"))
            {
                integer ret = 0;
                list vals = [];

                if (status == "WaitItemConsume")
                {
                    vals = valuesFromNotecard(itemName, user_nc);

                    if (llGetListLength(vals)>0) // Try user notecard first
                    {
                        ret = handleValues(vals, TRUE, TRUE);
                    }
                    // try default notecard values next
                    else if (llGetListLength(valuesFromNotecard(itemName, values_nc)) != 0)
                    {
                        vals = valuesFromNotecard(itemName, values_nc);

                        if (llGetListLength(vals)>0)
                        {
                            ret = handleValues(vals, TRUE, TRUE);
                        }
                    }
                    else
                    {
                        // Parse the dataserver event instead
                        ret = handleValues(tk, TRUE, TRUE);
                    }

                    if (ret>0)
                    {
                        refresh();
                    }
                    else
                    {
                        floatText(TXT_NOT_CONSUMABLE+" "+llToLower(itemName) +"\n \n", YELLOW, 1);
                    }
                }
                else if (status == "WaitItemStore")
                {
                    // is it Wood?
                    if (itemName == llToUpper(trimPrefix(SF_WOOD)))
                    {
                        woodStore += 5;
                        floatText(TXT_STORED +" "+llToLower(itemName) +"\n ", PURPLE, 1);
                        showStoreLevels();
                    }
                    // or kWh?
                    else if (itemName == llToUpper(trimPrefix(SF_POWER)))
                    {
                        energyStore += 5;
                        floatText(TXT_STORED +" "+llToLower(itemName) +"\n ", PURPLE, 1);
                        showStoreLevels();
                    }
                    else
                    {
                        // First check user values notecard
                        vals = valuesFromNotecard(itemName, user_nc);

                        if (llGetListLength(vals)>0)
                        {
                            // Found a user defined value so use that
                            ret = handleValues(vals, FALSE, TRUE);
                        }

                        // Now try the default notecard values
                        else if (llGetListLength(valuesFromNotecard(itemName, values_nc)) != 0)
                        {
                            vals = valuesFromNotecard(itemName, values_nc);

                            if (llGetListLength(vals)>0)
                            {
                                ret = handleValues(vals, FALSE, TRUE);
                            }
                        }
                        else
                        {
                            // Parse the dataserver event instead
                            ret = handleValues(tk, FALSE, TRUE);
                        }

                        if (ret>0)
                        {
                            floatText(TXT_STORED +" "+llToLower(itemName) +"\n ", PURPLE, 1);
                            showStoreLevels();
                            // ????  list tk = llParseStringKeepNulls(m, ["|", ":"], []);
                            // ????  refresh();
                        }
                        else
                        {
                            floatText(TXT_NOT_STORABLE+" "+llToLower(itemName) +"\n ", YELLOW, 1);
                        }
                    }
                }
                status = "";
            }
            else if (status == "waitProvConfirm")
            {
                if (itemName == "NOPROV")
                {
                    floatText(TXT_NOT_ENOUGH +" "+consumeType +" "+TXT_STORED +"\n ", RED, 1);
                    status = "";
                }

                if ((itemName == "CONFIRMPROV") && (llList2String(tk, 2) == consumeType))
                {
                    if (consumeType == TXT_FOOD)
                    {
                        hungry -= 20;
                        showStatus(TXT_HUNGRY +": -20 ");
                    }
                    else if (consumeType == TXT_DRINK)
                    {
                        thirsty -= 20;
                        showStatus(TXT_THIRSTY +": -20 ");
                    }
                    else if (consumeType == TXT_BOOZE)
                    {
                        drunk += 20;
                        showStatus(TXT_DRUNK +": -20 ");
                    }
                    else if (consumeType == TXT_MEDICINE)
                    {
                        health += 20;
                        showStatus(TXT_HEALTH +": -20 ");
                    }

                    if (useEffects == TRUE) llPlaySound(actionSound, fxVolume);

                    refresh();
                    status = "";
                }

                provisionsMenu();
            }
            else if (itemName == "fullProvisionsBox")
            {
                if (llList2String(tk, 1) == PASSWORD)
                {
                    foodStore += llList2Integer(tk, 2);
                    drinkStore += llList2Integer(tk, 3);
                    boozeStore += llList2Integer(tk, 4);
                    medicineStore += llList2Integer(tk, 5);

                    if (useEffects == TRUE)
                    {
                        llPlaySound(actionSound, fxVolume);
                    }

                    showStoreLevels();
                    status = "";
                }
                else
                {
                    llRegionSayTo(userID, 0, TXT_BAD_PASSWORD +" : fullProvisionsBox");
                    status = "";
                }
            }
        }
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        list tk = llParseStringKeepNulls(msg , ["|"], []);
        string cmd = llList2String(tk, 0);

        if (debugLevel == "MAX")
        {
            debug("link_message: {" + msg + "}\ncmd: {" + cmd + "}");
        }

        if (cmd == "TEXT")
        {
            floatText(llList2String(tk, 1), llList2Vector(tk, 2), 1);
        }
        else if (cmd == "SCAN_REPLY")
        {
            string floatyText = "";

            if (num == 0)
            {
                floatyText = TXT_NOT_FOUND;
            }
            else
            {
                floatyText += TXT_TOTAL+" " + lookingFor + " " + llList2String(tk, 1) + "\n \n";
                floatyText += TXT_FEMALES+" "                  + llList2String(tk, 2) + "\n";
                floatyText += TXT_MALES+" "                    + llList2String(tk, 3) + "\n \n";
                floatyText += TXT_AVG_HAPPY+" "                + llList2String(tk, 4) + "% "+TXT_HAPPY+   "\n";
                floatyText += TXT_AVG_HUNGER+" "               + llList2String(tk, 5) + "% "+TXT_HUNGRY+  "\n";
                floatyText += TXT_AVG_THIRST+" "               + llList2String(tk, 6) + "% "+TXT_THIRSTY+ "\n \n";
            }

            floatText(floatyText, WHITE, 0);
            status = "";
        }
        else if (cmd == "POINTS-DONE")
        {
            if (status == "ExchangePoints") status = "";
        }
        else if (cmd == "CMD_XP")
        {
            userXP = llList2Integer(tk,1);
            refresh();
        }
        else if (cmd == "GOT_XP")
        {
            llRegionSayTo(userID, 0, TXT_CREDITED+" " + (string)num + " " + TXT_XP);
            startAnim(wealthAnim);
            llSleep(2);
            startAnim("");
        }
        else if (cmd == "VERSION-REQUEST")
        {
            // llMessageLinked(LINK_SET, (integer)(10*VERSION), "VERSION-REPLY|"+NAME, "");
            // Used to multiply by 10 as version was e.g. 5.5 but now by 100 so we can support version = 5.51
            llMessageLinked(LINK_SET, (integer)(100*VERSION), "VERSION-REPLY|"+NAME, "");
        }
        else if (cmd == "SET-LANG")
        {
            languageCode = llList2String(tk, 1);
            loadLanguage(languageCode);
            refresh();
            txt_off();
        }
        else if (cmd == "HTTP_RESPONSE")
        {
            if (id == req_id2)
            {

                string jsonTxt = llList2String(tk, 1);
                tk = [];
                tk = llJson2List(jsonTxt);
                cmd = llList2String(tk, 0);

                if (cmd == "PROVLIST")
                {
                    if (llList2String(tk, 1) == "OK")
                    {
                        foodStore = llList2Integer(tk, 3);
                        drinkStore = llList2Integer(tk, 5);
                        boozeStore = llList2Integer(tk, 7);
                        medicineStore = llList2Integer(tk, 9);
                        woodStore = llList2Integer(tk, 11);
                        energyStore     = llList2Integer(tk, 13);
                        pubKey = llList2String(tk,15);
                        privKey = llList2String(tk,17);
                        showStoreLevels();
                    }
                    else
                    {
                        floatText(TXT_DATA_ERROR, YELLOW, 1);
                    }
                }
                else if (cmd == "HUDVALUES")
                {
                    string dataString = llList2String(tk,1);
                    debug("GOT_RAW\n" + llList2String(tk, 1) +"\n dataString: " + dataString);

                    if (dataString != "FAIL")
                    {
                        if (llGetSubString(dataString, 0, 0) == "0")
                        {
                            // No data has been stored yet so send it
                            saveState();
                        }
                        else
                        {
                            list descValues = llParseString2List(dataString, [";"], [""]);
                            setHealthMode(healthMode);

                            llResetTime();
                            storedTime = (integer)((timeRate * 3 * point) / 100);

                            setVals(descValues);
                            vals2Desc();

                            showStatus(getVersionText());

                            if (status == "waitLoadHUDbak")
                            {
                                updateIndicator("", WHITE);
                                // status = "";
                                // llResetScript();
                            }

                            status = "askProvs";
                            postMessage("task=getprovs&data1="+(string)userID);
                        }
                    }
                    else
                    {
                        floatText(TXT_DATA_ERROR, RED, 1);
                        llSleep(2.0);
                    }
                }
                else if (cmd == "HUDSET")
                {
                    if (llList2String(tk,1) != "INVALID-A")
                    {
                        floatText(TXT_DATA_ERROR, RED, 1);
                        llSleep(2.0);
                    }
                    else
                    {
                        showStatus(getVersionText());
                        showStoreLevels();
                    }
                }
                else if (cmd == "VERSION")
                {
                    integer serverVer = llList2Integer(tk, 1);

                    if ((status == "waitvaluesver") || (status == "waitvaluesver_reset"))
                    {
                        integer ourVer = getNotecardVer(values_nc);

                        if (ourVer == -1)
                        {
                            // Remove previous backup notecard if there is one
                            if (llGetInventoryType(values_nc+"-old") == INVENTORY_NOTECARD) llRemoveInventory(values_nc+"-old");
                        }

                        if (serverVer > ourVer)
                        {
                            valuesHash = llList2String(tk, 3);
                            llMessageLinked(LINK_SET, 1, "CMD_DUMP_REQ|" +values_nc +"|" +valuesHash, "");
                        }
                        else
                        {
                            lastNetCheck = "values";
                            status = "";
                        }
                    }
                    else if (status == "waitanimalsver")
                    {
                        integer ourVer = getNotecardVer(animals_nc);

                        if (serverVer > ourVer)
                        {
                            animalsHash = llList2String(tk, 3);
                            llMessageLinked(LINK_SET, 1, "CMD_DUMP_REQ|"+animals_nc +"|" +animalsHash, "");
                        }
                        else
                        {
                            lastNetCheck = "animals";
                            status = "";
                        }
                    }
                }
            }
        }
        else if (cmd == "DUMP_RESPONSE")
        {
            if (llList2String(tk, 1) == values_nc)
            {
                if (status == "waitvaluesver_reset")
                {
                    llSetTimerEvent(60);
                    systemReset(TRUE);
                }
                else
                {
                    lastNetCheck = "values";
                }
            }
            else
            {
                lastNetCheck = "animals";
            }

            status = "";
        }
        else if (cmd == "OSCHECK")
        {
            if (num == 1)
            {
                startUp();
            }
            else
            {
                state paused;
            }
        }
        else if (cmd == "EXPRESSION")
        {
            string expression = llList2String(tk, 1);
            if (expression == "SLEEP") sleeping = TRUE; else if (expression == "WAKE") sleeping = FALSE;
        }
        else if (cmd == "BAG_HERE")
        {
            if (critterKey != NULL_KEY) llMessageLinked(LINK_SET, 1, "CRITTER_STATUS", "");
        }
        else if ((cmd == "reset") && (num == 666))
        {
            llResetScript();
        }
    }

    object_rez(key id)
    {
        if (llKey2Name(id) == (SF_PREFIX +" " + provBoxName))
        {
            foodStore = 0;
            drinkStore = 0;
            boozeStore = 0;
            medicineStore = 0;
            showStoreLevels();
        }
        else if (llKey2Name(id) == (SF_WOOD))
        {
            woodStore -= 5;
            showStoreLevels();
        }
        else if (llKey2Name(id) == (SF_POWER))
        {
            energyStore -= 5;
            showStoreLevels();
        }
    }

    state_entry()
    {
        // Dont run this script in rezzer
        if ((llGetInventoryType("rezzer") == INVENTORY_SCRIPT) || (llGetInventoryType("B-rezzer") == INVENTORY_SCRIPT))
        {
            llSetScriptState(llGetScriptName(), FALSE);
        }
        else
        {
            txt_off();
            llSetColor(RED, 4);
            thisRegion = llGetRegionName();

            if (llGetAttached() == 0)
            {
                // We are not attached so prepare to self destruct
                state destruct;
            }
            else
            {
                // First character in object description should be 'H'
                if (llGetSubString(llGetObjectDesc(), 0, 0) != "H")
                {
                    systemReset(TRUE);
                }
                else
                {
                    llMessageLinked(LINK_THIS, 1, "DO_OS_CHK", "");
                }
            }
        }
    }

    on_rez(integer n)
    {
        thisRegion = llGetRegionName();
        string objDesc = llGetObjectDesc();

        // First character in object description should be 'H'
        if (llGetSubString(llGetObjectDesc(), 0, 0) != "H")
        {
                systemReset(TRUE);
        }
        else
        {
            loadStoredVals();
            safetyCheck = TRUE;
            llResetScript();
        }
    }

    run_time_permissions(integer parm)
    {
        if(parm & PERMISSION_TRIGGER_ANIMATION) //triggers animation
        {
            //startAnim(wealthAnim);
            startAnim("clap");
        }
        else if(parm & PERMISSION_ATTACH) //triggers animation
        {
            llOwnerSay("ATTACH OK");
        }
    }

    changed(integer change)
    {
        if ((change & CHANGED_REGION) || (llGetRegionName() != thisRegion))
        {
            llRegionSayTo(userID, 0, thisRegion +"-->" +llGetRegionName());
            thisRegion = llGetRegionName();
            llResetScript();
        }
        else if (change & CHANGED_OWNER)
        {
            privKey ="-";
            systemReset(TRUE);
        }
        else if (change & CHANGED_INVENTORY)
        {
            loadConfig();
            loadStoredVals();
            loadLanguage(languageCode);
            refresh();
        }
    }

    attach(key id)
    {
        if (id)  // is a valid key and not NULL_KEY
        {
            // we are attached
            userID = id;
        }
        else
        {
            llMessageLinked(LINK_SET, 1, "CMD_POST|"+"task=getprovs&data1="+(string)userID, "");
            updateIndicator(" ", WHITE);
        }
    }

}


// STATE SYSTEMRESET \\

state systemReset
{

    state_entry()
    {
        systemReset(TRUE);
    }

}


// STATE PAUSED \\

state paused
{

    state_entry()
    {
        setPaused();
    }

    on_rez(integer start_param)
    {
        setPaused();
    }

    touch_start(integer num_detected)
    {
        llListenRemove(listener);
        listener = -1;
        setBorder(borderColour);
        active = TRUE;
        llMessageLinked(LINK_SET, 0, "PAUSED", "");
        statusHudVisible = TRUE;

        if (checkIndicator(statusIndicator) == TRUE)
        {
            messageObj(indicatorKey, "VISIBILITY|" +PASSWORD+ "|" +(string)statusHudVisible +"|" +indicatorColour);
            messageObj(indicatorKey, "PAUSED|" +PASSWORD +"|0");
        }

        vals2Desc();
        llSetTimerEvent(2.0);
        llResetScript();
    }

}

// STATE DESTRUCT \\
state destruct
{

    state_entry()
    {
        // We will self destruct in 5 minutes if left not attached
        llSetTimerEvent(300);
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK) 
        {
            // The number of links have changed so we my have re-attached
            llSetTimerEvent(0);
            llResetScript();
        }
    }

    timer()
    {
        llDie();
    }

}

// STATE DEAD \\

state Dead
{

    state_entry()
    {
        setPaused();
        floatText("\n \n "+TXT_DEAD+"\t"+TXT_RIP+"\t"+TXT_DEAD+"\n \n", RED, 1);
        messageObj(indicatorKey, "CLEAN|" +PASSWORD);
        messageObj(indicatorKey, "RELIEVED|" +PASSWORD);
        messageObj(indicatorKey, "AM_DEAD|" +PASSWORD);
        llMessageLinked(LINK_SET, 0, "AM_DEAD", "");
        listenerFarm = llListen(FARM_CHANNEL, "", "", "");
    }

    listen(integer c, string nm, key id, string msg)
    {
        llRegionSayTo(userID, 0, "DEAD_msg:"+msg);

        if (c == FARM_CHANNEL)
        {
            list tk = llParseStringKeepNulls(msg, ["|"] , []);
            string cmd = llList2String(tk,0);

            if (cmd == "MAGIC")
            {
                if (llList2String(tk, 2) == "RESTORE_LIFE")
                {
                    if (llList2Integer(tk, 3) == 0)
                    {
                        txt_off();
                        isDead = FALSE;
                        llMessageLinked(LINK_SET, 1, "AM_DEAD", "");
                        setBorder(ORANGE);
                        active = TRUE;
                        floatText("\n - - -\n", ORANGE, 1);
                    }
                    else
                    {
                        startAnim("");
                        llMessageLinked(LINK_SET, 2, "AM_DEAD", "");
                        startAnim(wealthAnim);
                        llSleep(1);
                        startAnim("");
                        listener = -1;
                        llOwnerSay("@camtextures:b7ac96e5-21cb-44a5-a594-70651047ed43=y");
                        systemReset(TRUE);
                    }
                }
            }
        }
    }

}
