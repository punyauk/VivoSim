/* CHANGE LOG:
 * Added sending rental period to the server & also support for using with updater
 * Added abiliy to reserve rental for one avatar
 */
string TXT_RESERVED_MSG = "Sorry, this rental is reserved for someone else";
string TXT_RESERVED = "RESERVED";

/**
 * rental.lsl
 *
 * Rental box that accepts Vivo's for rental payments
 * Also communicates with the VivoSim infrastucture to support rental signs etc
 *
 * Based on script by Ferd Frederix  https://www.outworldz.com/cgi/freescripts.plx?ID=594
 */

float   VERSION = 3.04;     // 19 April 2023

integer DEBUGMODE = FALSE;   // Set this if you want to force startup in debug mode
debug(string text)
{
	if (DEBUGMODE == TRUE) llOwnerSay("DEBUG_" + llToUpper(llGetScriptName()) + "\n" + text);
}

// Default config info, can be overridden in config notecard
integer PERIOD = 7;                             // PERIOD=7             ; Number of days per rental period
integer rentalCost = 0;                         // COST=0               ; Rental cost in Vivo's for each PERIOD
integer MAXPERIOD = 7;                          // MAXPERIOD=7          ; Maximum number of days can lease if IS_RENEWABLE=1
integer PRIMMAX = 1000;                         // PRIMMAX=1000         ; Maximum number of total prims on the parcel
integer IS_RENEWABLE = FALSE;                   // IS_RENEWABLE=0       ; Can they renew?  1=yes, 0=no
integer RENTWARNING = 2;                        // RENTWARNING=2        ; Number of days before this claim expires, when a message is sent to ask them to reclaim (if IS_RENEWABLE=1)
integer GRACEPERIOD = 2;                        // GRACEPERIOD=2        ; Number of days allowed to miss claiming before it expires
integer FACE = 2;                               // FACE=2               ; Set to face to display lease image
string  languageCode = "en-GB";                 // LANG=en-GB           ; Default language to use
string  leaseNC = "Lease info";                 // TERMS_NC=terms       ; Name of the rental terms notecard
key     reservedFor = NULL_KEY;                 // RESERVED=            ; If you wish to only allow one person to rent, set their UUID here

// These textures need to be in the prims inventory:
string lease_renewal        = "renewal";        // "Renewal due"
string lease_available      = "available";      // "Available" large size
string lease_rented         = "rented";         // "Rented"

integer pollInterval = 900;  	// check every n minutes.  900=15 minutes
integer islandComms = -675128;
integer timeOut = 15;  			// How long to wait for comms to return a value

string  serverUri = "http://vivosim.net/index.php/?option=com_vivosim&view=vivosim&type=vivosim&format=json&";

// Language strings
string TXT_ACTIVATING = "ACTIVATING...";
string TXT_ADMIN_MESSAGE = "Click this rental box to activate after configuring the notecard.";
string TXT_BOX_DISABLED = "Rental box is disabled";
string TXT_BOX_OFFLINE = "Rental box is offline";
string TXT_ASK_LEASE = "Do you wish to claim this parcel?";
string TXT_ASK_RENEW = "Do you wish to renew your claim now, at a cost of ";
string TXT_AVAILABLE_FOR = "Available for";
string TXT_CANT_RENEW = "Sorry, you can not renew yet.";
string TXT_CLAIM_DUE = "Claim due for renewal soon.";
string TXT_CLAIM_DUE_TIME = "Rental re-claim is due in";
string TXT_CLAIM_INFO = "Claim Info";
string TXT_CLAIM_THANKS = "Thanks for claiming this spot! Please wait for the rental box to show Rented message.";
string TXT_CLEANUP = "CLAIM EXPIRED: CLEANUP!";
string TXT_CREDITED = "You have been credited";
string TXT_DAYS = "Days";
string TXT_DISABLED = "Disabled";
string TXT_ERR_MSG = "Returning to unleased state as data is not correct.";
string TXT_EXPIRED = "Your claim has expired. Please clean up the space or contact admin.";
string TXT_EXPIRED_ALERT = "CLAIM EXPIRED: CLEANUP!";
string TXT_FOUND = "found.";
string TXT_FUNDS_LOW = "Sorry, you don't have enough Vivo's to rent this property.";
string TXT_HELLO = "Hello";
string TXT_HOURS = "Hours";
string TXT_INIT = "Initialising...";
string TXT_JOIN_INVITE = "Please do join the group as that gives you access to group messages and chat.";
string TXT_LEASE_DLG = "Please ensure you have read the rental details and terms.";
string TXT_MAX_LEASE = "Max Lease Length";
string TXT_MAX_MESSAGE = "Sorry, you can not claim more than the maximum time.";
string TXT_RENEW_ALLOWED = "Renewal is allowed";
string TXT_MAX_PRIMS = "Max Prims";
string TXT_MINUTES = "Minutes";
string TXT_NEW_CLAIM = "NEW CLAIM";
string TXT_NO = "No";
string TXT_NO_CLAIM_NOW = "Sorry, this parcel can not be claimed again at this time.";
string TXT_NOACC = "Sorry, you need to have your avatar linked to a VivoSim account to use the rental system.";
string TXT_OFFLINE = "** OFFLINE **";
string TXT_OVERDUE = "Claim renewal is overdue!";
string TXT_OVERDUE_CLAIM = "CLAIM OVERDUE FOR";
string TXT_PRIM_ALERT = "Attention, resident prim count exceded allowed amount.";
string TXT_PRIM_WARNING = "Warning, prim count exceded allowed amount. Please remove excess. Allowed is";
string TXT_RECLAIM_DUE = "Re-claim due in";
string TXT_RENEW_FAILED = "Sorry, renewal transaction failed. Please try again later";
string TXT_RENEWAL_DUE = "Your rental claim is nearly due to be renewed. To renew, please go and touch the rental box.";
string TXT_RENEWED = "Renewed";
string TXT_RENEW_FUNDS_LOW = "Sorry, you don't have enough Vivo's to extend the rental.";
string TXT_RENTAL_OVERDUE = "Your rental claim renewal is overdue. Please go and touch the sign to renew if you wish to keep it.";
string TXT_SECONDS = "Seconds";
string TXT_SPACE_RENTED = "Space is currently rented to";
string TXT_TIME_LEFT = "Time left for current rent period";
string TXT_TIMED_OUT = "Sorry, timed out, Please try again.";
string TXT_VIVOS_FOR = "vivo's for";
string TXT_YES = "Yes";
string TXT_YOU_HAVE = "You have";
string TXT_YOUR_PROPERTY = "This property is now leased to you.";
string TXT_CHARGED = "You have been charged";
string TXT_RENTAL = "Rental";
string TXT_COIN = "Vivos";
string TXT_LANGUAGE = "@";
//
string  SUFFIX = "R3";
//
// This config info is stored in the object description:
integer boxRegistered = FALSE;                  // Set to TRUE once box has been registered on the VivoSim server
list    myData;                                 // 0=Registered 1=MyState 2=LeaserName 3=LeaserUUID 4=UnixTimeExpires 5=SentWarning 6=SentAlert 7=Lang
integer MY_STATE            = 0;                // 0 is un-leased, 1 is leased
string  LEASER              = "-";              // name of leaser
key     LEASERID            = NULL_KEY;         // and their UUID
integer LEASED_UNTIL;                           // unix time stamp
integer SENT_ALERT          = FALSE;            // did we send them the first notification IM?
integer SENT_WARNING        = FALSE;            // did we send them the overdue warning IM?
integer SENT_PRIMWARNING    = FALSE;            // did they get an im about going over prim count?
//
// Other system variables
string  leaseTerms = "Please contact owner!";   // Used to show lease terms in dialog box
string  plotName;                               // Name of the rental property
integer listener;                               // ID for active listener
integer dialogActiveFlag ;                      // true when we have up a dialogue box, used by the timer to clear out the listener if no response is given
string  msgSay;                                 // Extra text to put on dialog boxes
key     farmHTTP = NULL_KEY;                    // Used when talking to server
integer FARM_CHANNEL = -911201;
key     ownerID = "";                           // ID of rental box owner
key     touchedKey ;                            // the key of whoever touched us last (not necessarily the renter)
key     boxID;
string  gridName;
string  regionName;
vector  boxLocation;
string  pwNC = "sfp";                           // Name of notecard with farm password
string  PASSWORD = "*";
string  dialog_msg = "";
string  blank_texture = "924e77a1-48f9-4ce8-9991-735e5ce6a6de";  // the UUID of a blank sign
string  logo_texture = "9cd7dfd1-759c-4265-9d70-b555f54f93b6";   // UUID of logo

