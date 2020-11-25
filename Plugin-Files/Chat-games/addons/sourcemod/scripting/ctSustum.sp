#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required
char yazilar[82][256];
int randomSayi;
bool yazildi = false, yazdi[MAXPLAYERS];
Handle g_timer = null;
public Plugin myinfo =
{
    name = "CT Sustum",
    author = "ImPossibLe`(edit phiso)",
    description = "",
    version = "1.0"
}
public void OnPluginStart() 
{
	RegAdminCmd("sm_ctsustum", RandomYazi, ADMFLAG_GENERIC, "CT Sustum oyunu başlatır.");
	AddCommandListener(Command_Say, "say");
	HookEvent("round_start", elbb);
	HookEvent("round_end", elbb);
	yazilar[0] = "araba";
	yazilar[1] = "kırmızı araba";
	yazilar[2] = "kırmızı elbise";
	yazilar[3] = "siyah ceket";
	yazilar[4] = "pişmiş muz";
	yazilar[5] = "basketbol sahası";
	yazilar[6] = "DrK # GaminG";
	yazilar[7] = "ahmetin çükü kopsun";
	yazilar[8] = "profesyonel";
	yazilar[9] = "kırmızı başlıklı kız";
	yazilar[10] = "karambit";
	yazilar[11] = "mavi dildo";
	yazilar[12] = "Türk Bayrağı";
	yazilar[13] = "sarı çizmeli mehmet ağa";
	yazilar[14] = "fadimenin 50 tonu";
	yazilar[15] = "ne servermış be";
	yazilar[16] = "bilgin ejderha çok bilmiş";
	yazilar[17] = "bi koydum öldü";
	yazilar[18] = "çok soktun çek";
	yazilar[19] = "gizli mod";
	yazilar[20] = "yakışıklı bey";
	yazilar[21] = "hemen geliyorum";
	yazilar[22] = "cenabet";
	yazilar[23] = "ot ota demiş ki biz otuz";
	yazilar[24] = "mavi arabanın yanındaki kule";
	yazilar[25] = "kutsal damacana";
	yazilar[26] = "mavi arabanın yanındaki kırmızı arabanın altındaki mavi kadın";
	yazilar[27] = "memeler baş kaldırmış";
	yazilar[28] = "kavuşmuyor düğmeler";
	yazilar[29] = "kosovalı";
	yazilar[30] = "at";
	yazilar[31] = "kirpi gülüşü";
	yazilar[32] = "t sustum";
	yazilar[33] = "t susmadım";
	yazilar[34] = "sus ulen";
	yazilar[35] = "ilk yazan kazanır";
	yazilar[36] = "son yazan top";
	yazilar[37] = "siti sustum";
	yazilar[38] = "olan var olmayan var kıskanırlar";
	yazilar[39] = "önemli olan boyu değil işlevi";
	yazilar[40] = "çok mu komik?";
	yazilar[41] = "30 cm damarlı";
	yazilar[42] = "konsola demos yazın";
	yazilar[43] = "baban da yazardı böyle";
	yazilar[44] = "trigonometri";
	yazilar[45] = "para bok";
	yazilar[46] = "Muhammet Ali";
	yazilar[47] = "benim dediğimi yaz";
	yazilar[48] = "Uğur Bayrakdar";
	yazilar[49] = "boş";
	yazilar[50] = "global silver";
	yazilar[51] = "bi susun lan";
	yazilar[52] = "yarrabandı";
	yazilar[53] = "ampul";
	yazilar[54] = "kırmızı arabanın yanındaki pembe kızın yanındaki kırmızı şemsiyeli çocuk";
	yazilar[55] = "yarrrrrdım edin";
	yazilar[56] = "keşkekçinin keşkeklenmiş keşkek kepçesi";
	yazilar[57] = "çok sıcak ulen";
	yazilar[58] = "ayşe hanımın keçileri";
	yazilar[59] = "fatmagülün suçu neydi ki ulen";
	yazilar[60] = "babama sordum babama";
	yazilar[61] = "eller ala dana almış danalanmış biz de ala dana alalım danalanalım";
	yazilar[62] = "Bu yoğurdu sarımsaklasak da mı saklasak, sarımsaklamasak da mı saklasak?";
	yazilar[63] = "Bu çorbayı nanelemeli mi de yemeli, nanelememeli mi de yemeli?";
	yazilar[64] = "bir berber bir berbere gel beraber berberistanda bir berber dükkanı açalım demiş";
	yazilar[65] = "müdür müdür müdür";
	yazilar[66] = "Çökertmeden çıktım da halilim aman başım selamet";
	yazilar[67] = "Ne zaferinden bahsediyorsun, sen savaşla aşkı karıştırmışsın";
	yazilar[68] = "çan çin çon";
	yazilar[69] = "Ne senle, ne de sensiz";
	yazilar[70] = "Geçen bir maça girmiştim, yavşağın teki trolledi";
	yazilar[71] = "ben tiki değilim taam mı";
	yazilar[72] = "bu tuşlara basan parmağım kopsun";
	yazilar[73] = "ilk yazan top";
	yazilar[74] = "pandik";
	yazilar[75] = "adana merkez patlıyo herkes";
	yazilar[76] = "komutçunun sesinden kulağım kanadı";
	yazilar[77] = "mavi arabanın yanına gittim, yanında kırmızı kadın vardı";
	yazilar[78] = "dedi naber dedim iyidir";
	yazilar[79] = "çekoslavakyalılaştıramadıklarımızdan mısınız?";
	yazilar[80] = "uçan uçak";
	yazilar[81] = "yürüyen uçah";
}

