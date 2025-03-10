/**
 * vivosim_exchange.lsl
 * Allows anyone with a VivoSim account to buy & sell goods using Vivo coins

 * CHANGE LOG
  * Now shows image from collective if set and in collective mode
  * Can be set to only allow interaction by members of collective
  *
  * Now shows XP as nn.n
  * Fixed not displaying local texture if USE_TEXTURE=1 set
  * Support for showing top ten limited to Co-op membership, set via config notecard
       CO-OP_MODE=0					  Set to 1 to only work with and show data about selected Co-op
       CO_OP_ID=""					  Set to 4 digit code of co-op e.g.  1001
**/

// New strings
string TXT_COMMS_ERROR  = "Sorry, transaction failed, please try again later";
string TXT_COLLECTIVE   = "Collective";
string TXT_COLLECTIVE_ONLY = "Sorry, this board only allows members of the collective to use it";

// Changed strings
string TXT_NOT_FOUND    = "No more items found nearby";
string TXT_BAD_PASSWORD = "Sorry, expired or broken product";
string TXT_EX_TYPE      = "Type";
string TXT_EX_NAME      = "Exchange name";
string TXT_OPERATION_MODE = "Mode";

float   VERSION = 6.11;    // 4 May 2024
integer RSTATE  = 0;       // RSTATE = 1 for release, 0 for beta, -1 for Release candidate
//
integer DEBUGMODE = FALSE;
debug(string text)
{
	if (DEBUGMODE == TRUE) llOwnerSay("DEBUG:" + llToUpper(llGetScriptName()) + "\n" + text +" STATUS: " +status);
}

// Server URLs
string webURL 		= "vivosim.net/";
string webBASEURL;

string phpURL 		= "vivosim.net/index.php/?option=com_vivosim&view=vivosim&type=vivosim&format=json&";
string phpBASEURL;

string ImageURL_W 	= "/images/logo/vexw.png";   // for white background
string ImageURL_B 	= "/images/logo/vexb.png";   // for black background
string imageBASEURL;

string REGURL   	= "https://vivosim.net/register";
string vivoLogo		= "5fad78f0-26ba-411d-92b6-6b1b922f2f7d";

string marketType = "market_grocery.inf";  // or  market_hardware.inf  or  market_concessions.inf  or  market_bazaar.inf  or  market_gorean.inf
//
// Can be overridden by config notecard
string  exchangeType = "grocery";           // TYPE=Grocery                   Can be 'grocery', 'bazaar', 'hardware', 'concessions' or 'gorean' [bazaar is grocery minus concessions items]
integer useScreen = 1;                      // SCREEN=1                       Set to 0 for exchanges that don't use a screen
integer FACE = 4;                           // FACE=4                         Which face to display information on
integer useDarkMode = FALSE;                // DARK_MODE=0                    Set to 1 for datk mode screen, 0 for light
integer useTexture = FALSE;                 // USE_TEXTURE=0                  Set to 1 to use first texture found in inventory, 0 to use profile cover image (on vivosim.net)
vector  rezzPosition = <-1.5, 0.0, -1.0>;   // REZ_POSITION=<-1.5, 0.0, -1.0> Offset for rezzing productts
integer SENSOR_DISTANCE = 10;               // SENSOR_DISTANCE=10             Radius in m to scan
integer offset = 0;                         // Offset from UTC                For the 'last update' text
string  fontName = "Arial";                 // FONT=Arial                     See https://www.w3schools.com/cssref/css_websafe_fonts.php
integer useHTTPS = FALSE;                   // USE_HTTPS=0;                   Set to 1 to force https comms with server
integer useBeta = FALSE;                    // USE_BETA=0;                    Set to 1 to connect to the beta test site
string  languageCode = "en-GB";             // LANG=en-GB

//  STILL IN BETA STAGE - for release force this to always false
integer useCollectiveID = FALSE;			// COLLECTIVE_MODE=0			  Set to 1 to only work with and show data about selected Co-op
string  collectiveID = "";					// COLLECTIVE_ID=""				  Set to ID code of collective (from JomSocial)
integer allowRegister = FALSE;              // REGEX=1                        Set to 0 if this exchange box should't be registered on server

// Multilingual support
string  SUFFIX = "E1";

string    TXT_ACCESS_LEVEL         =    "Access level";
string    TXT_ACTIVATE             =    "Activate";
string    TXT_ALWAYS_SELL          =    "Normal";
string    TXT_AM                   =    "AM";
string    TXT_BAZAAR               =    "Bazaar";
string    TXT_BUY                  =    "Buy goods";
string    TXT_BUY_SELL             =    "Trade";
string    TXT_CHARGED              =    "You have been charged";
string    TXT_CHECKING             =    "Checking other locations...";
string    TXT_CHECKING_POINTS      =    "Checking...";
string    TXT_CLICK_FOR_MENU       =    "Click for menu...";
string    TXT_CLOSE                =    "CLOSE";
string    TXT_COINS                =    "Coins";
string    TXT_COIN_SYMBOL          =    "v";
string    TXT_CREDITED             =    "You have been credited ";
string    TXT_DARK_MODE            =    "Dark mode";
string    TXT_ENABLE               =    "Touch to enable";
string    TXT_EMPTYING             =    "emptying";
string    TXT_ERROR_DISABLED       =    "Sorry, system is currently disabled";
string    TXT_ERROR_GROUP          =    "Error, we are not in the same group";
string    TXT_ERROR_NOT_FOUND      =    "not found nearby";
string    TXT_ERROR_UPDATE         =    "Error: unable to update - you are not my owner";
string    TXT_EVERYONE             =    "Everyone";
string    TXT_GROCERY              =    "Grocery";
string    TXT_FARM_DESCRIPTION     =    "Description";
string    TXT_FOUND                =    "Found";
string    TXT_GIVE_PURCHASE        =    "Here is your purchase of ";
string    TXT_GOREAN               =    "Gorean";
string    TXT_GROUP                =    "Group";
string    TXT_GROUP_ONLY           =    "Sorry, this board only allows members of the group to use it";
string    TXT_HARDWARE             =    "Hardware";
string    TXT_CONCESSIONS          =    "Concessions";
string    TXT_INFO_MSG1            =    "To use points you first need to create an account";
string    TXT_INFO_MSG2            =    "You can create a VivoSim web account and then link it to this this avatar";
string    TXT_INSUFFICIENT_POINTS  =    "Sorry, you don't have enough points";
string    TXT_LAST_UPDATE          =    "Last update";
string    TXT_LOCAL                =    "Local";
string    TXT_LOCAL_ONLY           =    "Sorry, this board only allows local residents to use it";
string    TXT_NAME                 =    "Name";
string    TXT_NEWER_VERSION        =    "Newer version available";
string    TXT_NO_STOCK             =    "I don't have any stock of";
string    TXT_NOT_FOUND_INV        =    "Unable to find item in any other locations, sorry";
string    TXT_NOT_FOUND_ITEM       =    "not found nearby. You must bring them closer";
string    TXT_NOT_FOUND100         =    "with 100% not found nearby";
string    TXT_NOW_AVAILABLE        =    "Now available";
string    TXT_OFF                  =    "Off";
string    TXT_OFFLINE              =    "-- System Offline --";
string    TXT_ON                   =    "On";
string    TXT_OPTIONS              =    "Options";
string    TXT_PM                   =    "PM";
string    TXT_POINTS               =    "XP";
string    TXT_PRICES               =    "Show prices";
string    TXT_RANK                 =    "Rank";
string    TXT_READY                =    "Ready";
string    TXT_SCORE                =    "Score";
string    TXT_SEARCH               =    "SEARCH";
string    TXT_SEARCH_FAIL          =    "Sorry, search found nothing matching";
string    TXT_SEARCH_ITEM          =    "Search for...";
string    TXT_SELECT               =    "Choose option";
string    TXT_SELL                 =    "Sell goods";
string    TXT_SELL_ONLY            =    "Sell only";
string    TXT_TOPTEN               =    "VivoSim Leaderboard";
string    TXT_YOU_HAVE             =    "You have";
string    TXT_LANGUAGE             =    "@";
//
string TXT_RECENT_ACTIVITY = "Your Recent Activity";
string TXT_ACTIVITY = "Activity";
string TXT_DETAILS = "Details";
string TXT_RESET = "RESET";
//
string    TXT_DAYS="Days";
string    TXT_SUN="Sun";
string    TXT_MON="Mon";
string    TXT_TUE="Tue";
string    TXT_WED="Wed";
string    TXT_THU="Thu";
string    TXT_FRI="Fri";
string    TXT_SAT="Sat";
list      weekdays;
//
vector  GREEN       = <0.180, 0.800, 0.251>;
vector  YELLOW      = <1.000, 0.863, 0.000>;
vector  WHITE       = <1.0, 1.0, 1.0>;
integer CREDIT = 1;
integer DEBIT = -1;
string  farmName   = "*";
string  PASSWORD   = "*";
string  ExchangeID = "*" ;		// Unique key for registering this exchange on the server

string  stockNC    = "stklst";
string  tallyNC    = "tally";
string  settingsNC = "xcfg";
string  exchID     = "vex";
string  pwNC       = "sfp";
integer quinActive;
integer slaveState;
key     farmHTTP = NULL_KEY;
integer FARM_CHANNEL = -911201;
key     userToPayKey;
string  userToPayCollective;
key     owner;
integer joomlaID = 0;
integer activeVer;
integer outOfDate = FALSE;
key     ownKey;
string  lookingFor;
string  itemPrice;
integer startOffset = 0;
integer screenListOffset = 0;
integer screenCapacity = 60;
string  status;
string  screenState;
integer accessMode = 0;		// 0=Everyone, 1=Group, 2=Local residents, 3=Collective
integer opMode = 1;			// 0=Only items sold to this exchange can be purchased, 1=Normal operation
list    modeNames = [];
list    items = [];
list    prices = [];
list    sellItems = [];
list    stockItems = [];	// [item, quantity]
string  shareMode = "all";	// SHARE_MODE is always =All for the exchange
list    soldTally     = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
list    purchaseTally = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
integer totalSold;
integer totalPurchased;
integer lastDay = 0;
string  farmDescription = "";
string  profileCover = "";
integer lastPoll;

setMarket(string exchType)
{
	if (exchType == "bazaar") marketType = "market_bazaar.inf"; else if (exchType == "hardware") marketType = "market_hardware.inf"; else if (exchType == "concessions") marketType = "market_concessions.inf"; else if (exchType == "gorean") marketType = "market_gorean.inf"; else marketType = "market_grocery.inf";
}

