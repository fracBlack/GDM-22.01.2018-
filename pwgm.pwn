/*
������ �� 22.01.2018
�����: fracBlack
*/

#include <a_samp>
#include <a_ini>
#include <zcmd>
#include <sscanf>
#include <streamer>
#include <foreach>
#include <time>
#include <GSIP>
#include "../include/gl_common.inc"


#define COLOR_AQUA		0x00FFFFFF
#define COLOR_GREY		0x808080FF
#define COLOR_GRAY		0x808080FF
#define COLOR_NAVY		0x000080FF
#define COLOR_SILVER	0xC0C0C0FF
#define COLOR_LGREEN	0x90EE90AA
#define COLOR_GREEN     0x008000AA
#define COLOR_SALAT     0x06ba4bAA
#define COLOR_OLIVE		0x808000FF
#define COLOR_TEAL		0x008080FF
#define COLOR_BLUE		0x7B68EEAA
#define COLOR_LIME		0x00FF00FF
#define COLOR_PURPLE	0x800080FF
#define COLOR_WHITE		0xFFFFFFFF
#define COLOR_FUCHSIA	0xFF00FFFF
#define COLOR_MAROON	0x800000FF
#define COLOR_RED		0xFF0000AA
#define COLOR_YELLOW	0xFFFF00FF
#define COLOR_RP        0x100010AA
#define COLOR_KOJ		0xFFA07A
#define COLOR_ERROR     0xD3D3D3AA
#define COLOR_LIGHTRED 	0xF33535AA

// ����� ����
#define WEAPON_BODY_PART_TORSO 3 // ����
#define WEAPON_BODY_PART_CROTCH 4 // ���
#define WEAPON_BODY_PART_LEFT_ARM 5 // ����� ����
#define WEAPON_BODY_PART_RIGHT_ARM 6 // ������ ����
#define WEAPON_BODY_PART_LEFT_LEG 7 // ����� ����
#define WEAPON_BODY_PART_RIGHT_LEG 8 // ������ ����
#define WEAPON_BODY_PART_HEAD 9 // ������

// rcon
#define rconpass        "login 123" //

// �������
#define APANEL          1000
#define APANEL_1        1001
#define APANEL_2        1002
#define ATPM            2000
#define A_CMD           2001
#define INFO           	2002
#define invite          2004
#define payday          2005
#define bankinfo        2006
#define gunlspd	        2007
#define ammo_buy        2008
#define ammo_silent     2009
#define setting     	2010
#define selectgun       2011
#define selectskin      2012
#define menu            2013
#define stats           2014
#define donate          2015
#define mm          	3100
#define EXIT_REASON_BAN 2018
#define D_REPORT        2020
#define D_CMD          2021
#define D_INFO          2022
#define D_TDM          3200
#define D_RULES_TDM      2023
#define D_PACK          3300
#define D_INFO_TDM      2024
#define D_MEMBERS       2025
#define D_LEVEL_INFO    2026
#define A_HELP          2027
#define D_PVP           3400
#define P_SET           3600
#define CREDITS         2028
#define D_RANGS         2029
#define D_STATISTIC     2030
#define D_VEH           3700
#define D_SELLVEH       2031
#define D_AMMO          3800
#define D_GPS           3900
#define D_INV           4000
#define D_HEALUP        2032
#define D_TRAIN         4100
#define D_AIR           2033
#define D_TUNE          4200
#define D_TPANEL        4300

// �������
#define SPD             ShowPlayerDialog
#define SCM             SendClientMessage
#define SCMTA           SendClientMessageToAll
#define DLIST 			DIALOG_STYLE_LIST
#define DINPUT 			DIALOG_STYLE_INPUT
#define DPASS 			DIALOG_STYLE_PASSWORD
#define DBOX 			DIALOG_STYLE_MSGBOX

// �������
#define f(  format(string,sizeof(string),
#define GN(%1) PlayerInfo[%1][pName]

forward OtherTimerr();
forward Reklama();
static SetReklama;
forward ProxDetectorS(Float:radi, playerid, targetid);
forward Update(playerid);
forward IsVehicleOccupied(vehicleid);
forward RespCar();
forward RestartTimer(playerid);
forward KickTimer(playerid);
forward IsAtCandySprunk(playerid);

public IsVehicleOccupied(vehicleid)
{
    for(new i=0;i<MAX_PLAYERS;i++)
    {
        if(IsPlayerInVehicle(i,vehicleid)) return 1;
    }
    return 0;
}
// TDM
#define TEAM_ATTACK 1
#define TEAM_DEFINED 2
#define TEAM_REFREE 3
#define TEAM_ATTACK_COLOR COLOR_ERROR
#define TEAM_DEFINED_COLOR COLOR_ERROR

// PRICE GUN
#define PRICE_SD        5
#define PRICE_DEAGLE    10
#define PRICE_SHOTGUN   12
#define PRICE_M4        20
#define PRICE_RIFLE     25
#define PRICE_SNIPER    100

#define PRICE_HEALUP    1100 // ���� �� �����
#define TRAIN_ZP        10000 // �� �� ���� �������� �� ����������

#define LOCK_THE_TRAIN false     // ���������� �������� (true - �������/false - �������)

#define FOLLOW_TDM  	1
#define FOLLOW_SRACE    2

new Float:bolka[2][3] =
{
	{2034.5220,-1412.1310,16.9922}, // � �����
	{1172.8567,-1323.3353,15.3997} // � ������
};

new Float:ammopos[7][3] =
{
	{2169.5769,-1800.8601,13.3665},
	{1104.4542,-1383.4785,13.7813},
	{1331.2258,-1119.4856,24.0375},
	{1681.0171,-1342.8783,17.5530},
	{1263.4238,-2028.9175,59.3221},
	{1969.7012,-1783.4019,13.6320},
	{807.5547,-1531.9506,13.6744}
};
new ammo_playerid[MAX_PLAYERS];

new RandomMessage[][] =
{
	"������ ���������� � ������, �� �� ������� ������ ������ ������? ������ ���� ��� - {FFFFFF}/world",
	"��� ������� �� ������ ������ � ����� ������ ��������� - {FFFFFF}vk.com/",
	"������� ������? �� ����, ������������ ����������� - {FFFFFF}/restream",
	"������ �����, ������ �������� ���� ������� � ������� ����� ��������� ������? ������� ������� - {FFFFFF}/buylevel",
	"��� ������� ������� �� ������ ����� � {FFFFFF}/mm - ������ ������"
};
new bool:TDM_VEH_ALL;
new TDM_VEH[8];
new TDM_VEHICLE = 422;
new PLAYER_TRAIN_ZP[MAX_PLAYERS];
new status_lock[MAX_VEHICLES];
new numb = 0;
new bool:TWeaponL = LOCK_THE_TRAIN;
new raz = 0;
new prostt[MAX_PLAYERS];
new ATrain[5];
new igun[4][MAX_PLAYERS];
new ipt[4][MAX_PLAYERS];
new Float:POSITION_FOR_RESTREAM[3];
new savept;
new SET_SKIN[MAX_PLAYERS] = 299;
new CountVezit;
new othtimer;
new ANTI_DM[MAX_PLAYERS];
static gGun1[MAX_PLAYERS];
static gGun2[MAX_PLAYERS];
static gTEAM_SCORE_ATTACK;
static gTEAM_SCORE_DEFINED;
static TDM_Lock;
new GPS[MAX_PLAYERS] = 0;
new CalledVehicle[MAX_PLAYERS];
static vehicle[MAX_PLAYERS];
static vehicle_player_a[MAX_PLAYERS];
new a_vehicle[MAX_PLAYERS];

new logotipe_p[MAX_PLAYERS] = 1;
new info_p[MAX_PLAYERS] = 1;

new gangflash;
//new pvp[MAX_PLAYERS];
new gopvp[MAX_PLAYERS];
new gopvpId[MAX_PLAYERS];
static pvpv = 10;
new activepvp[MAX_PLAYERS];
new activepvar;
new dangerpvp;
static pvp_score[MAX_PLAYERS];
new spawnpvp[MAX_PLAYERS];

new gTeam[MAX_PLAYERS];
new PlayerDeathMatch[MAX_PLAYERS];
new bool:PlayerTrainZone[MAX_PLAYERS];

new TEAM_ATTACK_SKIN = 106; // ����� �����
new TEAM_DEFINED_SKIN = 174; // ����� ���
static TEAM_REFREE_SKIN[MAX_PLAYERS]; // ���� ���

new TDM;
new tdm_aero;
new tdm_stadion;

new Text3D:AdminText3D[MAX_PLAYERS];

new PlayerKill[MAX_PLAYERS];
new gpn[220];
new Login[MAX_PLAYERS];
new CarID[MAX_PLAYERS];
new VehID[MAX_PLAYERS];
new MapTP;
new dm_armour;
// gangzone
new dm1;
new dm2;
new dm3;
new tdm1;
new tdm2;

new HitDefTime[MAX_PLAYERS];

new Text:logo[2];
new Text:welcome[5];
new Text:Stats[MAX_PLAYERS];
new Text:moneyplus;
new Text:moneyminus;
new Text:monster[2];
new Text:score[3][MAX_PLAYERS];
new Text:FPS[MAX_PLAYERS];
new Text:IP;
new Text:timertdm[4];

new TimerSSS, KolvoSEC = 360;

//pickups
new parashut[9];
new ammo[7];
new ammoexit;
new ammobuy;
new healup[2];

static iPlayerChatTime[MAX_PLAYERS];
static szPlayerChatMsg[MAX_PLAYERS][128];

enum pInfo {
	pEntered,
	pName[MAX_PLAYER_NAME],
	Password[32],
	pScore,
	pDeath,
	pMoney,
	pBanned,
	pMute,
	pAdmin,
	pLockTP,
	pSkin,
	pClanInvite,
	pLevel,
	pVeh,
	pColorVeh1,
	pColorVeh2,
	pNitro,
	pFollow,
	pIGun0,
	pIPt0,
	pIGun1,
	pIPt1,
	pIGun2,
	pIPt2,
	pIGun3,
	pIPt3,
	pHealUp,
	pSpawnType,
};
new PlayerInfo[MAX_PLAYERS][pInfo];

main(){}

public OnGameModeInit()
{
	new a_skin = random(299);
	ATrain[0] = CreateActor(a_skin, 1367.6356,-19.4802,1000.9219,267.1120);
	ATrain[1] = CreateActor(a_skin, 1369.1344,-31.8131,1000.9219,289.3981);
	ATrain[2] = CreateActor(a_skin, 1379.2965,-41.1018,1000.9244,317.2458);
	ATrain[3] = CreateActor(a_skin, 1372.5900,-9.1787,1000.9219,236.1087);
	ATrain[4] = CreateActor(a_skin, 1379.4927,-18.9240,1000.9252,256.0838);
	SetActorHealth(ATrain[0], 1);
	SetActorHealth(ATrain[1], 1);
	SetActorHealth(ATrain[2], 1);
	SetActorHealth(ATrain[3], 1);
	SetActorHealth(ATrain[4], 1);
    SetActorInvulnerable(ATrain[0], 0);
    SetActorInvulnerable(ATrain[1], 0);
    SetActorInvulnerable(ATrain[2], 0);
    SetActorInvulnerable(ATrain[3], 0);
    SetActorInvulnerable(ATrain[4], 0);
   	new Float:actorHealth[5];
    GetActorHealth(ATrain[0], actorHealth[0]);
    GetActorHealth(ATrain[1], actorHealth[1]);
    GetActorHealth(ATrain[2], actorHealth[2]);
    GetActorHealth(ATrain[3], actorHealth[3]);
    GetActorHealth(ATrain[4], actorHealth[4]);
    printf("Actor ID %d | HP = %.2f", ATrain[0], actorHealth[0]);
    printf("Actor ID %d | HP = %.2f", ATrain[1], actorHealth[1]);
    printf("Actor ID %d | HP = %.2f", ATrain[2], actorHealth[2]);
    printf("Actor ID %d | HP = %.2f", ATrain[3], actorHealth[3]);
    printf("Actor ID %d | HP = %.2f", ATrain[4], actorHealth[4]);
    Create3DTextLabel("��������� �1", COLOR_GREEN,ammopos[0][0], ammopos[0][1], ammopos[0][2],50.0,0,0);
	SetGameModeText("Green DM"); // �������� ����
    dm_armour = 1;
    // ���������
	CreateObject(10631, 1104.83398, -1373.83313, 17.05792,   0.00000, 0.00000, 180.74010);
	CreateObject(10631, 1321.77588, -1119.44617, 27.19370,   0.00000, 0.00000, 273.38092);
	CreateObject(10631, 1661.83569, -1342.10315, 11.76102,   0.00000, 0.00000, 270.59995);
	CreateObject(10631, 2159.57861, -1800.44470, 16.52525,   0.00000, 0.00000, -88.98000);
	CreateObject(10631, 1979.16296, -1783.93445, 16.78830,   0.00000, 0.00000, 90.47994);
	CreateObject(10631, 1264.16614, -2019.07446, 62.57854,   0.00000, 0.00000, 178.79999);
	CreateObject(10631, 811.90710, -1523.53186, 16.83069,   0.00000, 0.00000, 156.17992);
	CreateObject(10631, 1671.54724, -1342.36829, 20.70922,   0.00000, 0.00000, 270.59995);
	CreateObject(10631, 1676.93408, -1342.21570, 11.73422,   0.00000, 0.00000, 270.59995);
	CreateObject(10631, 1676.51770, -1353.22253, 11.63523,   0.00000, 0.00000, 270.59995);
	CreateObject(10631, 1666.06323, -1352.82727, 11.63523,   0.00000, 0.00000, 270.59995);
	
	LoadTextDraw();
	LoadVehicle();
	LoadGangZone();
	LoadPickup();
    LimitPlayerMarkerRadius(15.0);
    SetNameTagDrawDistance(15.0);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    //UsePlayerPedAnims();
    othtimer = SetTimer("OtherTimerr", 1000, 1);
    SetTimer("Reklama",1000*60*10,1);
    SetTimer("Update",60,1);
    SetTimer("SendMessage", 60000*5, true);
	
	new i = 0;
	while(i < 21)
	{
	    AddPlayerClass(i, 0.0,0.0,0.0,0.0, 0,0,0,0,0,0);
	    i++;
	}
    for(new v; v < MAX_VEHICLES; v++) SetVehicleNumberPlate(v, "Pawn-Wiki");
	return 1;
}

public OnGameModeExit()
{
    KillTimer(othtimer);
	return 1;
}

forward SendMessage();
public SendMessage()
{
	new rand = random(sizeof(RandomMessage));
	SendClientMessageToAll(COLOR_SALAT, RandomMessage[rand]);
}

public ProxDetectorS(Float:radi, playerid, targetid)
{
	if(IsPlayerConnected(playerid)&&IsPlayerConnected(targetid))
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		//radi = 2.0; //Trigger Radius
		GetPlayerPos(targetid, posx, posy, posz);
		tempposx = (oldposx -posx);
		tempposy = (oldposy -posy);
		tempposz = (oldposz -posz);
		//printf("DEBUG: X:%f Y:%f Z:%f",posx,posy,posz);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return 1;
		}
	}
	return 0;
}

public IsAtCandySprunk(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid, 2, -2420.219, 984.578, 44.297)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2420.180, 985.945, 44.297)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2225.203, -1153.422, 1025.906)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2576.703, -1284.430, 1061.094)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2155.906, 1606.773, 1000.055)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2209.906, 1607.195, 1000.055)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2222.203, 1606.773, 1000.055)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 495.969, -24.320, 1000.734)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 501.828, -1.430, 1000.734)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 373.828, -178.141, 1000.734)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 330.680, 178.500, 1020.070)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 331.922, 178.500, 1020.070)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 350.906, 206.086, 1008.477)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 361.563, 158.617, 1008.477)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 371.594, 178.453, 1020.070)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 374.891, 188.977, 1008.477)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2155.844, 1607.875, 1000.063)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2202.453, 1617.008, 1000.063)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2209.242, 1621.211, 1000.063)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2222.367, 1602.641, 1000.063)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 500.563, -1.367, 1000.734)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 379.039, -178.883, 1000.734)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2480.86,-1959.27,12.9609)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1634.11,-2237.53,12.8906)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2139.52,-1161.48,23.3594)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2153.23,-1016.15,62.2344)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -1350.12,493.859,10.5859)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2229.19,286.414,34.7031)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1659.46,1722.86,10.2188)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2647.7,1129.66,10.2188)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2845.73,1295.05,10.7891)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1398.84,2222.61,10.4219)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -1455.12,2591.66,55.2344)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -76.0312,1227.99,19.125)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 662.43,-552.164,15.7109)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -253.742,2599.76,62.2422)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2271.73,-76.4609,25.9609)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1789.21,-1369.27,15.1641)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1729.79,-1943.05,12.9453)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2060.12,-1897.64,12.9297)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1928.73,-1772.45,12.9453)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2325.98,-1645.13,14.2109)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2352.18,-1357.16,23.7734)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1154.73,-1460.89,15.1562)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -1350.12,492.289,10.5859)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2118.97,-423.648,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2118.62,-422.414,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2097.27,-398.336,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2092.09,-490.055,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2063.27,-490.055,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2005.65,-490.055,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2034.46,-490.055,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2068.56,-398.336,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2039.85,-398.336,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -2011.14,-398.336,34.7266)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -1980.79,142.664,27.0703)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2319.99,2532.85,10.2188)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1520.15,1055.27,10.00)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2503.14,1243.7,10.2188)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 2085.77,2071.36,10.4531)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -862.828,1536.61,21.9844)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -14.7031,1175.36,18.9531)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, -253.742,2597.95,62.2422)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 201.016,-107.617,0.898438)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 2, 1277.84,372.516,18.9531)) return 1;
	else return 0;
}
new PLAYER_STATUS_CONNECT[MAX_PLAYERS];
#define CHANGE_SKIN_CONNECT 0
#define SPAWN_PLAYER_CONNECT 1
public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid,1944.9351,986.4768,992.4688);
	SetPlayerFacingAngle(playerid, 268.9163);
	SetPlayerCameraPos(playerid,1948.3185,986.4310,992.4688);
	SetPlayerCameraLookAt(playerid,1944.9351,986.4768,992.4688);
	SetPlayerInterior(playerid,10);
	PLAYER_STATUS_CONNECT[playerid] = CHANGE_SKIN_CONNECT;
	SET_SKIN[playerid] = classid;
	return 1;
}

public OnPlayerConnect(playerid)
{
    SetPlayerMapIcon(playerid, 1, ammopos[0][0], ammopos[0][1], ammopos[0][2], 18, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 2, ammopos[1][0], ammopos[1][1], ammopos[1][2], 18, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 3, ammopos[2][0], ammopos[2][1], ammopos[2][2], 18, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 4, ammopos[3][0], ammopos[3][1], ammopos[3][2], 18, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 5, ammopos[4][0], ammopos[4][1], ammopos[4][2], 18, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 6, ammopos[5][0], ammopos[5][1], ammopos[5][2], 18, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 7, ammopos[6][0], ammopos[6][1], ammopos[6][2], 18, 0, MAPICON_LOCAL);
	LoadDeleteObjects(playerid);
//---------------------------------------------------------------------------
    new countvezitstr[128];
    format(countvezitstr, sizeof(countvezitstr), "������� ������ �������� %d �������", CountVezit);
    CountVezit++;
    SendClientMessage(playerid,0xFF0606AA, countvezitstr);
//------------------------------------------------------------------------------
    TextDrawShowForPlayer(playerid, Text:welcome[0]);
    TextDrawShowForPlayer(playerid, Text:welcome[1]);
    TextDrawShowForPlayer(playerid, Text:welcome[2]);
    TextDrawShowForPlayer(playerid, Text:welcome[3]);
    TextDrawShowForPlayer(playerid, Text:welcome[4]);
	SetTimerEx("HideTextWelcome", 6000, 0, "i", playerid);
    TextDrawShowForPlayer(playerid, Text:logo[0]);
    TextDrawShowForPlayer(playerid, Text:logo[1]);

	PlayerInfo[playerid][pEntered] = 0;
	PlayerDeathMatch[playerid] = 0;
	TEAM_REFREE_SKIN[playerid] = 175;

	SetPlayerColor(playerid, 0xC4C4C4AA);
    //TextDrawShowForPlayer(playerid, Text:connect[0]);
	new string[128];
	//TogglePlayerSpectating(playerid, true);
	gTeam[playerid] = TEAM_REFREE;
	GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
	format(string, sizeof(string), "Accounts/%s.ini", PlayerInfo[playerid][pName]);
	if(fexist(string))
	{
    	GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� ��������������� � ���� ������\n����������, ������� ��� ������ ��� �����������", PlayerInfo[playerid][pName]);
		ShowPlayerDialog(playerid, 2, DIALOG_STYLE_PASSWORD, "�����������",gpn,"����","������");
	}
	else
	{
    	GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� �� ��������������� � ���� ������\n����������, ������� �������� ������ ��� �����������", PlayerInfo[playerid][pName]);
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "�����������",gpn,"�����","������");
	}
 	new sendername[MAX_PLAYER_NAME];
  	new string7[256];
   	new ipplayer[256];
	GetPlayerIp(playerid,ipplayer,sizeof(ipplayer));
 	GetPlayerName(playerid,sendername,sizeof(sendername));
  	format(string7, sizeof(string7), "[A] ����������� �����: %s[%d] IP: [%s]",sendername,playerid,ipplayer);
   	AdmChat(COLOR_GREY,string7);

   	LoadTextDrawForPlayer(playerid);
	return 1;
}

forward OnPlayerAir(playerid);
public OnPlayerAir(playerid)
{
	CallPlayerVehicle(playerid);
	SCM(playerid, COLOR_ERROR, " *�� �������� � ����");
	return 1;
}

forward CallPlayerVehicle(playerid);
public CallPlayerVehicle(playerid)
{
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	vehicle[playerid] = CreateVehicle(PlayerInfo[playerid][pVeh], pos[0], pos[1], pos[2]+3, 0, PlayerInfo[playerid][pColorVeh1], PlayerInfo[playerid][pColorVeh2], -1, 0);
	PutPlayerInVehicle(playerid, vehicle[playerid], 0);
	CalledVehicle[playerid] = 1;
	if(PlayerInfo[playerid][pNitro] != 0)
	{
		AddVehicleComponent(vehicle[playerid], PlayerInfo[playerid][pNitro]);
	}
	return 1;
}

forward HideTextWelcome(playerid);
public HideTextWelcome(playerid)
{
    TextDrawHideForPlayer(playerid, Text:welcome[0]);
    TextDrawHideForPlayer(playerid, Text:welcome[1]);
    TextDrawHideForPlayer(playerid, Text:welcome[2]);
    TextDrawHideForPlayer(playerid, Text:welcome[3]);
    TextDrawHideForPlayer(playerid, Text:welcome[4]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerTrainZone[playerid] == true) PlayerTrainZone[playerid] = false;
	if(PlayerInfo[playerid][pEntered] == 1)
	{
	    PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);
		PlayerDeathMatch[playerid] = 0;
		PlayerInfo[playerid][pEntered] = 0;
	    if(GetPVarInt(playerid, "Kick") != 0) KillTimer(GetPVarInt(playerid, "Kick"));
		new string[128];
		format(string, sizeof(string), "Accounts/%s.ini", PlayerInfo[playerid][pName]);
		new iniFile = ini_openFile(string);
		ini_setInteger(iniFile, "Admin", PlayerInfo[playerid][pAdmin]);
		ini_setInteger(iniFile, "Score", GetPlayerScore(playerid));
		ini_setInteger(iniFile, "Banned", PlayerInfo[playerid][pBanned]);
		ini_setInteger(iniFile, "Mute", PlayerInfo[playerid][pMute]);
		ini_setInteger(iniFile, "Skin", GetPlayerScore(playerid));
		ini_setInteger(iniFile, "LockTP", PlayerInfo[playerid][pLockTP]);
		ini_setInteger(iniFile, "Death", PlayerInfo[playerid][pDeath]);
		ini_setInteger(iniFile, "Money", GetPlayerMoney(playerid));
		ini_setInteger(iniFile, "ClanInvite", PlayerInfo[playerid][pClanInvite]);
		ini_setInteger(iniFile, "Level", PlayerInfo[playerid][pLevel]);
		ini_setInteger(iniFile, "Veh", PlayerInfo[playerid][pVeh]);
		ini_setInteger(iniFile, "ColorVeh1", PlayerInfo[playerid][pColorVeh1]);
		ini_setInteger(iniFile, "ColorVeh2", PlayerInfo[playerid][pColorVeh2]);
		ini_setInteger(iniFile, "Nitro", PlayerInfo[playerid][pNitro]);
		ini_setInteger(iniFile, "Follow", PlayerInfo[playerid][pFollow]);
		ini_setInteger(iniFile, "IGun0", PlayerInfo[playerid][pIGun0]);
		ini_setInteger(iniFile, "IGun1", PlayerInfo[playerid][pIGun1]);
		ini_setInteger(iniFile, "IGun2", PlayerInfo[playerid][pIGun2]);
		ini_setInteger(iniFile, "IGun3", PlayerInfo[playerid][pIGun3]);
        ini_setInteger(iniFile, "IPt0", PlayerInfo[playerid][pIPt0]);
        ini_setInteger(iniFile, "IPt1", PlayerInfo[playerid][pIPt1]);
        ini_setInteger(iniFile, "IPt2", PlayerInfo[playerid][pIPt2]);
        ini_setInteger(iniFile, "IPt3", PlayerInfo[playerid][pIPt3]);
        ini_setInteger(iniFile, "HealUp", PlayerInfo[playerid][pHealUp]);
        ini_setInteger(iniFile, "SpawnType", PlayerInfo[playerid][pSpawnType]);
		ini_closeFile(iniFile);
		iPlayerChatTime[playerid] = 0;
		szPlayerChatMsg[playerid] = "";
		if(PlayerInfo[playerid][pAdmin] > 0)
		{
		 	new bye[120], title[42];
		   	if(PlayerInfo[playerid][pAdmin] == 1) title = "���������";
			else if(PlayerInfo[playerid][pAdmin] == 2) title = "������� ���������";
			else if(PlayerInfo[playerid][pAdmin] == 3) title = "�������������";
			else if(PlayerInfo[playerid][pAdmin] == 4) title = "������� �������������";
			else if(PlayerInfo[playerid][pAdmin] == 5) title = "������� �������������";
			else if(PlayerInfo[playerid][pAdmin] == 6) title = "����������";
			format(bye, sizeof(bye), "[A] %s %s[%d] �����.", title, GN(playerid), playerid);
			AdmChat(COLOR_YELLOW, bye);
		}
		Delete3DTextLabel(AdminText3D[playerid]);
		TextDrawDestroy(FPS[playerid]);
		DestroyVehicle(vehicle[playerid]);
	}
	else return 1;
	return 1;
}

