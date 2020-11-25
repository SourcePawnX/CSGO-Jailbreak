#include <sourcemod>
#include <sdktools>
#include <sourcemod>
#include <smlib>
#define MAX_WORDS 400
#pragma newdecls required 
char yazilar[82][256];
int deagleKullanan = -1, randomSayi, toplamYazi;
bool yazildi = false, oldurulsun = false, oldurdu = false, oynaniyor = false;
Handle g_PluginTagi = INVALID_HANDLE, g_timer;
char yazilarDosyasi[PLATFORM_MAX_PATH];
public void OnPluginStart() 
{	
	g_PluginTagi = CreateConVar("plugin_taglari", "", "Pluginlerin basinda olmasini istediginiz tagi giriniz( [] olmadan )");
	RegAdminCmd("sm_dsustum", RandomYazi, ADMFLAG_GENERIC, "Deagle Sustum oyunu başlatır.");
	AddCommandListener(Command_Say, "say");
	HookEvent("weapon_fire", weapon_fire);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start", ElBasladi);
	yazilariOku();
}

void yazilariOku()
{
	BuildPath(Path_SM, yazilarDosyasi, sizeof(yazilarDosyasi), "configs/sustum_mesajlari.ini");
	if(FileExists(yazilarDosyasi))
	{
		Handle yazilarHandle = OpenFile(yazilarDosyasi, "r");
		int i = 0;
		while( i < MAX_WORDS && !IsEndOfFile(yazilarHandle))
		{
			ReadFileLine(yazilarHandle, yazilar[i], sizeof(yazilar[]));
			TrimString(yazilar[i]);
			i++;
		}
		toplamYazi = i;
		CloseHandle(yazilarHandle);
	}
}

public Action RandomYazi(int client, int args)
{
	char sPluginTagi[64];
	GetConVarString(g_PluginTagi, sPluginTagi, sizeof(sPluginTagi));
	
	PrintToChatAll(" \x02[%s] \x10%N \x0EDeagle sustum \x06başlatıyor!", sPluginTagi, client);
	Vuramazsa(client);
	oldurulsun = false;
	oldurdu = false;
	oynaniyor = false;
}
public Action timer(Handle Timer)
{
	randomSayi = GetRandomInt(0, toplamYazi);
	yazdir();
	yazildi = false;
}
void yazdir()
{
	char URL[512];
	Format(URL, 512, "https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=tr&client=tw-ob", yazilar[randomSayi]);
	int i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			ShowHiddenMOTDPanel(i, URL, MOTDPANEL_TYPE_URL);
		}
		i++;
	}
	Panel panel = new Panel();
	panel.SetTitle("DSUSTUM:");
	panel.DrawText(" ");
	panel.DrawText(yazilar[randomSayi]);
	panel.DrawText(" ");
	panel.DrawItem("Tamam");
	for(int z = 1; z <= MaxClients; z++){if (IsClientInGame(z) && !IsFakeClient(z)){panel.Send(z, panel_action, MENU_TIME_FOREVER);}}	
	g_timer = CreateTimer(0.1, RandomYaziTimer, _, TIMER_REPEAT);
	g_timer = CreateTimer(60.0, Bitir);
}

public Action RandomYaziTimer(Handle timer)
{
	if(!yazildi)
		PrintCenterTextAll("<font color='#00ffde'>%s", yazilar[randomSayi]);
}

