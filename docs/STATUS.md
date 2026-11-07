# Estado de ejecución — RONIN: SHADOW DOJO

Última actualización: 2026-11-07

| CP | Estado | Evidencia | Nota |
|---|---|---|---|
| CP-00 | ACCEPTED | Commit `ea246ba`, `RECOVERY_AUDIT.md` | Árbol histórico inventariado y 33 archivos restaurados |
| CP-01 | ACCEPTED | `architecture.md`, `RECOVERY_AUDIT.md` | Matriz KEEP/ADAPT/REWRITE/DEFER |
| CP-02 | IN_PROGRESS | README, ART_BIBLE, NARRATIVE_BIBLE, QA_MATRIX | Documentación base creada; falta revisión de consistencia global |
| CP-03 | IN_PROGRESS | Run `42376347067` | Validación de datos, agentes, importación y ejecución headless pasan; exportación Android falla al iniciar el sistema legacy. Diagnóstico aún sin causa interna explícita. |
| CP-04–18 | NOT_STARTED | — | Bloqueados hasta CP-03 |

## Política

Actualizar este tablero únicamente con evidencia. Los commits de documentación no equivalen a checkpoints de gameplay. Los checkpoints 04–18 se abren secuencialmente según dependencias.


## Trabajo de calidad en curso — 2026-11-07

- Añadida una prueba headless de recorrido: nueva partida, diálogo de Akane/Mika, recompensa no duplicable, transición al bosque, derrota de jefa y restauración del guardado.
- Corregido el renderizado multilínea de diálogos: el separador debe ser un salto de línea real.
- El salto táctil pasa a dispararse al pulsar, no continuamente mientras se mantiene el dedo; evita rebotes involuntarios.
- CP-03 continúa abierto hasta que la exportación Android produzca un APK verificable.
