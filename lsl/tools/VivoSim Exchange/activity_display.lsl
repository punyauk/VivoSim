// -------------------------------------------
//  VivoSim Exchange - Recent activity display
//  activity_display.lsl
// -------------------------------------------

float VERSION = 6.01;		// 27 February 2023

integer DEBUGMODE = FALSE;
debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DEBUG:" + llToUpper(llGetScriptName()) + " " + text);
}

// Server URL (sent from main script)
string BASEURL = "";
string fontName = "Arial"; // Arial is the default font used, if unspecified

string txt_heading     = "Your Recent Activity";
string txt_activity = "Activity";
string txt_rank     = "Rank";

vector GREEN       = <0.180, 0.800, 0.251>;
vector YELLOW      = <1.000, 0.863, 0.000>;
vector WHITE       = <1.0, 1.0, 1.0>;

key farmHTTP = NULL_KEY;
key owner;
integer FACE = 4;
string PASSWORD = "*";
integer useBeta = FALSE;
string rankTitle;
string rankImage;

showActivity(list activity)
{
    string body = "width:1024,height:1024,Alpha:0";
    string CommandList = "";  // Storage for our drawing commands
    string statusColour;
    string tmpStr;
    // Set the font to use
    CommandList = osSetFontName(CommandList, fontName);
    // Draw a border
    CommandList = osSetPenSize(CommandList, 20 );
    if (useBeta == TRUE) {statusColour = "gold";} else {statusColour = "chartreuse";}
    CommandList = osMovePen(CommandList, 1,1);
    CommandList = osDrawRectangle(CommandList, 1020,1020);
    // Put header
    CommandList = osSetPenColor(CommandList, "green");
    CommandList = osSetFontSize(CommandList, 30);
    vector Extents = osGetDrawStringSize( "vector", txt_heading, "Arial", 30);
    integer xpos = 512 - ((integer) Extents.x >> 1);        // Center the text horizontally
    CommandList = osMovePen(CommandList, xpos, 30);         // Position the text
    CommandList = osDrawText(CommandList, txt_heading);      // Place the text
    // Put column names
    CommandList = osSetPenColor(CommandList, "oldlace");
    CommandList = osSetFontSize(CommandList, 24);
    CommandList = osMovePen(CommandList, 75,100);
    CommandList = osDrawText(CommandList, txt_activity);
    // Draw horizontal seperator line
    CommandList = osSetPenSize(CommandList, 3);
    CommandList = osDrawLine(CommandList, 40, 150, 990, 150);
    // Show their ranking info
    CommandList = osMovePen(CommandList, 75, 925);
	CommandList = osSetFontSize(CommandList, 30);
   // CommandList = osSetPenColor(CommandList, "green");
    CommandList = osDrawText(CommandList, txt_rank +": " + rankTitle);
    // Show their ranking image on lower left
    CommandList = osMovePen(CommandList, 50, 800);
    CommandList = osDrawImage(CommandList, 350, 100, rankImage);
    // Display table
	CommandList = osSetFontSize(CommandList, 22);
	CommandList = osSetPenColor(CommandList, "oldlace");
    integer offset = 0;
    integer i;
    integer count = llGetListLength(activity) + 2;

    if (count >1)
    {
        for (i=0; i < count; i=i+1)
        {
            // {"title":"Hello there, 1, 2, 3 Testing!","content":""}
            CommandList = osMovePen(CommandList, 45, (165 + offset));
            tmpStr = llJsonGetValue(llList2String(activity, i), ["content"]);
            if (tmpStr == "")
			{
				tmpStr = llJsonGetValue(llList2String(activity, i), ["title"]);
			}
            tmpStr = llJsonGetValue(llList2String(activity, i), ["created"]) + "\n " + tmpStr;
            CommandList = osDrawText(CommandList, llGetSubString(tmpStr,0, 83));
            offset += 80;  // Move pen down ready for next line
        }
    }
    else
    {
        CommandList = osMovePen(CommandList, 100, (165 + offset));
        tmpStr = "- - - - - - -";
        CommandList = osDrawText(CommandList, llGetSubString(tmpStr,0, 55));
    }
    // Put it all together and display on the prim face
    osSetDynamicTextureDataBlendFace("", "vector", CommandList, body, FALSE, 2, 0, 255, FACE);
    llSetColor(WHITE, FACE);
    llSetTimerEvent(45);
}

