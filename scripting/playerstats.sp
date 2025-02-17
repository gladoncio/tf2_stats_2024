#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>



// ^ tf2_stocks.inc itself includes sdktools.inc and tf2.inc

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"
// Definir el máximo de niveles permitidos
#define MAX_NIVELES 50

#define MAX_NOMBRE 64  // Definir el tamaño máximo para nombres
#define PLUGIN_PREFIX 	"{black}[Player Ranks]{violet} " 	// Our chat friendly prefix.
#define SQL_CREATETABLE_SQLITE "CREATE TABLE IF NOT EXISTS ranks_players ( \
    id INTEGER PRIMARY KEY AUTOINCREMENT, \
    name TEXT, \
    steamid TEXT, \
    steamid64 TEXT, \
    rounds_wins INTEGER, \
    rounds_lose INTEGER, \
    kills INTEGER, \
    points INTEGER, \
    deaths INTEGER, \
    suicides INTEGER, \
    headshots INTEGER, \
    level INTEGER, \
    dominations INTEGER, \
    first_join_date DATETIME, \
    play_time_seconds FLOAT, \
    g_dominado INTEGER DEFAULT 0, \
    g_assist INTEGER DEFAULT 0, \
    backstabEvent INTEGER DEFAULT 0, \
    burningEvent INTEGER DEFAULT 0, \
    suicideEvent INTEGER DEFAULT 0, \
    tauntHadoukenEvent INTEGER DEFAULT 0, \
    burningFlareEvent INTEGER DEFAULT 0, \
    tauntHighNoonEvent INTEGER DEFAULT 0, \
    tauntGrandSlamEvent INTEGER DEFAULT 0, \
    penetrateMyTeamEvent INTEGER DEFAULT 0, \
    penetrateHeadshotEvent INTEGER DEFAULT 0, \
    telefragEvent INTEGER DEFAULT 0, \
    flyingBurnEvent INTEGER DEFAULT 0, \
    pumpkinBombEvent INTEGER DEFAULT 0, \
    decapitationEvent INTEGER DEFAULT 0, \
    shotgunRevengeCritEvent INTEGER DEFAULT 0, \
    fishKillEvent INTEGER DEFAULT 0, \
    tauntAllclassGuitarRiffEvent INTEGER DEFAULT 0, \
    kartEvent INTEGER DEFAULT 0, \
    dragonsFuryIgniteEvent INTEGER DEFAULT 0, \
    slapKillEvent INTEGER DEFAULT 0, \
    axtinguishBoosterEvent INTEGER DEFAULT 0, \
    g_ObjectsDestroyed INTEGER DEFAULT 0, \
    g_BuildingsDestroyed INTEGER DEFAULT 0, \
    g_EventsAssisted INTEGER DEFAULT 0 \
);"


#define SQL_CREATETABLE_MYSQL "CREATE TABLE IF NOT EXISTS ranks_players ( \
    id INT AUTO_INCREMENT PRIMARY KEY, \
    name VARCHAR(255), \
    steamid VARCHAR(32), \
    steamid64 VARCHAR(64), \
    rounds_wins INT, \
    rounds_lose INT, \
    kills INT, \
    points INT, \
    deaths INT, \
    suicides INT, \
    headshots INT, \
    level INT, \
    dominations INT, \
    first_join_date DATETIME, \
    play_time_seconds FLOAT, \
    g_dominado INT DEFAULT 0, \
    g_assist INT DEFAULT 0, \
    backstabEvent INT DEFAULT 0, \
    burningEvent INT DEFAULT 0, \
    suicideEvent INT DEFAULT 0, \
    tauntHadoukenEvent INT DEFAULT 0, \
    burningFlareEvent INT DEFAULT 0, \
    tauntHighNoonEvent INT DEFAULT 0, \
    tauntGrandSlamEvent INT DEFAULT 0, \
    penetrateMyTeamEvent INT DEFAULT 0, \
    penetrateHeadshotEvent INT DEFAULT 0, \
    telefragEvent INT DEFAULT 0, \
    flyingBurnEvent INT DEFAULT 0, \
    pumpkinBombEvent INT DEFAULT 0, \
    decapitationEvent INT DEFAULT 0, \
    shotgunRevengeCritEvent INT DEFAULT 0, \
    fishKillEvent INT DEFAULT 0, \
    tauntAllclassGuitarRiffEvent INT DEFAULT 0, \
    kartEvent INT DEFAULT 0, \
    dragonsFuryIgniteEvent INT DEFAULT 0, \
    slapKillEvent INT DEFAULT 0, \
    axtinguishBoosterEvent INT DEFAULT 0, \
    g_ObjectsDestroyed INT DEFAULT 0, \
    g_BuildingsDestroyed INT DEFAULT 0, \
    g_EventsAssisted INT DEFAULT 0 \
);"

#define SQL_SELECT_INFO "SELECT \
    kills, \
    deaths, \
    suicides, \
    headshots, \
    level, \
    dominations, \
    play_time_seconds, \
    points, \
    rounds_wins, \
    rounds_lose, \
    g_dominado, \
    g_assist, \
    backstabEvent, \
    burningEvent, \
    suicideEvent, \
    tauntHadoukenEvent, \
    burningFlareEvent, \
    tauntHighNoonEvent, \
    tauntGrandSlamEvent, \
    penetrateMyTeamEvent, \
    penetrateHeadshotEvent, \
    telefragEvent, \
    flyingBurnEvent, \
    pumpkinBombEvent, \
    decapitationEvent, \
    shotgunRevengeCritEvent, \
    fishKillEvent, \
    tauntAllclassGuitarRiffEvent, \
    kartEvent, \
    dragonsFuryIgniteEvent, \
    slapKillEvent, \
    axtinguishBoosterEvent, \
    g_ObjectsDestroyed, \
    g_BuildingsDestroyed, \
    g_EventsAssisted \
FROM ranks_players \
WHERE steamid = '%s'"


#define SQL_PLAYER_NOT_EXISTS "INSERT INTO ranks_players ( \
    steamid, \
    steamid64, \
    name, \
    rounds_wins, \
    rounds_lose, \
    kills, \
    points, \
    deaths, \
    suicides, \
    headshots, \
    level, \
    dominations, \
    first_join_date, \
    play_time_seconds, \
    g_dominado, \
    g_assist, \
    backstabEvent, \
    burningEvent, \
    suicideEvent, \
    tauntHadoukenEvent, \
    burningFlareEvent, \
    tauntHighNoonEvent, \
    tauntGrandSlamEvent, \
    penetrateMyTeamEvent, \
    penetrateHeadshotEvent, \
    telefragEvent, \
    flyingBurnEvent, \
    pumpkinBombEvent, \
    decapitationEvent, \
    shotgunRevengeCritEvent, \
    fishKillEvent, \
    tauntAllclassGuitarRiffEvent, \
    kartEvent, \
    dragonsFuryIgniteEvent, \
    slapKillEvent, \
    axtinguishBoosterEvent, \
    g_ObjectsDestroyed, \
    g_BuildingsDestroyed, \
    g_EventsAssisted) \
    VALUES ( \
    '%s', \
    '%s', \
    '%s', \
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '%s', 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)"



