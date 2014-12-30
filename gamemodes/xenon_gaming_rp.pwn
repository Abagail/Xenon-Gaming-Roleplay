#include a_samp
#include <a_mysql>
#include <streamer>
#include <zcmd>
#include <foreach>
#include <sscanf2>

#define DIALOG_LOGIN 			1
#define DIALOG_REGISTER 		2
#define DIALOG_CONFIRM_PASS 	3
#define DIALOG_CHANGE_PASSWORD  4

#define mysql_host "localhost"
#define mysql_user "root"
#define mysql_password ""
#define mysql_database "xenon_gaming_rp"

#define GMName "Xenon Gaming Roleplay"

#define COLOR_ERROR			0xFF0000FF
#define COLOR_GREEN 		0x008000FF
#define COLOR_WHITE			0xFFFFFFFF
#define COLOR_RED           0xFF0000FF
#define COLOR_YELLOW 		0xFFFF00FF
#define COLOR_BLUE 			0x0080FFFF
#define COLOR_DBLUE         0x003366FF
#define COLOR_GREY 			0x808080FF
#define COLOR_DARKGRAY      "{89898A}"
#define COLOR_LIME 			0x00FF00FF
#define COLOR_PINK			0xFF0080FF
#define COLOR_BLACK 		0x000000FF
#define COLOR_LIGHTBLUE 	0x00FFFFFF
#define COLOR_ORANGE 		0xFF8000FF
#define RED                 "{FF0000}"
#define GREY                "{808080}"
#define GREEN               "{00A400}"
#define WHITE               "{FFFFFF}"
#define BLUE               	"{0080FF}"
#define DBLUE               "{003366}"
#define COLOR_ADMIN         "{808080}"
#define DARK_WHITE 			"{BBBBBB}"
#define LIME            	"{00FF00}"
#define DARK_RED 			"{BB0000}"
#define DARK_GREEN			"{00BB00}"
#define LIGHT_GREEN         "{00FF00}"
#define PINK                "{FF0080}"
#define PURPLE				"{9A00FF}"
#define COLOR_ADMIN_DUTY    COLOR_ADMIN

#define MAKE_ADMIN_RANK         7
#define MAX_ADMIN_LEVEL         10
#define ADMIN_MANAGER_RANK      6
#define MAX_ADMIN_VEHICLE_SLOTS 25
native WP_Hash(buffer[], len, const str[]);
#pragma tabsize 0
new g_VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
    "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "SWAT Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Streak", "Freight", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
    "Uranus", "Jester", "Sultan", "Stratium", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Car", "SFPD Car", "LVPD Car",
    "Police Rancher", "Picador", "Splashy", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
    "Boxville", "Tiller", "Utility Traile"};
enum vehicleData
{
	a_vehicleID,
	a_ModelID,
	a_Colors[3],
	bool: a_slotTaken,
	a_spawnedBy
}
enum PlayerInfo
{
	pID,
	pPass[129],
	pAdmin,
	pVip,
	pMoney,
	pScore,
	pTrustedLevel,
	pDeaths,
	pKills,
	Float:pPos_x,
	Float:pPos_y,
	Float:pPos_z,
	Float:pPos_FacingAngle,
	pInterior,
	pSkinID,
	pVW,
	pAName[24] // This is their forum name. This will NEVER be shown as their in-game name(shows in /admins, /aduty, etc).
}

new pInfo[MAX_PLAYERS][PlayerInfo];
new AdminVehicleData[MAX_ADMIN_VEHICLE_SLOTS][vehicleData];
new IsLoggedIn[MAX_PLAYERS];
new LoginAttempt[MAX_PLAYERS];
new LoginAttempts[MAX_PLAYERS];
new RCONMakeAdmin = 0; // RCON Admins CAN'T use /makeadmin by default.
new serverMOTD[256];
new aduty[MAX_PLAYERS]; // Admin Duty Variable.
new pShotBy[MAX_PLAYERS] = INVALID_PLAYER_ID;
new g_AdminVehicleID[MAX_VEHICLES] = -1;

new Float: spawnPosX,
	Float: spawnPosY,
	Float: spawnPosZ,
	Float: spawnAngle;

new MySQLCon; // MySQL pipeline/main connection.

main()
{
	print("\n----------------------------------");
	print(" Initiating Gamemode(OnGameModeInit)...");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText(GMName);
	MySQLCon = mysql_connect(mysql_host, mysql_user, mysql_database, mysql_password);
	if(mysql_errno(MySQLCon) != 0) print("Could not connect to database!");
	if(mysql_errno(MySQLCon) == 0) print("Successfully connected to MySQL database.");
	mysql_log(LOG_ERROR | LOG_WARNING, LOG_TYPE_HTML);
	#if defined g_mapping_sys
	SendRconCommand("loadfs mapping");
	gMappingLoaded = 1;
	#endif
    LoadMOTD();
	if(strlen(serverMOTD) < 1) {
	format(serverMOTD, sizeof(serverMOTD), "Welcome to Xenon Gaming RP!");
	new query[250];
	mysql_format(MySQLCon, query, sizeof(query), "INSERT INTO `settings` (`MOTD`) VALUES ('%s')", serverMOTD);
    mysql_tquery(MySQLCon, query, "", "");
	print("MOTD Set-Up."); }
	LoadSpawn();
	ManualVehicleEngineAndLights();
	return 1;
}

public OnGameModeExit()
{
	print("Gamemode has exited.");
	SaveSpawn();
	SaveMOTD();
	return 1;
}

forward LoadMOTD();
public LoadMOTD()
{
	new query[500];
    mysql_format(MySQLCon, query, sizeof(query), "SELECT * FROM `settings`");
    mysql_tquery(MySQLCon, query, "OnMOTDLoad", "");
	return 1;
}

forward OnMOTDLoad();
public OnMOTDLoad()
{
    cache_get_row(0, 0, serverMOTD, MySQLCon, 256);
	print("MOTD has been loaded.");
	return 1;
}

