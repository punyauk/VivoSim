// messages-display_screen.lsl
//
// Message display and manager for VivoSim message system
//
//  Version 6.00    // 10 March 2023

string BASEURL="http://vivosim.net/index.php/?option=com_vivos&view=vivos&type=vivos&format=json&";

integer DEBUGMODE = TRUE;

debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DB_" + llToUpper(llGetScriptName()) + " " + text);
}

// Variables from config notecard
integer useSound = TRUE;            // USE_SOUND=1       ; Set to 1 to play a sound when new messages arrive
float   volume = 1.0;               // VOLUME=10         ; Set from 1 to 10 (10 is loudest)
integer displayFace = 4;			// DISPLAY_FACE=4    ; Which face to display information on
string  fontName = "Tahoma";        // FONT=Tahoma       ; Also Arial or Georgia etc. See https://www.w3schools.com/cssref/css_websafe_fonts.php
integer fontSize = 14;				// FONT_SIZE=14		 ;
string  languageCode = "en-GB";		// LANG=en-GB        ; Default language to use

// Language strings
string TXT_LIST_MESSAGES = "List";
string TXT_DELETE_MESSAGE = "Delete...";
string TXT_CLOSE = "CLOSE";
string TXT_MSG_ID_DELETE = "Message ID to delete";
string TXT_MSG_ADD = "Type your message";
string TXT_PROMPT = "VivoSim message system:";
string TXT_ADDED = "Message added okay";
string TXT_DELETED = "Message deletion sent";
string TXT_NO_MSGS = "No messages available";
string TXT_TALKING_TO_SERVER = "Talking to server...";
string TXT_VERIFY_ERROR = "Sorry, unable to verify with server";
string TXT_SEND_PRIVATE_MESSAGE = "Send Private message";
string TXT_NO_DELETE = "Sorry, that is a public message and can't be deleted";

string SUFFIX = "";

// Colours
vector RED      = <1.000, 0.255, 0.212>;
vector GREEN    = <0.180, 0.800, 0.251>;
vector PURPLE   = <0.694, 0.051, 0.788>;

//
integer dialogChannel;
key     farmHTTP  = NULL_KEY;
string  PASSWORD  = "*";
string  pwNC      = "sfp";
string  soundFile = "";
key     blankScreen = "fb3d5f6c-2d48-4a42-9714-dc74da3c4ea7";
key     ownerID;
string  status;
integer waitInterval = 60;
integer listener = -1;
list    messages = [];      // [msgID, timeStamp, Message)];


