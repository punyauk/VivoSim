/* addon_candle.lsl
 * VERSION = 6.01   9 May 2023
 */
 
 string notecard_name = "candata";

 integer amountLeft;
 integer flamePrim;
 integer candlePrim;
 
 // for prim scaling - will be 5 values in each list to match >90%, >75%, >50%, >25%, less
 list candleSizes;
 list candlePositions;
 list flamePositions;
 
 
 integer getLinkNum(string primName)
 {
	 integer result = -1;
	 integer i;
 
	 for (i = 1; i <= llGetNumberOfPrims(); i++)
	 {
		 if (llGetSubString(llGetLinkName(i), 0, 17)  == primName) result = i;
	 }
 
	 return result;
 }
 
 saveData()
 {
	 if (flamePrim != -1)
	 {
		 llSetLinkPrimitiveParamsFast(flamePrim, [PRIM_DESC, (string)amountLeft]);
	 }
 }
 
 loadData()
 {
	 if (flamePrim != -1)
	 {
		 string desc = llList2String(llGetLinkPrimitiveParams(flamePrim, [PRIM_DESC]), 0);
		 if (desc != "")
		 {
			 amountLeft = (integer)desc;
		 }
	 }
 }
 
 resizeObject()
 {
	 integer index;
	 integer count = llGetListLength(candleSizes);
 
	 if (count != 0)
	 {
 
		 if (amountLeft > 90)
		 {
			 index = 0;
		 }
		 else if (amountLeft > 75)
		 {
			 index = 1;
		 }
		 else if (amountLeft > 50)
		 {
			 index = 2;
		 }
		 else if (amountLeft > 25)
		 {
			 index = 3;
		 }
		 else
		 {
			 index = 4;
		 }
 
		 if (flamePrim != -1)
		 {
			 llSetLinkPrimitiveParamsFast(flamePrim, [PRIM_POS_LOCAL, llList2Vector(flamePositions, index)]);
		 }
 
		 if (candlePrim != -1)
		 {
			 llSetLinkPrimitiveParamsFast(candlePrim, [PRIM_SIZE, llList2Vector(candleSizes, index), PRIM_POS_LOCAL, llList2Vector(candlePositions, index)]);
		 }
 
		 if (flamePrim != -1)
		 {
			 llSetLinkPrimitiveParamsFast(flamePrim, [PRIM_POS_LOCAL, llList2Vector(flamePositions, index)]);
		 }
	 }
 
	 saveData();
 }
 
 default
 {
	 /*
		 touch_end(integer num)
		 {
			 amountLeft = amountLeft -15;
			 if (amountLeft < 5) amountLeft = 100;
			 llOwnerSay("amountLeft="+(string)amountLeft);
			 resizeObject();
		 }
	 */
 
	 state_entry()
	 {
		 flamePrim = getLinkNum("show_while_cooking");
		 candlePrim = getLinkNum("candle");
 
		 candleSizes = [];
		 candlePositions = [];
		 flamePositions = [];
 
		 if (llGetInventoryType(notecard_name) == INVENTORY_NOTECARD)
		 {
			 // candleSize|candlePos|flamepos| ...
			 string data;
			 list values;
 
			 integer notecardLines = osGetNumberOfNotecardLines(notecard_name);
			 integer i;
 
			 for (i = 0; i < notecardLines; i++)
			 {
				 data = llStringTrim(osGetNotecardLine(notecard_name, i), STRING_TRIM);
				 values = llParseString2List(data, ["|"], []);
				 candleSizes += llList2Vector(values, 0);
				 candlePositions += llList2Vector(values, 1);
				 flamePositions += llList2Vector(values, 2);
			 }
		 }
 
		 amountLeft = 100;
 
		 loadData();
		 resizeObject();
	 }
 
	 link_message(integer sender_num, integer num, string str, key id)
	 {
		 if (str == "STARTCOOKING")
		 {
			 resizeObject();
			 llSetAlpha(1.0, ALL_SIDES);
		 }
		 else if (str == "PROGRESS")
		 {
			 amountLeft = num;
			 resizeObject();
		 }
		 else if (str == "ENDCOOKING")
		 {
			amountLeft = 0;
			resizeObject();
			llSetAlpha(0.0, ALL_SIDES);
		 }
	 }
 }
 