//points.lsl

// Version = 6.07;  // 4 June 2023

integer DEBUGMODE = FALSE;

debug(string text)
{
	if ((DEBUGMODE == TRUE) || (systemDebug == TRUE)) llOwnerSay("DB_" + llGetScriptName() + ": " + text);
}

// Multilingual support
string TXT_ACTIVATE="Activate";
string TXT_ACTIVATING="Activating...";
string TXT_CHECKING_TOTAL="Checking...";
string TXT_OPTION="Choose option";
string TXT_CLICK_TO_LINK="Click Vivos button again to link account";
string TXT_CLICK_TO_ACTIVATE="Click to activate";
string TXT_EMPTYING="emptying...";
string TXT_FOUND="Found";
string TXT_MESSAGE1="If you had an account at vivosim.net, you would have just received some Vivos!";
string TXT_LINKED_OK="is now linked to your VivoSim account";
string TXT_LINK_ACCOUNT="Link account";
string TXT_MY_COINS="My Vivos";
string TXT_MY_XP="My XP";
string TXT_POINTS="XP";
string TXT_COINS="Coins";
string TXT_OFFLINE="Offline";
string TXT_MESSAGES="Messages";
string TXT_MENU_SELL="Sell menu";
string TXT_SENDING_ITEM="Sending item";
string TXT_SORRY="Sorry, to get Vivos you need to have a linked account at";
string TXT_SUCCESS="Success! Your avatar";
string TXT_TALKING_TO_SERVER="Talking to server...";
string TXT_LINK_ERROR="Unable to link account [err:";
string TXT_CREDITED="You have been credited";
string TXT_YOU_HAVE="You have";
string TXT_RANK="Rank";
string TXT_VIVOS="Vivos";
string TXT_CLOSE="CLOSE";
string TXT_BAD_PASSWORD="Comms error, please try again in a few minutes";
string TXT_SCANNING="Scanning";
string TXT_FOOD="Food";
string TXT_ERROR="Error";
string TXT_NOT_FOUND="Nothing found nearby!";
//
string  languageCode = "en-GB";
string  SUFFIX="H1";

// Colours
vector  RED      = <1.000, 0.255, 0.212>;
vector  GREEN    = <0.180, 0.800, 0.251>;
vector  YELLOW   = <1.000, 0.863, 0.000>;
vector  PURPLE   = <0.694, 0.051, 0.788>;
vector  WHITE    = <1.000, 1.000, 1.000>;

// Variables
integer FARM_CHANNEL = -911201;
string  PASSWORD="*";
string  systemVersion = "0";
integer vivoActive;		// TRUE or FALSE for Active state
string  oswToken;
key     ownerID;
string  lookingFor;
string  itemPrice;
integer itemFound;
integer pointsCount=0;
integer startOffset=0;
string  status;
integer systemDebug;
list    items = [];
list    prices = [];
string  tmpStr;
integer chattyMode;
integer validated;
key     req_id2 = NULL_KEY;
integer lastAwardTime;


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
		listenTs = llGetUnixTime();
	}
}

checkListen()
{
	if (listener > 0 && llGetUnixTime() - listenTs > 300)
	{
		llListenRemove(listener);
		listener = -1;
	}
}

loadConfig()
{
	if (llGetInventoryType("config") == INVENTORY_NOTECARD)
	{
		list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
		integer i;

		for (i=0; i < llGetListLength(lines); i++)
		{
			string line = llStringTrim(llList2String(lines, i), STRING_TRIM);

			if (llGetSubString(line, 0, 0) != "#")
			{
				list tok = llParseStringKeepNulls(line, ["="], []);
				string cmd = llList2String(tok, 0);
				string val = llList2String(tok, 1);

					 if (cmd == "LANG") languageCode = val;
				else if (cmd == "HTTPS") llMessageLinked(LINK_SET, (integer)val, "SETHTTPS", "");
			}
		}
	}
}

