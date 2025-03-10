/* CHANGE LOG
 *  Option to rez a by-product when fuel used up
 *  Option to specify burn time of the various fuel items
 *  Option to show smoke (particle effect)
 *  Option to select between root prim glowing or not
 *  Option to set flame colour & light radius
 *  Option to set sound fx volume
 *  Changed workings to use "show_while_cooking" feature rather than previous 'fire' and 'wood'
 *  Now uses 3 digit version code i.e. 6.00 instead of 6.0
 *  Sends FIREOFF instead of ENDCOOKING message when turning fire off. Sends ENDCOOKING when fuel runs out
 *  Added Italian language card
*/

// fire.lsl
//  Fire that uses SF Wood or other fuel
//   For fire sounds when burning include a sound file calle 'fire-fx'
//   To generate smoke, include a texture called  'smoke-fx' and set SMOKE=1 in config notecard

float  VERSION = 6.01;   // 15 May 2023
integer RSTATE = 1;      // RSTATE: 1=release, 0=beta, -1=RC

integer DEBUGMODE = FALSE;
debug(string text)
{
	if (DEBUGMODE == TRUE) llOwnerSay("DEBUG_" + llToUpper(llGetScriptName()) + " " + text);
}

// Can be overidden by config notecard
list    fuelTypes =  ["Branches", "Firewood Logs", "Wood", "Coal"];     // FUELS=Branches;Firewood Logs;Wood;Coal
list    burnHours =  [1,2,2,4];                                         // BURN_HOURS=1;2;2;3                          # How many hours each fuel type burns for
string  byProduct = "";                                                 // BY_PRODUCT=Ash                              # Short name of by product produced from burning. Blank for none
integer doSmoke   = FALSE;                                              // SMOKE=0                                     # Set to 1 for smoke particle effects, 0 for none
integer smokeLevel = 1;                                                 // SMOKE_LEVEL=Low                             # Can be low (1), medium (2) or high (3)
float   volume = 1.0;                                                   // VOLUME=10                                   # Set at 1 to 10 or 0 for off
integer rootLight = TRUE;                                               // ROOT_LIGHT=1                                # Set to 1 for root prim to glow, 0 for only "show_while_cooking" prims
float   lightRadius = 20.0 ;                                            // LIGHT_DISTANCE=20                           # Radius (m) to of light source
vector  lightColour = <0.874, 0.790, 0.665>;                            // LIGHT_COLOR=<0.874, 0.790, 0.665>           # Set the colour of the light given off
vector  TXT_COLOR = <1.0, 1.0, 1.0>;                                    // TXT_COLOR=<1,1,1>                           # Can set to OFF to not use float text
float   textBrightness = 1.0;                                           // TXT_BRIGHT=10                               # Brightness of text 1 to 10 (10 is maximum brightness)(1 to 10)
integer isMade = FALSE;                                                 // MANUFACTURED=0                              # If TRUE, item must be rezzed via kitchen.lsl script in order to work e.g. candles
integer EXPIRES = -1;                                                   // EXPIRES=                                    # If specified, item will 'wear out' and need to be replaced
float   range = 5;                                                      // SENSOR_DISTANCE=5                           # How far to scan for items
string  SF_PREFIX = "SF";                                               // SF_PREFIX=SF
string  languageCode = "en-GB";                                         // LANG=en-GB
//
// Multilingual support
string  TXT_FUEL="Fuel";
string  TXT_ADD="Add";
string  TXT_FUEL_FOUND="Found fuel, emptying...";
string  TXT_ERROR_NOT_FOUND="Error! Fuel not found nearby";
string  TXT_EXPIRED="I have expired! Removing...";
string  TXT_STOP_FIRE="Put out fire";
string  TXT_START_FIRE="Light fire";
string  TXT_SELECT="Select";
string  TXT_CLOSE="CLOSE";
string  TXT_FOLLOW_ME="Follow me";
string  TXT_STOP="STOP";
string  TXT_BAD_PASSWORD="Bad password";
string  TXT_ERROR_UPDATE="Error: unable to update - you are not my Owner";
string  TXT_LANGUAGE="@";
//
string  SUFFIX = "F2";
//
integer FARM_CHANNEL = -911201;
string  PASSWORD;
integer lastTs;
integer rezTs;
string  FUEL = "Wood";
float   baseEnergy = 3600.0;  // burn time = 1 hour * burnHours
integer fuelLife = 1;
vector  GRAY = <0.207, 0.214, 0.176>;
vector  RED = <1.0, 0.0, 0.0>;
float   fuel_level = 0.0;
integer burning;
integer energy = -1;
key     lastUser = NULL_KEY;
key     followUser = NULL_KEY;
float   uHeight = 0;
integer listener=-1;
integer listenTs;
string  status;


