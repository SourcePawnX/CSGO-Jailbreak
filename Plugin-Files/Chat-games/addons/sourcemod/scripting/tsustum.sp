#include <sourcemod>
#include <sdktools>
#include <sourcemod>
#define MAX_WORDS 400
Handle g_PluginTagi = INVALID_HANDLE;
Handle g_timer = null;
char yazilar[MAX_WORDS][128];
int randomSayi;
bool yazildi = false;
char yazilarDosyasi[PLATFORM_MAX_PATH];
int toplamYazi;
public OnPluginStart() 
{
	g_PluginTagi = CreateConVar("drk_plugin_taglari", "gametor", "Pluginlerin basinda olmasini istediginiz tagi giriniz( [] olmadan )");
	RegAdminCmd("sm_tsustum", RandomYazi, ADMFLAG_GENERIC, "T Sustum oyunu başlatır.");
	HookEvent("round_start", Elbasladi);
	AddCommandListener(Command_Say, "say");
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
	
	PrintToChatAll(" \x02[%s] \x10%N \x0ETsustum \x06başlatıyor!", sPluginTagi, client);
	CreateTimer(3.0, timer);
}
public Action timer(Handle Timer)
{
	randomSayi = GetRandomInt(0, toplamYazi);
	yazdir();
	yazildi = false;
}
void yazdir()
{
	Panel panel = new Panel();
	panel.SetTitle("TSUSTUM:");
	panel.DrawText(" ");
	panel.DrawText(yazilar[randomSayi]);
	panel.DrawText(" ");
	panel.DrawItem("Tamam");
	for(int i = 1; i <= MaxClients; i++){if (IsClientInGame(i) && !IsFakeClient(i)){panel.Send(i, panel_action, MENU_TIME_FOREVER); ShowMOTDPanel(i, "Ses", "https://translate.google.com/translate_tts?ie=UTF-8&q=31&tl=tr&client=tw-ob", 2);}}	
	g_timer = CreateTimer(0.1, RandomYaziTimer, _, TIMER_REPEAT);
	g_timer = CreateTimer(60.0, Bitir);	
}
public Action RandomYaziTimer(Handle Timer)
{
	if(!yazildi)
		PrintCenterTextAll("<font color='#00ffde'>%s", yazilar[randomSayi]);
}

public Action Command_Say(int client, const char[] command, int args)
{
	char yazi[200];
	GetCmdArgString(yazi, sizeof(yazi));
	StripQuotes(yazi);
	
	if(StrEqual(yazi, yazilar[randomSayi], false))
	{
		if(!yazildi)
		{
			if(GetClientTeam(client) != 3)
			{
				char sPluginTagi[64];
				GetConVarString(g_PluginTagi, sPluginTagi, sizeof(sPluginTagi));
				ChangeClientTeam(client, 3);
				PrintToChatAll(" \x02[%s] \x10%N \x01ilk doğru yazan kişi, \x06tebrikler!", sPluginTagi, client);
				PrintCenterTextAll("<b><font color='#FFFF00'>%N</font> <font color='#00FFFF'>ilk doğru yazan kişi, tebrikler!</font></b>", client);
				delete g_timer;
				yazildi = true;
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}
public Action Bitir(Handle Timer)
{
	if(!yazildi)
	{
		PrintToChatAll("[SM] \x05Kimse yazı yazmadığı için oyun \x02iptal \x05edildi!");
		delete g_timer;
		yazildi = true;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action Elbasladi(Event event, const char[] name, bool dontBroadcast)
{
	yazildi = true;
	delete g_timer;
}
public int panel_action(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		delete menu;
	}
	else
	{
		if(action == MenuAction_End)
		{
			delete menu;
		}
	}
}