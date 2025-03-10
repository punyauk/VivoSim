// vivocom.lsl
//
float version = 6.05;   //  19 May 2023
//

integer DEBUGMODE = FALSE;

string  baseUrl = "vivosim.net/index.php/?option=com_vivosim&view=vivosim&type=vivosim&format=json&";
string  betaServer = "BETA SERVER";
string  noServer = "NO URL SET!";

string  SERVERURL;
integer useHTTPS;
integer useBetaServer = FALSE;
string  ncName = "";
key     farmHTTP = NULL_KEY;
key     callerID = NULL_KEY;
string  cardHash;
integer systemDebug = FALSE;


debug(string text)
{
    if ((DEBUGMODE == TRUE) || (systemDebug == TRUE)) llOwnerSay("DEBUG_" + llToUpper(llGetScriptName()) + " " + text);
}

postMessage(string msg)
{
    if ((DEBUGMODE == TRUE) || (useBetaServer == TRUE))
    {
        llOwnerSay("\npostMessage:"+msg +"\nTO " +SERVERURL +"\n ");
    }

    if (SERVERURL != "")
    {
        farmHTTP = llHTTPRequest(SERVERURL, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded", HTTP_BODY_MAXLENGTH, 16384], msg);
    }
    else
    {
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

                    if (cmd == "USE_HTTPS")
                    {
                        useHTTPS = (integer)val;
                    }
                    else if (cmd == "SERVER")
                    {
                        if (llToUpper(val) == "BETA")
                        {
                            useBetaServer = TRUE;
                            llSetText(betaServer, <1,0,0>, 1.0);
                        }
                        else
                        {
                            useBetaServer = FALSE;
                            llSetText("", ZERO_VECTOR, 0.0);
                        }
                    }
                }
            }
        }
    }
}

setUrl()
{
    if (useHTTPS == TRUE)
    {
        if (useBetaServer == TRUE)
        {
            SERVERURL = "https://beta."+baseUrl;
        }
        else
        {
            SERVERURL = "https://"+baseUrl;
        }
    }
    else
    {
        if (useBetaServer == TRUE)
        {
            SERVERURL = "http://beta."+baseUrl;
        }
        else
        {
            SERVERURL = "http://"+baseUrl;
        }
    }
}


default
{
    state_entry()
    {
        ncName = "";
        systemDebug = FALSE;
        loadConfig();
        setUrl();
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if (useBetaServer == TRUE)
        {
            llSetText(betaServer, <1,0,0>, 1.0);
        }
        else
        {
            llSetText("", ZERO_VECTOR, 0.0);
        }

        list tk = llParseStringKeepNulls(msg, ["|"], []);
        string cmd = llList2String(tk,0);

        if (cmd == "CMD_POST")
        {
            callerID = id;
            postMessage(llList2String(tk,1));
        }
        else if (cmd == "CMD_DUMP_REQ")
        {
            callerID = id;
            ncName = llList2String(tk, 1);
            cardHash = llList2String(tk, 2);
            postMessage("task=dump&data1=" + ncName);
        }
        else if (cmd == "SETHTTPS")
        {
            useHTTPS = num;
            setUrl();
        }
        else if (cmd == "CMD_DEBUG")
        {
            systemDebug = llList2Integer(tk, 1);
        }
    }

    http_response(key request_id, integer Status, list metadata, string body)
    {
        debug("http:_response:" + body);

        if (request_id == farmHTTP)
        {
            if (ncName != "")
            {
                list tok = llJson2List(body);
                string cmd = llList2String(tok, 0);
                string givenHash = llSHA1String(llList2String(tok, 1));

                if (cmd == "DUMP-FAIL")
                {
                    // Sending the dump failed
                }
                else if (cmd == "DUMP")
                {
                    // If the response is a card 'dump' we should do the notecard management as fails if trying to use llMessageLinked
                    if ( givenHash == cardHash)
                    {
                        // First remove previous backup notecard if there is one
                        if (llGetInventoryType(ncName+"-old") == INVENTORY_NOTECARD) llRemoveInventory(ncName+"-old");
                        string xferValues = osGetNotecard(ncName);

                        // Create new backup notecard
                        osMakeNotecard(ncName+"-old", xferValues);
                        llSleep(0.25);

                        // Now remove current notecard so we can make a fresh copy
                        llRemoveInventory(ncName);

                        string newContent = llList2String(tok, 1);

                        // Create notecard with data from server
                        osMakeNotecard(ncName, newContent);
                        ncName = "";
                        llMessageLinked(LINK_SET, 1, "DUMP_RESPONSE|"+ncName, callerID);
                    }
                }
            }
            else
            {
                llMessageLinked(LINK_SET, 1, "HTTP_RESPONSE|"+body, callerID);
            }
        }
    }

}
