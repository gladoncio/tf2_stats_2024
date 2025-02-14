#include <sourcemod>
#include <tf2_stocks>



// ^ tf2_stocks.inc itself includes sdktools.inc and tf2.inc

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"
// Definir el máximo de niveles permitidos
#define MAX_NIVELES 50
#define MAX_NOMBRE 64  // Definir el tamaño máximo para nombres
#define SQL_CREATETABLE "CREATE TABLE IF NOT EXISTS ranks_players (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,steamid TEXT,steamid64 TEXT,rounds_wins INTEGER,rounds_lose INTEGER,kills INTEGER, points INTEGER ,deaths INTEGER,suicides INTEGER,headshots INTEGER,level INTEGER,dominations INTEGER,first_join_date DATETIME, play_time_seconds FLOAT);"

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



enum struct playerData {
	int g_Points;
    int g_PlayerKills;
    int g_PlayerDeaths;
    int g_PlayerSuicides;
    int g_PlayerHeadshots;
    int g_PlayerLevel;
    int g_PlayerDominations; 
    float g_PlayerPlayTime;
    float g_PlayerStartTime;   
    char g_LevelName[64];
    int g_roundWins;
    int g_roundLose; 
}

// Definir un struct para almacenar la configuración
enum struct ConfigData
{
    int puntosKill;
    int puntosAssist;
    int puntosHeadshot;
    int puntosGanarRonda;
    int puntosSuicide;
    int puntosDeath;
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
    if (!ExecuteQuery(SQL_CREATETABLE))
    {
        PrintToServer("Failed to create table.");
        return;
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






// Esto se ejecuta cuando inicia el plugin
public void OnPluginStart()
{
    LoadLevelsConfig();
	g_Config = LoadConfig();  // Cargar configuración al iniciar el plugin
    RegConsoleCmd("sm_mylevel", Comando_MiNivel, "Muestra tu nivel actual");
    RegConsoleCmd("sm_niveles", ComandoNiveles, "Muestra los niveles en la consola.");
    RegAdminCmd("sm_hud", Command_PrintMessage, ADMFLAG_GENERIC);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
    HookEvent("teamplay_round_win", Evento_RondaGanada, EventHookMode_Post);

	g_DB = SQL_Connect("playerstats", false, g_DBError, sizeof(g_DBError));
	
	if (g_DB == null) {
	    PrintToServer("Could not connect to 'playerstats': %s", g_DBError);
	    return;
	}

    else
    {
        createInitialBd();
    }
}



// Función que carga la configuración y la devuelve
ConfigData LoadConfig()
{
    ConfigData config;

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/playerstats.cfg");

    KeyValues kv = new KeyValues("playerstats");

    if (!kv.ImportFromFile(path))
    {
        LogError("No se pudo cargar el archivo de configuración: %s", path);
        delete kv;

        // Devolver valores por defecto si no hay archivo
        config.puntosKill = 100;
        config.puntosAssist = 50;
        config.puntosHeadshot = 150;
        config.puntosGanarRonda = 250;
        config.puntosSuicide = 250;
        config.puntosDeath = 100;
        
        return config;
    }

    // Leer valores del archivo
    config.puntosKill = kv.GetNum("puntos_kill", 100);
    config.puntosAssist = kv.GetNum("puntos_assist", 50);
    config.puntosHeadshot = kv.GetNum("puntos_headshot", 150);
    config.puntosGanarRonda = kv.GetNum("puntos_ganar_ronda", 250);
    config.puntosSuicide = kv.GetNum("puntos_autokills", 250);
    config.puntosDeath = kv.GetNum("puntos_deaths", 250);
    
    delete kv;
    return config;
}


void ShowHudMessage(int client, const char[] message)
{
    if (g_hHudSync == null)
    {
        g_hHudSync = CreateHudSynchronizer();
        if (g_hHudSync == INVALID_HANDLE)
        {
            ReplyToCommand(client, "Failed to create HUD synchronizer.");
            return;
        }
    }

    SetHudTextParams(0.01, 0.1, 10000.0, 255, 255, 255, 255, 0);
    ShowSyncHudText(client, g_hHudSync, message);
}


// Este es el evento para cuando un player hace respawn
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client_id = GetEventInt(event, "userid");
    int client = GetClientOfUserId(client_id);

    CreateTimer(2.0, Timer_ShowSecondMessage, client);

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
    char query[512];
	// Obtener el timestamp actual y formatearlo como una cadena
	int currentTimestamp = GetTime();
	char datetime[32];
	FormatTime(datetime, sizeof(datetime), "%Y-%m-%d %H:%M:%S", currentTimestamp);
	
	// Formatear la consulta para insertar en la base de datos
	Format(query, sizeof(query), "INSERT INTO ranks_players (points, steamid, steamid64, name, kills, deaths, suicides, headshots, level, dominations, first_join_date, play_time_seconds, rounds_wins, rounds_lose) VALUES (0, '%s', '%s', '%s', 0, 0, 0, 0, 0, 0, '%s', 0.0, 0, 0)", steamId, steamId64, playerName, datetime);


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
    char query[256];
    Format(query, sizeof(query), "SELECT kills, deaths, suicides, headshots, level, dominations, play_time_seconds, points, rounds_wins, rounds_lose FROM ranks_players WHERE steamid = '%s'", steamId);

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
	    playersdata[client].g_PlayerDominations = SQL_FetchInt(hResult, 5);
	    playersdata[client].g_PlayerPlayTime = SQL_FetchFloat(hResult, 6);
	    playersdata[client].g_Points = SQL_FetchInt(hResult, 7);
        playersdata[client].g_roundWins = SQL_FetchInt(hResult, 8);
        playersdata[client].g_roundLose = SQL_FetchInt(hResult, 9);
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
        return;
    }