#define SQL_UPDATE_INFO "UPDATE ranks_players SET \
    kills = %d, \
    deaths = %d, \
    suicides = %d, \
    headshots = %d, \
    level = %d, \
    dominations = %d, \
    play_time_seconds = play_time_seconds + %.2f, \
    points = %d, \
    rounds_wins = %d, \
    rounds_lose = %d, \
    g_dominado = %d, \
    g_assist = %d, \
    backstabEvent = %d, \
    burningEvent = %d, \
    suicideEvent = %d, \
    tauntHadoukenEvent = %d, \
    burningFlareEvent = %d, \
    tauntHighNoonEvent = %d, \
    tauntGrandSlamEvent = %d, \
    penetrateMyTeamEvent = %d, \
    penetrateHeadshotEvent = %d, \
    telefragEvent = %d, \
    flyingBurnEvent = %d, \
    pumpkinBombEvent = %d, \
    decapitationEvent = %d, \
    shotgunRevengeCritEvent = %d, \
    fishKillEvent = %d, \
    tauntAllclassGuitarRiffEvent = %d, \
    kartEvent = %d, \
    dragonsFuryIgniteEvent = %d, \
    slapKillEvent = %d, \
    axtinguishBoosterEvent = %d, \
    g_ObjectsDestroyed = %d, \
    g_BuildingsDestroyed = %d, \
    g_EventsAssisted = %d \
WHERE steamid = '%s'"


// Consulta para obtener el Top 20
#define SQL_SELECT_TOP20 "SELECT name, points FROM ranks_players ORDER BY points DESC LIMIT 20"

#define SQL_SELECT_PLAYER_STATS "SELECT kills, deaths, suicides, headshots, level, dominations, play_time_seconds, points, rounds_wins, rounds_lose FROM ranks_players WHERE steamid = '%s'"

#define SQL_UPDATE_ADMIN_POINTS "UPDATE ranks_players SET points = %d WHERE steamid = '%s'"


public Plugin myinfo =
{
    name = "TF2 rank / stats ",
    author = "Gladoncio",
    description = "Un plugin que registrará las stats y registrará un sistema de niveles",
    version = PLUGIN_VERSION,
    url = "https://github.com/gladoncio/tf2_stats_2025"
};

public Plugin myPlugin;

// Esto verifica si el plugin es compatible con tf2
public APLRes OnAskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion g_engineversion = GetEngineVersion();
    if (g_engineversion != Engine_TF2)
    {
        // Return a failure result
        return APLRes_Failure;
    }
    // If no special conditions, return success
    return APLRes_Success;
}



enum struct playerData {
    int g_Points;                // Puntos totales del jugador
    int g_PlayerKills;           // Número de kills del jugador
    int g_PlayerDeaths;          // Número de muertes del jugador
    int g_PlayerSuicides;        // Número de suicidios del jugador
    int g_PlayerHeadshots;       // Número de headshots del jugador
    int g_PlayerLevel;           // Nivel del jugador
    int g_dominando;             // Número de jugadores dominados
    int g_dominado;              // Número de jugadores que dominan al jugador
    int g_assist;                // Número de asistencias del jugador
    float g_PlayerPlayTime;      // Tiempo jugado
    float g_PlayerStartTime;     // Hora de inicio del jugador
    char g_LevelName[64];        // Nombre del nivel en el que está el jugador
    int g_roundWins;             // Número de rondas ganadas
    int g_roundLose;             // Número de rondas perdidas
    int g_points_required;       // Puntos requeridos para el siguiente nivel
    int g_points_lastlevel;      // Puntos del último nivel
    int backstabEvent;           // Número de backstabs
    int burningEvent;            // Número de eventos de quemaduras
    int suicideEvent;            // Número de suicidios
    int tauntHadoukenEvent;      // Número de eventos de Hadouken
    int burningFlareEvent;       // Número de eventos de quemadura con flare
    int tauntHighNoonEvent;      // Número de eventos de High Noon
    int tauntGrandSlamEvent;     // Número de eventos de Grand Slam
    int penetrateMyTeamEvent;    // Número de penetraciones a su equipo
    int penetrateHeadshotEvent;  // Número de headshots penetrantes
    int telefragEvent;           // Número de telefrag
    int flyingBurnEvent;         // Número de eventos de quema voladora
    int pumpkinBombEvent;        // Número de bombas de calabaza
    int decapitationEvent;       // Número de decapitaciones
    int shotgunRevengeCritEvent; // Número de crits de venganza con escopeta
    int fishKillEvent;           // Número de muertes por pez
    int tauntAllclassGuitarRiffEvent; // Número de taunts con guitarra
    int kartEvent;               // Número de eventos de kart
    int dragonsFuryIgniteEvent;  // Número de eventos de ignición de Dragons Fury
    int slapKillEvent;           // Número de muertes por bofetada
    int axtinguishBoosterEvent;  // Número de eventos de axtinguish
    int g_ObjectsDestroyed;      // Número de objetos destruidos
    int g_BuildingsDestroyed;    // Número de construcciones destruidas
    int g_EventsAssisted;        // Número de eventos asistidos
    // Otros eventos pueden agregarse aquí
}


// Definir un struct para almacenar la configuración
enum struct ConfigData {
    int use_hud;                 // Usar HUD             // Puntos totales del jugador
    int puntosg_PlayerKills;           // Número de kills del jugador
    int puntosg_PlayerDeaths;          // Número de muertes del jugador
    int puntosg_PlayerSuicides;        // Número de suicidios del jugador
    int puntosg_PlayerHeadshots;       // Número de headshots del jugador
    int puntosg_PlayerLevel;           // Nivel del jugador
    int puntosg_dominando;             // Número de jugadores dominados
    int puntosg_dominado;              // Número de jugadores que dominan al jugador
    int puntosg_assist;                // Número de asistencias del jugador
    int puntosg_roundWins;             // Número de rondas ganadas
    int puntosg_roundLose;             // Número de rondas perdidas
    int puntosbackstabEvent;           // Número de backstabs
    int puntosburningEvent;            // Número de eventos de quemaduras
    int puntossuicideEvent;            // Número de suicidios
    int puntostauntHadoukenEvent;      // Número de eventos de Hadouken
    int puntosburningFlareEvent;       // Número de eventos de quemadura con flare
    int puntostauntHighNoonEvent;      // Número de eventos de High Noon
    int puntostauntGrandSlamEvent;     // Número de eventos de Grand Slam
    int puntospenetrateMyTeamEvent;    // Número de penetraciones a su equipo
    int puntospenetrateHeadshotEvent;  // Número de headshots penetrantes
    int puntostelefragEvent;           // Número de telefrag
    int puntosflyingBurnEvent;         // Número de eventos de quema voladora
    int puntospumpkinBombEvent;        // Número de bombas de calabaza
    int puntosdecapitationEvent;       // Número de decapitaciones
    int puntosshotgunRevengeCritEvent; // Número de crits de venganza con escopeta
    int puntosfishKillEvent;           // Número de muertes por pez
    int puntostauntAllclassGuitarRiffEvent; // Número de taunts con guitarra
    int puntoskartEvent;               // Número de eventos de kart
    int puntosdragonsFuryIgniteEvent;  // Número de eventos de ignición de Dragons Fury
    int puntosslapKillEvent;           // Número de muertes por bofetada
    int puntosaxtinguishBoosterEvent;  // Número de eventos de axtinguish
    int puntosg_ObjectsDestroyed;      // Número de objetos destruidos
    int puntosg_BuildingsDestroyed;    // Número de construcciones destruidas
    int puntosg_EventsAssisted;        // Número de eventos asistidos
    // Otros eventos pueden agregarse aquí
}


// Estructura para almacenar la información del nivel
enum struct Nivel
{
    char nombre[64];   // Nombre del nivel
    int puntos_requeridos; // Puntos requeridos para el nivel
}




playerData playersdata[MAXPLAYERS + 1];
ConfigData g_Config;
int nivelesCargados = 0;
char nivelesNombres[MAX_NIVELES][MAX_NOMBRE];
int nivelesPuntos[MAX_NIVELES];

