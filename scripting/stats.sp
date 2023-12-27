#include <sourcemod>
#include <tf2_stocks>
// ^ tf2_stocks.inc itself includes sdktools.inc and tf2.inc

#pragma semicolon 1
#pragma newdecls required


#define PLUGIN_VERSION "0.00"




public Plugin myinfo = 
{
	name = "Nombre del plugin aquí", 
	author = "Tu nombre aquí", 
	description = "Breve descripción de la funcionalidad del plugin aquí", 
	version = PLUGIN_VERSION, 
	url = "Tu URL de sitio web/Perfil de AlliedModders"
};


public Plugin myPlugin;

// Implement the forward callback
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


public void OnPluginStart()
{
    RegAdminCmd("sm_printmessage", Command_PrintMessage, ADMFLAG_GENERIC);
	
}


public void OnClientPutInServer(int client)
{

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


// ====[ COMMANDS ]============================================================

public Action Command_PrintMessage(int iClient, int iArgs)
{
    if (iArgs < 3) {
        // Not enough arguments provided
        ReplyToCommand(iClient, "Usage: sm_printmessage <x> <y> <message>");
        return Plugin_Handled;
    }

    float flX = GetCmdArgFloat(1);
    float flY = GetCmdArgFloat(2);
    char strMessage[255];

    // Concatenate remaining arguments as the message
    GetCmdArg(3, strMessage, sizeof(strMessage));

    // Check if the client is in game
    if (!IsClientInGame(iClient)) {
        ReplyToCommand(iClient, "Invalid client or not in game.");
        return Plugin_Handled;
    }

    // Create a new HUD synchronizer handle
    Handle hHudSync = CreateHudSynchronizer();
    if (hHudSync == INVALID_HANDLE) {
        ReplyToCommand(iClient, "Failed to create HUD synchronizer.");
        return Plugin_Handled;
    }

    // Print the message on the screen at the specified coordinates
    SetHudTextParams(flX, flY, 10.0, 255, 255, 255, 255, 0);
    ShowSyncHudText(iClient, hHudSync, strMessage);

    // Destroy the HUD synchronizer handle
    CloseHandle(hHudSync);

    ReplyToCommand(iClient, "Message printed at coordinates (%.2f, %.2f): %s", flX, flY, strMessage);

    return Plugin_Handled;
}


public void OnMapStart()
{
	/**
     * @note Precarga tus modelos, sonidos, etc. aquí.
     * ¡No en OnConfigsExecuted! Hacerlo aquí evita problemas.
     */
}
