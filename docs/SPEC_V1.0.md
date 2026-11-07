# RONIN: SHADOW DOJO — Especificación de producto y plan de ejecución v1.0

> Estado: **specification baseline — aprobado para implementación**  
> Versión del documento: 1.0.0  
> Producto: videojuego RPG de acción 2D para Android y escritorio de desarrollo  
> Motor objetivo: Godot 4.x (versión exacta fijada en CI)  
> Arte: pixel art original, fantasía japonesa  
> Idioma de diseño: español; claves técnicas y nombres de código en inglés  
> Última actualización: 2026-11-07

---

## 0. Cómo se gobierna esta especificación

Este documento es la fuente de verdad de producto para llegar a v1.0. No describe trabajo ya realizado: los checkpoints empiezan **pendientes** hasta que exista evidencia reproducible en el repositorio o en una ejecución de CI.

### 0.1 Reglas de ejecución

1. Cada checkpoint tiene identificador, entregables, pruebas y criterios de aceptación.
2. Ninguna fase se considera terminada por tener archivos creados: debe existir comportamiento funcional y evidencia.
3. No se declara una función implementada si solo existe un mock, una escena vacía, un TODO o una captura.
4. Los agentes trabajan en tareas acotadas, leen esta spec antes de actuar y no sobrescriben trabajo ajeno.
5. La integración se hace en cambios pequeños y verificables. El usuario prefiere trabajar directamente sobre `main`; por tanto, los agentes no abrirán PR salvo petición explícita. Antes de modificar `main`, comprobarán el estado remoto y evitarán force-push.
6. No introducir assets, música, fuentes ni código de terceros sin licencia compatible y atribución cuando corresponda. Prioridad a contenido original.
7. No incorporar dependencias de red obligatorias ni servicios de pago. La campaña debe poder jugarse offline.
8. La spec manda sobre documentos antiguos contradictorios. Los documentos históricos se conservan como historia, no como requisitos vigentes.
9. Toda cifra de rendimiento se mide en dispositivo o entorno identificado; no se inventa ni extrapola.
10. Si el estado real del repositorio contradice una suposición de este documento, registrar la discrepancia y actualizar la spec mediante un cambio explícito antes de construir sobre ella.

### 0.2 Estados de checkpoint

- `NOT_STARTED`: no hay implementación.
- `IN_PROGRESS`: trabajo iniciado, sin aceptación completa.
- `BLOCKED`: dependencia o decisión pendiente; registrar causa y siguiente acción.
- `IN_REVIEW`: implementación disponible y pruebas ejecutadas, pendiente de revisión.
- `ACCEPTED`: todos los criterios y evidencias están satisfechos.
- `DEFERRED`: excluido conscientemente de v1.0; registrar motivo.

No cambiar a `ACCEPTED` basándose únicamente en afirmaciones del agente autor.

### 0.3 Registro inicial de realidad

El repositorio se ha identificado como `orbitalronin94/RoninRPG`, rama por defecto `main`. La inspección inicial de noviembre de 2026 encontró un repositorio muy reducido: los commits recientes muestran eliminación de documentación, narrativa, directorios de juego, herramientas y workflows. Por ello, esta especificación **no presupone que el prototipo anterior siga presente**. El primer checkpoint debe inventariar el árbol real y recuperar solo lo que exista en el historial y sea útil. La anterior mención de scripts y escenas es una pista histórica, no evidencia actual.

---

# PARTE I — VISIÓN Y DISEÑO

## 1. Identidad del juego

### 1.1 Premisa

**RONIN: SHADOW DOJO** es un action RPG 2D de fantasía japonesa, con pixel art detallado, exploración lateral por zonas conectadas, combate en tiempo real y progresión de personajes. La campaña se desarrolla en un Japón ficticio donde el mundo humano y el espiritual se han solapado tras la ruptura de antiguos sellos.

La protagonista, Akane, una ronin traicionada por su clan, sobrevive a una emboscada y despierta vinculada a un espíritu sellado en su katana. Su búsqueda de justicia la conduce a descubrir que los clanes guardianes han participado en la ruptura de los sellos.

### 1.2 Pilares de experiencia

1. **Combate legible y táctico:** golpes con anticipación, impacto y recuperación; esquiva, bloqueo, parry opcional, stamina y patrones de enemigos.
2. **Exploración con recompensa:** rutas alternativas, cofres, secretos, santuarios, NPCs y atajos.
3. **Fantasía japonesa con identidad propia:** Yokai originales, clanes ficticios, folklore como inspiración transformada y escenarios memorables.
4. **Progresión con decisiones:** armas, talismanes, habilidades, mejoras y eje Honor/Sombras.
5. **Diseño móvil primero:** controles táctiles cómodos, sesiones cortas, interfaz legible y guardado fiable.
6. **Contenido propio:** personajes, diálogos, nombres, mapas, pixel art, efectos y música originales o con licencia documentada.