// Variables globales para la base de datos
Database g_DB;
char g_DBError[255];
Handle g_hHudSync = null;
Handle g_hHudTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };  // Almacena los timers de cada jugador
int g_LastProgress[MAXPLAYERS + 1] = { -1, ... }; // Almacena el último progreso mostrado para evitar actualizaciones innecesarias



// Esto se ejecuta cuando inicia el plugin
public void OnPluginStart()
{
    LoadTranslations("common.phrases");
    LoadTranslations("playerstats.phrases");
    LoadLevelsConfig();
    RegConsoleCmd("sm_minivel", Comando_MiNivel, "Muestra tu nivel actual");
    RegConsoleCmd("sm_niveles", ComandoNiveles, "Muestra los niveles en la consola.");
    RegAdminCmd("sm_test", Command_PrintMessage, ADMFLAG_GENERIC);
    HookEvent("player_death", OnPlayerDeathEventsStocks);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
    HookEvent("teamplay_round_win", Evento_RondaGanada, EventHookMode_Post);
    HookEvent("object_destroyed", OnObjectDestroyed);
    RegAdminCmd("sm_setpoints", Command_SetPoints, ADMFLAG_GENERIC, "Cambia los puntos de un jugador usando SteamID.");
    RegConsoleCmd("sm_rank", Command_ShowStats);
    

    g_DB = SQL_Connect("playerstats", false, g_DBError, sizeof(g_DBError));

    if (g_DB == null) {
        PrintToServer("Could not connect to 'playerstats': %s", g_DBError);
        return;
    } else {
        PrintToServer("Connection to playerstats successful.");
        createInitialBd();
    }
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max){
    MarkNativeAsOptional("GetUserMessageType");
    return APLRes_Success;
} 


// Función para mostrar las estadísticas en un menú con opciones interactivas
public Action ShowPlayerStatsMenu(int client)
{
    if (!client || !IsClientInGame(client)) return Plugin_Handled;
    CalcularNivel(client);
    char entry[128]; // Tamaño ajustado para cada ítem individual
    Format(entry, sizeof(entry), "%T", "menu_title", LANG_SERVER);
    // Crear el menú
    Menu menu = new Menu(PlayerStatsMenuHandler);
    menu.SetTitle("%s",entry);

    // Agregar ítems individuales para cada estadística

    // Puntos
    Format(entry, sizeof(entry), "%T", "menu_points", LANG_SERVER, playersdata[client].g_Points);
    menu.AddItem("points", entry);

    if(playersdata[client].g_PlayerPlayTime / 60.0 > 60) {
        Format(entry, sizeof(entry), "%T","menu_playtime_hours", LANG_SERVER,  (playersdata[client].g_PlayerPlayTime / 60.0) / 60.0);
        menu.AddItem("playtime", entry);
    }else{
        Format(entry, sizeof(entry), "%T","menu_playtime_minutes", LANG_SERVER, playersdata[client].g_PlayerPlayTime / 60.0);
        menu.AddItem("playtime", entry);
    }


    // Kills
    Format(entry, sizeof(entry), "%T", "menu_kills", LANG_SERVER,  playersdata[client].g_PlayerKills);
    menu.AddItem("kills", entry);

    // Deaths
    Format(entry, sizeof(entry), "%T", "menu_deaths", LANG_SERVER, playersdata[client].g_PlayerDeaths);
    menu.AddItem("deaths", entry);

    // Suicidios
    Format(entry, sizeof(entry), "%T", "menu_suicides", LANG_SERVER, playersdata[client].g_PlayerSuicides);
    menu.AddItem("suicides", entry);

    // Headshots
    Format(entry, sizeof(entry), "%T", "menu_headshots", LANG_SERVER, playersdata[client].g_PlayerHeadshots);
    menu.AddItem("headshots", entry);

    // Nivel
    Format(entry, sizeof(entry), "%T", "menu_level", LANG_SERVER, playersdata[client].g_PlayerLevel);
    menu.AddItem("level", entry);

    // Dominaciones
    Format(entry, sizeof(entry), "%T", "menu_dominations", LANG_SERVER, playersdata[client].g_dominando);
    menu.AddItem("dominations", entry);
    // Rondas Ganadas
    Format(entry, sizeof(entry), "%T", "menu_rounds_won", LANG_SERVER, playersdata[client].g_roundWins);
    menu.AddItem("rounds_won", entry);

    // Rondas Perdidas
    Format(entry, sizeof(entry), "%T", "menu_rounds_lost", LANG_SERVER, playersdata[client].g_roundLose);
    menu.AddItem("rounds_lost", entry);

    // Mostrar el menú al jugador
    menu.Display(client, 20);
    return Plugin_Handled;
}

// Manejo de selección del menú
public int PlayerStatsMenuHandler(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End)
        delete menu;
    
    return 0;
}

public Action Command_SetPoints(int client, int args)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;  // Verificamos que el jugador esté vivo

    char entry[128];
    // Verificar permisos de administrador
    if (!CheckCommandAccess(client, "sm_setpoints", ADMFLAG_GENERIC))
    {
        Format(entry, sizeof(entry), "%s %T", PLUGIN_PREFIX, "command_not_admin", LANG_SERVER);
        MC_ReplyToCommand(client, entry);
        return Plugin_Handled;
    }

    // Verificar que se proporcionaron los argumentos correctos
    if (args < 2)
    {
        Format(entry, sizeof(entry), "%s %T", PLUGIN_PREFIX, "setpoints_usage", LANG_SERVER);
        MC_ReplyToCommand(client, entry);
        return Plugin_Handled;
    }

    // Obtener los argumentos
    char targetArg[MAX_NAME_LENGTH];
    char pointsArg[32];

    GetCmdArg(1, targetArg, sizeof(targetArg));
    GetCmdArg(2, pointsArg, sizeof(pointsArg));

    // Convertir los puntos a número
    int newPoints = StringToInt(pointsArg);
    if (newPoints < 0)
    {
        Format(entry, sizeof(entry), "%s %T", PLUGIN_PREFIX, "negative_points", LANG_SERVER);
        MC_ReplyToCommand(client, entry);
        return Plugin_Handled;
    }

    // Buscar al jugador por nombre o SteamID
    int target = FindTarget(client, targetArg, true);
    if (target == -1)
    {
        Format(entry, sizeof(entry), "%s %T", PLUGIN_PREFIX, "player_not_found", LANG_SERVER);
        MC_ReplyToCommand(client, entry);
        return Plugin_Handled;
    }

    // Obtener la SteamID del jugador
    char steamID[32];
    GetClientAuthId(target, AuthId_Steam2, steamID, sizeof(steamID));

    // Construir la consulta SQL usando la SteamID
    char query[256];
    Format(query, sizeof(query), SQL_UPDATE_ADMIN_POINTS, newPoints, steamID);

    // Ejecutar la consulta
    if (ExecuteQuery(query))
    {
        playersdata[target].g_Points = newPoints;
        if(g_Config.use_hud!=0){
            ShowLevelProgress(target);
        }
        Format(entry, sizeof(entry), "%s %T", PLUGIN_PREFIX, "points_ok", LANG_SERVER, target, newPoints);
        MC_ReplyToCommand(client, entry);
    }
    else
    {
        Format(entry, sizeof(entry), "%s %T", PLUGIN_PREFIX, "points_bad", LANG_SERVER);
        MC_ReplyToCommand(client, entry);
    }

    return Plugin_Handled;
}