public OnPlayerSpawn(playerid)
{
    GivePlayerWeapon(playerid, 22, 50);
    Delete3DTextLabel(AdminText3D[playerid]);
	SetPlayerInterior(playerid, 0);
	SetPlayerHealth(playerid, 100);
    //SetPlayerColor(playerid, COLOR_ERROR);
	/*if(PlayerInfo[playerid][pSkin] == 0)
 	{
			SetPlayerPos(playerid, 1564.8236,-1380.8655,401.7498);
			SetPlayerFacingAngle(playerid,101.8594);
			{
				TogglePlayerControllable(playerid, false);
				SCM(playerid, -1, "");
				SCM(playerid, -1, "");
				SCM(playerid, -1, "");
				SCM(playerid, -1, "");
				SCM(playerid, -1, "");
				SCM(playerid, -1, "�������� ���� ������� ����, ������� - /skin [1-311].");
				SCM(playerid, -1, "���������� ������ ������ ����� ��: http://wiki.sa-mp.com/wiki/Skins:All");
				SCM(playerid, -1, "");
				SCM(playerid, -1, "����� ������ ����� �� ������� ��� �������� �������� /skin.");
				SCM(playerid, -1, "");
				SCM(playerid, -1, "");
			}
	}*/
	//SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	if(PlayerTrainZone[playerid] == true)
	{
			                if(!IsPlayerInRangeOfPoint(playerid, 50.0, 1392.6025,-20.8305,1000.9109))
			    			{
			    			    new str[128];
			    			    SpawnPlayer(playerid);
					    	    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� �������� ���� ����������. ���������� ���������.");
					    	    format(str,sizeof(str),"{FFFF00}[����������] {FFFFFF}����� ����������: %d$", PLAYER_TRAIN_ZP[playerid]);
					    	    SCM(playerid, 0xFFFF00, str);
								PlayerTrainZone[playerid] = false;
								ResetPlayerWeapons(playerid);
								DisablePlayerCheckpoint(playerid);
			    			}
	}
	if(PlayerInfo[playerid][pSpawnType] == 1)
	{
	    DestroyVehicle(vehicle[playerid]);
	    SetTimerEx("SpawnType", 1000, 0, "i", playerid);
	}
	if(gTeam[playerid] == TEAM_REFREE){
	    if(SET_SKIN[playerid] == 0) SET_SKIN[playerid] = 299;
		SetPlayerSkin(playerid, SET_SKIN[playerid]);
	}
	spawnpvp[playerid] = pvpv;
	if(activepvp[playerid] == 1)
	{
		 	switch(random(8))
			{
			    case 0: SetPlayerPos(playerid, -445.4210,2223.1973,42.4297);
			    case 1: SetPlayerPos(playerid, -439.5626,2250.6855,42.4297);
			    case 2: SetPlayerPos(playerid, -411.5861,2264.4600,42.3509);
			    case 3: SetPlayerPos(playerid, -410.4398,2213.3442,42.4297);
			    case 4: SetPlayerPos(playerid, -392.0173,2195.2095,42.4164);
			    case 5: SetPlayerPos(playerid, -350.7846,2209.3391,42.4844);
			    case 6: SetPlayerPos(playerid, -350.9970,2246.5398,42.4844);
			    case 7: SetPlayerPos(playerid, -372.3033,2269.7151,42.0940);
			}
		 	switch(random(8))
			{
			    case 0: SetPlayerPos(gopvpId[playerid], -445.4210,2223.1973,42.4297);
			    case 1: SetPlayerPos(gopvpId[playerid], -439.5626,2250.6855,42.4297);
			    case 2: SetPlayerPos(gopvpId[playerid], -411.5861,2264.4600,42.3509);
			    case 3: SetPlayerPos(gopvpId[playerid], -410.4398,2213.3442,42.4297);
			    case 4: SetPlayerPos(gopvpId[playerid], -392.0173,2195.2095,42.4164);
			    case 5: SetPlayerPos(gopvpId[playerid], -350.7846,2209.3391,42.4844);
			    case 6: SetPlayerPos(gopvpId[playerid], -350.9970,2246.5398,42.4844);
			    case 7: SetPlayerPos(gopvpId[playerid], -372.3033,2269.7151,42.0940);
			}
			SetPlayerVirtualWorld(playerid, spawnpvp[playerid]);
			GivePlayerWeapon(playerid, gGun1[playerid], 1500);
			GivePlayerWeapon(playerid, gGun2[playerid], 1500);
			SetPlayerHealth(playerid, 100);
			if(dm_armour == 1) SetPlayerArmour(playerid, 100);
	}
	if(PlayerDeathMatch[playerid] == 0 && activepvp[playerid] == 0)
	{
	 	switch(random(12))
		{
		    case 0: SetPlayerPos(playerid, 1129.4718,-1455.3094,15.7969);
		    case 1: SetPlayerPos(playerid, 1693.0211,-1343.7659,17.4472);
		    case 2: SetPlayerPos(playerid, 2016.6740,-1143.5568,25.0200);
		    case 3: SetPlayerPos(playerid, 902.2699,-1238.6802,16.2490);
		    case 4: SetPlayerPos(playerid, 925.9724,-1084.1674,24.2891);
		    case 5: SetPlayerPos(playerid, 1333.3307,-1100.5815,24.6171);
		    case 6: SetPlayerPos(playerid, 804.6597,-1548.3232,13.5615);
		    case 7: SetPlayerPos(playerid, 489.5130,-1505.3882,20.6044);
		    case 8: SetPlayerPos(playerid, 1251.3844,-2030.4645,59.6651);
		    case 9: SetPlayerPos(playerid, 1481.0637,-1679.8412,14.0469);
		    case 10: SetPlayerPos(playerid, 1919.1431,-1760.3213,13.5469);
		    case 11: SetPlayerPos(playerid, 2184.2976,-1799.0032,13.3647);
		}
	}
	if(PlayerDeathMatch[playerid] == 1)
	{
	 	switch(random(8))
		{
		    case 0: SetPlayerPos(playerid, -445.4210,2223.1973,42.4297);
		    case 1: SetPlayerPos(playerid, -439.5626,2250.6855,42.4297);
		    case 2: SetPlayerPos(playerid, -411.5861,2264.4600,42.3509);
		    case 3: SetPlayerPos(playerid, -410.4398,2213.3442,42.4297);
		    case 4: SetPlayerPos(playerid, -392.0173,2195.2095,42.4164);
		    case 5: SetPlayerPos(playerid, -350.7846,2209.3391,42.4844);
		    case 6: SetPlayerPos(playerid, -350.9970,2246.5398,42.4844);
		    case 7: SetPlayerPos(playerid, -372.3033,2269.7151,42.0940);
		}
		if(dm_armour == 1) SetPlayerArmour(playerid, 100);
	}
	if(PlayerDeathMatch[playerid] == 2)
	{
	 	switch(random(8))
		{
		    case 0: SetPlayerPos(playerid, 2605.7703,2707.6506,36.1997);
		    case 1: SetPlayerPos(playerid, 2631.9253,2720.9282,36.1601);
		    case 2: SetPlayerPos(playerid, 2631.6123,2717.2773,33.9783);
		    case 3: SetPlayerPos(playerid, 2615.8176,2706.0972,25.8222);
		    case 4: SetPlayerPos(playerid, 2605.1643,2731.4534,23.8222);
		    case 5: SetPlayerPos(playerid, 2628.9973,2752.6213,23.8222);
		    case 6: SetPlayerPos(playerid, 2641.7649,2781.9226,23.8222);
		    case 7: SetPlayerPos(playerid, 2595.3110,2775.3281,23.8222);
		}
		if(dm_armour == 1) SetPlayerArmour(playerid, 100);
	}
	if(PlayerDeathMatch[playerid] == 3)
	{
					 	switch(random(12))
						{
						    case 0: SetPlayerPos(playerid, 1609.2114,2324.8989,10.8203);
						    case 1: SetPlayerPos(playerid, 1649.6317,2371.6128,10.8203);
						    case 2: SetPlayerPos(playerid, 1674.8348,2398.4629,10.8203);
						    case 3: SetPlayerPos(playerid, 1695.1720,2354.2163,10.8203);
						    case 4: SetPlayerPos(playerid, 1676.7113,2302.2229,10.8203);
						    case 5: SetPlayerPos(playerid, 1702.4471,2292.4709,10.8203);
						    case 6: SetPlayerPos(playerid, 1697.0825,2334.7505,10.8203);
						    case 7: SetPlayerPos(playerid, 1654.9846,2323.5359,21.1676);
						    case 8: SetPlayerPos(playerid, 1665.4963,2357.3474,21.3845);
						    case 9: SetPlayerPos(playerid, 1670.9081,2302.8088,21.3845);
						    case 10: SetPlayerPos(playerid, 1654.7216,2380.1387,21.3845);
						    case 11: SetPlayerPos(playerid, 1670.8424,2388.4595,21.3845);
						}
						if(dm_armour == 1) SetPlayerArmour(playerid, 100);
	}
	if(PlayerDeathMatch[playerid] > 0)
	{
		GivePlayerWeapon(playerid, gGun1[playerid], 1500);
		GivePlayerWeapon(playerid, gGun2[playerid], 1000);
	}
	GangZoneShowForPlayer(playerid, dm1, -16777017);
	GangZoneShowForPlayer(playerid, dm2, -16777017);
	GangZoneShowForPlayer(playerid, dm3, -16777017);
	GangZoneShowForPlayer(playerid, tdm1, -66);
	GangZoneShowForPlayer(playerid, tdm2, -66);
	if(gTeam[playerid] == TEAM_ATTACK)
	{
		SetPlayerColor(playerid, TEAM_ATTACK_COLOR);
		SetPlayerSkin(playerid, TEAM_ATTACK_SKIN);
	}
	if(gTeam[playerid] == TEAM_DEFINED)
	{
		SetPlayerColor(playerid, TEAM_DEFINED_COLOR);
		SetPlayerSkin(playerid, TEAM_DEFINED_SKIN);
	}
	if(TDM == 1)
	{
		if(tdm_stadion == 1){
			        if(gTeam[playerid] == 1)
			        {
			            SetPlayerPos(playerid, 2791.4883,-1847.5679,9.8446);
			        }
			        if(gTeam[playerid] == 2)
			        {
			            SetPlayerPos(playerid, 2668.9751,-1684.8577,9.8389);
			        }
     				SetPlayerHealth(playerid, 100);
					SetPlayerArmour(playerid, 100);
					GivePlayerWeapon(playerid, gGun1[playerid], 1000);
					GivePlayerWeapon(playerid, gGun2[playerid], 1000);
					return 1;}
		if(tdm_aero == 1){
			        if(gTeam[playerid] == 1)
			        {
			            SetPlayerPos(playerid, 417.8917,2543.8604,16.3947);
			        }
			        if(gTeam[playerid] == 2)
			        {
			            SetPlayerPos(playerid, 351.2186,2444.9973,16.9636);
			        }
     				SetPlayerHealth(playerid, 100);
					SetPlayerArmour(playerid, 100);
					GivePlayerWeapon(playerid, gGun1[playerid], 1000);
					GivePlayerWeapon(playerid, gGun2[playerid], 1000);
					return 1;}
	}
	return 1;
}

forward SpawnType(playerid);
public SpawnType(playerid)
{
	if(PlayerDeathMatch[playerid] > 0) return 1;
	new str[144];
	CallPlayerVehicle(playerid);
	format(str, sizeof(str), "� ��� ������ ��� ������ � ������, ����� ������� ���, �������������� ����������� {FFFFFF}(/menu(Y) - ��������� - ��� ������)");
	SCM(playerid, COLOR_YELLOW, str);
	return 1;
}

public OtherTimerr()
{
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
                if(IsPlayerConnected(i))
        {
                new string[256], kill[256], death[256], level[256];
                format(string,sizeof(string),"FPS: %d Ping: %d PacketLoss: 0.0%",GetPlayerFPS(i),GetPlayerPing(i));
                TextDrawSetString(FPS[i], string);
                TextDrawSetString(Stats[i], GN(i));
                format(kill,sizeof(kill),"K: %d", GetPlayerScore(i));
                TextDrawSetString(score[0][i], kill);
                format(death,sizeof(death),"D: %d", PlayerInfo[i][pDeath]);
                TextDrawSetString(score[1][i], death);
                format(level,sizeof(level),"Level: %d", PlayerInfo[i][pLevel]);
                TextDrawSetString(score[2][i], level);
                }
        }
}

/*public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
    if(damagedid != INVALID_PLAYER_ID)
	{
    }
    return 1;
}*/
forward OnActorDeath(damaged_actorid, playerid, weaponid, Float:x,Float:y,Float:z);
public OnActorDeath(damaged_actorid, playerid, weaponid, Float:x,Float:y,Float:z)
{
	new Float:xx, Float:yy, Float:zz;
	GetActorPos(damaged_actorid, xx,yy,zz);
	SetPlayerCheckpoint(playerid, xx,yy,zz,1.5);
	DestroyActor(damaged_actorid);
	new a_skin = random(299);
	damaged_actorid = CreateActor(a_skin,x,y,z,90.0);
	SetActorInvulnerable(damaged_actorid, 0);
	SetActorHealth(damaged_actorid, 1);
	return 1;
}
CMD:tdmpanel(playerid)
{
	if(PlayerInfo[playerid][pFollow] != FOLLOW_TDM) return SCM(playerid, COLOR_ERROR, "�� �� �������� �� TDM");
	new str[2048];
	format(str,sizeof(str),"������� ��������� ��� ����� ������\n������� ���� ��������� � �������\n������� ��������� ��� ATTACK\n������� ��������� ��� DEFENDER");
	SPD(playerid, D_TPANEL, DLIST, "������ �������", str, "�������", "������");
	return 1;
}
CMD:gow(playerid)
{
	if(PlayerTrainZone[playerid] == false) return SCM(playerid, COLOR_ERROR, "�� �� � ���� ����������");
	ShowWTrain(playerid);
	return 1;
}
CMD:getapos(playerid)
{
	new Float:xx, Float:yy, Float:zz;
	GetActorPos(ATrain[0], xx,yy,zz);
	SetPlayerCheckpoint(playerid, xx,yy,zz, 1.0);
	return 1;
}
public OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart)
{
	new Float:ahp, Float:x, Float:y, Float:z;
	GetActorHealth(damaged_actorid, ahp);
	GetActorPos(damaged_actorid, x,y,z);
	if(damaged_actorid == ATrain[0])
	{
		SetActorHealth(damaged_actorid, ahp-amount);
		{
		    SetPlayerCheckpoint(playerid,x,y,z, 3.0);
		    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� ����� ����.(1)");
			SetTimerEx("OnActorDeath", 0, 0, "iiifff", damaged_actorid, playerid, weaponid, Float:x,Float:y,Float:z);
			TextDrawShowForPlayer(playerid, Text:moneyplus);
			GivePlayerMoney(playerid, TRAIN_ZP);
		 	SetTimerEx("DeathMoney", 1000, false, "i", playerid);
		 	PLAYER_TRAIN_ZP[playerid] += TRAIN_ZP;
		}
	}
	if(damaged_actorid == ATrain[1])
	{
		SetActorHealth(damaged_actorid, ahp-amount);
		{
		    SetPlayerCheckpoint(playerid,x,y,z, 3.0);
		    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� ����� ����.(2)");
			SetTimerEx("OnActorDeath", 0, 0, "iiifff", damaged_actorid, playerid, weaponid, Float:x,Float:y,Float:z);
			TextDrawShowForPlayer(playerid, Text:moneyplus);
			GivePlayerMoney(playerid, TRAIN_ZP);
		 	SetTimerEx("DeathMoney", 1000, false, "i", playerid);
		 	PLAYER_TRAIN_ZP[playerid] += TRAIN_ZP;
		}
	}
	if(damaged_actorid == ATrain[2])
	{
		SetActorHealth(damaged_actorid, ahp-amount);
		{
		    SetPlayerCheckpoint(playerid,x,y,z, 3.0);
		    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� ����� ����.(3)");
			SetTimerEx("OnActorDeath", 0, 0, "iiifff", damaged_actorid, playerid, weaponid, Float:x,Float:y,Float:z);
			TextDrawShowForPlayer(playerid, Text:moneyplus);
			GivePlayerMoney(playerid, TRAIN_ZP);
		 	SetTimerEx("DeathMoney", 1000, false, "i", playerid);
		 	PLAYER_TRAIN_ZP[playerid] += TRAIN_ZP;
		}
	}
	if(damaged_actorid == ATrain[3])
	{
		SetActorHealth(damaged_actorid, ahp-amount);
		{
		    SetPlayerCheckpoint(playerid,x,y,z, 3.0);
		    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� ����� ����.(4)");
			SetTimerEx("OnActorDeath", 0, 0, "iiifff", damaged_actorid, playerid, weaponid, Float:x,Float:y,Float:z);
			TextDrawShowForPlayer(playerid, Text:moneyplus);
			GivePlayerMoney(playerid, TRAIN_ZP);
		 	SetTimerEx("DeathMoney", 1000, false, "i", playerid);
		 	PLAYER_TRAIN_ZP[playerid] += TRAIN_ZP;
		}
	}
	if(damaged_actorid == ATrain[4])
	{
		SetActorHealth(damaged_actorid, ahp-amount);
		{
		    SetPlayerCheckpoint(playerid,x,y,z, 3.0);
		    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� ����� ����.(5)");
			SetTimerEx("OnActorDeath", 0, 0, "iiifff", damaged_actorid, playerid, weaponid, Float:x,Float:y,Float:z);
			TextDrawShowForPlayer(playerid, Text:moneyplus);
			GivePlayerMoney(playerid, TRAIN_ZP);
		 	SetTimerEx("DeathMoney", 1000, false, "i", playerid);
		 	PLAYER_TRAIN_ZP[playerid] += TRAIN_ZP;
		}
	}
    PlayerPlaySound(playerid,17802,0,0,0); // ����������� ���� ������������ ���� ��� ����� � ������� ������
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    if(issuerid == INVALID_PLAYER_ID) return 1;
   	new stringda[128],
   		weaponname[24];
	GetWeaponName(weaponid, weaponname, sizeof (weaponname));
 	format(stringda, sizeof(stringda), "{FFFF00}%s | %s: {FFFFFF}-%.0f", GN(issuerid), weaponname, amount);
  	SetPlayerChatBubble(playerid, stringda, 0xFFFFFFFF, 30.0, 1500);
    PlayerPlaySound(issuerid,17802,0,0,0); // ����������� ���� ������������ ���� ��� ����� � ������� ������
    GameTextForPlayer(issuerid, "~r~HIT", 300, 4);
    
    if(HitDefTime[playerid] == 0){
	    HitDefTime[playerid] = 1;
	    SetTimerEx("HitDefT", 30000, false, "i", playerid);}
    
    switch(bodypart)
   	{
            case WEAPON_BODY_PART_HEAD: // ������� � ������
            {
    			new string[50];
				f("~g~HeadShot~n~~w~%s~n~~g~%s", GN(playerid), weaponname);
				GameTextForPlayer(issuerid, string, 3000, 6);
            }
    }
    return 1;
}

forward HitDefT(playerid);
public HitDefT(playerid){
	HitDefTime[playerid] = 0;
	return 1;}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(PlayerTrainZone[playerid] == true)
	{
			                if(!IsPlayerInRangeOfPoint(playerid, 50.0, 1392.6025,-20.8305,1000.9109))
			    			{
			    			    new str[128];
			    			    SpawnPlayer(playerid);
					    	    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� �������� ���� ����������. ���������� ���������.");
					    	    format(str,sizeof(str),"{FFFF00}[����������] {FFFFFF}����� ����������: %d$", PLAYER_TRAIN_ZP[playerid]);
					    	    SCM(playerid, 0xFFFF00, str);
								PlayerTrainZone[playerid] = false;
								ResetPlayerWeapons(playerid);
								DisablePlayerCheckpoint(playerid);
			    			}
	}
	if(a_vehicle[playerid] == 1)
	{
	    a_vehicle[playerid] = 0;
	    DestroyVehicle(vehicle_player_a[playerid]);
	    SCM(playerid, -1, "�� ������, ������ ���������� ����������");
	}
	if(killerid == INVALID_PLAYER_ID) return 1;
	new string[148], Float:health, text[62];
	GetPlayerHealth(killerid, health);
	PlayerKill[killerid] ++;
	if(activepvp[playerid] == 1)
	{
	    pvp_score[killerid] += 1;
	}
	
	new weaponname[34], stringk[124];
	GetWeaponName(GetPlayerWeapon(killerid), weaponname, sizeof(weaponname));
	f("���� ����: %s | ������: %s | � ���� ��������: %.1f hp | ����������: %.1f � | ��� ����: %d ms", GN(killerid), weaponname,health, GetDistanceBetweenPlayers(playerid,killerid),GetPlayerPing(killerid));
	SCM(playerid, COLOR_ERROR, string);
	format(stringk, sizeof(stringk), "�� ����: %s | ������: %s | ����������: %.1f � | ��� ����: %d ms", GN(playerid),weaponname, GetDistanceBetweenPlayers(playerid,killerid),GetPlayerPing(playerid));
	SCM(killerid, COLOR_ERROR, stringk);
	
	PlayerInfo[playerid][pScore] += 1;
	SetPlayerScore(killerid, GetPlayerScore(killerid)+1);
	PlayerInfo[playerid][pDeath] += 1;
	PlayerKill[playerid] = 0;
	GivePlayerMoney(killerid, 500);
	GivePlayerMoney(playerid, -200);
	TextDrawShowForPlayer(playerid, Text:moneyminus);
	TextDrawShowForPlayer(killerid, Text:moneyplus);
 	SetTimerEx("DeathMoney", 1000, false, "ii", killerid,playerid);
 	//SetTimerEx("HideMoneyPlus", 1000, false, "i", killerid);
 	format(text, sizeof(text), "{FFFF00}����: {FFFFFF}%s", GN(killerid));
    SetPlayerChatBubble(playerid, text, 0xFFFFFF, 20.0, 1500);
	//GameTextForPlayer(playerid, "-200", 200, 1);
	//GameTextForPlayer(killerid, "+500", 500, 1);
	SetPlayerHealth(killerid, 100);
	SendDeathMessage(killerid, playerid, reason);
	if(dm_armour == 1) SetPlayerArmour(killerid, 100);
	
	if(PlayerDeathMatch[killerid] > 0)
	{
	    SetPlayerHealth(killerid, 100);
	    if(dm_armour == 1) SetPlayerArmour(killerid, 100);
	    if(PlayerKill[killerid] == 1) GameTextForPlayer(killerid, "~w~WARM~n~~w~UP", 3000, 6);
	    if(PlayerKill[killerid] >= 3) GameTextForPlayer(killerid, "~g~WELL~n~~w~DONE", 3000, 6);
	    if(PlayerKill[killerid] >= 5){
        TextDrawShowForPlayer(killerid, Text:monster[0]);
        TextDrawShowForPlayer(killerid, Text:monster[1]);
        SetTimerEx("HideMonsterKill", 2500, false, "i", killerid);
		PlayerKill[killerid] = 0;
		f("%s - {FF0000}MONSTER", GN(killerid));
		SCMTA(COLOR_ERROR, string);}
	}
	if(TDM == 1)
	{
		    if(gTeam[killerid] == gTeam[playerid])
		    {
		        f("������� ������� ������ %s, �� �������� ��������� �� TDM.", GN(killerid));
				SCMTA(COLOR_LIGHTRED, string);
				GKick(killerid, 1000);
				return 1;
		    }
			if(gTeam[killerid] == TEAM_ATTACK)
			{
			    gTEAM_SCORE_ATTACK ++;
				f("%s [%d] ���� �� ���������� TDM ������ �� defined %s [%d]", GN(killerid), killerid, GN(playerid), playerid);
				SCMTA(COLOR_SALAT, string);
			}
			if(gTeam[killerid] == TEAM_DEFINED)
			{
			    gTEAM_SCORE_DEFINED ++;
				f("%s [%d] ���� �� ���������� TDM ������ �� attack %s [%d]", GN(killerid), killerid, GN(playerid), playerid);
				SCMTA(COLOR_SALAT, string);
			}
	}
	new sStr[144], rang[100];
	if(PlayerInfo[killerid][pScore] == 200) rang = "�������(1)";
	else if(PlayerInfo[killerid][pScore] == 500) rang = "����������(2)";
	else if(PlayerInfo[killerid][pScore]== 1000) rang = "��������(3)";
	else if(PlayerInfo[killerid][pScore] == 2000) rang = "���������(4)";
	else if(PlayerInfo[killerid][pScore] == 2500) rang = "�����������(5)";
	else if(PlayerInfo[killerid][pScore] == 3000) rang = "�������(6)";
	else if(PlayerInfo[killerid][pScore]== 5000) rang = "������(7)";
	else if(PlayerInfo[killerid][pScore] == 10000) rang = "������������(8)";
	else if(PlayerInfo[killerid][pScore]== 20000) rang = "�������(9)";
	else if(PlayerInfo[killerid][pScore] == 40000) rang = "�����������(10)";
    else if(PlayerInfo[killerid][pScore] == 60000) rang = "�������(11)";{
		format(sStr, sizeof(sStr), "�� �������� ���� ������, �����������! ����� ������ {00FF00}%s", rang);
		SCM(killerid, COLOR_YELLOW, sStr);}
	
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("SpawnPlayerTo", 3000, false, "i", playerid);
	SetTimer("UpdateKill", 1000, false);
	return 1;
}

forward UpdateKill();
public UpdateKill()
{
	new ttdm[256];
 	format(ttdm,sizeof(ttdm),"%d:%d", gTEAM_SCORE_DEFINED, gTEAM_SCORE_ATTACK);
	TextDrawSetString(timertdm[3], ttdm);
	return 1;
}

forward HideMonsterKill(killerid);
public HideMonsterKill(killerid)
{
    TextDrawHideForPlayer(killerid, Text:monster[0]);
    TextDrawHideForPlayer(killerid, Text:monster[1]);
	return 1;
}

forward DeathMoney(killerid, playerid);
public DeathMoney(killerid, playerid)
{
    TextDrawHideForPlayer(killerid, Text:moneyplus);
    TextDrawHideForPlayer(playerid, Text:moneyminus);
    TextDrawHideForPlayer(playerid, Text:moneyplus);
	return 1;
}

/*forward HideMoneyPlus(killerid);
public HideMoneyPlus(killerid)
{
	TextDrawHideForPlayer(killerid, Text:moneyplus);
	return 1;
}

forward HideMoneyMinus(playerid);
public HideMoneyMinus(playerid)
{
    TextDrawHideForPlayer(playerid, Text:moneyminus);
	return 1;
}*/


forward Float:GetDistanceBetweenPlayers(p1,p2);
public Float:GetDistanceBetweenPlayers(p1,p2)
{
        new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
        if(!IsPlayerConnected(p1) || !IsPlayerConnected(p2))
        {
                return -1.00;
        }
        GetPlayerPos(p1,x1,y1,z1);
        GetPlayerPos(p2,x2,y2,z2);
        return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

forward SpawnPlayerTo(playerid);
public SpawnPlayerTo(playerid)
{
	SpawnPlayer(playerid);
	TogglePlayerControllable(playerid, 1);
	return 1;
}

public RestartTimer(playerid)
{
	SendRconCommand("login saayYDSsnsdcaunuiBDYSdubdsnj12NBd"); // rcon ������, ����� login [������]
 	SendRconCommand("gmx");
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if(vehicleid == vehicle[killerid])
	{
	    SCM(killerid, -1, "���� ������ ���� ����������, �� ����� ������ ������� �� ����� ���� ����������");
	    CalledVehicle[killerid] = 0;
	    DestroyVehicle(vehicle[killerid]);
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
    	if(PlayerInfo[playerid][pEntered] == 1){
			new playername[MAX_PLAYER_NAME];
			GetPlayerName(playerid, playername, sizeof(playername));
			new string[250], rang[100];
		    if(GetPlayerScore(playerid) < 200) rang = "��� ������";
			else if(GetPlayerScore(playerid) >= 200 && GetPlayerScore(playerid) < 500 ) rang = "�������-1";
			else if(GetPlayerScore(playerid) >= 500 && GetPlayerScore(playerid) < 1000 ) rang = "����������-2";
			else if(GetPlayerScore(playerid) >= 1000 && GetPlayerScore(playerid) < 2000 ) rang = "��������-3";
			else if(GetPlayerScore(playerid) >= 2000 && GetPlayerScore(playerid) < 2500 ) rang = "���������-4";
			else if(GetPlayerScore(playerid) >= 2500 && GetPlayerScore(playerid) < 3000 ) rang = "�����������-5";
			else if(GetPlayerScore(playerid) >= 3000 && GetPlayerScore(playerid) < 5000 ) rang = "�������-6";
			else if(GetPlayerScore(playerid) >= 5000 && GetPlayerScore(playerid) < 10000 ) rang = "������-7";
			else if(GetPlayerScore(playerid) >= 10000 && GetPlayerScore(playerid) < 20000 ) rang = "������������-8";
			else if(GetPlayerScore(playerid) >= 20000 && GetPlayerScore(playerid) < 40000 ) rang = "�������-9";
			else if(GetPlayerScore(playerid) >= 40000 && GetPlayerScore(playerid) < 60000 ) rang = "�����������-10";
		    else if(GetPlayerScore(playerid) >= 60000) rang = "�������-11";
			if(PlayerInfo[playerid][pAdmin] == 0)
			{
			    format(string, sizeof(string), "{FFFF00}[%s] {FFFFFF}%s[%d]: %s", rang, playername, playerid, text);
			    SCMTA(-1, string);
			    return 0;
			}
			if(PlayerInfo[playerid][pAdmin] > 0)
			{
		 		format(string, sizeof(string), "{00FF00}[A-%d]{FFFF00}[%s] {FFFFFF}%s[%d]: %s", PlayerInfo[playerid][pAdmin], rang, playername, playerid, text);
		 		SCMTA(-1, string);
		 		return 0;
			}}
			//ProxDetector(10.0, playerid, string, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_GREY, COLOR_GREY);
		else return 1;
		return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(status_lock[vehicleid] == 1)
	{
		TogglePlayerControllable(playerid, 0);
		TogglePlayerControllable(playerid, 1);
		SetTimerEx("TogglePlayerControll", 1000, 0, "i", playerid);
		TogglePlayerControllable(playerid, 0);
		SCM(playerid, COLOR_YELLOW,"[CARLOCK] {FFFFFF}���������� ������!");
	}
	if(vehicleid == 1){
		TogglePlayerControllable(playerid, 0);
		TogglePlayerControllable(playerid, 1);
		SCM(playerid, COLOR_ERROR, "������ ������ ���� ���������");
		return 1;}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(GPS[playerid] == 1)
	{
		DisablePlayerRaceCheckpoint(playerid);
		SCM(playerid, -1, "�� �������� ����� ����������");
		GPS[playerid] = 0;
		return 1;
	}
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(pickupid == ammo[0])
	{
	    ammo_playerid[playerid] = 0;
	    ShowPlayerDialog(playerid, D_AMMO, DLIST, "���������", "{FFFFFF}�� ����� ������ ���������� ��������� �������?\n�������� ������� ������.", "��", "���");

	}
	if(pickupid == ammo[1])
	{
	    ammo_playerid[playerid] = 1;
	    ShowPlayerDialog(playerid, D_AMMO, DLIST, "���������", "{FFFFFF}�� ����� ������ ���������� ��������� �������?\n�������� ������� ������.", "��", "���");

	}
	if(pickupid == ammo[2])
	{
	    ammo_playerid[playerid] = 2;
	    ShowPlayerDialog(playerid, D_AMMO, DLIST, "���������", "{FFFFFF}�� ����� ������ ���������� ��������� �������?\n�������� ������� ������.", "��", "���");

	}
	if(pickupid == ammo[3])
	{
	    ammo_playerid[playerid] = 3;
	    ShowPlayerDialog(playerid, D_AMMO, DLIST, "���������", "{FFFFFF}�� ����� ������ ���������� ��������� �������?\n�������� ������� ������.", "��", "���");

	}
	if(pickupid == ammo[4])
	{
	    ammo_playerid[playerid] = 4;
	    ShowPlayerDialog(playerid, D_AMMO, DLIST, "���������", "{FFFFFF}�� ����� ������ ���������� ��������� �������?\n�������� ������� ������.", "��", "���");

	}
	if(pickupid == ammo[5])
	{
	    ammo_playerid[playerid] = 5;
	    ShowPlayerDialog(playerid, D_AMMO, DLIST, "���������", "{FFFFFF}�� ����� ������ ���������� ��������� �������?\n�������� ������� ������.", "��", "���");

	}
	if(pickupid == ammo[6])
	{
	    ammo_playerid[playerid] = 6;
	    ShowPlayerDialog(playerid, D_AMMO, DLIST, "���������", "{FFFFFF}�� ����� ������ ���������� ��������� �������?\n�������� ������� ������.", "��", "���");
	}
	if(pickupid == ammoexit)
	{
		if(ammo_playerid[playerid] == 0)
		{
		    SetPlayerPos(playerid, ammopos[0][0], ammopos[0][1]-3, ammopos[0][2]);
		    SetPlayerInterior(playerid, 0);
		    return 1;
		}
		if(ammo_playerid[playerid] == 1)
		{
		    SetPlayerPos(playerid, ammopos[1][0], ammopos[1][1]+3, ammopos[1][2]);
		    SetPlayerInterior(playerid, 0);
		    return 1;
		}
		if(ammo_playerid[playerid] == 2)
		{
		    SetPlayerPos(playerid, ammopos[2][0], ammopos[2][1]+3, ammopos[2][2]);
		    SetPlayerInterior(playerid, 0);
		    return 1;
		}
		if(ammo_playerid[playerid] == 3)
		{
		    SetPlayerPos(playerid, ammopos[3][0], ammopos[3][1]+3, ammopos[3][2]);
		    SetPlayerInterior(playerid, 0);
		    return 1;
		}
		if(ammo_playerid[playerid] == 4)
		{
		    SetPlayerPos(playerid, ammopos[4][0], ammopos[4][1]+3, ammopos[4][2]);
		    SetPlayerInterior(playerid, 0);
		    return 1;
		}
		if(ammo_playerid[playerid] == 5)
		{
		    SetPlayerPos(playerid, ammopos[5][0], ammopos[5][1]+3, ammopos[5][2]);
		    SetPlayerInterior(playerid, 0);
		    return 1;
		}
		if(ammo_playerid[playerid] == 6)
		{
		    SetPlayerPos(playerid, ammopos[6][0]+3, ammopos[6][1]-2, ammopos[6][2]);
		    SetPlayerInterior(playerid, 0);
		    return 1;
		}
	}
	if(pickupid == ammobuy)
	{
		new str[2048];
		format(str, sizeof(str), "{FFFFFF}����� ������ ������ � ��������, ������� ������� - /buyweapon [id ������] [���-�� ������]\n\n�������� � ���������� [id 23] - %d$ �� 1 ��.\nDesert Eagle [id 24] - %d$ �� 1 ��.\nShotgun [id 25] - %d$ �� 1 ��.\nM4 [id 31] - %d$ �� 1 ��.\nRifle [id 33] - %d$ �� 1 ��\nSniper Rifle [id 34] - %d$ �� 1 ��.", PRICE_SD, PRICE_DEAGLE, PRICE_SHOTGUN, PRICE_M4, PRICE_RIFLE, PRICE_SNIPER);
		ShowPlayerDialog(playerid, D_AMMO+1, DBOX, "���������", str, "�������","");

	}
	if(pickupid == healup[0] || pickupid == healup[1])
	{
	    new str[] = "{FFFFFF}����� �� ������ ��������� ���� ����� �����(���������� ��������), ����� ������� ��� - ����������� ������� /buyheal [���-��]";
		SPD(playerid, D_HEALUP, DBOX, "��������", str, "�������", "");
	}
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

forward PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z);
public PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		tempposx = (oldposx -x);
		tempposy = (oldposy -y);
		tempposz = (oldposz -z);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) &&
		((tempposz < radi) && (tempposz > -radi)))
		{
			return 1;
		}
	}
	return 0;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_YES)
	{
	    ShowMenu(playerid);
	}
    if( (newkeys & KEY_FIRE) || ( (newkeys & KEY_HANDBRAKE) && (oldkeys & KEY_HANDBRAKE) && (newkeys & KEY_SECONDARY_ATTACK) ) )
	{
	    //if(PlayerInfo[playerid][pAdmin] > 0) return 1;
		if(PlayerToPoint(50.0,playerid,308.3303,-140.5986,999.6016))
		{
			ShowPlayerDialog(playerid, 47, DIALOG_STYLE_MSGBOX, "���������", "{FFFFFF}� ���� ����� ��������� �������� ���� �������.", "�������", "");
			ApplyAnimation(playerid,"MISC","plyr_shkhead",4.0,0,0,0,0,0,1);
			TogglePlayerControllable(playerid, 0);
			SetTimerEx("TogglePlayerControll", 5000, 0, "i", playerid);
		}
		ANTI_DM[playerid] = 1;
	}
	if (newkeys == 16)//�������� �� ������
	{
	    if (IsAtCandySprunk(playerid))//��������
	    {
			new Float:hp;
			GetPlayerHealth(playerid, hp);
			if(hp > 100){
				SendClientMessage(playerid, COLOR_ERROR, "�� � �������");
				SetPlayerHealth(playerid, 100);
				return 1;}
			
			GameTextForPlayer(playerid, "+35", 3000, 1);
			SetPlayerHealth(playerid, hp+35);
   //SetPlayerAnimation(playerid, 1138);
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_SPRUNK);
	    }
	}
	return 1;
}