loadConfig()
{
	//sfp 'password' notecard
	PASSWORD = osGetNotecardLine(pwNC, 0);
    // Set the owner key
	owner = llGetOwner();

	//qex 'exchange id' notecard
	if (llGetInventoryType(exchID) == INVENTORY_NOTECARD)
	{
		// Read in the exchange ID
		ExchangeID = osGetNotecardLine(exchID, 0);
	}
	else
	{
		// notecard not found so make a new one
		ExchangeID = "*";
		osMakeNotecard(exchID, ExchangeID);
	}

	//config notecard
	if (llGetInventoryType("config") == INVENTORY_NOTECARD)
	{
		list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
		integer i;

		for (i=0; i < llGetListLength(lines); i++)
		{
			list tok = llParseString2List(llList2String(lines,i), ["="], []);

			if (llList2String(tok,1) != "")
			{
				string cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
				string val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

					 if (cmd == "TYPE") exchangeType = llToLower(val);
				else if (cmd == "SCREEN") useScreen = (integer)val;
				else if (cmd == "FACE") FACE = (integer)val;
				else if (cmd == "DARK_MODE") useDarkMode = (integer)val;
				else if (cmd == "SENSOR_DISTANCE") SENSOR_DISTANCE = (integer)val;
				else if (cmd == "REZ_POSITION") rezzPosition = (vector)val;
				else if (cmd == "REGEX") allowRegister = (integer)val;
				else if (cmd == "LANG") languageCode = val;
				else if (cmd == "FONT") fontName = val;
				else if (cmd == "COLLECTIVE_MODE") useCollectiveID = (integer)val;
				else if (cmd == "COLLECTIVE_ID") collectiveID = val;  
				else if (cmd == "USE_HTTPS") useHTTPS = (integer)val;
				else if (cmd == "USE_BETA") useBeta = (integer)val;
				else if (cmd == "USE_TEXTURE")
				{
					// If switching from use a texture to use profile image, clear any existing texture we had stored
					if ((useTexture == 1) && ((integer)val == 0))
					{
						profileCover = "";
					}

					useTexture = (integer)val;
					
				}
				else if (cmd == "DEBUG")
				{
					// If script has it as true it overides config notecard setting
					if (DEBUGMODE == FALSE) DEBUGMODE = (integer)val;
				}
			}
		}
	}

	setMarket(exchangeType);

	// ===========================================================
	//  FOR THIS RELEASE ALWAYS SET TO FALSE AS NEEDS MORE WORK!
		allowRegister = FALSE;
	// ===========================================================

	// Load settings from description
	list desc = llParseStringKeepNulls(llGetObjectDesc(), [";"], []);

	if (llList2String(desc, 0) == "E")
	{
		accessMode = llList2Integer(desc, 1);
		languageCode = llList2String(desc, 2);
		farmName = llList2String(desc, 3);
		exchangeType = llList2String(desc, 4);
		setMarket(exchangeType);
		opMode = llList2Integer(desc, 5);
		useDarkMode = llList2Integer(desc, 6);
	}
	else
	{
		saveToDesc();
	}

	// Set HTTP/HTTPS option
	if (useHTTPS == TRUE)
	{
		if (useBeta == TRUE)
		{
			phpBASEURL = "https://beta." + phpURL;
			webBASEURL = "https://beta." + webURL;

			if (useDarkMode == TRUE)
			{
				imageBASEURL = "https://beta." + webURL + ImageURL_B;
			}
			else
			{
				imageBASEURL = "https://beta." + webURL + ImageURL_W;
			}
		}
		else
		{
			phpBASEURL = "https://" + phpURL;
			webBASEURL = "https://" + webURL;

			if (useDarkMode == TRUE)
			{
				imageBASEURL = "https://" + webURL + ImageURL_B;
			}
			else
			{
				imageBASEURL = "https://" + webURL + ImageURL_W;
			}
		}
	}
	else
	{
		if (useBeta == TRUE)
		{
			phpBASEURL = "http://beta." + phpURL;
			webBASEURL = "http://beta." + webURL;

			if (useDarkMode == TRUE)
			{
				imageBASEURL = "http://beta." + webURL + ImageURL_B;
			}
			else
			{
				imageBASEURL = "http://beta." + webURL + ImageURL_W;
			}
		}
		else
		{
			phpBASEURL = "http://" + phpURL;
			webBASEURL = "http://" + webURL;

			if (useDarkMode == TRUE)
			{
				imageBASEURL = "http://" + webURL + ImageURL_B;
			}
			else
			{
				imageBASEURL = "http://" + webURL + ImageURL_W;
			}
		}

	}

	llMessageLinked(LINK_SET, useHTTPS, "SETHTTPS|" + phpBASEURL, "");

	// Set Collective mode and value
	llMessageLinked(LINK_SET, useCollectiveID, "COLLECTIVE_MODE|" + collectiveID, "");

	// Get farm description if saved
	if (llGetInventoryType(settingsNC) == INVENTORY_NOTECARD)
	{
		farmDescription = osGetNotecard(settingsNC);
	}
}

loadLanguage(string langCode)
{
	// optional language notecard
	string languageNC = langCode + "-lang" + SUFFIX;

	if (llGetInventoryType(languageNC) == INVENTORY_NOTECARD)
	{
		list lines = llParseStringKeepNulls(osGetNotecard(languageNC), ["\n"], []);
		integer i;

		for (i=0; i < llGetListLength(lines); i++)
		{
			string line = llList2String(lines, i);

			if (llGetSubString(line, 0, 0) != ";")
			{
				list tok = llParseString2List(line, ["="], []);

				if (llList2String(tok,1) != "")
				{
					string cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
					string val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

					// Remove start and end " marks
					val = llGetSubString(val, 1, -2);

					// Now check for language translations
						 if (cmd == "TXT_ACCESS_LEVEL")      TXT_ACCESS_LEVEL     = val;
					else if (cmd == "TXT_ACTIVATE")          TXT_ACTIVATE         = val;
					else if (cmd == "TXT_ACTIVITY")          TXT_ACTIVITY         = val;
					else if (cmd == "TXT_ALWAYS_SELL")       TXT_ALWAYS_SELL      = val;
					else if (cmd == "TXT_AM")                TXT_AM               = val;
					else if (cmd == "TXT_BAD_PASSWORD")      TXT_BAD_PASSWORD     = val;
					else if (cmd == "TXT_BAZAAR")            TXT_BAZAAR           = val;
					else if (cmd == "TXT_BUY")               TXT_BUY              = val;
					else if (cmd == "TXT_BUY_SELL")          TXT_BUY_SELL         = val;
					else if (cmd == "TXT_CHARGED")           TXT_CHARGED          = val;
					else if (cmd == "TXT_CHECKING")          TXT_CHECKING         = val;
					else if (cmd == "TXT_CHECKING_POINTS")   TXT_CHECKING_POINTS  = val;
					else if (cmd == "TXT_CLICK_FOR_MENU")    TXT_CLICK_FOR_MENU   = val;
					else if (cmd == "TXT_CLOSE")             TXT_CLOSE            = val;
					else if (cmd == "TXT_COINS")             TXT_COINS            = val;
					else if (cmd == "TXT_COIN_SYMBOL")       TXT_COIN_SYMBOL      = val;
					else if (cmd == "TXT_COLLECTIVE")        TXT_COLLECTIVE       = val;
					else if (cmd == "TXT_COLLECTIVE_ONLY")    TXT_COLLECTIVE_ONLY = val;
					else if (cmd == "TXT_COMMS_ERROR")       TXT_COMMS_ERROR      = val;
					else if (cmd == "TXT_CREDITED")          TXT_CREDITED         = val;
					else if (cmd == "TXT_DARK_MODE")         TXT_DARK_MODE        = val;
					else if (cmd == "TXT_DETAILS")           TXT_DETAILS          = val;
					else if (cmd == "TXT_EMPTYING")          TXT_EMPTYING         = val;
					else if (cmd == "TXT_ERROR_DISABLED")    TXT_ERROR_DISABLED   = val;
					else if (cmd == "TXT_ERROR_GROUP")       TXT_ERROR_GROUP      = val;
					else if (cmd == "TXT_ERROR_NOT_FOUND")   TXT_ERROR_NOT_FOUND  = val;
					else if (cmd == "TXT_ERROR_UPDATE")      TXT_ERROR_UPDATE     = val;
					else if (cmd == "TXT_EVERYONE")          TXT_EVERYONE         = val;
					else if (cmd == "TXT_EX_TYPE")           TXT_EX_TYPE          = val;
					else if (cmd == "TXT_GROCERY")           TXT_GROCERY          = val;
					else if (cmd == "TXT_FARM_DESCRIPTION")  TXT_FARM_DESCRIPTION = val;
					else if (cmd == "TXT_EX_NAME")           TXT_EX_NAME          = val;
					else if (cmd == "TXT_FOUND")             TXT_FOUND            = val;
					else if (cmd == "TXT_GIVE_PURCHASE")     TXT_GIVE_PURCHASE    = val;
					else if (cmd == "TXT_GOREAN")            TXT_GOREAN           = val;
					else if (cmd == "TXT_GROUP")             TXT_GROUP            = val;
					else if (cmd == "TXT_GROUP_ONLY")        TXT_GROUP_ONLY       = val;
					else if (cmd == "TXT_HARDWARE")          TXT_HARDWARE         = val;
					else if (cmd == "TXT_CONCESSIONS")         TXT_CONCESSIONS    = val;
					else if (cmd == "TXT_INFO_MSG2")           TXT_INFO_MSG2      = val;
					else if (cmd == "TXT_INFO_MSG1")           TXT_INFO_MSG1      = val;
					else if (cmd == "TXT_INSUFFICIENT_POINTS") TXT_INSUFFICIENT_POINTS = val;
					else if (cmd == "TXT_LAST_UPDATE")         TXT_LAST_UPDATE    = val;
					else if (cmd == "TXT_LOCAL")               TXT_LOCAL          = val;
					else if (cmd == "TXT_LOCAL_ONLY")          TXT_LOCAL_ONLY     = val;
					else if (cmd == "TXT_NAME")                TXT_NAME           = val;
					else if (cmd == "TXT_NEWER_VERSION")       TXT_NEWER_VERSION  = val;
					else if (cmd == "TXT_NOT_FOUND")  TXT_NOT_FOUND               = val;
					else if (cmd == "TXT_NO_STOCK")    TXT_NO_STOCK               = val;
					else if (cmd == "TXT_NOT_FOUND_INV") TXT_NOT_FOUND_INV        = val;
					else if (cmd == "TXT_NOT_FOUND_ITEM") TXT_NOT_FOUND_ITEM      = val;
					else if (cmd == "TXT_NOT_FOUND100") TXT_NOT_FOUND100          = val;
					else if (cmd == "TXT_NOW_AVAILABLE")  TXT_NOW_AVAILABLE       = val;
					else if (cmd == "TXT_OFF") TXT_OFF                            = val;
					else if (cmd == "TXT_OFFLINE") TXT_OFFLINE                    = val;
					else if (cmd == "TXT_ON") TXT_ON                              = val;
					else if (cmd == "TXT_OPERATION_MODE") TXT_OPERATION_MODE      = val;
					else if (cmd == "TXT_OPTIONS")    TXT_OPTIONS                 = val;
					else if (cmd == "TXT_PM")         TXT_PM                      = val;
					else if (cmd == "TXT_POINTS")     TXT_POINTS                  = val;
					else if (cmd == "TXT_PRICES") TXT_PRICES                      = val;
					else if (cmd == "TXT_RANK")   TXT_RANK                        = val;
					else if (cmd == "TXT_READY")  TXT_READY                       = val;
					else if (cmd == "TXT_RECENT_ACTIVITY") TXT_RECENT_ACTIVITY    = val;
					else if (cmd == "TXT_SEARCH") TXT_SEARCH                      = val;
					else if (cmd == "TXT_SEARCH_FAIL") TXT_SEARCH_FAIL            = val;
					else if (cmd == "TXT_SEARCH_ITEM") TXT_SEARCH_ITEM            = val;
					else if (cmd == "TXT_SCORE") TXT_SCORE                        = val;
					else if (cmd == "TXT_SELECT") TXT_SELECT                      = val;
					else if (cmd == "TXT_SELL") TXT_SELL                          = val;
					else if (cmd == "TXT_SELL_ONLY")   TXT_SELL_ONLY              = val;
					else if (cmd == "TXT_TOPTEN")  TXT_TOPTEN                     = val;
					else if (cmd == "TXT_YOU_HAVE")   TXT_YOU_HAVE                = val;
					else if (cmd == "TXT_ENABLE")  TXT_ENABLE                     = val;
					else if (cmd == "TXT_LANGUAGE") TXT_LANGUAGE                  = val;
					else if (cmd == "TXT_SUN") TXT_SUN = val;
					else if (cmd == "TXT_MON") TXT_MON = val;
					else if (cmd == "TXT_TUE") TXT_TUE = val;
					else if (cmd == "TXT_WED") TXT_WED = val;
					else if (cmd == "TXT_THU") TXT_THU = val;
					else if (cmd == "TXT_FRI") TXT_FRI = val;
					else if (cmd == "TXT_SAT") TXT_SAT = val;
				}
			}
		}
	}
}