// Función para ejecutar consultas
bool ExecuteQuery(const char[] query)
{
    if (g_DB == null)
    {
        PrintToServer("Database connection is not established.");
        return false;
    }

    if (!SQL_FastQuery(g_DB, query))
    {
        SQL_GetError(g_DB, g_DBError, sizeof(g_DBError));
        PrintToServer("Query execution failed (error: %s)", g_DBError);
        return false;
    }

    return true;
}


// Función para crear la tabla y realizar otras operaciones iniciales
public void createInitialBd()
{
    if (g_DB == null)  // Verifica si la conexión falló
    {
        PrintToServer("Error: No se pudo conectar a la base de datos.");
        return;
    }

    char driverName[32];
    SQL_ReadDriver(g_DB, driverName, sizeof(driverName));

    PrintToServer("El driver de la base de datos es: %s", driverName);

    SQL_ReadDriver(g_DB, driverName, sizeof(driverName));

    if (StrEqual(driverName, "mysql", false))
    {
        PrintToServer("Usando MySQL");
        if (!ExecuteQuery(SQL_CREATETABLE_MYSQL))
        {
            PrintToServer("Failed to create table.");
            return;
        }
    }
    else if (StrEqual(driverName, "sqlite", false))
    {
        PrintToServer("Usando SQLite");
        if (!ExecuteQuery(SQL_CREATETABLE_SQLITE))
        {
            PrintToServer("Failed to create table.");
            return;
        }
    }
    else
    {
        PrintToServer("Driver desconocido: %s", driverName);
    }

    PrintToServer("Initial database setup completed.");
}



void LoadLevelsConfig()
{
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/playerlevels.cfg");

    KeyValues kv = new KeyValues("playerlevels");

    if (!kv.ImportFromFile(path))
    {
        LogError("No se pudo cargar el archivo de configuración: %s", path);
        delete kv;
        return;
    }

    if (!kv.GotoFirstSubKey())
    {
        LogError("No hay niveles definidos en el archivo.");
        delete kv;
        return;
    }

    nivelesCargados = 0; // Resetear la cantidad de niveles cargados

    do
    {
        kv.GetString("levelname", nivelesNombres[nivelesCargados], MAX_NOMBRE, "Desconocido");
        nivelesPuntos[nivelesCargados] = kv.GetNum("puntos_requeridos", 0);
        nivelesCargados++;

        if (nivelesCargados >= MAX_NIVELES)
        {
            break;
        }

    } while (kv.GotoNextKey());

    delete kv;

    // Ordenar los niveles cargados
    OrdenarNiveles(nivelesCargados);
}

// Ordenamiento burbuja para ordenar niveles según los puntos requeridos
void OrdenarNiveles(int cantidad)
{
    for (int i = 0; i < cantidad - 1; i++)
    {
        for (int j = 0; j < cantidad - i - 1; j++)
        {
            if (nivelesPuntos[j] > nivelesPuntos[j + 1])
            {
                // Intercambiar puntos
                int tempPuntos = nivelesPuntos[j];
                nivelesPuntos[j] = nivelesPuntos[j + 1];
                nivelesPuntos[j + 1] = tempPuntos;

                // Intercambiar nombres
                char tempNombre[MAX_NOMBRE];
                strcopy(tempNombre, sizeof(tempNombre), nivelesNombres[j]);
                strcopy(nivelesNombres[j], sizeof(nivelesNombres[j]), nivelesNombres[j + 1]);
                strcopy(nivelesNombres[j + 1], sizeof(nivelesNombres[j + 1]), tempNombre);
            }
        }
    }
}

void ImprimirNiveles(int client)
{
    if (nivelesCargados == 0)
    {
        if (client == 0)
        {
            LogMessage("No hay niveles cargados.");
        }
        else
        {
            PrintToConsole(client, "No hay niveles cargados.");
        }
        return;
    }

    if (client == 0)
    {
        LogMessage("Niveles cargados y ordenados:");
    }
    else
    {
        PrintToConsole(client, "Niveles cargados y ordenados:");
    }

    for (int i = 0; i < nivelesCargados; i++)  // Solo iterar hasta nivelesCargados
    {
        if (client == 0)
        {
            LogMessage("Nivel %d: %s - Puntos requeridos: %d", i + 1, nivelesNombres[i], nivelesPuntos[i]);
        }
        else
        {
            PrintToConsole(client, "Nivel %d: %s - Puntos requeridos: %d", i + 1, nivelesNombres[i], nivelesPuntos[i]);
        }
    }
}

// Función auxiliar para cargar los valores de configuración
void LoadConfigValues(KeyValues kv, ConfigData config)
{
    config.use_hud = kv.GetNum("use_hud", 0);    
    config.puntosg_PlayerKills = kv.GetNum("puntosg_PlayerKills", 100);
    config.puntosg_PlayerDeaths = kv.GetNum("puntosg_PlayerDeaths", 100); 
    config.puntosg_PlayerSuicides= kv.GetNum("puntosg_PlayerSuicides", 100);
    config.puntosg_PlayerHeadshots  = kv.GetNum("puntosg_PlayerHeadshots", 100);  
    config.puntosg_PlayerLevel= kv.GetNum("puntosg_PlayerLevel", 100);
    config.puntosg_dominando = kv.GetNum("puntosg_dominando", 100); 
    config.puntosg_dominado = kv.GetNum("puntosg_dominado", 100);        
    config.puntosg_assist= kv.GetNum("puntosg_assist", 100);
    config.puntosg_roundWins= kv.GetNum("puntosg_roundWins", 100);
    config.puntosg_roundLose= kv.GetNum("puntosg_roundLose", 100);
    config.puntosbackstabEvent= kv.GetNum("puntosbackstabEvent", 100);
    config.puntosburningEvent= kv.GetNum("puntosburningEvent", 100);
    config.puntossuicideEvent= kv.GetNum("puntossuicideEvent", 100);
    config.puntostauntHadoukenEvent= kv.GetNum("puntostauntHadoukenEvent", 100);
    config.puntosburningFlareEvent = kv.GetNum("puntosburningFlareEvent", 100);
    config.puntostauntHighNoonEvent = kv.GetNum("puntostauntHighNoonEvent", 100);
    config.puntostauntGrandSlamEvent = kv.GetNum("puntostauntGrandSlamEvent", 100);
    config.puntospenetrateMyTeamEvent = kv.GetNum("puntospenetrateMyTeamEvent", 100);
    config.puntospenetrateHeadshotEvent = kv.GetNum("puntospenetrateHeadshotEvent", 100);
    config.puntostelefragEvent = kv.GetNum("puntostelefragEvent", 100);
    config.puntosflyingBurnEvent = kv.GetNum("puntosflyingBurnEvent", 100);
    config.puntospumpkinBombEvent = kv.GetNum("puntospumpkinBombEvent", 100);
    config.puntosdecapitationEvent = kv.GetNum("puntosdecapitationEvent", 100);
    config.puntosshotgunRevengeCritEvent = kv.GetNum("puntosshotgunRevengeCritEvent", 100);
    config.puntosfishKillEvent = kv.GetNum("puntosfishKillEvent", 100);
    config.puntostauntAllclassGuitarRiffEvent = kv.GetNum("puntostauntAllclassGuitarRiffEvent", 100);
    config.puntoskartEvent = kv.GetNum("puntoskartEvent", 100);
    config.puntosdragonsFuryIgniteEvent = kv.GetNum("puntosdragonsFuryIgniteEvent", 100);
    config.puntosslapKillEvent = kv.GetNum("puntosslapKillEvent", 100);
    config.puntosaxtinguishBoosterEvent= kv.GetNum("puntosaxtinguishBoosterEvent", 100);
    config.puntosg_ObjectsDestroyed = kv.GetNum("puntosg_ObjectsDestroyed", 100);
    config.puntosg_BuildingsDestroyed = kv.GetNum("puntosg_BuildingsDestroyed", 100);
    config.puntosg_EventsAssisted = kv.GetNum("puntosg_EventsAssisted", 100);
}

