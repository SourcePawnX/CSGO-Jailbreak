#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <store>

#pragma semicolon 1
#pragma tabsize 0
#pragma newdecls required

#define DEBUG

bool sutActive[MAXPLAYERS + 1];
bool betweenRound;

ConVar cvarGiveCredits;

public Plugin myinfo = 
{
	name 	= "[CSGO # Jailbreak] Sut Ol",
	author 	= "Henny!",
	version = "1.0.0",
	url 	= ""
};

public void OnMapStart()
{
	char mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));
	
	char pluginName[256];
	GetPluginFilename(INVALID_HANDLE, pluginName, sizeof(pluginName));
	
	if ((StrContains(mapName, "jb_", false) == 0) || (StrContains(mapName, "jail_", false) == 0) || (StrContains(mapName, "ba_jail", false) == 0))
	{
		ServerCommand("sm plugins load %s", pluginName);
	}
	else
	{
		ServerCommand("sm plugins unload %s", pluginName);
	}
}

public void OnPluginStart()
{	
	RegConsoleCmd("sm_sutol", sutOl);
	
	cvarGiveCredits = CreateConVar("spx_sutol_credits", "100", "The credits amount to be given to the person who was disarmed?");
	AutoExecConfig(true, "spx_sutol", "PluginSettings");
	
	HookEvent("round_start", roundStart);
	HookEvent("round_end", roundEnd);
	HookEvent("player_spawn", playerSpawn);
	HookEvent("player_death", playerDeath);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] args)
{
	if (!(strcmp(args, "!sütol", false)))
	{
		FakeClientCommand(client, "sm_sutol");
	}
}

public Action sutOl(int client, int args)
{
	if (!IsPlayerAlive(client))
	{
		PrintToChat(client, "[SM] \x01Bu komutu \x06yaşayanlar \x0Fkullanabilir.");
		return Plugin_Handled;
	}
	
	if (GetClientTeam(client) != CS_TEAM_T)
	{
		PrintToChat(client, "[SM] \x01Bu komutu \x10T takımı \x0Fkullanabilir.");
		return Plugin_Handled;
	}
	
	if (sutActive[client])
	{
		PrintToChat(client, "[SM] \x01Zaten süt olmuşsunuz.");
		return Plugin_Handled;
	}
	
	if (betweenRound)
	{
		PrintToChat(client, "[SM] \x01Komut şu anda kullanıma kapalı..");
		return Plugin_Handled;
	}
	
	PrintToChatAll("[SM] \x10%N \x01adlı oyuncu \x0Esüt \x06oldu!", client);
	
	Store_SetClientCredits(client, Store_GetClientCredits(client) + GetConVarInt(cvarGiveCredits));
	
	weaponClear(client);
	
	sutActive[client] = true;
	return Plugin_Continue;
}

public Action roundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i && IsClientInGame(i) && IsClientConnected(i) && !IsFakeClient(i) && IsValidEdict(i) && IsValidEntity(i) && IsPlayerAlive(i))
		{
			SDKUnhook(i, SDKHook_WeaponCanUse, WeaponCanUse);
			SetEntityMoveType(i, MOVETYPE_WALK);
			sutActive[i] = false;
		}
	}
	
	betweenRound = false;
}

public Action roundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	betweenRound = true;
}

public Action playerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client;
	int tCount;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
			{
				tCount++;
				client = i;
			}
		}
	}
	
	if (tCount == 1 && sutActive[client])
	{
		GivePlayerItem(client, "weapon_knife");
		SDKUnhook(client, SDKHook_WeaponCanUse, WeaponCanUse);
		sutActive[client] = false;
	}
}

public Action playerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (sutActive[client])
		weaponClear(client);
}

public Action WeaponCanUse(int client)
{
	if (sutActive[client])
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

static Action weaponClear(int client)
{
	for (int j = 0; j < 5; j++)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);
		}
	}
}

stock bool IsValidClient(int client)
{
	if (client <= 0 || client > MaxClients || !IsClientInGame(client))
		return false;
	return true;
}  