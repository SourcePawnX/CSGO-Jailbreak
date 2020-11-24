// To do:
// Add Turkish language

#include <sourcemod>
#include <cstrike>
#include <sdktools_voice>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "[CSGO # Jailbreak] Voice Delay Remover", 
	author = "DursunCan, ByDexter, Henny!", 
	version = "1.1", 
	url = ""
}

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
	RegAdminCmd("sm_delay", DelayClear, ADMFLAG_GENERIC);
}

public Action DelayClear(int client, int args)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT)
		{
			SetClientListeningFlags(i, VOICE_MUTED);
		}
	}
	
	CreateTimer(5.0, DelayCleaned, _, TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll("[SM] \x0CKomutçu\x01'nun mikrofonu \x045 saniye \x01içerisinde açılacak.");
}

public Action DelayCleaned(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 3)
		{
			SetClientListeningFlags(i, VOICE_NORMAL);
		}
	}
	
	PrintToChatAll("[SM] \x0CKomutçu\x01'nun mikrofon geçikmesi \x04giderildi.");
	return Plugin_Stop;
} 