integer sentAdminAlert = FALSE;
integer DAYSEC = 86400;                         // number of seconds in a day
integer status = 0;                             // 0 is disabled, 1 is active, -1 is offline
float   dailyCharge;                            // rentalCost/PERIOD
string  activityStatus;
integer coins;                                  // total number of coins leaser had at last check

// Colours
vector YELLOW = <1.000, 1.000, 0.000>;
vector ORANGE = <1.000, 0.502, 0.000>;
vector RED  = <1.000, 0.735, 0.469>;
vector WHITE  = <1.00, 1.00, 1.00>;

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
						 if (cmd == "TXT_ERR_MSG") TXT_ERR_MSG = val;
					else if (cmd == "TXT_ASK_LEASE") TXT_ASK_LEASE = val;
					else if (cmd == "TXT_BOX_DISABLED") TXT_BOX_DISABLED = val;
					else if (cmd == "TXT_BOX_OFFLINE") TXT_BOX_OFFLINE = val;
					else if (cmd == "TXT_ASK_RENEW") TXT_ASK_RENEW = val;
					else if (cmd == "TXT_YES") TXT_YES = val;
					else if (cmd == "TXT_NO") TXT_NO = val;
					else if (cmd == "TXT_INIT") TXT_INIT = val;
					else if (cmd == "TXT_ACTIVATING") TXT_ACTIVATING = val;
					else if (cmd == "TXT_OFFLINE") TXT_OFFLINE = val;
					else if (cmd == "TXT_DISABLED") TXT_DISABLED = val;
					else if (cmd == "TXT_NOACC") TXT_NOACC = val;
					else if (cmd == "TXT_FUNDS_LOW") TXT_FUNDS_LOW = val;
					else if (cmd == "TXT_YOU_HAVE") TXT_YOU_HAVE = val;
					else if (cmd == "TXT_TIMED_OUT") TXT_TIMED_OUT = val;
					else if (cmd == "TXT_LEASE_DLG") TXT_LEASE_DLG = val;
					else if (cmd == "TXT_NO_CLAIM_NOW") TXT_NO_CLAIM_NOW = val;
					else if (cmd == "TXT_DAYS") TXT_DAYS = val;
					else if (cmd == "TXT_HOURS") TXT_HOURS = val;
					else if (cmd == "TXT_MINUTES") TXT_MINUTES = val;
					else if (cmd == "TXT_SECONDS") TXT_SECONDS = val;
					else if (cmd == "TXT_RENEWAL_DUE") TXT_RENEWAL_DUE = val;
					else if (cmd == "TXT_RENEW_ALLOWED") TXT_RENEW_ALLOWED = val;
					else if (cmd == "TXT_RENEW_FUNDS_LOW") TXT_RENEW_FUNDS_LOW = val;
					else if (cmd == "TXT_RENEW_FAILED") TXT_RENEW_FAILED = val;
					else if (cmd == "TXT_RENTAL") TXT_RENTAL = val;
					else if (cmd == "TXT_RESERVED") TXT_RESERVED = val;
					else if (cmd == "TXT_RESERVED_MSG") TXT_RESERVED_MSG = val;
					else if (cmd == "TXT_CLAIM_DUE") TXT_CLAIM_DUE = val;
					else if (cmd == "TXT_CREDITED") TXT_CREDITED = val;
					else if (cmd == "TXT_RECLAIM_DUE") TXT_RECLAIM_DUE = val;
					else if (cmd == "TXT_RENTAL_OVERDUE") TXT_RENTAL_OVERDUE = val;
					else if (cmd == "TXT_OVERDUE_CLAIM") TXT_OVERDUE_CLAIM = val;
					else if (cmd == "TXT_EXPIRED") TXT_EXPIRED = val;
					else if (cmd == "TXT_ADMIN_MESSAGE") TXT_ADMIN_MESSAGE = val;
					else if (cmd == "TXT_CLAIM_THANKS") TXT_CLAIM_THANKS = val;
					else if (cmd == "TXT_EXPIRED_ALERT") TXT_EXPIRED_ALERT = val;
					else if (cmd == "TXT_MAX_MESSAGE") TXT_MAX_MESSAGE = val;
					else if (cmd == "TXT_YOUR_PROPERTY") TXT_YOUR_PROPERTY = val;
					else if (cmd == "TXT_JOIN_INVITE") TXT_JOIN_INVITE = val;
					else if (cmd == "TXT_CANT_RENEW") TXT_CANT_RENEW = val;
					else if (cmd == "TXT_TIME_LEFT") TXT_TIME_LEFT = val;
					else if (cmd == "TXT_CLAIM_DUE_TIME") TXT_CLAIM_DUE_TIME = val;
					else if (cmd == "TXT_SPACE_RENTED") TXT_SPACE_RENTED = val;
					else if (cmd == "TXT_HELLO") TXT_SPACE_RENTED = val;
					else if (cmd == "TXT_RENEWED") TXT_RENEWED = val;
					else if (cmd == "TXT_CLAIM_INFO") TXT_CLAIM_INFO = val;
					else if (cmd == "TXT_AVAILABLE_FOR") TXT_AVAILABLE_FOR = val;
					else if (cmd == "TXT_VIVOS_FOR") TXT_VIVOS_FOR = val;
					else if (cmd == "TXT_MAX_LEASE") TXT_MAX_LEASE = val;
					else if (cmd == "TXT_MAX_PRIMS") TXT_MAX_PRIMS = val;
					else if (cmd == "TXT_NEW_CLAIM") TXT_NEW_CLAIM = val;
					else if (cmd == "TXT_CLEANUP") TXT_CLEANUP = val;
					else if (cmd == "TXT_PRIM_WARNING") TXT_PRIM_WARNING = val;
					else if (cmd == "TXT_PRIM_ALERT") TXT_PRIM_ALERT = val;
					else if (cmd == "TXT_FOUND") TXT_FOUND = val;
					else if (cmd == "TXT_OVERDUE") TXT_OVERDUE = val;
					else if (cmd == "TXT_CHARGED") TXT_CHARGED = val;
					else if (cmd == "TXT_COIN") TXT_COIN = val;
					else if (cmd == "TXT_LANGUAGE") TXT_LANGUAGE = val;
				}
			}
		}
	}
}

