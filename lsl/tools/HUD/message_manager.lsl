/*
 * message_manager.lsl
 * Message manager for VivoSim
 * @version    6.05
 * @date       19 May 2023
*/

// Should we handle touch events or let another script do it?
integer handleTouch = FALSE;

integer DEBUGMODE = FALSE;

debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DB_" + llToUpper(llGetScriptName()) + " " + text);
}

// Variables from config notecard
integer useSound = TRUE;            // EFFECTS=1            ; Set to 1 to play a sound when new messages arrive
float   volume = 1.0;                // VOLUME=10            ; Set from 1 to 10 (10 is loudest)
string  fxSound = "alert";            // ALERT_SOUND=alert    ;
integer autoHide = FALSE;            // AUTO_HIDE=0            ; Set to 1 to have screen hide messages after a certain time, 0 otherwise
string  languageCode = "en-GB";        // LANG=en-GB            ; Default language to use
string  fontName = "Tahoma";        // FONT=Tahoma            ; Also Arial or Georgia etc. See https://www.w3schools.com/cssref/css_websafe_fonts.php
integer fontSize = 14;                // FONT_SIZE=14;
integer messageFace = -1;            // MESSAGE_FACE=0        ; Which face to display messages on. Set to -1 if no screen
integer xOffset = 0;                // X_OFFSET=0            ; Offsets to adjust top left corner of displayed text
integer yOffset = 0;                // Y_OFFSET=0

// Language strings
string TXT_ADDED = "Message added okay";
string TXT_SEND_PRIVATE_MESSAGE = "Send message";
string TXT_CLOSE = "CLOSE";
string TXT_DELETED = "Message deletion sent";
string TXT_DELETE_MESSAGE = "Delete...";
string TXT_LIST_MESSAGES = "List";
string TXT_MSG_ID_DELETE = "Message ID to delete";
string TXT_MSG_ADD = "Type your message";
string TXT_NO_DELETE = "Sorry, that is a public message and can't be deleted";
string TXT_NO_FRIEND = "Sorry, can't locate that friend on the server";
string TXT_NO_MSGS = "No messages available";
string TXT_PROMPT = "VivoSim message system:";
string TXT_TALKING_TO_SERVER = "Talking to server...";
string TXT_TIMEOUT = "Sorry, timed out waiting for your response.";
string TXT_NO_ACCOUNT = "Sorry, you need a VivoSim linked to your avatar to use the messaging system";
string TXT_XP = "XP";
string SUFFIX = "M3";

// Colours
vector RED      = <1.000, 0.255, 0.212>;
vector GREEN    = <0.180, 0.800, 0.251>;
vector PURPLE   = <0.694, 0.051, 0.788>;

// Constants for message types
string PRV = "PRV";
string GRP = "GRP";
string PUB = "PUB";

integer dialogChannel;
key     farmHTTP  = NULL_KEY;
string  PASSWORD  = "*";
string  pwNC      = "sfp";
string  soundFile = "";
key     blankScreen = "blanktex";
key     ownerID;
string  groupID;
string  status;
integer timeOut = 45;        // How long before a timeout for dialog boxes/server comms
integer listener = -1;
list    friendNames = [];
list    friendIDs = [];
list    messages = [];        // [msgID, timeStamp, Message, sender];
list    btnList = [];
string  infoText;
string  sendTo;
integer startOffset = 0;
integer pollInterval = 180;    // How often to poll for new messages
integer unread;
string  ourXP = "-";
integer hasAccount;
integer storedMsgCount;


integer chan(key u)
{
    return -1 - (integer)("0x" + llGetSubString( (string) u, -6, -1) )-393;
}

string generateID(string msgType)
{
    string result = (string)llGetUnixTime();
    result = msgType + result;
    debug("GeneratedID=" + result);

    return result;
}

postMessage(string msg)
{
    debug("post:" +msg + " via LinkMsg");
    farmHTTP = llGetKey();
    llMessageLinked(LINK_SET, 1, "CMD_POST|"+msg, farmHTTP);
}

floatText(string msg, vector colour)
{
     llMessageLinked(LINK_SET, 1 , "TEXT|" + msg + "|" + (string)colour + "|", NULL_KEY);
}

multiPageMenu(key id, string message, list opt)
{
    integer l = llGetListLength(opt);
    integer ch = chan(llGetKey());

    // Make sure dialog box won't complain if loads of messages
    if (llStringLength(message) > 500)
    {
        message = llGetSubString(message, 0, 500);
    }

    if (l < 12)
    {
        llDialog(id, message, opt +[TXT_CLOSE], ch);
    }
    else
    {
        if (startOffset >= l) startOffset = 0;
        list its = llList2List(opt, startOffset, startOffset + 9);
        llDialog(id, message, its +[">>", TXT_CLOSE], ch);
    }
}