### 1.3 No objetivos de v1.0

- Multijugador, PvP, cooperativo o matchmaking.
- Mundo abierto continuo.
- Gacha, cajas de botín, energía, anuncios o microtransacciones.
- Generación procedural de campaña.
- Conexión permanente, cuentas o backend.
- Cinemáticas de vídeo de alta resolución.
- Voz completa para todos los diálogos.
- Editor de niveles integrado.
- Port a consolas.
- Prometer 60 FPS en cualquier Android; se define una matriz de dispositivos y objetivos medibles.

## 2. Plataformas y restricciones

| Área | Decisión v1.0 |
|---|---|
| Motor | Godot 4.x, versión exacta fijada por CI |
| Lenguaje | GDScript tipado cuando aporte claridad |
| Render | 2D, pixel-perfect |
| Plataforma primaria | Android APK |
| Plataforma secundaria | Windows/Linux para desarrollo y QA |
| Orientación | Horizontal (landscape) |
| Red | No requerida durante el juego |
| Guardado | Local, versionado y validado |
| Objetivo de instalación | APK universal de release; tamaño medido y documentado |
| Memoria | Presupuesto inicial de 512 MiB RAM objetivo; validar en hardware real |
| Assets | Originales o licencia compatible registrada |
| Idiomas v1.0 | Español e inglés en textos esenciales |
| Input | Táctil + teclado/controlador para pruebas |

Los valores de memoria, tamaño, FPS y tiempos son objetivos de ingeniería, no resultados ya demostrados. Se ajustarán con mediciones.

## 3. Mundo y narrativa

### 3.0 Restricción de diálogo: kōan y haiku

Todo texto pronunciado por cualquier personaje —jugable, NPC, aliado, enemigo o jefe— debe ser exclusivamente un **kōan** o un **haiku**. Queda prohibida la exposición en prosa conversacional. Los haikus se escribirán en tres versos, buscando el ritmo 5–7–5 adaptado al español sin sacrificar naturalidad; los kōan serán preguntas o paradojas breves, abiertas a interpretación. Esta regla alcanza escenas, diálogos opcionales, recuerdos, tutoriales narrados y todas las localizaciones. Los tutoriales y objetivos podrán usar texto directo solo si son elementos de interfaz claramente no hablados. La guía editorial y ejemplos canónicos están en `docs/NARRATIVE_BIBLE.md`.


### 3.1 Reglas del mundo

- Los **sellos** mantienen separadas las corrientes humana y espiritual.
- Los **Yokai** no son todos malvados: algunos protegen lugares, otros cazan humanos y otros están corrompidos.
- Los clanes humanos controlan territorios y escuelas marciales.
- La espada de Akane contiene un fragmento espiritual; usar su poder aumenta la afinidad con Sombras.
- Honor y Sombras alteran diálogos, algunas misiones, recompensas y el desenlace, pero no bloquean arbitrariamente el progreso principal.

### 3.2 Personajes principales

| Personaje | Rol | Arma/estilo | Mecánica distintiva |
|---|---|---|---|
| Akane | Ronin protagonista | Katana | Parry, contraataques y técnicas de filo |
| Yoru | Kunoichi aliada | Kusarigama/kunai | Movilidad, marcas y ataques críticos |
| Hikari | Onmyoji aliada | Ofuda y bastón | Sellos, control de zona y purificación |
| Tsukiko | Guardiana aliada | Naginata | Alcance, guardia y control de grupos |

Las cuatro son personajes ficticios adultos. El diseño visual prioriza siluetas, legibilidad, personalidad y coherencia cultural; no sexualización como sustituto de diseño.

### 3.3 Arco de cinco capítulos

**Capítulo I — La traición**  
Akane sobrevive a una emboscada, aprende los fundamentos, llega a una aldea fronteriza y descubre que el sello local ha sido manipulado. Jefe: antigua compañera de clan corrompida.

**Capítulo II — El bosque de los espíritus**  
Exploración del bosque, encuentro con Yoru, santuarios, Yokai guardianes y primer dilema entre purificar o aprovechar una fuente espiritual. Jefe: ciervo espectral / guardián de raíces.

**Capítulo III — Las máscaras de Kioto**  
Intriga entre clanes, llegada de Hikari, infiltración, misiones de facción y revelación de que la ruptura de sellos fue deliberada. Jefe: sacerdotisa del velo.

**Capítulo IV — El reino de las sombras**  
Tsukiko se une al grupo; descenso a una región espiritual, pruebas de combate, armas legendarias y verdad sobre el espíritu de la katana. Jefe: general oni.

**Capítulo V — La última espada**  
Asalto al santuario central, decisión final sobre el equilibrio de mundos y desenlaces condicionados por Honor/Sombras y misiones clave. Jefe final con fases diferenciadas.