integer chan(key u)
{
	return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

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

setAnimations(integer level)
{
	vector color;
	float f;
	integer count = llGetNumberOfPrims();
	integer i;

	for (i = 0; i <= count; i++)
	{
		if (llGetSubString(llGetLinkName(i), 0, 17)  == "show_while_cooking")
		{
			color = llList2Vector(llGetLinkPrimitiveParams(i, [PRIM_COLOR, 0]), 0);

			f = (float)llGetSubString( llGetLinkName(i), 18, -1);
			if (f == 0.0) f = 1.0;

			llSetLinkPrimitiveParamsFast(i, [PRIM_COLOR, ALL_SIDES, color, level*f]);
			llSetLinkPrimitiveParamsFast(i, [PRIM_GLOW, ALL_SIDES, (float)level * 0.]);
			llSetLinkPrimitiveParamsFast(i, [PRIM_POINT_LIGHT, level, lightColour, 1.0, lightRadius, 0.01]);
		}
	}

	if (rootLight == TRUE)
	{
		// light up root prim
		llSetLinkPrimitiveParamsFast(1, [PRIM_POINT_LIGHT, level, lightColour, 1.0, lightRadius, 0.01]);
	}
}

loadConfig()
{
	integer i;

	//config Notecard
	if (llGetInventoryType("config") == INVENTORY_NOTECARD)
	{
		list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
		integer lnkProduct;
		string  productTexture;
	
		integer getLinkNum(string name)
		{
			integer i;
	
			for (i=1; i <=llGetNumberOfPrims(); i++)
			{
				if (llGetLinkName(i) == name) return i;
			}
	
			return -1;
		}
		string line;
		list tok;
		string cmd;
		string val;

		for (i = 0; i < llGetListLength(lines); i++)
		{
			line = llStringTrim(llList2String(lines, i), STRING_TRIM);

			if (llGetSubString(line, 0, 0) != "#")
			{
				tok = llParseStringKeepNulls(line, ["="], []);
				cmd = llList2String(tok, 0);
				val = llList2String(tok, 1);
				debug("cmd="+cmd +"  val="+val);

					 if (cmd == "FUELS") fuelTypes = llParseString2List(val, [",", ";"], []);
				else if (cmd == "FUEL_NAME") fuelTypes = [val];   // Legacy support, depracated
				else if (cmd == "BURN_HOURS") burnHours = llParseString2List(val, [",", ";"], []);
				else if (cmd == "BY_PRODUCT") byProduct = val;
				else if (cmd == "SMOKE") doSmoke = (integer)val;
				else if (cmd == "SMOKE_LEVEL")
				{
					if (llToLower(val) == "low") smokeLevel = 1; else if (llToLower(val) == "medium") smokeLevel = 2; else smokeLevel = 3;
				}
				else if (cmd == "ROOT_LIGHT") rootLight = (integer)val;
				else if (cmd == "LIGHT_DISTANCE")
				{
					lightRadius = (float)val;
					if (lightRadius > 20.0) lightRadius = 20.0;
					  else if (lightRadius < 0.1) lightRadius = 0.1;
				}
				else if (cmd == "LIGHT_COLOR")
				{
					lightColour = (vector)val;

					if ((lightColour == ZERO_VECTOR) || (lightColour == <0,0,0>))
					{
						lightColour = <0.874, 0.790, 0.665>;
						llOwnerSay("RESETCOLOUR");
					}
				}
				else if (cmd == "SENSOR_DISTANCE") range = (float)val;
				else if (cmd == "EXPIRES") EXPIRES = (integer)val;
				else if (cmd == "MANUFACTURED") isMade = (integer)val;
				else if (cmd == "TXT_COLOR")
				{
					if ((val == "ZERO_VECTOR") || (val == "OFF"))
					{
						TXT_COLOR = ZERO_VECTOR;
					}
					else
					{
						TXT_COLOR = (vector)val;
						if (TXT_COLOR == ZERO_VECTOR) TXT_COLOR = <1,1,1>;
					}
				}
				else if (cmd == "TXT_BRIGHT")
				{
					textBrightness = 0.1 * (float)val;

					if (textBrightness < 0.1)
					{
						textBrightness = 0.1;
					}
					else if (textBrightness > 1.0)
					{
						textBrightness = 1.0;
					}
				}
				else if (cmd == "VOLUME")
				{
					volume = (float)val/10;
					if (volume > 1.0) volume = 1.0;
				}
				else if (cmd == "SF_PREFIX") SF_PREFIX = val;
				else if (cmd == "LANG") languageCode = val;
			}
		}
	}
	// Load settings from description
	list desc = llParseStringKeepNulls(llGetObjectDesc(), [";"], []);

	if (llList2String(desc, 0) == "F")
	{
		rezTs = llList2Integer(desc, 1);
		languageCode = llList2String(desc, 2);
		fuel_level = llList2Float(desc, 3);
	}

	//sfp Notecard
	if (isMade == FALSE) PASSWORD = osGetNotecardLine("sfp", 0);
}

saveToDesc()
{
	llSetObjectDesc("F;" +(string)rezTs+";" +languageCode+";" +(string)fuel_level);
}

loadLanguage(string langCode)
{
	// optional language notecard
	string languageNC = langCode + "-lang" + SUFFIX;

	if (llGetInventoryType(languageNC) == INVENTORY_NOTECARD)
	{
		list lines = llParseStringKeepNulls(osGetNotecard(languageNC), ["\n"], []);
		list tok;
		string line;
		string cmd;
		string val;
		integer i;

		for (i=0; i < llGetListLength(lines); i++)
		{
			line = llList2String(lines, i);

			if (llGetSubString(line, 0, 0) != "#")
			{
				tok = llParseString2List(line, ["="], []);

				if (llList2String(tok,1) != "")
				{
					cmd = llStringTrim(llList2String(tok, 0), STRING_TRIM);
					val = llStringTrim(llList2String(tok, 1), STRING_TRIM);

					// Remove start and end " marks
					val = llGetSubString(val, 1, -2);

					// Now check for language translations
						 if (cmd == "TXT_FUEL") TXT_FUEL = val;
					else if (cmd == "TXT_ADD") TXT_ADD = val;
					else if (cmd == "TXT_STOP_FIRE") TXT_STOP_FIRE = val;
					else if (cmd == "TXT_START_FIRE") TXT_START_FIRE = val;
					else if (cmd == "TXT_SELECT") TXT_SELECT = val;
					else if (cmd == "TXT_CLOSE") TXT_CLOSE = val;
					else if (cmd == "TXT_FOLLOW_ME") TXT_FOLLOW_ME = val;
					else if (cmd == "TXT_STOP") TXT_STOP = val;
					else if (cmd == "TXT_FUEL_FOUND") TXT_FUEL_FOUND = val;
					else if (cmd == "TXT_ERROR_NOT_FOUND") TXT_ERROR_NOT_FOUND = val;
					else if (cmd == "TXT_ERROR_NOT_FOUND") TXT_ERROR_NOT_FOUND = val;
					else if (cmd == "TXT_EXPIRED") TXT_EXPIRED = val;
					else if (cmd == "TXT_BAD_PASSWORD") TXT_BAD_PASSWORD = val;
					else if (cmd == "TXT_LANGUAGE") TXT_LANGUAGE = val;
				}
			}
		}
	}
}

reset()
{
	if (llGetInventoryType(getProdScriptName()) == INVENTORY_SCRIPT) llRemoveInventory(getProdScriptName());

	rezTs = llGetUnixTime();
	lastTs = -1;
	lastUser = NULL_KEY;
	llParticleSystem([]);
	setAnimations(0);
	refresh(0);
	llSetTimerEvent(900);
}

psys()
{
	if (doSmoke == TRUE)
	{
		float endAlpha = (0.3 * (float)smokeLevel) - 0.2;
		float maxAge = 3.0 * (float)smokeLevel;
		float burstRate = 9.0 / (float)smokeLevel;
		list  startScales = [<0.05 ,0.05, 1>, <0.5 ,0.5, 1>, <1.0, 1.0, 1>];
		list  endScales = [<0.75 ,0.75, 1>, <2.0 ,2.0, 1>, <4.0 ,4.0, 1>];
		vector startScale = llList2Vector(startScales, smokeLevel-1);
		vector endScale = llList2Vector(endScales, smokeLevel-1);

		llParticleSystem(
		[
			PSYS_PART_FLAGS,( 0
			|PSYS_PART_INTERP_COLOR_MASK
			|PSYS_PART_INTERP_SCALE_MASK
			|PSYS_PART_WIND_MASK
			|PSYS_PART_EMISSIVE_MASK ),
			PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE ,
			PSYS_PART_START_ALPHA,0.8,
			PSYS_PART_END_ALPHA, endAlpha,
			PSYS_PART_START_COLOR,<0.1, 0.1, 0.1>,
			PSYS_PART_END_COLOR,<0.8, 0.8, 0.8>,
			PSYS_PART_START_SCALE,<0.05, 0.05, 1>,
			PSYS_PART_END_SCALE, endScale,
			PSYS_PART_MAX_AGE,maxAge,
			PSYS_SRC_MAX_AGE,0,
			PSYS_SRC_ACCEL,<0.0, 0.0, 1.0>,
			PSYS_SRC_BURST_PART_COUNT,smokeLevel,
			PSYS_SRC_BURST_RADIUS,0,
			PSYS_SRC_BURST_RATE, burstRate,
			PSYS_SRC_BURST_SPEED_MIN,0.1,
			PSYS_SRC_BURST_SPEED_MAX,0.01,
			PSYS_SRC_ANGLE_BEGIN,0,
			PSYS_SRC_ANGLE_END,0,
			PSYS_SRC_OMEGA,<0,-0.3,0>,
			PSYS_SRC_TEXTURE, "smoke-fx",
			PSYS_SRC_TARGET_KEY, NULL_KEY
		]);
	}
}

string getFuelName()
{
	if (llGetListLength(fuelTypes) == 1)
	{
		return llList2String(fuelTypes, 0);
	}
	else
	{
		return TXT_FUEL;
	}
}

string getProdScriptName()
{
	string prodScriptName = "";
	string itemName;
	integer i;
	integer count = llGetInventoryNumber(INVENTORY_SCRIPT);

	for (i=0; i < count; i++)
	{
		itemName = llGetSubString(llGetInventoryName(INVENTORY_SCRIPT, i), 0, 6);

		if (itemName == "product")
		{
			prodScriptName = llGetInventoryName(INVENTORY_SCRIPT, i);
		}
	}

	return prodScriptName;
}

fireOff()
{
	if (burning == TRUE)
	{
		llSetTimerEvent(0);
		setAnimations(0);
		llParticleSystem([]);
		llStopSound();
		burning = FALSE;
		llMessageLinked(LINK_SET, 0, "FIREOFF", NULL_KEY);
	}
}

fireOn()
{
	if (burning == FALSE)
	{
		burning = TRUE;
		psys();
		llSetTimerEvent(1);
		lastTs = llGetUnixTime();
		setAnimations(1);
		llLoopSound("fire-fx", volume);
		llMessageLinked(LINK_SET, 0, "STARTCOOKING", NULL_KEY);
	}
}

doDie(key objectKey)
{
	llOwnerSay(TXT_EXPIRED);

	if (llGetListLength(llGetObjectDetails(objectKey, [OBJECT_NAME])) != 0)
	{
		llSetLinkColor(LINK_SET, GRAY, ALL_SIDES);
		osMessageObject(objectKey, "DIE|"+llGetKey()+"|100");
		llSleep(2.5);
	}

	llDie();
}

refresh(integer force)
{
	integer days = llFloor((llGetUnixTime()- rezTs)/86400);

	if (EXPIRES > 0)
	{
		if (EXPIRES > 1 && (EXPIRES-days) < 2)
		{
			llSetLinkColor(LINK_SET, GRAY, ALL_SIDES);
		}

		if (days >= EXPIRES)
		{
			doDie(NULL_KEY);
		}
	}

	if ((burning == TRUE) || (force == TRUE))
	{
		string str = "";

		if (RSTATE == 0) str = "-B-"; else if (RSTATE == -1) str = "-RC-";

		integer ts = llGetUnixTime();
		fuel_level -= 100.0 *(float)(ts - lastTs) / (baseEnergy * (float)fuelLife);

		if (fuel_level < 0) fuel_level = 0;

		if (fuel_level < 100)
		{
			if (TXT_COLOR == ZERO_VECTOR)
			{
				if (str == "")
				{
					llSetText("", ZERO_VECTOR, 0.0);
				}
				else
				{
					llSetText(str, GRAY, 0.5);
				}
			}
			else
			{
				llSetText(TXT_FUEL +": "+(string)((integer)fuel_level)+"%\n"+str , TXT_COLOR, 1.0);
				llMessageLinked(LINK_SET,llRound(fuel_level), "PROGRESS", "");
			}
		}
		else
		{
			llSetText(str, GRAY, 0.5);
		}

		if (fuel_level <= 0)
		{
			fireOff();
			fuel_level = 0;
			llMessageLinked(LINK_SET, 0, "ENDCOOKING", NULL_KEY);

			// All fuel gone so rez by=product
			if (byProduct != "")
			{
				llMessageLinked(LINK_SET, 0, "REZ_PRODUCT|" +PASSWORD +"|" +(string)lastUser +"|" +SF_PREFIX +" " +byProduct, NULL_KEY);
			}
		}

		lastTs = ts;
		saveToDesc();
	}
}


default
{
	listen(integer c, string nm, key id, string m)
	{

		if (m == TXT_ADD + " " +TXT_FUEL)
		{
			FUEL = "";
			llSensor(FUEL, "",SCRIPTED,  range, PI);
		}
		else if (m == TXT_ADD+" "+getFuelName())
		{
			FUEL = SF_PREFIX+" "+getFuelName();
			llSensor(FUEL, "",SCRIPTED,  range, PI);
		}
		else if (m == TXT_STOP_FIRE)
		{
			fireOff();
		}
		else if (m == TXT_START_FIRE)
		{
			lastUser = id;
			fireOn();
		}
		else if (m == TXT_LANGUAGE)
		{
			llMessageLinked(LINK_THIS, 1, "MENU_LANGS|" + languageCode +"|" +SUFFIX, id);
		}
		else if (m == TXT_FOLLOW_ME)
		{
			followUser = id;
			llSetTimerEvent(1);
		}
		else if (m == TXT_STOP)
		{
			followUser = NULL_KEY;

			// No target so just go to ground
			llSetPos( llGetPos()- <0,0, uHeight-0.5> );
			checkListen();
			llSetTimerEvent(0);
		}
		else if (status == "WaitSelection")
		{
			status = "";
			FUEL = SF_PREFIX+" "+m;
			llSensor(FUEL, "",SCRIPTED,  range, PI);
		}
	}

	dataserver(key kk, string m)
	{
		debug("dataserver:" +m);
		list tk = llParseStringKeepNulls(m , ["|"], []);
		string cmd = llList2String(tk,0);

		if (cmd == "INIT")
		{
			PASSWORD = llList2String(tk,1);
			loadConfig();
			loadLanguage(languageCode);
			reset();
		}
		else if (llList2String(tk,1) == PASSWORD)
		{
			if (SF_PREFIX+" "+cmd == llToUpper(FUEL)) // Add fuel & start using it
			{
				fuel_level = 100.0;
				burning = FALSE;
				fireOn();
			}
			else if (cmd == "HEALTH")
			{
				if (llList2Key(tk, 3) != lastUser) lastUser = NULL_KEY;

				return;
			}
			//for updates
			else if (cmd == "VERSION-CHECK")
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
				osMessageObject(llList2Key(tk, 2), answer);

				//Send a message to other prim with script
				osMessageObject(llGetLinkKey(3), "VERSION-CHECK|" + PASSWORD + "|" + llList2String(tk, 2));
			}
			else if (cmd == "DO-UPDATE")
			{
				if (llGetOwnerKey(kk) != llGetOwner())
				{
					llOwnerSay(TXT_ERROR_UPDATE);

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
				osMessageObject(llList2Key(tk, 2), "DO-UPDATE-REPLY|"+PASSWORD+"|"+(string)llGetKey()+"|"+(string)pin+"|"+sRemoveItems);

				if (delSelf)
				{
					llRemoveInventory(me);
				}

				llSleep(10.0);
				llResetScript();
			}
		}
	}

	timer()
	{
		if (followUser!= NULL_KEY)
		{
			list userData=llGetObjectDetails((key)followUser, [OBJECT_NAME,OBJECT_POS, OBJECT_ROT]);

			if (llGetListLength(userData)==0)
			{
				followUser = NULL_KEY;
			}
			else
			{
				llSetKeyframedMotion( [], []);
				llSleep(.2);
				list kf;
				vector mypos = llGetPos();
				vector size  = llGetAgentSize(followUser);
				uHeight = size.z;
				vector v = llList2Vector(userData, 1)+ <2.1, -1.0, 1.0> * llList2Rot(userData,2);
				float t = llVecDist(mypos, v)/10;

				if (t > .1)
				{
					if (t > 5) t = 5;

					vector vn = llVecNorm(v  - mypos );
					vn.z=0;
					//rotation r2 = llRotBetween(<1,0,0>,vn);
					kf += v- mypos;
					kf += ZERO_ROTATION;
					kf += t;
					llSetKeyframedMotion( kf, [KFM_DATA, KFM_TRANSLATION|KFM_ROTATION, KFM_MODE, KFM_FORWARD]);
					llSetTimerEvent(t+1);
				}
			}
		}
		else
		{
			llSetTimerEvent(120);
		}

		refresh(FALSE);

		if ((burning == TRUE) && (lastUser != NULL_KEY))
		{
			llSay(FARM_CHANNEL, "HEALTH|" +PASSWORD+"|" +(string)lastUser +"|Health|5|Energy|10" );
		}

		checkListen();
	}

	touch_start(integer n)
	{
		if (PASSWORD == "") doDie(NULL_KEY);

		energy = -1;
		lastUser = llDetectedKey(0);
		llSay(FARM_CHANNEL, "HEALTH|" +PASSWORD+"|" +(string)lastUser +"|CQ");
		list opts = [];

		if (fuel_level < 10) opts += TXT_ADD + " " +getFuelName();

		if (burning == TRUE)
		{
			opts += TXT_STOP_FIRE;
		}
		else if (fuel_level >1)
		{
			opts += TXT_START_FIRE;
		}

		if (lastUser == llGetOwner())
		{
			if (isMade == TRUE)
			{
				if (followUser == NULL_KEY)
				{
					opts += TXT_FOLLOW_ME;
				}
				else
				{
					opts += TXT_STOP;
				}
			}
		}

		opts += [TXT_LANGUAGE, TXT_CLOSE];
		startListen();
		llDialog(llDetectedKey(0), TXT_SELECT, opts, chan(llGetKey()));
	}

	sensor(integer n)
	{
		integer i;
		debug("sensor:FUEL=|"+FUEL+"|  Status="+status+"  SF_PREFIX=|"+SF_PREFIX+"|");

		if (FUEL == "")
		{
			integer buttonCount = 0;
			list names;
			string desc;
			string name;
			list foundList = [];

			for (i = 0; i < n; i++)
			{
				name = llDetectedName(i);

				if ( llGetSubString(name, 0, 2) == SF_PREFIX+" ")
				{
					desc= llList2String(llGetObjectDetails(llDetectedKey(i), [OBJECT_DESC]), 0);
					name = llGetSubString(llDetectedName(i), 3,-1);

					if (llGetSubString(desc, 0,1) == "P;")
					{
						if ((llListFindList(foundList, [name]) == -1) && (buttonCount < 11))
						{
							if (llListFindList(fuelTypes, [name]) != -1)
							{
								foundList += name; // Add valid fuels
								buttonCount++;
							}
						}
					}
				}
			}

			if (llGetListLength(foundList) != 0)
			{
				status = "WaitSelection";
				llDialog(lastUser,  TXT_SELECT, foundList+[TXT_CLOSE], chan(llGetKey()));
			}
			else
			{
				llRegionSayTo(lastUser, 0, TXT_ERROR_NOT_FOUND+" ("+llDumpList2String(fuelTypes, ", ")+")");
			}
		}
		else
		{
			key id = llDetectedKey(0);
			llRegionSayTo(lastUser, 0, TXT_FUEL_FOUND);

			// Use the fuel product
			osMessageObject(id, "DIE|"+(string)llGetKey());

			// Check if number of hours fule lasts is set, assume 1 hour if not found
			string ourFuel = llGetSubString(FUEL, 3, -1);
			i = llListFindList(fuelTypes, [ourFuel]);

			if (i != -1) fuelLife = llList2Integer(burnHours, i); else fuelLife = 1;

			debug("fuel=|" + ourFuel +"|" +"  Burn hours=" +(string)fuelLife +"  i="+(string)i);
		}
	}

	no_sensor()
	{
		debug("no_sensor:FUEL=|"+FUEL+"|  Status="+status);
		llRegionSayTo(lastUser, 0, TXT_ERROR_NOT_FOUND+" ("+llDumpList2String(fuelTypes, ", ")+")");
	}

	link_message(integer sender_num, integer num, string str, key id)
	{
		list tk = llParseString2List(str, ["|"], []);
		string cmd = llList2String(tk, 0);

		if (cmd == "SET-LANG")
		{
			languageCode = llList2String(tk, 1);
			loadLanguage(languageCode);
			saveToDesc();
			refresh(TRUE);
		}
	}

	state_entry()
	{
		burning = TRUE;
		fireOff();
		loadConfig();
		loadLanguage(languageCode);
		lastUser = NULL_KEY;
		rezTs = llGetUnixTime();
		lastTs = rezTs;
		llMessageLinked(LINK_THIS, 1, "LANG_MENU|" + languageCode, "");
		llSetTimerEvent(1);
	}

	on_rez(integer n)
	{
		llSetObjectDesc("-");
		llSleep(0.1);
		fuel_level = 0.0;
		saveToDesc();
		string str = "";

		if (RSTATE == 0)
		{
			str = "-B-";
		}
		else if (RSTATE == -1)
		{
			str = "-RC-";
		}

		llSetText(TXT_FUEL +": "+(string)((integer)fuel_level)+"%\n"+str, RED, 1.0);
		llResetScript();
	}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY)
		{
			loadConfig();
			loadLanguage(languageCode);
			refresh(FALSE);

			if (burning == TRUE) setAnimations(1);
		}
	}

}
