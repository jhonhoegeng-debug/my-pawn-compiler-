// =======================================
//  MODERN FULL HD RP HUD - SAMP 0.3.7
//  BY CHATGPT
// =======================================

#include <a_samp>

#define COLOR_GREEN 0x00FF00FF
#define COLOR_BLUE 0x00BFFFFF
#define COLOR_ORANGE 0xFFA500FF
#define COLOR_CYAN 0x00FFFFFF
#define COLOR_RED 0xFF0000FF
#define COLOR_BLACK 0x00000088

new PlayerText:HealthBar[MAX_PLAYERS];
new PlayerText:ArmorBar[MAX_PLAYERS];
new PlayerText:HungerBar[MAX_PLAYERS];
new PlayerText:ThirstBar[MAX_PLAYERS];
new PlayerText:VoiceBar[MAX_PLAYERS];

new PlayerText:HealthIcon[MAX_PLAYERS];
new PlayerText:ArmorIcon[MAX_PLAYERS];
new PlayerText:HungerIcon[MAX_PLAYERS];
new PlayerText:ThirstIcon[MAX_PLAYERS];
new PlayerText:MicIcon[MAX_PLAYERS];

new PlayerText:MapCircle[MAX_PLAYERS];
new PlayerText:SpeedBox[MAX_PLAYERS];
new PlayerText:SpeedText[MAX_PLAYERS];

new Float:PlayerHunger[MAX_PLAYERS];
new Float:PlayerThirst[MAX_PLAYERS];

forward UpdateHUD(playerid);

public OnPlayerConnect(playerid)
{
    // =========================
    // MAP BULAT
    // =========================
    MapCircle[playerid] = CreatePlayerTextDraw(playerid, 15.0, 370.0, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, MapCircle[playerid], 95.0, 95.0);
    PlayerTextDrawFont(playerid, MapCircle[playerid], 4);
    PlayerTextDrawColor(playerid, MapCircle[playerid], 0x222222AA);
    PlayerTextDrawShow(playerid, MapCircle[playerid]);

    // =========================
    // ICON HEALTH
    // =========================
    HealthIcon[playerid] = CreatePlayerTextDraw(playerid, 120.0, 378.0, "HP");
    PlayerTextDrawLetterSize(playerid, HealthIcon[playerid], 0.20, 1.0);
    PlayerTextDrawColor(playerid, HealthIcon[playerid], COLOR_GREEN);
    PlayerTextDrawShow(playerid, HealthIcon[playerid]);

    // HEALTH BAR
    HealthBar[playerid] = CreatePlayerTextDraw(playerid, 140.0, 380.0, "_");
    PlayerTextDrawUseBox(playerid, HealthBar[playerid], 1);
    PlayerTextDrawBoxColor(playerid, HealthBar[playerid], COLOR_GREEN);
    PlayerTextDrawTextSize(playerid, HealthBar[playerid], 240.0, 0.0);
    PlayerTextDrawLetterSize(playerid, HealthBar[playerid], 0.0, 0.8);
    PlayerTextDrawShow(playerid, HealthBar[playerid]);

    // =========================
    // ARMOR
    // =========================
    ArmorIcon[playerid] = CreatePlayerTextDraw(playerid, 120.0, 394.0, "AR");
    PlayerTextDrawLetterSize(playerid, ArmorIcon[playerid], 0.20, 1.0);
    PlayerTextDrawColor(playerid, ArmorIcon[playerid], COLOR_BLUE);
    PlayerTextDrawShow(playerid, ArmorIcon[playerid]);

    ArmorBar[playerid] = CreatePlayerTextDraw(playerid, 140.0, 396.0, "_");
    PlayerTextDrawUseBox(playerid, ArmorBar[playerid], 1);
    PlayerTextDrawBoxColor(playerid, ArmorBar[playerid], COLOR_BLUE);
    PlayerTextDrawTextSize(playerid, ArmorBar[playerid], 220.0, 0.0);
    PlayerTextDrawLetterSize(playerid, ArmorBar[playerid], 0.0, 0.8);
    PlayerTextDrawShow(playerid, ArmorBar[playerid]);

    // =========================
    // HUNGER
    // =========================
    HungerIcon[playerid] = CreatePlayerTextDraw(playerid, 120.0, 410.0, "FOOD");
    PlayerTextDrawLetterSize(playerid, HungerIcon[playerid], 0.18, 0.9);
    PlayerTextDrawColor(playerid, HungerIcon[playerid], COLOR_ORANGE);
    PlayerTextDrawShow(playerid, HungerIcon[playerid]);

    HungerBar[playerid] = CreatePlayerTextDraw(playerid, 140.0, 412.0, "_");
    PlayerTextDrawUseBox(playerid, HungerBar[playerid], 1);
    PlayerTextDrawBoxColor(playerid, HungerBar[playerid], COLOR_ORANGE);
    PlayerTextDrawTextSize(playerid, HungerBar[playerid], 200.0, 0.0);
    PlayerTextDrawLetterSize(playerid, HungerBar[playerid], 0.0, 0.8);
    PlayerTextDrawShow(playerid, HungerBar[playerid]);

    // =========================
    // THIRST
    // =========================
    ThirstIcon[playerid] = CreatePlayerTextDraw(playerid, 120.0, 426.0, "DRINK");
    PlayerTextDrawLetterSize(playerid, ThirstIcon[playerid], 0.18, 0.9);
    PlayerTextDrawColor(playerid, ThirstIcon[playerid], COLOR_CYAN);
    PlayerTextDrawShow(playerid, ThirstIcon[playerid]);

    ThirstBar[playerid] = CreatePlayerTextDraw(playerid, 140.0, 428.0, "_");
    PlayerTextDrawUseBox(playerid, ThirstBar[playerid], 1);
    PlayerTextDrawBoxColor(playerid, ThirstBar[playerid], COLOR_CYAN);
    PlayerTextDrawTextSize(playerid, ThirstBar[playerid], 180.0, 0.0);
    PlayerTextDrawLetterSize(playerid, ThirstBar[playerid], 0.0, 0.8);
    PlayerTextDrawShow(playerid, ThirstBar[playerid]);

    // =========================
    // MIC VOICE REAL
    // =========================
    MicIcon[playerid] = CreatePlayerTextDraw(playerid, 120.0, 445.0, "MIC");
    PlayerTextDrawLetterSize(playerid, MicIcon[playerid], 0.20, 1.0);
    PlayerTextDrawColor(playerid, MicIcon[playerid], COLOR_RED);
    PlayerTextDrawShow(playerid, MicIcon[playerid]);

    VoiceBar[playerid] = CreatePlayerTextDraw(playerid, 140.0, 447.0, "_");
    PlayerTextDrawUseBox(playerid, VoiceBar[playerid], 1);
    PlayerTextDrawBoxColor(playerid, VoiceBar[playerid], COLOR_RED);
    PlayerTextDrawTextSize(playerid, VoiceBar[playerid], 160.0, 0.0);
    PlayerTextDrawLetterSize(playerid, VoiceBar[playerid], 0.0, 0.8);
    PlayerTextDrawShow(playerid, VoiceBar[playerid]);

    // =========================
    // SPEEDOMETER MODERN
    // =========================
    SpeedBox[playerid] = CreatePlayerTextDraw(playerid, 520.0, 400.0, "_");
    PlayerTextDrawUseBox(playerid, SpeedBox[playerid], 1);
    PlayerTextDrawBoxColor(playerid, SpeedBox[playerid], COLOR_BLACK);
    PlayerTextDrawTextSize(playerid, SpeedBox[playerid], 630.0, 0.0);
    PlayerTextDrawLetterSize(playerid, SpeedBox[playerid], 0.5, 4.0);
    PlayerTextDrawShow(playerid, SpeedBox[playerid]);

    SpeedText[playerid] = CreatePlayerTextDraw(playerid, 545.0, 415.0, "0 KM/H");
    PlayerTextDrawLetterSize(playerid, SpeedText[playerid], 0.35, 1.5);
    PlayerTextDrawColor(playerid, SpeedText[playerid], 0xFFFFFFFF);
    PlayerTextDrawShow(playerid, SpeedText[playerid]);

    PlayerHunger[playerid] = 100.0;
    PlayerThirst[playerid] = 100.0;

    SetTimerEx("UpdateHUD", 100, true, "i", playerid);

    return 1;
}

