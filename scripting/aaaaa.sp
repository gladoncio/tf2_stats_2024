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
	description = "Un plugin que registrara las stats y registrara un sistema de niveles", 
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



// Esto se ejecuta cuando inicia el plugin
public void OnPluginStart()
{
    RegAdminCmd("sm_hud", Command_PrintMessage , ADMFLAG_GENERIC);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("player_spawn",Event_PlayerSpawn, EventHookMode_Pre);
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
        CreateTimer(10.0, Timer_ShowSecondMessage, client);
    }
    else
    {
        // Hubo un error al obtener la SteamID
        PrintToChatAll("Jugador conectado: %s (SteamID no disponible)", playerName);
        CreateTimer(10.0, Timer_ShowSecondMessage, client);
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
    g_PlayerDeaths[victimId] += 1;
    int attackerId = event.GetInt("attacker");
    bool headshot = event.GetBool("headshot");
    event.GetString("weapon", weapon, sizeof(weapon));

    // variable para los nombres

    char nameAttacker[64];
    char nameVictim[64];
    int victim = GetClientOfUserId(victimId);
    int attacker = GetClientOfUserId(attackerId);
    GetClientName(attacker, nameAttacker, sizeof(nameAttacker));
    GetClientName(victim, nameVictim, sizeof(nameVictim));
 
    PrintToConsole(victim,
        "You were killed by \"%s\" (weapon \"%s\") (headshot \"%d\")",
        nameAttacker,
        weapon,
        headshot);

    char mensaje[64];
    Format(mensaje, sizeof(mensaje), "murio %s y muertes: %d", nameVictim , g_PlayerDeaths[victimId]);
    ShowHudMessage(victim, mensaje);

}

// Este es solamente un timer para ejecutar la funcion que imprimira el hud
public Action Timer_ShowSecondMessage(Handle timer, any client)
{
    // Muestra el segundo mensaje después de 3 segundos
    ShowHudMessage(client, "¡Sistema de niveles incoming!");

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