### 3.4 Narrativa y diálogos

- Diálogos breves, con voz propia y sin exposición excesiva.
- Cada personaje debe tener objetivo, contradicción, arco y relación con Akane.
- Misiones con objetivo, contexto, pasos, recompensa y estado persistente.
- Las elecciones importantes deben comunicar consecuencias previsibles cuando sea posible.
- No usar nombres, diseños o textos de franquicias existentes.
- Añadir glosario de términos propios: clanes, sellos, Yokai, técnicas y lugares.

## 4. Diseño de combate

### 4.1 Cámara y espacio

Combate 2D lateral en arenas delimitadas dentro de zonas explorables. El jugador puede moverse horizontalmente, saltar si el diseño del encuentro lo requiere, esquivar, bloquear y atacar. Evitar cambios de plano ambiguos; profundidad decorativa no debe alterar colisiones.

### 4.2 Bucle básico

1. Leer la anticipación del enemigo.
2. Posicionarse, bloquear, esquivar o interrumpir.
3. Castigar durante la ventana de recuperación.
4. Gestionar stamina y cooldowns.
5. Usar técnica o consumible en una oportunidad clara.
6. Recibir experiencia, materiales o desbloqueos.

### 4.3 Controles

**Móvil:** stick/d-pad virtual configurable, ataque ligero, ataque fuerte, esquiva, guardia y habilidad contextual. Botones grandes, separados y con zonas táctiles generosas. No exigir combinaciones de tres dedos.

**Teclado de desarrollo:** movimiento, salto/esquiva, ataque ligero/fuerte, guardia, habilidad, interacción y pausa. Mapeo documentado.

### 4.4 Reglas de combate

- Las animaciones y ventanas de impacto deben coincidir.
- Hitboxes separadas de sprites visuales y depurables.
- Invulnerabilidad de esquiva limitada y visible.
- Bloqueo consume stamina; ataques pesados pueden romper guardia.
- Parry tiene ventana exigente y recompensa clara; no es obligatorio para terminar.
- Los enemigos telegráfian ataques con animación, sonido o efecto.
- El daño, stagger y knockback deben sentirse consistentes.
- La dificultad se escala mediante patrones y composición, no solo inflando HP.

### 4.5 Personajes y grupo

Akane es obligatoria como personaje controlado durante la primera mitad de la campaña. Las aliadas se desbloquean progresivamente. Para v1.0 se permite controlar directamente una protagonista a la vez; el resto puede aportar apoyo pasivo o habilidades de asistencia. Cambio directo entre personajes es deseable, pero solo obligatorio si no compromete el alcance.

## 5. RPG y progresión

### 5.1 Atributos

- HP: salud.
- ATK: potencia ofensiva.
- DEF: mitigación.
- STAMINA: acciones físicas.
- SPIRIT: potencia/recuperación espiritual.
- CRIT: probabilidad o valor crítico, limitado por balance.

No mostrar números innecesarios al jugador. Cada atributo debe tener efecto probado.

### 5.2 Experiencia y niveles

- XP por enemigos, jefes y misiones.
- Curva de nivel definida en datos, no dispersa en scripts.
- Al subir de nivel: mejora moderada y/o punto de habilidad.
- Evitar grind obligatorio; la ruta principal debe ser completables con exploración razonable.
- El nivel máximo de v1.0 se fija tras pruebas de duración y balance.

### 5.3 Equipamiento

Categorías: arma principal, protección, talismán y accesorio. Cada objeto tiene ID estable, rareza descriptiva, estadísticas, texto, fuente de obtención y restricciones si las hay. Evitar loot aleatorio infinito; usar recompensas diseñadas y tablas pequeñas.

### 5.4 Habilidades

Árboles cortos y diferenciados. Cada habilidad debe incluir coste, efecto, cooldown, requisitos, icono y explicación. No añadir habilidades que solo cambien números sin alterar decisiones.

### 5.5 Honor y Sombras

Valor interno normalizado (por ejemplo, -100 a +100) con acciones relevantes y límites para evitar farming repetitivo. Influye en:
- algunas respuestas y opciones de diálogo;
- acceso a una selección acotada de misiones;
- afinidad con técnicas puras o sombrías;
- escenas y desenlace.

No debe convertir cada conversación en un test moral. Mostrar feedback diegético, no una barra que revele toda la lógica.

## 6. Exploración, misiones y mundo

- Zonas conectadas con transiciones rápidas.
- Aldea segura con NPCs, tienda, herrería, descanso y tablón.
- Bosque, santuario, camino/clan y región espiritual como mínimo para el slice.
- Puertas, cofres, objetos interactivos, puntos de guardado y atajos.
- Misiones principales y secundarias persistentes.
- Mapa simple por región; no requiere mapa global complejo.
- Los encuentros aleatorios no deben interrumpir repetidamente el recorrido.
- Los puntos de descanso guardan y recuperan recursos según reglas explícitas.