loadConfig()
{
	//sfp 'password' notecard
	PASSWORD = osGetNotecardLine(pwNC, 0);

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

					 if (cmd == "PERIOD") PERIOD = (integer)val;
				else if (cmd == "MAXPERIOD") MAXPERIOD = (integer)val;
				else if (cmd == "PRIMMAX") PRIMMAX = (integer)val;
				else if (cmd == "IS_RENEWABLE") IS_RENEWABLE = (integer)val;
				else if (cmd == "RENTWARNING") RENTWARNING = (integer)val;
				else if (cmd == "GRACEPERIOD") GRACEPERIOD = (integer)val;
				else if (cmd == "COST") rentalCost = (integer)val;
				else if (cmd == "TERMS_NC") leaseNC = val;
				else if (cmd == "FACE") FACE = (integer)val;
				else if (cmd == "LANG") languageCode = val;
				else if (cmd == "RESERVED")
				{
					if (osIsUUID(val) == TRUE)
					{
						reservedFor = (key)val;
					}
					else
					{
						llOwnerSay("Invalid 'RESERVED' Key");
					}
				}
			}
		}
	}
}

postMessage(string msg)
{
	debug("postMessage: " + msg +"  to: " +serverUri);
	if (msg != "")
	{
		farmHTTP = llHTTPRequest(serverUri, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded", HTTP_BODY_MAXLENGTH, 16384], msg);

		// Set a timeout for comms
		llSetTimerEvent(timeOut);
	}
}

sendMessage(key id, string msg)
{
	// Sends instant message and also message direct to VivoSim server as a private meesage for avatar
	llInstantMessage(id, msg);
	postMessage("task=msgadd&data1=" +msg +"&data2=PRV" +(string)llGetUnixTime() +"&data3=" +(string)id +"&data4=" +(string)ownerID);
}

// Returns the SLURL for this rental box
string slurl()
{
	regionName = llGetRegionName();
	vector pos = llGetPos();

	string gridURI = llDeleteSubString(osGetGridHomeURI(), 0, 3);

	string result = "hop" +gridURI +"/"
		+ llEscapeURL(regionName) + "/"
		+ (string)llRound(pos.x) + "/"
		+ (string)llRound(pos.y) + "/"
		+ (string)llRound(pos.z) + "/";
	return result;
}

dialog()
{
	llListenRemove(listener);
	integer channel = llCeil(llFrand(1000000)) + 100000 * -1;
	listener = llListen(channel,"","","");
	if (msgSay != "") msgSay += "\n \n";
	llDialog(touchedKey, msgSay + dialog_msg, [TXT_YES,"-",TXT_NO], channel);
	llSetTimerEvent(120);  // Allow 2 minutes
	dialogActiveFlag  = TRUE;
}

string getRentalboxInfo()
{
	return llGetRegionName()  + " @ " + (string)llGetPos() + " (Leaser: \"" + LEASER + "\", Expire: " + timespan(LEASED_UNTIL - llGetUnixTime()) + ")";
}

string timespan(integer time)
{
	integer days = time / DAYSEC;
	integer curtime = (time / DAYSEC) - (time % DAYSEC);
	integer hours = curtime / 3600;
	integer minutes = (curtime % 3600) / 60;
	integer seconds = curtime % 60;

	return (string)llAbs(days) +" " +TXT_DAYS +", " +(string)llAbs(hours) +" " +TXT_HOURS +", " +(string)llAbs(minutes) +" " +TXT_MINUTES +", " +(string)llAbs(seconds) + " " +TXT_SECONDS;
}

string float2String (float num)
{
	return (string)llRound(num);
}

loadData()
{
	boxLocation = llGetPos();
	regionName = llGetRegionName();

	if (llGetInventoryType(leaseNC) == INVENTORY_NOTECARD)
	{
		// read in terms notecard
		leaseTerms = osGetNotecard(leaseNC);
	}

	if (llStringLength(llGetObjectDesc()) < 10) // Not enough characters in description so use our default values
	{
		LEASED_UNTIL = llGetUnixTime() + (integer) (DAYSEC * PERIOD);
		saveData();
	}
	else
	{
		myData = llCSV2List(llGetObjectDesc());
		LEASED_UNTIL = llList2Integer(myData, 4);
	}

	boxRegistered = llList2Integer(myData, 0);
	MY_STATE = llList2Integer(myData, 1);
	LEASER = llList2String(myData, 2);
	LEASERID = llList2Key(myData, 3);
	SENT_WARNING = llList2Integer(myData, 5);
	SENT_ALERT = llList2Integer(myData, 6);

	if (boxRegistered == TRUE)
	{
		// Let server know the state this box is in
		//  MY_STATE  -1 is disabled, 0 is un-leased, 1 is leased
		if (status == 0)
		{
			postMessage("task=boxcmd&data1=" +boxID +"&data2=disabled");
		}
		else if (MY_STATE == 0)
		{
			if (reservedFor != NULL_KEY)
			{
				postMessage("task=boxcmd&data1=" +boxID +"&data2=reserved");
			}
			else
			{
				postMessage("task=boxcmd&data1=" +boxID +"&data2=unleased");
			}
		}
		else if (MY_STATE == 1)
		{
			postMessage("task=boxcmd&data1=" +boxID +"&data2=leased|" +(string)LEASERID);
		}
		else
		{
			// Something not right so reset everything
			llSetObjectDesc("*");
			llSetColor(YELLOW, ALL_SIDES);
			llResetScript();
		}
	}
	else
	{
		// Rental box not registered, so request to be registered
		postMessage("task=addrentalbox&data1=" +boxID +"&data2=" +gridName +"&data3=" +slurl() +"&data4=" +regionName +"|" +plotName +"|" +float2String(boxLocation.x) +"," +float2String(boxLocation.y) +"," +float2String(boxLocation.z) +"|" + (string)ownerID +"|" +(string)rentalCost +"|" +(string)PERIOD);
		llSetText(TXT_INIT, <0.0, 1.0, 1.0>, 1.0);
	}
}

saveData()
{
	// 0=Registered 1=MyState 2=LeaserName 3=LeaserUUID 4=UnixTimeExpires 5=SentWarning 6=SentAlert 7=Lang
	myData =  [(string)boxRegistered, (string)MY_STATE, LEASER, LEASERID, (string)LEASED_UNTIL, (string)SENT_WARNING, (string)SENT_ALERT, (string)languageCode];
	debug("myData:\n" +llDumpList2String(myData, "|"));
	llSetObjectDesc(llList2CSV(myData));
	postMessage("task=boxcmd&data1=" +boxID +"&data2=setflags|" +(string)SENT_ALERT +(string)SENT_WARNING);
}

primCheck()
{
	integer count = llGetParcelPrimCount(llGetPos(),PARCEL_COUNT_TOTAL, FALSE);

	// Check if over allowed prim count
	if (count > PRIMMAX && !SENT_PRIMWARNING)
	{
		sendMessage(LEASERID, getRentalboxInfo() +" " +TXT_PRIM_WARNING +" " +(string)PRIMMAX
		 +", " +(string)count + " " +TXT_FOUND);

		 sendMessage(ownerID, getRentalboxInfo() +" " +TXT_PRIM_ALERT +" " +(string)PRIMMAX
		 +", " +(string)count + " " +TXT_FOUND +"[" +LEASER +"]");

		SENT_PRIMWARNING = TRUE;
		llMessageLinked(LINK_SET, -4, "OVER", NULL_KEY);  // Let home control know we are over limit
	}
	// Check for near prim limit i.e 90% used
	else if  ( (PRIMMAX - count) < (PRIMMAX * 0.1) )
	{
		SENT_PRIMWARNING = FALSE;
		llMessageLinked(LINK_SET, -4, "CAUTION", NULL_KEY);  // Let home control know we are near limit
	}
	else
	{
		SENT_PRIMWARNING = FALSE;
		llMessageLinked(LINK_SET, -4, "OKAY", NULL_KEY);   // Let home control know all okay
	}
}

rentCheck()
{
	if (IS_RENEWABLE)
	{
		if (LEASED_UNTIL > llGetUnixTime() && LEASED_UNTIL - llGetUnixTime() < RENTWARNING * DAYSEC)
		{
			llMessageLinked(LINK_SET, -6, "CAUTION", NULL_KEY);  // Let home control know we are near rental renewal date

			if (!SENT_ALERT)
			{
				sendMessage(LEASERID, TXT_RENEWAL_DUE);
				llSetTexture(lease_renewal,FACE);
				llSetColor(<0.8,0.8,1.0>, FACE);
				llSetText(TXT_CLAIM_DUE, <0,0,0.8>, 1.0);
				SENT_ALERT = TRUE;
				saveData();
			}
		}
		else if (LEASED_UNTIL < llGetUnixTime()  && llGetUnixTime() - LEASED_UNTIL < GRACEPERIOD * DAYSEC)
		{
			llMessageLinked(LINK_SET, -6, "OVER", NULL_KEY);  // Let home control know we are past rental renewal date

			if (!SENT_WARNING)
			{
				sendMessage(LEASERID, TXT_RENTAL_OVERDUE + getRentalboxInfo());
				sendMessage(ownerID, TXT_OVERDUE_CLAIM +" - " + getRentalboxInfo());
				SENT_WARNING = TRUE;
				saveData();
			}

			llSetTexture(lease_renewal,FACE);
			llSetText(TXT_OVERDUE, <1,0,0>, 0.5);
		}
		else if (LEASED_UNTIL < llGetUnixTime())
		{
			llMessageLinked(LINK_SET, -6, "EXPIRED", NULL_KEY);  // Let home control know rental has expired
			sendMessage(LEASERID, TXT_EXPIRED);
			sendMessage(ownerID, TXT_EXPIRED_ALERT +" - " + getRentalboxInfo());
			MY_STATE = 0;
			saveData();
			sendMessage(ownerID, TXT_BOX_DISABLED +" - " + getRentalboxInfo());
			state default;
		}
		else
		{
			llMessageLinked(LINK_SET, -6, "OKAY", NULL_KEY);  // Let home control know rental all good
		}
	}
	// Re-leasing not allowed so if time is up, switch off box until owner has cleaned things up
	else if (LEASED_UNTIL < llGetUnixTime())
	{
		sendMessage(ownerID, TXT_CLEANUP +": " + getRentalboxInfo());
		llMessageLinked(LINK_SET, -6, "EXPIRED", NULL_KEY);  // Let home control know rental has expired
		state default;
	}
}

string renewalAmount()
{
	// if renewing early, have already paid for PERIOD days so should just pay for the days elapsed since last renewal    (PERIOD-DAYSLEFT) * daily cost
	integer daysLeft = (LEASED_UNTIL - llGetUnixTime()) / DAYSEC;
	float renewalCost = (PERIOD - daysLeft)  * dailyCharge;

	return (string)llRound(renewalCost);
}

// Our three states - default (rental box is disabled), leased and unleased
default
{
	state_entry()
	{
		// Don't run in updater
		if (llSubStringIndex(llGetObjectName(), "Update")>=0 || llSubStringIndex(llGetObjectName(), "Rezz")>=0)
		{
			string me = llGetScriptName();
			llSetScriptState(me, FALSE);
			llSleep(0.5);
		}
		else
		{
			llSetTexture(logo_texture,FACE);
			llSetColor(YELLOW, ALL_SIDES);
			llSetText(TXT_ACTIVATING, WHITE, 1.0);
			sentAdminAlert = FALSE;
			status = 0;
			ownerID = llGetOwner();
			boxID = llGetKey();
			gridName = osGetGridName();
			loadConfig();
			loadLanguage(languageCode);
			dailyCharge = rentalCost/PERIOD;

			// Talk to PHP script and check comms is okay before we activate this rental box
			postMessage("task=activq327&data1=" +(string)ownerID);
		}
	}

	on_rez(integer start_param)
	{
		llSetObjectDesc("*");
		llSetTimerEvent(0);
		llResetScript();
	}

	touch_start(integer total_number)
	{
		if (llDetectedKey(0) == ownerID)
		{
			if (boxRegistered == TRUE)
			{
				status = 1;
				loadData();
				if (MY_STATE == 0)
				{
					state unleased;
				}
				else if (MY_STATE == 1)
				{
					state leased;
				}
			}
			else
			{
				llResetScript();
			}
		}
	}

	http_response(key request_id, integer HStatus, list metadata, string body)
	{
		if (request_id == farmHTTP)
		{
			list tok = llJson2List(body);
			string cmd = llList2String(tok, 0);
			debug("http_response: " +"  body= "+body + "  [CMD: " +cmd +"]");

			if (cmd == "2017053016xR")
			{
				llSetText(TXT_DISABLED, <0.9, 0.2, 0.0>, 1.0);
				dialog_msg = TXT_ASK_LEASE;
				llSetTexture(logo_texture,FACE);
				llSetColor(<1,1,0>, FACE);
				llOwnerSay(TXT_ADMIN_MESSAGE);
				llMessageLinked(LINK_SET, 10, "RENTAL", NULL_KEY);
				plotName = llList2String(llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME]), 0);
				llSetObjectName("Rental - " + plotName);
				loadData();
			}
			else if (cmd == "REGBOX")
			{
				if (llList2String(tok, 1) == "NOID")
				{
					llOwnerSay(TXT_NOACC);
				}
				else
				{
					// box now registered
					boxRegistered = TRUE;
					saveData();
					llSetText(TXT_DISABLED,<0.8, 0.5, 0.0>, 1.0);
					// Let server know this box is in offline state
					postMessage("task=boxcmd&data1=" +boxID +"&data2=disabled");
				}
			}
			else if (cmd == "BOXCMD")
			{
				if (llList2String(tok, 1) == "NOBOX")
				{
					// We have the box marked as registered but server says not so adjust our settings
					boxRegistered = FALSE;

					// Update to say not registered
					saveData();

					// Now reload which will force registration
					loadData();
				}
				else
				{
					saveData();
				}
			}
		}
	}

	timer()
	{
		// if we get here, comms failed
		llSetTimerEvent(0);
		llSetText(TXT_OFFLINE, RED, 1.0);
		llSetColor(YELLOW, ALL_SIDES);
		status = -1;

		if (sentAdminAlert == FALSE)
		{
			sentAdminAlert = TRUE;
			sendMessage(ownerID, TXT_BOX_OFFLINE +" - " + getRentalboxInfo());
		}
	}

	changed(integer change)
	{
		// Check if a notecard changed
		if (change & CHANGED_INVENTORY)
		{
			llResetScript();
		}
	}

}

