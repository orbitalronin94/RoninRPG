# CP-00 — Auditoría forense y recuperación

**Estado:** ACCEPTED (inventario y rescate histórico; no implica que el juego nuevo esté implementado).  
**Fecha:** 2026-11-07  
**Repositorio:** `orbitalronin94/RoninRPG`  
**Rama:** `main`

## Evidencia del historial

- El último árbol completo antes de la limpieza está en el commit `dad06543e29c47f528028941bbbf6b3b10582471`.
- Entre el 26-10-2026 21:16 y 21:18 UTC se eliminaron sucesivamente `.github/workflows`, `docs`, `tools`, `game`, `narrative`, `ASSETS.md`, `BUILD_APK.md` y `README.md`.
- El commit `ea246ba35bd6ae097cf256c8dffe252a7944977e` restauró 33 blobs del árbol anterior sin reescribir historia ni mover referencias mediante force-push.
- El proyecto recuperado incluye Godot 4, una escena procedural `game/scenes/main.tscn`, script `game/scripts/main.gd`, ocho archivos JSON de datos, validador Python, cinco auditores deterministas y workflow Android.

## Inventario recuperado

| Dominio | Evidencia | Evaluación |
|---|---|---|
| Godot | `game/project.godot`, escena y script principal | Recuperado; prototipo antiguo |
| Datos de mundo | world, NPCs, story graph, missions, Yokai, systems, crafting, decisions | Recuperados; contenido antiguo |
| Narrativa | briefs, biblia de personajes y prompts | Recuperada; incompatible con nueva dirección |
| Herramientas | validador JSON y cinco auditores | Recuperadas; revisar y ampliar |
| Android | workflow, export preset y guía | Recuperados; build no revalidado |
| Assets | no había arte externo; escenario dibujado por código | Sin problemas de licencia conocidos en los recursos recuperados |

## Hallazgo principal

La versión anterior era un RPG narrativo histórico ambientado en Kanegawa en 1573, con Kagetora como protagonista masculino, movimiento libre 2D y diálogos. No era un juego de lucha tipo Shadow Fight. No se debe confundir su contenido con el nuevo producto aprobado.

## Resultado de CP-00

La auditoría es reproducible y la recuperación de archivos está confirmada por el commit de GitHub. Se conserva el historial completo. No se declara todavía CP-03 ACCEPTED: falta una ejecución verde del pipeline de Godot/Android.

## Límites

Esta auditoría se basa en el árbol Git y archivos recuperados. No afirma que la escena antigua compile o que el APK antiguo funcione. La validación de motor y dispositivo pertenece a CP-03/CP-18.