postMessage(string msg)
{
    debug("postMessage: " + msg +" to:"+BASEURL);
    if (BASEURL != "") farmHTTP = llHTTPRequest(BASEURL, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded", HTTP_BODY_MAXLENGTH, 16384], msg);
}


// --- STATE DEFAULT -- //

default
{

    on_rez(integer n)
    {
        llResetScript();
    }

    state_entry()
    {
        owner = llGetOwner();
        llPassTouches(1);
    }

    timer()
    {
        llMessageLinked(LINK_SET, 1, "CMD_REFRESH", "");
        llSetTimerEvent(0);
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        debug("link_message: " + msg +"  Num="+(string)num);
        list tk = llParseStringKeepNulls(msg, ["|"], []);
        string cmd = llList2String(tk,0);

        if (cmd == "LANG_ACTIVITY")
        {
            // TXT_RECENT_ACTIVITY|TXT_ACTIVITY|TXT_RANK
            txt_heading = llList2String(tk, 1);
            txt_activity = llList2String(tk, 2);
            txt_rank = llList2String(tk, 3);
        }
        else if (cmd == "CMD_INIT")
        {
            if (num ==1)
            {
                // PASSWORD|VERSION|RSTATE|ExchangeID|joomlaID|BASEURL|useBeta|fontName
                PASSWORD = llList2String(tk, 1);
                VERSION  = llList2Integer(tk, 2);
                VERSION  = (VERSION/100);
                BASEURL  = llList2String(tk, 6);
                useBeta  = llList2Integer(tk, 7);
                fontName = llList2String(tk, 8);
            }
            else
            {
                PASSWORD = llList2String(tk, 1);
            }
        }
        else if (cmd == "CMD_CLEAR")
        {
            llSetTexture(TEXTURE_BLANK, FACE);
            llSetColor(GREEN, FACE);
        }
        else if (cmd == "CMD_SHOW_ACTIVITY")
        {
            rankImage = llList2String(tk,1);
            rankTitle = llList2String(tk,2);
            postMessage("task=recentactivity&data1=" + (string)id);
        }
        else if (cmd == "SETHTTPS")
        {
            BASEURL = llList2String(tk,1);
        }
        else if (cmd == "RESET")
        {
            llResetScript();
        }
    }

    http_response(key request_id, integer Status, list metadata, string body)
    {
        debug("http_response - Status: " + Status + "\nbody: " + body);
        if (request_id == farmHTTP)
        {
            llSetColor(WHITE, 4);
            list tok = llJson2List(body);
            string cmd = llList2String(tok, 0);

            if (cmd == "ACTIVITY")
            {
                if (llList2Integer(tok, 1) == 0)
                {
                    llMessageLinked(LINK_SET, 0, "NO_ACTIVITY", "");
                    showActivity([]);
                    llSetTimerEvent(0);
                }
                else if (llList2String(tok, 1) == "NOID")
                {
                    llMessageLinked(LINK_SET, 0, "ACTIVITY_ERROR", "");
                    llSetTimerEvent(0);
                }
                else
                {
                    list activities = llJson2List(llList2String(tok, 3));
                    llMessageLinked(LINK_SET, 1, "ACTIVITY_OK", "");
                    showActivity(activities);
                }
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

    dataserver( key id, string m)
    {
        debug("dataserver: " +m);
        list tk = llParseStringKeepNulls(m, ["|"], []);
        string cmd = llList2String(tk,0);
        integer i;
        //for updates
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
            osMessageObject(llList2Key(tk, 2), answer);
        }
        else if (cmd == "DO-UPDATE")
        {
            if (llGetOwnerKey(id) != llGetOwner())
            {
                llMessageLinked(LINK_SET, 0, "UPDATE-FAILED", "");
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
                if (item == me) delSelf = TRUE;
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
