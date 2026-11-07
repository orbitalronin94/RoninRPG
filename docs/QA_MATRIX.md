# QA MATRIX — RONIN: SHADOW DOJO

## Reglas

Distinguir pruebas unitarias, smoke tests automatizados y pruebas manuales. No aceptar una prueba si no se documentan versión del motor, comando, resultado y evidencia. Una build verde no demuestra diversión ni usabilidad.

## Matriz por checkpoint

| Checkpoint | Prueba | Aceptación |
|---|---|---|
| CP-03 | Import Godot headless | Proyecto importa sin errores |
| CP-04 | Boot/menu | Nueva partida y continuar funcionan |
| CP-05 | Input | Teclado y táctil responden; sin input pegado |
| CP-06 | Navegación | Cambios de escena sin duplicación ni pérdida de estado |
| CP-07 | Save | Guardar/cargar, archivo corrupto y versión anterior |
| CP-08 | Movimiento | Límites, colisiones y aceleración estables |
| CP-09 | Estados | Transiciones válidas y sin acciones simultáneas imposibles |
| CP-10 | Hitboxes | Daño aplicado una vez y dentro de ventana |
| CP-11 | IA | Enemigo anticipa, ataca y recupera |
| CP-12 | Arena | Encuentro repetible y balance básico |
| CP-13 | Akane | Animaciones legibles en resolución móvil |
| CP-14 | Zona | Aldea y bosque conectados |
| CP-15 | Diálogo | Interacción y flags persistentes |
| CP-16 | Tutorial | Mecánicas básicas enseñadas y revisables |
| CP-17 | Jefa | Tres patrones, fase y recompensa |
| CP-18 | Recorrido completo | Título→zona→enemigos→jefa→recompensa→save/load |

## Gate del vertical slice

- Recorrido de 15–25 minutos, sin depender del editor.
- Dos tipos de enemigos y una jefa.
- Akane controlable con controles táctiles.
- Ataque, esquiva y guardia funcionales.
- Guardado persistente después de jefe y reinicio.
- APK instalado y probado en Android real.
- Cero bloqueadores que impidan terminar el recorrido.
- Evidencia: commit, run CI, logs, capturas o vídeo y dispositivo/versión Android.
