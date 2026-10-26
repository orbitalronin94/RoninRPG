# Arquitectura técnica inicial

- **Presentación:** `game/scenes/main.tscn` y `game/scripts/main.gd`; escenario dibujado por código, sin assets externos.
- **Estado de juego:** Honor, monedas, alojamiento e investigación del pozo.
- **Datos narrativos:** JSON estático en `game/data/`.
- **Narrativa:** briefs y prompts en `narrative/`. No existe aún backend LLM conectado; el diálogo del prototipo es estático.
- **Android:** exportación manual mediante Godot; sin workflows.
- **Pendiente:** persistencia, combate, inventario, opciones, memoria SQLite, validador LLM, mapas separados, controles táctiles completos y pruebas.