forward LoadSpawn();
public LoadSpawn()
{
	new query[50];
	mysql_format(MySQLCon, query, sizeof(query), "SELECT * FROM `spawnpoint`");
    mysql_tquery(MySQLCon, query, "OnSpawnLoad", "");
}

forward OnSpawnLoad();
public OnSpawnLoad()
{
    spawnPosX = cache_get_row_float(0, 0);
    spawnPosY = cache_get_row_float(0, 1);
    spawnPosZ = cache_get_row_float(0, 2);
	spawnAngle = cache_get_row_float(0, 3);
	printf("New player spawn point has been loaded(%f, %f, %f)", spawnPosX, spawnPosY, spawnPosZ);
	return true;
}

forward SaveSpawn();
public SaveSpawn()
{
		new query[500];
    	mysql_format(MySQLCon, query, sizeof(query), "UPDATE `spawnpoint` SET `X`='%f',`Y`='%f',`Z`='%f',`Angle`='%f'",
		spawnPosX,
		spawnPosY,
		spawnPosZ,
		spawnAngle);
        mysql_tquery(MySQLCon, query, "", "");
        print(query);
        return 1;
}

forward SaveMOTD();
public SaveMOTD()
{
		new query[500];
    	mysql_format(MySQLCon, query, sizeof(query), "UPDATE `settings` SET `MOTD`='%s'",
        serverMOTD);
        mysql_tquery(MySQLCon, query, "", "");
        print(query);
        return 1;
}
public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return true;
	if(!IsValidSkin(GetPlayerSkin(playerid)))
	{
		SetPlayerSkin(playerid, pInfo[playerid][pSkinID]);
		return 1;
	}
	return true;
}
public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, COLOR_WHITE); // Just white(FOR NOW).
	new query[500];
	SendClientMessage(playerid, -1, "Welcome to Xenon Gaming. Please wait.");
    new name[MAX_PLAYER_NAME], first[MAX_PLAYER_NAME], last[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,sizeof(name));
	if(BanCheck(playerid) == 0) KickEx(playerid, "You are banned from this server.");
	if(IsPlayerNPC(playerid))
	{
	    new pIP[16];
	    GetPlayerIp(playerid, pIP, 16);
	    if(!strcmp(pIP, "127.0.0.1", true)) return true;
	    else return Kick(playerid);
	}
	if(RPName(name,first,last))
	{
	    mysql_format(MySQLCon, query, sizeof(query),"SELECT * FROM `players` WHERE `user` = '%e' LIMIT 1", PlayerName(playerid));
	    mysql_tquery(MySQLCon, query, "OnAccountCheck", "i", playerid);
	} else {
 		KickEx(playerid, "Your name is not suitable for a roleplaying enviorment. If you feel this is a mistake please contact an administrator");
 		SetPlayerVirtualWorld(playerid, 9218321);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(!IsPlayerNPC(playerid))
	{
		LoginAttempts[playerid] = 0;
		aduty[playerid] = 0;
		pShotBy[playerid] = INVALID_PLAYER_ID;
	}
	OnPlayerSave(playerid);
	return 1;
}

forward OnPlayerSave(playerid);
public OnPlayerSave(playerid)
{
	new query[500], Float: FacingAngle, Float: pPos[3];
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	GetPlayerFacingAngle(playerid, FacingAngle);
	if(IsLoggedIn[playerid] == 1 && playerid != INVALID_PLAYER_ID && !IsPlayerNPC(playerid))
    {
        mysql_format(MySQLCon, query, sizeof(query), "UPDATE `players` SET `Admin`=%d, `Vip`=%d, `Money`=%d, `Score`=%d, `TrustedLevel`=%d, `Deaths`=%d, `Kills`=%d, `X`=%f, `Y`=%f, `Z`=%f, `FacingAngle`=%f, `Interior`=%d,`VW`=0,`SkinID`=%d WHERE `ID`=%d AND `user`='%e'",
        pInfo[playerid][pAdmin],
        pInfo[playerid][pVip],
        GetPlayerMoney(playerid),
        GetPlayerScore(playerid),
        pInfo[playerid][pTrustedLevel],
        pInfo[playerid][pDeaths],
        pInfo[playerid][pKills],
        pPos[0],
        pPos[1],
        pPos[2],
        FacingAngle,
        GetPlayerInterior(playerid),
		pInfo[playerid][pSkinID],
        pInfo[playerid][pID],
        PlayerName(playerid));
        mysql_tquery(MySQLCon, query, "", "");
        print(query);
        IsLoggedIn[playerid] = 0;
		if(pInfo[playerid][pAdmin] >= 1)
		{
		    mysql_format(MySQLCon, query, sizeof(query), "UPDATE `players` SET `AdminName`=%s WHERE `ID`=%d AND `user`='%e'", pInfo[playerid][pAName]);
		    return true;
		}
	}
	return 1;
}

