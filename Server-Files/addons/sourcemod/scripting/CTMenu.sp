#include <sourcemod>
#include <sdktools>
#include <warden>
#include <cstrike>

#include "files/Globals.sp"
#include "files/Stocks.sp"
#include "files/Oitc.sp"

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "CTMenu", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("core.phrases");
	RegConsoleCmd("sm_ctmenu", Command_CTMenu);
	
	HookEvent("round_start", RoundStartEnd);
	HookEvent("round_end", RoundStartEnd);
	HookEvent("player_death", Olduamk);
	
	Flag = CreateConVar("sm_ctmenu_flag", "z", "Komutçu harici erişebilecek yetki bayrağı", FCVAR_NOTIFY);
	CT_Access = CreateConVar("sm_ctmenu_access", "0", "CT takımı menüye erişebilisin mi ? ( Komutçu hariç )", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public Action Command_CTMenu(int client, int args)
{
	char Yetki[4];
	Flag.GetString(Yetki, sizeof(Yetki));
	if (CheckAdminFlag(client, Yetki) || warden_iswarden(client) || CT_Access && GetClientTeam(client) == CS_TEAM_CT)
	{
		Menu_CTMenu().Display(client, MENU_TIME_FOREVER);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] %t", "No Access");
		return Plugin_Handled;
	}
}

Menu Menu_CTMenu()
{
	Menu menu = new Menu(Menu_Callback);
	menu.SetTitle("[SM] CTMenu");
	menu.AddItem("1", "→ Tüm ayarları sıfırla");
	menu.AddItem("2", "→ CT Ölümsüzlük");
	menu.AddItem("3", "→ Ayarlar");
	menu.AddItem("4", "→ Oyunlar");
	menu.AddItem("5", "→ Rev Menü");
	menu.AddItem("6", "→ Kapat");
	menu.ExitBackButton = false;
	menu.ExitButton = false;
	return menu;
}

public int Menu_Callback(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "1") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu bütün ayarları sıfırladı!", client);
			Ayarlariduzelt();
			Menu_CTMenu().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "2") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu CT takımına ölümsüzlük verdi!", client);
			for (int x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && GetClientTeam(x) == CS_TEAM_CT)
					SetEntProp(x, Prop_Data, "m_takedamage", 0, 1);
			}
			Menu_CTMenu().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "3") == 0)
		{
			Menu_Ayarlar().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "4") == 0)
		{
			Menu_Oyunmenu().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "5") == 0)
		{
			Menu_Revmenu().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "6") == 0)
		{
			delete menu;
			return;
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

Menu Menu_Ayarlar()
{
	Menu menu2 = new Menu(Menu2_Callback);
	menu2.SetTitle("[SM] CTMenu - Ayarlar");
	if (GetConVarInt(FindConVar("mp_teammates_are_enemies")) != 1)
		menu2.AddItem("1", "→ Dost Ateşi: Başlat");
	if (GetConVarInt(FindConVar("mp_teammates_are_enemies")) != 0)
		menu2.AddItem("1", "→ Dost Ateşi: Kapat");
	if (GetConVarInt(FindConVar("weapon_accuracy_nospread")) != 1)
		menu2.AddItem("2", "→ Sekmeme: Aç");
	if (GetConVarInt(FindConVar("weapon_accuracy_nospread")) != 0)
		menu2.AddItem("2", "→ Sekmeme: Kapat");
	if (GetConVarInt(FindConVar("sm_parachute_enabled")) != 1)
		menu2.AddItem("3", "→ Paraşüt: Aç");
	if (GetConVarInt(FindConVar("sm_parachute_enabled")) != 0)
		menu2.AddItem("3", "→ Paraşüt: Kapat");
	menu2.AddItem("4", "→ Mahkumların Silahlarını Al");
	if (Mahkumlarindurumu)
		menu2.AddItem("5", "→ Mahkûmları Düzelt");
	else
		menu2.AddItem("5", "→ Mahkûmları Durdur");
	if (GetConVarInt(FindConVar("sv_gravity")) != 350)
		menu2.AddItem("6", "→ Gravity Aç");
	if (GetConVarInt(FindConVar("sv_gravity")) != 800)
		menu2.AddItem("6", "→ Gravity Kapat");
	menu2.ExitBackButton = true;
	menu2.ExitButton = false;
	return menu2;
}

public int Menu2_Callback(Menu menu2, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu2.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "1") == 0)
		{
			// Chat mesajı eklenecek
			if (GetConVarInt(FindConVar("mp_teammates_are_enemies")) != 1)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu dost ateşi açtı!", client);
				FFAyarla(true);
			}
			if (GetConVarInt(FindConVar("mp_teammates_are_enemies")) != 0)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu dost ateşi kapattı!", client);
				FFAyarla(false);
			}
		}
		else if (strcmp(Item, "2") == 0)
		{
			if (GetConVarInt(FindConVar("weapon_accuracy_nospread")) != 1)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu paraşütü açtı!", client);
				SekmemeAyarla(true);
			}
			if (GetConVarInt(FindConVar("weapon_accuracy_nospread")) != 0)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu sekmeme kapattı!", client);
				SekmemeAyarla(false);
			}
		}
		else if (strcmp(Item, "3") == 0)
		{
			if (GetConVarInt(FindConVar("sm_parachute_enabled")) != 1)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu paraşütü açtı!", client);
				SetCvar("sm_parachute_enabled", 1);
			}
			if (GetConVarInt(FindConVar("sm_parachute_enabled")) != 0)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu paraşütü kapattı!", client);
				SetCvar("sm_parachute_enabled", 0);
			}
		}
		else if (strcmp(Item, "4") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu mahkûmların silahlarını aldı!", client);
			for (int o = 1; o <= MaxClients; o++)
			{
				if (IsValidClient(o) && GetClientTeam(o) == CS_TEAM_T)
				{
					ClearWeapon(o);
				}
			}
		}
		else if (strcmp(Item, "5") == 0)
		{
			if (Mahkumlarindurumu)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu mahkûmları düzeltti!", client);
				for (int x = 1; x <= MaxClients; x++)
				{
					if (IsValidClient(x) && GetClientTeam(x) == CS_TEAM_T)
					{
						SetEntityMoveType(x, MOVETYPE_WALK);
					}
				}
				Mahkumlarindurumu = false;
			}
			else
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu mahkûmları durdurdu!", client);
				for (int x = 1; x <= MaxClients; x++)
				{
					if (IsValidClient(x) && GetClientTeam(x) == CS_TEAM_T)
					{
						SetEntityMoveType(x, MOVETYPE_NONE);
					}
				}
				Mahkumlarindurumu = true;
			}
		}
		else if (strcmp(Item, "6") == 0)
		{
			if (GetConVarInt(FindConVar("sv_gravity")) != 350)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu gravity açtı!", client);
				SetCvar("sv_gravity", 350);
			}
			if (GetConVarInt(FindConVar("sv_gravity")) != 800)
			{
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu gravity kapattı!", client);
				SetCvar("sv_gravity", 800);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu2;
	}
	else if (action == MenuAction_Cancel)
	{
		if (client == MenuCancel_ExitBack)
			Menu_CTMenu().Display(client, MENU_TIME_FOREVER);
	}
}

