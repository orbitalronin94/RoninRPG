# Ronin RPG — El Sauce y la Ceniza

RPG narrativo 2D para Godot 4, ambientado en Kanegawa en 1573. El proyecto contiene una escena prototipo dibujada por código, un primer diálogo con O-Ren, movimiento, Honor y datos narrativos ampliados para una campaña ramificada.

## Estado del proyecto
- Proyecto Godot en `game/`, con escena principal y controles de teclado.
- Datos de mundo con 7 facciones y 9 zonas; 12 nodos de historia; 12 misiones principales y 8 secundarias.
- Fichas de NPC, 10 encuentros yōkai, recetas de crafteo, estaciones/clima, combate, Honor y 6 finales definidos como datos.
- Cinco auditores deterministas en `tools/agents/` y validador general en `tools/validate_json.py`.
- Workflow de GitHub Actions en `.github/workflows/build-apk.yml` para intentar exportar APK, publicarlo como artefacto y copiarlo a `builds/ronin-rpg.apk`; los tags `v*` adjuntan el APK a una Release.

**Importante:** la ampliación de datos no significa que todas las mecánicas estén ya implementadas en la interfaz jugable. El combate táctico, los sistemas de clima/crafteo, los seis finales completos, los assets originales de sprites/sonido y el diálogo LLM en runtime siguen siendo trabajo pendiente. El workflow está configurado, pero el APK solo se considera entregado cuando una ejecución de Actions termina correctamente y el archivo se verifica en un dispositivo/emulador.

## Combate arcade: Ronin Duel
La escena `game/scenes/combat.tscn` añade duelos 2D contra CPU con estética samurái estilizada, barras de vida y KI, ataques normales, Corte del Sauce, bloqueo, salto, dash, chispas de impacto, combo y persistencia de victorias/Honor. El escenario y los luchadores se dibujan por código para evitar dependencias de recursos externos.

- Desde la aldea: pulsa **F** o toca **DUELO** para entrar en combate cuando el diálogo esté cerrado.
- En el duelo: **J/Z** corte, **K/X** especial (25 KI), **L** bloquear, **W/↑/Espacio** saltar, **Shift** dash, **A/D** o flechas moverse, **Esc** volver.
- En móvil: usa los controles táctiles de la parte inferior. Tras ganar, el contador de duelos y Honor se guardan en `user://decisions.json`.

Es un prototipo de combate jugable, no todavía una animación de sprites dibujados a mano comparable a un juego comercial; los gráficos son vectoriales y el duelo debe probarse en dispositivo antes de considerar el APK verificado.

## Ejecutar en escritorio
1. Instala Godot 4.2.2 o una versión compatible.
2. Abre `game/project.godot`.
3. Ejecuta con F6/F5 desde el editor.

Controles de aventura: WASD o flechas para moverse; Espacio/Enter para avanzar diálogo; E para interactuar.

## Validar datos
Con Python 3:
```sh
python tools/validate_json.py
python tools/agents/world_agent.py
python tools/agents/npc_agent.py
python tools/agents/story_agent.py
python tools/agents/mission_agent.py
python tools/agents/scene_agent.py
```

Los auditores revisan estructura y referencias; no simulan una partida ni sustituyen la ejecución de Godot.

## Android y releases
Consulta [BUILD_APK.md](BUILD_APK.md). Para generar una Release, crea y sube un tag, por ejemplo `v0.1.0`, después de comprobar que el workflow de compilación funciona.