    // Variables para el cálculo
    int nivel = 0;
    char nombreNivel[64]; // Ajustar tamaño según sea necesario

    // Iterar sobre los niveles cargados
    for (int i = 0; i < nivelesCargados; i++)
    {
        // Si los puntos del jugador son suficientes para alcanzar este nivel, asignar el nivel y nombre
        if (playersdata[client].g_Points >= nivelesPuntos[i])
        {
            nivel = i + 1;  // El nivel está basado en el índice
            strcopy(nombreNivel, 64, nivelesNombres[i]);
        }
        else
        {
            break;  // Los niveles están ordenados, por lo que no es necesario seguir buscando
        }
    }

    // Asignar el nivel y nombre calculado a las variables globales del jugador
    playersdata[client].g_PlayerLevel = nivel;
    strcopy(playersdata[client].g_LevelName, 64, nombreNivel);
}


public void OnClientPutInServer(int client)
{
	if (!IsValidClient(client)) return;  // Evita que bots reciban puntos
	
	
    playersdata[client].g_PlayerStartTime = GetClientTime(client); 

    // Obtiene el nombre y la SteamID del jugador
    char playerName[32], steamId[20], steamId64[20];

    GetClientName(client, playerName, sizeof(playerName));

    if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId), true) ||
        !GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true))
    {
        PrintToChatAll("Jugador conectado: %s (SteamID no disponible)", playerName);

        return;
    }

    // Mostrar información en el servidor
    PrintToChatAll("Jugador conectado: %s (SteamID: %s)", playerName, steamId);

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
    char query[512];
	Format(query, sizeof(query), 
	    "UPDATE ranks_players SET kills = %d, deaths = %d, suicides = %d, headshots = %d, level = %d, dominations = %d, play_time_seconds = play_time_seconds + %.2f, points = %d WHERE steamid = '%s'", 
	    playersdata[client].g_PlayerKills, playersdata[client].g_PlayerDeaths, playersdata[client].g_PlayerSuicides, 
	    playersdata[client].g_PlayerHeadshots, playersdata[client].g_PlayerLevel, playersdata[client].g_PlayerDominations, elapsedTime, playersdata[client].g_Points, steamId);

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