public Action Command_Say(int client, const char[] command, int args)
{
	char yazi[200];
	GetCmdArgString(yazi, sizeof(yazi));
	StripQuotes(yazi);
	
	char sPluginTagi[64];
	GetConVarString(g_PluginTagi, sPluginTagi, sizeof(sPluginTagi));
	
	if(StrEqual(yazi, yazilar[randomSayi], false))
	{
		if(!yazildi)
		{
			if(GetClientTeam(client) != 3 && IsPlayerAlive(client))
			{
				PrintToChatAll(" \x02[%s] \x10%N \x01ilk doğru yazan kişi, \x06tebrikler!", sPluginTagi, client);
				PrintCenterTextAll("<b><font color='#FFFF00'>%N</font> <font color='#00FFFF'>ilk doğru yazan kişi, tebrikler!</font></b>", client);
				oynaniyor = true;
				yazildi = true;
				DeagleSustum(client);
				deagleKullanan = client;
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}
public Action Bitir(Handle timer)
{
	if(!yazildi)
	{
		PrintToChatAll("[SM] \x04Hiç kimse doğru yazamadı :c");
		yazildi = true;
		oynaniyor = false;
		oldurulsun = true;
		oldurdu = false;
		delete g_timer;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public void OnMapStart()
{
	oldurulsun = false;
	oldurdu = false;
	oynaniyor = false;
	delete g_timer;
}
void DeagleSustum(int client)
{
	int userid = GetClientUserId(client);
	Client_GiveWeaponAndAmmo(client, "weapon_deagle", _, 0, _, 1);
	ServerCommand("sm_beacon #%d", userid);
}
public Action weapon_fire(Event event, const char[] name, bool dontBroadcast) 
{
	if(deagleKullanan > 0)
	{
		int userid = GetEventInt(event, "userid");
		int client = GetClientOfUserId(userid);
		char weapon_name[50];
		
		GetClientWeapon(client, weapon_name, sizeof(weapon_name));
		TrimString(weapon_name);
		StripQuotes(weapon_name);
		if(client == deagleKullanan)
		{
			if(StrEqual(weapon_name, "weapon_deagle", false))
			{
				CreateTimer(1.0, DeagleBitir, userid);
			}
		}
	}
}

public Action DeagleBitir(Handle timer, int userid)
{
	Client_RemoveAllWeapons(userid, "", false);
	ServerCommand("sm_beacon #%d", userid);
	CreateTimer(0.1, DeagleBitir2, userid);
}

public Action DeagleBitir2(Handle timer, int userid)
{
	if (deagleKullanan)
	{
		char sPluginTagi[64];
		GetConVarString(g_PluginTagi, sPluginTagi, sizeof(sPluginTagi));
		
		PrintToChatAll(" \x02[%s] \x10%N \x0ADeagle atış hakkını kullandı.", sPluginTagi, deagleKullanan);
		if(oynaniyor)
		{
			if(oldurulsun)
			{
				if(!oldurdu)
				{
					PrintToChatAll(" \x02[%s] \x10%N \x0CAdam vuramadığı için \x07öldürüldü.", sPluginTagi, deagleKullanan);
					ForcePlayerSuicide(deagleKullanan);
				}
				else
				{
					PrintToChatAll(" \x02[%s] \x10%N \x01Adam vurduğu için öldürülmedi, \x06tebrikler..", sPluginTagi, deagleKullanan);
				}
			}
		}
	}	
	deagleKullanan = -1;
	oynaniyor = false;
}
void Vuramazsa(int client)
{
	Menu menu = new Menu(vuramazsa, MenuAction_Select | MenuAction_End);
	menu.SetTitle("Vuramazsa Öldürülsün Mü?");

	menu.AddItem("evet", "Evet, Öldürülsün");
	menu.AddItem("hayir", "Hayır, Öldürülmesin");

	menu.Display(client, MENU_TIME_FOREVER);
}

public int vuramazsa(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			menu.GetItem(param2, item, sizeof(item));

			if (StrEqual(item, "evet"))
			{
				oldurulsun = true;
				oldurdu = false;
				CreateTimer(3.0, timer);
			}
			else if (StrEqual(item, "hayir"))
			{
				oldurulsun = false;
				oldurdu = false;
				CreateTimer(3.0, timer);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client_died = GetClientOfUserId(GetEventInt(event, "userid"));
	int client_killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(oynaniyor)
	{
		if(client_died != client_killer)
		{
			if(deagleKullanan > 0)
			{
				if(client_killer == deagleKullanan)
				{
					oldurdu = true;
				}
			}
		}
	}
}

public void ShowHiddenMOTDPanel(int client, char[] url, int type)
{
	Handle setup = CreateKeyValues("data");
	KvSetString(setup, "title", "YouTube Music Player by namazso");
	KvSetNum(setup, "type", type);
	KvSetString(setup, "msg", url);
	ShowVGUIPanel(client, "info", setup, false);
	delete setup;
}
public int panel_action(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		delete menu;
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}
public Action ElBasladi(Event event, const char[] name, bool dontBroadcast)
{
	yazildi = true;
	oynaniyor = false;
	oldurulsun = true;
	oldurdu = false;
	delete g_timer;
}