public Action RandomYazi(int client, int args)
{
	PrintToChatAll("[SM] \x04%N \x10CT sustum başlatıyor!", client);
	g_timer = CreateTimer(3.0, timer);
}

public Action timer(Handle Timer)
{
	randomSayi = GetRandomInt(0, 81);
	yazdir();
	yazildi = false;
}

void yazdir()
{
	Panel panel = new Panel();
	panel.SetTitle("CT SUSTUM:");
	panel.DrawText(" ");
	panel.DrawText(yazilar[randomSayi]);
	panel.DrawText(" ");
	panel.DrawItem("Tamam");
	for(int i = 1; i <= MaxClients; i++){if (IsClientInGame(i) && !IsFakeClient(i)){panel.Send(i, panel_action, MENU_TIME_FOREVER); ShowMOTDPanel(i, "Ses", "https://translate.google.com/translate_tts?ie=UTF-8&q=31&tl=tr&client=tw-ob", 2);}}	
	g_timer = CreateTimer(0.5, RandomYaziTimer, _, TIMER_REPEAT);
	g_timer = CreateTimer(60.0, bitir, _, TIMER_FLAG_NO_MAPCHANGE);
}
public Action bitir(Handle Timer)
{
	if(!yazildi){
		delete g_timer;
		PrintToChatAll("[SM] \x05Kimse yazı yazmadığı için oyun \x02iptal \x05edildi!");
		return Plugin_Handled;
	}
	return Plugin_Continue;
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
	
	if(StrEqual(yazi, yazilar[randomSayi], true))
	{
		if(!yazildi)
		{
			if(GetClientTeam(client) == CS_TEAM_CT)
			{
				PrintToChatAll("[SM] \x04%N \x10ilk doğru yazan kişi, tebrikler!", client);
				PrintCenterTextAll("<font color='#FFFF00'>%N</font> <font color='#00FFFF'>ilk doğru yazan kişi, tebrikler!</font>", client);
				yazildi = true;
				yazdi[client] = true;
				ctkov();
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}
public Action elbb(Event event, const char[] name, bool dontBroadcast)
{
	yazildi = true;
	delete g_timer;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			yazdi[i] = false;
		}
	}
}
void ctkov()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT && !yazdi[i])
		{
			CS_SwitchTeam(i, CS_TEAM_T);
		}
	}	
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