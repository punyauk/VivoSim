// vivocom.lsl
//
float version = 6.04;   //  6 May 2023
//

string  URL = "vivosim.net/index.php/?option=com_vivosim&view=vivosim&type=vivosim&format=json&";

integer DEBUGMODE = FALSE;

string  BASEURL;
integer useHTTPS;
string  ncName = "";
key     farmHTTP = NULL_KEY;
key     callerID = NULL_KEY;


debug(string text)
{
    if (DEBUGMODE == TRUE) llOwnerSay("DEBUG_" + llToUpper(llGetScriptName()) + " " + text);
}

postMessage(string msg)
{
    debug("postMessage:"+msg +"\nTO " +BASEURL);

    if (BASEURL != "")
    {
        farmHTTP = llHTTPRequest(BASEURL, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded", HTTP_BODY_MAXLENGTH, 16384], msg);
    }
    else
    {
        llOwnerSay("COMMS ERROR!");
        setUrl();
    }
}

loadConfig()
{
    if (llGetInventoryType("config") == INVENTORY_NOTECARD)
    {
        string firstChar;
        list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
        integer i;

        for (i=0; i < llGetListLength(lines); i++)
        {
            string line = llList2String(lines, i);
            firstChar = llGetSubString(line, 0, 0);
            
            // Comment lines can start with either  #  or  ;
            if ((firstChar != "#") && (firstChar != ";"))
            {
                list tok = llParseString2List(line, ["="], []);

                if (llList2String(tok,1) != "")
                {
                    string cmd=llStringTrim(llList2String(tok, 0), STRING_TRIM);
                    string val=llStringTrim(llList2String(tok, 1), STRING_TRIM);

                    if (cmd == "USE_HTTPS") useHTTPS = (integer)val;
                }
            }
        }
    }
}

setUrl()
{
    if (useHTTPS == TRUE)
    {
        BASEURL = "https://"+URL;
    }
    else
    {
        BASEURL = "http://"+URL;
    }
}


default
{
    state_entry()
    {
        ncName = "";
        loadConfig();
        setUrl();
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        list tk = llParseStringKeepNulls(msg, ["|"], []);
        string cmd = llList2String(tk,0);

        if ( (cmd == "CMD_POST") || (cmd == "SETHTTPS")) debug("link_message:" + msg +" from: " +(string)sender_num);

        if (cmd == "CMD_POST")
        {
            callerID = id;
            postMessage(llList2String(tk,1));
        }
        else if (cmd == "CMD_DUMP_REQ")
        {
            callerID = id;
            ncName = llList2String(tk, 1);
            postMessage("task=dump&data1=" + ncName);
        }
        else if (cmd == "SETHTTPS")
        {
            useHTTPS = num;
            setUrl();
        }
        else if (cmd == "CMD_DEBUG")
        {
            DEBUGMODE = llList2Integer(tk, 1);
        }
    }

    http_response(key request_id, integer Status, list metadata, string body)
    {
        debug("http:_response:" + body);

        if (request_id == farmHTTP)
        {
            if (ncName != "")
            {
                /** If the response is a card 'dump' we should do the notecard management is fails if trying to use llMessageLinked
                 *  First remove previous backup notecard if there is one
                 */
                if (llGetInventoryType(ncName+"-old") == INVENTORY_NOTECARD) llRemoveInventory(ncName+"-old");
                string xferValues = osGetNotecard(ncName);

                // Create new backup notecard
                osMakeNotecard(ncName+"-old", xferValues);
                llSleep(0.25);

                // Now remove current notecard so we can make a fresh copy
                llRemoveInventory(ncName);

                // Create notecard with data from server
                osMakeNotecard(ncName, body);
                ncName = "";
                llMessageLinked(LINK_SET, 1, "DUMP_RESPONSE|"+ncName, callerID);
            }
            else
            {
                llMessageLinked(LINK_SET, 1, "HTTP_RESPONSE|"+body, callerID);
            }
        }
    }

}