loadLanguage(string langCode)
{
	// optional language notecard
	string languageNC = langCode + "-lang"+SUFFIX;
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
						 if (cmd == "TXT_ACTIVATE") TXT_ACTIVATE = val;
					else if (cmd == "TXT_ACTIVATING") TXT_ACTIVATING = val;
					else if (cmd == "TXT_CHECKING_TOTAL") TXT_CHECKING_TOTAL = val;
					else if (cmd == "TXT_OPTION") TXT_OPTION = val;
					else if (cmd == "TXT_CLICK_TO_LINK") TXT_CLICK_TO_LINK = val;
					else if (cmd == "TXT_CLICK_TO_ACTIVATE") TXT_CLICK_TO_ACTIVATE = val;
					else if (cmd == "TXT_EMPTYING") TXT_EMPTYING = val;
					else if (cmd == "TXT_FOUND") TXT_FOUND = val;
					else if (cmd == "TXT_MESSAGE1") TXT_MESSAGE1 = val;
					else if (cmd == "TXT_LINKED_OK") TXT_LINKED_OK = val;
					else if (cmd == "TXT_LINK_ACCOUNT") TXT_LINK_ACCOUNT = val;
					else if (cmd == "TXT_OFFLINE") TXT_OFFLINE = val;
					else if (cmd == "TXT_MY_COINS") TXT_MY_COINS = val;
					else if (cmd == "TXT_POINTS") TXT_POINTS = val;
					else if (cmd == "TXT_MY_XP") TXT_MY_XP = val;
					else if (cmd == "TXT_COINS") TXT_COINS = val;
					else if (cmd == "TXT_RANK") TXT_RANK = val;
					else if (cmd == "TXT_MENU_SELL") TXT_MENU_SELL = val;
					else if (cmd == "TXT_MESSAGES") TXT_MESSAGES = val;
					else if (cmd == "TXT_SENDING_ITEM") TXT_SENDING_ITEM = val;
					else if (cmd == "TXT_SORRY") TXT_SORRY = val;
					else if (cmd == "TXT_SUCCESS") TXT_SUCCESS = val;
					else if (cmd == "TXT_TALKING_TO_SERVER") TXT_TALKING_TO_SERVER = val;
					else if (cmd == "TXT_LINK_ERROR") TXT_LINK_ERROR = val;
					else if (cmd == "TXT_CREDITED") TXT_CREDITED = val;
					else if (cmd == "TXT_YOU_HAVE") TXT_YOU_HAVE = val;
					else if (cmd == "TXT_VIVOS") TXT_VIVOS = val;
					else if (cmd == "TXT_CLOSE") TXT_CLOSE = val;
					else if (cmd == "TXT_BAD_PASSWORD") TXT_BAD_PASSWORD = val;
					else if (cmd == "TXT_SCANNING") TXT_SCANNING = val;
					else if (cmd == "TXT_FOOD") TXT_FOOD =val;
					else if (cmd == "TXT_ERROR") TXT_ERROR = val;
					else if (cmd == "TXT_NOT_FOUND") TXT_NOT_FOUND = val;
				}
			}
		}
	}
}

refresh()
{
	if (vivoActive == FALSE)
	{
		llMessageLinked(LINK_SET, 0, "COMMS|WEB|0", "");
		activate();
	}

	llListenRemove(listener);
	listener = -1;

	if (systemVersion == "0")
	{
		llMessageLinked(LINK_THIS, 1, "VERSION-REQUEST", "");
	}
}

dlgSell(key id)
{
	list its = llList2List(items, startOffset, startOffset+9);
	startListen();
	llDialog(id, "\n"+TXT_MENU_SELL, [TXT_CLOSE]+its+ [">>"], chan(llGetKey()));
	status = "Sell";
}

activate()
{
	PASSWORD = llStringTrim(osGetNotecard("sfp"), STRING_TRIM);
	loadConfig();
	loadLanguage(languageCode);

	// Talk to server and check comms is okay then activate
	status = "activation";
	postMessage("task=activq327&data1=1");
	ownerID = llGetOwner();
	llSetTimerEvent(500);
}

postMessage(string msg)
{
	floatText(TXT_TALKING_TO_SERVER, PURPLE);
	req_id2 = llGetKey();
	llMessageLinked(LINK_SET, 1, "CMD_POST|"+msg, req_id2);
	llSetTimerEvent(45);
}