public UpdateHUD(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    new Float:hp, Float:arm;
    GetPlayerHealth(playerid, hp);
    GetPlayerArmour(playerid, arm);

    // Smooth Health
    PlayerTextDrawTextSize(playerid,
        HealthBar[playerid],
        140.0 + (hp * 1.0),
        0.0
    );

    // Smooth Armor
    PlayerTextDrawTextSize(playerid,
        ArmorBar[playerid],
        140.0 + (arm * 0.8),
        0.0
    );

    // Hunger turun
    PlayerHunger[playerid] -= 0.01;
    if(PlayerHunger[playerid] < 0.0)
        PlayerHunger[playerid] = 0.0;

    // Thirst turun
    PlayerThirst[playerid] -= 0.02;
    if(PlayerThirst[playerid] < 0.0)
        PlayerThirst[playerid] = 0.0;

    PlayerTextDrawTextSize(playerid,
        HungerBar[playerid],
        140.0 + (PlayerHunger[playerid] * 0.6),
        0.0
    );

    PlayerTextDrawTextSize(playerid,
        ThirstBar[playerid],
        140.0 + (PlayerThirst[playerid] * 0.6),
        0.0
    );

    // VOICE ANIMATION RANDOM
    new randomvoice = random(90);

    PlayerTextDrawTextSize(playerid,
        VoiceBar[playerid],
        140.0 + randomvoice,
        0.0
    );

    // SPEEDOMETER
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);

        new Float:vx, Float:vy, Float:vz;
        GetVehicleVelocity(vehicleid, vx, vy, vz);

        new speed = floatround(
            floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0
        );

        new str[32];
        format(str, sizeof(str), "%d KM/H", speed);

        PlayerTextDrawSetString(playerid,
            SpeedText[playerid],
            str
        );
    }
    else
    {
        PlayerTextDrawSetString(playerid,
            SpeedText[playerid],
            "0 KM/H"
        );
    }

    PlayerTextDrawShow(playerid, HealthBar[playerid]);
    PlayerTextDrawShow(playerid, ArmorBar[playerid]);
    PlayerTextDrawShow(playerid, HungerBar[playerid]);
    PlayerTextDrawShow(playerid, ThirstBar[playerid]);
    PlayerTextDrawShow(playerid, VoiceBar[playerid]);

    return 1;
}