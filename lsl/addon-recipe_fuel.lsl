/* addon_recipe_fuel.lsl
 * VERSION = 6.00   18 May 2023
 */

string  TXT_MNU = "What fuel source would you like to use for";

string  fuelType01 = "POWER";
string  fuelType02 = "WOOD";

string  machineName;
string  recipeNotecard;
integer ourListener;
string  selectedfuelType;
key     user;


 askFuelType()
 {
	llListenRemove(ourListener);
	ourListener = llListen(-99, "", user, "");

	// Wood or grid power ?
	llDialog(user, "\n" +TXT_MNE +machineName, [fuelType01, fuelType02] , -99);

	// Start a 2 min timer, after which we will stop listening for responses
	llSetTimerEvent(120.0);
 }


setFuelRecipe()
 {
	llListenRemove(ourListener);
	llSetTimerEvent(0);

	if (llGetInventoryType(recipeNotecard) == INVENTORY_NOTECARD)
	{
		llRemoveInventory(recipeNotecard);
	}

	string contents = osGetNotecard(selectedfuelType);
	osMakeNotecard(recipeNotecard, contents);

 }

 loadConfig()
 {
	list lines = llParseString2List(osGetNotecard("config"), ["\n"], []);
	integer i;
 
	for (i=0; i < llGetListLength(lines); i++)
	 {
		list tok = llParseString2List(llList2String(lines,i), ["="], []);
 
		if (llList2String(tok,1) != "")
		{
			string cmd = llStringTrim(llList2String(tok, 0), STRING_TRIM);
			string val = llStringTrim(llList2String(tok, 1), STRING_TRIM);
 
			if (cmd == "RCODE") recipeNotecard = val + "_RECIPES";
		 }
	 }
}


 default
 {
	on_rez(integer num)
	{
		user = llGetOwner();
		loadConfig();
		machineName = llGetObjectName();
		llMessageLinked(LINK_SET, num, "ADD_MENU_OPTION|" +TXT_MNU, "");
	}

	link_message( integer sender_num, integer num, string str, key id )
	{
		list tok = llParseStringKeepNulls(msg, ["|"], []);
		string cmd = llList2String(tok,0);

		if (cmd == "CMD_LANG")
		{

		}
		else if (cmd == "")
		{
			if (llGetInventoryType(recipeNotecard) != INVENTORY_NOTECARD)
			{	
				askFuelType();
			}
			else
			{
				// ERROR
			}
		}
	 }

	listen(integer chan, string name, key id, string msg)
	{
		if (msg == fuelType01)
		{
			selectedfuelType = recipeNotecard +"-" + fuelType01;
		}
		else
		{
			selectedfuelType = recipeNotecard +"-" + fuelType02;
		}	

		setFuelRecipe();
	}

	timer()
	{
		selectedfuelType = recipeNotecard +"-" + fuelType01;
		setFuelRecipe();
	}

}
