# Arquitectura técnica — RONIN: SHADOW DOJO

## Estado de partida

El commit de recuperación `ea246ba` restauró el prototipo Godot 4 y 33 archivos desde el último árbol completo previo a la limpieza del 26-10-2026. La escena antigua `game/scenes/main.tscn` usa un único `Node2D` con dibujo procedural, movimiento 2D libre, diálogos contextuales y guardado JSON. Es una base ejecutable potencial, pero no implementa el combate lateral que requiere Shadow Dojo.

## Decisión de migración

- **KEEP:** Godot 4, proyecto `game/`, validación determinista de datos, pipeline Android como referencia, separación de datos narrativos.
- **ADAPT:** escena principal, input, persistencia local, misiones, estructura de zonas y workflow Android.
- **REWRITE:** mundo, personajes, arte, UI, control de personaje, combate, enemigos, jefes y loop de juego.
- **DEFER:** crafting, clima/estaciones, reputación de facciones y simulación de economía hasta que CP-18 esté aceptado.

## Arquitectura objetivo

```text
game/
  project.godot
  scenes/
    main.tscn
    menus/title_screen.tscn
    world/village.tscn
    world/bamboo_forest.tscn
    combat/arena.tscn
    combat/boss_arena.tscn
  scripts/
    core/game_state.gd
    core/save_manager.gd
    core/scene_router.gd
    actors/player_controller.gd
    actors/enemy_controller.gd
    combat/combat_component.gd
    combat/hitbox.gd
    ui/touch_controls.gd
  data/
    characters/
    enemies/
    quests/
    items/
```

No se crearán escenas vacías por adelantado: los componentes se incorporan cuando cada checkpoint los necesita.

## Contratos entre sistemas

- Gameplay emite eventos de combate (enemigo derrotado, daño recibido, jefe completado).
- RPG Systems procesa XP, recompensas, misiones y guardado.
- Narrative define textos, flags y consecuencias mediante IDs estables.
- UI presenta estado; no contiene reglas de combate ni de progresión.
- SaveManager serializa estado versionado y nunca ejecuta datos serializados.
- Los datos de balance viven fuera de los controladores.

## Plataformas

Android es la plataforma primaria. Windows/Linux se usan para desarrollo y smoke tests. El juego debe funcionar offline. Godot y las plantillas de exportación se fijan en CI para evitar builds no reproducibles.
