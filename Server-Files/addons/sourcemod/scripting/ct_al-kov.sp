#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

ConVar g_Yetkiliflag = null, g_Yetkiliflaz = null;

public Plugin myinfo = 
{
	name = "CT Kov - Al", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_ctkov", Command_CTKov);
	RegConsoleCmd("sm_ctal", Command_CTAl);
	
	g_Yetkiliflaz = CreateConVar("sm_ctkov_yetki", "r", "Komutçu harici CT Kov komutunu kullanacakların harfi!");
	g_Yetkiliflag = CreateConVar("sm_ctal_yetki", "r", "Komutçu harici CT Al komutunu kullanacakların harfi!");
	AutoExecConfig(true, "CT_al-kov", "ByDexter");
}


public Action Command_CTKov(int client, int args)
{
	char YetkiliflazString[4];
	g_Yetkiliflaz.GetString(YetkiliflazString, sizeof(YetkiliflazString));
	if ((warden_iswarden(client) || YetkiDurum(client, YetkiliflazString)))
	{
		for (int za = 1; za <= MaxClients; za++)
		{
			if (IsClientInGame(za) && !IsFakeClient(za) && GetClientTeam(za) == CS_TEAM_CT && !warden_iswarden(za))
			{
				ChangeClientTeam(za, CS_TEAM_T);
				if (IsPlayerAlive(za))
					ForcePlayerSuicide(za);
			}
		}
		PrintToChatAll("[SM] \x01Koruma(lar) \x04T takımına atıldı!");
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
}

public Action Command_CTAl(int client, int args)
{
	char YetkiliflagString[4];
	g_Yetkiliflag.GetString(YetkiliflagString, sizeof(YetkiliflagString));
	if ((warden_iswarden(client) || YetkiDurum(client, YetkiliflagString)))
	{
		for (int za = 1; za <= MaxClients; za++)
		{
			if (IsClientInGame(za) && !IsFakeClient(za) && IsPlayerAlive(za) && GetClientTeam(za) == CS_TEAM_T)
			{
				ChangeClientTeam(za, CS_TEAM_CT);
				if (IsPlayerAlive(za))
					ForcePlayerSuicide(za);
			}
		}
		PrintToChatAll("[SM] \x01Yaşayan(lar) \x04CT takımına alındı!");
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
}

stock bool YetkiDurum(int client, const char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}
	return bEntitled;
}