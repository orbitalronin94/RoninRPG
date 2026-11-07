# RONIN RPG — instrucciones para agentes y colaboradores

Antes de modificar código, lee `docs/SPEC_V1.0.md`.

## Producto
RONIN: SHADOW DOJO es un action RPG 2D de fantasía japonesa, pixel art original, offline y Android-first. La especificación es la fuente de verdad. No reintroduzcas decisiones antiguas incompatibles sin ADR.

## Reglas obligatorias
- Inspecciona el estado actual; no presupongas que archivos históricos siguen presentes.
- Trabaja en un checkpoint concreto y entrega evidencia reproducible.
- No declares un checkpoint ACCEPTED por haber creado archivos o mocks.
- No inventes resultados de tests, rendimiento, exportación o gameplay.
- Mantén cambios pequeños y limitados al dominio asignado.
- No borres historial, no hagas force-push y no publiques releases sin autorización.
- No añadas secretos, keystores, tokens ni credenciales.
- Verifica licencias de assets y dependencias.
- Mantén el juego offline; no añadas backend obligatorio.
- Documenta decisiones que alteren alcance o arquitectura en `docs/decisions/`.
- Si la realidad del repo contradice la spec, informa y propone actualización explícita.

## Calidad
- Preferir GDScript tipado y componentes pequeños.
- Mantener datos de balance separados de la lógica.
- Añadir tests para lógica de combate, progreso, misiones y guardado.
- Mantener input táctil y teclado de desarrollo.
- Evitar referencias absolutas frágiles y singletons omniscientes.
- Ejecutar validación Godot/CI disponible y registrar comandos y resultados.

## Entrega
Cada tarea debe indicar checkpoint, archivos afectados, pruebas, evidencia, riesgos y estado. Otro agente debe revisar el resultado antes de marcarlo ACCEPTED.