integer chan(key u)
{
    return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

string generateID(integer private)
{
    string result = (string)llGetUnixTime();

    if (private == TRUE)
    {
        result = "PRV" + result;
    }

    debug("GeneratedID=" + result);

    return result;
}

postMessage(string msg)
{
    debug("post:" +msg + " to " +BASEURL);
    farmHTTP = llHTTPRequest( BASEURL, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"], msg);
}

floatText(string msg, vector colour)
{
    llSetText(msg, colour, 1.0);
    llOwnerSay(msg);
}

displayMessages(integer alsoSay)
{
    string output = "";
    integer count = llGetListLength(messages);
    integer index = 1;
    integer i;

    string body = "width:1024, height:512, Alpha:256";
    string commandList = "";  // Storage for our drawing commands

    if (count >1)
    {
        // Prepare output line as index count then time/date on one line then message on next
        for (i=0; i < count; i += 3)
        {
            output += "(" +(string)(index) +") " +llList2String(messages, i+1) +("\n") +llList2String(messages, i+2) +"\n \n";
            index ++;
        }

        llSetTexture(blankScreen, displayFace);
        commandList = osSetPenColor(commandList, "Blue");
        commandList = osSetFontSize(commandList, fontSize);
        commandList = osMovePen(commandList, 10, 5);
    }
    else
    {
        output = TXT_NO_MSGS;
        commandList = osSetPenColor(commandList, "Orange");
        commandList = osSetFontSize(commandList, fontSize * 3);
        vector Extents = osGetDrawStringSize( "vector", output, fontName, fontSize * 3);
        integer xpos = 500 - ((integer) Extents.x >> 1);    // Center the text horizontally
        commandList = osMovePen(commandList, xpos, 200);
    }

    // Prepare for screen display

    commandList = osSetFontName(commandList, fontName);
    commandList = osDrawText(commandList, output);

    // Display it!
    osSetDynamicTextureDataBlendFace("", "vector", commandList, body, FALSE, 10, 5, 255, displayFace);

    if (alsoSay == TRUE) llOwnerSay("\n" + output);
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

                     if (cmd == "USE_SOUND") useSound = (integer)val;
                else if (cmd == "DISPLAY_FACE") displayFace = (integer)val;
                else if (cmd == "FONT") fontName = val;
                else if (cmd == "FONT_SIZE") fontSize = (integer)val;
                else if (cmd == "LANG") languageCode = val;
                else if (cmd == "VOLUME") volume = 0.1 * (float)val;

                if (volume > 1.0) volume = 1.0;
                 else if (volume < 0.1) volume = 0.1;
            }
        }

        // Use the first sound file we find
        if (llGetInventoryNumber(INVENTORY_SOUND) != 0 )
        {
            soundFile = llGetInventoryName(INVENTORY_SOUND, 0);
        }
        else
        {
            // No sound file found so turn off sound feature
            useSound = FALSE;
            soundFile = "";
        }
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
                         if (cmd == "TXT_SEND_PRIVATE_MESSAGE") TXT_ADD_PRIVATE_MESSAGE = val;
                    else if (cmd == "TXT_ADDED") TXT_ADDED = val;
                    else if (cmd == "TXT_CLOSE") TXT_CLOSE = val;
                    else if (cmd == "TXT_DELETE_MESSAGE") TXT_DELETE_MESSAGE = val;
                    else if (cmd == "TXT_DELETED") TXT_DELETED = val;
                    else if (cmd == "TXT_LIST_MESSAGES") TXT_LIST_MESSAGES = val;
                    else if (cmd == "TXT_MSG_ADD") TXT_MSG_ADD = val;
                    else if (cmd == "TXT_MSG_ID_DELETE") TXT_MSG_ID_DELETE = val;
                    else if (cmd == "TXT_NO_MSGS") TXT_NO_MSGS = val;
                    else if (cmd == "TXT_PROMPT") TXT_PROMPT = val;
                    else if (cmd == "TXT_TALKING_TO_SERVER") TXT_TALKING_TO_SERVER = val;
                    else if (cmd == "TXT_VERIFY_ERROR") TXT_VERIFY_ERROR = val;
                    else if (cmd == "TXT_NO_DELETE") TXT_NO_DELETE =val;
                }
            }
        }
    }
}

// --- STATE DEFAULT -- //

