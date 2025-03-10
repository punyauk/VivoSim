/**
 * CHANGE LOG
 *  fix issue with not working with XEngine
*/

// NEW TEXT
string TXT_GET_ID = "Get ID";
string TXT_SET_ID = "Set ID";
// DELETED TEXT
 // string TXT_EMPTY_CART = "Empty cart";

/**
 * storage_networked.lsl
 * Allows people to store items on the server so they can then rez them elsewhere
 */

float VERSION = 6.03;    // 1 March 2025

// If this item is worn, used to set the name so HUD interaction works
string NAME = "SF Backpack";

integer DEBUGMODE = FALSE;
debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DEBUG:" + llToUpper(llGetScriptName()) + " " + text);
}

string BASEURL="http://vivosim.net/index.php/?option=com_vivosim&view=vivosim&type=vivosim&format=json&";

// Default values, can be changed via config notecard
integer autoAttach = FALSE;                 // AUTO_ATTACH=0
vector  rezzPosition = <0.0, 1.5, 2.0>;     // REZ_POSITION=<0.0, 1.5, 2.0>
integer allowGroupUse = FALSE;              // ALLOW_GROUP_USE=0        Set to 1 for anyone in group to use, 0 for just owner to use
integer groupAddStock = TRUE;               // GROUP_STOCK_ADD=1
integer sayStockLevels = TRUE;              // SAY_STOCK=1              Set to 1 to say stock levels any time data retrieved from server, 0 to keep quiet
integer SENSOR_DISTANCE=10;                 // SENSOR_DISTANCE=10
vector  TXT_COLOR = <1,1,1>;                // TXT_COLOR=<1,1,1>
integer SORTDIR = 0;                        // SORTDIR=ASC  (set as ASC[1] or DEC[0])
string  SF_PREFIX = "SF";                   // SF_PREFIX=SF
string  languageCode = "en-GB";             // LANG=en-GB
//
// For multi-lingual support
string TXT_CLOSE="CLOSE";
string TXT_ADD="Add Product";
string TXT_REZ="Rez Product";
string TXT_CHECK="Check";
string TXT_ADDED="Added";
string TXT_SELECT="Select";
string TXT_GET_ITEM="Select item to get";
string TXT_STORE_ITEM="Select product to store";
string TXT_LEVEL="level is now";
string TXT_LEVELS="Levels";
string TXT_FOUND="Found";
string TXT_EMPTYING="emptying...";
string TXT_NOT_ENOUGH="Sorry, there is not enough left";
string TXT_NOT_FOUND="No items found nearby";
string TXT_NOT_FOUND_ITEM="not found nearby. You must bring them closer";
string TXT_NOT_FOUND100="with 100% not found nearby. Please bring it closer.";
string TXT_NOT_STORED="not in my Inventory";
string TXT_ERROR_UPDATE="Error: unable to update - you are not my Owner";
string TXT_NO_REZ="Unable to rez items here";
string TXT_MENU = "MENU";
string TXT_RIDE = "RIDE";
string TXT_ERROR_USE="Sorry, you are not allowed to use this";
string TXT_STORE_EMPTY = "is empty";
string TXT_ADD_STOCK = "New Stock";
string TXT_CHECKING = "Checking";
string TXT_IN_INVENTORY = "Product already in my inventory";
string TXT_INV_SEARCH_FAIL = "Sorry, unable to add to inventory";
string TXT_STORE_EMPTY_FAIL = "Sorry, emptying cart failed, please try again";
string TXT_ERROR_GROUP = "Error, we are not in the same group";
string TXT_STOCK_OWNER = "Stock owner";
string TXT_LOAD_STOCK = "Load stock";
string TXT_NO_ACCOUNT = "Unable to save stock as you don't have a Vivosim account";
string TXT_LANGUAGE    = "@";
//
string  SUFFIX = "S4";
string  PASSWORD="*";
key     farmHTTP = NULL_KEY;
integer FARM_CHANNEL = -911201;
string  stockNC = "stklst";
string  binIdNC = "binid";
list    catalog = [];
list    stockItems = [];
list    levels = [];
integer CREDIT = 1;
integer DEBIT = -1;
integer activated = 0;
integer timeout = 30;
//
integer singleLevel = 1;
string  shareMode = "all";
//listens and menus
integer listener=-1;
integer listenTs;
integer startOffset=0;
key     ownKey;
string  binKey;
//temp
string  tmpkey;
string  lookingFor;
string  status;
//
list    selitems = [];
key     menuUser = NULL_KEY;
key     stockOwner = NULL_KEY;
key     myGroup;
integer seated = FALSE;
string  okayFX = "fx";
string  failFX = "error";