// En esta parte el hook definido arriba ara las acciones sobre despues de la muerte de un usuario , sumara o restara la kill y muerte de los usuarios respectivamente
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    char weapon[64];
    int victimId = event.GetInt("userid");
    int attackerId = event.GetInt("attacker");// Convertir a booleano seguro
    bool headshot = GetEventBool(event, "headshot");

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
        playersdata[victim].g_PlayerSuicides += 1; // Incrementa los suicidios del jugador que murió
        playersdata[victim].g_Points -= g_Config.puntosSuicide;
        if (playersdata[victim].g_Points < 0){
        	playersdata[victim].g_Points = 0;
        }
    }
    else
    {
        playersdata[victim].g_PlayerDeaths += 1;
        playersdata[attacker].g_PlayerKills += 1; // Incrementa las muertes del jugador que murió
        playersdata[attacker].g_Points += g_Config.puntosKill;
        playersdata[victim].g_Points -= g_Config.puntosDeath;
         if (playersdata[victim].g_Points < 0){
        	playersdata[victim].g_Points = 0;
        }
    }
    PrintToConsole(attacker,"dadadadad : %d", headshot);
   
    char mensaje[64];
    Format(mensaje, sizeof(mensaje), "points: %d, muertes %d, suicidios: %d, kills : %d y tiempo: %.2f min", playersdata[attacker].g_Points, playersdata[attacker].g_PlayerDeaths, playersdata[attacker].g_PlayerSuicides, playersdata[attacker].g_PlayerKills, playersdata[attacker].g_PlayerPlayTime/60);
    ShowHudMessage(attacker, mensaje);

    Format(mensaje, sizeof(mensaje), "points: %d, muertes %d, suicidios: %d, kills : %d y tiempo: %.2f min", playersdata[victim].g_Points, playersdata[victim].g_PlayerDeaths, playersdata[victim].g_PlayerSuicides, playersdata[victim].g_PlayerKills, playersdata[victim].g_PlayerPlayTime/60);
    ShowHudMessage(victim, mensaje);

    // Crea un temporizador de 3 segundos para mostrar un segundo mensaje
    CreateTimer(3.0, Timer_ShowSecondMessage, victim);
}

// Este es solamente un timer para ejecutar la función que imprimirá el hud
public Action Timer_ShowSecondMessage(Handle timer, any client)
{
    char mensaje[64];
    Format(mensaje, sizeof(mensaje), "points: %d, muertes %d, suicidios: %d, kills : %d y tiempo: %.2f min", playersdata[client].g_Points, playersdata[client].g_PlayerDeaths, playersdata[client].g_PlayerSuicides, playersdata[client].g_PlayerKills, playersdata[client].g_PlayerPlayTime/60);
    ShowHudMessage(client, mensaje);

    // Devuelve Plugin_Stop para que el temporizador no se repita
    return Plugin_Stop;
}


// Evento cuando un equipo gana una ronda
public void Evento_RondaGanada(Event event, const char[] name, bool dontBroadcast)
{
    int equipoGanador = event.GetInt("team"); // 2 = RED, 3 = BLU
    int equipoPerdedor = (equipoGanador == 2) ? 3 : 2; // Si ganó RED, perdió BLU y viceversa

    // Recorremos todos los jugadores en el servidor
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue; // Ignoramos bots y jugadores desconectados

        if (GetClientTeam(i) == equipoGanador) // Si el jugador está en el equipo ganador
        {
            playersdata[i].g_roundWins += 1; // Aumenta las rondas ganadas
            PrintToChat(i, "🎉 ¡Has ganado esta ronda! Total de rondas ganadas: %d", playersdata[i].g_roundWins);
        }
        else if (GetClientTeam(i) == equipoPerdedor) // Si el jugador está en el equipo perdedor
        {
            playersdata[i].g_roundLose += 1; // Aumenta las rondas perdidas
            PrintToChat(i, "😢 Perdiste esta ronda. Total de rondas perdidas: %d", playersdata[i].g_roundLose);
        }
    }
}


// ====[ COMMANDS ]============================================================


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
    // Verificar si el comando es ejecutado por un jugador válido
    if (client == 0 || !IsClientInGame(client))
    {
        ReplyToCommand(client, "Este comando solo puede ser usado por jugadores en el juego.");
        return Plugin_Handled;
    }

    // Asegurar que el nivel ya se haya calculado antes de mostrarlo
    CalcularNivel(client);

    // Obtener los valores del nivel del jugador
    int nivel = playersdata[client].g_PlayerLevel;
    char nombreNivel[64];
    strcopy(nombreNivel, sizeof(nombreNivel), playersdata[client].g_LevelName);

    // Enviar el mensaje al jugador
    if (nivel>0){
        PrintToChat(client, "Tu nivel actual es: %d (%s)", nivel, nombreNivel);
    }else{
          PrintToChat(client, "Tu nivel actual es: 0 (iniciado)");
    }

    return Plugin_Handled;
}

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

public void OnPluginEnd()
{
    if (g_DB != null)
    {
        delete g_DB;
    }
}
