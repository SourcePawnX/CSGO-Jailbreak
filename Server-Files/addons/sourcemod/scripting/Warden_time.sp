#include <sourcemod>
#include <warden>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

ConVar g_Sure = null, g_Mode = null, g_Sonel = null;

bool SonTur = false;

Handle h_timer = null;

int KalanSure = -1, Warden = -1;

public Plugin myinfo = 
{
	name = "Komutçu Oylaması", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_komkalan", Command_Komkalan);
	
	g_Sure = CreateConVar("sm_komutcu_sure", "1", "Komutçu komut süresi ( Dakika )", 0, true, 1.0);
	g_Mode = CreateConVar("sm_komutcu_sure_mode", "1", "0 = Direk Kovulsun | 1 = Oylama(KomDK)", 0, true, 0.0, true, 1.0);
	g_Sonel = CreateConVar("sm_komutcu_sure_sonel", "1", "Komutçu son el oynatma sorulsun mu ?", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "KomSure", "ByDexter");
	
	HookEvent("round_end", RoundEnd, EventHookMode_PostNoCopy);
	
	AddCommandListener(Listener_UnWarden, "sm_uw");
	AddCommandListener(Listener_UnWarden, "sm_unwarden");
	AddCommandListener(Listener_UnWarden, "sm_uc");
	AddCommandListener(Listener_UnWarden, "sm_uncommander");
}

public void OnMapEnd()
{
	Warden = -1;
}

public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (SonTur)
	{
		SonTur = false;
		ChangeClientTeam(Warden, CS_TEAM_T);
		warden_remove(Warden);
		Warden = -1;
		PrintToChatAll("[SM] \x01Komutçu kovuldu!");
	}
}

public Action warden_OnWardenCreated(int client)
{
	KalanSure = g_Sure.IntValue;
	Warden = client;
	h_timer = CreateTimer(60.0, Zamansil, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	PrintToChatAll("[SM] \x01Komut süresi başladı! \x10( %d Dakika )", KalanSure);
}

public Action warden_OnWardenRemoved(int client)
{
	if (h_timer != null)
	{
		delete h_timer;
		h_timer = null;
	}
	PrintToChatAll("[SM] \x01Komutçu kovulduğu için süre iptal edildi!");
}

public Action Listener_UnWarden(int client, const char[] command, int argc)
{
	if (Warden)
	{
		if (h_timer != null)
		{
			delete h_timer;
			h_timer = null;
		}
		PrintToChatAll("[SM] \x01Komutçu ayrıldığı için süre iptal edildi!");
	}
}

public Action Zamansil(Handle timer, any data)
{
	KalanSure--;
	if (KalanSure > 0)
	{
		if (KalanSure == 1)
			PrintToChatAll("[SM] \x01Komutçu oylamasına \x041 Dakika \x01kaldı!");
	}
	else
	{
		PrintToChatAll("[SM] \x01Komutçu süresi sona erdi!");
		if (g_Mode.BoolValue)
		{
			DoVoteMenu();
		}
		else
		{
			if (g_Sonel.BoolValue)
			{
				Sonel().Display(Warden, MENU_TIME_FOREVER);
			}
			else
			{
				ChangeClientTeam(Warden, CS_TEAM_T);
				warden_remove(Warden);
				Warden = -1;
				PrintToChatAll("[SM] \x01Komutçu kovuldu!");
			}
		}
		h_timer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Command_Komkalan(int client, int args)
{
	if (KalanSure > 0)
	{
		ReplyToCommand(client, "[SM] \x01Kalan Komut Süresi: \x04%d Dakika", KalanSure);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Kalan Komut Süresi: \x04Süre Sona ermiş!");
		return Plugin_Handled;
	}
}

Menu Sonel()
{
	Menu sonel = new Menu(Menu_CallBack);
	sonel.SetTitle("Son El Oynatmak istiyor musun?\n ");
	sonel.AddItem("yes", "→ Evet");
	sonel.AddItem("no", "→ Hayır");
	sonel.ExitBackButton = false;
	sonel.ExitButton = false;
	return sonel;
}

public int Menu_CallBack(Menu sonel, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		sonel.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "yes") == 0)
		{
			SonTur = true;
			PrintToChatAll("[SM] \x01Komutçu son el oynatacak, el sonu kovulacak");
		}
		else if (strcmp(Item, "no") == 0)
		{
			SonTur = false;
			ChangeClientTeam(Warden, CS_TEAM_T);
			warden_remove(Warden);
			Warden = -1;
			PrintToChatAll("[SM] \x01Komutçu kovuldu!");
		}
	}
	else if (action == MenuAction_End)
	{
		delete sonel;
	}
}

public void DoVoteMenu()
{
	if (IsVoteInProgress())
	{
		CreateTimer(30.0, Tekraroylamayap, _, TIMER_FLAG_NO_MAPCHANGE);
		return;
	}
	
	char name[MAX_NAME_LENGTH];
	GetClientName(Warden, name, sizeof(name));
	Menu menu = new Menu(Handle_VoteMenu);
	menu.SetTitle("%s Adlı Komutçu değişsin mi ?\n ", name);
	menu.AddItem("yes", "→ Değiş");
	menu.AddItem("no", "→ Kal");
	menu.ExitBackButton = false;
	menu.ExitButton = false;
	menu.DisplayVoteToAll(20);
}

public Action Tekraroylamayap(Handle timer, any data)
{
	DoVoteMenu();
	return Plugin_Stop;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_VoteEnd)
	{
		if (param1 == 1)
		{
			PrintToChatAll("[SM] \x01Komutçu oylaması: \x10Kal!");
			KalanSure = g_Sure.IntValue;
			h_timer = CreateTimer(60.0, Zamansil, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			PrintToChatAll("[SM] \x01Komut süresi başladı! \x10( %d Dakika )", KalanSure);
		}
		else if (param1 == 0)
		{
			PrintToChatAll("[SM] \x01Komutçu oylaması: \x10Değiş!");
			Sonel().Display(Warden, MENU_TIME_FOREVER);
		}
	}
} 