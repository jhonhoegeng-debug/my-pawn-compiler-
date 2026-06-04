#include <a_samp>
#include <progress2>

// =============================================================================
// DEFINISI & VARIABEL
// =============================================================================
#define DIALOG_HUD_SETUP 9923

// Variabel untuk Player TextDraw (Status Bar)
new PlayerBar:BarDarah[MAX_PLAYERS];
new PlayerBar:BarArmor[MAX_PLAYERS];
new PlayerBar:BarMakan[MAX_PLAYERS];
new PlayerBar:BarMinum[MAX_PLAYERS];

// Variabel TextDraw Background dan Ikon Status
new PlayerText:HudBackground[MAX_PLAYERS];
new PlayerText:StatusIcons[MAX_PLAYERS];

// Variabel Indikator Mic (Suara Roleplay)
new PlayerText:MicIndicator[MAX_PLAYERS];
new PlayerText:MicText[MAX_PLAYERS];
new PlayerVoiceRange[MAX_PLAYERS]; // 0: Bisik, 1: Normal, 2: Teriak

// Variabel Speedometer
new PlayerText:SpeedoBG[MAX_PLAYERS];
new PlayerText:SpeedoText[MAX_PLAYERS];
new PlayerText:SpeedoUnit[MAX_PLAYERS];
new PlayerText:FuelText[MAX_PLAYERS];
new PlayerBar:BarBensin[MAX_PLAYERS];

// Variabel Status Kebutuhan Player (0 - 100)
new PlayerMakan[MAX_PLAYERS] = {100, ...};
new PlayerMinum[MAX_PLAYERS] = {100, ...};

// Timer untuk update HUD otomatis
new HudUpdateTimer;

// =============================================================================
// CALLBACKS UTAMA
// =============================================================================

public OnGameModeInit()
{
    // Mengubah radar/map bawaan game menjadi BULAT (Sesuai Request)
    // Catatan: Di SA-MP, radar kotak bawaan GTA SA diubah melingkar melalui konfigurasi ini
    SetGridlineRadar(0); 
    
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
    // Default range suara saat masuk server: Normal
    PlayerVoiceRange[playerid] = 1;
    PlayerMakan[playerid] = 100;
    PlayerMinum[playerid] = 100;
    
    // Inisialisasi TextDraw HUD saat player masuk
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
    // Tampilkan semua komponen HUD ke layar player
    ShowPlayerModernHUD(playerid);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    // Jika player masuk ke kendaraan (driver atau penumpang)
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        ShowPlayerSpeedometer(playerid);
    }
    // Jika player keluar dari kendaraan
    if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
    {
        HidePlayerSpeedometer(playerid);
    }
    return 1;
}

// Menangkap tombol 'H' untuk mengubah range Mic suara
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_CTRL_BACK) && IsPlayerSpawned(playerid)) // Tombol H / CapsLock dasar
    {
        PlayerVoiceRange[playerid]++;
        if(PlayerVoiceRange[playerid] > 2) PlayerVoiceRange[playerid] = 0;
        
        UpdateMicHUD(playerid);
        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0); // Suara klik radio ceria
    }
    return 1;
}

// =============================================================================
// FUNGSI BUAT & TAMPILKAN HUD (TEXTDRAW & PROGRESS BAR)
// =============================================================================