forward TogglePlayerControll(playerid);
public TogglePlayerControll(playerid)
{
	TogglePlayerControllable(playerid, 1);
	if(ANTI_DM[playerid] == 1)
	{
        ANTI_DM[playerid] = 0;
        SPD(playerid, 2456, DBOX, "�����������", "{FFFFFF}���� ������������", "�������", "");
	}
	return 1;
}
public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
    if(GetPVarInt(playerid, "Kick") != 0) GKick(playerid);
	return 1;
}
public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
   if(dialogid == D_TPANEL)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(TDM_VEH_ALL == true) return SCM(playerid, COLOR_ERROR, "������� ������� ���� �������� ���������");
                    TDM_VEH_ALL = true;
                    SCM(playerid, 0xFFFF00, "{FFFF00}[������] {FFFFFF}��������� ��� ���� ������");
					SCMTA(COLOR_LIGHTRED, "[������] ������ ��������� ��� ���� ������.");
                    // attack
					TDM_VEH[0] = CreateVehicle(TDM_VEHICLE,2792.8003,-1876.0487,9.8370,1.1602,0,0,0);
					TDM_VEH[1] = CreateVehicle(TDM_VEHICLE,2787.8489,-1875.7289,9.8200,0.1531,0,0,0);
					TDM_VEH[2] = CreateVehicle(TDM_VEHICLE,2782.6597,-1875.9143,9.7987,1.9347,0,0,0);
					TDM_VEH[3] = CreateVehicle(TDM_VEHICLE,2777.9092,-1875.5372,9.7797,0.7584,0,0,0);
					// def
					TDM_VEH[4] = CreateVehicle(TDM_VEHICLE,2676.5632,-1672.9352,9.3872,177.7219,0,0,0);
					TDM_VEH[5] = CreateVehicle(TDM_VEHICLE,2681.5435,-1672.0488,9.4077,181.2407,0,0,0);
					TDM_VEH[6] = CreateVehicle(TDM_VEHICLE,2686.8206,-1672.2860,9.4436,182.8534,0,0,0);
					TDM_VEH[7] = CreateVehicle(TDM_VEHICLE,2691.7244,-1673.0134,9.4459,180.5957,0,0,0);
                }
                case 1:
                {
                    SCM(playerid, 0xFFFF00, "{FFFF00}[������] {FFFFFF}���� ��������� ������");
                    TDM_VEH_ALL = false;
					SCMTA(COLOR_LIGHTRED, "[������] ������ ��������� � ���� ������.");
                    DestroyVehicle(TDM_VEH[0]);
                    DestroyVehicle(TDM_VEH[1]);
                    DestroyVehicle(TDM_VEH[2]);
                    DestroyVehicle(TDM_VEH[3]);
                    DestroyVehicle(TDM_VEH[4]);
                    DestroyVehicle(TDM_VEH[5]);
                    DestroyVehicle(TDM_VEH[6]);
                    DestroyVehicle(TDM_VEH[7]);
                }
                case 2:
                {
                    if(TDM_VEH_ALL == true) return SCM(playerid, COLOR_ERROR, "������� ������� ���� �������� ���������");
                    TDM_VEH_ALL = true;
                    SCM(playerid, 0xFFFF00, "{FFFF00}[������] {FFFFFF}��������� ��� ATTACK ������");
					SCMTA(COLOR_LIGHTRED, "[������] ��������� ��� ATTACK ������");
					TDM_VEH[0] = CreateVehicle(TDM_VEHICLE,2792.8003,-1876.0487,9.8370,1.1602,0,0,0);
					TDM_VEH[1] = CreateVehicle(TDM_VEHICLE,2787.8489,-1875.7289,9.8200,0.1531,0,0,0);
					TDM_VEH[2] = CreateVehicle(TDM_VEHICLE,2782.6597,-1875.9143,9.7987,1.9347,0,0,0);
					TDM_VEH[3] = CreateVehicle(TDM_VEHICLE,2777.9092,-1875.5372,9.7797,0.7584,0,0,0);
                }
                case 3:
                {
                    if(TDM_VEH_ALL == true) return SCM(playerid, COLOR_ERROR, "������� ������� ���� �������� ���������");
                    SCM(playerid, 0xFFFF00, "{FFFF00}[������] {FFFFFF}��������� ��� DEFINE ������");
                    TDM_VEH_ALL = true;
					SCMTA(COLOR_LIGHTRED, "[������] ��������� ��� DEFINE ������");
					TDM_VEH[4] = CreateVehicle(TDM_VEHICLE,2676.5632,-1672.9352,9.3872,177.7219,0,0,0);
					TDM_VEH[5] = CreateVehicle(TDM_VEHICLE,2681.5435,-1672.0488,9.4077,181.2407,0,0,0);
					TDM_VEH[6] = CreateVehicle(TDM_VEHICLE,2686.8206,-1672.2860,9.4436,182.8534,0,0,0);
					TDM_VEH[7] = CreateVehicle(TDM_VEHICLE,2691.7244,-1673.0134,9.4459,180.5957,0,0,0);
                }
            }
        }
        else return 1;
    }
   if(dialogid == D_TUNE)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                SPD(playerid, D_TUNE+1, DLIST, "������", "Nitro [x2]\nNitro [x5]\nNitro [x10]", "�������", "�����");
	            }
				case 1:
				{
					if(IsPlayerConnected(playerid))
					{
						new string[144];
						if(!IsPlayerInAnyVehicle(playerid)) return SCM(playerid, COLOR_ERROR, "�� �� � ������!");
						format(string,sizeof(string),"������� 2 ����� ����� �������\n������: {FFFFFF}1,1!");
						SPD(playerid,D_TUNE+2,DIALOG_STYLE_INPUT,"����",string,"�������","������");
					}
				}
	        }
	    }
	    else return 1;
	}
   if(dialogid == D_TUNE+2) return SCM(playerid, COLOR_ERROR, "������ �������� ������!");
   if(dialogid == D_TUNE+1)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    PlayerInfo[playerid][pNitro] = 1009;
                    AddVehicleComponent(vehicle[playerid], 1009);
                    SCM(playerid, -1, "�� ���������� ������ ����� (Nitro [x2])");
                }
                case 1:
                {
                    PlayerInfo[playerid][pNitro] = 1008;
                    AddVehicleComponent(vehicle[playerid], 1008);
                    SCM(playerid, -1, "�� ���������� ������ ����� (Nitro [x5])");
                }
                case 2:
                {
                    PlayerInfo[playerid][pNitro] = 1010;
                    AddVehicleComponent(vehicle[playerid], 1010);
                    SCM(playerid, -1, "�� ���������� ������ ����� (Nitro [x10])");
                }
            }
		}
		else return SPD(playerid, D_TUNE, DLIST, "������", "1. ������ �����", "�������", "������");
    }
   if(dialogid == D_INV)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
				{
				    if(PlayerInfo[playerid][pIPt0] == 0) return SCM(playerid, COLOR_ERROR, "���� ����");
					PlayerInfo[playerid][pIPt0] -= 100;
					GivePlayerWeapon(playerid,24,100);
				    new str[144];
					igun[0][playerid] = PlayerInfo[playerid][pIGun0];
					igun[1][playerid] = PlayerInfo[playerid][pIGun1];
					igun[2][playerid] = PlayerInfo[playerid][pIGun2];
					igun[3][playerid] = PlayerInfo[playerid][pIGun3];

					ipt[0][playerid] = PlayerInfo[playerid][pIPt0];
					ipt[1][playerid] = PlayerInfo[playerid][pIPt1];
					ipt[2][playerid] = PlayerInfo[playerid][pIPt2];
					ipt[3][playerid] = PlayerInfo[playerid][pIPt3];
					
					if(ipt[0][playerid] == 0) igun[0][playerid] = 0;
					if(ipt[1][playerid] == 0) igun[1][playerid] = 0;
					if(ipt[2][playerid] == 0) igun[2][playerid] = 0;
					if(ipt[3][playerid] == 0) igun[3][playerid] = 0;

					format(str, sizeof(str), "%d [%d]\n%d [%d]\n%d [%d]\n%d [%d]", igun[0][playerid], ipt[0][playerid],igun[1][playerid], ipt[1][playerid],igun[2][playerid], ipt[2][playerid],igun[3][playerid], ipt[3][playerid]);
					SPD(playerid, D_INV, DLIST, "���������", str, "�����", "������");
				}
	            case 1:
				{
				    if(PlayerInfo[playerid][pIPt1] == 0) return SCM(playerid, COLOR_ERROR, "���� ����");
					PlayerInfo[playerid][pIPt1] -= 100;
					GivePlayerWeapon(playerid,25,100);
				    new str[144];
					igun[0][playerid] = PlayerInfo[playerid][pIGun0];
					igun[1][playerid] = PlayerInfo[playerid][pIGun1];
					igun[2][playerid] = PlayerInfo[playerid][pIGun2];
					igun[3][playerid] = PlayerInfo[playerid][pIGun3];

					ipt[0][playerid] = PlayerInfo[playerid][pIPt0];
					ipt[1][playerid] = PlayerInfo[playerid][pIPt1];
					ipt[2][playerid] = PlayerInfo[playerid][pIPt2];
					ipt[3][playerid] = PlayerInfo[playerid][pIPt3];

					if(ipt[0][playerid] == 0) igun[0][playerid] = 0;
					if(ipt[1][playerid] == 0) igun[1][playerid] = 0;
					if(ipt[2][playerid] == 0) igun[2][playerid] = 0;
					if(ipt[3][playerid] == 0) igun[3][playerid] = 0;

					format(str, sizeof(str), "%d [%d]\n%d [%d]\n%d [%d]\n%d [%d]", igun[0][playerid], ipt[0][playerid],igun[1][playerid], ipt[1][playerid],igun[2][playerid], ipt[2][playerid],igun[3][playerid], ipt[3][playerid]);
					SPD(playerid, D_INV, DLIST, "���������", str, "�����", "������");
				}
	            case 2:
				{
				    if(PlayerInfo[playerid][pIPt2] == 0) return SCM(playerid, COLOR_ERROR, "���� ����");
					PlayerInfo[playerid][pIPt2] -= 100;
					GivePlayerWeapon(playerid,31,100);
				    new str[144];
					igun[0][playerid] = PlayerInfo[playerid][pIGun0];
					igun[1][playerid] = PlayerInfo[playerid][pIGun1];
					igun[2][playerid] = PlayerInfo[playerid][pIGun2];
					igun[3][playerid] = PlayerInfo[playerid][pIGun3];

					ipt[0][playerid] = PlayerInfo[playerid][pIPt0];
					ipt[1][playerid] = PlayerInfo[playerid][pIPt1];
					ipt[2][playerid] = PlayerInfo[playerid][pIPt2];
					ipt[3][playerid] = PlayerInfo[playerid][pIPt3];

					if(ipt[0][playerid] == 0) igun[0][playerid] = 0;
					if(ipt[1][playerid] == 0) igun[1][playerid] = 0;
					if(ipt[2][playerid] == 0) igun[2][playerid] = 0;
					if(ipt[3][playerid] == 0) igun[3][playerid] = 0;

					format(str, sizeof(str), "%d [%d]\n%d [%d]\n%d [%d]\n%d [%d]", igun[0][playerid], ipt[0][playerid],igun[1][playerid], ipt[1][playerid],igun[2][playerid], ipt[2][playerid],igun[3][playerid], ipt[3][playerid]);
					SPD(playerid, D_INV, DLIST, "���������", str, "�����", "������");
				}
	            case 3:
				{
				    if(PlayerInfo[playerid][pIPt3] == 0) return SCM(playerid, COLOR_ERROR, "���� ����");
					PlayerInfo[playerid][pIPt3] -= 100;
					GivePlayerWeapon(playerid,33,100);
				    new str[144];
					igun[0][playerid] = PlayerInfo[playerid][pIGun0];
					igun[1][playerid] = PlayerInfo[playerid][pIGun1];
					igun[2][playerid] = PlayerInfo[playerid][pIGun2];
					igun[3][playerid] = PlayerInfo[playerid][pIGun3];

					ipt[0][playerid] = PlayerInfo[playerid][pIPt0];
					ipt[1][playerid] = PlayerInfo[playerid][pIPt1];
					ipt[2][playerid] = PlayerInfo[playerid][pIPt2];
					ipt[3][playerid] = PlayerInfo[playerid][pIPt3];

					if(ipt[0][playerid] == 0) igun[0][playerid] = 0;
					if(ipt[1][playerid] == 0) igun[1][playerid] = 0;
					if(ipt[2][playerid] == 0) igun[2][playerid] = 0;
					if(ipt[3][playerid] == 0) igun[3][playerid] = 0;

					format(str, sizeof(str), "%d [%d]\n%d [%d]\n%d [%d]\n%d [%d]", igun[0][playerid], ipt[0][playerid],igun[1][playerid], ipt[1][playerid],igun[2][playerid], ipt[2][playerid],igun[3][playerid], ipt[3][playerid]);
					SPD(playerid, D_INV, DLIST, "���������", str, "�����", "������");
				}
	        }
	    }
	    else return 1;
	}
   if(dialogid == D_GPS)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					ShowPlayerDialog(playerid, D_GPS+1, DLIST, "�����", "���������[1]\n���������[2]\n���������[3]\n���������[4]\n���������[5]\n���������[6]\n���������[7]", "�����", "�����");
	            }
	            case 1:
	            {
	                PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					ShowPlayerDialog(playerid, D_GPS+2, DLIST, "�����", "�������� � �����[1]\n�������� � ������[2]", "�����", "�����");
	            }
	        }
	    }
	    else return 1;
	}
   if(dialogid == D_GPS+2)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
				{
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, bolka[0][0], bolka[0][1], bolka[0][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
				}
	            case 1:
				{
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, bolka[1][0], bolka[1][1], bolka[1][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
				}
	        }
	    }
	    else return 1;
	}
   if(dialogid == D_GPS+1)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, ammopos[0][0], ammopos[0][1], ammopos[0][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
                }
                case 1:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, ammopos[1][0], ammopos[1][1], ammopos[1][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
                }
                case 2:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, ammopos[2][0], ammopos[2][1], ammopos[2][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
                }
                case 3:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, ammopos[3][0], ammopos[3][1], ammopos[3][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
                }
                case 4:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, ammopos[4][0], ammopos[4][1], ammopos[4][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
                }
                case 5:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, ammopos[5][0], ammopos[5][1], ammopos[5][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
                }
                case 6:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
                    SetPlayerRaceCheckpoint(playerid, 1, ammopos[6][0], ammopos[6][1], ammopos[6][2], 0.0, 0.0, 0.0, 3);
                    SCM(playerid, -1, "����� �������� �� ����� ������� ������");
                    GPS[playerid] = 1;
                }
            }
        }
        else return 1;
    }
   if(dialogid == D_AMMO)
	{
	    if(response)
	    {
	        SetPlayerPos(playerid, 314.820983,-141.431991,999.601562);
	        SetPlayerInterior(playerid, 7);
			SCM(playerid, COLOR_GREY, "�� �������� ��������� �������, ����� ������� ������ ��� ������� - ��������� � ������");
			GameTextForPlayer(playerid, "~w~/buyweapon [id] [pt]", 3000, 1);
	    }
	    else return 1;
	}
   if(dialogid == D_PVP)
	{
	    if(response)
	    {
	        activepvar = 1;
			PlayerDeathMatch[playerid] = 0;
			PlayerDeathMatch[gopvpId[playerid]] = 0;
			pvpv ++;
			new pvpvv = pvpv;
			activepvp[playerid] = 1;
			gopvp[playerid] = 0;
			gopvp[gopvpId[playerid]] = 0;
			activepvp[gopvpId[playerid]] = 1;
			spawnpvp[playerid] = GetPlayerVirtualWorld(playerid);
			spawnpvp[gopvpId[playerid]] = GetPlayerVirtualWorld(gopvpId[playerid]);
			SetPlayerPos(gopvpId[playerid],-349.4037,2214.2800,42.4844);
			SetPlayerVirtualWorld(gopvpId[playerid], pvpvv);
			SetPlayerPos(playerid, -445.2425,2226.5425,42.4297);
			SetPlayerVirtualWorld(playerid, pvpvv);
			GivePlayerWeapon(gopvpId[playerid], gGun1[gopvpId[playerid]], 1500);
			GivePlayerWeapon(gopvpId[playerid], gGun2[gopvpId[playerid]], 1500);
			GivePlayerWeapon(playerid, gGun1[playerid], 1500);
			GivePlayerWeapon(playerid, gGun2[playerid], 1500);
			SetPlayerHealth(playerid, 100);
			if(dm_armour == 1) SetPlayerArmour(playerid, 100);
			SetPlayerHealth(gopvpId[playerid], 100);
			if(dm_armour == 1) SetPlayerArmour(gopvpId[playerid], 100);
			SCM(playerid, COLOR_YELLOW, "PVP ��������, ����� �������� ��� ������� {FFFFFF}/exitpvp");
			SCM(gopvpId[playerid], COLOR_YELLOW,"PVP ��������, ����� �������� ��� ������� {FFFFFF}/exitpvp");
			SCMTA(COLOR_SALAT, "����� PVP ����� ����� ������ ����� ����� 5 �����");
			new string[124];
			f("�� PVP ����� �������� PVP ����� �������� %s � %s", GN(playerid), GN(gopvpId[playerid]));
			SCMTA(COLOR_SALAT, string);
            SetTimerEx("TimeOutPvp", 60000*5, 0, "i", playerid);
	    }
	    else return 1;
	}
   if(dialogid == selectgun)
	{
					if(PlayerDeathMatch[playerid] == 1)
					{
					 	switch(random(8))
						{
						    case 0: SetPlayerPos(playerid, -445.4210,2223.1973,42.4297);
						    case 1: SetPlayerPos(playerid, -439.5626,2250.6855,42.4297);
						    case 2: SetPlayerPos(playerid, -411.5861,2264.4600,42.3509);
						    case 3: SetPlayerPos(playerid, -410.4398,2213.3442,42.4297);
						    case 4: SetPlayerPos(playerid, -392.0173,2195.2095,42.4164);
						    case 5: SetPlayerPos(playerid, -350.7846,2209.3391,42.4844);
						    case 6: SetPlayerPos(playerid, -350.9970,2246.5398,42.4844);
						    case 7: SetPlayerPos(playerid, -372.3033,2269.7151,42.0940);
						}
					}
					if(PlayerDeathMatch[playerid] == 2)
					{
					 	switch(random(8))
						{
						    case 0: SetPlayerPos(playerid, 2605.7703,2707.6506,36.1997);
						    case 1: SetPlayerPos(playerid, 2631.9253,2720.9282,36.1601);
						    case 2: SetPlayerPos(playerid, 2631.6123,2717.2773,33.9783);
						    case 3: SetPlayerPos(playerid, 2615.8176,2706.0972,25.8222);
						    case 4: SetPlayerPos(playerid, 2605.1643,2731.4534,23.8222);
						    case 5: SetPlayerPos(playerid, 2628.9973,2752.6213,23.8222);
						    case 6: SetPlayerPos(playerid, 2641.7649,2781.9226,23.8222);
						    case 7: SetPlayerPos(playerid, 2595.3110,2775.3281,23.8222);
						}
					}
					if(PlayerDeathMatch[playerid] == 3)
					{
					 	switch(random(12))
						{
						    case 0: SetPlayerPos(playerid, 1609.2114,2324.8989,10.8203);
						    case 1: SetPlayerPos(playerid, 1649.6317,2371.6128,10.8203);
						    case 2: SetPlayerPos(playerid, 1674.8348,2398.4629,10.8203);
						    case 3: SetPlayerPos(playerid, 1695.1720,2354.2163,10.8203);
						    case 4: SetPlayerPos(playerid, 1676.7113,2302.2229,10.8203);
						    case 5: SetPlayerPos(playerid, 1702.4471,2292.4709,10.8203);
						    case 6: SetPlayerPos(playerid, 1697.0825,2334.7505,10.8203);
						    case 7: SetPlayerPos(playerid, 1654.9846,2323.5359,21.1676);
						    case 8: SetPlayerPos(playerid, 1665.4963,2357.3474,21.3845);
						    case 9: SetPlayerPos(playerid, 1670.9081,2302.8088,21.3845);
						    case 10: SetPlayerPos(playerid, 1654.7216,2380.1387,21.3845);
						    case 11: SetPlayerPos(playerid, 1670.8424,2388.4595,21.3845);
						}
					}
					GivePlayerWeapon(playerid, gGun1[playerid], 1500);
					GivePlayerWeapon(playerid, gGun2[playerid], 1500);
					SetPlayerHealth(playerid, 100);
					if(dm_armour == 1) SetPlayerArmour(playerid, 100);
	}
   if(dialogid == D_PACK+1)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
				case 0:
	            {
					gGun2[playerid] = 23;
					SCM(playerid, COLOR_GREY, "������ ���� - �������� � ����������");
	            }
	            case 1:
	            {
					gGun2[playerid] = 24;
					SCM(playerid, COLOR_GREY, "������ ���� - Desert Eagle");
	            }
	            case 2:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 1)
					{
						SCM(playerid, COLOR_ERROR, "��������� 1 �������");
						SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
                        return 1;
					}
					gGun2[playerid] = 25;
					SCM(playerid, COLOR_GREY, "������ ���� - Shotgun");
				}
	            case 3:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 2)
					{
						SCM(playerid, COLOR_ERROR, "��������� 2 �������");
						SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
                        return 1;
					}
					gGun2[playerid] = 31;
					SCM(playerid, COLOR_GREY, "������ ���� - M4");
	            }
	            case 4:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 4)
					{
						SCM(playerid, COLOR_ERROR, "��������� 4 �������");
						SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
                        return 1;
					}
					gGun2[playerid] = 33;
					SCM(playerid, COLOR_GREY, "������ ���� - Country Rifle");
	            }
	            case 5:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 7)
					{
						SCM(playerid, COLOR_ERROR, "��������� 7 �������");
						SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
						return 1;
					}
					gGun2[playerid] = 34;
					SCM(playerid, COLOR_GREY, "������ ���� - Sniper Rifle");
	            }
			}
		}
		else return SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 1", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "������");
	}
   if(dialogid == D_PACK)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
					gGun1[playerid] = 23;
					SCM(playerid, COLOR_GREY, "������ ���� - �������� � ����������");
					SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
	            }
	            case 1:
	            {
					gGun1[playerid] = 24;
					SCM(playerid, COLOR_GREY, "������ ���� - Desert Eagle");
					SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
	            }
	            case 2:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 1)
					{
						SCM(playerid, COLOR_ERROR, "��������� 1 �������");
						SPD(playerid, D_PACK, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
                        return 1;
					}
					gGun1[playerid] = 25;
					SCM(playerid, COLOR_GREY, "������ ���� - Shotgun");
					SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
				}
	            case 3:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 2)
					{
						SCM(playerid, COLOR_ERROR, "��������� 2 �������");
						SPD(playerid, D_PACK, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
						return 1;
					}
					gGun1[playerid] = 31;
					SCM(playerid, COLOR_GREY, "������ ���� - M4");
					SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
	            }
	            case 4:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 4)
					{
						SCM(playerid, COLOR_ERROR, "��������� 4 �������");
						SPD(playerid, D_PACK, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
                        return 1;
					}
					gGun1[playerid] = 33;
					SCM(playerid, COLOR_GREY, "������ ���� - Country Rifle");
					SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
	            }
	            case 5:
	            {
	            	if(PlayerInfo[playerid][pLevel] < 7)
					{
						SCM(playerid, COLOR_ERROR, "��������� 7 �������");
						SPD(playerid, D_PACK, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
                        return 1;
					}
					gGun1[playerid] = 34;
					SCM(playerid, COLOR_GREY, "������ ���� - Sniper Rifle");
					SPD(playerid, D_PACK+1, DLIST, "����� ������ - ���� 2", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "�����");
	            }
	        }
	    }
	    else return 1;
	}
   if(dialogid == D_TDM)
	{
	    if(response)
	    {
			SPD(playerid, D_TDM+1, DLIST, "����� �����", "������� ���-�������\n����������� ��������", "�������", "������");
	    }
	    else return 1;
	}
   if(dialogid == D_TDM+1)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0:
			    {
			        SetPlayerCameraPos(playerid,2638.7080,-1871.8036,75.0293);
			        SetPlayerCameraLookAt(playerid,2714.0388,-1793.4640,41.7010);
			        SPD(playerid, D_TDM+2, DBOX, "�������������", "�� ������������� ������ ������� ����� '������� ���-�������'?", "��", "���");
			    }
				case 1:
				{
			        SetPlayerCameraPos(playerid,465.5332,2414.0815,64.2065);
			        SetPlayerCameraLookAt(playerid,404.7923,2483.1658,16.4844);
			        SPD(playerid, D_TDM+3, DBOX, "�������������", "�� ������������� ������ ������� ����� '����������� ��������'?", "��", "���");
				}
			}
	    }
	    else return 1;
	}
   if(dialogid == D_TDM+3)
    {
        if(response)
        {
	        for(new i=0;i<MAX_PLAYERS;i++)
			{
		        if(gTeam[i] == 1)
		        {
		            SetPlayerPos(i, 417.8917,2543.8604,16.3947);
		            SetPlayerWorldBounds(i,449.4684, 322.6075, 2566.9373, 2407.7988);
		            SpawnPlayer(playerid);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 100);
					GivePlayerWeapon(i, gGun1[i], 1000);
					GivePlayerWeapon(i, gGun2[i], 1000);
					SCM(i, COLOR_KOJ, "��� ��� ����� ��� ����� ������. ����� ��� ��������, ����������� ����� ������ ������ � ����� ������ ��� �������� (/pack)");
		        }
		        if(gTeam[i] == 2)
		        {
		            SetPlayerPos(i, 351.2186,2444.9973,16.9636);
		            SetPlayerWorldBounds(i,449.4684, 322.6075, 2566.9373, 2407.7988);
		            SpawnPlayer(playerid);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 100);
					GivePlayerWeapon(i, gGun1[i], 1000);
					GivePlayerWeapon(i, gGun2[i], 1000);
					SCM(i, COLOR_KOJ, "��� ��� ����� ��� ����� ������. ����� ��� ��������, ����������� ����� ������ ������ � ����� ������ ��� �������� (/pack)");
		        }
			}
	        SCMTA(COLOR_YELLOW, "������������� �������� TDM �� ����������� ���������. ����� ���������� - 6 �����, ������ 3 ������ ��� ����� ���������.");
	        SCMTA(COLOR_YELLOW, "����� ���������� ���� TDM, ������� ������� {FFFFFF}/tdminfo");
			tdm_aero = 1;
			tdm_stadion = 0;
            TDM = 1;
            SCMTA(COLOR_LGREEN, "�� ��������� TDM �������� 6 �����.");
            GangZoneFlashForAll(tdm2, COLOR_RED);
            TextDrawShowForAll(timertdm[0]);
            TextDrawShowForAll(timertdm[1]);
            TextDrawShowForAll(timertdm[2]);
            TextDrawShowForAll(timertdm[3]);
           	SendRconCommand("login saayYDSsnsdcaunuiBDYSdubdsnj12NBd"); // rcon ������, ����� login [������]
 			SendRconCommand("password 314563");
            TimerSSS = SetTimerEx("TimerTD", 1000, false, "d", KolvoSEC);
			new ttt[124];{
				format(ttt, sizeof(ttt), "%d", TimerSSS);}
			AdmChat(-1, ttt);
            SetTimer("TimeOut1", 1000*60*3, 0); // ������ ����� ���
        }
        else{
			SPD(playerid, D_TDM+1, DLIST, "����� �����", "������� ���-�������\n����������� ��������", "�������", "������");
			SpawnPlayer(playerid);
			return 1;}
    }
   if(dialogid == D_TDM+2)
    {
        if(response)
        {
	        for(new i=0;i<MAX_PLAYERS;i++)
			{
		        if(gTeam[i] == 1)
		        {
		            SetPlayerPos(i, 2791.4883,-1847.5679,9.8446);
		            SetPlayerWorldBounds(i,2818.4871, 2643.8035, -1663.9380, -1881.2035);
		            SpawnPlayer(playerid);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 100);
					GivePlayerWeapon(i, gGun1[i], 1000);
					GivePlayerWeapon(i, gGun2[i], 1000);
					SCM(i, COLOR_KOJ, "��� ��� ����� ��� ����� ������. ����� ��� ��������, ����������� ����� ������ ������ � ����� ������ ��� �������� (/pack)");
		        }
		        if(gTeam[i] == 2)
		        {
		            SetPlayerPos(i, 2668.9751,-1684.8577,9.8389);
		            SetPlayerWorldBounds(i,2818.4871, 2643.8035, -1663.9380, -1881.2035);
		            SpawnPlayer(playerid);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 100);
					GivePlayerWeapon(i, gGun1[i], 1000);
					GivePlayerWeapon(i, gGun2[i], 1000);
					SCM(i, COLOR_KOJ, "��� ��� ����� ��� ����� ������. ����� ��� ��������, ����������� ����� ������ ������ � ����� ������ ��� �������� (/pack)");
		        }
			}
	        SCMTA(COLOR_YELLOW, "������������� �������� TDM �� �������� ���-�������. ����� ���������� - 6 �����, ������ 3 ������ ��� ����� ���������.");
	        SCMTA(COLOR_YELLOW, "����� ���������� ���� TDM, ������� ������� {FFFFFF}/tdminfo");
			tdm_aero = 0;
			tdm_stadion = 1;
            TDM = 1;
            SCMTA(COLOR_LGREEN, "�� ��������� TDM �������� 6 �����.");
            GangZoneFlashForAll(tdm1, COLOR_RED);
            TextDrawShowForAll(timertdm[0]);
            TextDrawShowForAll(timertdm[1]);
            TextDrawShowForAll(timertdm[2]);
            TextDrawShowForAll(timertdm[3]);
           	SendRconCommand("login saayYDSsnsdcaunuiBDYSdubdsnj12NBd"); // rcon ������, ����� login [������]
 			SendRconCommand("password 314563");
            TimerSSS = SetTimerEx("TimerTD", 1000, false, "d", KolvoSEC);
			new ttt[124];{
				format(ttt, sizeof(ttt), "%d", TimerSSS);}
			AdmChat(-1, ttt);
            SetTimer("TimeOut1", 1000*60*3, 0); // ������ ����� ���
        }
        else{
			SPD(playerid, D_TDM+1, DLIST, "����� �����", "������� ���-�������\n����������� ��������", "�������", "������");
			SpawnPlayer(playerid);
			return 1;}
    }
   if(dialogid == P_SET+1)
    {
        if(response)
        {
            PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			if(logotipe_p[playerid] == 0)
			{
			    TextDrawShowForPlayer(playerid, logo[0]);
			    TextDrawShowForPlayer(playerid, logo[1]);
			    SCM(playerid, COLOR_GREEN, "������� �������.");
            	logotipe_p[playerid] = 1;
            	return 1;
			}
			if(logotipe_p[playerid] == 1)
			{
			    TextDrawHideForPlayer(playerid, logo[0]);
			    TextDrawHideForPlayer(playerid, logo[1]);
				SCM(playerid, COLOR_RED, "������� ��������.");
            	logotipe_p[playerid] = 0;
            	return 1;
			}
		}
		else return 1;
	}
   if(dialogid == P_SET+2)
    {
        if(response)
        {
            PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			if(logotipe_p[playerid] == 0)
			{
			    TextDrawShowForPlayer(playerid, FPS[playerid]);
			    TextDrawShowForPlayer(playerid, FPS[playerid]);
			    SCM(playerid, COLOR_GREEN, "������ ���������� � ���� ��������.");
            	logotipe_p[playerid] = 1;
            	return 1;
			}
			if(logotipe_p[playerid] == 1)
			{
			    TextDrawHideForPlayer(playerid, FPS[playerid]);
			    TextDrawHideForPlayer(playerid, FPS[playerid]);
				SCM(playerid, COLOR_RED, "������ ���������� � ���� ���������.");
            	logotipe_p[playerid] = 0;
            	return 1;
			}
		}
		else return 1;
	}
   if(dialogid == P_SET)
    {
        if(response)
        {
			switch(listitem)
			{
			    case 0:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					if(logotipe_p[playerid] == 0)
					{
					    SPD(playerid, P_SET+1, DBOX, "����", "{FFFFFF}�� ������ �������� �������?", "��", "���");
						return 1;
					}
					if(logotipe_p[playerid] == 1)
					{
					    SPD(playerid, P_SET+1, DBOX, "����", "{FFFFFF}�� ������ ��������� �������?", "��", "���");
					    return 1;
					}
			    }
			    case 1:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					if(info_p[playerid] == 0)
					{
					    SPD(playerid, P_SET+2, DBOX, "������ ���������� � ����", "{FFFFFF}�� ������ �������� ������ ���������� � ����?", "��", "���");
						return 1;
					}
					if(info_p[playerid] == 1)
					{
					    SPD(playerid, P_SET+2, DBOX, "������ ���������� � ����", "{FFFFFF}�� ������ ��������� ������ ���������� � ����?", "��", "���");
					    return 1;
					}
			    }
			    case 2:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        SPD(playerid, P_SET+4, DLIST, "��� ������", "�������\n� ������ ������", "�������", "�����");
			    }
			}
        }
        else
        {
			ShowMenu(playerid);
        }
    }
   if(dialogid == P_SET+4)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(PlayerInfo[playerid][pSpawnType] == 0) return SCM(playerid, COLOR_ERROR, "� ��� � ��� ����������� ���� �����");
                    SCM(playerid, COLOR_ERROR, "*������ ������� ��� ������(��� ������)");
                    PlayerInfo[playerid][pSpawnType] = 0;
                    SPD(playerid, P_SET, DLIST, "���������", "������� �������\n������ ���������� � ����\n��� ������", "�������", "�����");
                }
                case 1:
                {
                    if(PlayerInfo[playerid][pSpawnType] == 1) return SCM(playerid, COLOR_ERROR, "� ��� � ��� ����������� ���� �����");
					if(PlayerInfo[playerid][pVeh] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ������� ����������");
                    SCM(playerid, COLOR_ERROR, "*������ �� ������ ���������� � ����� ������ ����������");
                    PlayerInfo[playerid][pSpawnType] = 1;
                    SPD(playerid, P_SET, DLIST, "���������", "������� �������\n������ ���������� � ����\n��� ������", "�������", "�����");
                }
            }
        }
        else return SPD(playerid, P_SET, DLIST, "���������", "������� �������\n������ ���������� � ����\n��� ������", "�������", "�����");
    }
   if(dialogid == mm)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0: ShowPlayerStat(playerid);
			    case 1:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        SPD(playerid, P_SET, DLIST, "���������", "������� �������\n������ ���������� � ����\n��� ������", "�������", "�����");
			    }
			    case 2:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        new str[2048];
			        format(str, sizeof(str), "\
					/dm [1-3] - DeathMatch ����\n\
					/world - �������� ���� ����������� ���\n\
					/mm - ���� �������\n\
					/report - ������� ����� � ��������������(����)\n\
					/switch - ����� �������\n\
					/pack - �������� ����� ������\n\
					/mypack - ���������� ���� ����� ������\n\
					/spawn - ������������\n\
					/buyweapon - ������ ������\n\
					/buyheal - ������ �����\n\
					/restream - �������� ���� ����������(������ �����)\n\
					/healup - ������������ �����(+60HP)\n\
					/inv - ���������\n\
     				/putgun - �������� ������ � ������(���������)\n\
					/tdm - ��������� TDM(��� ��������� �� TDM)\n");
				    SPD(playerid, D_CMD, DBOX, "������� �������", str, "�������", "");
			    }
				case 3:
				{
				    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
				    SPD(playerid, D_REPORT, DINPUT, "����� � ��������������", "{FFFFFF}����������� ������������� ��� ������/������ � ������� � ���� ����", "���������", "������");
				}
				case 4:
				{
				    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
				    SPD(playerid, CREDITS, DBOX, "������", "{FFFFFF}fracBlack aka Raymond Rich aka Minor North", "������", "");
				}
				case 5:
				{
				    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
				    SPD(playerid, D_VEH, DLIST, "���� ������� ����������", "���������� ������ ���������\n������ ������ ���������\n������� ������ ���������\n{FFFF00}���������� ���������\n������ ������� ����������", "�������", "�����");
				}
				case 6:
				{
				    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
				    SPD(playerid, D_TRAIN, DLIST, "���� ����������", "���������� ��������", "�������", "�����");
				}
			}
	    }
	    else return 1;
	}
   if(dialogid == D_AIR)
    {
        if(response)
        {
			if(PlayerInfo[playerid][pVeh] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ������� ����������");
			GivePlayerMoney(playerid, -10000);
			DestroyVehicle(vehicle[playerid]);
			SetTimerEx("OnPlayerAir", 1000, 0, "i", playerid);
        }
        else return 1;
	}
   if(dialogid == D_TRAIN)
    {
        if(response)
        {
			switch(listitem)
			{
			    case 0:
			    {
					if(TWeaponL == true)
					{
	                    SCM(playerid, COLOR_ERROR, "   *������ �������� ������!");
						PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					    SPD(playerid, D_TRAIN, DLIST, "���� ����������", "���������� ��������", "�������", "�����");
						return 1;
					}
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        SetPlayerInterior(playerid, 1);
			        SetPlayerPos(playerid,1412.639892,-1.787510,1000.924377);
					ShowWTrain(playerid);
					PlayerTrainZone[playerid] = true;
			    }
			}
        }
        else return ShowMenu(playerid);
    }
   if(dialogid == D_TRAIN+1)
    {
        new str[144];
        new namew[54];
        new idgun;
        if(response)
        {
			switch(listitem)
			{
			    case 0:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					idgun = 24;
			        GivePlayerWeapon(playerid, idgun, 9999);
			        GetWeaponName(idgun, namew, sizeof(namew));
					format(str, sizeof(str), "������� ������ %s. ����� ������� ������ � ������� ������, �������: /gow", namew);
					SCM(playerid, COLOR_ERROR, str);
			    }
			    case 1:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					idgun = 25;
			        GivePlayerWeapon(playerid, idgun, 9999);
			        GetWeaponName(idgun, namew, sizeof(namew));
					format(str, sizeof(str), "������� ������ %s. ����� ������� ������ � ������� ������, �������: /gow", namew);
					SCM(playerid, COLOR_ERROR, str);
			    }
			    case 2:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					idgun = 31;
			        GivePlayerWeapon(playerid, idgun, 9999);
			        GetWeaponName(idgun, namew, sizeof(namew));
					format(str, sizeof(str), "������� ������ %s. ����� ������� ������ � ������� ������, �������: /gow", namew);
					SCM(playerid, COLOR_ERROR, str);
			    }
			    case 3:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					idgun = 33;
			        GivePlayerWeapon(playerid, idgun, 9999);
			        GetWeaponName(idgun, namew, sizeof(namew));
					format(str, sizeof(str), "������� ������ %s. ����� ������� ������ � ������� ������, �������: /gow", namew);
					SCM(playerid, COLOR_ERROR, str);
			    }
			    case 4:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					idgun = 34;
			        GivePlayerWeapon(playerid, idgun, 9999);
			        GetWeaponName(idgun, namew, sizeof(namew));
					format(str, sizeof(str), "������� ������ %s. ����� ������� ������ � ������� ������, �������: /gow", namew);
					SCM(playerid, COLOR_ERROR, str);
			    }
			}
        }
        else
        {
            format(str, sizeof(str), "�� �������� ���� ����������");
            SetPlayerInterior(playerid, 0);
            SpawnPlayer(playerid);
            ShowMenu(playerid);
			SCM(playerid, COLOR_ERROR, str);
        }
    }
   if(dialogid == D_VEH)
	{
	    new string[144];
		if(response)
		{
			switch(listitem)
			{
			    case 0:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(PlayerInfo[playerid][pVeh] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ������� ����������");
			        if(CalledVehicle[playerid] == 1) return SCM(playerid, COLOR_ERROR, "�� ��� �������� ���� ���������, ���� �� ��� ��������, ������� /fixcar � ����� �������� ���");
			        if(GetPVarInt(playerid,"Vehicle") > gettime()) { SendClientMessage(playerid, COLOR_ERROR, "�������� ������ ��������� ����� ��� � 60 ������!"); return 0; }
			        if(PlayerDeathMatch[playerid] > 0) return SCM(playerid, COLOR_ERROR, "�� ���������� �� �� ����, ������� �� ���, ����� ������� ���������");
					CallPlayerVehicle(playerid);
					f("����� %s[%d] ������ ������ ��������� (ID: %d)", GN(playerid), playerid, PlayerInfo[playerid][pVeh]);
					SCMTA(COLOR_GREEN, string);
					SetPVarInt(playerid,"Vehicle",gettime() + 60);
			    }
			    case 1:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(PlayerInfo[playerid][pVeh] > 0){
						SCM(playerid, COLOR_ERROR, "� ��� ��� ������� ���������, �������� ���, ����� ������ �����");
						SPD(playerid, D_VEH, DLIST, "���� ������� ����������", "���������� ������ ���������\n������ ������ ���������\n������� ������ ���������\n{FFFF00}���������� ���������\n������ ������� ����������", "�������", "�����");
						return 1;}
					SPD(playerid, D_VEH+1, DLIST, "������� ����������", "Class A, �����\nClass B, �������\nClass D, ������\nClass C, Off Road\nClass N, Bike\nClass Fly", "�������", "�����");
			    }
			    case 2:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(PlayerInfo[playerid][pVeh] == 0){
						SCM(playerid, COLOR_ERROR, "� ��� ��� ������� ����������");
						SPD(playerid, D_VEH, DLIST, "���� ������� ����������", "���������� ������ ���������\n������ ������ ���������\n������� ������ ���������\n{FFFF00}���������� ���������\n������ ������� ����������", "�������", "�����");
						return 1;}
					SPD(playerid, D_SELLVEH, DBOX, "������� ����������", "{FFFFFF}�� ������������� ������ ������� ���� ���������?\n��� �������� ������ �������� ��������� ����������.", "��", "���");
			    }
			    case 3:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        //if(a_vehicle[playerid] == 1) return SCM(playerid, COLOR_ERROR, "�� ��� ��������� ���������");
			        if(PlayerDeathMatch[playerid] > 0) return SCM(playerid, COLOR_ERROR, "�� ���������� �� �� ����");
			        SPD(playerid, D_VEH+7, DLIST, "������: {FFFF00}250$", "Tampa\nSabre\nClover\nMountain Bike", "�������", "�����");
			    }
			    case 4:
			    {
					new Float:x,Float:y,Float:z;
					GetVehiclePos(vehicle[playerid], x,y,z);
					if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
					if(PlayerInfo[playerid][pVeh] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ����������");
					if(CalledVehicle[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� �� �������� ���� ���������");
					if(!PlayerToPoint(6.0, playerid, x,y,z)) return SCM(playerid, COLOR_ERROR, "�� ������ �� ����� ������");
					SPD(playerid, D_TUNE, DLIST, "������", "1. ������ �����", "�������", "������");
			    }
			}
		}
		else return ShowMenu(playerid);
	}
   if(dialogid == D_VEH+7)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					if(GetPlayerMoney(playerid) < 250){
					    SCM(playerid, COLOR_ERROR, "������������ �����");
						return 1;}
                    if(a_vehicle[playerid] == 1){
                    	DestroyVehicle(vehicle_player_a[playerid]);
                    	SCM(playerid, COLOR_YELLOW, "���������� ������ ���������� �����������");}
                    new Float:pos[3];
                    a_vehicle[playerid] = 1;
                    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
                    vehicle_player_a[playerid] = CreateVehicle(549, pos[0], pos[1], pos[2], 0, 1, 1, -1, 0);
                    PutPlayerInVehicle(playerid, vehicle_player_a[playerid], 0);
                    GivePlayerMoney(playerid, -250);
                    SCM(playerid, COLOR_YELLOW, "�� ������� ���������� ��������� {00FF00}Tampa");
                    SCM(playerid, COLOR_WHITE, "�� ��������� ������ 10 �����");
					SetTimerEx("ArendaExit", 60*1000*10, false, "i", playerid);
                }
                case 1:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					if(GetPlayerMoney(playerid) < 250){
					    SCM(playerid, COLOR_ERROR, "������������ �����");
						return 1;}
                    if(a_vehicle[playerid] == 1){
                    	DestroyVehicle(vehicle_player_a[playerid]);
                    	SCM(playerid, COLOR_YELLOW, "���������� ������ ���������� �����������");}
                    new Float:pos[3];
                    a_vehicle[playerid] = 1;
                    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
                    vehicle_player_a[playerid] = CreateVehicle(475, pos[0], pos[1], pos[2], 0, 1, 1, -1, 0);
                    PutPlayerInVehicle(playerid, vehicle_player_a[playerid], 0);
                    GivePlayerMoney(playerid, -250);
                    SCM(playerid, COLOR_YELLOW, "�� ������� ���������� ��������� {00FF00}Sabre");
                    SCM(playerid, COLOR_WHITE, "�� ��������� ������ 10 �����");
                    SetTimerEx("ArendaExit", 60*1000*10, false, "i", playerid);
                }
                case 2:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					if(GetPlayerMoney(playerid) < 250){
					    SCM(playerid, COLOR_ERROR, "������������ �����");
						return 1;}
                    if(a_vehicle[playerid] == 1){
                    	DestroyVehicle(vehicle_player_a[playerid]);
                    	SCM(playerid, COLOR_YELLOW, "���������� ������ ���������� �����������");}
                    new Float:pos[3];
                    a_vehicle[playerid] = 1;
                    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
                    vehicle_player_a[playerid] = CreateVehicle(542, pos[0], pos[1], pos[2], 0, 1, 1, -1, 0);
                    PutPlayerInVehicle(playerid, vehicle_player_a[playerid], 0);
                    GivePlayerMoney(playerid, -250);
                    SCM(playerid, COLOR_YELLOW, "�� ������� ���������� ��������� {00FF00}Clover");
                    SCM(playerid, COLOR_WHITE, "�� ��������� ������ 10 �����");
                    SetTimerEx("ArendaExit", 60*1000*10, false, "i", playerid);
                }
                case 3:
                {
                    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
					if(GetPlayerMoney(playerid) < 250){
					    SCM(playerid, COLOR_ERROR, "������������ �����");
						return 1;}
                    if(a_vehicle[playerid] == 1){
                    	DestroyVehicle(vehicle_player_a[playerid]);
                    	SCM(playerid, COLOR_YELLOW, "���������� ������ ���������� �����������");}
                    new Float:pos[3];
                    a_vehicle[playerid] = 1;
                    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
                    vehicle_player_a[playerid] = CreateVehicle(510, pos[0], pos[1], pos[2], 0, 1, 1, -1, 0);
                    PutPlayerInVehicle(playerid, vehicle_player_a[playerid], 0);
                    GivePlayerMoney(playerid, -250);
                    SCM(playerid, COLOR_YELLOW, "�� ������� ���������� ��������� {00FF00}Mountain Bike");
                    SCM(playerid, COLOR_WHITE, "�� ��������� ������ 10 �����");
                    SetTimerEx("ArendaExit", 60*1000*10, false, "i", playerid);
                }
            }
        }
        else return SPD(playerid, D_VEH, DLIST, "���� ������� ����������", "���������� ������ ���������\n������ ������ ���������\n������� ������ ���������\n{FFFF00}���������� ���������\n������ ������� ����������", "�������", "�����");
    }
   if(dialogid == D_SELLVEH)
	{
	    if(response)
	    {
	        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			new price, string[144];
			if(PlayerInfo[playerid][pVeh] == 402) price = 75000;
			else if(PlayerInfo[playerid][pVeh] == 411) price = 100000;
			else if(PlayerInfo[playerid][pVeh] == 415) price = 100000;
			else if(PlayerInfo[playerid][pVeh] == 429) price = 85000;
			else if(PlayerInfo[playerid][pVeh] == 451) price = 100000;
			else if(PlayerInfo[playerid][pVeh] == 477) price = 55000;
			else if(PlayerInfo[playerid][pVeh] == 506) price = 85000;
			else if(PlayerInfo[playerid][pVeh] == 541) price = 100000;
			else if(PlayerInfo[playerid][pVeh] == 559) price = 80000;
			else if(PlayerInfo[playerid][pVeh] == 603) price = 70000;
			else if(PlayerInfo[playerid][pVeh] == 405) price = 35000;
			else if(PlayerInfo[playerid][pVeh] == 421) price = 25000;
			else if(PlayerInfo[playerid][pVeh] == 426) price = 40000;
			else if(PlayerInfo[playerid][pVeh] == 445) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 492) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 507) price = 25000;
			else if(PlayerInfo[playerid][pVeh] == 551) price = 35000;
			else if(PlayerInfo[playerid][pVeh] == 560) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 562) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 475) price = 45000;
			else if(PlayerInfo[playerid][pVeh] == 404) price = 10000;
			else if(PlayerInfo[playerid][pVeh] == 418) price = 10000;
			else if(PlayerInfo[playerid][pVeh] == 458) price = 15000;
			else if(PlayerInfo[playerid][pVeh] == 479) price = 15000;
			else if(PlayerInfo[playerid][pVeh] == 405) price = 35000;
			else if(PlayerInfo[playerid][pVeh] == 410) price = 10000;
			else if(PlayerInfo[playerid][pVeh] == 419) price = 20000;
			else if(PlayerInfo[playerid][pVeh] == 436) price = 10000;
			else if(PlayerInfo[playerid][pVeh] == 466) price = 15000;
			else if(PlayerInfo[playerid][pVeh] == 604) price = 12500;
			else if(PlayerInfo[playerid][pVeh] == 474) price = 15000;
			else if(PlayerInfo[playerid][pVeh] == 518) price = 15000;
			else if(PlayerInfo[playerid][pVeh] == 542) price = 15000;
			else if(PlayerInfo[playerid][pVeh] == 549) price = 15000;
			else if(PlayerInfo[playerid][pVeh] == 400) price = 20000;
			else if(PlayerInfo[playerid][pVeh] == 424) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 470) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 489) price = 35000;
			else if(PlayerInfo[playerid][pVeh] == 495) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 500) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 568) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 573) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 579) price = 45000;
			else if(PlayerInfo[playerid][pVeh] == 487) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 497) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 488) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 520) price = 100000;
			else if(PlayerInfo[playerid][pVeh] == 417) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 425) price = 80000;
			else if(PlayerInfo[playerid][pVeh] == 447) price = 60000;
			else if(PlayerInfo[playerid][pVeh] == 469) price = 55000;
			else if(PlayerInfo[playerid][pVeh] == 460) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 476) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 511) price = 25000;
			else if(PlayerInfo[playerid][pVeh] == 512) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 513) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 519) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 548) price = 40000;
			else if(PlayerInfo[playerid][pVeh] == 553) price = 50000;
			else if(PlayerInfo[playerid][pVeh] == 563) price = 30000;
			else if(PlayerInfo[playerid][pVeh] == 593) price = 45000;
	                    
			PlayerInfo[playerid][pVeh] = 0;
			PlayerInfo[playerid][pColorVeh1] = 0;
			PlayerInfo[playerid][pColorVeh2] = 0;
			PlayerInfo[playerid][pNitro] = 0;
			GivePlayerMoney(playerid, price);
			CalledVehicle[playerid] = 0;
			DestroyVehicle(vehicle[playerid]);
			f("�� ������� ������� ���� ����������, ������� � ���� �������� ��� ��������� %d$", price);
			SCM(playerid, COLOR_YELLOW, string);
	    }
	    else return SPD(playerid, D_VEH, DLIST, "���� ������� ����������", "���������� ������ ���������\n������ ������ ���������\n������� ������ ���������\n{FFFF00}���������� ���������\n������ ������� ����������", "�������", "�����");
	}
   if(dialogid == D_VEH+1)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	                SPD(playerid, D_VEH+2, DLIST, "�����", "\
                    Buffalo\t\t[150.000$]\n\
                    Infernus\t\t[200.000$]\n\
                    Cheetah\t\t[200.000$]\n\
                    Banshee\t\t[170.000$]\n\
                    Turismo\t\t[200.000$]\n\
                    ZR-350\t\t[110.000$]\n\
                    Super GT\t\t[170.000$]\n\
                    Bullet\t\t[200.000$]\n\
                    Jester\t\t[160.000$]\n\
                    Phoenix\t\t[140.000$]\n\
					", "������", "�����");
	            }
	            case 1:
	            {
	                PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	                SPD(playerid, D_VEH+3, DLIST, "�������", "\
                    Sentinel\t\t[70.000$]\n\
                    Washington\t\t[50.000$]\n\
                    Premier\t\t[80.000$]\n\
                    Admiral\t\t[60.000$]\n\
                    Greenwood\t\t[60.000$]\n\
                    Elegant\t\t[50.000$]\n\
                    Merit\t\t[70.000$]\n\
                    Sultan\t\t[100.000$]\n\
                    Elegy\t\t[100.000$]\n\
                    Sabre\t\t[90.000$]\n\
					", "������", "�����");
	            }
	            case 2:
	            {
	                PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	                SPD(playerid, D_VEH+4, DLIST, "������", "\
                    Perenniel\t\t[20.000$]\n\
                    Moonbeam\t\t[20.000$]\n\
                    Solair\t\t[30.000$]\n\
                    Regina\t\t[30.000$]\n\
                    Manana\t\t[20.000$]\n\
                    Esperanto\t\t[40.000$]\n\
                    Previon\t\t[20.000$]\n\
                    Glendale\t\t[30.000$]\n\
                    Glendale Shit\t\t[25.000$]\n\
                    Hermes\t\t[30.000$]\n\
                    Buccaneer\t\t[30.000$]\n\
                    Clover\t\t[30.000$]\n\
                    Tampa\t\t[30.000$]\n\
					", "������", "�����");
	            }
	            case 3:
	            {
	                PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
	                Landstalker\t\t[40.000$]\n\
	                BF Injection\t\t[100.000$]\n\
	                Patriot\t\t[60.000$]\n\
	                Rancher\t\t[70.000$]\n\
	                Sandking\t\t[100.000$]\n\
	                Mesa\t\t[60.000$]\n\
	                Bandito\t\t[100.000$]\n\
	                Dune\t\t[100.000$]\n\
	                Huntley\t\t[90.000$]\n\
					", "������", "�����");
	            }
	            case 4:
				{
				    return 1;
				}
	            case 5:
	            {
	                PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
	                Maverick\t\t[100.000$]\n\
	                SAPD Maverick\t\t[100.000$]\n\
	                SAN News Maverick\t\t[100.000$]\n\
	                Hydra\t\t[200.000$]\n\
	                Leviathan\t\t[60.000$]\n\
	                Hunter\t\t[190.000$]\n\
	                Seasparrow\t\t[120.000$]\n\
	                Sparrow\t\t[110.000$]\n\
                    Skimmer\t\t[60.000$]\n\
                    Rustler\t\t[100.000$]\n\
                    Beagle\t\t[50.000$]\n\
                    Cropduster\t\t[60.000$]\n\
                    Stuntplane\t\t[100.000$]\n\
                    Shamal\t\t[100.000$]\n\
                    Cargobob\t\t[80.000$]\n\
                    Nevada\t\t[100.000$]\n\
                    Raindance\t\t[60.000$]\n\
                    Dodo\t\t[90.000$]\n\
					", "������", "�����");
	            }
			}
	    }
	    else{
	        SPD(playerid, D_VEH, DLIST, "���� ������� ����������", "���������� ������ ���������\n������ ������ ���������\n������� ������ ���������\n{FFFF00}���������� ���������\n������ ������� ����������", "�������", "�����");
	        return 1;}
	}
   if(dialogid == D_VEH+10)
    {
        if(response)
        {
			switch(listitem)
			{
			    case 0:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
			        PlayerInfo[playerid][pVeh] = 487;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Maverick");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 1:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
			        PlayerInfo[playerid][pVeh] = 497;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}SAPD Maverick");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 2:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
			        PlayerInfo[playerid][pVeh] = 488;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}SAN News Maverick");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 3:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 200000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -200000);
			        PlayerInfo[playerid][pVeh] = 520;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Hydra");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 4:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
			        PlayerInfo[playerid][pVeh] = 417;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Leviathan");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 5:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 190000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -190000);
			        PlayerInfo[playerid][pVeh] = 425;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Hunter");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 6:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 120000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -120000);
			        PlayerInfo[playerid][pVeh] = 447;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Seasparrow");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 7:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 110000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -110000);
			        PlayerInfo[playerid][pVeh] = 469;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Sparrow");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 8:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
			        PlayerInfo[playerid][pVeh] = 460;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Skimmer");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 9:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
			        PlayerInfo[playerid][pVeh] = 576;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Rustler");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 10:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 50000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -50000);
			        PlayerInfo[playerid][pVeh] = 511;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Beagle");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 11:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
			        PlayerInfo[playerid][pVeh] = 512;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Cropduster");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 12:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
			        PlayerInfo[playerid][pVeh] = 513;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Stuntplane");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 13:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
			        PlayerInfo[playerid][pVeh] = 519;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Shamal");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 14:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 80000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -80000);
			        PlayerInfo[playerid][pVeh] = 548;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Cargobob");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 15:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
			        PlayerInfo[playerid][pVeh] = 553;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Nevada");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 16:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
			        PlayerInfo[playerid][pVeh] = 563;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Raindance");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 17:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 90000){
		                SPD(playerid, D_VEH+10, DLIST, "Class Fly", "\
		                Maverick\t\t[100.000$]\n\
		                SAPD Maverick\t\t[100.000$]\n\
		                SAN News Maverick\t\t[100.000$]\n\
		                Hydra\t\t[200.000$]\n\
		                Leviathan\t\t[60.000$]\n\
		                Hunter\t\t[190.000$]\n\
		                Seasparrow\t\t[120.000$]\n\
		                Sparrow\t\t[110.000$]\n\
	                    Skimmer\t\t[60.000$]\n\
	                    Rustler\t\t[100.000$]\n\
	                    Beagle\t\t[50.000$]\n\
	                    Cropduster\t\t[60.000$]\n\
	                    Stuntplane\t\t[100.000$]\n\
	                    Shamal\t\t[100.000$]\n\
	                    Cargobob\t\t[80.000$]\n\
	                    Nevada\t\t[100.000$]\n\
	                    Raindance\t\t[60.000$]\n\
	                    Dodo\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -90000);
			        PlayerInfo[playerid][pVeh] = 593;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Dodo");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			}
		}
		else return SPD(playerid, D_VEH+1, DLIST, "������� ����������", "Class A, �����\nClass B, �������\nClass D, ������\nClass C, Off Road\nClass N, Bike\nClass Fly", "�������", "�����");
	}
   if(dialogid == D_VEH+2)
    {
        if(response)
        {
			switch(listitem)
			{
			    case 0:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 150000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -150000);
			        PlayerInfo[playerid][pVeh] = 402;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Buffalo");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 1:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 200000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
					GivePlayerMoney(playerid, -200000);
			        PlayerInfo[playerid][pVeh] = 411;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Infernus");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 2:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 200000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -200000);
					PlayerInfo[playerid][pVeh] = 415;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Cheetah");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 3:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 170000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -170000);
					PlayerInfo[playerid][pVeh] = 429;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Banshee");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 4:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 200000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -200000);
					PlayerInfo[playerid][pVeh] = 451;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Turismo");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 5:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 110000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -110000);
					PlayerInfo[playerid][pVeh] = 477;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}ZR-350");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 6:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 170000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -170000);
					PlayerInfo[playerid][pVeh] = 506;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Super GT");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 7:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 200000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -200000);
					PlayerInfo[playerid][pVeh] = 541;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Bullet");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 8:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 160000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -160000);
					PlayerInfo[playerid][pVeh] = 559;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Jester");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 9:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 140000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+2, DLIST, "�����", "\
	                    Buffalo\t\t[150.000$]\n\
	                    Infernus\t\t[200.000$]\n\
	                    Cheetah\t\t[200.000$]\n\
	                    Banshee\t\t[170.000$]\n\
	                    Turismo\t\t[200.000$]\n\
	                    ZR-350\t\t[110.000$]\n\
	                    Super GT\t\t[170.000$]\n\
	                    Bullet\t\t[200.000$]\n\
	                    Jester\t\t[160.000$]\n\
	                    Phoenix\t\t[140.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -140000);
					PlayerInfo[playerid][pVeh] = 603;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Phoenix");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			}
        }
        else return SPD(playerid, D_VEH+1, DLIST, "������� ����������", "Class A, �����\nClass B, �������\nClass D, ������\nClass C, Off Road\nClass N, Bike\nClass Fly", "�������", "�����");
    }
   if(dialogid == D_VEH+3)
    {
        if(response)
        {
			switch(listitem)
			{
			    case 0:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 70000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -70000);
					PlayerInfo[playerid][pVeh] = 405;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Sentinel");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 1:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 50000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -50000);
					PlayerInfo[playerid][pVeh] = 421;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Washington");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 2:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 80000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -80000);
					PlayerInfo[playerid][pVeh] = 426;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Premier");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 3:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
					PlayerInfo[playerid][pVeh] = 445;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Admiral");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 4:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
					PlayerInfo[playerid][pVeh] = 492;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Greenwood");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 5:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 50000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -50000);
					PlayerInfo[playerid][pVeh] = 507;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Elegant");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 6:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 70000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -70000);
					PlayerInfo[playerid][pVeh] = 551;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Merit");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 7:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
					PlayerInfo[playerid][pVeh] = 560;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Sultan");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 8:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
					PlayerInfo[playerid][pVeh] = 562;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Elegy");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			    case 9:
			    {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 90000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+3, DLIST, "�������", "\
	                    Sentinel\t\t[70.000$]\n\
	                    Washington\t\t[50.000$]\n\
	                    Premier\t\t[80.000$]\n\
	                    Admiral\t\t[60.000$]\n\
	                    Greenwood\t\t[60.000$]\n\
	                    Elegant\t\t[50.000$]\n\
	                    Merit\t\t[70.000$]\n\
	                    Sultan\t\t[100.000$]\n\
	                    Elegy\t\t[100.000$]\n\
	                    Sabre\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -90000);
					PlayerInfo[playerid][pVeh] = 475;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Sabre");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
			    }
			}
        }
        else return SPD(playerid, D_VEH+1, DLIST, "������� ����������", "Class A, �����\nClass B, �������\nClass D, ������\nClass C, Off Road\nClass N, Bike\nClass Fly", "�������", "�����");
    }
   if(dialogid == D_VEH+4)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 20000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -20000);
					PlayerInfo[playerid][pVeh] = 404;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Perenniel");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 1:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 20000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -20000);
					PlayerInfo[playerid][pVeh] = 418;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Moonbeam");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 2:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 30000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -30000);
					PlayerInfo[playerid][pVeh] = 458;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Solair");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 3:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 30000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -30000);
					PlayerInfo[playerid][pVeh] = 479;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Regina");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 4:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 20000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -20000);
					PlayerInfo[playerid][pVeh] = 410;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Manana");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 5:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 40000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -40000);
					PlayerInfo[playerid][pVeh] = 419;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Esperanto");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 6:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 20000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -20000);
					PlayerInfo[playerid][pVeh] = 436;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Previon");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 7:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 30000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -30000);
					PlayerInfo[playerid][pVeh] = 466;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Glendale");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 8:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 25000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -25000);
					PlayerInfo[playerid][pVeh] = 604;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Glendale Shit");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 9:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 30000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -30000);
					PlayerInfo[playerid][pVeh] = 474;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Hermes");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 10:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 30000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -30000);
					PlayerInfo[playerid][pVeh] = 518;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Buccaneer");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 11:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 30000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -30000);
					PlayerInfo[playerid][pVeh] = 542;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Clover");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
                case 12:
                {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 30000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+4, DLIST, "������", "\
	                    Perenniel\t\t[20.000$]\n\
	                    Moonbeam\t\t[20.000$]\n\
	                    Solair\t\t[30.000$]\n\
	                    Regina\t\t[30.000$]\n\
	                    Manana\t\t[20.000$]\n\
	                    Esperanto\t\t[40.000$]\n\
	                    Previon\t\t[20.000$]\n\
	                    Glendale\t\t[30.000$]\n\
	                    Glendale Shit\t\t[25.000$]\n\
	                    Hermes\t\t[30.000$]\n\
	                    Buccaneer\t\t[30.000$]\n\
	                    Clover\t\t[30.000$]\n\
	                    Tampa\t\t[30.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -30000);
					PlayerInfo[playerid][pVeh] = 549;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Tampa");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
                }
            }
        }
        else return SPD(playerid, D_VEH+1, DLIST, "������� ����������", "Class A, �����\nClass B, �������\nClass D, ������\nClass C, Off Road\nClass N, Bike\nClass Fly", "�������", "�����");
    }
   if(dialogid == D_VEH+5)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 40000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -40000);
					PlayerInfo[playerid][pVeh] = 400;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Landstalker");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 1:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
					PlayerInfo[playerid][pVeh] = 424;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}BF Injection");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 2:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
					PlayerInfo[playerid][pVeh] = 470;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Patriot");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 3:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 70000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -70000);
					PlayerInfo[playerid][pVeh] = 489;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Rancher");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 4:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
					PlayerInfo[playerid][pVeh] = 495;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Sandking");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 5:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 60000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -60000);
					PlayerInfo[playerid][pVeh] = 500;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Mesa");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 6:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
					PlayerInfo[playerid][pVeh] = 568;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Bandito");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 7:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 100000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -100000);
					PlayerInfo[playerid][pVeh] = 573;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Dune");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	            case 8:
	            {
			        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
			        if(GetPlayerMoney(playerid) < 90000){
						SCM(playerid, COLOR_ERROR, "������������ �����");
		                SPD(playerid, D_VEH+5, DLIST, "Off Road", "\
		                Landstalker\t\t[40.000$]\n\
		                BF Injection\t\t[100.000$]\n\
		                Patriot\t\t[60.000$]\n\
		                Rancher\t\t[70.000$]\n\
		                Sandking\t\t[100.000$]\n\
		                Mesa\t\t[60.000$]\n\
		                Bandito\t\t[100.000$]\n\
		                Dune\t\t[100.000$]\n\
		                Huntley\t\t[90.000$]\n\
						", "������", "�����");
						return 1;}
                    GivePlayerMoney(playerid, -90000);
					PlayerInfo[playerid][pVeh] = 579;
					SCM(playerid, COLOR_YELLOW, "�� ������� ��������� ������ ��������� {00FF00}Huntley");
					SCM(playerid, COLOR_YELLOW, "��� ���������� ��, �����������: {00FF00}/mm - ���� ����������");
	            }
	        }
	    }
	    else return SPD(playerid, D_VEH+1, DLIST, "������� ����������", "Class A, �����\nClass B, �������\nClass D, ������\nClass C, Off Road\nClass N, Bike\nClass Fly", "�������", "�����");
	}
   if(dialogid == D_REPORT)
	{
	    if(response)
	    {
	        PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	        new string[144], string1[144];
	        f("���� ��������� ����������. ���������: {FFFFFF} %s", inputtext[0]);
			SendClientMessage(playerid, COLOR_GREEN, string);
			format(string1, sizeof(string1), "[REPORT] �� %s [%d]: %s", GN(playerid), playerid, inputtext[0]);
			AdmChat(COLOR_GREY, string1);
	    }
	    else return 1;
	}
   if(dialogid == setting)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0:
			    {
	       			if(PlayerInfo[playerid][pLockTP] == 0)
	        		{
		                PlayerInfo[playerid][pLockTP] = 1;
		                SendClientMessage(playerid, -1, "���������. ������ ��� �� ������ ��������������� ������ ��������������.");
						PlayerPlaySound(playerid, 3000, 0, 0, 0);
	        		}
	        		else
	        		{
		                PlayerInfo[playerid][pLockTP] = 0;
		                SendClientMessage(playerid, -1, "���������. ������ ��� ����� ����� ���������������.");
	        		}
			    }
			}
	    }
	    else return 1;
	}
   if(dialogid == 1) // �����������
	{
        GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� �� ��������������� � ���� ������\n����������, ������� �������� ������ ��� �����������", PlayerInfo[playerid][pName]);
		if(!response){
			ShowPlayerDialog(playerid, 48, DIALOG_STYLE_MSGBOX, "��������","{FF0000}���� �� ����� ������� ��� ����������� ����������.\n\t\t       �� ���� �������.","��","");
			GKick(playerid, 1000);
			return 1;}
        GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� �� ��������������� � ���� ������\n����������, ������� �������� ������ ������ ��� �����������\n\n{FF0000}�� ������ ������������ � ������ �� ����� 6 � �� ����� 32 ��������", PlayerInfo[playerid][pName]);
		if(strlen(inputtext) < 6 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "�����������",gpn,"�����","������");
	    new allowed = 1;
		for(new i = 0; i < strlen(inputtext); i++)
		{
			if(inputtext[i] == 0) { allowed = 1; break; }
			if((inputtext[i] < 48) && (inputtext[i] != 32)) { allowed = 0; break; }
			if(inputtext[i] > 57 && inputtext[i] < 65) { allowed = 0; break; }
			if(inputtext[i] > 90 && inputtext[i] < 97) { allowed = 0; break; }
			if(inputtext[i] > 122) { allowed = 0; break; }
		}
        GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� �� ��������������� � ���� ������\n����������, ������� �������� ������ ��� �����������\n\n{FF0000}�������� ������ �������� ������������ �������\n�����������: a-z, A-Z, 0-9", PlayerInfo[playerid][pName]);
		if(!allowed) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "�����������",gpn,"�����","������");
        GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� ��������������� � ���� ������\n����������, ������� ��� ������ ��� �����������", PlayerInfo[playerid][pName]);
		new string[128];
		format(string, sizeof(string), "Accounts/%s.ini", PlayerInfo[playerid][pName]);
		new iniFile = ini_createFile(string);
		ini_setString(iniFile, "Password", inputtext);
		ini_setInteger(iniFile, "Admin", 0);
		ini_setInteger(iniFile, "Score", 0);
		ini_setInteger(iniFile, "Banned", 0);
		ini_setInteger(iniFile, "Skin", 0);
		ini_setInteger(iniFile, "LockTP", 0);
		ini_setInteger(iniFile, "DM", 0);
		ini_setInteger(iniFile, "Death", 0);
		ini_setInteger(iniFile, "Donate", 0);
		ini_setInteger(iniFile, "Money", 2500);
		ini_setInteger(iniFile, "ClanInvite", 0);
		ini_setInteger(iniFile, "Level", 0);
		ini_closeFile(iniFile);
		SendClientMessage(playerid, COLOR_YELLOW, "����������� � �������� ������������!");
		new stringa[124];
		format(stringa, sizeof(stringa), "����������������� ����� ����� - %s [%d]", GN(playerid), playerid);
		AdmChat(COLOR_GREY, stringa);
		ShowPlayerDialog(playerid, 2, DIALOG_STYLE_PASSWORD, "�����������",gpn,"����","������");
	}
   if(dialogid == 2) // �����������
	{
        GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� ��������������� � ���� ������\n����������, ������� ��� ������ ��� �����������", PlayerInfo[playerid][pName]);
		if(!response) return ShowPlayerDialog(playerid, 2, DIALOG_STYLE_PASSWORD, "�����������",gpn,"����","������");
        GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� ��������������� � ���� ������\n����������, ������� ��� ������ ��� �����������\n\n{FF0000}�� �� ����� ������, ���������� ��� ���", PlayerInfo[playerid][pName]);
		if(!strlen(inputtext)) return ShowPlayerDialog(playerid, 2, DIALOG_STYLE_PASSWORD, "�����������",gpn,"����","������");
	    new string[128];
	    format(string, sizeof(string), "Accounts/%s.ini", PlayerInfo[playerid][pName]);
	    new iniFile = ini_openFile(string);
	    ini_getString(iniFile, "Password", PlayerInfo[playerid][Password], 32);
	    ini_getInteger(iniFile, "Admin", PlayerInfo[playerid][pAdmin]);
	    ini_getInteger(iniFile, "Banned", PlayerInfo[playerid][pBanned]);
	    ini_getInteger(iniFile, "Mute", PlayerInfo[playerid][pMute]);
	    ini_getInteger(iniFile, "Skin", PlayerInfo[playerid][pSkin]);
	    ini_getInteger(iniFile, "LockTP", PlayerInfo[playerid][pLockTP]);
	    ini_getInteger(iniFile, "Death", PlayerInfo[playerid][pDeath]);
	    ini_getInteger(iniFile, "Money", PlayerInfo[playerid][pMoney]);
	    ini_getInteger(iniFile, "Level", PlayerInfo[playerid][pLevel]);
	    ini_getInteger(iniFile, "Score", PlayerInfo[playerid][pScore]);
	    ini_getInteger(iniFile, "Veh", PlayerInfo[playerid][pVeh]);
		ini_getInteger(iniFile, "ColorVeh1", PlayerInfo[playerid][pColorVeh1]);
		ini_getInteger(iniFile, "ColorVeh2", PlayerInfo[playerid][pColorVeh2]);
		ini_setInteger(iniFile, "Nitro", PlayerInfo[playerid][pNitro]);
	    ini_getInteger(iniFile, "Follow", PlayerInfo[playerid][pFollow]);
	    ini_getInteger(iniFile, "HealUp", PlayerInfo[playerid][pHealUp]);
	    ini_getInteger(iniFile, "SpawnType", PlayerInfo[playerid][pSpawnType]);
	    ini_closeFile(iniFile);
	    
        GetPlayerName(playerid, PlayerInfo[playerid][pName], 24);
    	format(gpn, sizeof(gpn), "�������: %s\n\n��� ������� ��������������� � ���� ������\n����������, ������� ��� ������ ��� �����������\n\n{FF0000}�� ����� �������� ������, ���������� ��� ���", PlayerInfo[playerid][pName]);
		if(strcmp(PlayerInfo[playerid][Password], inputtext)) return ShowPlayerDialog(playerid, 2, DIALOG_STYLE_PASSWORD, "�����������",gpn,"����","������");
		new str[1024];
		format(str, sizeof(str), "{FFFF00}��� ���: {FFFFFF}%s\n{FFFF00}��������� ������������ ���� ������: {FFFFFF}������� ������������.", GN(playerid));
		if(PlayerInfo[playerid][pBanned] > 0) return ShowPlayerDialog(playerid, 49, DIALOG_STYLE_MSGBOX, "�����������", str, "�������", "") && GKick(playerid, 6000);
		PlayerInfo[playerid][pEntered] = 1;
  		PlayerDeathMatch[playerid] = 0;
		TogglePlayerSpectating(playerid, false);
	    ForceClassSelection(playerid);
		new welcplay[124], welcomeadmin[124], texta[124];
		format(welcplay, sizeof(welcplay), "�� ������� ��������������. ��� �����: %s", GN(playerid));
		if(PlayerInfo[playerid][pScore] == 0)
		{
			SCM(playerid, COLOR_YELLOW, "[INFO] {FFFFFF}�� ������������� ���� ������������ � ����������� ������� (REFREE)");
			SCM(playerid, COLOR_YELLOW, "[INFO] {FFFFFF}����� ������� ���� �������, ������� {00FF00}/switch");
			SCM(playerid, COLOR_YELLOW, "[INFO] {FFFFFF}����� ������� ���� ���� �������� � REFREE, ������� {00FF00}/setskin (/ss)");
			SCM(playerid, COLOR_YELLOW, "[INFO] {FFFFFF}��� ������� �� ������ ���������� � �������: {00FF00}/mm - ������ ������");
			SCM(playerid, COLOR_YELLOW, "[INFO] {FFFFFF}��� ����� � �������������� ����������� ������: {00FF00}/mm - ����� � ��������������");
			SCM(playerid, COLOR_YELLOW, "[INFO] {FFFFFF}�� ������� ��������� ������� LVL, ��� ���� ����� ���������� ����� ������� �������: {00FF00}/buylevel");
			SCM(playerid, COLOR_YELLOW, "[INFO] {FFFFFF}�������������� ������� ���� �� ������, �������� ������� �� ������ �����, ������ �������: {00FF00}/levelinfo");
            SCM(playerid, -1, "������ ����� ���������� � ����� �� ��������� ���������, ����������� /map(gps)");
		}
		/*SPD(playerid, D_INFO, DBOX, "���������� � ����-�����", "\
		{FFFFFF}������ ���� �� 29.08(�������)\n\
		��������� �� ������ � �������������(��� �����): skype: live:osnova.north\n\n\
		������� �� ������������ ������ ���� ��� �� ���������� ������ ������ /mm - ������� �������\
		", "�������", "");*/
		//SCM(playerid, 0xFFFF00, "{FFFF00}[{FF0000}��������{FFFF00}] {FFFFFF}�������� ����� ������, ����� ��� ������� � ���� ����, ������� ������� {00FF00}/pack");
		//SPD(playerid, D_PACK, DLIST, "����� ������ - ���� 1", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "������");
		new strl[144];
		format(strl, sizeof(strl), "~w~Welcome to~n~~g~green death match~n~~r~%s", GN(playerid));
		GameTextForPlayer(playerid, strl, 3000, 1);
		format(welcomeadmin, sizeof(welcomeadmin), "�� �������������� ��� ���������� �������, ��� �������� ��� �����������. ��� �����: {FFFFFF}%s", GN(playerid));
		GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
		SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
		if(PlayerInfo[playerid][pAdmin] < 6) texta = welcplay;
		else if(PlayerInfo[playerid][pAdmin] == 6) texta = welcomeadmin;
		SendClientMessage(playerid, COLOR_LGREEN, texta);
		if(PlayerInfo[playerid][pAdmin] > 0) ShowAList(playerid);
		SpawnPlayer(playerid);
	}
   return 1;
}