saveToDesc()
{
	llSetObjectDesc("E;" +(string)accessMode+";" +languageCode + ";" +farmName +";" +exchangeType +";" +(string)opMode +";" +(string)useDarkMode);
	setMarket(exchangeType);
}

loadStock()
{
	stockItems = [];

	if (llGetInventoryType(stockNC) == INVENTORY_NOTECARD)
	{
		list lines = llParseStringKeepNulls(osGetNotecard(stockNC), ["\n"], []);
		integer i;

		for (i=0; i < llGetListLength(lines); i++)
		{
			// SF Beef|1
			list values = llParseString2List(llList2String(lines, i), ["|"], []);
			stockItems += values;
		}
	}

	debug("STOCK:" +llDumpList2String(stockItems, ","));
}

saveStock(string item, integer transaction)
{
	debug("=== saveStock called ===");
	integer qty;

	if (llGetInventoryType(stockNC) == INVENTORY_NOTECARD)
	{
		llRemoveInventory(stockNC);
	}

	// Check if item already in stock
	integer invCheck = llListFindList(stockItems, [item]);

	if (invCheck != -1)
	{
		// already in stock so update total
		if (transaction == CREDIT)
		{
			qty = llList2Integer(stockItems, invCheck+1) +1;
		}
		else
		{
			qty = llList2Integer(stockItems, invCheck+1) -1;
		}

		if (qty >0)
		{
			stockItems = llListReplaceList(stockItems, [item, qty], invCheck, invCheck+1);
		}
		else
		{
			stockItems = llDeleteSubList(stockItems, invCheck, invCheck+1);
		}
	}
	else
	{
		if (transaction == CREDIT)
		{
			// not in stock so add to stock list
			stockItems += [item, 1];
		}
	}

	// now save updated stock list
	string output = "";
	integer count = llGetListLength(stockItems);
	integer i;

	for (i=0; i < count; i+=2)
	{
		output += llList2String(stockItems, i) + "|" + llList2String(stockItems, i+1) +"\n";
	}

	osMakeNotecard(stockNC, output);
}