Menu Menu_Revmenu()
{
	Menu menu3 = new Menu(Menu3_Callback);
	menu3.SetTitle("[SM] CTMenu - Respawn Menu");
	menu3.AddItem("1", "→ Ölü Gardiyanları Canlandır");
	menu3.AddItem("2", "→ Ölü Mahkûmları Canlandır");
	menu3.AddItem("3", "→ Ölü Oyuncuları Listeden Canlandır");
	menu3.ExitBackButton = true;
	menu3.ExitButton = false;
	return menu3;
}

public int Menu3_Callback(Menu menu3, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu3.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "1") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu ölü gardiyanları canlandırdı!", client);
			for (int x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && GetClientTeam(x) == CS_TEAM_CT && !IsPlayerAlive(x))
					CS_RespawnPlayer(x);
			}
		}
		else if (strcmp(Item, "2") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu ölü mahkûmları canlandırdı!", client);
			for (int x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && GetClientTeam(x) == CS_TEAM_T && !IsPlayerAlive(x))
					CS_RespawnPlayer(x);
			}
		}
		else if (strcmp(Item, "3") == 0)
		{
			Menu_Tektekrevleme().Display(client, MENU_TIME_FOREVER);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu3;
	}
	else if (action == MenuAction_Cancel)
	{
		if (client == MenuCancel_ExitBack)
			Menu_CTMenu().Display(client, MENU_TIME_FOREVER);
	}
}

Menu Menu_Tektekrevleme()
{
	Menu menu3a = new Menu(Menu3a_Callback);
	menu3a.SetTitle("[SM] Respawn Menu - Oyuncu Seç");
	menu3a.AddItem("Reload", "→ Sayfayı Yenile");
	char name[MAX_NAME_LENGTH], list[32];
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x) && !IsPlayerAlive(x))
		{
			GetClientName(x, name, sizeof(name));
			Format(list, sizeof(list), "%d", x);
			menu3a.AddItem(list, name);
		}
	}
	menu3a.ExitBackButton = true;
	menu3a.ExitButton = false;
	return menu3a;
}