forward OnAccountCheck(playerid);
public OnAccountCheck(playerid)
{
    new rows, fields, string[128];
    cache_get_data(rows, fields, MySQLCon);
    if(rows)
    {
        cache_get_row(0, 2, pInfo[playerid][pPass], MySQLCon, 129);
        pInfo[playerid][pID] = cache_get_field_content_int(0, "ID");
   		format(string, sizeof(string), "Before playing you must login\n\nUsername: %s\n\nEnter your password below and click login",PlayerName(playerid));
        ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"{EDDC57}Login required",string,"Login","Cancel");
	}
    else
    {
        format(string, sizeof(string), "This server requires you to register an account before playing\n\nUsername: %s\n\nEnter your desired password below then click ok",PlayerName(playerid));
        ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_INPUT,"{EDDC57}Registration required",string,"Register","Cancel");
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new query[300];
    if(dialogid == DIALOG_REGISTER)
    {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 6 || strlen(inputtext) > 129)
		{
			new string[128];
		    SendClientMessage(playerid, COLOR_RED, "[ERROR]: Your password must be 6 to 129 characters long!");
  			format(string, sizeof(string), "This server requires you to register an account before playing\n\nUsername: %s\n\nEnter your desired password below then click ok.",PlayerName(playerid));
        	ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_INPUT,"{EDDC57}Registration required",string,"Register","Cancel");
  			return 1;
		} else {
		    mysql_format(MySQLCon, query, sizeof(query), "INSERT INTO `players` (`user`, `pass`, `IP`) VALUES ('%e', '%s', '%s')", PlayerName(playerid), PasswordHash(inputtext), PlayerIP(playerid));
            mysql_tquery(MySQLCon, query, "OnPlayerRegister", "i", playerid);
		}
    }
    if(dialogid == DIALOG_LOGIN)
    {
        if(!response) return Kick(playerid);
        if(!strcmp(PasswordHash(inputtext), pInfo[playerid][pPass], false))
	    {
	        mysql_format(MySQLCon, query, sizeof(query), "SELECT * FROM `players` WHERE `user` = '%e' LIMIT 1", PlayerName(playerid));
            mysql_tquery(MySQLCon, query, "OnPlayerLogin", "i", playerid);
		} else {
		    LoginAttempt[playerid]++; new string[128];
		    if(LoginAttempt[playerid] == 1)
			{
			    format(string, sizeof(string), "Before playing you must login\n\nUsername: %s\n\nEnter your password below and click login",PlayerName(playerid));
       		 	ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"{EDDC57}Login required",string,"Login","Cancel");
				SendClientMessage(playerid, -1,"{B30000}[ERROR]: {FFFFFF}You have entered an incorrect password. [1/3]");
			} else if(LoginAttempt[playerid] == 2)
			{
			    format(string, sizeof(string), "Before playing you must login\n\nUsername: %s\n\nEnter your password below and click login",PlayerName(playerid));
       		 	ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"{EDDC57}Login required",string,"Login","Cancel");
				SendClientMessage(playerid, -1,"{B30000}[ERROR] {FFFFFF}You have entered an incorrect password. [2/3]");
			} else if(LoginAttempt[playerid] == 3)
			{
                SendClientMessage(playerid, -1,"{B30000}[ERROR] {FFFFFF}You have entered an incorrect password. [3/3]");
                format(string,sizeof(string),"{208DD6}[SERVER] {FFFFFF}%s[%d] has been kicked from the server. (Max password attempts)",PlayerName(playerid),playerid);
        		SendClientMessageToAll(COLOR_WHITE,string);
        		Kick(playerid);
			}
		}
    }
    if(dialogid == DIALOG_CONFIRM_PASS)
    {
		if(!response) return 1;
		if(!strcmp(PasswordHash(inputtext), pInfo[playerid][pPass], false))
	    {
			ShowPlayerDialog(playerid, DIALOG_CHANGE_PASSWORD, DIALOG_STYLE_INPUT, "New Password", "Please enter your new password.", "Change Pass", "Cancel");
			SetPVarInt(playerid, "pConfirmedPW", 1);
			return 1;
		} else {
			SendClientMessage(playerid, COLOR_WHITE, "Invalid password! Please try again.");
			return 1;
		}
	}
	if(dialogid == DIALOG_CHANGE_PASSWORD)
	{
	    if(!response) return 1;
	    //if(GetPVarInt(playerid, "pConfirmPW") != 1) return 1; // They shouldn't be here then!
	    if(pInfo[playerid][pAdmin] > 0 && pInfo[playerid][pAdmin] < 7) return 1; // Admins can't change their own password without the help of a level 7 admin!
	    if(strlen(inputtext) < 6 || strlen(inputtext) > 129)
		{
		    SendClientMessage(playerid, COLOR_WHITE, "Your password must be longer than 6 characters, and shorter than 129.");
		    DeletePVar(playerid, "pConfirmPW");
		    return 1;
		}
		else {
		    new newpassword[129];
		    format(newpassword, 129, "%s", PasswordHash(inputtext));
		    format(pInfo[playerid][pPass], 129, "%s", newpassword);
		    mysql_format(MySQLCon, query, sizeof(query), "UPDATE `players` SET `Pass`='%s' WHERE`ID`=%d AND `user`='%e'",
        	newpassword,
        	pInfo[playerid][pID],
			PlayerName(playerid));
        	mysql_tquery(MySQLCon, query, "", "");
        	SendClientMessage(playerid, COLOR_WHITE, "Your password has been changed. Please relog to confirm changes.");
        	SetTimerEx("KickPlayer", 1000, false, "i", playerid);
        	new string[300];
			format(string, sizeof(string), "[WARNING]: %s has changed their password(IP: %s - ID: %d)", GetName(playerid), PlayerIP(playerid), playerid);
			print(string);
			print(query);
		}
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new words;
    new length = strlen(text);
    for(new i = 0; i < length; i++)
    {
        if(i != ' ') continue;
        else words++;
    }
    words++;

    new
        message[128];
    format(message, sizeof(message), "%s says: %s", GetName(playerid), text);
    SendAreaMessage(30.0, playerid, message, -1);
	new string[245];
	format(string, sizeof(string), "[CHAT]: %s(playerID: %d", message, playerid);
	printf(string);
	if(!IsPlayerInAnyVehicle(playerid)) ApplyAnimation(playerid, "PED", "IDLE_CHAT", 1, 0, 0, 0, 0, words*1000, 1);
	// else RandCarChat(playerid, GetPlayerVehicleID(playerid), GetPlayerSeatID(playerid));
    return 0;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(playerid != killerid)
	{
		pInfo[playerid][pDeaths] += 1;
		pShotBy[playerid] = killerid;
		new Float: X, Float: Y, Float: Z;
		GetPlayerPos(playerid, X, Y, Z);
		//SetPlayerToRespawn(playerid, DEATH_RESPAWN, -1, -1, -1, -1);
		//FadePlayerScreen(giveplayerid, FADE_DEATH);
		return 1;
	}
	return 1;
}