ConfigData LoadConfig()
{
    ConfigData config;

    // Obtener el nombre del mapa actual usando GetCurrentMap
    char mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));

    // Buscar si el mapa contiene un guion bajo
    int underscoreIndex = StrContains(mapName, "_", true); // Buscar guion bajo

    // Si encontramos un guion bajo, extraemos el prefijo
    char prefix[64];
    if (underscoreIndex != -1)
    {
        // Copiar el prefijo antes del guion bajo
        strcopy(prefix, sizeof(prefix), mapName);
        prefix[underscoreIndex] = '\0'; // Terminamos el prefijo en el guion bajo
    }
    else
    {
        // Si no encontramos un guion bajo, usamos el nombre completo como prefijo
        strcopy(prefix, sizeof(prefix), mapName);
    }

    // Crear la ruta para el archivo de configuración específico del mapa
    char mapConfigPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, mapConfigPath, sizeof(mapConfigPath), "configs/playerstatsmaps/%s_.cfg", prefix);

    // Verificar si existe un archivo de configuración para el prefijo del mapa
    KeyValues kv = new KeyValues("playerstats");

    // Intentamos cargar la configuración específica del mapa
    if (kv.ImportFromFile(mapConfigPath))  // Si el archivo específico del mapa existe
    {
        LogMessage("Cargando configuración específica del mapa: %s", mapConfigPath);
        LoadConfigValues(kv, config); // Cargar valores del archivo específico del mapa
    }
    else  // Si el archivo específico del mapa no existe, cargar la configuración global
    {
        LogMessage("No se encontró configuración para el prefijo del mapa. Cargando configuración global.");

        // Cargar la configuración global
        char globalConfigPath[PLATFORM_MAX_PATH];
        BuildPath(Path_SM, globalConfigPath, sizeof(globalConfigPath), "configs/playerstats.cfg");

        if (!kv.ImportFromFile(globalConfigPath))  // Si no se puede cargar el archivo global
        {
            LogError("No se pudo cargar el archivo de configuración global: %s", globalConfigPath);

            // Valores predeterminados si no se puede cargar el archivo
            config.use_hud = 0;
            config.puntosg_PlayerKills = 20;
            config.puntosg_PlayerDeaths = 20; 
            config.puntosg_PlayerSuicides = 20;
            config.puntosg_PlayerHeadshots = 20;  
            config.puntosg_PlayerLevel = 20;
            config.puntosg_dominando = 20;
            config.puntosg_dominado = 20;       
            config.puntosg_assist = 20;
            config.puntosg_roundWins = 20;
            config.puntosg_roundLose = 20;
            config.puntosbackstabEvent = 20;
            config.puntosburningEvent = 20;
            config.puntossuicideEvent = 20;
            config.puntostauntHadoukenEvent = 20;
            config.puntosburningFlareEvent = 20;
            config.puntostauntHighNoonEvent = 20;
            config.puntostauntGrandSlamEvent = 20;
            config.puntospenetrateMyTeamEvent = 20;
            config.puntospenetrateHeadshotEvent = 20;
            config.puntostelefragEvent = 20;
            config.puntosflyingBurnEvent = 20;
            config.puntospumpkinBombEvent = 20;
            config.puntosdecapitationEvent = 20;
            config.puntosshotgunRevengeCritEvent = 20;
            config.puntosfishKillEvent = 20;
            config.puntostauntAllclassGuitarRiffEvent = 20;
            config.puntoskartEvent = 20;
            config.puntosdragonsFuryIgniteEvent = 20;
            config.puntosslapKillEvent = 20;
            config.puntosaxtinguishBoosterEvent = 20;
            config.puntosg_ObjectsDestroyed = 20;
            config.puntosg_BuildingsDestroyed = 20;
            config.puntosg_EventsAssisted = 20;

        }
        else
        {
            LoadConfigValues(kv, config); // Cargar valores del archivo global
        }
    }

    // Liberar la memoria de la variable KeyValues
    delete kv;

    return config;
}




// Timer para actualizar el HUD cada 5 segundos
public Action Timer_UpdateHUD(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (!IsValidClient(client) || !IsPlayerAlive(client))
    {
        g_hHudTimer[client] = INVALID_HANDLE;
        return Plugin_Stop;  // Eliminamos el timer si el jugador ya no es válido o está muerto
    }
    if(g_Config.use_hud!=0){
        ShowLevelProgress(client);
    }

    return Plugin_Continue;
}
// Muestra el mensaje en el HUD
// Muestra el mensaje en el HUD
void ShowHudMessage(int client, const char[] message)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return;  // No mostramos el HUD si está muerto

    if (g_hHudSync == INVALID_HANDLE)
    {
        g_hHudSync = CreateHudSynchronizer();
        if (g_hHudSync == INVALID_HANDLE)
        {
            PrintToServer("[HUD ERROR] No se pudo crear el HUD synchronizer.");
            return;
        }
    }

    SetHudTextParams(0.01, 0.1, 10.0, 255, 255, 255, 255, 0);
    ShowSyncHudText(client, g_hHudSync, message);
}


// Llamar a ShowLevelProgress cuando el jugador haga respawn
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));

    if (IsValidClient(client) && IsPlayerAlive(client))
    {
        if(g_Config.use_hud!=0){
            ShowLevelProgress(client);
        }
    }
}



// Función para verificar si el jugador existe en la base de datos
bool CheckIfPlayerExists(const char[] steamId)
{
    // Aquí se crea la consulta para buscar el jugador en la base de datos
    char query[256];
    Format(query, sizeof(query), "SELECT id FROM ranks_players WHERE steamid = '%s'", steamId);

	DBResultSet hResult = SQL_Query(g_DB, query);
	if (hResult == null) {
	    PrintToServer("Error al ejecutar la consulta en la base de datos.");
	    return false;
	}
	bool playerExists = SQL_FetchRow(hResult);
	delete hResult;
	return playerExists;
}


// Función para crear un nuevo jugador en la base de datos
void CreateNewPlayerInDatabase(const char[] steamId, const char[] playerName, const char[] steamId64)
{
    // Crear la consulta SQL para insertar el nuevo jugador
    char query[2000];
	// Obtener el timestamp actual y formatearlo como una cadena
	int currentTimestamp = GetTime();
	char datetime[32];
	FormatTime(datetime, sizeof(datetime), "%Y-%m-%d %H:%M:%S", currentTimestamp);
	
	// Formatear la consulta para insertar en la base de datos
	Format(query, sizeof(query), SQL_PLAYER_NOT_EXISTS, steamId, steamId64, playerName, datetime);




    // Usar la función ExecuteQuery para ejecutar la consulta
    if (!ExecuteQuery(query))
    {
        PrintToServer("Error al registrar al jugador en la base de datos.");
    }
    else
    {
        PrintToServer("Jugador registrado exitosamente en la base de datos.");
    }
}

