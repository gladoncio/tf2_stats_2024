#include <sourcemod>
#include <tf2_stocks>


// ^ tf2_stocks.inc itself includes sdktools.inc and tf2.inc

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"

public Plugin myinfo =
{
    name = "TF2 rank / stats ",
    author = "Gladoncio",
    description = "Un plugin que registrará las stats y registrará un sistema de niveles",
    version = PLUGIN_VERSION,
    url = "Tu URL de sitio web/Perfil de AlliedModders"
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

// Aqui se definen las variables que se usaran
int g_PlayerKills[MAXPLAYERS + 1];
int g_PlayerDeaths[MAXPLAYERS + 1];
int g_PlayerSuicides[MAXPLAYERS + 1];

// Variables globales para la base de datos
Database g_DB;
char g_DBError[255];

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
    // Ejecuta los queries iniciales
    if (!ExecuteQuery("CREATE TABLE IF NOT EXISTS ranks_players (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, steamid TEXT, kills INTEGER, deaths INTEGER, suicides INTEGER, headshots INTEGER, level INTEGER, dominations INTEGER)"))
    {
        PrintToServer("Failed to create table.");
        return;
    }

    PrintToServer("Initial database setup completed.");
}

// Esto se ejecuta cuando inicia el plugin
public void OnPluginStart()
{
    RegAdminCmd("sm_hud", Command_PrintMessage, ADMFLAG_GENERIC);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);

    // Conecta a la base de datos
    g_DB = SQL_Connect("aaaaa", false, g_DBError, sizeof(g_DBError));

    if (g_DB == null)
    {
        PrintToServer("Could not connect to 'aaaaa': %s", g_DBError);
    }
    else
    {
        createInitialBd();
    }
}




// esta es la funcion que usare para llamarala desde cualquier parte del codigo que imprima un hud con el nivel en pantalla
void ShowHudMessage(int client, const char[] message)
{
    
    Handle hHudSync = CreateHudSynchronizer();
    if (hHudSync == INVALID_HANDLE) {
        ReplyToCommand(client, "Failed to create HUD synchronizer.");
        return;
    }

    SetHudTextParams(0.01, 0.1, 10000.0, 255, 255, 255, 255, 0);
    ShowSyncHudText(client, hHudSync, message);

    // SetHudTextParams(0.01, 0.13, 10000.0, 255, 255, 255, 255, 0);
    // ShowSyncHudText(client, hHudSync, "Level: 0 I|||||||||||||");

    CloseHandle(hHudSync);
}


// Este es el evento para cuando un player hace respawn
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client_id = GetEventInt(event, "userid");
    int client = GetClientOfUserId(client_id);

    CreateTimer(2.0, Timer_ShowSecondMessage, client);

}






// Esta es la parte que carga cuando un player se conecta al servidor
public void OnClientPutInServer(int client)
{

    
    // Inicializar kills y deaths del jugador
    g_PlayerKills[client] = 0;
    g_PlayerDeaths[client] = 0;
    g_PlayerSuicides[client] = 0;
    
    

    // Obtiene el nombre del jugador
    char playerName[32];
    GetClientName(client, playerName, sizeof(playerName));

    
    // Obtiene la SteamID del jugador
    char steamId[20];
    if (GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId), true))
    {
        // La SteamID se obtuvo correctamente
        PrintToChatAll("Jugador conectado: %s (SteamID: %s)", playerName, steamId);
    }
    else
    {
        // Hubo un error al obtener la SteamID
        PrintToChatAll("Jugador conectado: %s (SteamID no disponible)", playerName);
    }
    
   
    // Obtiene la hora actual del servidor
    int currentTimestamp = GetTime();

    // Convierte el timestamp a una cadena de fecha y hora
    char datetime[32];
    FormatTime(datetime, sizeof(datetime), "%Y-%m-%d %H:%M:%S", currentTimestamp);

    // Imprime la hora actual en el chat del servidor
    PrintToChatAll("Hora actual del servidor: %s", datetime);
    

}


// En esta parte el hook definido arriba ara las acciones sobre despues de la muerte de un usuario , sumara o restara la kill y muerte de los usuarios respectivamente
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    char weapon[64];
    int victimId = event.GetInt("userid");
    int attackerId = event.GetInt("attacker");
    bool headshot = event.GetBool("headshot");
    event.GetString("weapon", weapon, sizeof(weapon));

    // Variable para los nombres
    char nameAttacker[64];
    char nameVictim[64];
    int victim = GetClientOfUserId(victimId);
    int attacker = GetClientOfUserId(attackerId);
    GetClientName(attacker, nameAttacker, sizeof(nameAttacker));
    GetClientName(victim, nameVictim, sizeof(nameVictim));

    // Verifica si el jugador que murió es el mismo que el atacante
    if (victim == attacker)
    {
        g_PlayerSuicides[victim] += 1; // Incrementa los suicidios del jugador que murió
    }
    else
    {
        g_PlayerDeaths[victim] += 1;
        g_PlayerKills[attacker] += 1; // Incrementa las muertes del jugador que murió
    }

    PrintToConsole(victim,
        "You were killed by \"%s\" (weapon \"%s\") (headshot \"%d\")",
        nameAttacker,
        weapon,
        headshot);


    char mensaje[64];
    Format(mensaje, sizeof(mensaje), "muertes %d, suicidios: %d y kills : %d", g_PlayerDeaths[attacker], g_PlayerSuicides[attacker], g_PlayerKills[attacker] );
    ShowHudMessage(attacker, mensaje);

    Format(mensaje, sizeof(mensaje), "muertes %d, suicidios: %d y kills : %d", g_PlayerDeaths[victim], g_PlayerSuicides[victim], g_PlayerKills[victim] );
    ShowHudMessage(victim, mensaje);

    // Crea un temporizador de 3 segundos para mostrar un segundo mensaje
    CreateTimer(3.0, Timer_ShowSecondMessage, victim);
}

// Este es solamente un timer para ejecutar la función que imprimirá el hud
public Action Timer_ShowSecondMessage(Handle timer, any client)
{
    char mensaje[64];
    Format(mensaje, sizeof(mensaje), "muertes %d, suicidios: %d y kills : %d", g_PlayerDeaths[client], g_PlayerSuicides[client], g_PlayerKills[client] );
    ShowHudMessage(client, mensaje);

    // Devuelve Plugin_Stop para que el temporizador no se repita
    return Plugin_Stop;
}


// ====[ COMMANDS ]============================================================

public Action Command_PrintMessage(int client , int args)
{
    ShowHudMessage(client, "hola");
    return Plugin_Handled;
}

public void OnMapStart()
{
	/**
     * @note Precarga tus modelos, sonidos, etc. aquí.
     * ¡No en OnConfigsExecuted! Hacerlo aquí evita problemas.
     */
}