stock CreatePlayerModernHUD(playerid)
{
    // 1. Background Kotak Transparan untuk Status Bar (Kiri Bawah di samping Map Bulat)
    HudBackground[playerid] = CreatePlayerTextDraw(playerid, 150.0000, 430.0000, "LD_SPAC:white");
    PlayerTextDrawLetterSize(playerid, HudBackground[playerid], 0.0000, 0.0000);
    PlayerTextDrawTextSize(playerid, HudBackground[playerid], 120.0000, 25.0000);
    PlayerTextDrawAlignment(playerid, HudBackground[playerid], 1);
    PlayerTextDrawColor(playerid, HudBackground[playerid], 150); // Transparan gelap ala FiveM
    PlayerTextDrawSetShadow(playerid, HudBackground[playerid], 0);
    PlayerTextDrawSetOutline(playerid, HudBackground[playerid], 0);
    PlayerTextDrawFont(playerid, HudBackground[playerid], 4);

    // 2. Progres Bar Darah (Warna Hijau Cerah)
    BarDarah[playerid] = CreatePlayerProgressBar(playerid, 155.0, 433.0, 20.0, 4.0, 0xFF0000FF, 100.0, BAR_DIRECTION_RIGHT);
    
    // 3. Progres Bar Armor/Vest (Warna Biru Gendarmerie)
    BarArmor[playerid] = CreatePlayerProgressBar(playerid, 180.0, 433.0, 20.0, 4.0, 0x0088FFFF, 100.0, BAR_DIRECTION_RIGHT);
    
    // 4. Progres Bar Makanan (Warna Oranye)
    BarMakan[playerid] = CreatePlayerProgressBar(playerid, 205.0, 433.0, 20.0, 4.0, 0xFF8800FF, 100.0, BAR_DIRECTION_RIGHT);
    
    // 5. Progres Bar Minuman (Warna Sian/Aqua)
    BarMinum[playerid] = CreatePlayerProgressBar(playerid, 230.0, 433.0, 20.0, 4.0, 0x00FFFFFF, 100.0, BAR_DIRECTION_RIGHT);

    // 6. Pembuatan Indikator Mic (Kiri bawah, di samping status bar)
    MicBackground(playerid);
    
    // 7. Pembuatan Struktur Speedometer (Kanan Bawah)
    CreatePlayerSpeedoDraw(playerid);
    return 1;
}

stock MicBackground(playerid)
{
    MicIndicator[playerid] = CreatePlayerTextDraw(playerid, 125.0000, 431.0000, "I");
    PlayerTextDrawFont(playerid, MicIndicator[playerid], 1);
    PlayerTextDrawLetterSize(playerid, MicIndicator[playerid], 0.5, 1.5);
    PlayerTextDrawColor(playerid, MicIndicator[playerid], 0x00FF00FF); // Default Hijau aktif

    MicText[playerid] = CreatePlayerTextDraw(playerid, 110.0000, 433.0000, "NORMAL");
    PlayerTextDrawFont(playerid, MicText[playerid], 2);
    PlayerTextDrawLetterSize(playerid, MicText[playerid], 0.18, 0.9);
    PlayerTextDrawColor(playerid, MicText[playerid], 0xFFFFFFFF);
}

stock CreatePlayerSpeedoDraw(playerid)
{
    // Background Hitam Melingkar Ringan untuk Angka Kecepatan
    SpeedoBG[playerid] = CreatePlayerTextDraw(playerid, 510.0000, 390.0000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, SpeedoBG[playerid], 110.0000, 50.0000);
    PlayerTextDrawColor(playerid, SpeedoBG[playerid], 120);
    PlayerTextDrawFont(playerid, SpeedoBG[playerid], 4);

    // Teks Angka Speedometer 000
    SpeedoText[playerid] = CreatePlayerTextDraw(playerid, 550.0000, 395.0000, "000");
    PlayerTextDrawFont(playerid, SpeedoText[playerid], 3); // Font bergaya sport/bold
    PlayerTextDrawLetterSize(playerid, SpeedoText[playerid], 0.55, 2.4);
    PlayerTextDrawColor(playerid, SpeedoText[playerid], 0xFFFFFFFF);

    // Teks KM/H
    SpeedoUnit[playerid] = CreatePlayerTextDraw(playerid, 553.0000, 420.0000, "KMH");
    PlayerTextDrawFont(playerid, SpeedoUnit[playerid], 2);
    PlayerTextDrawLetterSize(playerid, SpeedoUnit[playerid], 0.17, 0.8);
    PlayerTextDrawColor(playerid, SpeedoUnit[playerid], 0xAAAAAAFF);

    // Bar Indikator Bensin Mini di Bawah Angka Speedo
    BarBensin[playerid] = CreatePlayerProgressBar(playerid, 520.0, 433.0, 90.0, 3.0, 0xFFFF00FF, 100.0, BAR_DIRECTION_RIGHT);
}