forward TimerTD(secc);
public TimerTD(secc)
{
        new nsa[10];
        format(nsa, sizeof nsa ,"TIME %d", secc);
        TextDrawSetString(timertdm[0], nsa);
        secc--;
		if(TDM == 0) secc = 0;
        if(secc > 0)
        TimerSSS = SetTimerEx("TimerTD", 1000, false, "d", secc);
        return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
        if(MapTP == 1)
		{
			SetPlayerPosFindZ(playerid, fX, fY, fZ);
			printf("���������� ����� �� �����(%d): %f.4, %f.4, %f.4",numb, fX, fY, fZ);
			numb++;
        }
        return true;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
//==============================================================================
stock ShowPlayerStat(playerid)
{
	new string[1024], rang[100];
    if(GetPlayerScore(playerid) < 200) rang = "��� ����������� ������";
	else if(GetPlayerScore(playerid) >= 200 && GetPlayerScore(playerid) < 500 ) rang = "�������(1)";
	else if(GetPlayerScore(playerid) >= 500 && GetPlayerScore(playerid) < 1000 ) rang = "����������(2)";
	else if(GetPlayerScore(playerid) >= 1000 && GetPlayerScore(playerid) < 2000 ) rang = "��������(3)";
	else if(GetPlayerScore(playerid) >= 2000 && GetPlayerScore(playerid) < 2500 ) rang = "���������(4)";
	else if(GetPlayerScore(playerid) >= 2500 && GetPlayerScore(playerid) < 3000 ) rang = "�����������(5)";
	else if(GetPlayerScore(playerid) >= 3000 && GetPlayerScore(playerid) < 5000 ) rang = "�������(6)";
	else if(GetPlayerScore(playerid) >= 5000 && GetPlayerScore(playerid) < 10000 ) rang = "������(7)";
	else if(GetPlayerScore(playerid) >= 10000 && GetPlayerScore(playerid) < 20000 ) rang = "������������(8)";
	else if(GetPlayerScore(playerid) >= 20000 && GetPlayerScore(playerid) < 40000 ) rang = "�������(9)";
	else if(GetPlayerScore(playerid) >= 40000 && GetPlayerScore(playerid) < 60000 ) rang = "�����������(10)";
    else if(GetPlayerScore(playerid) >= 60000) rang = "�������(11)";
	f("{FFFFFF}�������:\t\t%s\n����������� �������:\t\t%d\n����������� �������:\t\t%d\n������:\t\t%s\n\n�����:\t\t%d", GN(playerid), PlayerInfo[playerid][pScore], PlayerInfo[playerid][pDeath], rang, PlayerInfo[playerid][pHealUp]);
	SPD(playerid, D_STATISTIC, DBOX, "����������", string, "������", "");
}
stock IsPlayerFlooding(playerid)
{
	if(GetTickCount() - iPlayerChatTime[playerid] < 2000)
	    return 1;

	return 0;
}

public Reklama()
{
	if(SetReklama == 0) return 1; // ���� ������� ��������� - ��������� �������
	SendClientMessageToAll(COLOR_YELLOW, "�������� ������� ������� ������ ����� � /mm - ������ ������");
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[],success)
{
    return 1;
}

forward ArendaExit(playerid);
public ArendaExit(playerid)
{
	if(a_vehicle[playerid] == 0) return 1;
	a_vehicle[playerid] = 0;
	SCM(playerid, COLOR_WHITE, "����� ������ ���������� �������");
	DestroyVehicle(vehicle_player_a[playerid]);
	return 1;
}
// ������� �������
CMD:cartune(playerid)
{
	new Float:x,Float:y,Float:z;
	GetVehiclePos(vehicle[playerid], x,y,z);
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(PlayerInfo[playerid][pVeh] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ����������");
	if(CalledVehicle[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� �� �������� ���� ���������");
	if(!PlayerToPoint(6.0, playerid, x,y,z)) return SCM(playerid, COLOR_ERROR, "�� ������ �� ����� ������");
	SPD(playerid, D_TUNE, DLIST, "������", "1. ������ �����\n2. ����", "�������", "������");
	return 1;
}
CMD:carlock(playerid)
{
	new Float:x,Float:y,Float:z;
	GetVehiclePos(vehicle[playerid], x,y,z);
	new Float:xx,Float:yy,Float:zz;
	GetPlayerPos(playerid, xx,zz,yy);
	if(PlayerInfo[playerid][pVeh] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ����������");
	if(CalledVehicle[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� �� �������� ���� ���������");
	if(!PlayerToPoint(5.0, playerid, x,y,z)) return SCM(playerid, COLOR_ERROR, "�� ������ �� ����� ������");
	if(status_lock[vehicle[playerid]] == 0)
	{
	    status_lock[vehicle[playerid]] = 1;
	    SCM(playerid, COLOR_RED, "�� ������� ���� ���������");
	}
	else
	{
	    status_lock[vehicle[playerid]] = 0;
	    SCM(playerid, COLOR_GREEN, "�� ������� ���� ���������");
	}
	return 1;
}
CMD:lock(playerid) return cmd_carlock(playerid);
CMD:setwanted(playerid, params[])
{
	if(sscanf(params, "d", params[0])) return 1;
	SetPlayerWantedLevel(playerid, params[0]);
	
	return 1;
}
CMD:air(playerid)
{
	SPD(playerid, D_AIR, DBOX, "��������� ������������", "{FFFFFF}�� ������ ������������ � ��������� ������������.\n��� ������������� ��� �������� ������ ������� ���������� ������������� �������� ��� ������ � ��������\n���������: {00FF00}$10000", "�����", "������");
	return 1;
}
CMD:inv(playerid)
{
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	new str[1024];
	
	igun[0][playerid] = PlayerInfo[playerid][pIGun0];
	igun[1][playerid] = PlayerInfo[playerid][pIGun1];
	igun[2][playerid] = PlayerInfo[playerid][pIGun2];
	igun[3][playerid] = PlayerInfo[playerid][pIGun3];

	ipt[0][playerid] = PlayerInfo[playerid][pIPt0];
	ipt[1][playerid] = PlayerInfo[playerid][pIPt1];
	ipt[2][playerid] = PlayerInfo[playerid][pIPt2];
	ipt[3][playerid] = PlayerInfo[playerid][pIPt3];

	if(ipt[0][playerid] == 0) igun[0][playerid] = 0;
	if(ipt[1][playerid] == 0) igun[1][playerid] = 0;
	if(ipt[2][playerid] == 0) igun[2][playerid] = 0;
	if(ipt[3][playerid] == 0) igun[3][playerid] = 0;
	
	format(str, sizeof(str), "%d [%d]\n%d [%d]\n%d [%d]\n%d [%d]", igun[0][playerid], ipt[0][playerid],igun[1][playerid], ipt[1][playerid],igun[2][playerid], ipt[2][playerid],igun[3][playerid], ipt[3][playerid]);
	SPD(playerid, D_INV, DLIST, "���������", str, "�����", "������");
	return 1;
}
CMD:buyheal(playerid, params[])
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(!PlayerToPoint(5.0,playerid,1172.8567,-1323.3353,15.3997))
	{
		if(!PlayerToPoint(5.0,playerid,2034.5220,-1412.1310,16.9922))
		{
			SCM(playerid, COLOR_ERROR, "���������� ��������� ����� ����� ��������(/gps)");
			return 1;
		}
	}
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/buyheal [����������]");
	if(PlayerInfo[playerid][pHealUp] == 3) return SCM(playerid, COLOR_ERROR, "� ��� ������������ ���������� �����");
	new price = PRICE_HEALUP;
	new str[144];
	if(params[0] > 3) return SCM(playerid, COLOR_ERROR, "������ ������ ������ 3-� �����");
	if(params[0]+PlayerInfo[playerid][pHealUp] > 3) return SCM(playerid, COLOR_ERROR, "������ ������ ������ 3-� �����");
	PlayerInfo[playerid][pHealUp] += params[0];
	GivePlayerMoney(playerid, -params[0]*price);
	format(str, sizeof(str), "�� ������ %d �� $%d. ������ � ��� %d ����� � $%d", params[0], params[0]*price, PlayerInfo[playerid][pHealUp], PlayerInfo[playerid][pMoney]);
	SCM(playerid, COLOR_BLUE, str);
	return 1;
}
CMD:healup(playerid)
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
    if(GetPVarInt(playerid,"HealUp") > gettime()) { SendClientMessage(playerid, COLOR_ERROR, "��������� �������� ������ ����� ���� ��� � 1 ������"); return 0; }
	if(PlayerInfo[playerid][pHealUp] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ����� :(");
	
	new Float:hp;
	GetPlayerHealth(playerid, hp);
	SetPlayerHealth(playerid, hp+60);
	GameTextForPlayer(playerid, "~b~+60HP", 1200, 1);
	PlayerInfo[playerid][pHealUp] -= 1;
	SetTimerEx("HealUpSave", 1000, 0, "i", playerid);
	ApplyAnimation(playerid,"ped","gum_eat",4.0,0,0,0,0,0,1);
	
	SetPVarInt(playerid,"HealUp",gettime() + 60);
	return 1;
}
forward HealUpSave(playerid);
public HealUpSave(playerid)
{
	new Float:hp;
	GetPlayerHealth(playerid, hp);
	if(hp > 100) SetPlayerHealth(playerid, 100);
	return 1;
}
CMD:restream(playerid)
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	
	GetPlayerPos(playerid, POSITION_FOR_RESTREAM[0], POSITION_FOR_RESTREAM[1], POSITION_FOR_RESTREAM[2]);
	SetPlayerPos(playerid, 0, 0, 0);
	SetTimerEx("reStream", 500, 0, "i", playerid);
	return 1;
}
forward reStream(playerid);
public reStream(playerid)
{
	SetPlayerPos(playerid, POSITION_FOR_RESTREAM[0], POSITION_FOR_RESTREAM[1], POSITION_FOR_RESTREAM[2]);
	return 1;
}
CMD:putgun(playerid)
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(GetPlayerWeapon(playerid) < 24 || GetPlayerWeapon(playerid) > 33) return SCM(playerid, COLOR_ERROR, "��� ������ ������ �������� � ���������");
	new str[144];
	if(GetPlayerWeapon(playerid) == 24)
	{
	    if(GetPlayerAmmo(playerid) < 100) return SCM(playerid, COLOR_ERROR, "���������� �������� �� ������ ���� ������ 100");
		format(str, sizeof(str), "�� �������� ������ [id %d] � �������� ������ [100] � ���� ������", GetPlayerWeapon(playerid));
		SCM(playerid, COLOR_GREEN, str);
		PlayerInfo[playerid][pIGun0] = 24;
		savept = GetPlayerAmmo(playerid)-100;
		PlayerInfo[playerid][pIPt0] += 100;
		SetPlayerAmmo(playerid, 24, savept);
	}
	if(GetPlayerWeapon(playerid) == 25)
	{
	    if(GetPlayerAmmo(playerid) < 100) return SCM(playerid, COLOR_ERROR, "���������� �������� �� ������ ���� ������ 100");
		format(str, sizeof(str), "�� �������� ������ [id %d] � �������� ������ [100] � ���� ������", GetPlayerWeapon(playerid));
		SCM(playerid, COLOR_GREEN, str);
		PlayerInfo[playerid][pIGun1] = 25;
		savept = GetPlayerAmmo(playerid)-100;
		PlayerInfo[playerid][pIPt1] += 100;
		SetPlayerAmmo(playerid, 25, GetPlayerAmmo(playerid)-100);
	}
	if(GetPlayerWeapon(playerid) == 31)
	{
	    if(GetPlayerAmmo(playerid) < 100) return SCM(playerid, COLOR_ERROR, "���������� �������� �� ������ ���� ������ 100");
		format(str, sizeof(str), "�� �������� ������ [id %d] � �������� ������ [100] � ���� ������", GetPlayerWeapon(playerid));
		SCM(playerid, COLOR_GREEN, str);
		PlayerInfo[playerid][pIGun2] = 31;
		savept = GetPlayerAmmo(playerid)-100;
		PlayerInfo[playerid][pIPt2] += 100;
		SetPlayerAmmo(playerid, 31, GetPlayerAmmo(playerid)-100);
	}
	if(GetPlayerWeapon(playerid) == 33)
	{
	    if(GetPlayerAmmo(playerid) < 100) return SCM(playerid, COLOR_ERROR, "���������� �������� �� ������ ���� ������ 100");
		format(str, sizeof(str), "�� �������� ������ [id %d] � �������� ������ [100] � ���� ������", GetPlayerWeapon(playerid));
		SCM(playerid, COLOR_GREEN, str);
		PlayerInfo[playerid][pIGun3] = 33;
		savept = GetPlayerAmmo(playerid)-100;
		PlayerInfo[playerid][pIPt3] += 100;
		SetPlayerAmmo(playerid, 33, GetPlayerAmmo(playerid)-100);
	}
	return 1;
}
CMD:pay(playerid, params[])
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
    if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/pay [id] [�����]");
	if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "�� ������� ���� ID");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
	if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
	if(params[1] > GetPlayerMoney(playerid)) return SCM(playerid, COLOR_ERROR, "� ��� ��� ������� �����");
	if(params[1] == 0) return SCM(playerid, COLOR_ERROR, "����� �� ����� ��������� ����");
	if(params[1] > 500000) return SCM(playerid, COLOR_ERROR, "��������� ���������� �� ���� �������� �� ����� $500000");
	if(params[1] < 1000) return SCM(playerid, COLOR_ERROR, "������ ��������� ������ $1000");
	GivePlayerMoney(params[0], params[1]);
	GivePlayerMoney(playerid, -params[1]);
	GivePlayerMoney(playerid, -250);
	new str[144];
	new name[MAX_PLAYER_NAME];
	new pname[MAX_PLAYER_NAME];
	GetPlayerName(params[0], pname, sizeof(pname));
	GetPlayerName(playerid, name, sizeof(name));
	format(str, sizeof(str), "����� %s ������� �� ��� ���� $%d", name, params[1]);
	SCM(params[0], COLOR_BLUE, str);
	format(str, sizeof(str), "�� �������� ������ %s �� ��� ���� $%d, ������� �� ����� ����� $%d", pname, params[1], GetPlayerMoney(playerid));
	SCM(playerid, COLOR_BLUE, str);
	SCM(playerid, -1, "�������� ������� ��������� $250");
	return 1;
}
CMD:gps(playerid, params[]) return cmd_map(playerid, params);
CMD:map(playerid, params[])
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(PlayerDeathMatch[playerid] > 0) return SCM(playerid, COLOR_ERROR, "������ ������������ �� �� ����");
    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	ShowPlayerDialog(playerid, D_GPS, DLIST, "�����", "1. ���������[7]\n2. ��������[2]", "�������", "�������");
	return 1;
}
CMD:w(playerid, params[]) return cmd_sms(playerid, params);
CMD:sms(playerid, params[])
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
    if(sscanf(params, "ds", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/sms(/w) [id] [�����]");
    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
    if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
    if(GetPlayerMoney(playerid) < 25) return SCM(playerid, COLOR_ERROR, "� ��� ������������ �����, ���������� $25");
	new str[144];
	new name[MAX_PLAYER_NAME];
	new pname[MAX_PLAYER_NAME];
	GetPlayerName(params[0], pname, sizeof(pname));
	GetPlayerName(playerid, name, sizeof(name));
	format(str, sizeof(str), "(SMS) �����������: %s | ���������: %s.", name, params[1]);
	SCM(params[0], COLOR_YELLOW, str);
	format(str, sizeof(str), "(SMS) ����������: %s | ���������: %s.", pname, params[1]);
	SCM(playerid, COLOR_YELLOW, str);
	SCM(playerid, -1, "   - ��������� ����������");
	GameTextForPlayer(playerid, "~g~-$25", 3000, 3);
	GivePlayerMoney(playerid, -25);
	return 1;
}
CMD:buyweapon(playerid, params[])
{
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(!PlayerToPoint(5.0, playerid, 308.5656,-140.8533,999.6016)) return SCM(playerid, COLOR_ERROR, "���������� ���������� � ��������� ��������");
	if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/buyweapon [id ������] [���-�� ������]");
	if(params[1] > 100) return SCM(playerid, COLOR_ERROR, "�� ��� ������ ������ ������ 100 ������ ������");
	new price[6];
	price[0] = PRICE_SD; //23
	price[1] = PRICE_DEAGLE; //24
	price[2] = PRICE_SHOTGUN; //25
	price[3] = PRICE_M4; //31
	price[4] = PRICE_RIFLE; //33
	price[5] = PRICE_SNIPER; //34
	
	if(params[0] < 23 || params[0] > 34) return SCM(playerid, COLOR_ERROR, "����������� ��� ������");
	if(params[0] == 24)
	{
		if(GetPlayerMoney(playerid) < params[1]*price[1]) return SCM(playerid, COLOR_ERROR, "������������ �����");
		GivePlayerMoney(playerid, -(params[1]*price[1]));
		GivePlayerWeapon(playerid, params[0], params[1]);
	}
	if(params[0] == 23)
	{
		if(GetPlayerMoney(playerid) < params[1]*price[0]) return SCM(playerid, COLOR_ERROR, "������������ �����");
		GivePlayerMoney(playerid, -(params[1]*price[0]));
		GivePlayerWeapon(playerid, params[0], params[1]);
	}
	if(params[0] == 25)
	{
		if(GetPlayerMoney(playerid) < params[1]*price[2]) return SCM(playerid, COLOR_ERROR, "������������ �����");
		GivePlayerMoney(playerid, -(params[1]*price[2]));
		GivePlayerWeapon(playerid, params[0], params[1]);
	}
	if(params[0] == 31)
	{
		if(GetPlayerMoney(playerid) < params[1]*price[3]) return SCM(playerid, COLOR_ERROR, "������������ �����");
		GivePlayerMoney(playerid, -(params[1]*price[3]));
		GivePlayerWeapon(playerid, params[0], params[1]);
	}
	if(params[0] == 33)
	{
		if(GetPlayerMoney(playerid) < params[1]*price[4]) return SCM(playerid, COLOR_ERROR, "������������ �����");
		GivePlayerMoney(playerid, -(params[1]*price[4]));
		GivePlayerWeapon(playerid, params[0], params[1]);
	}
	if(params[0] == 34)
	{
		if(GetPlayerMoney(playerid) < params[1]*price[5]) return SCM(playerid, COLOR_ERROR, "������������ �����");
		GivePlayerMoney(playerid, -(params[1]*price[5]));
		GivePlayerWeapon(playerid, params[0], params[1]);
	}
	return 1;
}
CMD:setfollow(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5){
	    return 1;}
	    else{
		if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
		if(sscanf(params, "dd", params[0], params[1])){
			SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/setfollow [id] [����� �������]");
			SCM(playerid, -1, "(0) ����� � ��������� ��������� ; (1) �������� TDM ; (2) �������� �� Street Racer");
			return 1;}
		if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
		if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
		if(params[1] > 2 || params[1] < 0){
			SCM(playerid, COLOR_ERROR, "�������� ����� �������");
			SCM(playerid, -1, "(1) �������� TDM ; (2) �������� �� Street Racer");
			return 1;}
		new string[144];
		if(params[1] == 0){
		    if(PlayerInfo[params[0]][pFollow] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������� ��������");
		    PlayerInfo[params[0]][pFollow] = 0;
		    f("������������� %s ���� ��� � ��������� ���������", GN(playerid), GN(params[0]));
		    SCM(playerid, COLOR_YELLOW, string);
		    return 1;}
		if(params[1] == 1){
		    PlayerInfo[params[0]][pFollow] = params[1];
		    f("������������� %s �������� ��������� �� TDM %s", GN(playerid), GN(params[0]));
		    SCMTA(COLOR_LIGHTRED, string);
		    return 1;}
		if(params[1] == 2){
		    PlayerInfo[params[0]][pFollow] = params[1];
		    f("������������� %s �������� ��������� �� Street Racer %s", GN(playerid), GN(params[0]));
		    SCMTA(COLOR_LIGHTRED, string);
		    return 1;}}
	return 1;
}
CMD:fixcar(playerid)
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(CalledVehicle[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� �� �������� ���� ���������");
	if(PlayerInfo[playerid][pVeh] == 0) return SCM(playerid, COLOR_ERROR, "� ��� ��� ������� ����������");
	if(GetPlayerMoney(playerid) < 1000) return SCM(playerid, COLOR_ERROR, "������������ �����, ���������� 1000$");
	CalledVehicle[playerid] = 0;
	SCM(playerid, COLOR_YELLOW, "�� ������� �������� ���� ���������.");
	GameTextForPlayer(playerid, "-1000", 1500, 1);
	GivePlayerMoney(playerid, -1000);
	DestroyVehicle(vehicle[playerid]);
	return 1;
}
/*
1. ������� 200
2. ���������� 500
3. �������� 1000
4. ��������� 2000
5. ����������� 2500
6. ������� 3000
7. ������ 5000
8. ������������ 10000
9. ������� 20000
10. ����������� 40000
11. ������� 60000
*/
CMD:setstat(playerid, params[]){
	new string[144];
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(PlayerInfo[playerid][pAdmin] != 6) return 1;
	if(sscanf(params, "ddd", params[0], params[1], params[2])){
		SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/setstat [id] [�����] [��������]");
		SCM(playerid, COLOR_ERROR, "(1) ���� ������� ; (2) ������ ; (3) ���� �������");
		return 1;}
	if(params[1] > 3 || params[1] < 1){
	    SCM(playerid, COLOR_ERROR, "�������� �����");
		SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/setstat [id] [�����] [��������]");
		SCM(playerid, COLOR_ERROR, "(1) ���� ������� ; (2) ������ ; (3) ���� �������");
		return 1;}
	if(params[1] == 1){
	    PlayerInfo[params[0]][pScore] = params[2];
	    SetPlayerScore(params[0], params[2]);
	    f("�� ���������� �������� ������� ������ %s �� %d", GN(params[0]), params[2]);
	    SCM(playerid, COLOR_GREY, string);
		return 1;}
	if(params[1] == 2){
		GivePlayerMoney(params[0], params[2]);
	    f("�� ������ %d$ ������ %s", params[2], GN(params[0]));
	    SCM(playerid, COLOR_GREY, string);
		return 1;}
	if(params[1] == 3){
		PlayerInfo[params[0]][pDeath] = params[2];
	    f("�� ���������� �������� ������� ������ %s �� %d", GN(params[0]), params[2]);
	    SCM(playerid, COLOR_GREY, string);
		return 1;}
	return 1;}
CMD:stats(playerid){
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	ShowPlayerStat(playerid);
	return 1;}
CMD:rangs(playerid){
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	SPD(playerid, D_RANGS, DBOX, "������� ������", "{FFFFFF}������\t\t��������\n\n�������\t\t� 200 �������\n����������\t\t� 500 �������\n��������\t\t� 1000 �������\n���������\t\t� 2000 �������\n�����������\t\t� 2500 �������\n�������\t\t� 3000 �������\n������\t\t� 5000 �������\n������������\t\t� 10000 �������\n�������\t\t� 20000 �������\n�����������\t\t� 40000 �������\n�������\t\t� 60000 �������", "������", "");
	return 1;}
CMD:gangflash(playerid)
{
	if(PlayerInfo[playerid][pAdmin] == 0) return 1;
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(gangflash == 1){
		GangZoneStopFlashForAll(dm1);
		GangZoneStopFlashForAll(dm2);
		GangZoneStopFlashForAll(dm3);
		SCMTA(COLOR_LIGHTRED, "������������� �������� ������� �� ���.");
		gangflash = 0;
		return 1;}
	if(gangflash == 0){
		GangZoneFlashForAll(dm1, 1445735634);
		GangZoneFlashForAll(dm2, 1445735634);
		GangZoneFlashForAll(dm3, 1445735634);
		SCMTA(COLOR_LIGHTRED, "������������� ������� ������� �� ���.");
		gangflash = 1;
		return 1;}
	return 1;
}
CMD:slap(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
	{
	    return 1;
	}
	else{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
		if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/slap [id]");
	    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
	    if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
		new Float:pos[3], string[144], Float:hp;
		GetPlayerPos(params[0], pos[0], pos[1], pos[2]);
		SetPlayerPos(params[0], pos[0], pos[1], pos[2]+6);
		GetPlayerHealth(params[0], hp);
		SetPlayerHealth(params[0], hp-7);
		
		f("������������� %s ��� ��� ���������", GN(playerid));
		SCM(params[0], COLOR_LIGHTRED, string);
	}
	return 1;
}
CMD:ahelp(playerid)
{
	new string[1024];
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(PlayerInfo[playerid][pAdmin] < 1)
	{
		return 1;
	}
	else
	{
	        f("{FFFFFF}\
            1 ������� - /a, /gangflash, /admins, /duty, /jetpack, /pm, /rules_tdm, /mute, /kick, /re, /reoff, /freeze, /setting, /mtp, /aarmour, /aspawn, /get\n\
            2 ������� - /tdm, /goto, /slap\n\
            3 ������� -	/sethp, /spawncars, /veh, /delveh, /ban\n\
            4 ������� - /locktp, /weather, /time, /gethere\n\
            5 ������� - /makeadmin, /removeadmin, /agun, /skick, /setfollow\n\
            6 ������� - /reklama, /setstat, /tdmlock, /stoptdm, /restart, /dellaccount");
	    	SPD(playerid, A_HELP, DBOX, "������� ��������������", string, "�������", "");
	}
	return 1;
}
CMD:reklama(playerid)
{
	if(PlayerInfo[playerid][pAdmin] == 6)
	{
		new string[124];
		if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
		if(SetReklama == 0)
		{
		    SetReklama = 1;
		    f("[A] ������������� %s ������� ������� �� �������", GN(playerid));
		    AdmChat(COLOR_GREY, string);
		    return 1;
		}
		if(SetReklama == 1)
		{
		    SetReklama = 0;
		    f("[A] ������������� %s �������� ������� �� �������", GN(playerid));
		    AdmChat(COLOR_GREY, string);
		    return 1;
		}
	}
	else return 1;
	return 1;
}

CMD:ascore(playerid, params[])
{
	new str1[124], str2[124];
	if(PlayerInfo[playerid][pAdmin] == 6)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
	    if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/ascore [id] [score]");
	    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
	    if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
	    SetPlayerScore(params[0], params[1]);
		PlayerInfo[params[0]][pScore] = params[1];
		format(str1, sizeof(str1), "������������� %s ����� ��� %d ����� �������", GN(playerid), params[1]);
		format(str2, sizeof(str2), "[A] ������������� ����� %d ����� ������� ������ %s", params[1], GN(params[0]));
		AdmChat(COLOR_GREY, str2);
		SCM(playerid, COLOR_YELLOW, str1);
	}
	else return 1;
	return 1;
}
/*CMD:pvp(playerid, params[])
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
    if(gopvp[playerid] == 1) return SCM(playerid, COLOR_ERROR, "� ��� ��� ���� �������� �����������, ����� ��� �������� ������� {FFFFFF}/cancel");
    if(activepvar == 1) return SCM(playerid, COLOR_ERROR, "�� ������ ������ ��� ����������� PVP");
	if(dangerpvp == 1) return SCM(playerid, COLOR_ERROR, "����� ����������� PVP �� ������ 1 ������, ���������� ���������");
    if(activepvp[playerid] == 1) return SCM(playerid, COLOR_ERROR, "�� �� PVP");
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/pvp [id]");
    if(params[0] == playerid) return SCM(playerid, COLOR_ERROR, "������ ������������ �� ����.");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
	if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
	new string[124], stringd[244];
	gopvp[playerid] = 1;
	gopvpId[params[0]] = playerid;
	f("�� ��������� ����������� � PVP ������ %s[%d], ����� �������� ����������� ������� {FFFFFF}/cancel", GN(params[0]), params[0]);
	SCM(playerid, COLOR_SALAT, string);
	format(stringd, sizeof(stringd), "{FFFFFF}����� %s ���������� ��� ������� � ��� � PVP. �� ��������?\n\n*���� �� �����������, �� ������ �� ���������, ������ �� ������ ������ �� �������.", GN(playerid));
	SPD(params[0], D_PVP, DBOX, "����������� �������� PVP", stringd, "��", "���");
	return 1;
}*/
CMD:exitpvp(playerid)
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
    if(activepvp[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� �� �� PVP");
	activepvar = 0;
	dangerpvp = 0;
	activepvp[playerid] = 0;
    activepvp[gopvpId[playerid]] = 0;
	pvp_score[playerid] = 0;
	pvp_score[gopvpId[playerid]] = 0;
    SpawnPlayer(playerid);
    SpawnPlayer(gopvpId[playerid]);
	new string[124];
	f("����� %s[%d] ������� ����� PVP", GN(playerid), playerid);
    SCMTA(COLOR_SALAT, string);
    return 1;
}

forward TimeOutPvp(playerid);
public TimeOutPvp(playerid)
{
	if(activepvar == 0) return 1;
	activepvar = 0;
	activepvp[playerid] = 0;
    activepvp[gopvpId[playerid]] = 0;
	pvp_score[playerid] = 0;
	pvp_score[gopvpId[playerid]] = 0;
    SpawnPlayer(playerid);
    SpawnPlayer(gopvpId[playerid]);
	new string[124];
	f("����� PVP ������������, ������ ����� �������� ����� ����� 1 ������(/pvp [id])");
    SCMTA(COLOR_SALAT, string);
    dangerpvp = 1;
	SetTimer("TimeOutPvp1", 60000, 0);
	return 1;
}

forward TimeOutPvp1();
public TimeOutPvp1()
{
	if(dangerpvp == 0) return 1;
	dangerpvp = 0;
	new string[124];
	f("������ ����� �������� PVP ����� (/pvp [id])");
    SCMTA(COLOR_SALAT, string);
	return 1;
}

CMD:cancel(playerid)
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
    if(gopvp[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� ������ �� ���������� ������� � PVP");
    if(gopvp[playerid] == 1){
        gopvp[playerid] = 0;
        SCM(playerid, COLOR_YELLOW, "�� �������� ���� �����������.");}
	return 1;
}
CMD:amoney(playerid, params[])
{
	new str1[124], str2[124];
	if(PlayerInfo[playerid][pAdmin] == 6)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
	    if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/amoney [id] [money]");
	    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
	    if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
	    GivePlayerMoney(params[0], params[1]);
		format(str1, sizeof(str1), "������������� %s ����� ��� %d$", GN(playerid), params[1]);
		format(str2, sizeof(str2), "[A] ������������� ����� %d$ ������ %s", params[1], GN(params[0]));
		AdmChat(COLOR_GREY, str2);
		SCM(params[0], COLOR_YELLOW, str1);
	}
	else return 1;
	return 1;
}
CMD:levelinfo(playerid)
{
			if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
			new string[1024];
	        f("{FFFFFF}\
            ��� ���� ����� ������� �� ��������� �������, ��� ���������� ������. ������ �� ������ ��������\n\
            ������ ������ ������� �� DeathMatch �����(/dm), �� ������� ������� ��� ����������� 500$, � ��\n\
            ������ ���� ������, � ��� �������� 200$.\n\n\
            ������������ ������� - 7.\n\
            ���� �������:\n\
			1 - 5000$\n\
			2 - 10.000$\n\
			3 - 12.000$\n\
			4 - 15.000$\n\
			5 - 20.000$\n\
			6 - 20.000$\n\
			7 - 20.000$");
	    	SPD(playerid, D_LEVEL_INFO, DBOX, "������� �������", string, "�������", "");
			return 1;
}
CMD:buylevel(playerid)
{
	new string[148];
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
	if(PlayerInfo[playerid][pLevel] == 0)
	{
	    if(GetPlayerMoney(playerid) < 5000) return SCM(playerid, COLOR_ERROR, "��� ������� ���������� LVL ��� ���������� 5000$");
	    PlayerInfo[playerid][pLevel] += 1;
	    GivePlayerMoney(playerid, -5000);
	    GameTextForPlayer(playerid, "-5000", 2000, 1);
	    return 1;
	}
	if(PlayerInfo[playerid][pLevel] == 1)
	{
	    if(GetPlayerMoney(playerid) < 10000) return SCM(playerid, COLOR_ERROR, "��� ������� ���������� LVL ��� ���������� 10000$");
	    PlayerInfo[playerid][pLevel] += 1;
	    GivePlayerMoney(playerid, -10000);
	    GameTextForPlayer(playerid, "-10000", 2000, 1);
	    return 1;
	}
	if(PlayerInfo[playerid][pLevel] == 2)
	{
	    if(GetPlayerMoney(playerid) < 12000) return SCM(playerid, COLOR_ERROR, "��� ������� ���������� LVL ��� ���������� 12000$");
	    PlayerInfo[playerid][pLevel] += 1;
	    GivePlayerMoney(playerid, -12000);
	    GameTextForPlayer(playerid, "-12000", 2000, 1);
	    return 1;
	}
	if(PlayerInfo[playerid][pLevel] == 3)
	{
	    if(GetPlayerMoney(playerid) < 15000) return SCM(playerid, COLOR_ERROR, "��� ������� ���������� LVL ��� ���������� 15000$");
	    PlayerInfo[playerid][pLevel] += 1;
	    GivePlayerMoney(playerid, -15000);
	    GameTextForPlayer(playerid, "-15000", 2000, 1);
	    return 1;
	}
	if(PlayerInfo[playerid][pLevel] == 4)
	{
	    if(GetPlayerMoney(playerid) < 20000) return SCM(playerid, COLOR_ERROR, "��� ������� ���������� LVL ��� ���������� 20000$");
	    PlayerInfo[playerid][pLevel] += 1;
	    GivePlayerMoney(playerid, -20000);
	    GameTextForPlayer(playerid, "-20000", 2000, 1);
	    return 1;
	}
	if(PlayerInfo[playerid][pLevel] == 5)
	{
	    if(GetPlayerMoney(playerid) < 20000) return SCM(playerid, COLOR_ERROR, "��� ������� ���������� LVL ��� ���������� 20000$");
	    PlayerInfo[playerid][pLevel] += 1;
	    GivePlayerMoney(playerid, -20000);
	    GameTextForPlayer(playerid, "-20000", 2000, 1);
	    return 1;
	}
	if(PlayerInfo[playerid][pLevel] == 6)
	{
	    if(GetPlayerMoney(playerid) < 20000) return SCM(playerid, COLOR_ERROR, "��� ������� ���������� LVL ��� ���������� 20000$");
	    PlayerInfo[playerid][pLevel] += 1;
	    GivePlayerMoney(playerid, -20000);
	    GameTextForPlayer(playerid, "-20000", 2000, 1);
	    f("����� %s ������ ������������� ������(7) � ������ ���� ����������� �������� �� ������� LVL.", GN(playerid));
	    SCMTA(COLOR_ERROR, string);
	    GivePlayerMoney(playerid, 184000);
	    GameTextForPlayer(playerid, "+184000", 2000, 1);
	    return 1;
	}
	if(PlayerInfo[playerid][pLevel] > 6) return SCM(playerid, COLOR_ERROR, "� ��� ������������ �������");
	return 1;
}
CMD:tdminfo(playerid)
{
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
	new string[1024];
	SCM(playerid, -1, "");
	f("\
	{FFFFFF}ATTACK: %d (�������)\n\
	DEFINED: %d (�������)\n\n\
	", gTEAM_SCORE_ATTACK, gTEAM_SCORE_DEFINED);
	SPD(playerid, D_INFO_TDM, DBOX, "���������� � TDM", string, "�������", "");
	/*if(TDM == 0)
	{
		if(gTEAM_SCORE_ATTACK > gTEAM_SCORE_DEFINED)
		{
		    f("\
			{FFFFFF}������� ���������� � ��������� �����: ATTACK\n\n\
			ATTACK: %d (�������)\n\
			DEFINED: %d (�������)\n\n\
			", gTEAM_SCORE_ATTACK, gTEAM_SCORE_DEFINED);
			SPD(playerid, D_INFO_TDM, DBOX, "���������� � TDM", string, "�������", "");
		}
		if(gTEAM_SCORE_DEFINED > gTEAM_SCORE_ATTACK)
		{
		    f("\
			{FFFFFF}������� ���������� � ��������� �����: DEFINED\n\n\
			ATTACK: %d (�������)\n\
			DEFINED: %d (�������)\n\n\
			", gTEAM_SCORE_ATTACK, gTEAM_SCORE_DEFINED);
			SPD(playerid, D_INFO_TDM, DBOX, "���������� � TDM", string, "�������", "");
		}
	}*/
	return 1;
}

CMD:rules_tdm(playerid)
{
	if(PlayerInfo[playerid][pAdmin] > 0)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� �������������");
	    {
	        for(new i=0;i<MAX_PLAYERS;i++)
			{
		        if(gTeam[playerid] == TEAM_ATTACK)
		        {
					SCM(i, COLOR_LIGHTRED,"������������� ������ ��� ������ ������ �� ���������� TDM.");
					SPD(i, D_RULES_TDM, DBOX, "������� �� ���������� TDM", "���������� �������", "�������", "");
		        }
		        if(gTeam[playerid] == TEAM_DEFINED)
		        {
					SCM(i, COLOR_LIGHTRED, "������������� ������ ��� ������ ������ �� ���������� TDM.");
					SPD(i, D_RULES_TDM, DBOX, "������� �� ���������� TDM", "���������� �������", "�������", "");
		        }
			}
		}
	}
	else return 1;
	return 1;
}

CMD:tdmlock(playerid)
{
	if(PlayerInfo[playerid][pAdmin] == 6)
	{
	    if(TDM_Lock == 0)
	    {
			if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
			TDM_Lock = 1;
			SCM(playerid, COLOR_GREY, " �� ������� TDM.");
			return 1;
		}
		if(TDM_Lock == 1)
	    {
			if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
			TDM_Lock = 0;
			SCM(playerid, COLOR_GREY, " �� ������� TDM.");
			return 1;
		}
	}
	else return 1;
	return 1;
}
CMD:setskin(playerid, params[])
{
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/setskin [id �����]");
	if(gTeam[playerid] != TEAM_REFREE) return SCM(playerid, COLOR_ERROR, "���������� ���������� � ������� REFREE");
	if(params[0] < 1 || params[0] > 311 || params[0] == 74) return SCM(playerid, COLOR_ERROR, "�������� ��������.");
	TEAM_REFREE_SKIN[playerid] = params[0];
	SetPlayerSkin(playerid, params[0]);
	SET_SKIN[playerid] = params[0];
	return 1;
}
CMD:ss(playerid, params[]){
	return cmd_setskin(playerid, params);}

CMD:switch(playerid, params[])
{
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/switch [1(ATTACK) - 2(DEFINED) - 3(REFREE)]");
	if(params[0] < 1 || params[0] > 3) return SCM(playerid, COLOR_ERROR, "�������� ��������.");
	if(params[0] == 1)
	{
		gTeam[playerid] = TEAM_ATTACK;
		SetPlayerSkin(playerid, TEAM_ATTACK_SKIN);
		GameTextForPlayer(playerid, "TEAM_ATTACK", 500, 3);
	}
	if(params[0] == 2)
	{
		gTeam[playerid] = TEAM_DEFINED;
		GameTextForPlayer(playerid, "TEAM_DEFINED", 500, 3);
		SetPlayerSkin(playerid, TEAM_DEFINED_SKIN);
	}
	if(params[0] == 3)
	{
		gTeam[playerid] = TEAM_REFREE;
		GameTextForPlayer(playerid, "TEAM_REFREE", 500, 3);
		SetPlayerSkin(playerid, TEAM_REFREE_SKIN[playerid]);
	}
	SCM(playerid, -1, "���������.");
	return 1;
}

CMD:tdm(playerid)
{
	if(TDM_Lock == 1) return SCM(playerid, COLOR_ERROR, "   ������ ���� ������ �� ��������. ������ ������� :(");
	if(PlayerInfo[playerid][pFollow] == FOLLOW_TDM)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	    if(TDM == 1) return SCM(playerid, COLOR_ERROR, "������ ������� TDM, ����� ��� ��� ������");
		SPD(playerid, D_TDM, DBOX, "�������������" ,"{FFFFFF}�� ������������� ������ ��������� TDM? ����������� ���� �������� �������������� �������", "��", "���");
	}
	else return SCM(playerid, COLOR_ERROR, "�� �� �������� �� TDM");
	return 1;
}

forward TimeOut1();
public TimeOut1()
{
	if(TDM == 1){
		SCMTA(COLOR_LGREEN, "�������� 3 ������ �� ��������� TDM.");
		SetTimer("TimeOut2", 1000*60*3, 0);}
	return 1;
}

forward TimeOut2();
public TimeOut2()
{
	if(TDM == 1){
				new string[144];
 				if(gTEAM_SCORE_ATTACK > gTEAM_SCORE_DEFINED)
				{
					f("TDM ������� ��������, �������� ������� ATTACK, �� ������ %d:%d", gTEAM_SCORE_ATTACK, gTEAM_SCORE_DEFINED);
	   				SCMTA(COLOR_YELLOW, string);
					SCMTA(COLOR_LIGHTRED, "[������] �������� ���������������� �������� ������� �������, ���������� ���������.");
	   				TDM = 0;
					gTEAM_SCORE_ATTACK = 0;
					gTEAM_SCORE_DEFINED = 0;
					for(new i=0;i<MAX_PLAYERS;i++)
					{
				        if(gTeam[i] == 1)
				        {
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 0);
							SpawnPlayer(i);
							TextDrawHideForPlayer(i,timertdm[0]);
							TextDrawHideForPlayer(i,timertdm[1]);
							TextDrawHideForPlayer(i,timertdm[2]);
							TextDrawHideForPlayer(i,timertdm[3]);
				        }
				        if(gTeam[i] == 2)
				        {
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 0);
							SpawnPlayer(i);
							TextDrawHideForPlayer(i,timertdm[0]);
							TextDrawHideForPlayer(i,timertdm[1]);
							TextDrawHideForPlayer(i,timertdm[2]);
							TextDrawHideForPlayer(i,timertdm[3]);
				        }
			           	SendRconCommand("login saayYDSsnsdcaunuiBDYSdubdsnj12NBd"); // rcon ������, ����� login [������]
			 			SendRconCommand("password 0");
					}
					return 1;
				}
				if(gTEAM_SCORE_DEFINED > gTEAM_SCORE_ATTACK)
				{
					f("TDM ������� ��������, �������� ������� DEFINED, �� ������ %d:%d", gTEAM_SCORE_DEFINED, gTEAM_SCORE_ATTACK);
	   				SCMTA(COLOR_YELLOW, string);
	   				TDM = 0;
                    gTEAM_SCORE_ATTACK = 0;
					gTEAM_SCORE_DEFINED = 0;
					for(new i=0;i<MAX_PLAYERS;i++)
					{
				        if(gTeam[i] == 1)
				        {
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 0);
							SpawnPlayer(i);
							TextDrawHideForPlayer(i,timertdm[0]);
							TextDrawHideForPlayer(i,timertdm[1]);
							TextDrawHideForPlayer(i,timertdm[2]);
							TextDrawHideForPlayer(i,timertdm[3]);
				        }
				        if(gTeam[i] == 2)
				        {
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 0);
							SpawnPlayer(i);
							TextDrawHideForPlayer(i,timertdm[0]);
							TextDrawHideForPlayer(i,timertdm[1]);
							TextDrawHideForPlayer(i,timertdm[2]);
							TextDrawHideForPlayer(i,timertdm[3]);
				        }
			           	SendRconCommand("login saayYDSsnsdcaunuiBDYSdubdsnj12NBd"); // rcon ������, ����� login [������]
			 			SendRconCommand("password 0");
					}
					return 1;
				}
				if(gTEAM_SCORE_DEFINED == gTEAM_SCORE_ATTACK)
				{
					f("TDM ������� ��������, �����, �� ������ D: %d ; A: %d", gTEAM_SCORE_DEFINED, gTEAM_SCORE_ATTACK);
	   				SCMTA(COLOR_YELLOW, string);
	   				TDM = 0;
					gTEAM_SCORE_ATTACK = 0;
					gTEAM_SCORE_DEFINED = 0;
					for(new i=0;i<MAX_PLAYERS;i++)
					{
				        if(gTeam[i] == 1)
				        {
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 0);
							SpawnPlayer(i);
							TextDrawHideForPlayer(i,timertdm[0]);
							TextDrawHideForPlayer(i,timertdm[1]);
							TextDrawHideForPlayer(i,timertdm[2]);
							TextDrawHideForPlayer(i,timertdm[3]);
				        }
				        if(gTeam[i] == 2)
				        {
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 0);
							SpawnPlayer(i);
							TextDrawHideForPlayer(i,timertdm[0]);
							TextDrawHideForPlayer(i,timertdm[1]);
							TextDrawHideForPlayer(i,timertdm[2]);
							TextDrawHideForPlayer(i,timertdm[3]);
				        }
			           	SendRconCommand("login saayYDSsnsdcaunuiBDYSdubdsnj12NBd"); // rcon ������, ����� login [������]
			 			SendRconCommand("password 0");
					}
					return 1;
				}
				return 1;}
    GangZoneStopFlashForAll(tdm1);
    GangZoneStopFlashForAll(tdm2);
	return 1;
}