integer chan(key u)
{
    return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

startListen()
{
    if (listener < 0)
    {
        listener = llListen(chan(ownKey), "", "", "");
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
        selitems = [];
    }
}

showMenu()
{
    debug("showMenu:menuUser="+(string)menuUser+" stockOwner="+(string)stockOwner +"  Status="+status);
    status = "";
    list opts = [];

    if ((menuUser == llGetOwner()) || (groupAddStock == TRUE))
    {
        if (menuUser == llGetOwner())
        {
            opts += TXT_GET_ID;
            opts += TXT_SET_ID;
        }

        opts += [TXT_ADD_STOCK];
    }

    if (stockOwner != NULL_KEY)
    {
        opts += [TXT_ADD];
    }

    if (llGetListLength(stockItems) != 0)
    {
        opts += [TXT_REZ];
    }

    opts += [TXT_CHECK, TXT_CLOSE, TXT_LANGUAGE];
    startListen();
    llDialog(menuUser, TXT_SELECT, opts, chan(ownKey));
    llSetTimerEvent(300);
}

// Returns a list that is vLstSrc with the elements in reverse order
list listReverse(list lst)
{
    if (llGetListLength(lst) <= 1)
    {
        return lst;
    }
    else
    {
        return listReverse(llList2List(lst, 1, llGetListLength(lst))) + llList2List(lst, 0, 0);
    }
}

multiPageMenu(string message, list buttons)
{
    integer l = llGetListLength(buttons);
    integer ch = chan(ownKey);

    if (l < 12)
    {
        llDialog(menuUser, message, [TXT_CLOSE]+buttons, ch);

        return;
    }

    if (startOffset >= l)
    {
        startOffset = 0;
    }

    list its = llList2List(buttons, startOffset, startOffset + 9);
    its = llListSort(its, 1, TRUE);
    llDialog(menuUser, message, [TXT_CLOSE]+its+[">>"], ch);
}

postMessage(string msg)
{
    debug("postMessage:"+msg +"\nTO " +BASEURL);
    farmHTTP = llHTTPRequest(BASEURL, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"], msg);
}

loadConfig()
{
    integer i;

    //sfp Notecard
    PASSWORD = llStringTrim(osGetNotecard("sfp"), STRING_TRIM);

    //config Notecard
    if (llGetInventoryType("config") == INVENTORY_NOTECARD)
    {
        list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
        list tok;
        string cmd;
        string val;

        for (i=0; i < llGetListLength(lines); i++)
        {
            string line = llStringTrim(llList2String(lines, i), STRING_TRIM);
            if (llGetSubString(line, 0, 0) != ";")
            {
                tok = llParseStringKeepNulls(line, ["="], []);
                cmd = llList2String(tok, 0);
                val = llList2String(tok, 1);

                     if (cmd == "AUTO_ATTACH") autoAttach = (integer)val;
                else if (cmd == "REZ_POSITION") rezzPosition = (vector)val;
                else if (cmd == "ALLOW_GROUP_USE")
                {
                    allowGroupUse = (integer)val;
                    llMessageLinked(LINK_SET, allowGroupUse, "GROUP_ALLOWED", "");
                }
                else if (cmd == "GROUP_STOCK_ADD") groupAddStock = (integer)val;
                else if (cmd == "SAY_STOCK") sayStockLevels = (integer)val;
                else if (cmd == "SF_PREFIX") SF_PREFIX = val;
                else if (cmd == "SENSOR_DISTANCE") SENSOR_DISTANCE = (integer)val;
                else if (cmd == "LANG") languageCode = val;
                else if (cmd == "SORTDIR")
                {
                    if (llToUpper(val) == "ASC") SORTDIR = 1; else SORTDIR = 0;
                }
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
            }
        }
    }
    //state by description
    list desc = llParseStringKeepNulls(llGetObjectDesc(), [";"], []);

    if (llList2String(desc, 0) == "S")
    {
        languageCode = llList2String(desc, 1);
    }
    else
    {
        llSetObjectDesc("S;" + languageCode);
    }
}

loadLanguage(string langCode)
{
    // optional language notecard
    string languageNC = langCode + "-lang" + SUFFIX;

    if (llGetInventoryType(languageNC) == INVENTORY_NOTECARD)
    {
        list lines = llParseStringKeepNulls(osGetNotecard(languageNC), ["\n"], []);
        string line;
        integer i;
        list tok;
        string cmd;
        string val;

        for (i=0; i < llGetListLength(lines); i++)
        {
            line = llList2String(lines, i);

            if (llGetSubString(line, 0, 0) != "#")
            {
                tok = llParseString2List(line, ["="], []);

                if (llList2String(tok,1) != "")
                {
                    cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
                    val=llStringTrim(llList2String(tok, 1), STRING_TRIM);
                    
                    // Remove start and end " marks
                    val = llGetSubString(val, 1, -2);
                    
                    // Now check for language translations
                         if (cmd == "TXT_CLOSE") TXT_CLOSE = val;
                    else if (cmd == "TXT_SELECT") TXT_SELECT= val;
                    else if (cmd == "TXT_ADD") TXT_ADD = val;
                    else if (cmd == "TXT_ADDED") TXT_ADDED = val;
                    else if (cmd == "TXT_ADD_STOCK") TXT_ADD_STOCK = val;
                    else if (cmd == "TXT_REZ") TXT_REZ= val;
                    else if (cmd == "TXT_CHECK") TXT_CHECK = val;
                    else if (cmd == "TXT_CHECKING") TXT_CHECKING =val;
                    else if (cmd == "TXT_GET_ITEM") TXT_GET_ITEM = val;
                    else if (cmd == "TXT_GET_ID") TXT_GET_ID = val;
                    else if (cmd == "TXT_SET_ID") TXT_SET_ID = val;
                    else if (cmd == "TXT_STORE_ITEM") TXT_STORE_ITEM = val;
                    else if (cmd == "TXT_LEVEL") TXT_LEVEL = val;
                    else if (cmd == "TXT_LEVELS") TXT_LEVELS = val;
                    else if (cmd == "TXT_FOUND") TXT_FOUND = val;
                    else if (cmd == "TXT_EMPTYING") TXT_EMPTYING = val;
                    else if (cmd == "TXT_STORE_EMPTY") TXT_STORE_EMPTY = val;
                    else if (cmd == "TXT_IN_INVENTORY") TXT_IN_INVENTORY = val;
                    else if (cmd == "TXT_INV_SEARCH_FAIL") TXT_INV_SEARCH_FAIL =val;
                    else if (cmd == "TXT_STOCK_OWNER") TXT_STOCK_OWNER = val;
                    else if (cmd == "TXT_LOAD_STOCK") TXT_LOAD_STOCK =val;
                    else if (cmd == "TXT_NOT_ENOUGH") TXT_NOT_ENOUGH = val;
                    else if (cmd == "TXT_NOT_FOUND") TXT_NOT_FOUND = val;
                    else if (cmd == "TXT_NOT_FOUND_ITEM") TXT_NOT_FOUND_ITEM = val;
                    else if (cmd == "TXT_NOT_FOUND100") TXT_NOT_FOUND100 = val;
                    else if (cmd == "TXT_NOT_STORED") TXT_NOT_STORED = val;
                    else if (cmd == "TXT_NO_REZ") TXT_NO_REZ = val;
                    else if (cmd == "TXT_MENU") TXT_MENU = val;
                    else if (cmd == "TXT_RIDE") TXT_RIDE = val;
                    else if (cmd == "TXT_NO_ACCOUNT") TXT_NO_ACCOUNT = val;
                    else if (cmd == "TXT_STORE_EMPTY_FAIL") TXT_STORE_EMPTY_FAIL = val;
                    else if (cmd == "TXT_ERROR_GROUP") TXT_ERROR_GROUP = val;
                    else if (cmd == "TXT_ERROR_USE") TXT_ERROR_USE = val;
                    else if (cmd == "TXT_ERROR_UPDATE") TXT_ERROR_UPDATE = val;
                    else if (cmd == "TXT_LANGUAGE") TXT_LANGUAGE = val;
                }
            }
        }
    }

    llMessageLinked(LINK_THIS, 1, "LANG_MENU|" + languageCode, "");
    llMessageLinked(LINK_SET, 1, "LANGTEXT|"+PASSWORD+"|TXT_MENU|"+TXT_MENU, "");
    llMessageLinked(LINK_SET, 1, "LANGTEXT|"+PASSWORD+"|TXT_RIDE|"+TXT_RIDE, "");
    llMessageLinked(LINK_SET, 1, "LANGTEXT|"+PASSWORD+"|TXT_ERROR_USE|"+TXT_ERROR_USE, "");
}

activate()
{
    activated = 0;

    if (stockOwner != NULL_KEY)
    {
        postMessage("task=getxp&data1=" + (string)stockOwner);
        status = "waitLinked";

        // Set a comms timeout
        llSetTimerEvent(timeout);
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

setBinId(key newID)
{

    if (llGetInventoryType(binIdNC) != INVENTORY_NOTECARD)
    {
        // No binID notecard found so make a new one
        if (newID == NULL_KEY)
        {
            binKey = (string)llGetKey();
        }
        else
        {
            binKey = newID;
        }

        osMakeNotecard(binIdNC, binKey);
    }
    else
    {
        if (newID == NULL_KEY)
        {
            binKey = llStringTrim(osGetNotecard(binIdNC), STRING_TRIM);
        }
        else
        {
            binKey = newID;
            llRemoveInventory(binIdNC);
            llSleep(0.2);
            osMakeNotecard(binIdNC, binKey);
        }
    }

    debug("BinID=" +binKey);
}

loadStock()
{
    if (stockOwner != NULL_KEY)
    {
        postMessage("task=getstock&data1=" +binKey +"&data2=" +(string)stockOwner);
        llSetTimerEvent(timeout);
    }
}

// Update our stored items data
saveStock(string item, integer transaction)
{
    integer qty;

    // Check if item already in stock
    integer invCheck = llListFindList(stockItems, [item]);

    if (invCheck != -1)
    {
        // already in stock so update total
        if (transaction == CREDIT)
        {
            qty = llList2Integer(levels, invCheck) +1;
        }
        else
        {
            qty = llList2Integer(levels, invCheck) -1;
        }

        if (qty >0)
        {
            levels = llListReplaceList(levels, [qty], invCheck, invCheck);
        }
        else
        {
            stockItems = llDeleteSubList(stockItems, invCheck, invCheck);
                levels = llDeleteSubList(levels, invCheck, invCheck);
        }
    }
    else
    {
        if (transaction == CREDIT)
        {
            // not in stock so add one to stock/levels lists
            stockItems += [item];
            levels += [1];
        }
    }

    setStock();
}

// Saves stock info to cloud
setStock()
{
    if ((llGetListLength(stockItems) >0) && (stockOwner != NULL_KEY))
    {
        debug("Saving to cloud");
        postMessage("task=setstock&data1=" +binKey +"&data2=" +(string)stockOwner +"&data3="+llDumpList2String(stockItems, "|") +"&data4="+llDumpList2String(levels, "|"));

        // Set comms timeout
        status = "stockSave";
        llSetTimerEvent(timeout);
    }
}

// Makes a list of all the products we have in our inventory
makeCatalog()
{
    catalog = [];
    integer itemsCount = llGetInventoryNumber(INVENTORY_OBJECT);
    integer i;

    for (i=0; i < itemsCount; i++)
    {
        catalog += llGetInventoryName(INVENTORY_OBJECT, i);
    }
}

sayStock()
{
    list sayList = [];
    string str = "";
    integer count = llGetListLength(stockItems);

    if (count >0)
    {
        integer i;

        for (i = 0;  i < count; i++)
        {
            sayList += [llList2String(stockItems, i), (string)(llRound(llList2Float(levels, i)))];
        }

        sayList = llListSort(sayList, 2, SORTDIR);
        count = llGetListLength(sayList);

        for (i=0;  i < count; i=i+2)
        {
            str += "\t" +llList2String(sayList, i)+": "+(string)(llRound(llList2Float(sayList, i+1)))+"\n";
        }

        str = TXT_LEVELS +"\n" + str;
    }
    else
    {
        str = ourName()+" "+TXT_STORE_EMPTY +"\n";
    }

    if (stockOwner != NULL_KEY)
    {
        str += TXT_STOCK_OWNER +": ";
        str += llKey2Name(stockOwner);
    }

    llRegionSayTo(menuUser, 0, str);
}

string ourName()
{
    return llGetSubString(llGetLinkName(LINK_ROOT), 3, -1);
}

// Answers TRUE if rezzing is permitted, FALSE if not.
integer canRez()
{
    vector pos = llGetPos();
    integer parcelFlags = llGetParcelFlags(pos);
    list parcelDetails = llGetParcelDetails(pos, [PARCEL_DETAILS_OWNER, PARCEL_DETAILS_GROUP]);
    key parcelOwner = llList2Key(parcelDetails, 0);
    key parcelGroup = llList2Key(parcelDetails, 1);
    integer result = FALSE;

    if (parcelFlags & PARCEL_FLAG_ALLOW_CREATE_OBJECTS)
    {
        result = TRUE;
    }
    else if (parcelOwner == llGetOwner())
    {
        result = TRUE;
    }
    else if (parcelFlags & PARCEL_FLAG_ALLOW_CREATE_GROUP_OBJECTS)
    {
        if (myGroup == parcelGroup) result = TRUE;
    }

    if (result == FALSE)
    {
        llRegionSayTo(menuUser, 0, TXT_NO_REZ);
    }

    return result;
}

rezzItem(string m, key agent)
{
    string object = SF_PREFIX+" " + m;

    if (llGetInventoryType(object) != INVENTORY_OBJECT)
    {
        llRegionSayTo(menuUser, 0, object + " " + TXT_NOT_STORED);

        return;
    }

    integer idx = llListFindList(stockItems, [object]);

    if (idx >= 0 && llList2Integer(levels,idx) >= singleLevel)
    {
        llMessageLinked(LINK_SET, 0, "REZ_PRODUCT|" +PASSWORD +"|" +(string)agent +"|" +object, NULL_KEY);
        lookingFor = object;
    }
    else
    {
        llRegionSayTo(menuUser, 0, TXT_NOT_ENOUGH);
    }
}

list getAvailProducts()
{
    list availProducts = [];
    integer len = llGetListLength(stockItems);

    while (len--)
    {
        if (llList2Integer(levels, len) >= singleLevel)
        {
            string shortName = llGetSubString(llList2String(stockItems, len), 3, -1);
            availProducts += [shortName];
        }
    }

    return availProducts;
}


default
{
    listen(integer c, string nm, key id, string m)
    {
        debug("listen: " +m +"  status=" +status);

        //parse buttons
        if (m == TXT_CLOSE)
        {
            checkListen(TRUE);
        }
        else if (m == TXT_ADD)
        {
            tmpkey = id;
            status = "SELL";
            startOffset = 0;
            lookingFor = "all";
            llSensor("", "", SCRIPTED, SENSOR_DISTANCE, PI);
        }
        else if (m == TXT_REZ)
        {
            status = "GET";
            list availProducts = getAvailProducts();

            if (availProducts == [])
            {
                llRegionSayTo(menuUser, 0, ourName()+" "+TXT_STORE_EMPTY);
            }
            else
            {
                startOffset = 0;
                multiPageMenu(TXT_GET_ITEM, availProducts);
            }
        }
        else if (m == TXT_CHECK)
        {
            status = "chkStkBtn";
            loadStock();
        }
        else if (m == TXT_LANGUAGE)
        {
            llMessageLinked(LINK_THIS, 1, "MENU_LANGS|" + languageCode +"|" +SUFFIX, id);
            checkListen(TRUE);
        }
        else if (m == TXT_ADD_STOCK)
        {
            startOffset = 0;
            lookingFor = "all";
            status = "stockScan";
            llSensor("", "", SCRIPTED, SENSOR_DISTANCE, PI);
        }
        else if (m == TXT_LOAD_STOCK)
        {
            status = "waitStock";
            loadStock();
        }
        else if (m == TXT_GET_ID)
        {
            llOwnerSay(TXT_GET_ID +": " +(string)binKey);
        }
        else if (m == TXT_SET_ID)
        {
            status = "waitBinId";
            llTextBox(id, TXT_SET_ID, chan(ownKey));
            llSetTimerEvent(timeout);
        }
        // Status based responses
        else if (status  == "SELL")
        {
            if (m == ">>")
            {
                startOffset += 10;
            }
            else
            {
                lookingFor = SF_PREFIX+" " +m;
                llSensor(lookingFor, "", SCRIPTED, SENSOR_DISTANCE, PI);
            }
        }
        else if (status  == "GET")
        {
            if (m == ">>")
            {
                startOffset += 10;
            }
            else
            {
                if (canRez() == TRUE) rezzItem(m, id);
            }
            list availProducts = getAvailProducts();

            if (availProducts != [])
            {
                multiPageMenu(TXT_GET_ITEM, availProducts);
            }
            else
            {
                checkListen(TRUE);
            }
        }
        else if (status == "stockScan")
        {
            lookingFor = SF_PREFIX +" " +m;

            if (llGetInventoryType(lookingFor) != INVENTORY_OBJECT)
            {
                status = "waitNewInventory";
                llRegionSayTo(menuUser, 0, TXT_CHECKING);
                llSetText(TXT_CHECKING+"\n"+ lookingFor, TXT_COLOR, 1.0);
                llMessageLinked(LINK_SET, 0, "GET_PRODUCT|" +PASSWORD +"|" +lookingFor, NULL_KEY);
            }
            else
            {
                llRegionSayTo(menuUser, 0, TXT_IN_INVENTORY+": "+lookingFor);
                status = "";
            }
        }
        else if (status == "waitBinId")
        {
            setBinId((key)m);
        }
    }

    dataserver(key k, string m)
    {
        list tk = llParseStringKeepNulls(m, ["|"] , []);
        string cmd = llList2String(tk, 0);
        debug("dataserver: " + m + "  (cmd: " + cmd +")");

        if (llList2String(tk,1) != PASSWORD )
        {
            return;
        }

        if (cmd == "INIT")
        {
            loadConfig();
            loadLanguage(languageCode);
            llSetRemoteScriptAccessPin(0);
            activate();
        }
        else if (cmd == "CMD_BACKPACK")
        {
            myGroup = llList2Key(llGetObjectDetails(ownKey, [OBJECT_GROUP]), 0);
            showMenu();
        }
        //for updates
        else if (cmd == "VERSION-CHECK")
        {
            string answer = "VERSION-REPLY|" + PASSWORD + "|";

            // Used to multiply by 10 as version was e.g. 5.5 but now by 100 so we can support version = 5.51
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
        }
        else if (cmd == "DO-UPDATE")
        {
            if (llGetOwnerKey(k) != llGetOwner())
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
        else if (cmd == "GIVE")
        {
            string productName = llList2String(tk,2);
            key u = llList2Key(tk,3);
            integer idx = llListFindList(stockItems, [productName]);

            if (idx>=0 && llList2Float(levels, idx) > singleLevel )
            {
                messageObj(u, "HAVE|"+PASSWORD+"|"+productName+"|"+(string)ownKey);
                llMessageLinked(LINK_SET, 99, "REZZEDPRODUCT|" + (string)u + "|" + productName, NULL_KEY);
                saveStock(productName, DEBIT);
            }
            else
            {
                llRegionSayTo(menuUser, 0, productName + "-" + TXT_NOT_ENOUGH);
            }
        }
        else
        {
            // Something has 'died' so we can now add it to the store
            integer i;

            for (i=0; i < llGetListLength(stockItems); i++)
            {
                if (llToUpper(llList2String(stockItems,i)) ==  cmd)
                {
                    llRegionSayTo(menuUser, 0, TXT_ADDED +" " +llToLower(cmd) +", " +TXT_LEVEL +" " +llList2String(levels, i));
                    saveStock(cmd, CREDIT);

                    return;
                }
            }
        }
    }

    on_rez(integer n)
    {
        llResetScript();
    }

    timer()
    {
        if ((status == "waitNewInventory") || (status == "stockScan"))
        {
            llSetText("", ZERO_VECTOR, 0);
            checkListen(FALSE);
            status = "";
        }
        else if (status == "waitLinked")
        {
            activated = FALSE;
            status = "";
        }
        else if (status == "waitStock")
        {
            //  Timeout on wait stock
        }
        else if (status == "waitBinId")
        {
            checkListen(FALSE);
            status = "";
        }
        else if (status == "emptyingCart" || "saveAfterReSat" || "saveAfterStood")
        {
            // Timeout on saving stock to cloud
            if (status == "emptyingCart")
            {
                llRegionSayTo(menuUser, 0, TXT_STORE_EMPTY_FAIL);
            }
            else if (status == "saveAfterStood")
            {
                activated = FALSE;
            }
            status = "";
        }
        else if (status == "stockSave")
        {
            // Save stock to cloud failed
        }
        else
        {
            checkListen(FALSE);
        }

        llSetTimerEvent(1000);
    }

    touch_start(integer n)
    {
        menuUser = llDetectedKey(0);

        if ((menuUser == llGetOwner()) || (allowGroupUse == TRUE))
        {
            if (llSameGroup(menuUser) == TRUE)
            {
                myGroup = llList2Key(llGetObjectDetails(ownKey, [OBJECT_GROUP]), 0);
                showMenu();
            }
            else
            {
                llRegionSayTo(menuUser, 0, TXT_ERROR_GROUP);
                menuUser = NULL_KEY;
            }
        }
        else
        {
            llRegionSayTo(menuUser, 0, TXT_ERROR_USE);
            menuUser = NULL_KEY;
        }
    }

    sensor(integer n)
    {
        if (lookingFor == "all")
        {
            list buttons = [];
            string shortName;
            string name;
            string desc;

            while (n--)
            {
                name = llKey2Name(llDetectedKey(n));
                shortName = llGetSubString(llKey2Name(llDetectedKey(n)), 3, -1);

                if (status == "stockScan")
                {
                    if (llListFindList(buttons, [shortName]) == -1)
                    {
                        desc= llList2String(llGetObjectDetails(llDetectedKey(n), [OBJECT_DESC]), 0);
                        
                        if (llGetSubString(desc, 0,1) == "P;")
                        {
                            buttons += [shortName];
                        }
                    }
                }
                else if (llListFindList(catalog, [name]) != -1 && llListFindList(buttons, [shortName]) == -1)
                {
                    buttons += [shortName];
                }
            }
            if (buttons == [])
            {
                if (selitems == [])
                {
                    llRegionSayTo(menuUser, 0, TXT_NOT_FOUND);
                }

                checkListen(TRUE);
            }
            else
            {

                if (status == "stockScan")
                {
                    // put buttons so closest will appear on the top left
                    buttons = listReverse(buttons);
                }

                multiPageMenu(TXT_STORE_ITEM, buttons);
            }
        }
        else
        {
            //get first product that isn't already selected and has enough percentage
            key obj;
            list stats =[];
            integer have_percent;
            integer c;
            key ready_obj = NULL_KEY;

            for (c = 0; ready_obj == NULL_KEY && c < n; c++)
            {
                obj = llDetectedKey(c);
                stats = llParseString2List(llList2String(llGetObjectDetails(obj,[OBJECT_DESC]),0), [";"], []);
                have_percent = llList2Integer(stats, 1);

                // have_percent == 0 for backwards compatibility with old items
                if (llListFindList(selitems, [obj]) == -1 && (have_percent == 100 || have_percent == 0))
                {
                    ready_obj = llDetectedKey(c);
                }
            }
            
            if (ready_obj == NULL_KEY)
            {
                llRegionSayTo(menuUser, 0, lookingFor + " " + TXT_NOT_FOUND100);
            }
            else
            {
                selitems += [ready_obj];
                llRegionSayTo(menuUser, 0, TXT_FOUND +"  " +lookingFor + ", " + TXT_EMPTYING);
                saveStock(lookingFor, CREDIT);
                messageObj(ready_obj, "DIE|"+(string)ownKey);

                if (status == "SELL")
                {
                    lookingFor = "all";
                    llSensor("", "", SCRIPTED, SENSOR_DISTANCE, PI);
                }
            }
        }
    }

    no_sensor()
    {
        if (lookingFor == "all" && selitems == [])
        {
            llRegionSayTo(menuUser, 0, TXT_NOT_FOUND);
        }
        else
        {
            llRegionSayTo(menuUser, 0, lookingFor +" " +TXT_NOT_FOUND100);
        }

        checkListen(TRUE);
    }

    state_entry()
    {
        menuUser = llGetOwner();
        ownKey = llGetKey();
        loadConfig();
        loadLanguage(languageCode);

        if (autoAttach == TRUE)
        {
            llRequestPermissions(menuUser, PERMISSION_ATTACH);
        }
        else
        {
            stockOwner = menuUser;
        }

        setBinId(NULL_KEY);
        makeCatalog();
        activate();
    }

    link_message(integer sender, integer val, string m, key id)
    {
        //debug("link_message: " +m +"  Val="+(string)val);
        list tk = llParseString2List(m, ["|"], []);
        string cmd = llList2String(tk, 0);

        if (cmd == "SET-LANG")
        {
            languageCode = llList2String(tk, 1);
            loadLanguage(languageCode);
            llSetObjectDesc("S;" + languageCode);
        }
        else if (cmd == "VERSION-REQUEST")
        {
            llMessageLinked(LINK_SET, (integer)(100*VERSION), "VERSION-REPLY|"+NAME, "");
        }
        // Messages from other things such as the NPC horse & cart
        else if (cmd == "USER_SIT")
        {
            seated = val;
            if (seated == TRUE)
            {
                // someone sat
                if (id != stockOwner)
                {
                    // New person sat down so save current stock to cloud
                    if (stockOwner != NULL_KEY) setStock();

                    // Now clear and set up for new stock owner
                    stockItems = [];
                    levels = [];
                    stockOwner = id;
                    activate();
                }
                else
                {
                    status = "saveAfterReSat";
                    setStock();
                }
            }
            else
            {
                // stockOwner stood up
                status = "saveAfterStood";
                setStock();
            }
        }
        else if (cmd == "WAS_TOUCHED")
        {
            menuUser = id;

            if ((menuUser == llGetOwner()) || (allowGroupUse == TRUE))
            {
                if (llSameGroup(menuUser) == TRUE)
                {
                    myGroup = llList2Key(llGetObjectDetails(ownKey, [OBJECT_GROUP]), 0);
                    showMenu();
                }
            }
            else
            {
                llRegionSayTo(menuUser, 0, TXT_ERROR_USE);
                menuUser = NULL_KEY;
            }
        }
        else if (cmd == "PRODUCT_FOUND")
        {
            llSetText("", ZERO_VECTOR,0);
            llRegionSayTo(menuUser, 0, TXT_ADDED+": "+lookingFor);
            llPlaySound(okayFX, 10.0);
            llSleep(0.2);
            llResetScript();
        }
        else if (cmd == "NO_PRODUCT")
        {
            llSetText(TXT_INV_SEARCH_FAIL+"\n \n  "+lookingFor, TXT_COLOR, 1.0);
            llRegionSayTo(menuUser, 0, TXT_INV_SEARCH_FAIL+": "+lookingFor);
            llPlaySound(failFX, 10.0);
            llSleep(0.2);
            llSetTimerEvent(5);
        }
    }

    object_rez(key id)
    {
        llSleep(0.4);

        if (llGetListLength(llGetObjectDetails(id, [OBJECT_NAME])) !=0)
        {
            messageObj(id, "INIT|" +PASSWORD);
        }

        llMessageLinked(LINK_SET, 91, "REZZED|"+(string)id, NULL_KEY);
        saveStock(lookingFor, DEBIT);
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            loadConfig();
            loadLanguage(languageCode);
            setBinId(NULL_KEY);
        }

        if (change & CHANGED_OWNER)
        {
            if (llGetInventoryType(binIdNC) == INVENTORY_NOTECARD)
            {
                llRemoveInventory(binIdNC);
            }

            llSetObjectDesc("");
            llSleep(0.5);
            llResetScript();
        }
    }

    run_time_permissions(integer vBitPermissions)
    {
        if (vBitPermissions & PERMISSION_ATTACH)
        {
            string data = llGetObjectName();

            if (data == "FRMHUD")
            {
                if (vBitPermissions & PERMISSION_ATTACH)
                {
                    llAttachToAvatarTemp(ATTACH_BACK);
                }
            }
            else
            {
                if (vBitPermissions & PERMISSION_ATTACH)
                {
                    llAttachToAvatar(ATTACH_BACK);
                }
            }

            llSetObjectName(NAME);
            menuUser = llGetOwner();
            stockOwner = menuUser;
            activate();
        }
    }

    attach(key id)
    {
        if (id != NULL_KEY) stockOwner = id;
    }

    http_response(key request_id, integer Status, list metadata, string body)
    {
        if (request_id == farmHTTP)
        {
            list tok = llJson2List(body);
            string cmd = llList2String(tok, 0);

            debug("http_response - Status: " + Status + "\nbody: " + body + "\nCMD=" + cmd +" data=" +llDumpList2String(tok, "|"));

            if (cmd == "FAIL")
            {
                debug("An unknown command was sent:" +llList2String(tok, 1));
            }
            else if (cmd == "XPTOTAL")
            {
                // Were we waiting to link in a new stock owner?
                if (status == "waitLinked")
                {
                    if (llList2String(tok, 1) != "NOID")
                    {
                        activated = TRUE;
                        stockOwner = menuUser;

                        if (stockOwner != NULL_KEY)
                        {
                            status = "waitStock";
                            loadStock();
                        }
                    }
                    else
                    {
                        // invalid user
                        llRegionSayTo(menuUser, 0, TXT_NO_ACCOUNT);
                    }
                }
            }
            else if (cmd == "GETSTOCK")
            {
                // If we get the FAIL message, no bin exists yet
                if (llList2String(tok, 1) == "FAIL")
                {
                    // setstock(binID, osID, Stock_Items, Stock_Qty)
                    postMessage("task=setstock&data1=" +binKey +"&data2=" +(string)stockOwner +"&data3=&data4=");
                }
                else if (llGetListLength(tok) >1)
                {
                    // Update the stocklist with the one stored on the server
                    string item;  integer qty;
                    stockItems = [];
                    levels = [];

                    string items = llList2String(tok, 1);
                    stockItems = llParseString2List(items, ["|"], []);

                    string values = llList2String(tok, 3);
                    levels = llParseString2List(values, ["|"], []);

                    if ((status == "chkStkBtn") || (sayStockLevels == TRUE)) sayStock();
                    status = "";
                }
            }
            else if (cmd == "SETSTOCK")
            {
                if (llList2String(tok,1) != "INVALID-A")
                {
                    // stock was saved to cloud okay
                    if (status == "saveAfterReSat")
                    {
                        // re-load the updated data back
                        activate();
                    }
                    else if (status == "emptyingCart")
                    {
                        llRegionSayTo(menuUser, 0, ourName()+" "+TXT_STORE_EMPTY);
                        stockOwner = NULL_KEY;
                        stockItems = [];
                        levels = [];
                        status = "";
                        setStock();
                    }
                    else if (status == "saveAfterStood")
                    {
                        menuUser = NULL_KEY;
                        status = "";
                    }
                    else if (status == "stockSave")
                    {
                        status = "";
                    }
                }
                else
                {
                    if (llList2String(tok, 1) == "INVALID-A")
                    {
                        if (status != "saveAfterStood") llRegionSayTo(menuUser, 0, TXT_NO_ACCOUNT);
                    }
                    else
                    {
                        llRegionSayTo(menuUser, 0, TXT_STORE_EMPTY_FAIL);
                    }
                }
            }
        }
        else
        {
            debug("NOT FOR US: " +body);
        }
    }

}
