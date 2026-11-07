# Estado de ejecución — RONIN: SHADOW DOJO

Última actualización: 2026-11-07

| CP | Estado | Evidencia | Nota |
|---|---|---|---|
| CP-00 | ACCEPTED | Commit `ea246ba`, `RECOVERY_AUDIT.md` | Árbol histórico inventariado y 33 archivos restaurados |
| CP-01 | ACCEPTED | `architecture.md`, `RECOVERY_AUDIT.md` | Matriz KEEP/ADAPT/REWRITE/DEFER |
| CP-02 | IN_PROGRESS | README, ART_BIBLE, NARRATIVE_BIBLE, QA_MATRIX | Documentación base creada; falta revisión de consistencia global |
| CP-03 | IN_PROGRESS | Run `42376606171` | Datos, agentes, importación y smoke test end-to-end pasan; exportación Android sigue fallando al iniciar el sistema legacy. Entorno ajustado a requisitos documentados de Godot 4.2 para reintento. |
| CP-04–18 | NOT_STARTED | — | Bloqueados hasta CP-03 |

## Política

Actualizar este tablero únicamente con evidencia. Los commits de documentación no equivalen a checkpoints de gameplay. Los checkpoints 04–18 se abren secuencialmente según dependencias.


## Trabajo de calidad en curso — 2026-11-07

- Añadida una prueba headless de recorrido: nueva partida, diálogo de Akane/Mika, recompensa no duplicable, transición al bosque, derrota de jefa y restauración del guardado. Run `42376606171`: todas las aserciones PASS.
- Corregido el renderizado multilínea de diálogos: el separador debe ser un salto de línea real.
- El salto táctil pasa a dispararse al pulsar, no continuamente mientras se mantiene el dedo; evita rebotes involuntarios.
- CP-03 continúa abierto hasta que la exportación Android produzca un APK verificable.
- Ajustado el workflow Android a Platform 33, Build Tools 33.0.2, CMake 3.10.2 y NDK r23c según la guía de Godot 4.2; keystore configurado mediante variables oficiales de exportación.
- Esquiva táctil convertida a acción por pulsación para evitar que mantener el dedo provoque esquivas repetidas.