public int Menu3a_Callback(Menu menu3a, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu3a.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "Reload") == 0)
		{
			Menu_Tektekrevleme().Display(client, MENU_TIME_FOREVER);
		}
		else
		{
			int target = StringToInt(Item);
			if (target != 0)
			{
				CS_RespawnPlayer(target);
				PrintToChatAll("[SM] \x10%N \x01adlı oyuncu \x10%N \x01adlı oyuncuyu canlandırdı!", client, target);
			}
			Menu_Tektekrevleme().Display(client, MENU_TIME_FOREVER);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu3a;
	}
	else if (action == MenuAction_Cancel)
	{
		if (client == MenuCancel_ExitBack)
			Menu_Revmenu().Display(client, MENU_TIME_FOREVER);
	}
}

Menu Menu_Oyunmenu()
{
	Menu menu4 = new Menu(Menu4_Callback);
	menu4.SetTitle("[SM] CTMenu - Oyun Menu");
	menu4.AddItem("1", "→ Aref");
	menu4.AddItem("2", "→ KamiKz");
	menu4.AddItem("3", "→ Kuş Avı");
	menu4.AddItem("4", "→ OITC");
	menu4.AddItem("5", "→ Zeus");
	menu4.ExitBackButton = true;
	menu4.ExitButton = false;
	return menu4;
}

public int Menu4_Callback(Menu menu4, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu4.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "1") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu Aref oynunu başlattı!", client);
			sure = 10;
			CreateTimer(1.0, Sureeksilt, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			for (int x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && GetClientTeam(x) == CS_TEAM_T && IsPlayerAlive(x))
				{
					SetEntityRenderMode(x, RENDER_TRANSALPHA);
					SetEntityRenderColor(x, 255, 255, 255, 0);
					ClearWeapon(x);
					GivePlayerItem(x, "weapon_deagle");
				}
			}
			Oyunbasladi = true;
		}
		else if (strcmp(Item, "2") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu KamiKz oynunu başlattı!", client);
			SetCvar("sv_airaccelerate", -50);
			SetCvar("sm_parachute_enabled", 0);
		}
		else if (strcmp(Item, "3") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu Kuş Avı oynunu başlattı!", client);
			for (int x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && IsPlayerAlive(x))
				{
					if (GetClientTeam(x) == CS_TEAM_CT)
					{
						SetEntProp(x, Prop_Data, "m_takedamage", 0, 1);
						ClearWeapon(x);
						GivePlayerItem(x, "weapon_ssg08");
					}
					if (GetClientTeam(x) == CS_TEAM_T)
					{
						SetEntityHealth(x, 1);
					}
				}
			}
			SetCvar("sv_gravity", 350);
		}
		else if (strcmp(Item, "4") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu OITC oynunu başlattı!", client);
			Oitc = true;
			HookEvent("weapon_fire", Oitc_WeapnFire);
			HookEvent("player_death", Oitc_PlayerDeath);
			SetCvar("sv_infinite_ammo", 0);
			sure = 10;
			CreateTimer(1.0, Sureeksilt, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			for (int x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && IsPlayerAlive(x) && GetClientTeam(x) == CS_TEAM_T)
				{
					SetEntityHealth(x, 10);
				}
			}
		}
		else if (strcmp(Item, "5") == 0)
		{
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu Zeus oynunu başlattı!", client);
			SetCvar("sv_infinite_ammo", 1);
			sure = 10;
			CreateTimer(1.0, Sureeksilt, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			for (int x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && IsPlayerAlive(x) && GetClientTeam(x) == CS_TEAM_T)
				{
					GivePlayerItem(x, "weapon_zeus");
				}
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu4;
	}
	else if (action == MenuAction_Cancel)
	{
		if (client == MenuCancel_ExitBack)
			Menu_CTMenu().Display(client, MENU_TIME_FOREVER);
	}
}

public Action Sureeksilt(Handle timer, any data)
{
	sure--;
	if (sure > 0)
	{
		PrintCenterTextAll("→ %d Saniye sonra Oyun başlayacak ←", sure);
	}
	else
	{
		PrintToChatAll("[SM] \x01Oyun başladı!");
		PrintCenterTextAll("→ Oyun Başladı ←");
		FFAyarla(true);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action RoundStartEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!Sifirladin)
	{
		Ayarlariduzelt();
		Sifirladin = true;
	}
	if (strcmp(name, "round_start") == 0)
	{
		Sifirladin = false;
	}
}

public Action Olduamk(Event event, const char[] name, bool dontBroadcast)
{
	if (Oyunbasladi || Oitc)
	{
		int YasayanT = 0;
		for (int x = 1; x <= MaxClients; x++)
		{
			if (IsValidClient(x) && GetClientTeam(x) == CS_TEAM_T && IsPlayerAlive(x))
			{
				YasayanT++;
			}
		}
		if (YasayanT == 1)
		{
			if (Oitc)
			{
				Oitc = false;
				UnhookEvent("weapon_fire", Oitc_WeapnFire);
				UnhookEvent("player_death", Oitc_PlayerDeath);
			}
			PrintCenterTextAll("→ Oyun sona erdi! ←");
			Ayarlariduzelt();
		}
	}
} 