friendPicker(key id)
{
    listener = llListen(chan(llGetKey()), "", "", "");
    status = "waitPrivateMessageUser";

    integer i;
    integer total = llGetListLength(friendNames);
    btnList = [];
    infoText = "";

    for (i = 0; i < total; i++)
    {
        btnList += [(string)(i+1)];
        infoText += (string)(i+1) + " " + llList2String(friendNames, i) +"\n";
    }

    multiPageMenu(id, infoText, btnList);
}

displayMessages(integer alsoSay)
{
    string output = "";
    integer count = llGetListLength(messages);
    integer index = 1;
    integer i;

    string body = "width:1024, height:512, Alpha:0";
    string commandList = "";  // Storage for our drawing commands

    // First set up display of users XP
    commandList = osSetPenColor(commandList, "Green");
    commandList = osSetFontSize(commandList, fontSize +1);
    commandList = osMovePen(commandList, 900, 10);
    commandList = osDrawText(commandList, TXT_XP + ": " +ourXP);

    // Now display any messages
    if (count >1)
    {
        // Prepare output line as index count then time/date on one line then message on next
        for (i=0; i < count; i += 4)
        {
            output += "(" +(string)(index) +") " +llList2String(messages, i+1) +("\n") +llList2String(messages, i+2) +"\n"   +llList2String(messages, i+3) +"\n \n";
            index ++;
        }

        commandList = osSetPenColor(commandList, "Blue");
        commandList = osSetFontSize(commandList, fontSize);
        commandList = osMovePen(commandList, 10 + xOffset, 15 + yOffset);
    }
    else
    {
        // No messages available
        if (messageFace != -1) output = TXT_NO_MSGS; else output = "";

        commandList = osSetPenColor(commandList, "Orange");
        commandList = osSetFontSize(commandList, fontSize * 3);
        vector Extents = osGetDrawStringSize( "vector", output, fontName, fontSize * 3);
        integer xpos = 500 - ((integer) Extents.x >> 1);    // Center the text horizontally
        commandList = osMovePen(commandList, xpos, 200);
    }

    // Prepare for screen display
    commandList = osSetFontName(commandList, fontName);
    commandList = osDrawText(commandList, output);

    if (messageFace != -1)
    {
        // Display it!
        llSetTexture(blankScreen, messageFace);
        osSetDynamicTextureDataBlendFace("", "vector", commandList, body, TRUE, 2, 0, 128, messageFace);
    }
    else
    {
        if (count >1)
        {
            llMessageLinked(LINK_SET, 1 , "TEXT|" + output + "|" + (string)GREEN + "|", NULL_KEY);
        }
    }

    if (alsoSay == TRUE) llOwnerSay("\n" + output);
}