default
{

    state_entry()
    {
        ownerID = llGetOwner();
        loadConfig();
        loadLanguage(languageCode);
        llSetTexture(blankScreen, displayFace);
        messages = [];
        llSetTimerEvent(1);
    }

    touch_end(integer index)
    {
        if (llDetectedKey(0) == ownerID)
        {
            floatText("", ZERO_VECTOR);
            llSetTimerEvent(waitInterval);
            list options = [TXT_LIST_MESSAGES, TXT_SEND_PRIVATE_MESSAGE, TXT_DELETE_MESSAGE, TXT_CLOSE];
            listener = llListen(chan(llGetKey()), "", "", "");
            llDialog(ownerID, TXT_PROMPT, options, chan(llGetKey()));
        }
    }

    timer()
    {
        floatText(TXT_TALKING_TO_SERVER, PURPLE);
        llSetTimerEvent(waitInterval);
        llListenRemove(listener);
        postMessage("task=msglist&data1=" +(string)ownerID);
    }

    listen(integer c, string nm, key id, string m)
    {
        debug("listen: " + m +"  Status=" +status);

        if (m == TXT_CLOSE)
        {
            llSetTimerEvent(1);
        }
        else if (m == TXT_LIST_MESSAGES)
        {
            floatText(TXT_TALKING_TO_SERVER, PURPLE);
            status = "listRequested";
            postMessage("task=msglist&data1=" +(string)id);
        }
        else if (m == TXT_ADD_PRIVATE_MESSAGE)
        {
            listener = llListen(chan(llGetKey()), "", "", "");
            status = "waitPrivateMessage";
            llTextBox(id, TXT_MSG_ADD, chan(llGetKey()));
        }
        else if (m == TXT_DELETE_MESSAGE)
        {
            displayMessages(TRUE);
            listener = llListen(chan(llGetKey()), "", "", "");
            status = "waitID";
            llTextBox(id, TXT_MSG_ID_DELETE, chan(llGetKey()));
        }
        else
        {
            if (status == "waitPrivateMessage")
            {
                floatText(TXT_TALKING_TO_SERVER, PURPLE);
                status = "";
                list stream = llParseStringKeepNulls(m, ["|"], []);
                m = llList2String(stream, 1);
                postMessage("task=msgadd&data1=" +m +"&data2=" +generateID(TRUE) +"&data3=" +llList2String(stream, 0));
            }
            else if (status == "waitID")
            {
                // [msgID, timeStamp, Message)]    Message number equates to the item store in last at  (m - 1) * 3
                integer num = (integer)m;
                num = (num  -1) * 3;

                string msgID = llList2String(messages, num);
                string prefix = llGetSubString(msgID, 0, 2);

                if (prefix == "PRV")
                {
                    // This is a private message so they can delete it
                    postMessage("task=msgdel&data1=" + msgID +"&data2=" +(string)ownerID);
                    status = "";
                }
                else
                {
                    llOwnerSay(TXT_NO_DELETE);
                }
            }
        }
    }

    http_response(key request_id, integer Status, list metadata, string body)
    {
        debug("http_response:" +body);
        if (request_id == farmHTTP)
        {
            floatText("", ZERO_VECTOR);

            list tk = llJson2List(body);
            string cmd = llList2String(tk, 0);

            if (cmd == "MSGADD")
            {
                floatText(TXT_ADDED, GREEN);
                llSetTimerEvent(1);
            }
            else if (cmd == "MSGDEL")
            {
                floatText(TXT_DELETED, GREEN);
                llSetTexture(blankScreen, displayFace);
                llSetTimerEvent(1);
            }

            else if (cmd == "MSGCOUNT")
            {
                if (status == "listRequested") llOwnerSay(TXT_PROMPT);

                list tok = llJson2List(llList2String(tk, 3));
                integer count = 2 * llList2Integer(tk, 1);
                string output = "";
                string timeStamp;
                string msgID;

                integer currentMessageCount = (llGetListLength(messages));
                messages = [];

                if (count > 1)
                {
                    integer i;
                    string prefix;

                    for (i=0; i < count; i += 2)
                    {
                        msgID = llList2String(tok,i+1);
                        prefix = llGetSubString(msgID, 0, 2);

                        if (prefix == "PRV")
                        {
                            // For private messages, the ID PRV plus UnixTime
                            timeStamp = osUnixTimeToTimestamp((integer)llGetSubString(msgID, 3, -1));
                        }
                        else
                        {
                            // For public messages the ID is UnixTime
                            timeStamp = osUnixTimeToTimestamp((integer)msgID);
                        }

                        // Replace the T from the timestamp with blank space to make things look nicer
                        timeStamp = osReplaceString(timeStamp, "T", " ", 1, 0);

                        // Remove the seconds
                        timeStamp = llGetSubString(timeStamp, 0, 15);

                        if (prefix == "PRV")
                        {
                            messages += [msgID, timeStamp, llList2String(tok, i)];
                        }
                        else
                        {
                            messages += [msgID, timeStamp, "* " +llList2String(tok, i)];
                        }
                    }
                }

                // If message list is bigger than before then a new mssage has been added
                if ((llGetListLength(messages) > currentMessageCount) && (useSound == TRUE)) llPlaySound(soundFile, volume);

                if (status == "listRequested") displayMessages(TRUE); else displayMessages(FALSE);

                status = "";
            }
        }
    }

}
