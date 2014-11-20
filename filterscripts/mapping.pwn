#include a_samp
#include streamer

#define MAPPING_NOT_LOADED 0
#define MAPPING_LOADED 1

new CityHall[10];
new gMappingLoaded = MAPPING_NOT_LOADED;

forward LoadMappings();
public LoadMappings()
{
	CityHall[0] = CreateDynamicObject(3980, -289.43506, 1247.69556, 29.00150,   0.00000, 0.00000, 181.91689);
	CityHall[1] = CreateDynamicObject(4003, -290.42682, 1211.31799, 35.64032,   0.00000, 0.00000, 180.69093);
	CityHall[2] = CreateDynamicObject(18850, -322.60690, 1240.07043, 27.68906,   0.00000, 0.00000, 357.83032);
	CityHall[3] = CreateDynamicObject(3858, -276.23615, 1229.50757, 38.56118,   -135.00000, 280.00000, 187.82901);
	CityHall[4] = CreateDynamicObject(3858, -300.06015, 1227.84216, 38.82462,   -135.00000, 280.00000, 187.82901);
	CityHall[5] = CreateDynamicObject(3858, -297.24997, 1227.48108, 38.82462,   -135.00000, 280.00000, 187.82901);
	CityHall[6] = CreateDynamicObject(3858, -293.50009, 1230.17188, 38.82462,   -135.00000, 280.00000, 187.82901);
	CityHall[7] = CreateDynamicObject(3858, -289.09036, 1229.92590, 38.82462,   -135.00000, 280.00000, 187.82901);
	CityHall[8] = CreateDynamicObject(3858, -284.39069, 1229.66443, 38.82462,   -135.00000, 280.00000, 187.82901);
	CityHall[9] = CreateDynamicObject(3858, -280.11728, 1228.93286, 38.56118,   -135.00000, 280.00000, 187.82901);
	gMappingLoaded = MAPPING_LOADED;
	return 1;
}

forward RemoveBuildingsForPlayer(playerid);
public RemoveBuildingsForPlayer(playerid)
{
    RemoveBuildingForPlayer(playerid, 16066, -186.4844, 1217.6250, 20.5625, 0.25);
	return 1;
}

public OnFilterScriptInit()
{
	LoadMappings();
	return 1;
}

public OnFilterScriptExit()
{
	for (new i = 0; i != sizeof(CityHall); ++i)
	{
        DestroyDynamicObject(CityHall[i]);
        gMappingLoaded = MAPPING_NOT_LOADED;
	}
	return 1;
}