## 7. Enemigos y jefes

Familias mínimas v1.0:
1. Yokai menor rápido.
2. Yokai pesado.
3. Yokai a distancia.
4. Guerrero humano/clan.
5. Élite con mecánica.
6. Jefe de capítulo.

Cada enemigo necesita ficha de diseño: rol, silueta, patrón, telegráfos, vulnerabilidades, resistencia, recompensa, animaciones y prueba de balance.

Cada jefe debe tener:
- presentación breve;
- al menos tres patrones distinguibles;
- ventanas de castigo;
- cambio de fase o escalada;
- recuperación tras derrota;
- recompensa y persistencia;
- test de combate repetible.

## 8. Arte, audio y UX

### 8.1 Dirección de pixel art

- Pixel art de alta legibilidad, no pixelado automático de ilustraciones.
- Resolución interna de referencia inicial: 480×270 o 640×360; decidir con pruebas de composición y escalado.
- Paleta por bioma con valores de contraste coherentes.
- Sprites con escala consistente, pivotes definidos y siluetas legibles.
- Animaciones requeridas: idle, run, turn, attack light, attack heavy, hit, dodge, guard, skill, interact, defeat.
- Fondos por capas con parallax moderado.
- VFX limitados y legibles; evitar ruido visual durante telegráfos.
- UI pixel art o tipografía bitmap compatible con idiomas requeridos.

### 8.2 Audio

- Música original o con licencia documentada.
- Ambientes por zona.
- SFX de ataque, impacto, bloqueo, esquiva, UI, recompensa y jefe.
- Mezcla con prioridades: señales de combate por encima del ambiente.
- Controles de volumen separados para música, efectos y ambiente.

### 8.3 Accesibilidad y UX

- Reasignación básica de controles cuando sea viable.
- Tamaño de controles táctiles ajustable.
- Texto legible, contraste y escalado de UI.
- Vibración opcional.
- Pausa accesible en cualquier momento fuera de cinemáticas no interactivas.
- Confirmación para borrar partida.
- Indicador de guardado y recuperación de datos.
- Tutorial que se puede revisar desde menú.

## 9. Arquitectura técnica propuesta

La arquitectura exacta se adaptará al estado real del repo en CP-00. Separar responsabilidades y datos.

Estructura objetivo sugerida:

```text
/
├── project.godot
├── README.md
├── docs/
│   ├── SPEC_V1.0.md
│   ├── ARCHITECTURE.md
│   ├── ART_BIBLE.md
│   ├── NARRATIVE_BIBLE.md
│   ├── QA_MATRIX.md
│   └── decisions/
├── .github/
│   ├── copilot-instructions.md
│   ├── agents/
│   └── workflows/
├── scenes/
│   ├── boot/
│   ├── menus/
│   ├── world/
│   ├── combat/
│   ├── characters/
│   └── ui/
├── scripts/
│   ├── core/
│   ├── combat/
│   ├── actors/
│   ├── progression/
│   ├── quests/
│   ├── save/
│   └── ui/
├── data/
│   ├── characters/
│   ├── enemies/
│   ├── items/
│   ├── skills/
│   ├── quests/
│   └── balance/
├── assets/
│   ├── characters/
│   ├── enemies/
│   ├── environments/
│   ├── ui/
│   ├── audio/
│   └── fonts/
└── tests/
    ├── unit/
    ├── integration/
    └── smoke/
```

No crear toda esta estructura vacía de golpe. Cada directorio aparece cuando existe contenido real.

### 9.1 Principios

- Datos de balance separados de lógica.
- IDs estables; no depender de nombres visibles traducibles.
- Componentes pequeños y escenas reutilizables.
- Autoloads limitados y documentados.
- Señales/eventos para desacoplar sistemas.
- Evitar singletons globales que mezclen estado de juego, UI y guardado.
- Guardado con versión de esquema, escritura atómica y recuperación ante archivo corrupto.
- RNG con semilla registrable para reproducir bugs.
- Recursos y texturas con import settings controlados.
- Sin plugins de terceros sin justificación, versión fijada y licencia.

### 9.2 Guardado

Guardar al menos:
- versión del esquema;
- capítulo/zona/posición segura;
- progreso de misiones;
- personajes desbloqueados;
- nivel, XP y habilidades;
- inventario/equipamiento;
- Honor/Sombras;
- flags narrativos;
- opciones de usuario.

Requisitos: dos slots o un slot principal más backup; escritura temporal y rename; validación de campos; migración de versiones; fallback seguro; no cargar datos arbitrarios como objetos ejecutables.

---

# PARTE II — ROADMAP POR FASES Y CHECKPOINTS

## 10. Mapa de fases

