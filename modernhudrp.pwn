#include <a_samp>
#include <progress2>

// Variabel untuk Player TextDraw (Status Bar)
new PlayerBar:BarDarah[MAX_PLAYERS];
new PlayerBar:BarArmor[MAX_PLAYERS];
new PlayerBar:BarMakan[MAX_PLAYERS];
new PlayerBar:BarMinum[MAX_PLAYERS];

// Variabel TextDraw Background
new PlayerText:HudBackground[MAX_PLAYERS];

// Variabel Indikator Mic (Suara Roleplay)
new PlayerText:MicIndicator[MAX_PLAYERS];
new PlayerText:MicText[MAX_PLAYERS];
new PlayerVoiceRange[MAX_PLAYERS]; // 0: Bisik, 1: Normal, 2: Teriak

// Variabel Speedometer
new PlayerText:SpeedoBG[MAX_PLAYERS];
new PlayerText:SpeedoText[MAX_PLAYERS];
new PlayerText:SpeedoUnit[MAX_PLAYERS];
new PlayerBar:BarBensin[MAX_PLAYERS];

// Variabel Status Kebutuhan Player (0 - 100)
new PlayerMakan[MAX_PLAYERS] = {100, ...};
new PlayerMinum[MAX_PLAYERS] = {100, ...};

// Timer untuk update HUD otomatis
new HudUpdateTimer;

public OnGameModeInit()
{
    // Jalankan timer update status & speedo setiap 1 detik
    HudUpdateTimer = SetTimer("UpdateAllPlayerHUD", 1000, true);
    return 1;
}

public OnGameModeExit()
{
    KillTimer(HudUpdateTimer);
    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerVoiceRange[playerid] = 1;
    PlayerMakan[playerid] = 100;
    PlayerMinum[playerid] = 100;
    
    CreatePlayerModernHUD(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    DestroyPlayerModernHUD(playerid);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    ShowPlayerModernHUD(playerid);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        ShowPlayerSpeedometer(playerid);
    }
    if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
    {
        HidePlayerSpeedometer(playerid);
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_CTRL_BACK) && IsPlayerSpawned(playerid)) 
    {
        PlayerVoiceRange[playerid]++;
        if(PlayerVoiceRange[playerid] > 2) PlayerVoiceRange[playerid] = 0;
        
        UpdateMicHUD(playerid);
        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0); 
    }
    return 1;
}