ReturnUser(text[]) {

	new
		strPos,
		returnID = 0,
		bool: isnum = true;

	while(text[strPos]) {
		if(isnum) {
			if ('0' <= text[strPos] <= '9') returnID = (returnID * 10) + (text[strPos] - '0');
			else isnum = false;
		}
		strPos++;
	}
	if (isnum) {
		if(IsPlayerConnected(returnID)) return returnID;
	}
	else {

		new
			sz_playerName[MAX_PLAYER_NAME];

		foreach(new i: Player)
		{
			GetPlayerName(i, sz_playerName, MAX_PLAYER_NAME);
			if(!strcmp(sz_playerName, text, true, strPos)) return i;
		}
	}
	return INVALID_PLAYER_ID;
}

stock GetAdminVehicleSlot(vehicleid)
{
	if(vehicleid != INVALID_VEHICLE_ID)
	{
	    if(g_AdminVehicleID[vehicleid] == -1) return 0;
	    return g_AdminVehicleID[vehicleid];
	}
	return 0;
}
stock GetModelIDFromName(const string[])
{
	for(new i = 0, g = sizeof(g_VehicleNames); i < g; i++)
 	{
  		if(strfind(g_VehicleNames[i], string, true) != -1)
    	{
     		return i + 400;
     	}
  	}
	return -1;
}
stock IsNumeric(const string[])
{
        for (new i = 0, j = strlen(string); i < j; i++)
        {
                if (string[i] > '9' || string[i] < '0') return 0;
        }
        return 1;
}

stock GetFreeAdminVehicleSlot()
{
	if(AdminVehicleData[MAX_ADMIN_VEHICLE_SLOTS-1][a_slotTaken] == true)
	{
	    return -1;
	}
	for (new i = 0; i != MAX_ADMIN_VEHICLE_SLOTS; ++i)
	{
	    if(AdminVehicleData[i][a_slotTaken] == false)
	    {
	        return i;
		}
	}
	return true;
}
stock IsValidVehicleModel(modelid)
{
	if(modelid == -1) return 0;
	if(modelid >= 400 && modelid < 612) return 1;
	else return 0;
}

stock SetNewbieSpawn(Float: X, Float: Y, Float: Z, Float: angle)
{
	if(X != -1 && Y != -1 && Z != -1 && angle != -1)
	{
	    spawnPosX = X;
	    spawnPosY = Y;
		spawnPosZ = Z;
		spawnAngle = angle;
		SaveSpawn();
		return print("The spawn point has been changed.");
	}
	return true;
}

stock RPName(name[],ret_first[],ret_last[])
{
	new len = strlen(name),
		point = -1,
		bool:done = false;
	for(new i = 0; i < len; i++)
	{
	  if(name[i] == '_')
	  {
	    if(point != -1) return 0;
	    else {
				if(i == 0) return 0;
				point = i + 1;
			}
	  } else if(point == -1) ret_first[i] = name[i];
	  else {
			ret_last[i - point] = name[i];
			done = true;
		}
	}
	if(!done) return 0;
	return 1;
}

stock PlayerName(playerid)
{
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	return pName;
}

stock PasswordHash(value[])
{
	new buffer[129];
    WP_Hash(buffer,sizeof(buffer),value);
    return buffer;
}

stock PlayerIP(playerid)
{
	new IP[16];
	GetPlayerIp(playerid, IP, sizeof(IP));
	return IP;
}

stock GetName(playerid)
{
    new
        name[24];
    GetPlayerName(playerid, name, sizeof(name));
    strreplace(name, '_', ' ');
    return name;
}

stock SendAreaMessage(Float:arearadi, playerid, string[],color)
{
    new Float:x,Float:y,Float:z;
    GetPlayerPos(playerid,x,y,z);
    foreach(Player,i)
    {
        if(IsPlayerInRangeOfPoint(i,arearadi,x,y,z) && IsLoggedIn[playerid] == 1)
        {
            SendClientMessage(i,color,string);
        }
    }
}

stock strreplace(string[], find, replace)
{
    for(new i=0; string[i]; i++)
    {
        if(string[i] == find)
        {
            string[i] = replace;
        }
    }
}

stock SendAdminMessage(color, string[])
{
	foreach(Player, i) {
	    if(pInfo[i][pAdmin] > 0 && IsLoggedIn[i] == 1) SendClientMessage(i, color, string); }
	return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
    pInfo[playerid][pID] = cache_insert_id();
    GivePlayerMoney(playerid, 250);
    SetPlayerScore(playerid, 0);
    SpawnPlayer(playerid);
    SetPlayerSkinEx(playerid, 299);
    SetPlayerPos(playerid, spawnPosX, spawnPosY, spawnPosZ);
    SetPlayerFacingAngle(playerid, spawnAngle);
	SetCameraBehindPlayer(playerid);
    IsLoggedIn[playerid] = 1;
    SendClientMessage(playerid, COLOR_WHITE, "You have successfully registered an account and have spawned at City Hall. Please continue the registration prompts.");
	return 1;
}

forward KickEx(playerid, msg[]);
public KickEx(playerid, msg[])
{
	SendClientMessage(playerid, COLOR_RED, msg);
	SetTimerEx("KickPublic", 1000, false, "i", playerid);
	return true;
}
forward KickPublic(playerid);
public KickPublic(playerid) { Kick(playerid); return 1; }

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(!ispassenger)
	{
	    new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		if(engine == VEHICLE_PARAMS_UNSET || VEHICLE_PARAMS_OFF)
		{
			SetVehicleParamsEx(vehicleid, 0, 0, alarm, doors, bonnet, boot, objective);
			return SendClientMessage(playerid, COLOR_GREY, "The vehicle's engine is off.");
		}
	}
	return 1;
}