// STATE //
state unleased
{
	state_entry()
	{
		SENT_WARNING = FALSE;
		SENT_ALERT = FALSE;
		dialog_msg = TXT_ASK_LEASE;
		loadData();

		if (MY_STATE !=0 || PERIOD == 0 || boxRegistered == FALSE)
		{
			llOwnerSay(TXT_ERR_MSG);
			state default;
		}

		// Let server no this box is in unleased state
		postMessage("task=boxcmd&data1=" +boxID +"&data2=unleased");

		// Change prim to the unleased style
		llSetColor(WHITE, ALL_SIDES);
		llSetTexture(blank_texture, FACE);
		llSetTexture(lease_available,1);
		llSetTexture(lease_available,3);
		llSetText("", ZERO_VECTOR, 0.0);

		// If this was leased we need to remove that person from the Residents group, but don't if it's the owner since that's not a nice thing to do!
		if ((LEASERID != NULL_KEY) && (LEASERID != ownerID))
		{
			osEjectFromGroup(LEASERID);
		}

		if (reservedFor != NULL_KEY)
		{
			// Send a region message so any status boards get updated that this property is unleased but reserved
			llSetText(TXT_RESERVED, YELLOW, 1.0);
			llRegionSay(islandComms, "RENTAL|RESERVED|" + plotName);
		}
		else
		{
			// Send a region message so any status boards get updated that this property is unleased
			llRegionSay(islandComms, "RENTAL|UNLEASED|" + plotName);
		}

		// Set up to send a ping every so often so server knows we are alive
		llSetTimerEvent(pollInterval * 2);
	}

	listen(integer channel, string name, key id, string message)
	{
		dialogActiveFlag = FALSE;
		llListenRemove(listener);

		loadData();

		if (message == TXT_YES)
		{
			llRegionSayTo(LEASERID,  0, TXT_CLAIM_THANKS);
			MY_STATE = 1;
			LEASER = llKey2Name(touchedKey);
			LEASER = llList2String(llParseString2List(LEASER, [" "], []), 0);
			LEASERID = touchedKey;
			LEASED_UNTIL = llGetUnixTime() + (integer) (DAYSEC * PERIOD);
			SENT_WARNING = FALSE;
			SENT_ALERT = FALSE;
			saveData();
			sendMessage(ownerID, TXT_NEW_CLAIM +" - " +getRentalboxInfo());

			// Deduct Vivo's for the rent
			postMessage("task=sold&data1=" + (string)LEASERID + "&data2=Rental_" + plotName + "&data3=" + (string)(rentalCost * -1));
		}
	}

	link_message(integer sender_num, integer cmd, string message, key id)
	{
		if (cmd == 0)
		{
			debug("RESET - Called via linked message (rental box)");
			llResetScript();
		}
		else if (cmd == -2)
		{
			llRegionSayTo(id, 0, "Rental box script version: " + (string)VERSION);
		}

	}

	touch_start(integer total_number)
	{
		touchedKey = llDetectedKey(0);

		if ((reservedFor == NULL_KEY) || (touchedKey == reservedFor))
		{
			// Check if this person has an account and enough coins
			postMessage("task=coins&data1=" +(string)touchedKey);
		}
		else
		{
			llRegionSayTo(touchedKey, 0, TXT_RESERVED_MSG);
		}
	}

	timer()
	{
		// clear out the channel listener, the menu timed out
		dialogActiveFlag = FALSE;
		llListenRemove(listener);

		// Send ping to let server know we are alive
		postMessage("task=boxcmd&data1=" +boxID +"&data2=ping");
	}

	http_response(key request_id, integer HStatus, list metadata, string body)
	{
		if (request_id == farmHTTP)
		{
			list tok = llJson2List(body);
			string cmd = llList2String(tok, 0);
			debug("http_response: " +"  body= "+body + "  [CMD: " +cmd +"]");

			if (cmd == "COINS")
			{
				loadData();

				// Read out summary of rental
				llRegionSayTo(touchedKey, 0, TXT_CLAIM_INFO);
				llRegionSayTo(touchedKey, 0, TXT_AVAILABLE_FOR +" " +(string)PERIOD +" " +TXT_DAYS  +" @ "  +(string)rentalCost +" " +TXT_VIVOS_FOR +" " +(string)PERIOD  + " " +TXT_DAYS);
				if (IS_RENEWABLE == 0)
				{
					llRegionSayTo(touchedKey, 0, TXT_MAX_LEASE +": " + (string)MAXPERIOD + " " +TXT_DAYS);
				}
				else
				{
					llRegionSayTo(touchedKey, 0, TXT_RENEW_ALLOWED);
				}
				llRegionSayTo(touchedKey, 0, TXT_MAX_PRIMS +": " + (string)PRIMMAX +"\n");

				string coins = llList2String(tok, 1);

				if (coins == "NONE")
				{
					llRegionSayTo(touchedKey, 0, TXT_NOACC);
				}
				else if ((integer)coins >= rentalCost)
				{
					// Show full leasing terms
					integer i;
					integer notecard_line = osGetNumberOfNotecardLines(leaseNC);
					for(i = 0; i < notecard_line; ++i)
					{
						llRegionSayTo(touchedKey, 0, llStringTrim(osGetNotecardLine(leaseNC, i), STRING_TRIM));
					}

					// Now ask if hey wish to lease
					msgSay = TXT_LEASE_DLG;
					dialog();
				}
				else
				{
				  llRegionSayTo(touchedKey, 0, TXT_FUNDS_LOW + "\n" +TXT_YOU_HAVE + " " +coins);
				}
			}
			else if (cmd == "SOLD")
			{
				// Let them know they have been charged and the lease is now ready
				llRegionSayTo(LEASERID, 0, TXT_CHARGED + " " +(string)rentalCost + " " + TXT_COIN);

				// Now credit the owner the rental charge
				postMessage("task=sold&data1=" +(string)ownerID +"&data2=" +TXT_RENTAL +": " +plotName +"&data3=" +(string)rentalCost);
				sendMessage(ownerID, TXT_CREDITED +" " +(string)rentalCost +" " +TXT_COIN +" (" +TXT_RENTAL +": " +plotName +")");

				// Send a region command to force rentee and owners HUDs to update coins
				llRegionSay(FARM_CHANNEL, "COINCHK|" +PASSWORD +"|" +(string)LEASERID);

				state leased;
			}
		}
	}

	changed(integer change)
	{
		// Check if a notecard changed
		if (change & CHANGED_INVENTORY)
		{
			llResetScript();
		}
	}

	on_rez(integer start_param)
	{
		llSetObjectDesc("*");
		llResetScript();
	}

}