bool LoadPlayerDataFromDatabase(int client, const char[] steamId)
{
    char query[2000]; // Aumentamos el tamaño del buffer para la consulta
    Format(query, sizeof(query), SQL_SELECT_INFO, steamId);

    // Ejecutar la consulta
    DBResultSet hResult = SQL_Query(g_DB, query);
    if (hResult == null)
    {
        PrintToServer("Error al cargar los datos del jugador desde la base de datos.");
        return false;
    }

    if (SQL_FetchRow(hResult)) {
        playersdata[client].g_PlayerKills = SQL_FetchInt(hResult, 0);
        playersdata[client].g_PlayerDeaths = SQL_FetchInt(hResult, 1);
        playersdata[client].g_PlayerSuicides = SQL_FetchInt(hResult, 2);
        playersdata[client].g_PlayerHeadshots = SQL_FetchInt(hResult, 3);
        playersdata[client].g_PlayerLevel = SQL_FetchInt(hResult, 4);
        playersdata[client].g_dominando = SQL_FetchInt(hResult, 5);
        playersdata[client].g_PlayerPlayTime = SQL_FetchFloat(hResult, 6);
        playersdata[client].g_Points = SQL_FetchInt(hResult, 7);
        playersdata[client].g_roundWins = SQL_FetchInt(hResult, 8);
        playersdata[client].g_roundLose = SQL_FetchInt(hResult, 9);
        playersdata[client].g_dominado = SQL_FetchInt(hResult, 10);
        playersdata[client].g_assist = SQL_FetchInt(hResult, 11);
        playersdata[client].backstabEvent = SQL_FetchInt(hResult, 12);
        playersdata[client].burningEvent = SQL_FetchInt(hResult, 13);
        playersdata[client].suicideEvent = SQL_FetchInt(hResult, 14);
        playersdata[client].tauntHadoukenEvent = SQL_FetchInt(hResult, 15);
        playersdata[client].burningFlareEvent = SQL_FetchInt(hResult, 16);
        playersdata[client].tauntHighNoonEvent = SQL_FetchInt(hResult, 17);
        playersdata[client].tauntGrandSlamEvent = SQL_FetchInt(hResult, 18);
        playersdata[client].penetrateMyTeamEvent = SQL_FetchInt(hResult, 19);
        playersdata[client].penetrateHeadshotEvent = SQL_FetchInt(hResult, 20);
        playersdata[client].telefragEvent = SQL_FetchInt(hResult, 21);
        playersdata[client].flyingBurnEvent = SQL_FetchInt(hResult, 22);
        playersdata[client].pumpkinBombEvent = SQL_FetchInt(hResult, 23);
        playersdata[client].decapitationEvent = SQL_FetchInt(hResult, 24);
        playersdata[client].shotgunRevengeCritEvent = SQL_FetchInt(hResult, 25);
        playersdata[client].fishKillEvent = SQL_FetchInt(hResult, 26);
        playersdata[client].tauntAllclassGuitarRiffEvent = SQL_FetchInt(hResult, 27);
        playersdata[client].kartEvent = SQL_FetchInt(hResult, 28);
        playersdata[client].dragonsFuryIgniteEvent = SQL_FetchInt(hResult, 29);
        playersdata[client].slapKillEvent = SQL_FetchInt(hResult, 30);
        playersdata[client].axtinguishBoosterEvent = SQL_FetchInt(hResult, 31);
        playersdata[client].g_ObjectsDestroyed = SQL_FetchInt(hResult, 32);
        playersdata[client].g_BuildingsDestroyed = SQL_FetchInt(hResult, 33);
        playersdata[client].g_EventsAssisted = SQL_FetchInt(hResult, 34);

        delete hResult;
        return true;
    }

    // Liberar el resultado si no hay datos
    delete hResult;
    return false; // No se encontraron datos para el jugador
}



bool IsValidClient(int client, bool replaycheck = true)
{
    if (client <= 0 || client > MaxClients)
    {
        return false;
    }
    if (!IsClientInGame(client))
    {
        return false;
    }
    if (IsFakeClient(client))  // Filtrar bots
    {
        return false;
    }
    if (GetEntProp(client, Prop_Send, "m_bIsCoaching"))
    {
        return false;
    }
    if (replaycheck)
    {
        if (IsClientSourceTV(client) || IsClientReplay(client))
        {
            return false;
        }
    }
    return true;
}

void CalcularNivel(int client)
{
    // Verificar que los niveles estén cargados
    if (nivelesCargados == 0)
    {
        // Si no hay niveles cargados, asignar valores predeterminados
        playersdata[client].g_PlayerLevel = 0;
        strcopy(playersdata[client].g_LevelName, 64, "Desconocido");
        playersdata[client].g_points_required = 0;
        playersdata[client].g_points_lastlevel = 0;
        return;
    }

    // Variables para el cálculo
    int nivel = 0;
    char nombreNivel[64]; // Ajustar tamaño según sea necesario
    int puntosRequeridos = 0;
    int puntosUltimoNivel = 0;

    // Iterar sobre los niveles cargados
    for (int i = 0; i < nivelesCargados; i++)
    {
        // Si los puntos del jugador son suficientes para alcanzar este nivel, asignar el nivel y nombre
        if (playersdata[client].g_Points >= nivelesPuntos[i])
        {
            nivel = i + 1;  // El nivel está basado en el índice
            strcopy(nombreNivel, 64, nivelesNombres[i]);
            puntosRequeridos = nivelesPuntos[i + 1] - nivelesPuntos[i];  // Puntos necesarios para el siguiente nivel
            puntosUltimoNivel = nivelesPuntos[i];  // Últimos puntos alcanzados
        }
        else
        {
            break;  // Los niveles están ordenados, por lo que no es necesario seguir buscando
        }
    }

    // Asignar el nivel y nombre calculado a las variables globales del jugador
    playersdata[client].g_PlayerLevel = nivel-1;
    strcopy(playersdata[client].g_LevelName, 64, nombreNivel);
    playersdata[client].g_points_required = puntosRequeridos;
    playersdata[client].g_points_lastlevel = puntosUltimoNivel;
}

void ShowLevelProgress(int client)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return;  // Verificamos que el jugador esté vivo

    CalcularNivel(client);
    
    int progreso = 0;
    if (playersdata[client].g_points_required > 0)
    {
        progreso = (playersdata[client].g_Points - playersdata[client].g_points_lastlevel) * 100 / playersdata[client].g_points_required;
    }

    // Si el progreso no cambió, evitamos actualizar el HUD innecesariamente
    if (g_LastProgress[client] == progreso)
    {
        return;
    }
    g_LastProgress[client] = progreso;  // Guardamos el último progreso mostrado

    char message[256];
    Format(message, sizeof(message), "Nivel %d: %s\nProgreso: %d%%", 
        playersdata[client].g_PlayerLevel, 
        playersdata[client].g_LevelName, 
        progreso
    );

    // Si ya hay un HUD activo, eliminamos el anterior antes de crear uno nuevo
    if (g_hHudTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hHudTimer[client]);
        g_hHudTimer[client] = INVALID_HANDLE;
    }

    // Crear un nuevo HUD que se actualizará cada 5 segundos solo si el jugador sigue vivo
    g_hHudTimer[client] = CreateTimer(5.0, Timer_UpdateHUD, GetClientUserId(client), TIMER_REPEAT);

    // Mostrar el mensaje inicial
    ShowHudMessage(client, message);
}


public void OnClientPutInServer(int client)
{

	if (!IsValidClient(client)) return;  // Evita que bots reciban puntos
	
    char buffer[256];  // Se declara una sola vez al inicio

    playersdata[client].g_PlayerStartTime = GetClientTime(client); 

    // Obtiene el nombre y la SteamID del jugador
    char playerName[32], steamId[20], steamId64[20];

    GetClientName(client, playerName, sizeof(playerName));

    if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId), true) ||
        !GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true))
    {
        Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "player_invalid", LANG_SERVER);
        MC_PrintToChatAll("%s", buffer);
        return;
    }
    Format(buffer, sizeof(buffer), "%T", "player_connect", LANG_SERVER, playerName, steamId);
    MC_PrintToChatAll("%s",buffer);


    if (!CheckIfPlayerExists(steamId))
        CreateNewPlayerInDatabase(steamId, playerName, steamId64);

    // Cargar los datos del jugador (sea nuevo o existente)
    LoadPlayerDataFromDatabase(client, steamId);
    // Actualizar el nivel del jugador cuando cambien sus puntos
    CalcularNivel(client);


    PrintToServer("Tiempo: %.2f", playersdata[client].g_PlayerPlayTime);
}


