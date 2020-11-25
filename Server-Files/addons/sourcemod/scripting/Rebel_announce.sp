#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Rebel Announce", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

bool Announce = false;

public void OnPluginStart()
{
	LoadTranslations("rebel_announce.phrases");
	HookEvent("player_hurt", OnClientHurt);
	HookEvent("round_start", RoundStartEnd);
	HookEvent("round_end", RoundStartEnd);
}

public Action RoundStartEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (Announce)
		Announce = false;
}

public Action OnClientHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (!Announce)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if (attacker != CS_TEAM_T)return;
		int victim = GetClientOfUserId(event.GetInt("userid"));
		if (victim != CS_TEAM_CT)return;
		PrintCenterTextAll("%t", "Rebel Announce", attacker);
		PrintToChatAll("[SM] \x01%t", "Rebel Announce", attacker);
	}
} 