forward OnPlayerLogin(playerid);
public OnPlayerLogin(playerid)
{
    SetPlayerColor(playerid, COLOR_WHITE);
    pInfo[playerid][pAdmin] = cache_get_field_content_int(0, "Admin");
    pInfo[playerid][pVip] = cache_get_field_content_int(0, "Vip");
    pInfo[playerid][pMoney] = cache_get_field_content_int(0, "Money");
    pInfo[playerid][pScore] = cache_get_field_content_int(0, "Score");
    pInfo[playerid][pTrustedLevel] = cache_get_field_content_int(0, "TrustedLevel");
    pInfo[playerid][pDeaths] = cache_get_field_content_int(0, "Deaths");
    pInfo[playerid][pKills] = cache_get_field_content_int(0, "Kill");
    pInfo[playerid][pPos_x] = cache_get_field_content_float(0, "X");
    pInfo[playerid][pPos_y] = cache_get_field_content_float(0, "Y");
    pInfo[playerid][pPos_z] = cache_get_field_content_float(0, "Z");
    pInfo[playerid][pPos_FacingAngle] = cache_get_field_content_float(0, "FacingAngle");
    pInfo[playerid][pInterior] = cache_get_field_content_int(0, "Interior");
    pInfo[playerid][pVW] = cache_get_field_content_int(0, "VW");
    pInfo[playerid][pSkinID] = cache_get_field_content_int(0, "SkinID");

    TogglePlayerControllable(playerid, false);
    SetSpawnInfo(playerid,pInfo[playerid][pSkinID], 0, pInfo[playerid][pPos_x], pInfo[playerid][pPos_y], pInfo[playerid][pPos_z], pInfo[playerid][pPos_FacingAngle], 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
    SetPlayerScore(playerid, pInfo[playerid][pScore]);
    SetPlayerSkin(playerid, pInfo[playerid][pSkinID]);
	new string[126];
    format(string, sizeof(string), "[DEBUG]: %f %f %f", pInfo[playerid][pPos_x], pInfo[playerid][pPos_y], pInfo[playerid][pPos_z]);
	print(string);
    IsLoggedIn[playerid] = 1;
    if(pInfo[playerid][pAdmin] != 0) SendClientMessage(playerid, COLOR_RED, "You have logged in as an administrator. Use [/adminhelp] to see your commands.");

	SendClientMessage(playerid, COLOR_WHITE, "{8EC7DC}[INFO]: {FFFFFF}You have been logged in.");
	TogglePlayerControllable(playerid, true);
	new bigstring[261];
	format(bigstring, sizeof(bigstring), "MOTD: %s", serverMOTD);
	SendClientMessage(playerid, COLOR_WHITE, bigstring);
	return 1;
}

stock SetPlayerSkinEx(playerid, skinid)
{
	pInfo[playerid][pSkinID] = skinid;
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid), iSeatID = GetPlayerVehicleSeat(playerid);
		if(iSeatID == 128) return SetPlayerSkin(playerid, skinid); // They're bugged anyway, so why not just set it right away.
		RemovePlayerFromVehicle(playerid);
		SetPlayerSkin(playerid, skinid);
		PutPlayerInVehicle(playerid, vehicleid, iSeatID);
		return 1;
	}
	SetPlayerSkin(playerid, skinid);
	return 1;
}

stock BanCheck(playerid)
{
	new pIP[16], query[500];
	GetPlayerIp(playerid, pIP, 16);
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	mysql_format(MySQLCon, query, sizeof(query), "SELECT * FROM `bans` WHERE `ip` = '%s' OR `username` = '%s'", pIP, pName);
 	mysql_tquery(MySQLCon, query, "", "");
  	new rows, fields;
 	cache_get_data(rows, fields, MySQLCon);
  	if(rows)
   	{
	    return 0;
   	}
    else
    {
        return 1;
    }
}

stock IsValidSkin(skin)
{
	switch(skin)
	{
	    case 0: return false;// This skin is forbidden since certain animations like cuffed don't apply.
	    case 1..73: return true;
	    case 74: return false; // This skin is invalid/missing. Using this sets skin to CJ skin(skin ID 0).
		case 75..299: return 1; // A valid skin has been passed. Note ID 74 returns 0, - so this won't get called.
		default: return 0; // Anything else is invalid, so nothing gets returned.
	}
	return -1;
}
stock SkinName(skin)
{
	#pragma unused skin
	new tmpstr[5];
	format(tmpstr, sizeof(tmpstr), "null");
	return tmpstr;
}
stock DoesAccountExist(szName[])
{
     new query[500];
     mysql_format(MySQLCon, query, sizeof(query), "SELECT * FROM `players` WHERE `user` = '%e' LIMIT 1", szName);
     mysql_tquery(MySQLCon, query, "", "");
     new rows, fields;
 	 cache_get_data(rows, fields, MySQLCon);
     if(rows)
     {
	    return 0;
     }
    else
    {
        return 1;
    }
}

CMD:adminhelp(playerid, params[])
{
	if(pInfo[playerid][pAdmin] == 0) return SendClientMessage(playerid, COLOR_WHITE, "There are no commands for your rank.");
	if(pInfo[playerid][pAdmin] >= 1) SendClientMessage(playerid, COLOR_WHITE, "Level 1 Admin: /kick /poke /a /aduty /gotov /getcar /respawnv");
	if(pInfo[playerid][pAdmin] >= 2) SendClientMessage(playerid, COLOR_WHITE, "There are no commands for this rank.");
	if(pInfo[playerid][pAdmin] >= 3) SendClientMessage(playerid, COLOR_WHITE, "There are no commands for this rank.");
	if(pInfo[playerid][pAdmin] >= 4) SendClientMessage(playerid, COLOR_WHITE, "There are no commands for this rank.");
	if(pInfo[playerid][pAdmin] >= 5) SendClientMessage(playerid, COLOR_WHITE, "There are no commands for this rank.");
	if(pInfo[playerid][pAdmin] >= 6) SendClientMessage(playerid, COLOR_WHITE, "There are no commands for this rank.");
	if(pInfo[playerid][pAdmin] >= 7) SendClientMessage(playerid, COLOR_WHITE, "There are no commands for this rank.");
	if(pInfo[playerid][pAdmin] >= ADMIN_MANAGER_RANK) SendClientMessage(playerid, COLOR_WHITE, "ADMIN MANAGER: /setforumname");
	if(pInfo[playerid][pAdmin] >= MAKE_ADMIN_RANK) SendClientMessage(playerid, COLOR_WHITE, "Administrative Management: /makeadmin");
	return 1;
}