| Fase | Resultado | Checkpoints |
|---|---|---|
| 0 | Recuperación y baseline | CP-00 a CP-03 |
| 1 | Fundaciones técnicas | CP-04 a CP-07 |
| 2 | Prototipo de combate | CP-08 a CP-12 |
| 3 | Vertical slice | CP-13 a CP-18 |
| 4 | Sistemas RPG | CP-19 a CP-24 |
| 5 | Campaña y contenido | CP-25 a CP-31 |
| 6 | Pulido y producción | CP-32 a CP-37 |
| 7 | Release candidate y v1.0 | CP-38 a CP-42 |

### Fase 0 — Recuperación del proyecto

**CP-00 — Inventario forense del repositorio**  
Entregables: árbol completo, ramas, commits recientes, assets, scripts, escenas, workflows, documentación eliminada recuperable desde Git.  
Aceptación:
- inventario reproducible;
- lista de archivos actuales y ausentes;
- identificar commit histórico con el último estado funcional verificable;
- no restaurar automáticamente carpetas enteras sin revisión;
- registrar riesgos/licencias y deuda.

**CP-01 — Decisión de rescate**  
Entregables: informe KEEP / REWRITE / ADAPT por subsistema.  
Aceptación:
- cada componente histórico clasificado;
- razón técnica y coste aproximado;
- no afirmar que un sistema funciona sin ejecutarlo;
- propuesta de base Godot y versión.

**CP-02 — Recuperar documentación esencial**  
Entregables: README, ARCHITECTURE, ART_BIBLE, NARRATIVE_BIBLE y QA_MATRIX mínimos.  
Aceptación:
- documentos consistentes con esta spec;
- README explica cómo abrir, probar y exportar;
- estado real separado de roadmap.

**CP-03 — Baseline reproducible**  
Entregables: proyecto importable, comando headless de validación, workflow CI mínimo y artefacto de diagnóstico.  
Aceptación:
- Godot exacto fijado;
- import sin errores;
- validación headless verde;
- logs conservados;
- no se requiere secreto para validar el proyecto.

### Fase 1 — Fundaciones técnicas

**CP-04 — Boot y navegación**: arranque, pantalla título, menú, nueva partida, continuar y salir.  
**CP-05 — Input abstraction**: acciones de input para táctil, teclado y mando; prueba de remapeo básico.  
**CP-06 — Scene flow**: cargar/descargar escenas, transiciones, pausa y retorno sin duplicar nodos.  
**CP-07 — Persistencia base**: esquema de save versionado, escritura atómica, backup y tests de corrupción.

Aceptación de fase: arranque repetible, navegación sin errores, guardado recuperable y CI verde.

### Fase 2 — Prototipo de combate

**CP-08 — Player controller**: movimiento lateral, aceleración, frenado, salto si procede, límites de arena.  
**CP-09 — Máquina de estados de combate**: idle, locomotion, attack, recovery, dodge, guard, hitstun, defeat.  
**CP-10 — Hitboxes y daño**: áreas activas, invulnerabilidad, daño, knockback, debug overlay.  
**CP-11 — Primer enemigo**: IA finita, anticipación, ataque, recuperación, muerte y recompensa.  
**CP-12 — Encuentro de prueba**: arena repetible, HUD de debug y balance inicial.

Aceptación:
- input determinista y responsivo;
- no hay ataques dobles por un único input;
- hitboxes alineadas con animación;
- enemigo legible y derrotables;
- test automatizado de daño/estados donde sea posible;
- prueba manual grabada o documentada.

### Fase 3 — Vertical slice

**CP-13 — Akane final slice**: sprite, animaciones, paleta, armas y feedback.  
**CP-14 — Zona inicial**: aldea y bosque corto conectados, colisiones y cámara.  
**CP-15 — NPC y diálogo**: interacción, retratos o bustos pixel, flags de diálogo.  
**CP-16 — Tutorial integrado**: movimiento, combate, esquiva, guardia, interacción.  
**CP-17 — Jefe del slice**: patrones, fase, recompensa y retry.  
**CP-18 — Slice end-to-end**: título → partida → zona → combate → jefe → recompensa → guardar → continuar.

Aceptación:
- 15–25 minutos de contenido probado;
- al menos un recorrido completo sin intervención del editor;
- controles táctiles utilizables;
- guardado conserva el progreso;
- rendimiento medido en dispositivo objetivo;
- feedback de al menos una ronda de prueba y lista de correcciones.

### Fase 4 — Sistemas RPG

**CP-19 — XP y niveles**: curva de experiencia en datos y feedback.  
**CP-20 — Inventario**: objetos, stacks cuando proceda, filtros y descripción.  
**CP-21 — Equipamiento**: arma, protección, talismán y accesorio; recalcular atributos de forma centralizada.  
**CP-22 — Habilidades**: desbloqueo, costes, cooldowns, UI y persistencia.  
**CP-23 — Honor/Sombras**: eventos relevantes, límites, feedback y flags narrativos.  
**CP-24 — Misiones**: estados, objetivos, recompensas, seguimiento y guardado.