// =============================================================================
// LOGIKA MENAMPILKAN / MENYEMBUNYIKAN
// =============================================================================

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

// =============================================================================
// ENGINES & SISTEM UPDATE DATA OTOMATIS
// =============================================================================

forward UpdateAllPlayerHUD();
public UpdateAllPlayerHUD()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !IsPlayerSpawned(i)) continue;
        
        // 1. Ambil Data Darah (Health) Asli
        new Float:hp;
        GetPlayerHealth(i, hp);
        SetPlayerProgressBarValue(i, BarDarah[i], hp);
        
        // 2. Ambil Data Vest (Armour) Asli
        new Float:arm;
        GetPlayerArmour(i, arm);
        SetPlayerProgressBarValue(i, BarArmor[i], arm);
        
        // 3. Update Bar Lapar dan Haus (Kebutuhan Roleplay)
        PlayerMakan[i] -= 1; // Berkurang perlahan tiap waktu
        PlayerMinum[i] -= 1;
        if(PlayerMakan[i] < 0) PlayerMakan[i] = 0;
        if(PlayerMinum[i] < 0) PlayerMinum[i] = 0;
        
        SetPlayerProgressBarValue(i, BarMakan[i], Float:PlayerMakan[i]);
        SetPlayerProgressBarValue(i, BarMinum[i], Float:PlayerMinum[i]);
        
        // Refresh Bar agar visualnya bergeser
        UpdatePlayerProgressBar(i, BarDarah[i]);
        UpdatePlayerProgressBar(i, BarArmor[i]);
        UpdatePlayerProgressBar(i, BarMakan[i]);
        UpdatePlayerProgressBar(i, BarMinum[i]);
        
        // 4. Update Angka Speedometer jika di dalam Mobil
        if(IsPlayerInAnyVehicle(i))
        {
            new string[8];
            valstr(string, GetPlayerSpeed(i));
            PlayerTextDrawSetString(i, SpeedoText[i], string);
            
            // Set bensin statis di angka 80% untuk simulasi visual HUD
            SetPlayerProgressBarValue(i, BarBensin[i], 80.0);
            UpdatePlayerProgressBar(i, BarBensin[i]);
        }
    }
    return 1;
}

stock UpdateMicHUD(playerid)
{
    // Mengubah indikator mic berdasarkan range tombol H
    if(PlayerVoiceRange[playerid] == 0) // Bisik
    {
        PlayerTextDrawSetString(playerid, MicText[playerid], "WHISPER");
        PlayerTextDrawColor(playerid, MicIndicator[playerid], 0xFFFF00FF); // Kuning redup
    }
    else if(PlayerVoiceRange[playerid] == 1) // Normal
    {
        PlayerTextDrawSetString(playerid, MicText[playerid], "NORMAL");
        PlayerTextDrawColor(playerid, MicIndicator[playerid], 0x00FF00FF); // Hijau
    }
    else if(PlayerVoiceRange[playerid] == 2) // Teriak
    {
        PlayerTextDrawSetString(playerid, MicText[playerid], "SHOUT");
        PlayerTextDrawColor(playerid, MicIndicator[playerid], 0xFF0000FF); // Merah membara
    }
    PlayerTextDrawShow(playerid, MicIndicator[playerid]);
    PlayerTextDrawShow(playerid, MicText[playerid]);
}

// Fungsi pembantu menghitung kecepatan asli kendaraan ala SA-MP
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