integer inStock(string prodName)
{
	if (llListFindList(stockItems, [prodName]) != -1)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

integer chan(key u)
{
	return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

integer listener=-1;
integer listenTs;

startListen()
{
	if (listener<0)
	{
		listener = llListen(chan(llGetKey()), "", "", "");
	}

	listenTs = llGetUnixTime();
}

checkListen(integer force)
{
	if ((listener > 0 && llGetUnixTime() - listenTs > 300) || force)
	{
		llListenRemove(listener);
		listener = -1;
		status = "";
		sellItems = [];
	}
}

multiPageMenu(key id, string message, list buttons)
{
	integer l = llGetListLength(buttons);
	integer ch = chan(ownKey);
	
	if (l < 11)
	{
		if (status == "SellGoods")
		{
			llDialog(id, message, [TXT_CLOSE]+buttons, ch);
		}
		else
		{
			llDialog(id, message, [TXT_CLOSE, TXT_SEARCH]+buttons, ch);
		}

		return;
	}

	if (startOffset >= l)
	{
		startOffset = 0;
	}

	list its = llList2List(buttons, startOffset, startOffset + 8);
	llDialog(id, message, [TXT_CLOSE, TXT_SEARCH]+its+[">>"], ch);
}

setImage()
{
	if (useTexture == TRUE)
	{
		profileCover = llGetInventoryName(INVENTORY_TEXTURE, 0);

		// Convert to UUID to pass to other prim
		profileCover = (string)llGetInventoryKey(profileCover);
	}

	if (profileCover != "")
	{
		llMessageLinked(LINK_SET, useTexture, "SHOW_IMAGE|" +profileCover , "");
	}
	else
	{
		if (getLinkNum("secondary_display") != -1)
		{
			llSetLinkTexture(getLinkNum("secondary_display"), vivoLogo, FACE);
		}

		if (getLinkNum("display_board") != -1)
		{
			llSetLinkTexture(getLinkNum("display_board"), vivoLogo, FACE);
		}
	}
}

messageScreen(string msg)
{
	screenState = "idle";

	if (useScreen == TRUE)
	{
		if (getLinkNum("secondary_display") != -1)
		{
			llSetLinkAlpha(getLinkNum("secondary_display"), 1.0, ALL_SIDES);
		}

		if (getLinkNum("buttons_display") != -1)
		{
			llSetLinkAlpha(getLinkNum("buttons_display"), 0.0, ALL_SIDES);
		}

		llSetTexture("blank", FACE);
		string body = "width:512,height:512,Alpha:128";
		string CommandList = "";  // Storage for our drawing commands
		string statusColour;
		string tmpStr = "";
		integer X;

		// Set the font to use
		CommandList = osSetFontName(CommandList, fontName);

		// Draw the border
		if (quinActive == FALSE) {statusColour = "crimson";} else if (useBeta == TRUE) {statusColour = "gold";} else {statusColour = "chartreuse";}

		CommandList = osSetPenSize( CommandList, 70);
		CommandList = osSetPenColor( CommandList, statusColour );
		CommandList = osMovePen( CommandList, 0,0);
		CommandList = osDrawRectangle( CommandList, 505,505);

		// Fill in background
		if (useDarkMode == TRUE) CommandList = osSetPenColor( CommandList, "black" ); else CommandList = osSetPenColor( CommandList, "cornsilk" );

		CommandList = osMovePen( CommandList, 10, 10 );
		CommandList = osDrawFilledRectangle( CommandList, 490, 490 );

		// Display VivoSim Exchange logo
		CommandList = osMovePen(CommandList, 28, 20);
		CommandList = osDrawImage(CommandList, 455, 75, imageBASEURL);   // Display logo

		// Display farm details
		if (quinActive == TRUE)
		{
			if (useDarkMode == TRUE)
			{
				CommandList = osSetPenColor(CommandList, "cornsilk");
			}
			else
			{
				CommandList = osSetPenColor(CommandList, "navy");
			}

			CommandList = osSetFontSize(CommandList, 28);
			vector Extents = osGetDrawStringSize( "vector", farmName, "Arial", 28);
			integer xpos = 256 - ((integer) Extents.x >> 1);        // Center the text horizontally
			CommandList = osMovePen(CommandList, xpos, 100);        // Position the text
			CommandList = osDrawText(CommandList, farmName);        // Place the text
			
			// Display the farm description
			if (useDarkMode == TRUE)
			{
				CommandList = osSetPenColor(CommandList, "gold");
			}
			else
			{
				CommandList = osSetPenColor(CommandList, "darkgreen");
			}
			
			if (llStringLength(msg) < 40)
			{
				CommandList = osSetFontSize(CommandList, 14);
				Extents = osGetDrawStringSize( "vector", msg, "Arial", 14);
			}
			else
			{
				CommandList = osSetFontSize(CommandList, 12);
				Extents = osGetDrawStringSize( "vector", msg, "Arial", 12);
			}

			xpos = 256 - ((integer) Extents.x >> 1);                // Center the text horizontally
			CommandList = osMovePen(CommandList, xpos, 430);        // Position the text
			CommandList = osDrawText(CommandList, msg);             // Place the text

			// show exchange type
			CommandList = osSetFontSize(CommandList, 7);
			CommandList = osSetPenColor(CommandList, "black");

				 if (exchangeType == "grocery")   tmpStr =  TXT_GROCERY;
			else if (exchangeType == "hardware") tmpStr =  TXT_HARDWARE;
			else if (exchangeType == "concessions") tmpStr = TXT_CONCESSIONS;
			else if (exchangeType == "bazaar") tmpStr =  TXT_BAZAAR;

			// Show version info
			tmpStr += " - V" +qsFixPrecision(VERSION, 2);

			if (RSTATE == 0)
			{
				tmpStr+= " Beta";
			}
			else if (RSTATE == -1)
			{
				tmpStr+= " RC";
			}

			if (outOfDate == TRUE)
			{
				tmpStr += " |  [" +TXT_NEWER_VERSION +", ";
				tmpStr += " V" +qsFixPrecision(0.1 * activeVer, 1) +"]";
			}

			CommandList = osMovePen(CommandList, 10, 500);        // Position the text
			CommandList = osDrawText(CommandList, tmpStr);         // Place the text
		}
		else
		{
			CommandList = osSetFontSize(CommandList, 30);
			CommandList = osMovePen(CommandList, 100,150);
			CommandList = osDrawText(CommandList, TXT_OFFLINE);
		}

		osSetDynamicTextureDataBlendFace("", "vector", CommandList, body, FALSE, 1, 0, 255, FACE);
	}
}

showPrices()
{
	screenState = "showPrices";

	if (useScreen == TRUE)
	{
		if (getLinkNum("secondary_display") != -1)
		{
			llSetLinkAlpha(getLinkNum("secondary_display"), 0.0, ALL_SIDES);
		}

		if (getLinkNum("buttons_display")   != -1)
		{
			llSetLinkPrimitiveParams(getLinkNum("buttons_display"), [PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0 ]);

			if (screenListOffset == 0)
			{
				llSetLinkPrimitiveParams(getLinkNum("buttons_display"), [PRIM_COLOR, 2, <0.0, 0.0, 0.0>, 0.0 ]);
			}

			if (screenListOffset+screenCapacity > llGetListLength(items))
			{
				llSetLinkPrimitiveParams(getLinkNum("buttons_display"), [PRIM_COLOR, 4, <0.0, 0.0, 0.0>, 0.0 ]);
			}
		}

		integer i;
		integer j = llGetListLength(items);
		integer k;
		string outputTextL = "";
		string outputTextR = "";
		string tmpStr = "";
		string body = "width:512,height:512";
		string CommandList = "";  // Storage for our drawing commands
		string statusColour;
		llSetTexture("blank", FACE);

		// Set the font to use
		CommandList = osSetFontName(CommandList, fontName);

		// Fill in background
		if (useDarkMode == TRUE)
		{
			CommandList = osSetPenColor( CommandList, "black" );
		}
		else
		{
			CommandList = osSetPenColor( CommandList, "cornsilk" );
		}
		
		CommandList = osMovePen( CommandList, 10, 10 );
		CommandList = osDrawFilledRectangle( CommandList, 490, 490 );

		// Show the Exchange logo
		CommandList = osMovePen(CommandList, 20, 20);
		CommandList = osDrawImage(CommandList, 230, 40, imageBASEURL);  // Display small logo

		// show exchange type
		CommandList = osSetFontSize(CommandList, 10);

		if (useDarkMode == TRUE) CommandList = osSetPenColor(CommandList, "cornsilk"); else CommandList = osSetPenColor(CommandList, "slateblue");

		if (exchangeType == "grocery")   tmpStr =  TXT_GROCERY;
		 else if (exchangeType == "hardware") tmpStr =  TXT_HARDWARE;
		  else if (exchangeType == "concessions") tmpStr = TXT_CONCESSIONS;
		   else if (exchangeType == "bazaar") tmpStr =  TXT_BAZAAR;

		 // Show version info
		tmpStr += " (V" +qsFixPrecision(VERSION, 2);

		if (RSTATE == 0) tmpStr+= " Beta"; else if (RSTATE == -1) tmpStr+= " RC";

		tmpStr += ")";
		CommandList = osMovePen(CommandList, 300, 10);
		CommandList = osDrawText(CommandList, tmpStr);

		if (quinActive == FALSE)
		{
			statusColour = "crimson";
		}
		else if (useBeta == TRUE)
		{
			statusColour = "gold";
		}
		else
	 	{
			statusColour = "chartreuse";
		}

		CommandList = osSetPenSize(CommandList, 20);
		CommandList = osSetPenColor(CommandList, statusColour);
		CommandList = osMovePen(CommandList, 0,0);
		CommandList = osDrawRectangle(CommandList, 505,505);
		CommandList = osMovePen(CommandList, 15, 70);
		CommandList = osSetFontSize(CommandList, 10);

		if (quinActive == TRUE)
		{
			if (useDarkMode == TRUE)
			{
				CommandList = osSetPenColor(CommandList, "cornsilk");
			}
			else
			{
				CommandList = osSetPenColor(CommandList, "DarkBlue");
			}

			string product;
			string what;

			for( i = 0; i < screenCapacity; i = i+2 )
			{
				product =  llList2String(items, i+screenListOffset);

				if (product != "")
				{
					what = "SF " + product;

					if (llGetInventoryType(what) != INVENTORY_OBJECT)
					{
						product = "x ";
					}
					else
					{
						if (opMode == 0)
						{

							if (inStock(what) == FALSE)
							{
								product = "x ";
							}
							else
							{
								product = "• ";
							}
						}
						else
						{
							product = "• ";
						}
					}

					outputTextL = outputTextL +product +llList2String(items, i+screenListOffset) +" " +llList2String(prices, i+screenListOffset) +TXT_COIN_SYMBOL +"\n";
				}
				else
				{
					outputTextL = outputTextL + "-";
				}

				k = i + 1;
				product =  llList2String(items, k+screenListOffset);

				if (product != "")
				{
					what = "SF " + product;

					if (llGetInventoryType(what) != INVENTORY_OBJECT)
					{
						product = "x ";
					}
					else
					{
						if (opMode == 0)
						{

							if (inStock(what) == FALSE)
							{
								product = "x ";
							}
							else
							{
								product = "• ";
							}
						}
						else
						{
							product = "• ";
						}
					}
					outputTextR = outputTextR +product +llList2String(items, k+screenListOffset) +" " +llList2String(prices, k+screenListOffset) +TXT_COIN_SYMBOL +"\n";
				}
				else
				{
					outputTextL = outputTextL + "-";
				}
			}

			CommandList = osDrawText(CommandList, outputTextL);
			CommandList = osMovePen(CommandList, 280, 70);
			CommandList = osDrawText(CommandList, outputTextR);
		}
		else
		{
			CommandList = osMovePen(CommandList, 150,150);
			CommandList = osDrawText(CommandList, TXT_OFFLINE);
		}
			// Show if out of date
			if (outOfDate == TRUE)
			{
				tmpStr += " |  [" +TXT_NEWER_VERSION +", ";
				tmpStr += " V" +qsFixPrecision(0.1*activeVer, 1) +"]";
				CommandList = osSetFontSize(CommandList, 7);
				CommandList = osMovePen(CommandList, 5, 500);
				CommandList = osDrawText(CommandList, tmpStr);
			}

		// Show key
		if (useDarkMode == TRUE)
		{
			CommandList = osSetPenColor(CommandList, "cornsilk");
		}
		else
		{
			CommandList = osSetPenColor(CommandList, "MidnightBlue");
		}

		// Do it!
		osSetDynamicTextureDataFace("", "vector", CommandList, body, 0, FACE);
		status = "displayActive";
		llSetTimerEvent(60);
	}
}

integer getLinkNum(string name)
{
	integer i;

	for (i=1; i <=llGetNumberOfPrims(); i++)
		if (llGetLinkName(i) == name) return i;
	return -1;
}

activate()
{
	string msg = "task=activq327&data1=1";

	// Check if there is an ID for this Exchange
	if (ExchangeID == "*")
	{
		// Exchange has not been registered with VivoSim server
		if (allowRegister == TRUE)
		{
			llRemoveInventory(exchID);
			ExchangeID = (string)llGenerateKey( );
			osMakeNotecard(exchID, ExchangeID);
			msg += "&data2=" +ExchangeID +"&data3=" +(string)owner;
		}
	}

	// Talk to PHP script and check comms is okay then activate the exchange
	postMessage(msg);
	userToPayKey = llGetOwner();
	psys(userToPayKey);
	llMessageLinked(LINK_SET, 1, "CMD_INIT|" +PASSWORD +"|" +(string)((integer)(VERSION*100)) +"|" +(string)RSTATE +"|" +ExchangeID +"|" +(string)joomlaID +"|" +phpBASEURL +"|" +(string)useBeta + "|" + fontName, "");
	llSetTimerEvent(60);
}

postMessage(string msg)
{
	debug("postMessage: " + msg);

	if (msg != "")
	{
		farmHTTP = llHTTPRequest(phpBASEURL, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded", HTTP_BODY_MAXLENGTH, 16384], msg);
	}
}

messageObj(key objId, string msg)
{
	list check = llGetObjectDetails(objId, [OBJECT_NAME]);

	if (llList2String(check, 0) != "")
	{
		osMessageObject(objId, msg);
	}
}

psys(key k)
{
	llParticleSystem(
				[
					PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
					PSYS_SRC_BURST_RADIUS,1,
					PSYS_SRC_ANGLE_BEGIN,0,
					PSYS_SRC_ANGLE_END,0,
					PSYS_SRC_TARGET_KEY, (key) k,
					PSYS_PART_START_COLOR,GREEN,
					PSYS_PART_END_COLOR,YELLOW,

					PSYS_PART_START_ALPHA,.5,
					PSYS_PART_END_ALPHA,0,
					PSYS_PART_START_GLOW,0,
					PSYS_PART_END_GLOW,0,
					PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
					PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,

					PSYS_PART_START_SCALE,<0.100000,0.100000,0.000000>,
					PSYS_PART_END_SCALE,<1.000000,1.000000,0.000000>,
					PSYS_SRC_TEXTURE,"",
					PSYS_SRC_MAX_AGE,2,
					PSYS_PART_MAX_AGE,5,
					PSYS_SRC_BURST_RATE, 10,
					PSYS_SRC_BURST_PART_COUNT, 30,
					PSYS_SRC_ACCEL,<0.000000,0.000000,0.000000>,
					PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
					PSYS_SRC_BURST_SPEED_MIN, 0.1,
					PSYS_SRC_BURST_SPEED_MAX, 1.,
					PSYS_PART_FLAGS,
						0 |
						PSYS_PART_EMISSIVE_MASK |
						PSYS_PART_TARGET_POS_MASK|
						PSYS_PART_INTERP_COLOR_MASK |
						PSYS_PART_INTERP_SCALE_MASK
				]);
}

string qsFixPrecision(float input, integer precision)
{
	precision = precision - 7 - (precision < 1);

	if (precision < 0)
	{
		return llGetSubString((string)input, 0, precision);
	}
	else
	{
		return (string)input;
	}
}

string WrapText(string pcText, integer piWidth)
{
	list     laLines  = [];
	integer  liIndex;
	integer  liKeep;  // Specifies if we keep the char pointed at or not
	integer  liLen    = llStringLength(pcText);
	list     llSearch = [" ", "\n"];

	while (liLen > 0)
	{
		liIndex = piWidth;

		if (!(liKeep = (liLen <= piWidth)))
		{
			while ((liIndex >= 0) && (-1 == llListFindList(llSearch, (list)llGetSubString(pcText, liIndex, liIndex))))
				--liIndex;

			if (liIndex <= 0)
			{
				liIndex = piWidth;
				liKeep = 1;
			}
		}

		laLines += llGetSubString(pcText, 0, liIndex - 1);
		pcText = llDeleteSubString(pcText, 0, liIndex - liKeep);
		liLen -= (1 + liIndex - liKeep);
	}

	return llDumpList2String(laLines,"\n");
}

incSoldTally()
{
	integer i;
	integer count;
	integer day = llList2Integer(llParseString2List(llGetDate(), ["-"], []), 2);

	if (day == lastDay)
	{
		// still same day so add to sales for today
		i = llList2Integer(soldTally, day);
		i++;
		soldTally = llListReplaceList(soldTally, [i], day, day);
	}
	else
	{
		// new day so update 'lastDay' and record as a new days sales
		lastDay = day;

		// Check if a new month, if so clear all values
		if (day == 1)
		{
			soldTally = [];
		}

		// Record first sale of the day
		soldTally = llListReplaceList(soldTally, [1], day, day);
	}

	totalSold = 0;
	count = llGetListLength(soldTally);

	for (i = 0; i < count; i++)
	{
		totalSold += llList2Integer(soldTally, i);
	}

	// update notecard
	saveTally();

	// Now send a message to the comms script so database on server gets updated
	llMessageLinked(LINK_SET, 1, "SOLD_UPDATE|" + (string)totalSold +"|", "");
	debug("=== incSoldTally called ===\n Total sold=" +(string)totalSold);
}

incPurchasedTally()
{
	integer i;
	integer count;
	integer day = llList2Integer(llParseString2List(llGetDate(), ["-"], []), 2);

	if (day == lastDay)
	{
		// still same day so add to purchase for today
		i = llList2Integer(purchaseTally, day);
		i++;
		purchaseTally = llListReplaceList(purchaseTally, [i], day, day);
	}
	else
	{
		// new day so update 'lastDay' and record as a new days purchases
		lastDay = day;

		// Check if a new month, if so clear all values
		if (day == 1)
		{
			purchaseTally = [];
		}

		// Record first purchase of the day
		purchaseTally = llListReplaceList(purchaseTally, [1], day, day);
	}

	totalPurchased = 0;
	count = llGetListLength(soldTally);

	for (i = 0; i < count; i++)
	{
		totalPurchased += llList2Integer(purchaseTally, i);
	}

	// update notecard
	saveTally();

	// Now send a message to the comms script so database on server gets updated
	llMessageLinked(LINK_SET, 1, "PURCHASE_UPDATE|" + (string)totalPurchased +"|", "");
	debug("=== incPurchasedTally called ===\n Total purchased=" +(string)totalPurchased);
}

saveTally()
{
	if (llGetInventoryType(tallyNC) == INVENTORY_NOTECARD)
	{
		llRemoveInventory(tallyNC);
	}

	string output = llDumpList2String(soldTally, "|");
	output += "\n" + llDumpList2String(purchaseTally, "|");
	debug("saveTally: " + output);
	osMakeNotecard(tallyNC, output);
}

loadTally()
{
	if (llGetInventoryType(tallyNC) == INVENTORY_NOTECARD)
	{
		list values = [];
		soldTally = [];
		purchaseTally = [];
		list lines = llParseStringKeepNulls(osGetNotecard(tallyNC), ["\n"], []);
		soldTally = llList2List(lines, 0, 0);
		purchaseTally = llList2List(lines, 1, 1);
		debug("loadTally:" +llDumpList2String(soldTally, "|") +"\n" +llDumpList2String(purchaseTally, "|"));
	}
	else
	{
		saveTally();
	}
}

broadcast_data()
{
	/*
	 // Send data to comms script
	 string cmdList = "EXCH_VALUES|" +(string)((integer)(VERSION*100)) +"|" +(string)RSTATE +"|" +ExchangeID +"|" +exchangeType +"|" +(string)offset +"|" +(string)allowRegister +"|" +farmName +"|" +(string)accessMode +"|" +(string)opMode +"|" +joomlaID +"|" +farmDescription;
	 llMessageLinked(LINK_SET, 1, cmdList, "");
	 postMessage("task=chkuser&data1=" + (string)owner);
	*/
}

idleScreen(string msg)
{
	if (farmDescription == "")
	{
		messageScreen(msg);
	}
	else
	{
		messageScreen(WrapText(farmDescription, 55));
	}

	lastPoll = llGetUnixTime();
	postMessage("task=imageuser&data1=" +owner);
}

doTouch(key toucher)
{
	userToPayKey = toucher;

	if ((status == "waitFirstTouch") || ( farmName == "*"))
	{
		if (useCollectiveID == TRUE)
		{
			postMessage("task=chkcollective&data1=" + owner + "&data2=" + collectiveID);
		}

		if (userToPayKey == owner)
		{
			status = "";
			doReset();
		}
	}
	else
	{
		if (useCollectiveID == TRUE)
		{
			postMessage("task=chkcollective&data1=" + owner + "&data2=" + collectiveID);
		}

		// Owner always allowed!
		if (userToPayKey != owner)
		{
			// 0=Everyone, 1=Group, 2=Local residents, 3=Collective
			if (accessMode != 0)
			{
				if (accessMode == 1)
				{
					if (llDetectedGroup(0) == FALSE)
					{
						llRegionSayTo(userToPayKey, 0, TXT_GROUP_ONLY);

						return;
					}
				}
				else if (accessMode == 2)
				{
					if (osGetAvatarHomeURI(userToPayKey) != osGetGridHomeURI())
					{
						llRegionSayTo(userToPayKey, 0, TXT_LOCAL_ONLY);

						return;
					}
				}
				else
				{
					if (userToPayCollective != collectiveID)
					{
						// check member of collective failed
						llRegionSayTo(userToPayKey, 0, TXT_COLLECTIVE_ONLY);
						return;
					}

				}
			}
		}
		
		// If they get here they are allowed to use the board
		// First check if it was the navigation buttons touched
		if ((llDetectedLinkNumber(0) == getLinkNum("buttons_display")) && (screenState = "showPrices"))
		{
			if ((screenListOffset + screenCapacity) > llGetListLength(items)) screenListOffset = 0;

			integer face = llDetectedTouchFace(0);
			if (face == 2)
			{
				// go back;
				if (screenListOffset -screenCapacity >=0)
				{
					screenListOffset -= screenCapacity;
				}
				else
				{
					screenListOffset = 0;
				}

				showPrices();
			}
			else if (face == 4)
			{
				// go forward
				if (screenListOffset +screenCapacity <= llGetListLength(items))
				{
					screenListOffset += screenCapacity;
				}
				else
				{
					screenListOffset = llGetListLength(items) - screenCapacity;
				}

				showPrices();
			}
			else if (face == 0)
			{
				// Home
				screenListOffset = 0;
				showPrices();
			}
			return;

		}
		// If not, show the menu
		list opts = [];
		screenListOffset = 0;
		status = "";

		if (quinActive == FALSE)
		{
			opts += [TXT_ACTIVATE, TXT_CLOSE];
		}
		else
		{
			if (userToPayKey == owner)
			{
				opts += [TXT_OPTIONS, TXT_RESET, TXT_CLOSE, TXT_PRICES, TXT_COINS, TXT_POINTS, TXT_SELL, TXT_BUY, TXT_LANGUAGE];
			}
			else
			{
				opts += [TXT_COINS, TXT_POINTS, TXT_CLOSE, TXT_SELL, TXT_BUY, TXT_PRICES, TXT_LANGUAGE];
			}
		}

		startListen();
		llDialog(userToPayKey, TXT_SELECT, opts, chan(llGetKey()));
		llSetTimerEvent(120);
	}
}

doReset()
{
	llSetLinkColor(LINK_SET, <0,0,0>, FACE);
	llSetLinkTexture(LINK_SET, "BLANK", FACE);
	llSetText(TXT_RESET, YELLOW, 1.0);

	// Clear the saved exchange ID to force re-generation
	if (llGetInventoryType(exchID) == INVENTORY_NOTECARD)
	{
		llRemoveInventory(exchID);
	}

	// Clear the saved farm description
	if (llGetInventoryType(settingsNC) == INVENTORY_NOTECARD)
	{
		llRemoveInventory(settingsNC);
	}

	farmDescription = "";
	llSleep(0.5);
	ExchangeID = "*";
	osMakeNotecard(exchID, ExchangeID);

	if (llGetInventoryType(tallyNC) == INVENTORY_NOTECARD)
	{
		llRemoveInventory(tallyNC);
	}

	status = "";
	llSetObjectDesc("");
	llResetScript();
}


// --- STATE DEFAULT -- //

default
{

	on_rez(integer n)
	{
		llSetText(TXT_ENABLE, YELLOW, 1.0);
		status = "waitFirstTouch";
		owner = llGetOwner();
	}

	state_entry()
	{
		// Don't run this script in updaters etc
		if (osRegexIsMatch(llGetObjectName(), "(Update|Rezz)+"))
		{
			string me = llGetScriptName();
			llSetScriptState(me, FALSE);
			llSleep(0.5);
		}
		else
		{
			llSetText("...", WHITE, 1.0);
			loadConfig();
			loadLanguage(languageCode);
			weekdays = [TXT_THU, TXT_FRI, TXT_SAT, TXT_SUN, TXT_MON, TXT_TUE, TXT_WED];
			loadStock();
			loadTally();
			owner = llGetOwner();
			ownKey = llGetKey();
			llMessageLinked(LINK_SET, 1, "LANG_TOPTEN|" +TXT_NAME +"|" +TXT_SCORE +"|" +TXT_TOPTEN +"|" +languageCode, "");
			llMessageLinked(LINK_SET, 1, "LANG_ACTIVITY|"  +TXT_RECENT_ACTIVITY +"|" +TXT_ACTIVITY +"|" +TXT_RANK, "");
			setImage();
			modeNames = [TXT_EVERYONE, TXT_GROUP, TXT_LOCAL, TXT_COLLECTIVE];
			idleScreen(TXT_CLICK_FOR_MENU);
			llListen(FARM_CHANNEL, "", "", "");
			lastPoll = llGetUnixTime();
			postMessage("task=chkuser&data1=" + (string)owner);
			activate();
		}
	}

	changed(integer change)
	{
		debug("change: "+(string)change +"  status: "+status);
		if (change & CHANGED_INVENTORY)
		{
			loadConfig();
			loadLanguage(languageCode);
			loadStock();
			setImage();
			llMessageLinked(LINK_SET, 1, "CMD_INIT|" +PASSWORD +"|" +(string)((integer)(VERSION*100)) +"|" +(string)RSTATE +"|" +ExchangeID +"|" +(string)joomlaID +"|" +phpBASEURL +"|" +(string)useBeta + "|" + fontName, "");
		}

		if (change & CHANGED_REGION_START)
		{
			loadStock();
		}

		if (change & CHANGED_OWNER)
		{
			doReset();
		}
	}

	touch_start(integer n)
	{
		doTouch(llDetectedKey(0));
	}

	timer()
	{
		if (status == "waitNewItem")
		{
			llRegionSayTo(userToPayKey, 0, TXT_NOT_FOUND_INV);
			messageScreen(lookingFor + "\n \n" +TXT_NOT_FOUND_INV);
			status = "";
			llSetTimerEvent(30);
		}
		else if (status == "waitDieResponse")
		{
			// No valid reply after sending DIE command
			llRegionSayTo(userToPayKey, 0, TXT_BAD_PASSWORD);
			status = "";
			llSetTimerEvent(30);
		}
		else if (status == "verifying-soldpnt")
		{
			// Timed out waiting for response from server so rez back the product as payment to user failed
			llRegionSayTo(userToPayKey, 0, TXT_COMMS_ERROR);
			string what = "SF " + lookingFor;
			llMessageLinked(LINK_SET, 0, "REZ_PRODUCT|" +PASSWORD +"|" +(string)userToPayKey +"|" +what, NULL_KEY);
			status = "";
			llSetTimerEvent(30);

		}
		else if ((llGetUnixTime() -lastPoll) > 900)  // Check around every 15 minutes if profile cover changed
		{
			lastPoll = llGetUnixTime();
			postMessage("task=imageuser&data1=" +owner); llMessageLinked(LINK_SET, 1, "CMD_INIT|" +PASSWORD +"|" +(string)((integer)(VERSION*100)) +"|" +(string)RSTATE +"|" +ExchangeID +"|" +(string)joomlaID +"|" +phpBASEURL +"|" +(string)useBeta + "|" + fontName, "");
	llSetTimerEvent(60);
		}
		else
		{
			idleScreen(TXT_CLICK_FOR_MENU);
			checkListen(FALSE);
			llSetTimerEvent(180);

			if (slaveState == 0) llMessageLinked(LINK_SET, 0, "CMD_INIT", PASSWORD);

			if (joomlaID == 0)
			{
				postMessage("task=chkuser&data1=" + (string)owner);
				debug("Asking for website user info...");
			}
		}
	}

	dataserver(key id, string m)
	{
		debug("dataserver: " + m);
		list tk = llParseStringKeepNulls(m, ["|"], []);
		string cmd = llList2String(tk,0);
		integer i;

		if (llList2String(tk,1) != PASSWORD)
		{
			//llRegionSayTo(userToPayKey, 0, TXT_BAD_PASSWORD);

			return;
		}

		// For updates
		if (cmd == "VERSION-CHECK")
		{
			string answer = "VERSION-REPLY|" + PASSWORD + "|";
			answer += (string)llGetKey() + "|" + (string)((integer)(VERSION*100)) + "|";
			integer len = llGetInventoryNumber(INVENTORY_OBJECT);

			while (len--)
			{
				answer += llGetInventoryName(INVENTORY_OBJECT, len) + ",";
			}

			len = llGetInventoryNumber(INVENTORY_SCRIPT);
			string me = llGetScriptName();

			while (len--)
			{
				string item = llGetInventoryName(INVENTORY_SCRIPT, len);

				if (item != me)
				{
					answer += item + ",";
				}
			}

			answer += me;
			messageObj(llList2Key(tk, 2), answer);
			//Send a message to other prim with script
			messageObj(llGetLinkKey(3), "VERSION-CHECK|" + PASSWORD + "|" + llList2String(tk, 2));
		}
		else if (cmd == "DO-UPDATE")
		{
			if (llGetOwnerKey(id) != llGetOwner())
			{
				llSay(0, TXT_ERROR_UPDATE);

				return;
			}

			string me = llGetScriptName();
			string sRemoveItems = llList2String(tk, 3);
			list lRemoveItems = llParseString2List(sRemoveItems, [","], []);
			integer delSelf = FALSE;
			integer d = llGetListLength(lRemoveItems);

			while (d--)
			{
				string item = llList2String(lRemoveItems, d);

				if (item == me)
				{
					delSelf = TRUE;
				}
				else if (llGetInventoryType(item) != INVENTORY_NONE)
				{
					llRemoveInventory(item);
				}
			}

			integer pin = llRound(llFrand(1000.0));
			llSetRemoteScriptAccessPin(pin);
			messageObj(llList2Key(tk, 2), "DO-UPDATE-REPLY|"+PASSWORD+"|"+(string)llGetKey()+"|"+(string)pin+"|"+sRemoveItems);

			if (delSelf)
			{
				llRemoveInventory(me);
			}

			llSleep(10.0);
			llResetScript();
		}
		else
		{
			// A product has responded to DIE so now credit user
			for (i=0; i < llGetListLength(items); i++)
			{
				if (llToUpper(llList2String(items,i)) == cmd)
				{
					string stuff =  llGetSubString(lookingFor, 3, llStringLength(lookingFor));
					psys(NULL_KEY);
					postMessage("task=sold&data1=" + (string)userToPayKey + "&data2=Sold_" + " " + stuff + "&data3=" + itemPrice);
					status = "verifying-soldpnt";
					llSetTimerEvent(5);

					return;
				}
			}
		}
	}

	listen(integer c, string nm, key id, string m)
	{
		debug("LISTEN: MSG=" +m +" (status= " +status +")");
		if (c != FARM_CHANNEL)
		{
			if (m == TXT_CLOSE)
			{
				llListenRemove(listener);
				listener = -1;

				return;
			}
			else if (m == TXT_SELL)
			{
				llSetColor(GREEN, 4);
				status = "SellGoods";
				lookingFor = "";
				postMessage("task=getmenu&data1=" + (string)id +"&data2=" +marketType);
			}
			else if (m == TXT_BUY)
			{
				llSetColor(GREEN, 4);
				status = "BuyGoods";
				postMessage("task=getmenu&data1=" + (string)id +"&data2=" +marketType);

				return;
				{
					if (llGetInventoryType("poster") == INVENTORY_TEXTURE)
					{
						llSetLinkTexture(3, "poster", FACE);
					}
					else
					{
						llSetLinkTexture(3, "cdf521e1-f3d7-4e3b-ab32-34c3b268cba9", FACE);
					}
					
					slaveState = 0;
				}	}
			else if (m == TXT_PRICES)
			{
				llSetColor(GREEN, 4);
				llListenRemove(listener);
				listener = -1;
				prices = [];
				status = "priceReq";
				postMessage("task=getmenu&data1=" + (string)id +"&data2=" +marketType);

				return;
			}
			else if (m == TXT_ACTIVATE)
			{
				activate();
			}
			else if (m == TXT_OPTIONS)
			{
				list opts = [TXT_EX_NAME, TXT_FARM_DESCRIPTION, TXT_EX_TYPE, TXT_CLOSE, TXT_ACCESS_LEVEL, TXT_OPERATION_MODE];

				if (useDarkMode == TRUE)
				{
					opts += ["-"+TXT_DARK_MODE]; 
				}
				else
				{
					opts += ["+"+TXT_DARK_MODE];
				}

				startListen();
				string tmpStr = "\n" + TXT_ACCESS_LEVEL +": " + llList2String(modeNames, accessMode) + "\t" + TXT_OPERATION_MODE + ": ";
				
				if (opMode == 1)
				{
					tmpStr += TXT_ALWAYS_SELL;
				}
				else
				{
					tmpStr += TXT_BUY_SELL;
				}

				tmpStr += "\n" +TXT_EX_TYPE+": " +exchangeType +"\t" +TXT_DARK_MODE +": ";
				
				if (useDarkMode == TRUE)
				{
					tmpStr +=TXT_ON;
				}
				else
				{
					tmpStr += TXT_OFF;
				}

				llDialog(userToPayKey, "\n" + TXT_SELECT + tmpStr , opts, chan(llGetKey()));
				llSetTimerEvent(300);
			}
			else if (m == TXT_ACCESS_LEVEL)
			{
				list opts = [TXT_EVERYONE, TXT_GROUP, TXT_LOCAL, TXT_COLLECTIVE, TXT_CLOSE];
				startListen();
				string tmpStr = "\n" + TXT_ACCESS_LEVEL +": " + llList2String(modeNames, accessMode);
				llDialog(userToPayKey, "\n" + TXT_SELECT + tmpStr , opts, chan(llGetKey()));
				llSetTimerEvent(300);
			}
			else if (m == TXT_EX_NAME)
			{
				startListen();
				llTextBox(userToPayKey, TXT_EX_NAME, chan(llGetKey()));
				status = "getName";
				llSetTimerEvent(300);
			}
			else if (m == TXT_FARM_DESCRIPTION)
			{
				startListen();
				llTextBox(userToPayKey, TXT_FARM_DESCRIPTION +"\n" +farmDescription, chan(llGetKey()));
				status = "getDesc";
				llSetTimerEvent(300);
			}
			else if (m == TXT_EX_TYPE)
			{
			   list opts = [TXT_GROCERY, TXT_BAZAAR, TXT_CONCESSIONS, TXT_HARDWARE, TXT_GOREAN, TXT_CLOSE];
				startListen();
				llDialog(userToPayKey, "\n" + TXT_SELECT , opts, chan(llGetKey()));
				llSetTimerEvent(300);
			}
			else if ((m == "+"+TXT_DARK_MODE) || (m == "-"+TXT_DARK_MODE))
			{
				useDarkMode = !useDarkMode;

				if (useDarkMode == TRUE)
				{
					llOwnerSay(TXT_DARK_MODE +" " +TXT_ON);
				}
				else
				{
					llOwnerSay(TXT_DARK_MODE +" " +TXT_OFF);
				}
				
				idleScreen(TXT_READY +"...");
			}
			else if (m == TXT_GROCERY)
			{
				exchangeType = "grocery";
				setMarket(exchangeType);
				idleScreen(TXT_READY +"...");
				llOwnerSay(TXT_EX_TYPE + ": " + TXT_GROCERY);
			}
			else if (m == TXT_HARDWARE)
			{
				exchangeType = "hardware";
				setMarket(exchangeType);
				idleScreen(TXT_READY +"...");
				llOwnerSay(TXT_EX_TYPE + ": " + TXT_HARDWARE);
			}
			else if (m == TXT_CONCESSIONS)
			{
				exchangeType = "concessions";
				setMarket(exchangeType);
				idleScreen(TXT_READY +"...");
				llOwnerSay(TXT_EX_TYPE + ": " + TXT_CONCESSIONS);
			}
			else if (m == TXT_BAZAAR)
			{
				exchangeType = "bazaar";
				setMarket(exchangeType);
				idleScreen(TXT_READY +"...");
				llOwnerSay(TXT_EX_TYPE + ": " + TXT_BAZAAR);
			}
			else if (m == TXT_GOREAN)
			{
				exchangeType = "gorean";
				setMarket(exchangeType);
				idleScreen(TXT_READY +"...");
				llOwnerSay(TXT_EX_TYPE + ": " + TXT_GOREAN);
			}
			else if (m == TXT_EVERYONE)
			{
				accessMode = 0;
				llOwnerSay(TXT_ACCESS_LEVEL + ": " + TXT_EVERYONE);
			}
			else if (m == TXT_GROUP)
			{
				accessMode = 1;
				llOwnerSay(TXT_ACCESS_LEVEL + ": " + TXT_GROUP);
			}
			else if (m == TXT_LOCAL)
			{
				accessMode = 2;
				llOwnerSay(TXT_ACCESS_LEVEL + ": " + TXT_LOCAL);
			}
			else if (m == TXT_COLLECTIVE)
			{
				accessMode = 3;
				llOwnerSay(TXT_ACCESS_LEVEL + ": " + TXT_COLLECTIVE);
			}
			else if (m == TXT_OPERATION_MODE)
			{
				list opts = [TXT_ALWAYS_SELL, TXT_BUY_SELL, TXT_CLOSE];
				startListen();
				llDialog(userToPayKey, "\n" + TXT_SELECT , opts, chan(llGetKey()));
				llSetTimerEvent(300);
			}
			else if (m == TXT_ALWAYS_SELL)
			{
				opMode = 1;
				stockItems = [];
				showPrices();
				llOwnerSay(TXT_OPERATION_MODE + ": " + TXT_ALWAYS_SELL);
			}
			else if (m == TXT_BUY_SELL)
			{
				opMode = 0;
				loadStock();
				showPrices();
				llOwnerSay(TXT_OPERATION_MODE + ": " + TXT_BUY_SELL);
			}
			else if (m == TXT_POINTS)
			{
				llSetColor(GREEN, 4);
				llMessageLinked(LINK_SET, 1, "CMD_CLEAR", "");
				llRegionSayTo(userToPayKey, 0, TXT_CHECKING_POINTS);loadStock();
				status = "pointsQuery";
				postMessage("task=getxp&data1=" + (string)id);
				userToPayKey = id;
			}
			else if (m == TXT_COINS)
			{
				llSetColor(GREEN, 4);
				llRegionSayTo(userToPayKey, 0, TXT_CHECKING_POINTS);
				status = "coinsQuery";
				postMessage("task=coins&data1=" + (string)id);
			}
			else if (m == TXT_SEARCH)
			{
				// Ask what to search for;
				llTextBox(userToPayKey, "\n" + TXT_SEARCH_ITEM, chan(llGetKey()));
				status = "searchQuery";
			}
			else if (m == TXT_LANGUAGE)
			{
				llMessageLinked(LINK_THIS, 1, "MENU_LANGS|" + languageCode +"|" +SUFFIX, id);
			}
			else if (m == TXT_RESET)
			{
				llMessageLinked(LINK_THIS, 1, "RESET", id);
			}
			else if (m == ">>")
			{
				startOffset += 9;
				if (status == "SellGoods")
				{
					multiPageMenu(id, TXT_SELL, sellItems);
				}
				else
				{
					multiPageMenu(id, TXT_BUY, items);
				}
			}
			// Run out of buttons, check status
			else if (status == "getName")
			{
				if (m != "")
				{
					farmName = m;

					if (useBeta == TRUE)
					{
						farmName += " (BETA)";
					}
					
					llMessageLinked(LINK_THIS, 1, "FARM_NAME|" + farmName, "");
					idleScreen(TXT_READY +"...");
					status = "";
				}
			}
			else if (status == "getDesc")
			{
				farmDescription = m;
				status = "";

				if (llGetInventoryType(settingsNC) == INVENTORY_NOTECARD)
				{
					llRemoveInventory(settingsNC);
					llSleep(0.5);
				}

				osMakeNotecard(settingsNC, farmDescription);
				llMessageLinked(LINK_THIS, 1, "FARM_DESC|" + farmDescription, "");
				idleScreen(TXT_READY +"...");
			}
			else if (status == "SellGoods")
			{
				string what = llGetSubString(m, 4,-1);
				integer idx = llListFindList(items, m);

				if (idx>=0)
				{
					itemPrice  = llList2String(prices, idx);
					lookingFor = "SF " + llList2String(items,idx);
					llSensor(lookingFor, "",SCRIPTED,  SENSOR_DISTANCE, PI);
				}

				status = "WaitItem";
			}
			else if (status == "BuyGoods")
			{
				llSetColor(GREEN, 4);
				integer idx = llListFindList(items, m);
				itemPrice = llList2String(prices, idx);
				lookingFor = m;

				// Check they have enough points
				status = "balCheck";
				postMessage("task=coins&data1=" + (string)userToPayKey);
			}
			else if (status == "WaitItem")
			{
				debug("status = WaitItem");
			}
			else if (status == "searchQuery")
			{
				// Create list of matching items for search term
				list searchItems = [];
				list searchPrices = [];
				integer index;
				integer i;
				string itemName;
				integer length = llGetListLength(items);

				for (i = 0; i < length; i++)
				{
					itemName = llList2String(items, i);
					// for search, set everything to lowercase so user doesn't need to worry!  E.G Apple and apple will both work
					index = llSubStringIndex(llToLower(itemName), llToLower(m));

					if (index != -1)
					{
						llOwnerSay("I=" + (string)i + "   " +itemName + " PRICE: " + llList2String(prices, i));
						searchItems += [itemName];
						searchPrices += llList2String(prices, i);
					}
				}
				if (llGetListLength(searchItems) >0)
				{
					items = [] + searchItems;
					prices = [] + searchPrices;
					showPrices();
					status = "BuyGoods";
					startOffset = 0;
					multiPageMenu(userToPayKey, TXT_BUY, items);
				}
				else
				{
					status = "";
					llOwnerSay(TXT_SEARCH_FAIL +": " + m);
				}
			}
			saveToDesc();
		}
		else
		{
			// FARM_CHANNEL message ?
			list tk = llParseString2List(m, ["|"], []);
			string cmd = llList2String(tk, 0);

			if (llList2String(tk, 1) == PASSWORD)
			{
				if (cmd == "INV_QRY")
				{
					string object = "SF " + llList2String(tk, 3);

					if (llGetInventoryType(object) == INVENTORY_OBJECT)
					{
						llRegionSay(FARM_CHANNEL, "INV_AVAIL|" +PASSWORD +"|" +(string)ownKey +"|" +object);
					}
				}
				else if (cmd == "INV_REQ")
				{
					// Belt and braces check we still have the item!
					string object = llList2String(tk, 3);

					if ((llGetInventoryType(object) == INVENTORY_OBJECT) && (llList2Key(tk, 2) == ownKey))
					{
						llGiveInventory(id, object);
					}
				}
			}
		}
	}

	sensor(integer n)
	{
		if (lookingFor == "all")
		{
			sellItems = [];

			while (n--)
			{
				string name = llGetSubString(llKey2Name(llDetectedKey(n)), 3, -1);

				if (llListFindList(items, [name]) != -1 && llListFindList(sellItems, [name]) == -1)
				{
					sellItems += [name];
				}
			}
			if (sellItems == [])
			{
				if (sellItems == [])
				{
					if (lookingFor != "")
					{
						llRegionSayTo(userToPayKey, 0, TXT_NOT_FOUND);
					}
				}

				checkListen(TRUE);
			}
			else
			{
				status = "SellGoods";
				multiPageMenu(userToPayKey, TXT_SELL, sellItems);
			}

			return;
		}

		//get first product that isn't already selected and has enough percentage
		integer c;
		key ready_obj = NULL_KEY;

		for (c = 0; ready_obj == NULL_KEY && c < n; c++)
		{
			key obj = llDetectedKey(c);
			list stats = llParseString2List(llList2String(llGetObjectDetails(obj,[OBJECT_DESC]),0), [";"], []);
			integer have_percent = llList2Integer(stats, 1);

			// have_percent == 0 for backwards compatibility with old items
			if (llListFindList(sellItems, [obj]) == -1 && (have_percent == 100 || have_percent == 0))
			{
				ready_obj = llDetectedKey(c);
			}
		}

		if (ready_obj == NULL_KEY)
		{
			llRegionSayTo(userToPayKey, 0, lookingFor + " " + TXT_NOT_FOUND100);
		}
		else
		{
			sellItems += [ready_obj];
			llRegionSayTo(userToPayKey, 0, TXT_FOUND +"  " +lookingFor + ", " + TXT_EMPTYING);
			
			// Set up a timeout in case product is 'broken'
			status = "waitDieResponse";
			llSetTimerEvent(5);
			messageObj(ready_obj, "DIE|"+llGetKey());
		}
	}

	no_sensor()
	{
		if (lookingFor == "all" && sellItems == [])
		{
		  if (lookingFor != "") llRegionSayTo(userToPayKey, 0, TXT_NOT_FOUND);
		}
		else
		{
			llRegionSayTo(userToPayKey, 0, lookingFor +" " + TXT_NOT_FOUND_ITEM);
		}
		checkListen(TRUE);
	}

	object_rez(key id)
	{
		llSleep(0.5);
		messageObj(id, "INIT|" +PASSWORD);
	}

	link_message(integer sender_num, integer num, string msg, key id)
	{
		debug("link_message: " + msg + " From:" + (string)sender_num);
		list tk = llParseString2List(msg, ["|"], []);
		string cmd = llList2String(tk, 0);

		if (cmd == "TOPTEN_ERROR")
		{
			if (llGetInventoryType("poster") == INVENTORY_TEXTURE)
			{
				llSetLinkTexture(3, "poster", FACE);
			}
			else
			{
				llSetLinkTexture(3, "cdf521e1-f3d7-4e3b-ab32-34c3b268cba9", FACE);
			}

			slaveState = 0;
		}
		else if (cmd == "TOPTEN_OK")
		{
			slaveState = 1;
		}
		else if (cmd == "SET-LANG")
		{
			languageCode = llList2String(tk, 1);
			loadLanguage(languageCode);
			idleScreen(TXT_READY +"...");
			 llMessageLinked(LINK_SET, 1, "LANG_TOPTEN|" +TXT_NAME +"|" +TXT_SCORE +"|" +TXT_TOPTEN +"|" +languageCode, "");
			llMessageLinked(LINK_SET, 1, "LANG_ACTIVITY|"  +TXT_RECENT_ACTIVITY +"|" +TXT_ACTIVITY +"|" +TXT_RANK, "");
			saveToDesc();
			llSleep(0.5);
			llMessageLinked(LINK_SET, 1, "CMD_REFRESH|", "");
		}
		else if (cmd == "PRODUCT_FOUND")
		{
			//status = "";
			llRegionSayTo(userToPayKey, 0, TXT_NOW_AVAILABLE + ": " +lookingFor);
			showPrices();
			llSetTimerEvent(60.0);
		}
		else if (cmd == "NO_PRODUCT")
		{
			llRegionSayTo(userToPayKey, 0, TXT_NOT_FOUND_INV);
			messageScreen(lookingFor + "\n \n  " +TXT_NOT_FOUND_INV);
			llSetTimerEvent(60);
		}
		else if (cmd == "VERINFO")
		{
			activeVer = num;
			integer vers = llRound(VERSION * 100);
			if (activeVer > vers) outOfDate = TRUE; else outOfDate = FALSE;
		}
		else if (cmd == "EXCH_RESEND")
		{
			broadcast_data();
		}
		else if (cmd == "WAS_TOUCHED")
		{
			// See if the secondary_display or display_board prim was touched
			if (getLinkNum("secondary_display") == num) doTouch(id);
			 else if (getLinkNum("display_board") == num) doTouch(id);
		}
		else if (cmd == "RESET")
		{
			llSetText("-- RESET --", YELLOW, 1.0);
			messageScreen("-- RESET --");
			// Reset stats and update the notecard
			totalSold = 0;
			totalPurchased = 0;
			lastDay = 0;
			soldTally     = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			purchaseTally = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			saveTally();
			llSetObjectDesc("");
			// Remove data from VivoSim server
			// First check to see if the is an ID for this exchange, if * try refreshing from notecard
			if (ExchangeID == "*") loadConfig();
			if (ExchangeID != "*")
			{
				// we have an ID for this exchange so requst to delete it from VivoSim server
				postMessage("task=delExch&data1=" + (string)ExchangeID);
				status = "waitExchDelConfirm";
			}
			else
			{
				doReset();
			}
		}
	}

	http_response(key request_id, integer HStatus, list metadata, string body)
	{
		debug("http_response: " +"  body= "+body);

		if (request_id == farmHTTP)
		{
			llSetColor(WHITE, 4);
			list tok = llJson2List(body);
			string cmd = llList2String(tok, 0);

			if (cmd == "2017053016xR")
			{
				status = "";
				quinActive = TRUE;
				llSetLinkColor(LINK_SET, <1,1,1>, FACE);
				idleScreen(TXT_CLICK_FOR_MENU);
				llMessageLinked(LINK_SET, 1, "CMD_INIT|" +PASSWORD +"|" +(string)((integer)(VERSION*100)) +"|" +(string)RSTATE +"|" +ExchangeID +"|" +(string)joomlaID +"|" +phpBASEURL +"|" +(string)useBeta, "");
				llSetText("", ZERO_VECTOR, 0.0);
				llSleep(2.0);
				if (farmName == "*")
				{
					startListen();
					llTextBox(userToPayKey, TXT_EX_NAME, chan(llGetKey()));
					status = "getName";
					llSetTimerEvent(120);
				}
				else
				{
					postMessage("task=imageuser&data1=" +owner);
					idleScreen(TXT_READY +"...");
				}
			}
			else if (cmd == "USERINFO")
			{
				joomlaID = llList2Integer(tok, 1);
			}
			else if (cmd == "IMAGE")
			{
				if (useCollectiveID == FALSE)
				{
					profileCover = llList2String(tok, 1);

					if (profileCover == "INVALID-A")
					{
						profileCover = "";
					}

					setImage();
				}
				else
				{
					if ((profileCover = "") && (collectiveID !=""))
					{
						postMessage("task=chkcollective&data1=" +owner +"&data2=" +collectiveID);
					}
				}
				
			}
			else if (cmd == "MENU")
			{
				string dataString = (llList2String(tok, 1));

				if (dataString == "NOID")
				{
					llRegionSayTo(userToPayKey, 0, TXT_INFO_MSG1 + " " +REGURL +"\n");
					status = "";
				}
				else if (dataString == "READ-FAIL")
				{
					llRegionSayTo(userToPayKey, 0, TXT_BAD_PASSWORD +"\n");
					status = "";
				}
				else
				{
					list data = llParseString2List(llList2String(tok, 1), [";", "\n"], []);
					items = [];
					prices = [];
					integer i;
					integer j = llGetListLength(data);

					for( i = 0; i < j; i = i+2 )
					{
						items += llList2String(data, i);
						prices += llList2Integer(data, i+1);
					}

					if (status == "priceReq")
					{
						status = "";
						showPrices();
					}
					else if (status == "BuyGoods")
					{
						if (opMode == 0)
						{
							list newItems = [];
							list newPrices = [];

							// take out items not in stock
							integer count = llGetListLength(items);

							for (i=0; i < count; i++)
							{
								if (llListFindList(stockItems, ["SF " +llList2String(items, i)]) != -1)
								{
									newItems += [llList2String(items, i)];
									newPrices += [llList2Integer(prices, i)];
								}
							}
							items = [] + newItems;
								// Check if there is an ID for this Exchang
							prices = [] + newPrices;
						}
						startOffset = 0;
						multiPageMenu(userToPayKey, TXT_BUY, items);
					}
					else
					{
						startOffset = 0;
						lookingFor = "all";
						llSensor("", "", SCRIPTED, SENSOR_DISTANCE, PI);
					}
				}
			}
			else if (cmd == "SOLD")
			{
				if (llList2String(tok, 1) == "NOID")
				{
					llRegionSayTo(userToPayKey, 0, TXT_INFO_MSG1 + " " +REGURL +"\n");
					status = "";
				}
				else
				{
					if (status == "verifying-soldpnt")
					{
						llRegionSayTo(userToPayKey, 0, TXT_CREDITED + " " + llList2String(tok,3) + " " + TXT_COINS);
						llPlaySound("ching", 1.0);
						incPurchasedTally();
						llMessageLinked(LINK_SET, 1, "CMD_REFRESH", "");
						status = "";
						llRegionSay(FARM_CHANNEL, "COINCHK|" +PASSWORD +"|" +(string)userToPayKey);
						if (opMode == 0)
						{
							saveStock(lookingFor, CREDIT);
							setImage();
						}
						items = [];
						checkListen(TRUE);
						startListen();

						status = "SellGoods";
						postMessage("task=getmenu&data1=" + (string)userToPayKey +"&data2=" +marketType);

					}
					else if (status == "verifying-buypnt")
					{
						// Points deducted okay so give them item    "SF " + lookingFor
						psys(userToPayKey);
						llMessageLinked(LINK_SET, 1, "CMD_REFRESH", "");
						string what = "SF " + lookingFor;
						llMessageLinked(LINK_SET, 0, "REZ_PRODUCT|" +PASSWORD +"|" +(string)userToPayKey +"|" +what, NULL_KEY);
						llRegionSayTo(userToPayKey, 0, TXT_GIVE_PURCHASE + " " + lookingFor + ".\n" + TXT_CHARGED + " " + itemPrice + " " + TXT_COINS);
						llPlaySound("ching", 1.0);
						status = "";

						if (opMode == 0)
						{
							saveStock(what, DEBIT);
							setImage();
						}

						llRegionSay(FARM_CHANNEL, "COINCHK|" +PASSWORD +"|" +(string)userToPayKey);
						incSoldTally();
						status = "BuyGoods";

						postMessage("task=getmenu&data1=" + (string)userToPayKey +"&data2=" +marketType);
					}
				}
			}
			else if ((cmd == "XPTOTAL") || (cmd == "COINS"))
			{
				string tmpStr;

				if (status == "pointsQuery")
				{
					if (llList2String(tok, 1) == "NOID")
					{
						tmpStr = TXT_INFO_MSG1 +" " +REGURL +"\n";
					}
					else
					{
						// JSON at llList2String(tok, 3)
						// JSON is  {"current":{"id":2,"title":"Farm hand","points":50,"image":"https://vivosim.net/components/com_community/assets/badge_2.png","published":1,"progress":"0.00"}}
						list rankList = llJson2List(llList2String(llJson2List(llList2String(tok, 3)), 1));
						string userRank = llList2String(rankList, 3);
						string rankImage = llList2String(rankList, 7);
						tmpStr = TXT_YOU_HAVE +" " +(string)llList2String(tok,1) + " "+TXT_POINTS + "\n" + TXT_RANK + ": " +llList2String(rankList, 3);
						llMessageLinked(LINK_SET, 1, "CMD_SHOW_ACTIVITY|" +rankImage +"|" +userRank , userToPayKey);
					}

					llRegionSayTo(userToPayKey, 0, tmpStr);
				}
				else if (status == "coinsQuery")
				{
					if (llList2String(tok, 1) == "NONE")
					{
						tmpStr = TXT_INFO_MSG1 +" " +REGURL +"\n";
					}
					else
					{
						tmpStr = TXT_YOU_HAVE +" " +(string)llList2Integer(tok,1) +" " +TXT_COIN_SYMBOL;
					}

					llRegionSayTo(userToPayKey, 0, tmpStr);
				}
				else if (status == "balCheck")
				{
					integer pointsBal = llList2Integer(tok,1);
					integer cost = (integer)itemPrice;

					if ( (pointsBal - cost)  < 0)
					{
						llRegionSayTo(userToPayKey, 0, TXT_INSUFFICIENT_POINTS);
					}
					else
					{
						string what = "SF " + lookingFor;

						if (llGetInventoryType(what) != INVENTORY_OBJECT)
						{
							llRegionSayTo(userToPayKey, 0, TXT_NO_STOCK +" " +lookingFor +"\n" +TXT_CHECKING);
							llMessageLinked(LINK_SET, 0, "GET_PRODUCT|" +PASSWORD +"|" +what, NULL_KEY);
							messageScreen(TXT_NO_STOCK +" " +lookingFor +"\n \n  " +TXT_CHECKING);
							status = "waitNewItem";
							llSetTimerEvent(15);
						}
						else
						{
							// Deduct points then give them item if deduct went okay
							cost = cost * -1;
							postMessage("task=sold&data1=" + (string)userToPayKey + "&data2=Bought_" + lookingFor + "&data3=" + (string)cost);
							status = "verifying-buypnt";
						}
					}
				}
			}

			else if (cmd == "MEMBER")
			{
				// MEMBER|1|COLLECTIVENAME|VivoSim Beta|IMAGE|images\/cover\/group\/27\/d33f549ee28b1bc5d43cf661c7a42990.jpg
				userToPayCollective = llList2String(tok, 1);
				string collectiveName = llList2String(tok, 3);
				string collectiveImage = llList2String(tok, 5);
			
				if (collectiveName == "INVALID-C")
				{
					collectiveName = "";
					useCollectiveID = FALSE;
				}
				else
				{
					if(collectiveImage != "")
					{
						collectiveImage = webBASEURL + collectiveImage;

						if (useTexture == FALSE)
						{
							profileCover = collectiveImage;
							setImage();
						}
					}
				}

				llMessageLinked(LINK_SET, useCollectiveID, "COLLECTIVE_NAME|" + collectiveName, "");
			}

			else if (status == "waitExchDelConfirm")
			{
				doReset();
			}

			else
			{
			  debug(" == "+llList2String(tok,1));
			}
		}
		else
		{
			// Response not for this script
		}
	}

}
