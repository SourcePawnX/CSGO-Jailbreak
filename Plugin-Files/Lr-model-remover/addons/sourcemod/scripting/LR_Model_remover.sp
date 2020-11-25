#include <sourcemod>
#include <sdktools>
#include <lastrequest>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Last Request - Player Server Side Model Remover", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnMapStart()
{
	PrecacheModel("models/player/custom_player/legacy/ctm_sas_varianta.mdl", false);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_varianta.mdl", false);
}

public void OnStartLR(int PrisonerIndex, int GuardIndex, int LR_Type)
{
	SetEntityModel(PrisonerIndex, "models/player/custom_player/legacy/tm_phoenix_varianta.mdl");
	SetEntityModel(GuardIndex, "models/player/custom_player/legacy/ctm_sas_varianta.mdl");
}