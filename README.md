<div align="center">
  <h1><code>tf2_stats_2025</code></h1>
  <p>
    <strong>Short Description</strong>
  </p>
  <p style="margin-bottom: 0.5ex;">
    <img
        src="https://img.shields.io/github/downloads/gladoncio/tf2_stats_2023/total"
    />
    <img
        src="https://img.shields.io/github/last-commit/gladoncio/tf2_stats_2023"
    />
    <img
        src="https://img.shields.io/github/issues/gladoncio/tf2_stats_2023"
    />
    <img
        src="https://img.shields.io/github/issues-closed/gladoncio/tf2_stats_2023"
    />
    <img
        src="https://img.shields.io/github/repo-size/gladoncio/tf2_stats_2023"
    />
    <img
        src="https://img.shields.io/github/workflow/status/gladoncio/tf2_stats_2023/Compile%20and%20release"
    />
  </p>
</div>

# TF2 Stats Plugin (Beta)

Este plugin está actualmente en desarrollo. La idea es crear un sistema de estadísticas junto a un sistema de niveles.

## Requirements
- Sourcemod y Metamod
- SQLite (por ahora; soporte para MySQL pronto)

## Installation
1. Descarga la última versión desde la página de releases y descomprímela en tu carpeta de Sourcemod.

## Configuration
- Una vez cargado el plugin, puedes modificar las especificaciones en `addons/sourcemod/config/playerstats.cfg`.
- Para configurar puntos por tipo de mapa, prefijos, etc., puedes editar `addons/sourcemod/config/playerstatsmaps/vsh_.cfg`.
- Configura los puntos por tipo de evento en `addons/sourcemod/config/playerlevels.cfg`.
- Para habilitar MySQL, asegúrate de configurar la base de datos en `addons/sourcemod/config/databases.cfg`:

```json
"playerstats"
{
	"driver"		"mysql"
	"host"			"localhost"
	"database"		"playerstats"
	"user"			"root"
	"pass"			""
	//"timeout"		"0"
	//"port"		"0"
}
```

## Usage (Beta)
Este plugin aún está en fase beta. Actualmente **no guarda todas las estadísticas**, Sin embargo, representa un gran avance desde la última actualización.

### Eventos de Estadísticas
El plugin registra los siguientes eventos de muerte y destrucción, asignando puntos según el tipo de evento. Estos puntos son configurables en los archivos de configuración del plugin:

- **Muerte**: Se registran las estadísticas de kills, deaths y asistencias. 
- **Dominación**: Si un jugador mata a otro con una dominación, se registra.
- **Eventos Personalizados de Muerte**: Se incluyen eventos como headshots, backstabs, quemaduras, suicidios, y otros eventos especiales. Los eventos personalizados permiten agregar puntuaciones especiales por acciones destacadas.
- **Destrucción de Objetos**: Si un jugador destruye un objeto o construcción, se registran las estadísticas de destrucción.
- **Rondas Ganadas/Perdidas**: Se registran las rondas ganadas y perdidas por los jugadores.

### Ejemplo de Código (Eventos de Muerte)
El plugin maneja varios tipos de eventos, incluyendo headshots, backstabs, quemaduras, etc. Aquí hay un ejemplo del código para el evento de muerte:

#### Configuración de Puntos por Evento
Los puntos asociados con cada evento se pueden configurar en los archivos del plugin. Ejemplo:

```plaintext
"playerstats"
{
    "use_hud" "0"  // Desactiva el HUD para las estadísticas
    "puntosg_PlayerKills" = "20"  // Puntos por matar a un jugador
    "puntosg_PlayerDeaths" = "20"  // Puntos por morir
    "puntosg_PlayerSuicides" = "20"  // Puntos por suicidio
    "puntosg_PlayerHeadshots" = "20"  // Puntos por headshots
    "puntosg_PlayerLevel" = "20"  // Puntos por nivel
    "puntosg_dominando" = "20"  // Puntos por dominar a un jugador
    "puntosg_dominado" = "20"  // Puntos por ser dominado
    "puntosg_assist" = "20"  // Puntos por asistencia
    "puntosg_roundWins" = "20"  // Puntos por ganar una ronda
    "puntosg_roundLose" = "20"  // Puntos por perder una ronda
    "puntosbackstabEvent" = "20"  // Puntos por backstab
    "puntosburningEvent" = "20"  // Puntos por quemadura
    "puntossuicideEvent" = "20"  // Puntos por suicidio
    "puntostauntHadoukenEvent" = "20"  // Puntos por taunt Hadouken
    "puntosburningFlareEvent" = "20"  // Puntos por quemadura con flare
    "puntostauntHighNoonEvent" = "20"  // Puntos por taunt High Noon
    "puntostauntGrandSlamEvent" = "20"  // Puntos por taunt Grand Slam
    "puntospenetrateMyTeamEvent" = "20"  // Puntos por penetrar a un miembro de tu equipo
    "puntospenetrateHeadshotEvent" = "20"  // Puntos por penetrar con headshot
    "puntostelefragEvent" = "20"  // Puntos por telefrag
    "puntosflyingBurnEvent" = "20"  // Puntos por quemar en vuelo
    "puntospumpkinBombEvent" = "20"  // Puntos por bomba calabaza
    "puntosdecapitationEvent" = "20"  // Puntos por decapitación
    "puntosshotgunRevengeCritEvent" = "20"  // Puntos por venganza con escopeta
    "puntosfishKillEvent" = "20"  // Puntos por kill con fish
    "puntostauntAllclassGuitarRiffEven" = "20"  // Puntos por taunt de guitarra
    "puntoskartEvent" = "20"  // Puntos por evento de kart
    "puntosdragonsFuryIgniteEvent" = "20"  // Puntos por fuego de Dragons Fury
    "puntosslapKillEvent" = "20"  // Puntos por slap kill
    "puntosaxtinguishBoosterEvent" = "20"  // Puntos por apagar con extintor
    "puntosg_ObjectsDestroyed" = "20"  // Puntos por destruir objetos
    "puntosg_BuildingsDestroyed" = "20"  // Puntos por destruir edificaciones
    "puntosg_EventsAssisted" = "20"  // Puntos por asistir en eventos
}

```