CMD:checkip(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 1)
	{
		new szName[MAX_PLAYER_NAME];
		if(sscanf(params, "s[24]", szName)) return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /checkip [playerid/playername]");
        new giveplayerid = ReturnUser(szName);
		if(IsPlayerConnected(giveplayerid)) {
		    new pIP[16], string[256];
		    GetPlayerIp(giveplayerid, pIP, 16);
			format(string, sizeof(string), "[CHECKIP]: %s(%d): %s", GetName(giveplayerid), giveplayerid, pIP);
			return SendClientMessage(playerid, COLOR_WHITE, string);
		}
		else if(DoesAccountExist(szName)) {
             new query[500];
    		 mysql_format(MySQLCon, query, sizeof(query), "SELECT * FROM `players` WHERE `user` = '%e' LIMIT 1", szName);
		     mysql_tquery(MySQLCon, query, "", "");
		     new pIP[16], string[256];
             cache_get_row(0, 3, pIP, MySQLCon, 16);
             format(string, sizeof(string), "[CHECKIP]: %s(OFFLINE): %s", szName, pIP);
             return SendClientMessage(playerid, COLOR_WHITE, string);
		}
		else return SendClientMessage(playerid, COLOR_GREY, "That account doesn't exist.");
	}
	else return SendClientMessage(playerid, COLOR_RED, "You're not authorized to use this command.");
}

CMD:kick(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 1)
	{
	    new giveplayerid, reason[128], string[200];
	    if(sscanf(params, "us[128]", giveplayerid, reason)) return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /kick [playerid] [reason]");
	    if(IsPlayerConnected(giveplayerid) && pInfo[playerid][pAdmin] > pInfo[giveplayerid][pAdmin])
	    {
			format(string, sizeof(string), "Warn: %s has been kicked from the server by Administrator %s, reason: %s", GetName(giveplayerid), GetName(playerid), reason);
			SendClientMessageToAll(COLOR_RED, string);
			print(string);
			format(string, sizeof(string), "You have been kicked from the server by Admin %s, for: %s.", GetName(playerid), reason);
			SendClientMessage(giveplayerid, COLOR_RED, string);
			IsLoggedIn[giveplayerid] = 0;
			LoginAttempts[giveplayerid] = 0;
            SetTimerEx("KickPublic", 1000, false, "i", playerid);
            return 1;
		}
		else return SendClientMessage(playerid, COLOR_RED, "They aren't connected, or have a higher admin rank than you.");
	}
	else return SendClientMessage(playerid, COLOR_RED, "You're not authorized to use this command.");
}

CMD:poke(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 1)
	{
	    new giveplayerid, message[128], string[200];
	    if(sscanf(params, "us[128]", giveplayerid, message)) return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /poke [playerid] [message]");
		if(IsPlayerConnected(giveplayerid))
		{
		    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "An admin pokes you.", message, "Okay", "Okay");
			format(string, sizeof(string), "You poked %s with the message %s.", GetName(giveplayerid), message);
			SendClientMessage(playerid, COLOR_RED, string);
			return 1;
		}
		else return SendClientMessage(playerid, COLOR_RED, "They aren't connected.");
	}
	else return SendClientMessage(playerid, COLOR_RED, "You're not authorized to use this command.");
}

CMD:makeadmin(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= MAKE_ADMIN_RANK || IsPlayerAdmin(playerid) && RCONMakeAdmin == 1)
	{
	    new giveplayerid, level;
	    if(sscanf(params, "ud", giveplayerid, level)) return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /makeadmin [playerid] [level]");
	    if(IsPlayerConnected(giveplayerid) && level < MAX_ADMIN_LEVEL)
	    {
	        new status[64], string[200];
	        if(level > pInfo[giveplayerid][pAdmin]) format(status, 64, "Promoted");
	        else format(status, 64, "Demoted");
			pInfo[giveplayerid][pAdmin] = level;
			format(string, sizeof(string), "AdminWarning: %s has %s %s to level %d admin.", GetName(playerid), status, GetName(giveplayerid), level);
			SendAdminMessage(COLOR_RED, string);
			print(string);
			return 1;
		}
		else return SendClientMessage(playerid, COLOR_RED, "They aren't connected or the level entered is invalid.");
	}
	else return SendClientMessage(playerid, COLOR_RED, "You're not authorized to use this command.");
}

CMD:a(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 1 && aduty[playerid] || pInfo[playerid][pAdmin] >= 7) // Level 7 Admins can use this whilst off-duty.
	{
	    new message[64];
	    if(sscanf(params, "s[64]", message)) return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /a [message]");
	    new string[200];
		format(string, sizeof(string), "Level %d Admin %s: %s", pInfo[playerid][pAdmin], GetName(playerid), message);
		SendAdminMessage(COLOR_YELLOW, string);
		return 1;
	}
	else return SendClientMessage(playerid, COLOR_RED, "You're not an admin, or are not on-duty.");
}