stock CreatePlayerModernHUD(playerid)
{
    // Background Kotak Transparan untuk Status Bar Kiri Bawah
    HudBackground[playerid] = CreatePlayerTextDraw(playerid, 150.0000, 430.0000, "LD_SPAC:white");
    PlayerTextDrawLetterSize(playerid, HudBackground[playerid], 0.0000, 0.0000);
    PlayerTextDrawTextSize(playerid, HudBackground[playerid], 120.0000, 25.0000);
    PlayerTextDrawAlignment(playerid, HudBackground[playerid], 1);
    PlayerTextDrawColor(playerid, HudBackground[playerid], 150); 
    PlayerTextDrawSetShadow(playerid, HudBackground[playerid], 0);
    PlayerTextDrawSetOutline(playerid, HudBackground[playerid], 0);
    PlayerTextDrawFont(playerid, HudBackground[playerid], 4);

    // Progres Bar Kebutuhan Fisik
    BarDarah[playerid] = CreatePlayerProgressBar(playerid, 155.0, 433.0, 20.0, 4.0, 0xFF0000FF, 100.0, BAR_DIRECTION_RIGHT);
    BarArmor[playerid] = CreatePlayerProgressBar(playerid, 180.0, 433.0, 20.0, 4.0, 0x0088FFFF, 100.0, BAR_DIRECTION_RIGHT);
    BarMakan[playerid] = CreatePlayerProgressBar(playerid, 205.0, 433.0, 20.0, 4.0, 0xFF8800FF, 100.0, BAR_DIRECTION_RIGHT);
    BarMinum[playerid] = CreatePlayerProgressBar(playerid, 230.0, 433.0, 20.0, 4.0, 0x00FFFFFF, 100.0, BAR_DIRECTION_RIGHT);

    // Indikator Mic
    MicIndicator[playerid] = CreatePlayerTextDraw(playerid, 125.0000, 431.0000, "I");
    PlayerTextDrawFont(playerid, MicIndicator[playerid], 1);
    PlayerTextDrawLetterSize(playerid, MicIndicator[playerid], 0.5, 1.5);
    PlayerTextDrawColor(playerid, MicIndicator[playerid], 0x00FF00FF);

    MicText[playerid] = CreatePlayerTextDraw(playerid, 110.0000, 433.0000, "NORMAL");
    PlayerTextDrawFont(playerid, MicText[playerid], 2);
    PlayerTextDrawLetterSize(playerid, MicText[playerid], 0.18, 0.9);
    PlayerTextDrawColor(playerid, MicText[playerid], 0xFFFFFFFF);
    
    // Speedometer Kanan Bawah
    SpeedoBG[playerid] = CreatePlayerTextDraw(playerid, 510.0000, 390.0000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, SpeedoBG[playerid], 110.0000, 50.0000);
    PlayerTextDrawColor(playerid, SpeedoBG[playerid], 120);
    PlayerTextDrawFont(playerid, SpeedoBG[playerid], 4);

    SpeedoText[playerid] = CreatePlayerTextDraw(playerid, 550.0000, 395.0000, "000");
    PlayerTextDrawFont(playerid, SpeedoText[playerid], 3); 
    PlayerTextDrawLetterSize(playerid, SpeedoText[playerid], 0.55, 2.4);
    PlayerTextDrawColor(playerid, SpeedoText[playerid], 0xFFFFFFFF);

    SpeedoUnit[playerid] = CreatePlayerTextDraw(playerid, 553.0000, 420.0000, "KMH");
    PlayerTextDrawFont(playerid, SpeedoUnit[playerid], 2);
    PlayerTextDrawLetterSize(playerid, SpeedoUnit[playerid], 0.17, 0.8);
    PlayerTextDrawColor(playerid, SpeedoUnit[playerid], 0xAAAAAAFF);

    BarBensin[playerid] = CreatePlayerProgressBar(playerid, 520.0, 433.0, 90.0, 3.0, 0xFFFF00FF, 100.0, BAR_DIRECTION_RIGHT);
    return 1;
}

stock ShowPlayerModernHUD(playerid)
{
    PlayerTextDrawShow(playerid, HudBackground[playerid]);
    PlayerTextDrawShow(playerid, MicIndicator[playerid]);
    PlayerTextDrawShow(playerid, MicText[playerid]);
    
    ShowPlayerProgressBar(playerid, BarDarah[playerid]);
    ShowPlayerProgressBar(playerid, BarArmor[playerid]);
    ShowPlayerProgressBar(playerid, BarMakan[playerid]);
    ShowPlayerProgressBar(playerid, BarMinum[playerid]);
    return 1;
}

stock DestroyPlayerModernHUD(playerid)
{
    PlayerTextDrawDestroy(playerid, HudBackground[playerid]);
    PlayerTextDrawDestroy(playerid, MicIndicator[playerid]);
    PlayerTextDrawDestroy(playerid, MicText[playerid]);
    PlayerTextDrawDestroy(playerid, SpeedoBG[playerid]);
    PlayerTextDrawDestroy(playerid, SpeedoText[playerid]);
    PlayerTextDrawDestroy(playerid, SpeedoUnit[playerid]);
    
    DestroyPlayerProgressBar(playerid, BarDarah[playerid]);
    DestroyPlayerProgressBar(playerid, BarArmor[playerid]);
    DestroyPlayerProgressBar(playerid, BarMakan[playerid]);
    DestroyPlayerProgressBar(playerid, BarMinum[playerid]);
    DestroyPlayerProgressBar(playerid, BarBensin[playerid]);
    return 1;
}