CMD:stoptdm(playerid)
{
	if(PlayerInfo[playerid][pFollow] == FOLLOW_TDM)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	    if(TDM == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������� TDM.");
	    TDM = 0;
	    new string[144];
	    f("������������� %s ��������� TDM, ��� ������ ���������� �� �������.", GN(playerid));
	    SCMTA(COLOR_LIGHTRED, string);
		for(new i=0;i<MAX_PLAYERS;i++){
				        if(gTeam[i] == 1)
				        {
				            SetPlayerPos(i, 2791.4883,-1847.5679,9.8446);
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 100);
							SpawnPlayer(i);
				        }
				        if(gTeam[i] == 2)
				        {
				            SetPlayerPos(i, 2668.9751,-1684.8577,9.8389);
				            SetPlayerWorldBounds(i,20000.0000, -20000.0000, 20000.0000, -20000.0000);
							SetPlayerHealth(i, 100);
							SetPlayerArmour(i, 0);
							SpawnPlayer(i);
				        }
				        GangZoneStopFlashForAll(tdm1);
						TextDrawHideForPlayer(i,timertdm[0]);
						TextDrawHideForPlayer(i,timertdm[1]);
						TextDrawHideForPlayer(i,timertdm[2]);
						TextDrawHideForPlayer(i,timertdm[3]);
			           	SendRconCommand("login saayYDSsnsdcaunuiBDYSdubdsnj12NBd"); // rcon ������, ����� login [������]
			 			SendRconCommand("password 0");
		}
	}
	else return SCM(playerid, COLOR_ERROR, "�� �� �������� �� TDM");
	return 1;
}
CMD:mute(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] == 0) return 1;
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(sscanf(params, "us", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/mute [id] [�������]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������.");
	if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
	new string[144], name2[MAX_PLAYER_NAME], name[MAX_PLAYER_NAME];
	GetPlayerName(params[0], name2, sizeof(name2));
	GetPlayerName(playerid, name, sizeof(name));
	new title[42];
	if(PlayerInfo[playerid][pAdmin] == 1) title = "���������";
	else if(PlayerInfo[playerid][pAdmin] == 2) title = "������� ���������";
	else if(PlayerInfo[playerid][pAdmin] == 3) title = "�������������";
	else if(PlayerInfo[playerid][pAdmin] == 4) title = "������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 5) title = "������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 6) title = "����������";
	format(string, sizeof(string), "%s %s ������� ������ %s, �� �������: %s",title, name, name2, params[1]);
	SendClientMessageToAll(COLOR_LIGHTRED, string);
	PlayerInfo[playerid][pMute] = 1;
	return 1;
}
CMD:re(playerid, params[])
{
        if (PlayerInfo[playerid][pAdmin] < 1)
        {
            return 1;
        }
		else
		{
		    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/re [id ������] � ����� ��������� ������� /reoff");
		    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, COLOR_ERROR, "����� �� ������");
		    if(params[0] == playerid) return SendClientMessage(playerid, COLOR_ERROR, "�� �� ������ ������ ������ �� ����� �����");
		    if(PlayerInfo[params[0]][pEntered] == 0) return SendClientMessage(playerid, COLOR_ERROR, "����� �� �������������");
      		TogglePlayerSpectating(playerid, 1);
        	PlayerSpectatePlayer(playerid, params[0]);
        	SetPlayerInterior(playerid,GetPlayerInterior(params[0]));
        	SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(params[0]));
		}
		return 1;
}
CMD:reoff(playerid, params[])
{
        TogglePlayerSpectating(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SpawnPlayer(playerid);
		return 1;
}
CMD:world(playerid, params[])
{
	new world = params[0], string[124];
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������.");
	if(PlayerDeathMatch[playerid] == 0) return SCM(playerid, COLOR_ERROR, "���������� ���������� �� ����� �� �� ���.");
 	if(sscanf(params, "d", world)) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/world [����� ����]");
	if(world == GetPlayerVirtualWorld(playerid)) return SCM(playerid, COLOR_ERROR, "�� ��� ���������� � ���� ����");
	f("�� ���� ���������� � ����������� ��� - {FFFFFF}%d, ����� ��������� �� ����� �������, ���������� ��� �� 0.", world);
	SendClientMessage(playerid, COLOR_GREEN, string);
	SetPlayerVirtualWorld(playerid, world);
	return 1;
}
CMD:freeze(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1)
	{
	    if(sscanf(params, "dd", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/freeze [id ������] [1/0] (1 - ���������� , 0 - �����������)");
		if(params[1] < 0 || params[1] > 1) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/freeze [id ������] [1/0] (1 - ���������� , 0 - �����������)");
		if(params[1] == 0)
		{
			TogglePlayerControllable(params[0], params[1]);
			SCM(params[0], COLOR_LIGHTRED, "������������� ��������� ���.");
		}
		if(params[1] == 1)
		{
			TogglePlayerControllable(params[0], params[1]);
			SCM(params[0], COLOR_LIGHTRED, "������������� ���������� ���.");
		}
	}
	else return 1;
	return 1;
}
CMD:setting(playerid)
{
	if(PlayerInfo[playerid][pAdmin] >= 1)
	{
		SPD(playerid, setting, DLIST, "��������� ��������������", "�������/������� �������� � ���\n�������� �� �����", "�������", "������");
	}
	else return 1;
	return 1;
}
CMD:locktp(playerid)
{
	if(PlayerInfo[playerid][pAdmin] >= 4)
	{
        if(PlayerInfo[playerid][pLockTP] == 0)
        {
                PlayerInfo[playerid][pLockTP] = 1;
                SendClientMessage(playerid, -1, "���������. ������ ��� �� ������ ��������������� ������ ��������������.");
				PlayerPlaySound(playerid, 3000, 0, 0, 0);
        }
        else
        {
                PlayerInfo[playerid][pLockTP] = 0;
                SendClientMessage(playerid, -1, "���������. ������ ��� ����� ����� ���������������.");
        }
	}
	else return 1;
 	return 1;
}
CMD:mtp(playerid)
{
	if(PlayerInfo[playerid][pAdmin] > 0)
	{
        if(MapTP == 0)
        {
                MapTP = 1;
                SendClientMessage(playerid, COLOR_LGREEN, "�� �������� �������� � ������� ������� �� �����.");
        }
        else
        {
                MapTP = 0;
                SendClientMessage(playerid, COLOR_RED, "�� ��������� �������� �� �������.");
        }
	}
	else return 1;
 	return 1;
}
CMD:aarmour(playerid)
{
	if(PlayerInfo[playerid][pAdmin] >= 1)
	{
        if(dm_armour == 0)
        {
                new string[124];
                dm_armour = 1;
                format(string, sizeof(string), "������������� %s ������� ���������� �� �� �����", GN(playerid));
                SCMTA(COLOR_LIGHTRED, string);
        }
        else
        {
                new string2[124];
                dm_armour = 0;
                format(string2, sizeof(string2), "������������� %s �������� ���������� �� �� �����", GN(playerid));
                SCMTA(COLOR_LIGHTRED, string2);
        }
	}
	else return 1;
	return 1;
}
CMD:duty(playerid)
{
	if(PlayerInfo[playerid][pAdmin] > 0)
	{
		        new string[124], ip[42];
		        GetPlayerIp(playerid, ip, sizeof(ip));
	    		if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
				AdminText3D[playerid] = Create3DTextLabel("�������������",0xFF0000FF,0.0,0.0,0.0,50.0,0,1);
				Attach3DTextLabelToPlayer(AdminText3D[playerid],playerid,0.0,0.0,0.4);
	            f("[A] %s �������������. [IP: %s]", GN(playerid), ip);
	            AdmChat(COLOR_YELLOW, string);
	}
	else return 1;
	return 1;
}
CMD:sethp(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 2)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
		if(sscanf(params, "ud", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/sethp [id] [���-��]");
		if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
		if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
		if(params[1] > 100) return SCM(playerid, COLOR_ERROR, "������ ������ ������ 100 HP.");
		SetPlayerHealth(params[0],params[1]);
		new str[124], name[MAX_PLAYER_NAME];
		GetPlayerName(params[0], name, sizeof(name));
		format(str, sizeof(str), "������� HP %d ������ %s ����������.", params[1], name);
		SCM(playerid, -1, str);
	}
	else return 1;
	return 1;
}
CMD:aspawn(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 1)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/spawn [id]");
	    //if(PlayerInfo[params[0]][pAdmin] > 4) return SCM(playerid, -1, " ������ ������������ �� ������������ ��������������!");
		if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
		if(!IsPlayerConnected(params[0])) return SCM(playerid, -1, "����� �� ������");
		{
		    SpawnPlayer(params[0]);
			new givename[MAX_PLAYER_NAME], admname[MAX_PLAYER_NAME], string[124], string2[124];
			GetPlayerName(params[0], givename, sizeof(givename));
			GetPlayerName(playerid, admname, sizeof(admname));
			format(string, sizeof(string), "������������� %s �������� ��� �� �����.", admname);
			format(string2, sizeof(string2), "�� ��������� %s �� �����.", givename);
			SCM(playerid, -1, string2);
			SCM(params[0], -1, string);
		}
	}
	else return 1;
	return 1;
}
CMD:spawn(playerid)
{
    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
    if(HitDefTime[playerid] == 1) return SCM(playerid, COLOR_ERROR, "��� �������� ����, ��������� 30 ������ ����� ���������� �����");
	SpawnPlayer(playerid);
	return 1;
}
CMD:a(playerid, params[])
{
        if(PlayerInfo[playerid][pAdmin] >= 1)
        {
            if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
            if(sscanf(params, "s", params[0])) return SCM(playerid, COLOR_LGREEN, "������� /a [���������]");
            new string[128];
            format(string,sizeof(string),"[A] %s[%d]: %s", GN(playerid), playerid, params[0]);
            AdmChat(COLOR_YELLOW, string);
        }
        return 1;
}
CMD:spawncars(playerid)
{
	if(PlayerInfo[playerid][pAdmin] > 2)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
		for(new c=0; c<MAX_VEHICLES; c++)
	 	{
	  		if(!IsVehicleOccupied(c))
	    	{
	     		SetVehicleToRespawn(c);
	       	}
		}
		new sendername[MAX_PLAYER_NAME], string[124];
	 	GetPlayerName(playerid,sendername,sizeof(sendername));
	  	format(string,sizeof(string),"[A] %s[%d] ������ ������� �����.",sendername, playerid);
	   	AdmChat(COLOR_GRAY,string);
	}
   	else return 1;
	return 1;
}
CMD:veh(playerid,params[])
{
    if(PlayerInfo[playerid][pAdmin] > 2)
    {
	    new string[145];
	    new Float:pX,Float:pY,Float:pZ;
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	    if(sscanf(params, "ddd", params[0],params[1],params[2])) return SendClientMessage(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/veh [id ������] [���� 1] [���� 2]");
	    {
	        if(GetPlayerVirtualWorld(playerid) != 0) return SCM(playerid, COLOR_ERROR, "���������� ��������� � ���� 0, /world 0.");
	        if(params[0] > 611 || params[0] < 400) return SendClientMessage(playerid, COLOR_ERROR, "ID ���������� �� 400 �� 611!");
	        if(params[1] > 126 || params[1] < 0 || params[2] > 126 || params[2] < 0) return SendClientMessage(playerid, COLOR_ERROR, "ID ����� �� 0 �� 126!");
	        GetPlayerPos(playerid,pX,pY,pZ);
	        format(string,sizeof(string),"[A] %s[%d] ������ ��������� ID: %d.", GN(playerid), playerid,params[0],VehID[playerid]);
	        AdmChat(COLOR_GRAY,string);
	        ChangeVehicleColor(CreateVehicle(params[0],pX+2,pY,pZ,0.0,1,1,0,0),params[1],params[2]);
	    }
	}
	else return 1;
    return 1;
}
CMD:delveh(playerid)
{
    if(PlayerInfo[playerid][pAdmin] > 2)
    {
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	    {
	        if(GetPlayerVehicleID(playerid) == CarID[playerid]) return SendClientMessage(playerid,-1,"������� /delveh");
	        DestroyVehicle(GetPlayerVehicleID(playerid));
	        SendClientMessage(playerid,-1,"������ �������!");
	    }
	    else SendClientMessage(playerid,-1," �� �� �� ����� ������!");
	}
	else return 1;
    return 1;
}
CMD:weather(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 3)
	{
		if(sscanf(params, "i", params[0])) return SCM(playerid, COLOR_WHITE, "�������: /setweather [id ������]");
		if(params[0] < 0 || params[0] > 45) return SCM(playerid, COLOR_ERROR, "ID ������ �� ����� ���� ������ 0 ��� ������ 45!");
		SetWeather(params[0]);
		new string[100];
		f(string, sizeof(string), "[A] %s[%d] ��������� ������ �����: %d",GN(playerid),playerid, params[0]);
		AdmChat(COLOR_GRAY, string);
	}
	else return 1;
	return 1;
}
CMD:time(playerid, params[])
{
 	if(PlayerInfo[playerid][pAdmin] > 3)
	{
		if(sscanf(params, "i", params[0])) return SCM(playerid, COLOR_WHITE, "�������: /settime [����� �����]");
		if(params[0] < 0 || params[0] > 23) return SCM(playerid, COLOR_GREY, "����� ����� �� ����� ���� ������ 0 ��� ������ 23!");
		SetWorldTime(params[0]);
		new string[100];
		f("����� ����� ������������ �� %d:00", params[0]);
		SCM(playerid, -1, string);
	}
	else return 1;
	return 1;
}
CMD:pack(playerid)
{
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	SPD(playerid, D_PACK, DLIST, "����� ������ - ���� 1", "�������� � ����������\nDesert Eagle\nShotgun (1 LVL)\nM4 (2 LVL)\nCountry Rifle (4 LVL)\nSniper Rifle (7 LVL)", "�������", "������");
	return 1;
}
CMD:mypack(playerid)
{
	new string[248];
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	f("{FFFFFF}���� ������: %d\n���� ������: %d\n\n23 - �������� � ����������\n24 - Desert Eagle\n25 - Shotgun\n31 - M4\n33 - Country Rifle\n34 - Sniper Rifle", gGun1[playerid], gGun2[playerid]);
	SPD(playerid, D_PACK+10, DBOX, "��� ����� ������", string, "�������", "");
	return 1;
}
CMD:makeadmin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 4)
	{
	    if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid, -1, "�� �� ������������.");
		if(sscanf(params,"ud",params[0],params[1])) return SCM(playerid, COLOR_LGREEN, "������� /makeadmin [id] [1-5]");
		if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_LGREEN, "����� �� � ����.");
		if(params[1] > 5 || params[1] < 1) return SCM(playerid, COLOR_LGREEN, "������� �������������� �� ����� ���� ������ 1 � ������ 5");
		{
		    PlayerInfo[params[0]][pAdmin] = params[1];
		    new string[120];
		    new name2[MAX_PLAYER_NAME];
		    GetPlayerName(playerid, name2, sizeof(name2));
			format(string, sizeof(string), "������������� %s �������� ��� ��������������� %d ������.", name2, params[1]);
			SCM(params[0], COLOR_YELLOW, string);
		    new string2[120];
		    new name[MAX_PLAYER_NAME];
		    GetPlayerName(params[0], name, sizeof(name));
			format(string2, sizeof(string2), "�� ��������� %s [%d] ��������������� %d ������.", name, params[0], params[1]);
			SCM(playerid, COLOR_YELLOW, string2);
		}
	}
	else return 1;
	return 1;
}
CMD:get(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 0)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
		if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/get [id]");
		if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
		if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
		new Float:hp, Float:arm, string[1024], ip[43];
		GetPlayerHealth(params[0], hp);
		GetPlayerArmour(params[0], arm);
		GetPlayerIp(params[0], ip, sizeof(ip));
		f("{FFFFFF}��������: %.1f\n�����: %.1f\n�� ����: %d\n����������� ���: %d\nIP: %s\nLevel: %d\nKills: %d\nDeath: %d", hp, arm, PlayerDeathMatch[params[0]], GetPlayerVirtualWorld(params[0]), ip, PlayerInfo[params[0]][pLevel], GetPlayerScore(params[0]), PlayerInfo[params[0]][pDeath]);
		SPD(playerid, stats, DBOX, GN(params[0]), string, "�������", "");
	}
	else
	{
	    return 1;
	}
	return 1;
}
CMD:getstat(playerid, params[]){
	return cmd_get(playerid, params);}