CMD:setforumname(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= ADMIN_MANAGER_RANK) // This rank can access commands to "edit" admin accounts, how-ever they can't actually use /makeadmin.
	{
	    new giveplayerid, name[128], string[256];
	    if(sscanf(params, "us[128]", giveplayerid, name)) return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setforumname [player] [name]");
	    if(IsPlayerConnected(giveplayerid)) {
			if(pInfo[giveplayerid][pAdmin] == 0) return SendClientMessage(playerid, COLOR_WHITE, "Only admins can have forum names associated with their account.");
			format(pInfo[playerid][pAdmin], 128, "%s", name);
			format(string, sizeof(string), "Your forum-name has been set to %s by Level %d Admin %s.", name, pInfo[playerid][pAdmin], GetName(playerid));
			SendClientMessage(giveplayerid, COLOR_RED, string);
			format(string, sizeof(string), "You have set %s's forum name to %s.", GetName(giveplayerid), name);
			SendClientMessage(playerid, COLOR_RED, string);
			CallLocalFunction("OnPlayerSave", "d", playerid);
			return 1;
		}
		else return SendClientMessage(playerid, COLOR_RED, "They aren't connected.");
	}
	else return SendClientMessage(playerid, COLOR_RED, "You're not authorized to use this command.");
}
CMD:aduty(playerid, params[])
{
	new string[128];
	if(pInfo[playerid][pAdmin] >= 1)
	{
		if(aduty[playerid] == 0) // Off Duty
		{
		    new Float: X, Float: Y, Float: Z;
		    GetPlayerPos(playerid, X, Y, Z);
		    TogglePlayerSpectating(playerid, true);
		    TogglePlayerSpectating(playerid, false);
		    SpawnPlayer(playerid);
		    SetPlayerSkin(playerid, pInfo[playerid][pSkinID]);
		    SetPlayerColor(playerid, COLOR_ORANGE);
		    format(string, sizeof(string), "AdmWarn: %s is now on-duty(%s).", GetName(playerid), pInfo[playerid][pAName]);
			SendAdminMessage(COLOR_WHITE, string);
			SetPlayerPos(playerid, X, Y, Z);
			aduty[playerid] = 1;
			return 1;
		}
		else {
		    SetPlayerSkin(playerid, pInfo[playerid][pSkinID]);
			aduty[playerid] = 0;
			SetPlayerColor(playerid, COLOR_WHITE);
            format(string, sizeof(string), "AdmWarn: %s is now off-duty(%s).", GetName(playerid), pInfo[playerid][pAName]);
			SendAdminMessage(COLOR_WHITE, string);
			return 1;
		}
	}
	else return SendClientMessage(playerid, COLOR_WHITE, "You're not an administrator!");
}

CMD:getcar(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 1 && aduty[playerid] || pInfo[playerid][pAdmin] >= 7)
	{
		new vehicleid, string[129];
		if(sscanf(params, "d", vehicleid)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /getcar [vehicleid]");
		if(vehicleid != INVALID_VEHICLE_ID)
		{
			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(playerid, X, Y, Z);
			SetVehiclePos(vehicleid, X, Y+5, Z);
			format(string, sizeof(string), "You have teleported vehicle ID %d to you.", vehicleid);
			SendClientMessage(playerid, COLOR_RED, string);
			return 1;
		}
		else return SendClientMessage(playerid, COLOR_WHITE, "Invalid vehicle ID!");
	}
	else return SendClientMessage(playerid, COLOR_WHITE, "You aren't an admin, or aren't on-duty.");
}

CMD:gotov(playerid, params[])
{
     if(pInfo[playerid][pAdmin] >= 1 && aduty[playerid] || pInfo[playerid][pAdmin] >= 7)
	 {
		new vehicleid, string[129];
		if(sscanf(params, "d", vehicleid)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /gotov [vehicleid]");
		if(vehicleid != INVALID_VEHICLE_ID)
		{
			new Float: X, Float: Y, Float: Z;
			GetVehiclePos(playerid, X, Y, Z);
			SetPlayerPos(vehicleid, X, Y+1.25, Z);
			format(string, sizeof(string), "You have teleported yourself to vehicle ID %d.", vehicleid);
			SendClientMessage(playerid, COLOR_RED, string);
			return 1;
		}
		else return SendClientMessage(playerid, COLOR_WHITE, "Invalid vehicle ID!");
	}
    else return SendClientMessage(playerid, COLOR_WHITE, "You aren't an admin, or aren't on-duty.");
}

CMD:respawnv(playerid, params[])
{
     if(pInfo[playerid][pAdmin] >= 1 && aduty[playerid] || pInfo[playerid][pAdmin] >= 7)
	 {
		new vehicleid, string[129];
		if(sscanf(params, "d", vehicleid)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /gotov [vehicleid]");
		if(vehicleid != INVALID_VEHICLE_ID)
		{
			SetVehicleToRespawn(vehicleid);
			format(string, sizeof(string), "You have respawned vehicle ID %d.", vehicleid);
			SendClientMessage(playerid, COLOR_RED, string);
			return 1;
		}
		else return SendClientMessage(playerid, COLOR_WHITE, "Invalid vehicle ID!");
	}
	else return SendClientMessage(playerid, COLOR_WHITE, "You aren't an admin, or aren't on-duty.");
}

CMD:setskin(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 1 && aduty[playerid] || pInfo[playerid][pAdmin] >= 7)
	{
	    new giveplayerid, skin, string[128];
	    if(sscanf(params, "ud", giveplayerid, skin)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /setskin [player] [skin]");
		if(IsPlayerConnected(giveplayerid))
		{
		    if(IsValidSkin(skin))
		    {
				SetPlayerSkinEx(giveplayerid, skin);
				SendClientMessage(playerid, -1, "Your skin has been changed by an administrator.");
				format(string, sizeof(string), "You have set player %s's(ID: %d) skin to %d(%s)", GetName(giveplayerid), giveplayerid, skin, SkinName(skin));
				return true;
			}
		}
		return true;
	}
	return true;
}
CMD:changepassword(playerid, params[])
{
	if(pInfo[playerid][pAdmin] == 0)
	{
		ShowPlayerDialog(playerid, DIALOG_CONFIRM_PASS, DIALOG_STYLE_INPUT, "Current Password", "Please enter your current password to continue.", "Continue", "Cancel");
		return 1;
	}
	else {
	    SendClientMessage(playerid, COLOR_GREY, "As an administrator you are unable to change your password for security reasons. Contact a Level 7 admin or above.");
	    return 1;
	}
}

CMD:engine(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "You must be driving a vehicle.");
	new vehicleid = GetPlayerVehicleID(playerid);
    new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	if(engine == 0)
	{
  		SendClientMessage(playerid, COLOR_WHITE, "You have turned the engine on.");
        SetVehicleParamsEx(vehicleid, 1, 1, alarm, doors, bonnet, boot, objective);
        return 1;
	}
	else {
	    SendClientMessage(playerid, COLOR_WHITE, "You have turned the engine off.");
        SetVehicleParamsEx(vehicleid, 0, 0, alarm, doors, bonnet, boot, objective);
        return 1;
	}
}
CMD:setnewspawn(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 7)
	{
		new Float: X, Float: Y, Float: Z;
		GetPlayerPos(playerid, X, Y, Z);
		new Float: pFacingAngle;
		GetPlayerFacingAngle(playerid, pFacingAngle);
		SetNewbieSpawn(X, Y, Z, pFacingAngle);
		SendClientMessage(playerid, -1, "You have changed the point where new players will spawn!");
		return 1;
	}
	else return SendClientMessage(playerid, COLOR_WHITE, "You're not authorized to use this command.");
}