Aceptación:
- sistemas integrados, no pantallas aisladas;
- no duplicar recompensas al recargar;
- inventario y equipamiento sobreviven a reinicio;
- curvas y costes documentados;
- pruebas de regresión para economía y misiones.

### Fase 5 — Campaña y contenido

**CP-25 — Biblia narrativa cerrada**: arcos, cronología, glosario y fichas de personajes.  
**CP-26 — Capítulo I completo**: zonas, NPCs, misiones, jefe y transición.  
**CP-27 — Capítulo II completo**: Yoru, bosque, guardianes y decisiones.  
**CP-28 — Capítulo III completo**: Kioto, Hikari, intriga y jefe.  
**CP-29 — Capítulo IV completo**: región espiritual, Tsukiko y jefe.  
**CP-30 — Capítulo V y finales**: santuario central, jefe final y desenlaces.  
**CP-31 — Side content**: misiones secundarias, coleccionables, secretos y recompensas.

Aceptación:
- campaña principal completa de principio a fin;
- todos los objetivos de misión se pueden completar;
- no hay softlocks;
- finales accesibles mediante condiciones alcanzables;
- contenido narrativo revisado por continuidad y localización.

### Fase 6 — Pulido y producción

**CP-32 — Arte y animación completos**: roster, enemigos, jefes, tilesets y VFX.  
**CP-33 — Audio y mezcla**: música, ambiente, SFX, sliders y prioridades.  
**CP-34 — UX y accesibilidad**: tamaño de controles, escalado UI, contraste, tutorial revisitable, vibración opcional.  
**CP-35 — Balance**: curvas de daño, HP, stamina, economía, drops y dificultad.  
**CP-36 — Rendimiento**: perfiles, draw calls, memoria, carga de escenas, tamaño APK.  
**CP-37 — Localización**: español e inglés, cadenas externalizadas, prueba de expansión de texto.

Aceptación:
- no quedan assets placeholder en rutas críticas;
- no hay texto cortado;
- el combate mantiene claridad con VFX activos;
- objetivos de rendimiento medidos y documentados;
- todas las cadenas visibles están localizadas.

### Fase 7 — Release candidate y v1.0

**CP-38 — QA funcional completo**: matriz de dispositivos, flujos críticos y regresión.  
**CP-39 — Robustez**: suspensión/reanudación Android, llamadas/notificaciones, falta de espacio, save corrupto, cierre inesperado.  
**CP-40 — Seguridad y licencias**: inventario SBOM ligero, licencias de assets, permisos Android mínimos, secretos fuera del repo.  
**CP-41 — Release candidate**: versionado semántico, changelog, APK firmado según disponibilidad, checksum SHA-256 y notas de release.  
**CP-42 — Gate v1.0**: revisión final de criterios, evidencia, etiqueta Git y publicación de artefacto.

---

## 11. Definition of Done global

Un checkpoint solo puede cerrarse cuando:
- código y recursos están en el repositorio;
- la escena o sistema puede ejecutarse;
- pruebas relevantes pasan;
- no se introducen errores críticos conocidos;
- documentación refleja el comportamiento real;
- assets nuevos tienen procedencia y licencia;
- el agente añade evidencia (comando, run CI, captura o pasos de reproducción);
- otro agente o revisor distinto verifica el resultado.

## 12. Criterios de aceptación v1.0

### Producto
- Campaña principal de cinco capítulos completables.
- Cuatro protagonistas jugables o controlables en encuentros diseñados.
- Combate en tiempo real con ataque ligero/fuerte, esquiva, guardia y habilidades.
- Al menos cinco familias de enemigos y cinco jefes principales.
- Inventario, equipamiento, XP, habilidades, misiones y guardado.
- Sistema Honor/Sombras con consecuencias demostrables.
- Español e inglés para UI y textos principales.
- Juego completo offline.

### Android
- APK instalable en Android soportado.
- Orientación landscape estable.
- Controles táctiles utilizables.
- Suspender y reanudar no corrompe partida.
- Permisos mínimos.
- No depende de red.
- Tamaño, memoria y FPS documentados en dispositivo de referencia.

### Ingeniería
- Proyecto importa y valida en CI.
- Workflow exporta APK reproducible en versión de Godot fijada.
- Smoke tests para arranque, nueva partida, combate, guardado y carga.
- No hay errores críticos conocidos al publicar.
- README contiene instalación, controles, requisitos y enlace de artefacto.
- Licencias de todo contenido externo verificadas.