stock ShowPlayerSpeedometer(playerid)
{
    PlayerTextDrawShow(playerid, SpeedoBG[playerid]);
    PlayerTextDrawShow(playerid, SpeedoText[playerid]);
    PlayerTextDrawShow(playerid, SpeedoUnit[playerid]);
    ShowPlayerProgressBar(playerid, BarBensin[playerid]);
}

stock HidePlayerSpeedometer(playerid)
{
    PlayerTextDrawHide(playerid, SpeedoBG[playerid]);
    PlayerTextDrawHide(playerid, SpeedoText[playerid]);
    PlayerTextDrawHide(playerid, SpeedoUnit[playerid]);
    HidePlayerProgressBar(playerid, BarBensin[playerid]);
}

forward UpdateAllPlayerHUD();
public UpdateAllPlayerHUD()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !IsPlayerSpawned(i)) continue;
        
        new Float:hp;
        GetPlayerHealth(i, hp);
        SetPlayerProgressBarValue(i, BarDarah[i], hp);
        
        new Float:arm;
        GetPlayerArmour(i, arm);
        SetPlayerProgressBarValue(i, BarArmor[i], arm);
        
        PlayerMakan[i] -= 1; 
        PlayerMinum[i] -= 1;
        if(PlayerMakan[i] < 0) PlayerMakan[i] = 0;
        if(PlayerMinum[i] < 0) PlayerMinum[i] = 0;
        
        SetPlayerProgressBarValue(i, BarMakan[i], Float:PlayerMakan[i]);
        SetPlayerProgressBarValue(i, BarMinum[i], Float:PlayerMinum[i]);
        
        UpdatePlayerProgressBar(i, BarDarah[i]);
        UpdatePlayerProgressBar(i, BarArmor[i]);
        UpdatePlayerProgressBar(i, BarMakan[i]);
        UpdatePlayerProgressBar(i, BarMinum[i]);
        
        if(IsPlayerInAnyVehicle(i))
        {
            new string[8];
            valstr(string, GetPlayerSpeed(i));
            PlayerTextDrawSetString(i, SpeedoText[i], string);
            
            SetPlayerProgressBarValue(i, BarBensin[i], 80.0);
            UpdatePlayerProgressBar(i, BarBensin[i]);
        }
    }
    return 1;
}

stock UpdateMicHUD(playerid)
{
    if(PlayerVoiceRange[playerid] == 0)
    {
        PlayerTextDrawSetString(playerid, MicText[playerid], "WHISPER");
        PlayerTextDrawColor(playerid, MicIndicator[playerid], 0xFFFF00FF);
    }
    else if(PlayerVoiceRange[playerid] == 1)
    {
        PlayerTextDrawSetString(playerid, MicText[playerid], "NORMAL");
        PlayerTextDrawColor(playerid, MicIndicator[playerid], 0x00FF00FF);
    }
    else if(PlayerVoiceRange[playerid] == 2)
    {
        PlayerTextDrawSetString(playerid, MicText[playerid], "SHOUT");
        PlayerTextDrawColor(playerid, MicIndicator[playerid], 0xFF0000FF);
    }
    PlayerTextDrawShow(playerid, MicIndicator[playerid]);
    PlayerTextDrawShow(playerid, MicText[playerid]);
}

stock GetPlayerSpeed(playerid)
{
    new Float:ST[3], Float:SpeedVF;
    if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), ST[0], ST[1], ST[2]);
    else GetPlayerVelocity(playerid, ST[0], ST[1], ST[2]);
    SpeedVF = floatsqroot(floatpower(ST[0], 2) + floatpower(ST[1], 2) + floatpower(ST[2], 2)) * 178.66617;
    return floatround(SpeedVF);
}

stock IsPlayerSpawned(playerid)
{
    new state = GetPlayerState(playerid);
    return (state == PLAYER_STATE_ONFOOT || state == PLAYER_STATE_DRIVER || state == PLAYER_STATE_PASSENGER);
}