CMD:v(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 3 && aduty[playerid] == 1 || pInfo[playerid][pAdmin] >= 7)
	{
	    new vehicleid[25], color1 = 0, color2 = 1;
	    if(sscanf(params, "s[24]DD", vehicleid, color1, color2)) return SendClientMessage(playerid, -1, "USAGE: /v [name/id] [color1] [color2]");
	    if(IsNumeric(vehicleid))
	    {
			new vehiclemodel = strval(vehicleid);
	        if(IsValidVehicleModel(vehiclemodel))
	        {
	            new vehslot = GetFreeAdminVehicleSlot();
	            if(vehslot == -1) return SendClientMessage(playerid, -1, "The Admin Vehicle spawn limit has been reached.");
	            new Float: pos[3];
	            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
				AdminVehicleData[vehslot][a_vehicleID] = CreateVehicle(vehiclemodel, pos[0], pos[1], pos[2], 0.0, color1, color2, -1);
				if(AdminVehicleData[vehslot][a_vehicleID] == INVALID_VEHICLE_ID)
				{
				    AdminVehicleData[vehslot][a_vehicleID] = -1;
				    SendClientMessage(playerid, -1, "An error has occured. The vehicle couldn't be created.");
				    return true;
				}
				AdminVehicleData[vehslot][a_slotTaken] = true;
				AdminVehicleData[vehslot][a_spawnedBy] = playerid;
				AdminVehicleData[vehslot][a_Colors][0] = color1;
				AdminVehicleData[vehslot][a_Colors][1] = color2;
				PutPlayerInVehicle(playerid, AdminVehicleData[vehslot][a_vehicleID], 0);
				g_AdminVehicleID[AdminVehicleData[vehslot][a_vehicleID]] = -1;
				new string[64];
				format(string, sizeof(string), "Vehicle Spawn Successfull(ID: %d - Model: %d)", AdminVehicleData[vehslot][a_vehicleID], vehiclemodel);
				return 1;
			}
			else return SendClientMessage(playerid, -1, "Invalid vehicle model.");
		}
		else if(!IsNumeric(vehicleid))
		{
			new modelid = GetModelIDFromName(vehicleid);
			if(modelid == -1) return SendClientMessage(playerid, -1, "Invalid vehicle model name!");
			if(IsValidVehicleModel(modelid))
			{
			    new Float: pos[3];
			    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   				new vehslot = GetFreeAdminVehicleSlot();
     	 		if(vehslot == -1) return SendClientMessage(playerid, -1, "The Admin Vehicle spawn limit has been reached.");
				AdminVehicleData[vehslot][a_vehicleID] = CreateVehicle(modelid, pos[0], pos[1], pos[2], 0.0, color1, color2, -1);
				g_AdminVehicleID[AdminVehicleData[vehslot][a_vehicleID]] = vehslot;
				if(AdminVehicleData[vehslot][a_vehicleID] == INVALID_VEHICLE_ID)
				{
				    AdminVehicleData[vehslot][a_vehicleID] = -1;
				    SendClientMessage(playerid, -1, "An error has occured. The vehicle couldn't be created.");
				    return true;
				}
				AdminVehicleData[vehslot][a_slotTaken] = true;
				AdminVehicleData[vehslot][a_spawnedBy] = playerid;
				AdminVehicleData[vehslot][a_Colors][0] = color1;
				AdminVehicleData[vehslot][a_Colors][1] = color2;
				PutPlayerInVehicle(playerid, AdminVehicleData[vehslot][a_vehicleID], 0);
				new string[64];
				format(string, sizeof(string), "Vehicle Spawn Successfull(ID: %d - Model: %d)", AdminVehicleData[vehslot][a_vehicleID], modelid);
				return 1;
			}
		}
		return true;
	}
	else return SendClientMessage(playerid, -1, "You are not allowed to perform this action.");
}

CMD:destroyvehicle(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 2 && aduty[playerid] == 1 || pInfo[playerid][pAdmin] >= 7)
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        if(!GetAdminVehicleSlot(GetPlayerVehicleID(playerid)))
	        {
	            SendClientMessage(playerid, -1, "As of now, you can only destroy administrative spawned vehicles... And this isn't one!");
	            return 1;
			}
			if(AdminVehicleData[GetAdminVehicleSlot(GetPlayerVehicleID(playerid))][a_vehicleID] != INVALID_VEHICLE_ID)
			{
			    new vehslot = GetAdminVehicleSlot(GetPlayerVehicleID(playerid));
			    AdminVehicleData[vehslot][a_slotTaken] = false;
			    AdminVehicleData[vehslot][a_spawnedBy] = INVALID_PLAYER_ID;
			    AdminVehicleData[vehslot][a_Colors][0] = -1;
				AdminVehicleData[vehslot][a_Colors][1] = -1;
				DestroyVehicle(AdminVehicleData[vehslot][a_vehicleID]);
				AdminVehicleData[vehslot][a_vehicleID] = -1;
				g_AdminVehicleID[GetPlayerVehicleID(playerid)] = -1;
				return 1;
			}
		}
		else
		{
		    SendClientMessage(playerid, -1, "You're not in a vehicle!");
			return 1;
		}
		return 1;
	}
	else return SendClientMessage(playerid, -1, "You are not allowed to perform this action.");
}
			
	
