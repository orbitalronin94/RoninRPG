# RONIN: SHADOW DOJO

Action RPG 2D de fantasía japonesa, pixel art original y combate en tiempo real. Proyecto Android-first desarrollado con Godot 4. El objetivo inmediato es completar el vertical slice definido en [SPEC_V1.0.md](docs/SPEC_V1.0.md), checkpoints CP-00 a CP-18.

## Identidad del juego

Akane, una ronin adulta traicionada por su clan, despierta con una katana ligada a un espíritu sellado. En un Japón fantástico donde el mundo humano y el espiritual se han mezclado, deberá sobrevivir a Yokai, descubrir quién rompió los sellos y decidir qué precio está dispuesta a pagar por el poder.

- Protagonistas y personajes principales femeninos.
- Fantasía japonesa original; no usa personajes ni recursos de franquicias existentes.
- Combate lateral en tiempo real: ataques, esquiva, guardia, habilidades y patrones enemigos.
- Exploración de aldeas, bosques y santuarios.
- Progresión RPG, misiones, equipo y guardado local.
- Campaña offline; no necesita cuentas ni servidores.

## Estado real

La rama principal contiene la especificación v1.0, seis perfiles de agentes y la recuperación del prototipo Godot anterior. El prototipo recuperado pertenece a una dirección narrativa anterior (Kanegawa histórico y Kagetora) y **no es todavía el juego nuevo**. Se conservará selectivamente su arquitectura, validadores y datos técnicos; la identidad, protagonistas, mundo, arte y combate se están rehaciendo.

Consulta [docs/RECOVERY_AUDIT.md](docs/RECOVERY_AUDIT.md) para la auditoría y [docs/STATUS.md](docs/STATUS.md) para el estado demostrable de checkpoints. No se declara ningún sistema funcional sin pruebas.

## Abrir el proyecto

1. Instala la versión Godot indicada en el workflow.
2. Abre `game/project.godot`.
3. Ejecuta la escena principal con F6/F5.

## Validación

```bash
python tools/validate_json.py
python tools/agents/world_agent.py
python tools/agents/npc_agent.py
python tools/agents/story_agent.py
python tools/agents/mission_agent.py
python tools/agents/scene_agent.py
```

La validación de datos comprueba estructura y referencias; no demuestra por sí sola que el juego sea jugable. La validación del motor se realiza en GitHub Actions.

## Android

La exportación Android se realiza mediante [GitHub Actions](.github/workflows/build-apk.yml). Los APK de CI son builds de depuración para pruebas, no releases comerciales. No se considera entregado un APK hasta que el workflow finalice correctamente y el paquete se instale y pruebe en un dispositivo Android real.

## Documentación

- [Especificación de producto v1.0](docs/SPEC_V1.0.md)
- [Estado y checkpoints](docs/STATUS.md)
- [Auditoría de recuperación](docs/RECOVERY_AUDIT.md)
- [Arquitectura](docs/architecture.md)
- [Biblia visual](docs/ART_BIBLE.md)
- [Biblia narrativa](docs/NARRATIVE_BIBLE.md)
- [Matriz QA](docs/QA_MATRIX.md)
- [Build Android](BUILD_APK.md)
- [Registro de assets](ASSETS.md)