// STATE //
state leased
{
	state_entry()
	{
		loadData();
		llSetColor(<1,1,1>, FACE);
		llSetTexture(lease_rented,FACE);
		llSetText("",<1,0,0>, 1.0);

		if (MY_STATE != 1 || PERIOD == 0 || LEASER == "" || boxRegistered == FALSE)
		{
			MY_STATE = 0;
			saveData();
			llOwnerSay(TXT_ERR_MSG);
			state unleased;
		}

		llRegionSayTo(LEASERID, 0, TXT_YOUR_PROPERTY);

		// Invite them to the residents group.
		if (osInviteToGroup(LEASERID) == TRUE)
		{
			llRegionSayTo(LEASERID, 0, TXT_JOIN_INVITE);
		}

		// Add them to the access list for the home control system
		llMessageLinked(LINK_SET, 10, "RENTAL", LEASERID);
		llRegionSay(islandComms, "RENTAL|LEASED|" + plotName);

		// Let server know this plot is now leased
		postMessage("task=boxcmd&data1=" +boxID +"&data2=leased");

		llSetText(TXT_SPACE_RENTED +": " +LEASER, WHITE, 1.0);

		// Call timer in a few seconds to check things
		llSetTimerEvent(5);
	}

	listen(integer channel, string name, key id, string message)
	{
		dialogActiveFlag = FALSE;

		// Leaser answered 'yes' to wanting to renew and we know they have enough coins to pay for it
		if ((message == TXT_YES) && (activityStatus == "waitRenewDlgResponse"))
		{
			loadData();

			if (MY_STATE != 1 || PERIOD == 0 || LEASER == "")
			{
				MY_STATE = 0;
				saveData();
				llSay(0,TXT_ERR_MSG);
				state unleased;
			}
			else if (IS_RENEWABLE)
			{
				integer timeleft = LEASED_UNTIL - llGetUnixTime();

				/** Don't think this should ever happen?
				 *   If time left is greater than one rental period, can't renew yet
				 */
				if (DAYSEC + timeleft > MAXPERIOD * DAYSEC)
				{
					llSay(0, TXT_MAX_MESSAGE);
				}
				else
				{
					if ((integer)coins >= (integer)renewalAmount())
					{
						// Deduct Vivo's for the rent
						activityStatus = "waitRenewalPayConfirm";

						// Get the renewal fee and set to negative as a purchase
						integer charge = -1 * (integer)renewalAmount();

						postMessage("task=sold&data1=" + (string)LEASERID + "&data2=Rental_" + plotName + "&data3=" + (string)charge);
					}
					else
					{
						llRegionSayTo(LEASERID, 0, TXT_RENEW_FUNDS_LOW);
					}
				}
			}
			else
			{
				llRegionSayTo(id, 0, TXT_CANT_RENEW);
			}
		}
		else
		{
			 llRegionSayTo(id, 0, TXT_TIME_LEFT +": " +timespan(llGetUnixTime()-LEASED_UNTIL));
			 activityStatus = "";
		}
	}

	link_message(integer sender_num, integer cmd, string message, key id)
	{
		if (cmd == 0)
		{
			debug("RESET called via linked message (rental box)");
			state default;
		}
		else if (cmd == -2)
		{
			llRegionSayTo(id, 0, "Rental box script version: " + (string)VERSION);
		}
		else if (cmd == -4)
		{
			if (message == "PRIMCHK")
			{
				primCheck();
			}
		}
		else if (cmd == -6)
		{
			if (message == "QUERY")
			{
				rentCheck();

				// Send back lease time info
				llRegionSayTo(id, 0, TXT_CLAIM_DUE_TIME +" " + timespan(llGetUnixTime()-LEASED_UNTIL));
			}
		}
	}

	timer()
	{
		if (activityStatus == "waitRenewalPayConfirm")
		{
			// Timed out on confirming payment for lease renewal
			llRegionSayTo(LEASERID, 0, TXT_RENEW_FAILED);
			activityStatus = "";
		}
		else if (activityStatus == "leasedTouch")
		{
			// Timed out getting info for leaser
			llRegionSayTo(LEASERID, 0, TXT_TIMED_OUT);
			activityStatus = "";
		}
		else if (dialogActiveFlag)
		{
			dialogActiveFlag = FALSE;
			llListenRemove(listener);
		}
		else
		{
			llSetTimerEvent(pollInterval);
			loadData();

			if (MY_STATE != 1 || PERIOD == 0 || LEASER == "")
			{
				MY_STATE = 0;
				saveData();
				llSay(0,TXT_ERR_MSG);
				state unleased;
			}

			// Do a prim count check
			primCheck();

			// Check the rental time left
			rentCheck();

			// Send ping to let server know we are alive
			postMessage("task=boxcmd&data1=" +boxID +"&data2=ping");
		}
	}

	touch_start(integer total_number)
	{
		touchedKey = llDetectedKey(0);

		if (touchedKey != LEASERID)
		{
			// Not leaser so give out info about who is renting and how long left
			llRegionSayTo(touchedKey, 0, TXT_SPACE_RENTED +": " + LEASER + "\n" + TXT_RECLAIM_DUE +" " + timespan(llGetUnixTime()-LEASED_UNTIL));
		}
		else
		{
			if (!IS_RENEWABLE)
			{
				// Leaser is trying to renew but that's set as not allowed
				llRegionSayTo(touchedKey, 0, TXT_SPACE_RENTED +": " + LEASER + "\n" + TXT_RECLAIM_DUE +" " + timespan(llGetUnixTime()-LEASED_UNTIL));
				msgSay = "";
				llRegionSayTo(touchedKey, 0, TXT_NO_CLAIM_NOW);
			}
			else
			{
				// Check if leaser has enough coins to renew
				activityStatus = "leasedTouch";
				postMessage("task=coins&data1=" +(string)touchedKey);
			}
		}
	}

	http_response(key request_id, integer HStatus, list metadata, string body)
	{
		if (request_id == farmHTTP)
		{
			// Reset from the timout interval to slower poll interval
			llSetTimerEvent(pollInterval);

			list tok = llJson2List(body);
			string cmd = llList2String(tok, 0);
			debug("http_response: " +"  body= "+body + "  [CMD: " +cmd +"]" +" activityStatus="+activityStatus);

			if (cmd == "BOXCMD")
			{
				if (llList2String(tok, 1) == "NOBOX")
				{
				}
			}
			else if (cmd == "COINS")
			{
				if (activityStatus == "leasedTouch")
				{
					if (MY_STATE != 1 || PERIOD == 0 || LEASER == "" )
					{
						MY_STATE = 0;
						saveData();
						llSay(0,TXT_ERR_MSG);
						state unleased;
					}
					else
					{
						// We have been touched by leaser so assume they may wish to renew
						activityStatus = "";
						loadData();

						if (llList2String(tok, 1) == "NONE")
						{
							// No account linked
							llRegionSayTo(touchedKey, 0, TXT_NOACC);
						}
						else
						{
							// Get their current balance
							coins = llList2Integer(tok, 1);

							// If they have enough coins to renew, ask them if they wish to go ahead and renew
							if ((integer)coins >= (integer)renewalAmount())
							{
								dialog_msg = TXT_ASK_RENEW +" " +renewalAmount() +" " +TXT_COIN;

								msgSay = TXT_HELLO +" " + LEASER + ".\n \n" +TXT_RECLAIM_DUE +" " + timespan(llGetUnixTime()-LEASED_UNTIL);
								activityStatus = "waitRenewDlgResponse";
								dialog();
							}
							else
							{
								llRegionSayTo(LEASERID, 0, TXT_RENEW_FUNDS_LOW);
							}
						}
					}
				}
			}
			else if (cmd = "SOLD")
			{
				SENT_ALERT = FALSE;
				SENT_WARNING = FALSE;
				LEASED_UNTIL = llGetUnixTime() + (integer) (DAYSEC * PERIOD);
				activityStatus = "";

				llSetColor(<1,1,1>, FACE);
				llSetTexture(lease_rented, FACE);
				llSetText("",<1,0,0>, 1.0);

				integer charge = llList2Integer(tok,3);

				// It's a deduction so will be negative, so turn positive to display in message
				charge = charge * -1;
				llRegionSayTo(LEASERID, 0, TXT_CHARGED +": " +(string)charge +" " +TXT_COIN);

				// Credit the owner the amount of rental paid
				postMessage("task=sold&data1=" +(string)ownerID +"&data2=" +TXT_RENTAL +": " +plotName +"&data3=" +(string)charge);
				sendMessage(ownerID, TXT_CREDITED +" " +(string)charge +" " +TXT_COIN +" (" +TXT_RENTAL +": " +plotName +")");

				// Send a region command to force rentee and owners HUDs to update coins
				llRegionSay(FARM_CHANNEL, "COINCHK|" +PASSWORD +"|" +(string)LEASERID);

				saveData();
			}
		}
	}

	changed(integer change)
	{
		// Check if a notecard changed
		if (change & CHANGED_INVENTORY)
		{
			llResetScript();
		}
	}

	on_rez(integer start_param)
	{
		llSetObjectDesc("*");
		llResetScript();
	}

}