CMD:removeadmin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 4)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
		if(sscanf(params,"us",params[0],params[1])) return SCM(playerid, COLOR_LGREEN, "������� /removeadmin [id] [reason]");
		if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
		if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_LGREEN, "����� �� � ����.");
		if(PlayerInfo[params[0]][pAdmin] == 6) return SCM(playerid, COLOR_ERROR, "������� ���������� ��� ������ ����������");
		{
		    PlayerInfo[params[0]][pAdmin] = 0;
			new string[120];
			new name[MAX_PLAYER_NAME];
			GetPlayerName(params[0], name, sizeof(name));
			format(string, sizeof(string), "�� ����� %s � ��������� ��������������, �� �������: %s", name, params[1]);
			SCM(playerid, COLOR_YELLOW, string);
			new string2[120];
			new name2[MAX_PLAYER_NAME];
			GetPlayerName(playerid, name2, sizeof(name2));
			format(string2, sizeof(string2), "������������� %s ���� ��� � ��������� ��������������, �� �������: %s", name2, params[1]);
			SCM(params[0], COLOR_YELLOW, string2);
		}
	}
	else return 1;
	return 1;
}
CMD:admins(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] > 0)
    {
		ShowAList(playerid);
    }
    else return SCM(playerid, COLOR_WHITE, "������� ���� ��� ������������� ������ ��� �������������.");
	return 1;
}
CMD:goto(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 1)
	{
	    if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid, -1, "�� �� ������������.");
	    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/goto [id]");
	    if(params[0] == playerid) return SCM(playerid, -1, "�� ������� ���� ID");
	    if(!IsPlayerConnected(params[0])) return SCM(playerid, -1, "����� �� ������");
	    if(params[0] > 1000 || params[0] < 0) return SCM(playerid, -1, "�������� ID.");
	    new Float:gx, Float:gy, Float:gz;
	    GetPlayerPos(params[0], gx, gy, gz);
	    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(params[0]));
	    SetPlayerInterior(playerid, GetPlayerInterior(params[0]));
	    SetPlayerPos(playerid, gx+1, gy, gz);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(params[0], name, sizeof(name));
		new string[124];
		format(string, sizeof(string), "�� ����������������� � ������ %s[%d]", name, params[0]);
		SCM(playerid, -1, string);
	}
	else return 1;
	return 1;
}
CMD:gethere(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 3)
	{
	    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/gethere [id]");
	    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, -1, " ����� �� � ����!");
	    if(params[0] == playerid) return SCM(playerid, -1, "�� ������� ���� ID");
        if(PlayerInfo[params[0]][pLockTP] == 1) return SCM(playerid, -1, "�����������: ����� �������� ������������ � ����.");
	    new Float:gx, Float:gy, Float:gz;
	    GetPlayerPos(playerid, gx, gy, gz);
	    SetPlayerVirtualWorld(params[0], GetPlayerVirtualWorld(playerid));
	    SetPlayerInterior(params[0], GetPlayerInterior(playerid));
	    SetPlayerPos(params[0], gx+1, gy, gz);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(params[0], name, sizeof(name));
		new string[124];
		format(string, sizeof(string), "�� ��������������� � ���� %s[%d]", name, params[0]);
		SCM(playerid, -1, string);
		new admname[MAX_PLAYER_NAME];
		GetPlayerName(playerid, admname, sizeof(admname));
		new string1[124];
		format(string1, sizeof(string1), "������������� %s[%d] �������������� ��� � ����.", admname, playerid);
		SCM(params[0], -1, string1);
	}
	else return 1;
	return 1;
}
CMD:jetpack(playerid,params[])
{
	if(PlayerInfo[playerid][pAdmin] > 0)
	{
	    new string[124];
		if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������.");
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USEJETPACK);
		f("[A] %s[%d] ������ JetPack.", GN(playerid), playerid);
		AdmChat(COLOR_GRAY, string);
	}
	else return 1;
	return 1;
}
CMD:restart(playerid)
{
    if(PlayerInfo[playerid][pAdmin] > 5)
    {
		SetTimer("RestartTimer", 1000*30, false);
		new string[124], admname[MAX_PLAYER_NAME];
		GetPlayerName(playerid, admname, sizeof(admname));
		format(string, sizeof(string), "[A] %s[%d] �������� �������������� ������� �������.", admname, playerid);
		AdmChat(COLOR_GRAY, string);
		SCMTA(COLOR_LIGHTRED, "���������! ����� 30 ������ ����� ������� �������, ���������� ����� � ������� ��������������.");
    }
}
CMD:pm(playerid, params[])
{
	new string[144];
	if(PlayerInfo[playerid][pAdmin] > 0)
	{
	    if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	    if(sscanf(params, "ds", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������:{FFFFFF} /pm [id] [���������]");
		if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������");
		if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
		f("[PM] %s � %s [%d]: %s", GN(playerid), GN(params[0]), params[0], params[1]);
		AdmChat(COLOR_GREY, string);
		SCM(params[0], COLOR_YELLOW, string);
		WriteLog("pm", string);
	}
	else return 1;
	return 1;
}
CMD:o(playerid, params[])
{
	new string[144];
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������");
	if(PlayerInfo[playerid][pMute] == 1) return SCM(playerid, COLOR_ERROR, "� ��� ���. (��� ��� ������ ���������� � ������������� /mm - ����� � ��������������)");
	if(sscanf(params, "s", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/o [���������]");
	f("<< [�] %s [%d]: %s >>", GN(playerid), playerid, params[0]);
	SCMTA(-1, string);
	return 1;
}
CMD:dellaccount(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 5)
	{
	    if(sscanf(params, "s", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/dellaccount [���]");
	    static const fmt_str[] = "Accounts/%s.ini";
	    new str[sizeof(fmt_str) - 2 + MAX_PLAYER_NAME];
	    format(str, sizeof(str), fmt_str, params);
	    if(!fexist(str)) return SendClientMessage(playerid, -1, "������ �������� �� ����������.");
	    fremove(str);
	    new string[144];
	    f("[A] ���������� %s ������ ������� %s, �� ��������� ������ ��������� ������ �������", GN(playerid), params[0]);
	    AdmChat(COLOR_GRAY, string);
	}
	else return 1;
	return 1;
}
CMD:agun(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 4)
	{
	    if(sscanf(params, "udd", params[0], params[1], params[2])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/agun [id] [������] [�������]");
	    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������.");
	    if(PlayerInfo[params[0]][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������.");
	    if(params[1] > 46 || params[1] < 1) return SCM(playerid, COLOR_ERROR, "�������� ID ������, �������� �� 1 �� 46.");
 		if(params[2] > 9999 || params[2] < 1) return SCM(playerid, COLOR_ERROR, "�������� ����������� ������, �������� �� 1 �� 9999.");
		GivePlayerWeapon(params[0], params[1], params[2]);
		new name[MAX_PLAYER_NAME], name2[MAX_PLAYER_NAME];
		GetPlayerName(params[0], name, sizeof(name));
		GetPlayerName(playerid, name2, sizeof(name2));
		new string[124], gunname[124];
		GetWeaponName(params[1], gunname, sizeof(gunname));
		format(string, sizeof(string), "[A] %s[%d] ����� %s(%d ������) ������ %s[%d]", name2, playerid, gunname, params[2], name, params[0]);
		AdmChat(COLOR_GRAY, string);
	}
	else return 1;
	return 1;
}
CMD:kick(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] == 0) return 1;
	if(sscanf(params, "us", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/kick [id] [�������]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������.");
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
	new string[144], name2[MAX_PLAYER_NAME], name[MAX_PLAYER_NAME];
	GetPlayerName(params[0], name2, sizeof(name2));
	GetPlayerName(playerid, name, sizeof(name));
	new title[42];
	if(PlayerInfo[playerid][pAdmin] == 1) title = "���������";
	else if(PlayerInfo[playerid][pAdmin] == 2) title = "������� ���������";
	else if(PlayerInfo[playerid][pAdmin] == 3) title = "�������������";
	else if(PlayerInfo[playerid][pAdmin] == 4) title = "������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 5) title = "������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 6) title = "����������";
	format(string, sizeof(string), "%s %s �������� �� ������� ������ %s, �� �������: %s",title, name, name2, params[1]);
	SendClientMessageToAll(COLOR_LIGHTRED, string);
	GKick(params[0], 1000);
	WriteLog("kick", string);
	return 1;
}
CMD:ban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return 1;
	if(sscanf(params, "us", params[0], params[1])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/ban [id] [�������]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_ERROR, "����� �� ������.");
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "����� �� �������������");
	new string[144], name2[MAX_PLAYER_NAME], name[MAX_PLAYER_NAME];
	GetPlayerName(params[0], name2, sizeof(name2));
	GetPlayerName(playerid, name, sizeof(name));
	PlayerInfo[params[0]][pBanned] = 1;
	new title[42];
	if(PlayerInfo[playerid][pAdmin] == 1) title = "���������";
	else if(PlayerInfo[playerid][pAdmin] == 2) title = "������� ���������";
	else if(PlayerInfo[playerid][pAdmin] == 3) title = "�������������";
	else if(PlayerInfo[playerid][pAdmin] == 4) title = "������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 5) title = "������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 6) title = "����������";
	format(string, sizeof(string), "%s %s �������� �� ������� � ������� ������ %s, �� �������: %s",title, name, name2, params[1]);
	SendClientMessageToAll(COLOR_LIGHTRED, string);
	GKick(params[0], 1000);
	WriteLog("ban", string);
	return 1;
}

CMD:skick(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return 1;
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/skick [id]");
	if(!IsPlayerConnected(params[0])) return SCM(playerid, -1, " ������ �� ��� ������!");
	new string[124], name2[MAX_PLAYER_NAME], name[MAX_PLAYER_NAME];
	GetPlayerName(params[0], name2, sizeof(name2));
	GetPlayerName(playerid, name, sizeof(name));
	format(string, sizeof(string), "[A] %s ������ ������ %s ����� �����.", name, name2);
	AdmChat(COLOR_GRAY, string);
	GKick(params[0], 1000);
	WriteLog("skick", string);
	return 1;
}
CMD:mm(playerid)
{
	ShowMenu(playerid);
	return 1;
}
CMD:menu(playerid){
	return cmd_mm(playerid);}
CMD:mn(playerid){
	return cmd_mm(playerid);}

CMD:exit(playerid)
{
	if(PlayerDeathMatch[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� �� ���������� �� �� ����.");
	SCM(playerid, COLOR_YELLOW, "  �� ����� � �� ����.");
	PlayerDeathMatch[playerid] = 0;
	SetPlayerVirtualWorld(playerid, 0);
	PlayerKill[playerid] = 0;
	SpawnPlayer(playerid);
	return 1;
}
CMD:dm(playerid, params[])
{
	new string[124];
	if(TDM == 1) return SCM(playerid, COLOR_ERROR, "���������� �� ����� ���������� TDM");
	if(gGun1[playerid] == 0 || gGun2[playerid] == 0) return SCM(playerid, COLOR_ERROR, "�� �� ������� ����� ������ {FFFFFF}/pack");
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_LGREEN, "�����������: {FFFFFF}/dm [����� ����]");
	if(PlayerDeathMatch[playerid] > 0) return SCM(playerid, COLOR_YELLOW, "�� ��� ���������� �� �����-�� �������, ����� �� �������� ������� {00FF00}/exit");
	if(params[0] > 3 || params[0] < 1) return SCM(playerid, COLOR_LGREEN, "������������ ����� ����.");
	if(params[0] == 1)
	{
		PlayerDeathMatch[playerid] = 1;
		SPD(playerid, selectgun, DBOX, "�������������", "{FFFFFF}��?", "��", "");
		f("����� %s[%d] ������������ �� DM 1 - (/dm 1)", GN(playerid), playerid);
	}
	if(params[0] == 2)
	{
        PlayerDeathMatch[playerid] = 2;
        SPD(playerid, selectgun, DBOX, "�������������", "{FFFFFF}��?", "��", "");
        f("����� %s[%d] ������������ �� DM 2 - (/dm 2)", GN(playerid), playerid);
	}
	if(params[0] == 3)
	{
        PlayerDeathMatch[playerid] = 3;
        SPD(playerid, selectgun, DBOX, "�������������", "{FFFFFF}��?", "��", "");
        f("����� %s[%d] ������������ �� DM 3 - (/dm 3)", GN(playerid), playerid);
	}
	SCM(playerid, COLOR_ERROR, "����� ����� � �� ����, �������: /exit");
	SCMTA(COLOR_SALAT, string);
	return 1;
}

public Update(playerid)
{
        new hour,minute,second;
        gettime(hour,minute,second);
        if(second >= 0 || second <= 60)
		{
  			if(PlayerTrainZone[playerid] == true)
     		{
			                if(!IsPlayerInRangeOfPoint(playerid, 50.0, 1392.6025,-20.8305,1000.9109))
			    			{
			    			    new str[128];
			    			    SpawnPlayer(playerid);
					    	    SCM(playerid, 0xFFFF00, "{FFFF00}[����������] {FFFFFF}�� �������� ���� ����������. ���������� ���������.");
					    	    format(str,sizeof(str),"{FFFF00}[����������] {FFFFFF}����� ����������: %d$", PLAYER_TRAIN_ZP[playerid]);
					    	    SCM(playerid, 0xFFFF00, str);
								PlayerTrainZone[playerid] = false;
								ResetPlayerWeapons(playerid);
								DisablePlayerCheckpoint(playerid);
			    			}
		    }
	        if(PlayerDeathMatch[playerid] == 1)
	        {
	                if(!IsPlayerInRangeOfPoint(playerid, 90.0, -399.5983,2225.1563,42.4297))
	    			{
							 	switch(random(8))
								{
								    case 0: SetPlayerPos(playerid, -445.4210,2223.1973,42.4297);
								    case 1: SetPlayerPos(playerid, -439.5626,2250.6855,42.4297);
								    case 2: SetPlayerPos(playerid, -411.5861,2264.4600,42.3509);
								    case 3: SetPlayerPos(playerid, -410.4398,2213.3442,42.4297);
								    case 4: SetPlayerPos(playerid, -392.0173,2195.2095,42.4164);
								    case 5: SetPlayerPos(playerid, -350.7846,2209.3391,42.4844);
								    case 6: SetPlayerPos(playerid, -350.9970,2246.5398,42.4844);
								    case 7: SetPlayerPos(playerid, -372.3033,2269.7151,42.0940);
								}
	    			}
	        }
	        if(PlayerDeathMatch[playerid] == 2)
	        {
	                if(!IsPlayerInRangeOfPoint(playerid, 90.0, 2620.3906,2744.8208,25.8049))
	    			{
	    			    	 	switch(random(8))
								{
								    case 0: SetPlayerPos(playerid, 2605.7703,2707.6506,36.1997);
								    case 1: SetPlayerPos(playerid, 2631.9253,2720.9282,36.1601);
								    case 2: SetPlayerPos(playerid, 2631.6123,2717.2773,33.9783);
								    case 3: SetPlayerPos(playerid, 2615.8176,2706.0972,25.8222);
								    case 4: SetPlayerPos(playerid, 2605.1643,2731.4534,23.8222);
								    case 5: SetPlayerPos(playerid, 2628.9973,2752.6213,23.8222);
								    case 6: SetPlayerPos(playerid, 2641.7649,2781.9226,23.8222);
								    case 7: SetPlayerPos(playerid, 2595.3110,2775.3281,23.8222);
								}
	    			}
	        }
	        if(PlayerDeathMatch[playerid] == 3)
	        {
	                if(!IsPlayerInRangeOfPoint(playerid, 90.0, 1663.4873,2351.1042,18.1561))
	    			{
	    			    	 	switch(random(8))
								{
								    case 0: SetPlayerPos(playerid, 1609.2114,2324.8989,10.8203);
								    case 1: SetPlayerPos(playerid, 1649.6317,2371.6128,10.8203);
								    case 2: SetPlayerPos(playerid, 1674.8348,2398.4629,10.8203);
								    case 3: SetPlayerPos(playerid, 1695.1720,2354.2163,10.8203);
								    case 4: SetPlayerPos(playerid, 1676.7113,2302.2229,10.8203);
								    case 5: SetPlayerPos(playerid, 1702.4471,2292.4709,10.8203);
								    case 6: SetPlayerPos(playerid, 1697.0825,2334.7505,10.8203);
								    case 7: SetPlayerPos(playerid, 1654.9846,2323.5359,21.1676);
								    case 8: SetPlayerPos(playerid, 1665.4963,2357.3474,21.3845);
								    case 9: SetPlayerPos(playerid, 1670.9081,2302.8088,21.3845);
								    case 10: SetPlayerPos(playerid, 1654.7216,2380.1387,21.3845);
								    case 11: SetPlayerPos(playerid, 1670.8424,2388.4595,21.3845);
								}
	    			}
	        }
		}
        return 1;
}

public RespCar()
{
	for(new c=0; c<MAX_VEHICLES; c++)
	{
		if(!IsVehicleOccupied(c))
 		{
 			SetVehicleToRespawn(c);
 			SetVehicleToRespawn(c);
 			SetVehicleToRespawn(c);
       	}
	}
	return 1;
}

// �����
stock ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
	if(IsPlayerConnected(playerid))
	{
		new Float: posx;
		new Float: posy;
		new Float: posz;
		new Float: oldposx;
		new Float: oldposy;
		new Float: oldposz;
		new Float: tempposx;
		new Float: tempposy;
		new Float: tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		foreach(new i: Player)
		{
			if(IsPlayerConnected(i))
			{
				if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
				{
					GetPlayerPos(i, posx, posy, posz);
					tempposx = (oldposx -posx);
					tempposy = (oldposy -posy);
					tempposz = (oldposz -posz);
					if(((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) SendClientMessage(i, col1, string);
					else if(((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))) SendClientMessage(i, col2, string);
					else if(((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))) SendClientMessage(i, col3, string);
					else if(((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))) SendClientMessage(i, col4, string);
					else if(((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) SendClientMessage(i, col5, string);
				}
				else SendClientMessage(i, col1, string);
			}
		}
	}
	return 1;
}
//
stock Clear(playerid)
{
	Login[playerid] = 0;
}
// ����� �����
stock AdmChat(color, const string[])
{
        foreach(new i: Player) if(PlayerInfo[i][pAdmin] > 0) SCM(i, color, string);
}

public KickTimer(playerid) return GKick(playerid);

stock GKick(playerid, time = 1000)
{
    if(GetPVarInt(playerid, "Kick") == -1) Kick(playerid);
    else if(!GetPVarInt(playerid, "Kick")) SetPVarInt(playerid, "Kick", SetTimerEx("KickTimer", time, 0, "d", playerid));
    else
    {
        KillTimer(GetPVarInt(playerid, "Kick"));
        SetPVarInt(playerid, "Kick", -1);
        GKick(playerid);
    }
    return 1;
}

stock WriteLog(namelog[],string[])
{
    new text[256],log[50],computation1, computation2, computation3,File:LogFile,i;
    gettime(computation1, computation2, computation3);
    format(text, sizeof(text), "[%02d:%02d:%02d]%s\r\n",computation1,computation2,computation3,string);
    getdate(computation1, computation2, computation3);
    format(log,sizeof(log),"logs/%s/[%02d][%02d]%s.log",namelog,computation3,computation2,namelog);
    LogFile = fopen(log, io_append);
    while (text[i] != EOS)
    {
        fputchar(LogFile, text[i], false);
        i++;
    }
    fclose(LogFile);
}

stock GetPlayerID(string[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i))continue;
        if(!strcmp(PI[i][pName], string, true)) return i;
    }
    return INVALID_PLAYER_ID;
}

stock ReadOneString(file[],tostring[])
{
	if(!fexist(file)) return -1; /* ��������� ������� ����� file, ���� �� �� ���������� �� ���������� ���������� ������� � ���������� �������� -1 */

	new File:opnfile; // ������ �������� ����������
	opnfile=fopen(file,io_read); /* ��������� ���� file � ������������ ������ � ���������� ��� ������������� � opnfile */
	fread(opnfile,tostring); // ������ ������ ������ �� ����� � ���������� � � tostring
	fclose(opnfile); // ��������� ������ � ������
	return 1; // ���������� 1 ����� ����� ��� �� ������ �������
}

stock WriteOneString(tofile[],string[])
{
	new File:opnfile; // ������ �������� ����������
	opnfile=fopen(tofile,io_append); /* ��������� ���� � ���������� io_append, � ������ ������ �� ������ ����� �������� */
	fwrite(opnfile,string); // ���������� � ���� ������ string
	fclose(opnfile);// ��������� ������ � ������
	return 1; // ���������� 1 ����� ����� ��� �� ������ �������
}

stock LoadTextDrawForPlayer(playerid)
{
	FPS[playerid] = TextDrawCreate(10.000000,430.000000,"_");
 	TextDrawAlignment(FPS[playerid],0);
  	TextDrawBackgroundColor(FPS[playerid],0x000000ff);
   	TextDrawFont(FPS[playerid],1);
    TextDrawLetterSize(FPS[playerid],0.240000,0.6);
    TextDrawColor(FPS[playerid],0xffffffff);
    TextDrawSetOutline(FPS[playerid],1);
    TextDrawSetProportional(FPS[playerid],1);
    TextDrawSetShadow(FPS[playerid],1);
    TextDrawShowForPlayer(playerid, FPS[playerid]);

	/*Stats[playerid] = TextDrawCreate(502.531158, 96.533302, "_");
	TextDrawLetterSize(Stats[playerid], 0.235080, 1.039999);
	TextDrawAlignment(Stats[playerid], 1);
	TextDrawColor(Stats[playerid], -1);
	TextDrawSetShadow(Stats[playerid], 0);
	TextDrawSetOutline(Stats[playerid], 1);
	TextDrawBackgroundColor(Stats[playerid], 255);
	TextDrawFont(Stats[playerid], 1);
	TextDrawSetProportional(Stats[playerid], 1);
	TextDrawSetShadow(Stats[playerid], 0);
	TextDrawShowForPlayer(playerid, Stats[playerid]);*/

	Stats[playerid] = TextDrawCreate(2.796494, 190.583282, "_");
	TextDrawLetterSize(Stats[playerid], 0.283805, 1.162500);
	TextDrawAlignment(Stats[playerid], 1);
	TextDrawColor(Stats[playerid], -5963521);
	TextDrawSetShadow(Stats[playerid], 0);
	TextDrawSetOutline(Stats[playerid], 0);
	TextDrawBackgroundColor(Stats[playerid], 255);
	TextDrawFont(Stats[playerid], 1);
	TextDrawSetProportional(Stats[playerid], 1);
	TextDrawSetShadow(Stats[playerid], 0);
	TextDrawShowForPlayer(playerid, Stats[playerid]);

	/*score[playerid] = TextDrawCreate(509.736450, 111.833290, "_");
	TextDrawLetterSize(score[playerid], 0.200409, 1.156666);
	TextDrawAlignment(score[playerid], 1);
	TextDrawColor(score[playerid], -1378294017);
	TextDrawSetShadow(score[playerid], 0);
	TextDrawSetOutline(score[playerid], 1);
	TextDrawBackgroundColor(score[playerid], 255);
	TextDrawFont(score[playerid], 3);
	TextDrawSetProportional(score[playerid], 1);
	TextDrawSetShadow(score[playerid], 0);
	TextDrawShowForPlayer(playerid, score[playerid]);*/

	moneyplus = TextDrawCreate(566.772705, 56.750041, "+500");
	TextDrawLetterSize(moneyplus, 0.293645, 1.092499);
	TextDrawAlignment(moneyplus, 1);
	TextDrawColor(moneyplus, 16711935);
	TextDrawSetShadow(moneyplus, 1);
	TextDrawSetOutline(moneyplus, 0);
	TextDrawBackgroundColor(moneyplus, 255);
	TextDrawFont(moneyplus, 3);
	TextDrawSetProportional(moneyplus, 1);
	TextDrawSetShadow(moneyplus, 1);

	moneyminus = TextDrawCreate(566.772705, 56.750041, "-200");
	TextDrawLetterSize(moneyminus, 0.293645, 1.092499);
	TextDrawAlignment(moneyminus, 1);
	TextDrawColor(moneyminus, -16776961);
	TextDrawSetShadow(moneyminus, 1);
	TextDrawSetOutline(moneyminus, 0);
	TextDrawBackgroundColor(moneyminus, 255);
	TextDrawFont(moneyminus, 3);
	TextDrawSetProportional(moneyminus, 1);
	TextDrawSetShadow(moneyminus, 1);

	monster[0] = TextDrawCreate(276.412841, 104.833328, "MONSTER~n~");
	TextDrawLetterSize(monster[0], 0.527437, 2.492501);
	TextDrawAlignment(monster[0], 1);
	TextDrawColor(monster[0], -16776961);
	TextDrawSetShadow(monster[0], 1);
	TextDrawSetOutline(monster[0], 0);
	TextDrawBackgroundColor(monster[0], 255);
	TextDrawFont(monster[0], 1);
	TextDrawSetProportional(monster[0], 1);
	TextDrawSetShadow(monster[0], 1);

	monster[1] = TextDrawCreate(276.712646, 105.616653, "MONSTER~n~");
	TextDrawLetterSize(monster[1], 0.527437, 2.492501);
	TextDrawAlignment(monster[1], 1);
	TextDrawColor(monster[1], -65281);
	TextDrawSetShadow(monster[1], 1);
	TextDrawSetOutline(monster[1], 0);
	TextDrawBackgroundColor(monster[1], 255);
	TextDrawFont(monster[1], 1);
	TextDrawSetProportional(monster[1], 1);
	TextDrawSetShadow(monster[1], 1);

	score[0][playerid] = TextDrawCreate(2.796494, 198.749984, "_");
	TextDrawLetterSize(score[0][playerid], 0.283806, 1.162500);
	TextDrawAlignment(score[0][playerid], 1);
	TextDrawColor(score[0][playerid], -1061109505);
	TextDrawSetShadow(score[0][playerid], 0);
	TextDrawSetOutline(score[0][playerid], 0);
	TextDrawBackgroundColor(score[0][playerid], 255);
	TextDrawFont(score[0][playerid], 1);
	TextDrawSetProportional(score[0][playerid], 1);
	TextDrawSetShadow(score[0][playerid], 0);
	TextDrawShowForPlayer(playerid, score[0][playerid]);

	score[1][playerid] = TextDrawCreate(2.796494, 207.550521, "_");
	TextDrawLetterSize(score[1][playerid], 0.283806, 1.162500);
	TextDrawAlignment(score[1][playerid], 1);
	TextDrawColor(score[1][playerid], -1061109505);
	TextDrawSetShadow(score[1][playerid], 0);
	TextDrawSetOutline(score[1][playerid], 0);
	TextDrawBackgroundColor(score[1][playerid], 255);
	TextDrawFont(score[1][playerid], 1);
	TextDrawSetProportional(score[1][playerid], 1);
	TextDrawSetShadow(score[1][playerid], 0);
	TextDrawShowForPlayer(playerid, score[1][playerid]);

	score[2][playerid] = TextDrawCreate(2.796494, 216.451065, "_");
	TextDrawLetterSize(score[2][playerid], 0.283806, 1.162500);
	TextDrawAlignment(score[2][playerid], 1);
	TextDrawColor(score[2][playerid], -1061109505);
	TextDrawSetShadow(score[2][playerid], 0);
	TextDrawSetOutline(score[2][playerid], 0);
	TextDrawBackgroundColor(score[2][playerid], 255);
	TextDrawFont(score[2][playerid], 1);
	TextDrawSetProportional(score[2][playerid], 1);
	TextDrawSetShadow(score[2][playerid], 0);
	TextDrawShowForPlayer(playerid, score[2][playerid]);
	
	timertdm[0] = TextDrawCreate(350.906921, 409.916931, "_");
	TextDrawLetterSize(timertdm[0], 0.463250, 2.253333);
	TextDrawAlignment(timertdm[0], 3);
	TextDrawColor(timertdm[0], -1);
	TextDrawSetShadow(timertdm[0], 0);
	TextDrawSetOutline(timertdm[0], 1);
	TextDrawBackgroundColor(timertdm[0], 255);
	TextDrawFont(timertdm[0], 1);
	TextDrawSetProportional(timertdm[0], 1);
	TextDrawSetShadow(timertdm[0], 0);

	timertdm[1] = TextDrawCreate(250.175949, 421.000000, "DEFINE");
	TextDrawLetterSize(timertdm[1], 0.321288, 1.541666);
	TextDrawAlignment(timertdm[1], 1);
	TextDrawColor(timertdm[1], -16711681);
	TextDrawSetShadow(timertdm[1], 0);
	TextDrawSetOutline(timertdm[1], 1);
	TextDrawBackgroundColor(timertdm[1], 255);
	TextDrawFont(timertdm[1], 1);
	TextDrawSetProportional(timertdm[1], 1);
	TextDrawSetShadow(timertdm[1], 0);

	timertdm[2] = TextDrawCreate(350.613708, 420.516662, "ATTACK");
	TextDrawLetterSize(timertdm[2], 0.321288, 1.541666);
	TextDrawAlignment(timertdm[2], 1);
	TextDrawColor(timertdm[2], -5963521);
	TextDrawSetShadow(timertdm[2], 0);
	TextDrawSetOutline(timertdm[2], 1);
	TextDrawBackgroundColor(timertdm[2], 255);
	TextDrawFont(timertdm[2], 1);
	TextDrawSetProportional(timertdm[2], 1);
	TextDrawSetShadow(timertdm[2], 0);

	timertdm[3] = TextDrawCreate(308.272064, 428.000061, "_");
	TextDrawLetterSize(timertdm[3], 0.400000, 1.600000);
	TextDrawAlignment(timertdm[3], 1);
	TextDrawColor(timertdm[3], -1);
	TextDrawSetShadow(timertdm[3], 0);
	TextDrawSetOutline(timertdm[3], 1);
	TextDrawBackgroundColor(timertdm[3], 255);
	TextDrawFont(timertdm[3], 1);
	TextDrawSetProportional(timertdm[3], 1);
	TextDrawSetShadow(timertdm[3], 0);
}

stock LoadTextDraw()
{
	logo[0] = TextDrawCreate(136.793563, 337.000061, "~n~The_Green~n~");
	TextDrawLetterSize(logo[0], 0.400000, 1.600000);
	TextDrawAlignment(logo[0], 1);
	TextDrawColor(logo[0], -1378294017);
	TextDrawSetShadow(logo[0], 1);
	TextDrawSetOutline(logo[0], 0);
	TextDrawBackgroundColor(logo[0], 255);
	TextDrawFont(logo[0], 0);
	TextDrawSetProportional(logo[0], 1);
	TextDrawSetShadow(logo[0], 1);

	logo[1] = TextDrawCreate(140.073181, 363.250152, "DeathMatch");
	TextDrawLetterSize(logo[1], 0.620673, 2.550833);
	TextDrawAlignment(logo[1], 1);
	TextDrawColor(logo[1], -1);
	TextDrawSetShadow(logo[1], 1);
	TextDrawSetOutline(logo[1], 0);
	TextDrawBackgroundColor(logo[1], 255);
	TextDrawFont(logo[1], 0);
	TextDrawSetProportional(logo[1], 1);
	TextDrawSetShadow(logo[1], 1);

	welcome[0] = TextDrawCreate(387.452423, 283.516662, "Welcome to");
	TextDrawLetterSize(welcome[0], 1.285973, 4.539996);
	TextDrawAlignment(welcome[0], 3);
	TextDrawColor(welcome[0], -1);
	TextDrawSetShadow(welcome[0], 3);
	TextDrawSetOutline(welcome[0], 0);
	TextDrawBackgroundColor(welcome[0], 255);
	TextDrawFont(welcome[0], 0);
	TextDrawSetProportional(welcome[0], 1);
	TextDrawSetShadow(welcome[0], 3);

	welcome[1] = TextDrawCreate(394.011749, 327.666687, "Green DeathMatch");
	TextDrawLetterSize(welcome[1], 0.466062, 1.786664);
	TextDrawAlignment(welcome[1], 3);
	TextDrawColor(welcome[1], 8388863);
	TextDrawSetShadow(welcome[1], 0);
	TextDrawSetOutline(welcome[1], 2);
	TextDrawBackgroundColor(welcome[1], 255);
	TextDrawFont(welcome[1], 3);
	TextDrawSetProportional(welcome[1], 1);
	TextDrawSetShadow(welcome[1], 0);

	welcome[2] = TextDrawCreate(384.172760, 279.433319, "Welcome to");
	TextDrawLetterSize(welcome[2], 1.285973, 4.539996);
	TextDrawAlignment(welcome[2], 3);
	TextDrawColor(welcome[2], -5963521);
	TextDrawSetShadow(welcome[2], 3);
	TextDrawSetOutline(welcome[2], 0);
	TextDrawBackgroundColor(welcome[2], 255);
	TextDrawFont(welcome[2], 0);
	TextDrawSetProportional(welcome[2], 1);
	TextDrawSetShadow(welcome[2], 3);

	welcome[3] = TextDrawCreate(219.890304, 354.400024, "box");
	TextDrawLetterSize(welcome[3], 0.000000, -0.073206);
	TextDrawTextSize(welcome[3], 400.699981, 0.000000);
	TextDrawAlignment(welcome[3], 1);
	TextDrawColor(welcome[3], -1);
	TextDrawUseBox(welcome[3], 1);
	TextDrawBoxColor(welcome[3], -1378294017);
	TextDrawSetShadow(welcome[3], 0);
	TextDrawSetOutline(welcome[3], 0);
	TextDrawBackgroundColor(welcome[3], 65535);
	TextDrawFont(welcome[3], 1);
	TextDrawSetProportional(welcome[3], 1);
	TextDrawSetShadow(welcome[3], 0);

	welcome[4] = TextDrawCreate(219.890304, 280.295501, "box");
	TextDrawLetterSize(welcome[4], 0.000000, -0.073206);
	TextDrawTextSize(welcome[4], 400.699981, 0.000000);
	TextDrawAlignment(welcome[4], 1);
	TextDrawColor(welcome[4], -1);
	TextDrawUseBox(welcome[4], 1);
	TextDrawBoxColor(welcome[4], -1378294017);
	TextDrawSetShadow(welcome[4], 1);
	TextDrawSetOutline(welcome[4], 2);
	TextDrawBackgroundColor(welcome[4], 255);
	TextDrawFont(welcome[4], 1);
	TextDrawSetProportional(welcome[4], 1);
	TextDrawSetShadow(welcome[4], 1);
	
	IP = TextDrawCreate(122.269378, 325.333496, "_");
	TextDrawLetterSize(IP, 0.184480, 0.970000);
	TextDrawAlignment(IP, 3);
	TextDrawColor(IP, -1);
	TextDrawSetShadow(IP, 0);
	TextDrawSetOutline(IP, 0);
	TextDrawBackgroundColor(IP, 255);
	TextDrawFont(IP, 1);
	TextDrawSetProportional(IP, 1);
	TextDrawSetShadow(IP, 0);
}

stock LoadVehicle()
{
    AddStaticVehicle(487,1544.8619,-1353.1508,329.7258,89.5426,0,0);
}

stock LoadGangZone()
{
	dm1 = GangZoneCreate(-495.708374, 2149.523681, -303.708374, 2301.523681);
	dm2 = GangZoneCreate(2568.149902, 2662.420410, 2680.149902, 2814.420410);
	dm3 = GangZoneCreate(1549.170166, 2279.957519, 1773.170166, 2439.957519);
	tdm1 = GangZoneCreate(2639.915283, -1887.280273, 2831.915283, -1663.280273);
	tdm2 = GangZoneCreate(320.274505, 2394.203613, 456.274505, 2570.203613);
}

stock LoadPickup()
{
	parashut[0] = CreatePickup(1310, 3, 1565.0593,-1359.1481,330.0543,0);
	parashut[1] = CreatePickup(1310, 3, 1562.8062,-1346.4335,330.0507,0);
	parashut[2] = CreatePickup(1310, 3, 1551.6619,-1338.5565,330.0000,0);
	parashut[3] = CreatePickup(1310, 3, 1537.4838,-1338.0909,330.0544,0);
	parashut[4] = CreatePickup(1310, 3, 1526.4983,-1346.1212,330.0574,0);
	parashut[5] = CreatePickup(1310, 3, 1524.1188,-1359.0664,330.0000,0);
	parashut[6] = CreatePickup(1310, 3, 1531.4076,-1369.8879,330.0000,0);
	parashut[7] = CreatePickup(1310, 3, 1544.7446,-1374.5927,330.0589,0);
	parashut[8] = CreatePickup(1310, 3, 1558.1240,-1370.4556,330.0619,0);
	ammoexit = CreatePickup(1235, 3, 315.7947,-143.0751,999.6016,0);
	ammobuy = CreatePickup(2044, 3, 308.5656,-140.8533,999.6016,0);
	ammo[0] = CreatePickup(1239, 3, 2169.5769,-1800.8601,13.3665,0);
	ammo[1] = CreatePickup(1239, 3, 1104.4542,-1383.4785,13.7813,0);
	ammo[2] = CreatePickup(1239, 3, 1331.2258,-1119.4856,24.0375,0);
	ammo[3] = CreatePickup(1239, 3, 1681.0171,-1342.8783,17.5530,0);
	ammo[4] = CreatePickup(1239, 3, 1263.4238,-2028.9175,59.3221,0);
	ammo[5] = CreatePickup(1239, 3, 1969.7012,-1783.4019,13.6320,0);
	ammo[6] = CreatePickup(1239, 3, 807.5547,-1531.9506,13.6744,0);
	healup[0] = CreatePickup(1241, 3, 1172.8567,-1323.3353,15.3997,0);
	healup[1] = CreatePickup(1241, 3, 2034.5220,-1412.1310,16.9922,0);
}

stock LoadDeleteObjects(playerid)
{
	RemoveBuildingForPlayer(playerid, 4580, 1671.5078, -1343.3359, 87.5391, 0.25);
	RemoveBuildingForPlayer(playerid, 4747, 1671.5078, -1343.3359, 87.5391, 0.25);
	RemoveBuildingForPlayer(playerid, 4602, 1671.5078, -1343.3359, 87.5391, 0.25);
	RemoveBuildingForPlayer(playerid, 726, 816.1563, -1530.1094, 10.7422, 0.25);
	RemoveBuildingForPlayer(playerid, 621, 798.0078, -1528.4531, 10.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 799.5625, -1521.5313, 10.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 762, 807.1016, -1527.2188, 15.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 6214, 849.3359, -1490.0625, 15.2031, 0.25);
	RemoveBuildingForPlayer(playerid, 727, 1319.6875, -1112.9063, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 727, 1327.9766, -1124.3438, 21.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 5888, 1202.6719, -1098.0234, 27.5234, 0.25);
}

stock GetPlayerFPS(playerid)
{
        SetPVarInt(playerid, "DrunkL", GetPlayerDrunkLevel(playerid));
        if(GetPVarInt(playerid, "DrunkL") < 100)
        {
                SetPlayerDrunkLevel(playerid, 2000);
    	}
    	else
        {
                if(GetPVarInt(playerid, "LDrunkL") != GetPVarInt(playerid, "DrunkL"))
                {
                SetPVarInt(playerid, "FPS", (GetPVarInt(playerid, "LDrunkL") - GetPVarInt(playerid, "DrunkL")));
                SetPVarInt(playerid, "LDrunkL", GetPVarInt(playerid, "DrunkL"));
                if((GetPVarInt(playerid, "FPS") > 0) && (GetPVarInt(playerid, "FPS") < 256))
                        {
                        return GetPVarInt(playerid, "FPS") - 1;
                }
                }
        }
        return 0;
}

stock SetPlayerAnimation(playerid, index, Float:fDelta = 4.1, loop = 0, lockx = 1, locky = 1, freeze = 0, time = 1000, forcesync = 1) {
        if(IsPlayerConnected(playerid)) {
                if(index > 0 && index < 1813) {
                        new animlib[32], animname[32];
                        GetAnimationName(index, animlib, 32, animname, 32);
                        ApplyAnimation(playerid, animlib, animname, fDelta, loop, lockx, locky, freeze, time, forcesync);
                        return 1;
                }
        }
        return 0;
}

stock SaveGang(playerid)
{
    	new string[64];// ����� � ���� ��� �����
        new playername[MAX_PLAYER_NAME];// ����� ��� ��������� ����� ������
        GetPlayerName(playerid, playername, sizeof(playername));// �������� ��� ������
        format(string, sizeof(string), "Gangs/%s.ini", playername);// ��������� ��� ������, � ���� ��� ����������
        iniFile = ini_openFile(string);// ��������� ���� �� ���� ���� ������� �������.
        ini_setString(iniFile,"Name",Gang[gName]);
        ini_closeFile(iniFile);// ��������� ����
}
stock ShowAList(playerid)
{
        if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "�� �� ������������.");
		new str[256],full = 0;
        SendClientMessage(playerid, 0xFF8C00AA, "������������� � ����:");
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!IsPlayerConnected(i)) continue;
            if(PlayerInfo[i][pAdmin] > 0)
            {
                new admrank[120];
               	if(PlayerInfo[i][pAdmin] == 1){format(admrank, sizeof(admrank),"������: {FFA500}���������");}
                else if(PlayerInfo[i][pAdmin] == 2){format(admrank, sizeof(admrank),"������: {FFA500}��. ���������");}
                else if(PlayerInfo[i][pAdmin] == 3){format(admrank, sizeof(admrank),"������: {9ACD32}�������������");}
                else if(PlayerInfo[i][pAdmin] == 4){format(admrank, sizeof(admrank),"������: {9ACD32}��. �������������");}
                else if(PlayerInfo[i][pAdmin] == 5){format(admrank, sizeof(admrank),"������: {FF0000}������� �������������");}
                else if(PlayerInfo[i][pAdmin] == 6){format(admrank, sizeof(admrank),"������: {FF0000}����������");}
         	  	full++;
                format(str,sizeof(str),"�����: %s [%d] %s\n",PlayerInfo[i][pName],i,admrank);
                SendClientMessage(playerid, COLOR_WHITE, str);
            }
          }
        if(full == 0) SendClientMessage(playerid, COLOR_WHITE, "������������� ��� � ����.");
        return 1;
}
stock ShowWTrain(playerid)
{
    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
    prostt[playerid] = SetTimerEx("prost", 100, 1, "i", playerid);
    SPD(playerid, D_TRAIN+1, DLIST, "�������� ������ ��� ����������", "Desert Eagle\nShotgun\nM4\nRifle\nSniper", "�������", "�����");
}
forward prost(playerid);
public prost(playerid)
{
	if(raz > 2) return KillTimer(prostt[playerid]);
    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	raz++;
	return 1;
}
stock ShowMenu(playerid)
{
    PlayerPlaySound(playerid, 1058, 0, 0 ,0);
	if(PlayerInfo[playerid][pEntered] == 0) return SCM(playerid, COLOR_ERROR, "���������� ��������������.");
	new str[123], string[250], ip[30], title[250];
 	if(PlayerInfo[playerid][pAdmin] == 0) title = "{FFFF00}�����";
	else if(PlayerInfo[playerid][pAdmin] == 1) title = "{00FF00}���������";
	else if(PlayerInfo[playerid][pAdmin] == 2) title = "{00FF00}������� ���������";
	else if(PlayerInfo[playerid][pAdmin] == 3) title = "{00FF00}�������������";
	else if(PlayerInfo[playerid][pAdmin] == 4) title = "{00FF00}������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 5) title = "{00FF00}������� �������������";
	else if(PlayerInfo[playerid][pAdmin] == 6) title = "{FF0000}����������";
  	GetPlayerIp(playerid, ip, sizeof(ip));
	format(str, 123, "���� | �������: {FFFFFF}%s | %s | %s", GN(playerid), ip, title);
	f("����������\n���������\n������ ������\n����� � ��������������\n������\n���� ������� ����������\n���� ����������");
	SPD(playerid, mm, DLIST, str, string, "�������", "������");
	return 1;
}
