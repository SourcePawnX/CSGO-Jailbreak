#include <sourcemod>
#include <sdktools_voice>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Voice delay remover", 
	author = "DursunCan, ByDexter", 
	version = "1.0.0", 
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_CSGO)
	{
		SetFailState("This plugin was made for use with Counter-Strike: Global Offensive only.");
	}
}

public void OnPluginStart()
{
	RegAdminCmd("sm_delay", Delay_Gider, ADMFLAG_GENERIC);
}

public Action Delay_Gider(int client, int args)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 3)
		{
			SetClientListeningFlags(i, VOICE_MUTED);
		}
	}
	CreateTimer(5.0, Muteac);
	PrintToChatAll("[SM] \x045 Saniye \x01sonra delay gideriliyor!");
}

public Action Muteac(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 3)
		{
			SetClientListeningFlags(i, VOICE_NORMAL);
		}
	}
	PrintToChatAll("[SM] \x04Delay giderildi!");
	return Plugin_Handled;
} 