processMessages(list stream)
{
    llSetTimerEvent(0);

    if (status == "listRequested") llOwnerSay(TXT_PROMPT);

    list msgs = llJson2List(llList2String(stream, 3));
    integer count = 3 * llList2Integer(stream, 1);

    string  output = "";
    string  timeStamp;
    string  msgID;
    string  sender;
    integer grpID;
    integer i;
    integer index;
    integer currentMessageCount = (llGetListLength(messages));
    messages = [];

    if (count > 1)
    {
        string prefix;

        for (i=0; i < count; i += 3)
        {
            sender = llList2String(msgs, i+2);
            index = llListFindList(friendIDs, sender);

            if (index != -1)
            {
                sender = "-" +llList2String(friendNames, index) +"-";
            }
            else
            {
                sender = "-?-";
            }

            msgID = llList2String(msgs,i+1);
            prefix = llGetSubString(msgID, 0, 2);

            if (prefix == PRV)
            {
                // For private messages, the ID PRV plus UnixTime
                timeStamp = osUnixTimeToTimestamp((integer)llGetSubString(msgID, 3, -1));
            }
            else if (prefix = GRP)
            {
                // TO DO
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

            if (prefix == PRV)
            {
                messages += [msgID, timeStamp, llList2String(msgs, i), sender];
            }
            else
            {
                messages += [msgID, timeStamp, "* " +llList2String(msgs, i), sender];
            }
        }

        // If message list is bigger than before then a new message has been added
        if (llGetListLength(messages) > currentMessageCount)
        {
            // Set the number of unread messages since last check
            unread = (llGetListLength(messages) - currentMessageCount);
            unread = unread / 4;

            // Send a message to any attached prims that may support a new message indicator
            llMessageLinked(LINK_SET, unread, "NEW_MESSAGE", "");

            if (useSound == TRUE) llPlaySound(fxSound, volume);

        }

        if (status == "listRequested")
        {
            displayMessages(TRUE);
        }
        else
        {
            if (autoHide == FALSE) displayMessages(FALSE);
        }

        status = "";

        // Set timer to poll for new messages in a while
        llSetTimerEvent(pollInterval);
    }
}

loadConfig()
{
    // Check if there is a config notecard
    if (llGetInventoryType("config") == INVENTORY_NOTECARD)
    {
        //sfp 'password' notecard
        if (llGetInventoryType(pwNC) == INVENTORY_NOTECARD)
        {
            PASSWORD = osGetNotecardLine(pwNC, 0);
        }

        list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
        list tok;
        string cmd;
        string val;
        integer i;

        for (i=0; i < llGetListLength(lines); i++)
        {
            tok = llParseString2List(llList2String(lines,i), ["="], []);

            if (llList2String(tok, 1) != "")
            {
                cmd = llStringTrim(llList2String(tok, 0), STRING_TRIM);
                val = llStringTrim(llList2String(tok, 1), STRING_TRIM);

                     if (cmd == "EFFECTS") useSound = (integer)val;
                else if (cmd == "ALERT_SOUND") fxSound = val;
                else if (cmd == "MESSAGE_FACE") messageFace = (integer)val;
                else if (cmd == "FONT") fontName = val;
                else if (cmd == "FONT_SIZE") fontSize = (integer)val;
                else if (cmd == "LANG") languageCode = val;
                else if (cmd == "AUTO_HIDE") autoHide = (integer)val;
                else if (cmd == "X_OFFSET") xOffset = (integer)val;
                else if (cmd == "Y_OFFSET") yOffset = (integer)val;
                else if (cmd == "VOLUME") volume = 0.1 * (float)val;

                if (volume > 1.0)
                {
                    volume = 1.0;
                }
                else if (volume < 0.1)
                {
                    volume = 0.1;
                }
            }
        }
    }

    // Check sound file exists
    if (llGetInventoryType(fxSound) != INVENTORY_SOUND)
    {
        // No sound file found so turn off sound feature
        useSound = FALSE;
        fxSound = "";
    }

        // Check 'blanking' texture file exists
        if (llGetInventoryType(blankScreen) != INVENTORY_TEXTURE)
        {
            // No texture file found so set to default BLANK
            blankScreen = "TEXTURE_BLANK";
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
     string cmd;
     string val;
     list   tok;
     integer i;

     for (i=0; i < llGetListLength(lines); i++)
     {
         line = llList2String(lines, i);

         if (llGetSubString(line, 0, 0) != ";")
         {
             tok = llParseString2List(line, ["="], []);

             if (llList2String(tok,1) != "")
             {
                 cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
                 val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

                 // Remove start and end " marks
                 val = llGetSubString(val, 1, -2);

                 // Now check for language translations
                      if (cmd == "TXT_SEND_PRIVATE_MESSAGE") TXT_SEND_PRIVATE_MESSAGE = val;
                 else if (cmd == "TXT_ADDED") TXT_ADDED = val;
                 else if (cmd == "TXT_CLOSE") TXT_CLOSE = val;
                 else if (cmd == "TXT_DELETE_MESSAGE") TXT_DELETE_MESSAGE = val;
                 else if (cmd == "TXT_DELETED") TXT_DELETED = val;
                 else if (cmd == "TXT_LIST_MESSAGES") TXT_LIST_MESSAGES = val;
                 else if (cmd == "TXT_MSG_ADD") TXT_MSG_ADD = val;
                 else if (cmd == "TXT_MSG_ID_DELETE") TXT_MSG_ID_DELETE = val;
                 else if (cmd == "TXT_NO_FRIEND") TXT_NO_FRIEND = val;
                 else if (cmd == "TXT_NO_MSGS") TXT_NO_MSGS = val;
                 else if (cmd == "TXT_PROMPT") TXT_PROMPT = val;
                 else if (cmd == "TXT_TALKING_TO_SERVER") TXT_TALKING_TO_SERVER = val;
                 else if (cmd == "TXT_TIMEOUT") TXT_TIMEOUT = val;
                 else if (cmd == "TXT_NO_DELETE") TXT_NO_DELETE =val;
                 else if (cmd == "TXT_NO_ACCOUNT") TXT_NO_ACCOUNT = val;
                 else if (cmd == "TXT_XP") TXT_XP = val;
             }
         }
     }
}
}

doTouch()
{
    floatText("", ZERO_VECTOR);

    // Assume if touched that messages are now going to be read
    unread = 0;

    // Send a message to any attached prims that may support a new message indicator
    llMessageLinked(LINK_SET, unread, "NEW_MESSAGE", "");

    // Let any attached prims know we have been touched, eg for clearing new message indicators etc
    llMessageLinked(LINK_SET, 1, "TOUCHED", ownerID);

    // Set up a time out for the dialog box
    llSetTimerEvent(timeOut);

    list options = [TXT_LIST_MESSAGES, TXT_SEND_PRIVATE_MESSAGE, TXT_DELETE_MESSAGE, TXT_CLOSE];
    listener = llListen(chan(llGetKey()), "", "", "");
    status = "waitTouch";
    llDialog(ownerID, TXT_PROMPT, options, chan(llGetKey()));
}

default
{

    state_entry()
    {
        // Assume no linked account until we get confirmation
        hasAccount = FALSE;

        ownerID = llGetOwner();
        loadConfig();
        loadLanguage(languageCode);

        if (messageFace != -1) llSetTexture(blankScreen, messageFace);

        messages = [];
        unread = 0;

        // Request the users XP total
        postMessage("task=getxp&data1=" +(string)ownerID);
        llSetTimerEvent(timeOut);
    }

    touch_end(integer index)
    {
        if ((llDetectedKey(0) == ownerID) && (handleTouch == TRUE))
        {
            doTouch();
        }
    }

    timer()
    {
        if (status == "waitTouch")
        {
            // Timed out waiting for dialog box response
            status = "";
            llOwnerSay(TXT_TIMEOUT);
            llListenRemove(listener);
        }
        else if (status == "waitFriends")
        {
            // Timed out waiting for friends list
            status = "";
        }
        else if (status == "waitPrivateMessageID")
        {
            // Timed out waiting for friends ID
            llOwnerSay(TXT_NO_FRIEND);
            status = "";
        }
        else
        {
            if (messageFace != -1) llSetTexture(blankScreen, messageFace);

            //floatText(TXT_TALKING_TO_SERVER, PURPLE);
            llSetTimerEvent(timeOut);
            llListenRemove(listener);

            // Request list of private messages for this user
            postMessage("task=msglist&data1=" +(string)ownerID +"&data2=PRV");
        }
    }

    listen(integer c, string nm, key id, string m)
    {
        debug("listen: " + m +"  Status=" +status);

        if (m == TXT_CLOSE)
        {
            status = "";
            llSetTimerEvent(1);
        }
        else if (m ==">>")
        {
            startOffset += 10;
            multiPageMenu(id, infoText, btnList);
        }
        else if (m == TXT_LIST_MESSAGES)
        {
            floatText(TXT_TALKING_TO_SERVER, PURPLE);
            status = "listRequested";

            // Request list of private messages for this user
            postMessage("task=msglist&data1=" +(string)id +"&data2=PRV");
        }
        else if (m == TXT_SEND_PRIVATE_MESSAGE)
        {
            if (llGetListLength(friendNames) == 0)
            {
                status = "askFriendsToMsg";
                postMessage("task=getfriends&data1=" +(string)ownerID);
            }
            else
            {
                friendPicker(id);
            }
        }
        else if (m == TXT_DELETE_MESSAGE)
        {
            listener = llListen(chan(llGetKey()), "", "", "");
            integer i;
            string msgID;
            string prefix;
            infoText = "\n";
            btnList = [];
            integer index = 1;
            integer count = llGetListLength(messages);

            if (count >1)
            {
                // Prepare output line as index count then time/date on one line then message on next
                for (i=0; i < count; i += 3)
                {

                    msgID = llList2String(messages,i);
                    prefix = llGetSubString(msgID, 0, 2);

                    if (prefix == PRV)
                    {
                        btnList += [(string)index];
                        infoText += "(" +(string)(index) +") " +llList2String(messages, i+2) +"\n \n";
                        index ++;
                    }
                }

                if (index > 1)
                {
                    status = "waitID";
                    multiPageMenu(id, infoText, btnList);
                }
                else
                {
                    // No messages available for deletion by this user
                    llOwnerSay(TXT_NO_MSGS);
                    status = "";
                    llSetTimerEvent(1);
                }
            }
            else
            {
                // No messages available
                llOwnerSay(TXT_NO_MSGS);
                status = "";
                llSetTimerEvent(1);
            }
        }
        else
        {
            if (status == "waitPrivateMessageUser")
            {
                // Our dialog starts the numbers at 1 so we need to take one off for finding in list
                sendTo = llList2String(friendIDs, (integer)(m)-1);
                floatText(TXT_TALKING_TO_SERVER, PURPLE);
                status = "waitPrivateMessageID";
                postMessage("task=chkuser&data1=" +sendTo +"&data2=J");
            }
            else if (status == "waitPrivateMessage")
            {
                floatText(TXT_TALKING_TO_SERVER, PURPLE);
                status = "";
                postMessage("task=msgadd&data1=" +m +"&data2=" +generateID(PRV) +"&data3=" +sendTo +"&data4=" +(string)ownerID);
            }
            else if (status == "waitID")
            {
                // [msgID, timeStamp, Message)]    Message number equates to the item store in last at  (m - 1) * 3
                integer num = (integer)m;
                num = (num  -1) * 3;

                string msgID = llList2String(messages, num);
                string prefix = llGetSubString(msgID, 0, 2);

                if (prefix == PRV)
                {
                    floatText(TXT_TALKING_TO_SERVER, PURPLE);

                    // This is a private message so they can delete it
                    postMessage("task=msgdel&data1=" + msgID +"&data2=" +(string)ownerID);
                    status = "";
                }
                else
                {
                    llOwnerSay(TXT_NO_DELETE);
                    floatText(TXT_NO_DELETE, RED);
                }
            }
        }
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        debug("link_message:" + msg +" Link:" +(string)sender_num);
        list tok = llParseStringKeepNulls(msg, ["|"], []);
        string cmd = llList2String(tok,0);

        if (cmd == "XP")
        {
            ourXP = llList2String(tok,1);
        }
        else if (cmd == "CMD_DOPOLL")
        {
            // Call timer to initiate a pull of messages from server
            status = "";
            llSetTimerEvent(0.1);
        }
        else if (cmd == "MSG_MENU")
        {
            if ((id == ownerID) && (handleTouch == FALSE)) doTouch();
        }
        else if (cmd == "MSG_COUNT")
        {
            storedMsgCount = num;
        }
        else if (cmd == "CMD_CHATTY")
        {
            useSound = num;
        }
        else if (cmd == "DEBUG_MODE")
        {
            DEBUGMODE = num;
        }
        else if (cmd == "HTTP_RESPONSE")
        {
            if (id == farmHTTP)
            {
                list dataStream = llParseStringKeepNulls(msg , ["|"], []);
                list tk = llJson2List(llList2String(dataStream, 1));
                cmd = llList2String(tk, 0);

                if (cmd == "MSGCOUNT")
                {
                    if (llList2Integer(tk, 1) != 0)
                    {
                        processMessages(tk);
                    }

                    postMessage("task=getfriends&data1=" +(string)ownerID);
                    status = "waitFriends";
                }
                else if (cmd == "MSGADD")
                {
                    floatText(TXT_ADDED, GREEN);
                    llSetTimerEvent(1);
                }
                else if (cmd == "MSGDEL")
                {
                    floatText(TXT_DELETED, GREEN);
                    if (messageFace != -1) llSetTexture(blankScreen, messageFace);
                    llSetTimerEvent(1);
                }
                else if (cmd == "XPTOTAL")
                {
                    ourXP = llList2String(tk, 1);

                    if (ourXP == "NOID")
                    {
                        ourXP = "-";
                        llOwnerSay(TXT_NO_ACCOUNT);
                    }
                    else
                    {
                        hasAccount = TRUE;
                    }
                }
                else if (cmd == "FRIENDS")
                {
                    if (llList2String(tk, 1) != "INVALID-J")
                    {
                        list friends = llJson2List(llList2String(tk, 1));
                        integer count = llGetListLength(friends);
                        integer i;
                        friendNames = [];
                        friendIDs = [];

                        if (count != 0)
                        {
                            for (i = 0; i < count; i=i+2)
                            {
                                friendIDs += [llList2String(friends, i)];
                                friendNames += [llList2String(friends, i+1)];
                            }
                        }

                        if ( status == "askFriendsToMsg") friendPicker(ownerID);
                    }
                }
                else if (cmd == "USERINFO")
                {
                    integer userNum = llListFindList(friendIDs, sendTo);
                    userNum = userNum -1;

                    string dialogMsg = llList2String(friendNames, userNum) +"\n" +TXT_MSG_ADD;

                    sendTo = llList2String(tk, 1);
                    listener = llListen(chan(llGetKey()), "", "", "");
                    status = "waitPrivateMessage";
                    llTextBox(ownerID, dialogMsg, chan(llGetKey()));
                }
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

    attach(key id)
    {
        if (id)
        {
            // we are attached
            llResetScript();
        }
    }

}

