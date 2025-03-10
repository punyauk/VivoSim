// point-index.lsl Script may also be called  sub-index

float version = 6.01;    // 19 May 2023


// The command for 'percentage complete towards 1 XP'
string cmdP = "POINT";

// The command for 'percent if using sub-divisions'
string cmdS = "SUBPOINT";

// The command we respond to. Set based on script name
string cmd;

integer subValue;


setIndicator(integer num)
{
    float level = num / 100.0;

    if (level < 0.02) level = 0.02;

    llSetLinkPrimitiveParams(LINK_THIS,[PRIM_SLICE,<0.0, level, 0.0>]);
}

default
{

    state_entry()
    {
        subValue = -1;

        // Should be  POINT-INDEX  or  SUB-INDEX
        if (llToUpper(llGetScriptName()) == "POINT-INDEX")
        {
            cmd = cmdP;
        }
        else
        {
            cmd = cmdS;
            subValue = (integer)llGetObjectDesc();
            setIndicator(subValue);
        }
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if (msg == cmd)
        {
            if (cmd == cmdS)
            {
                num = num * 10;
                llSetObjectDesc((string)num);
            }

            setIndicator(num);
        }

        if (msg == "GOT_XP")
        {
            setIndicator(0);

            if (subValue != -1)
            {
                subValue = 0;
                llSetObjectDesc((string)subValue);
            }
        }
    }
}