void SavePlayerDataToDatabase(int client, const char[] steamId, float elapsedTime)
{
    // Crear la consulta SQL para actualizar los datos del jugador
    char query[2000];
	Format(query, sizeof(query),
           SQL_UPDATE_INFO,
        playersdata[client].g_PlayerKills,
        playersdata[client].g_PlayerDeaths, 
        playersdata[client].g_PlayerSuicides, 
        playersdata[client].g_PlayerHeadshots, 
        playersdata[client].g_PlayerLevel, 
        playersdata[client].g_dominando, 
        elapsedTime, 
        playersdata[client].g_Points,
        playersdata[client].g_roundWins, 
        playersdata[client].g_roundLose, 
        playersdata[client].g_dominado,
        playersdata[client].g_assist,
        playersdata[client].backstabEvent,
        playersdata[client].burningEvent,
        playersdata[client].suicideEvent,
        playersdata[client].tauntHadoukenEvent,
        playersdata[client].burningFlareEvent,
        playersdata[client].tauntHighNoonEvent,
        playersdata[client].tauntGrandSlamEvent,
        playersdata[client].penetrateMyTeamEvent,
        playersdata[client].penetrateHeadshotEvent,
        playersdata[client].telefragEvent,
        playersdata[client].flyingBurnEvent,
        playersdata[client].pumpkinBombEvent,
        playersdata[client].decapitationEvent,
        playersdata[client].shotgunRevengeCritEvent,
        playersdata[client].fishKillEvent,
        playersdata[client].tauntAllclassGuitarRiffEvent,
        playersdata[client].kartEvent,
        playersdata[client].dragonsFuryIgniteEvent,
        playersdata[client].slapKillEvent,
        playersdata[client].axtinguishBoosterEvent,
        playersdata[client].g_ObjectsDestroyed,
        playersdata[client].g_BuildingsDestroyed,
        playersdata[client].g_EventsAssisted,
        steamId);

    // Ejecutar la consulta
    if (!ExecuteQuery(query))
    {
        PrintToServer("Error al guardar los datos del jugador en la base de datos.");
    }
    else
    {
        PrintToServer("Datos del jugador guardados correctamente en la base de datos.");
    }
}



public void OnClientDisconnect(int client)
{
	if (!IsValidClient(client)) return;  // Evita que bots reciban puntos
        

    // Obtener SteamID
    char steamId[20];
    if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId), true))
    {
        PrintToServer("Error: No se pudo obtener la SteamID del jugador.");
        return;
    }
    
    // Obtenemos el tiempo actual y calculamos el tiempo transcurrido desde la conexión
    float currentTime = GetClientTime(client);
    float elapsedTime = currentTime - playersdata[client].g_PlayerStartTime; // Calculamos el tiempo transcurrido

    
    PrintToServer("Tiempo transcurrido del jugador %d: %.2f segundos", client, elapsedTime);

    // Guardar datos al desconectarse
    SavePlayerDataToDatabase(client, steamId, elapsedTime);
}	

void UpdatePlayerPoints(int player, int pointsChange) {
    playersdata[player].g_Points += pointsChange;
    if (playersdata[player].g_Points < 0) {
        playersdata[player].g_Points = 0;
    }
}

public void OnPlayerDeathEventsStocks(Event event, const char[] name, bool dontBroadcast) {
    // Obtención de datos básicos del evento
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int assister = GetClientOfUserId(event.GetInt("assister"));
    int customkill = event.GetInt("customkill");
    if (attacker==0) return;
    int deathFlags = event.GetInt("death_flags");  // Obtenemos las banderas de la muerte
    char weapon[64];
    char buffer[255];
    event.GetString("weapon", weapon, sizeof(weapon));

    // Variable para los nombres
    char nameAttacker[64];
    char nameVictim[64];
    GetClientName(attacker, nameAttacker, sizeof(nameAttacker));
    GetClientName(victim, nameVictim, sizeof(nameVictim));

    // Verificamos si el atacante dominó al jugador
    if (attacker > 0 && deathFlags & TF_DEATHFLAG_KILLERDOMINATION) {
        Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "g_dominando", LANG_SERVER, attacker, victim);
        MC_PrintToChat(attacker,buffer);

        playersdata[attacker].g_dominando += 1;  // Aumentamos el contador de dominaciones
        playersdata[victim].g_dominado += 1;  // Incrementamos un contador en la víctima
    }
    if (victim != attacker){
        playersdata[victim].g_PlayerDeaths += 1;
        playersdata[attacker].g_PlayerKills += 1; 
        playersdata[assister].g_assist += 1; 
        playersdata[attacker].g_Points += g_Config.puntosg_PlayerKills;
        UpdatePlayerPoints(attacker, g_Config.puntosg_PlayerKills);
        UpdatePlayerPoints(assister, -g_Config.puntosg_PlayerKills);
        UpdatePlayerPoints(victim, -g_Config.puntosg_PlayerKills);
    }

    // Manejamos los eventos personalizados de muertes
    switch (customkill) {
        case TF_CUSTOM_HEADSHOT: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "headshot", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].g_PlayerHeadshots += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosg_PlayerHeadshots);
            return;
        }
        case TF_CUSTOM_BACKSTAB: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "backstabs", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].backstabEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosbackstabEvent);
            return;
        }
        case TF_CUSTOM_BURNING: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "burning", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].burningEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosburningEvent);
            return;
        }
        case TF_CUSTOM_SUICIDE: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "Suicides", LANG_SERVER, victim);
            MC_PrintToChat(victim,buffer);

            playersdata[victim].g_PlayerSuicides += 1; // Incrementa los suicidios del jugador
            UpdatePlayerPoints(attacker, -g_Config.puntosg_PlayerSuicides);
            return;
        }
        case TF_CUSTOM_TAUNT_HADOUKEN: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "Hadouken", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].tauntHadoukenEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntostauntHadoukenEvent);
            return;
        }
        case TF_CUSTOM_BURNING_FLARE: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "burningFlareEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].burningFlareEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosburningFlareEvent);
            return;
        }
        case TF_CUSTOM_TAUNT_HIGH_NOON: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "tauntHighNoonEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].tauntHighNoonEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntostauntHighNoonEvent);
            return;
        }
        case TF_CUSTOM_TAUNT_GRAND_SLAM: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "slam", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].tauntGrandSlamEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntostauntGrandSlamEvent);
            return;
        }
        case TF_CUSTOM_PENETRATE_MY_TEAM: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "penetrateMyTeamEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].penetrateMyTeamEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntospenetrateMyTeamEvent);
            return;
        }
        case TF_CUSTOM_PENETRATE_HEADSHOT: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "penetrateHeadshotEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].penetrateHeadshotEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntospenetrateHeadshotEvent);
            return;
        }
        case TF_CUSTOM_TELEFRAG: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "telefragEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].telefragEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntostelefragEvent);
            return;
        }
        case TF_CUSTOM_FLYINGBURN: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "flyingBurnEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].flyingBurnEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosflyingBurnEvent);
            return;
        }
        case TF_CUSTOM_PUMPKIN_BOMB: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "pumpkinBombEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].pumpkinBombEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntospumpkinBombEvent);
            return;
        }
        case TF_CUSTOM_DECAPITATION: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "decapitationEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].decapitationEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosdecapitationEvent);
            return;
        }
        case TF_CUSTOM_SHOTGUN_REVENGE_CRIT: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "shotgunRevengeCritEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].shotgunRevengeCritEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosshotgunRevengeCritEvent);
            return;
        }
        case TF_CUSTOM_FISH_KILL: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "fishKillEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].fishKillEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosfishKillEvent);
            return;
        }
        case TF_CUSTOM_TAUNT_ALLCLASS_GUITAR_RIFF: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "tauntAllclassGuitarRiffEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].tauntAllclassGuitarRiffEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntostauntAllclassGuitarRiffEvent);
            return;
        }
        case TF_CUSTOM_KART: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "kartEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].kartEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntoskartEvent);
            return;
        }
        case TF_CUSTOM_DRAGONS_FURY_IGNITE: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "dragonsFuryIgniteEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].dragonsFuryIgniteEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosdragonsFuryIgniteEvent);
            return;
        }
        case TF_CUSTOM_SLAP_KILL: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "slapKillEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].slapKillEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosslapKillEvent);
            return;
        }
        case TF_CUSTOM_AXTINGUISHER_BOOSTED: {
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "axtinguishBoosterEvent", LANG_SERVER, attacker, victim);
            MC_PrintToChat(attacker,buffer);

            playersdata[attacker].axtinguishBoosterEvent += 1;
            UpdatePlayerPoints(attacker,g_Config.puntosaxtinguishBoosterEvent);
            return;
        }
        default: {
            if (victim != attacker || attacker!=0){
                Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "kill_not_event", LANG_SERVER, attacker, victim);
                MC_PrintToChat(attacker,buffer);
                return;
            }
        }

    }

}