### Calidad
- 0 bloqueadores conocidos.
- 0 pérdida reproducible de partida.
- 0 softlocks en ruta principal.
- Ningún jefe obligatorio imposible de derrotar por bug.
- Prueba de recorrido completo en hardware real.
- Lista de limitaciones conocidas publicada.

## 13. Matriz de QA

| Área | Caso | Resultado esperado |
|---|---|---|
| Boot | Lanzar app limpia | Menú visible, sin crash |
| Nueva partida | Iniciar campaña | Spawn correcto y save creado |
| Input | Táctil/teclado | Acciones coherentes, sin input pegado |
| Combate | Ataque y esquiva | Estados y daño correctos |
| IA | Enemigo fuera de rango | No ataca a distancia inválida |
| Jefe | Cambiar de fase | Patrón y HUD coherentes |
| Inventario | Equipar/quitar | Stats recalculados una sola vez |
| Quest | Reclamar recompensa | No se duplica al recargar |
| Save | Cerrar y continuar | Progreso persistente |
| Save | Archivo corrupto | Recuperación segura o aviso |
| Android | Suspender/reanudar | Estado consistente |
| Localización | Cambiar idioma | Sin claves faltantes ni texto cortado |
| Rendimiento | Zona con muchos efectos | Cumple objetivo medido |
| Offline | Modo avión | Campaña sigue funcionando |

## 14. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Alcance excesivo | Slice antes de cinco capítulos; congelar features por fase |
| Rehacer sistemas existentes | Auditoría CP-00/01 y recuperación selectiva |
| Pixel art inconsistente | ART_BIBLE, paleta y tamaños fijados |
| Combate poco satisfactorio | Prototipo con test externo antes de producir contenido |
| APK frágil | CI headless + export + instalación smoke |
| Corrupción de saves | Escritura atómica, backup, migraciones y tests |
| Trabajo paralelo conflictivo | Propietarios por dominio y cambios pequeños |
| Licencias dudosas | Registro de assets y revisión antes de integrar |
| Rendimiento móvil | Presupuesto y profiling desde vertical slice |
| Traducción tardía | Cadenas externalizadas desde la primera UI |

---

# PARTE III — SISTEMA DE AGENTES

## 15. Modelo de trabajo multiagente

Los agentes son perfiles de trabajo persistentes definidos como archivos Markdown en `.github/agents/`. No son procesos autónomos que se ejecutan por sí solos: se invocan desde un entorno compatible con agentes (por ejemplo, GitHub Copilot coding agent o un orquestador) y necesitan permisos y tareas explícitas.

### 15.1 Roles

| Agente | Dominio | No debe decidir por su cuenta |
|---|---|---|
| Producer / Orchestrator | Plan, checkpoints, dependencias, integración | Cambiar visión o scope |
| Gameplay Engineer | Controlador, combate, IA, balance técnico | Reescribir narrativa o arte |
| RPG Systems Engineer | XP, inventario, equipo, quests, save | Cambiar contratos de combate |
| Pixel Art Director | Art bible, sprites, tilesets, UI visual | Cambiar mecánicas |
| Narrative Designer | Mundo, personajes, diálogos, misiones | Alterar arquitectura técnica |
| QA & Release Engineer | Tests, CI, Android, release gates | Marcar su propio trabajo como aceptado |

### 15.2 Protocolo de asignación

Toda tarea debe incluir:
- ID de checkpoint;
- objetivo observable;
- archivos o dominio autorizado;
- dependencias;
- criterios de aceptación;
- pruebas que debe ejecutar;
- evidencia a entregar;
- riesgos y bloqueos.

No asignar “haz el juego entero”. Asignar una unidad que pueda revisarse en un ciclo corto.

### 15.3 Integración

1. Producer selecciona el siguiente checkpoint desbloqueado.
2. Agente de dominio inspecciona primero el estado real.
3. Propone plan breve y lista de archivos.
4. Implementa el cambio mínimo.
5. Ejecuta pruebas y documenta resultados.
6. QA revisa de forma independiente.
7. Producer actualiza estado y desbloquea el siguiente checkpoint.
8. Si cambia una decisión de diseño, crear ADR en `docs/decisions/` y actualizar esta spec.

### 15.4 Límites de seguridad

- No imprimir ni copiar secretos.
- No añadir tokens, keystores ni credenciales al repositorio.
- No cambiar permisos de Actions ni publicar releases sin autorización explícita.
- No borrar historia, tags ni ramas.
- No hacer force-push.
- No modificar workflows de publicación sin QA.
- No añadir paquetes/plugins sin justificar mantenimiento, licencia y superficie de riesgo.
- No descargar ni integrar assets de procedencia dudosa.
- No asumir que un workflow verde prueba calidad jugable.

## 16. Agentes instalados en el repositorio