floatText(string msg, vector colour)
{
	llMessageLinked(LINK_SET, 1 , "TEXT|" + msg + "|" + (string)colour + "|", NULL_KEY);
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

checkCoins(key userId)
{
	if (status != "initCoin")
	{
		floatText(TXT_CHECKING_TOTAL+"\n ", PURPLE);
	}

	postMessage("task=coins&data1=" + (string)userId);
}

checkXP(key userId)
{
	postMessage("task=getxp&data1=" + (string)userId);
}


default
{

	on_rez(integer n)
	{
		llResetScript();
	}

	state_entry()
	{
		chattyMode = TRUE;
		listener=-1;
		systemDebug = FALSE;
		lastAwardTime = llGetUnixTime();
		llMessageLinked(LINK_SET, 1, "LANG_MESSENGER|" +TXT_MESSAGES+"|" +TXT_CLOSE, "");
	}

	link_message(integer sender_num, integer num, string msg, key id)
	{
		debug("link_message:" + msg);
		list tok = llParseStringKeepNulls(msg, ["|"], []);
		string cmd = llList2String(tok,0);

		if (cmd == "CMD_LANG")
		{
			languageCode=llList2String(tok, 1);
			loadLanguage(languageCode);
			refresh();
		}
		else if (cmd == "CMD_TEST")
		{
			postMessage("task=cmdtest&data1=" + (string)llGetOwner());
			llOwnerSay("CMD_TEST Sent:\ntask=cmdtest&data1=" +(string)llGetOwner());
		}
		else if (cmd == "CMD_DEBUG")
		{
			systemDebug = llList2Integer(tok, 1);
			refresh();
		}
		else if (cmd == "CMD_POINTS")
		{
			if (id == NULL_KEY) id = ownerID;

			list opts = [];

			opts += [TXT_MY_XP, TXT_MY_COINS, TXT_MESSAGES];

			if (vivoActive == FALSE)
			{
				opts += [TXT_ACTIVATE];
			}
			else if (validated == FALSE)
			{
				opts += [TXT_LINK_ACCOUNT];
			}

			opts += TXT_CLOSE;
			refresh();
			startListen();
			llDialog(id, "\n"+TXT_OPTION, opts, chan(llGetKey()));
			llSetTimerEvent(300);
		}
		else if (cmd == "CMD_COIN_CHECK")
		{
			checkCoins(llList2Key(tok,2));
		}
		else if (cmd == "NOW_LINKED")
		{
			status = "initCoin";
			vivoActive = TRUE;
			validated = TRUE;
			checkCoins(id);
		}
		else if (cmd == "CMD_PLUSPNT")
		{
			// To prevent re-triggering errors
			if (llGetUnixTime() - lastAwardTime > 180)
			{
				lastAwardTime = llGetUnixTime();
				status = "verifying_plusxp";
				postMessage("task=hudxp&data1=" +(string)id +"&data2=" +systemVersion +"&data3=1"  +"&data4=" +llList2String(tok, 1));
			}
		}
		else if (cmd == "CMD_CHATTY")
		{
			chattyMode = num;
		}
		else if (cmd == "CMD_LINKRESULT")
		{
			if (num == -1)
			{
				validated = FALSE;
				floatText(TXT_LINK_ERROR +" err: " +(string)id + "\n \n", RED);
			}
			else
			{
				validated = TRUE;
				floatText(TXT_SUCCESS +"\n \n" + TXT_LINKED_OK +"\n \n", GREEN);
			}

			refresh();
		}
		else if (cmd == "VERSION-REPLY")
		{
			systemVersion = (string)num;
		}
		else if (cmd == "HTTP_RESPONSE")
		{
			string jsonTxt = llList2String(tok, 1);
			tok = [];
			tok = llJson2List(jsonTxt);
			cmd = llList2String(tok, 0);
			floatText("  ", WHITE);

			if (cmd == "DISABLE")
			{
				llMessageLinked(LINK_SET, 0, "COMMS|WEB|0", "");
				llResetScript();
			}
			else if (llList2String(tok, 1) == "NOID")
			{
				if (validated == FALSE)
				{
					//
				}
				else if (status == "verifying_plusxp")
				{
					// They don't have an account so can't credit them
					floatText(TXT_MESSAGE1, GREEN);
					status = "";
					llMessageLinked(LINK_SET, 0, "COMMS|WEB|1", "");
					refresh();
				}
				else
				{
					// status == "verifying-soldpnt"
					floatText(TXT_SORRY+ "\nhttps:\\vivosim.net", YELLOW);
					validated = FALSE;
					status = "";
					llMessageLinked(LINK_SET, 0, "COMMS|WEB|1", "");
					refresh();
				}
			}
			else if (cmd == "2017053016xR")
			{
				//  Communication established okay
				vivoActive = TRUE;
				llMessageLinked(LINK_SET, 0, "COMMS|WEB|1", "");
				postMessage("task=getxp&data1=" + (string)ownerID);
			}
			//TODO: Is this used now? Think we don't need it in HuD?
			else if (cmd == "SOLD")
			{
				llRegionSayTo(ownerID, 0, TXT_CREDITED+" " + llList2String(tok,3) + " " + TXT_COINS);
				status = "";
				llMessageLinked(LINK_SET, 0, "CMD_COINS|" + llList2String(tok,3), "");
				llMessageLinked(LINK_SET, 0, "COMMS|WEB|1", "");
				refresh();
			}
			else if (cmd == "PLUSXP")
			{
				string dataString = llList2String(tok, 1);
				list XPValues = llParseString2List(dataString, [";"], [""]);

				num = llList2Integer(XPValues, 0);

				if (llList2String(XPValues, 0) == "ATMAX")
				{
					integer fraction = llList2Integer(XPValues, 1);
					llMessageLinked(LINK_SET, fraction, "SUBPOINT", "");
				}
				else if (num != 0)
				{
					// Let main HUD script know XP got awarded
					llMessageLinked(LINK_SET, num, "GOT_XP", "");

					// Comms must be okay so make sure it shows it!
					llMessageLinked(LINK_SET, 0, "COMMS|WEB|1", "");

					status = "";
					checkXP(ownerID);
				}
				else
				{
					// ALREADYDONE, NOID, NOVALUE, ADDFAIL
				}

				refresh();
			}
			else if (cmd == "XPTOTAL")
			{
				// JSON at llList2String(tok, 3)
				// JSON is  {"current":{"id":2,"title":"Farm hand","points":50,"image":"https://vivosim.net/components/com_community/assets/badge_2.png","published":1,"progress":"0.00"}}
				list rankList = llJson2List(llList2String(llJson2List(llList2String(tok, 3)), 1));
				string userRank = llList2String(rankList, 3);
				string rankImage = llList2String(rankList, 7);
				tmpStr = TXT_YOU_HAVE +" " +(string)llList2String(tok,1) + " "+TXT_POINTS + "\n \n" + TXT_RANK + ": " +llList2String(rankList, 3);
				llMessageLinked(LINK_SET, 0, "CMD_XP|" + llList2String(tok,1), "");

				if (validated == FALSE)
				{
					validated = TRUE;
					status = "initCoin";
					checkCoins(llGetOwner());
				}
				else
				{
					floatText(tmpStr +"\n ", WHITE);
					llMessageLinked(LINK_SET, 0, "COMMS|WEB|1", "");
				}
			}
			else if (cmd == "COINS")
			{
				if (status == "initCoin")
				{
					status = "";
					validated = TRUE;
					vivoActive = TRUE;
					llMessageLinked(LINK_SET, 0, "COMMS|WEB|1", "");
				}
				else
				{
					floatText(TXT_YOU_HAVE+" " +(string)llList2Integer(tok,1) +" " +TXT_VIVOS +"\n \n", WHITE);
				}
				llMessageLinked(LINK_ALL_OTHERS, 0, "CMD_COINS|" + llList2String(tok,1), "");
			}
			else if (cmd == "OSCHECK")
			{
				if (num == 1) activate();
			}
			else if (cmd == "LINKED")
			{
				if (llList2String(tok, 1) != "INVALID-J")
				{
					vivoActive = TRUE;
					validated = TRUE;
					floatText(TXT_SUCCESS +" " +llList2String(tok, 3) +" " +TXT_LINKED_OK, WHITE);
				}
				else
				{
					floatText(TXT_LINK_ERROR +" " +llList2String(tok, 1), RED);
				}
			}
			else
			{
			  // debug(" == "+llList2String(tok,1));
			}
		}
	}

	timer()
	{
		floatText(" ", WHITE);
		refresh();
		llSetTimerEvent(600);
		checkListen();
	}

	dataserver( key id, string m)
	{
		debug("dataserver: " + m);
		list tk = llParseStringKeepNulls(m, ["|"], []);
		string item = llList2String(tk,0);
		integer i;

		if (llList2String(tk,1) != PASSWORD) return;

		if (item == "DEBUG")
		{
			DEBUGMODE = llList2Integer(tk, 2);
			return;
		}

		// We are trying to use a product
		for (i=0; i < llGetListLength(items); i++)
		{
			if (llToUpper(llList2String(items,i)) ==  item)
			{
				lookingFor = llGetSubString(lookingFor, 3, llStringLength(lookingFor));
				floatText(TXT_SENDING_ITEM +" " + lookingFor + "...", PURPLE);
				psys(NULL_KEY);
				postMessage("task=sold&data1=" + (string)ownerID + "&data2=Sold_  " + (lookingFor) + "&data3=" + itemPrice);
				status = "verifying-soldpnt";

				return;
			}
		}

		itemFound = 0;
	}

	listen(integer c, string nm, key id, string m)
	{
		if (m == TXT_CLOSE)
		{
			refresh();

			return;
		}
		else if (m == ">>")
		{
			startOffset += 10;

			if (startOffset >llGetListLength(items))
			{
				startOffset=0;
			}

			dlgSell(id);
		}
		else if (m == TXT_LINK_ACCOUNT)
		{
			llMessageLinked(LINK_SET, 1, "CMD_LINKACC", ownerID);
			refresh();
		}
		else if (m == TXT_MY_COINS)
		{
			checkCoins(id);
		}
		else if (m == TXT_ACTIVATE)
		{
			floatText(TXT_ACTIVATING+"\n \n", PURPLE);
			status = "Activating";
			activate();
		}
		else if (m == TXT_MY_XP)
		{
			floatText(TXT_CHECKING_TOTAL+"\n ", PURPLE);
			postMessage("task=getxp&data1=" + (string)id);
		}
		else if (m == TXT_MY_COINS)
		{
			checkCoins(id);
			floatText(TXT_CHECKING_TOTAL+"\n ", PURPLE);
			postMessage("task=coins&data1=" + (string)id);
		}
		else if (m == TXT_MESSAGES)
		{
			llMessageLinked(LINK_SET, 1, "MSG_MENU", id);
		}
		else if (status == "Sell")
		{
			string what = llGetSubString(m, 4,-1);
			integer idx = llListFindList(items, m);

			if (idx >= 0)
			{
				floatText(TXT_SCANNING, PURPLE);
				itemPrice  = llList2String(prices, idx);
				lookingFor = "SF " + llList2String(items,idx);
				llSensor(lookingFor, "",SCRIPTED,  10, PI);
			}
			
			status = "WaitItem";
		}
		else if (status == "WaitItem")
		{
			// debug("status = WaitItem");
		}
	}

	sensor(integer n)
	{
		itemFound=1;
		tmpStr = TXT_FOOD +" "+llDetectedName(0)+", " + TXT_EMPTYING;
		floatText(tmpStr, PURPLE);
		llRegionSayTo(ownerID, 0, tmpStr);
		osMessageObject(llDetectedKey(0), "DIE|"+llGetKey());
	}

	no_sensor()
	{
		floatText(TXT_ERROR + ":"+lookingFor+" " + TXT_NOT_FOUND, RED);
		refresh();
	}

	changed(integer change)
	{
		if (change & CHANGED_OWNER)
		{
			validated = FALSE;
			llResetScript();
		}
	}
}