public void OnObjectDestroyed(Event event, const char[] name, bool dontBroadcast) {
    int owner = GetClientOfUserId(event.GetInt("userid")); // Propietario del objeto
    int attacker = GetClientOfUserId(event.GetInt("attacker")); // Jugador que destruyó el objeto
    int assister = GetClientOfUserId(event.GetInt("assister")); // Jugador que asistió (si hay uno)
    char weapon[64];
    char buffer[255];
    event.GetString("weapon", weapon, sizeof(weapon)); // Arma usada para destruir el objeto
    bool wasBuilding = event.GetBool("was_building"); // ¿Era un objeto en construcción?

    // Obtener los nombres de los jugadores
    char nameAttacker[64], nameAssister[64], nameOwner[64];
    GetClientName(attacker, nameAttacker, sizeof(nameAttacker));
    if (assister > 0) GetClientName(assister, nameAssister, sizeof(nameAssister));
    GetClientName(owner, nameOwner, sizeof(nameOwner));

    // Mensaje de destrucción
    if (wasBuilding) {
        Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "g_BuildingsDestroyed", LANG_SERVER, attacker, owner, weapon);
        MC_PrintToChat(attacker,buffer);
    } else {
        Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "g_ObjectsDestroyed", LANG_SERVER, attacker, owner, weapon);
        MC_PrintToChat(attacker,buffer);
    }

    // Registra las estadísticas para el atacante
    playersdata[attacker].g_ObjectsDestroyed += 1; // Aumenta el contador de destrucción de objetos
    UpdatePlayerPoints(attacker, g_Config.puntosg_ObjectsDestroyed); // Puntos por destruir el objeto

    // Si hay un asistente, registra su asistencia
    if (assister > 0) {
        playersdata[assister].g_assist += 1; // Aumenta el contador de asistencias
        UpdatePlayerPoints(assister, g_Config.puntosg_assist); // Puntos por asistencia
    }

    // Si el objeto destruido es una construcción, se puede registrar de manera diferente si lo deseas
    if (wasBuilding) {
        // Agregar lógica especial si se destruyó una construcción, como contar puntos extra, etc.
        playersdata[attacker].g_BuildingsDestroyed += 1;
        UpdatePlayerPoints(assister, g_Config.puntosg_BuildingsDestroyed); // Puntos por asistencia
    }
}


// Evento cuando un equipo gana una ronda
public void Evento_RondaGanada(Event event, const char[] name, bool dontBroadcast)
{
    char buffer[256]; 
    int equipoGanador = event.GetInt("team"); // 2 = RED, 3 = BLU
    int equipoPerdedor = (equipoGanador == 2) ? 3 : 2; // Si ganó RED, perdió BLU y viceversa

    // Recorremos todos los jugadores en el servidor
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue; // Ignoramos bots y jugadores desconectados

        if (GetClientTeam(i) == equipoGanador) // Si el jugador está en el equipo ganador
        {
            playersdata[i].g_roundWins += 1; // Aumenta las rondas ganadas
            UpdatePlayerPoints(i,g_Config.puntosg_roundWins);
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "Round_Wins", LANG_SERVER, playersdata[i].g_roundWins, g_Config.puntosg_roundWins);
            MC_PrintToChat(i,buffer);
        }
        else if (GetClientTeam(i) == equipoPerdedor) // Si el jugador está en el equipo perdedor
        {
            playersdata[i].g_roundLose += 1; // Aumenta las rondas perdidas
            UpdatePlayerPoints(i,g_Config.puntosg_roundLose);
            Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "Round_Lose", LANG_SERVER, playersdata[i].g_roundLose, g_Config.puntosg_roundLose);
            MC_PrintToChat(i,buffer);
        }
    }
}


// ====[ COMMANDS ]============================================================

// Comando para mostrar las estadísticas del jugador
public Action Command_ShowStats(int client, int args)
{
    ShowPlayerStatsMenu(client);
    return Plugin_Handled;
}

public Action ComandoNiveles(int client, int args)
{
    if (client == 0) {
        ReplyToCommand(client, "Este comando solo puede ser usado por jugadores.");
        return Plugin_Handled;
    }

    ImprimirNiveles(client);
    return Plugin_Handled;
}

// Función que maneja el comando
public Action Comando_MiNivel(int client, int args)
{
    char buffer[255];
    // Verificar si el comando es ejecutado por un jugador válido
    if (client == 0 || !IsClientInGame(client))
    {
        Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "mylevelnotPlayer", LANG_SERVER);
        MC_ReplyToCommand(client,buffer);

        return Plugin_Handled;
    }

    // Asegurar que el nivel ya se haya calculado antes de mostrarlo
    CalcularNivel(client);

    // Obtener los valores del nivel del jugador
    int nivel = playersdata[client].g_PlayerLevel;
    char nombreNivel[64];
    strcopy(nombreNivel, sizeof(nombreNivel), playersdata[client].g_LevelName);

    // Enviar el mensaje al jugador
    Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "mylevelcommand", LANG_SERVER, nivel, nombreNivel);
    MC_PrintToChat(client,buffer);

    return Plugin_Handled;
}

public Action Command_PrintMessage(int client , int args)
{
    char test[20];
    test = "123";
    char buffer[256]; 
    Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "player_connect", LANG_SERVER, test, test);
    MC_PrintToChatAll("%s", buffer);
    char buffer2[256]; 
    Format(buffer2, sizeof(buffer2), "%s %T", PLUGIN_PREFIX, "test", LANG_SERVER, test);
    MC_PrintToChat(client,buffer2);
    Format(buffer, sizeof(buffer), "%s %T", PLUGIN_PREFIX, "player_invalid", LANG_SERVER);
    MC_PrintToChatAll("%s", buffer);
    return Plugin_Handled;
}

public void OnMapStart()
{
    g_Config = LoadConfig();
}

public void OnPluginEnd()
{
    if (g_DB != null)
    {
        delete g_DB;
    }
}