Las definiciones ejecutables de rol se encuentran en:
- `.github/agents/ronin-producer.agent.md`
- `.github/agents/ronin-gameplay.agent.md`
- `.github/agents/ronin-rpg-systems.agent.md`
- `.github/agents/ronin-pixel-art.agent.md`
- `.github/agents/ronin-narrative.agent.md`
- `.github/agents/ronin-qa-release.agent.md`

Cada agente debe leer este documento antes de iniciar una tarea y actualizar solo el estado de checkpoint que pueda demostrar.

## 17. Tablero inicial

Todos los checkpoints se inicializan como `NOT_STARTED`. CP-00 es el único trabajo autorizado para comenzar primero.

| ID | Estado | Responsable inicial | Evidencia requerida |
|---|---|---|---|
| CP-00 | ACCEPTED | Producer + QA | `docs/RECOVERY_AUDIT.md`, commit `ea246ba` |
| CP-01 | ACCEPTED | Producer | `docs/architecture.md`, ADR-001 y auditoría |
| CP-02 | IN_PROGRESS | Producer + Narrative | README, ART_BIBLE, NARRATIVE_BIBLE, QA_MATRIX |
| CP-03 | NOT_STARTED | QA/Release | CI baseline |
| CP-04–42 | NOT_STARTED | Según dominio | Según checkpoint |

No iniciar CP-04 hasta aceptar CP-03. No iniciar producción masiva de arte o capítulos antes de aceptar CP-18.

## 18. Plantilla de informe de checkpoint

```markdown
## CP-XX — Nombre
Estado: NOT_STARTED | IN_PROGRESS | BLOCKED | IN_REVIEW | ACCEPTED | DEFERRED
Responsable:
Dependencias:
Objetivo:
Archivos afectados:
Implementación:
Pruebas ejecutadas:
Resultados:
Evidencias (run, commit, captura, logs):
Riesgos/bloqueos:
Revisor independiente:
Decisión:
```

## 19. Plantilla de ADR

```markdown
# ADR-NNN — Título
Estado: Proposed | Accepted | Superseded
Fecha:
Contexto:
Decisión:
Alternativas:
Consecuencias:
Checkpoint afectado:
```

## 20. Primer sprint recomendado

**Sprint S0 — Reanimación, no producción de contenido**
1. Ejecutar CP-00.
2. Recuperar desde historial solo la documentación útil.
3. Confirmar versión Godot y estado Android.
4. Definir KEEP/REWRITE/ADAPT.
5. Crear CI mínimo reproducible.
6. Entregar un informe de riesgos y un plan de S1.

Salida de S0: repositorio entendido, proyecto importable o diagnóstico concreto de por qué no lo es. No se dibujan 40 sprites ni se construyen cinco capítulos en S0.

---

# PARTE IV — RELEASE Y GOBIERNO

## 21. Versionado

- `0.x`: prototipos y vertical slice.
- `0.9.0-rc.N`: release candidates.
- `1.0.0`: primera campaña completa, estable y verificable.
- Hotfix: `1.0.N`.

Cada release debe incluir commit/tag, changelog, checksum, versión Godot, configuración de exportación, resultado CI y limitaciones conocidas.

## 22. Definition of Release

No publicar v1.0 si:
- un checkpoint obligatorio está sin aceptar;
- hay bug que impide avanzar en campaña;
- el guardado pierde progreso;
- el APK no instala o no arranca en la matriz soportada;
- hay assets sin licencia verificada;
- no existe evidencia de prueba en hardware Android real;
- el README promete funciones no implementadas.

## 23. Glosario

- **Yokai:** entidades espirituales del universo del juego.
- **Sello:** mecanismo que separa o estabiliza ambos mundos.
- **Honor:** decisiones alineadas con deber, protección y transparencia.
- **Sombras:** decisiones que usan poder prohibido, engaño o pactos.
- **Vertical slice:** segmento pequeño pero representativo con calidad cercana al producto final.
- **Checkpoint:** unidad verificable de avance.
- **ADR:** registro de una decisión de arquitectura/diseño.
- **Softlock:** estado en el que el jugador no puede continuar sin reiniciar o perder progreso.

---

## Apéndice A — Decisiones pendientes que no bloquean CP-00

1. Resolución interna definitiva (480×270 vs 640×360).
2. Side-scroller puro vs arenas con ligera profundidad.
3. Cambio directo entre cuatro personajes vs Akane activa con asistencia.
4. Duración final de campaña y cantidad de misiones secundarias.
5. Curva de niveles y nivel máximo.
6. Modo de distribución y firma final del APK.
7. Dispositivos Android mínimos soportados.

El Producer debe proponer opciones basadas en pruebas y registrar ADR; no inventar respuestas como si ya estuvieran aprobadas.

## Apéndice B — Regla de oro

**Primero un combate excelente, después un slice completo, luego el RPG, y finalmente la campaña.**  
La v1.0 se gana con un juego terminado y comprobable, no con una lista larga de sistemas a medio hacer.
