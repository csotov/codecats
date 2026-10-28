# CodeCats 🐱⚔️

Un juego para aprender **C++ y algoritmos (DSA)** jugando — pensado para
niños desde ~10 años con el camino hacia la **IOI** (Olimpiada
Internacional de Informática) como meta.

Learn **C++ and DSA** by fighting code battles — aimed at kids ~10+
on the road to competitive programming / IOI.

## Cómo funciona / How it works

- **Batallas de código**: cada nivel es un problema de juez online
  (entrada → salida) con ejemplos visibles y pruebas ocultas.
- **Bloques → C++ real**: los primeros niveles usan un editor de bloques
  que genera C++ de verdad (se ve el código generado en vivo). Luego se
  pasa a escribir código directamente.
- **Intérprete C++ local**: el código se ejecuta con
  [JSCPP](https://github.com/felixhao28/JSCPP), un intérprete de C++ en
  JavaScript. **100% offline**: sin servidor, sin instalar un compilador.
- **Juez integrado**: comparación de salida insensible a espacios
  (como los jueces reales), límite de pasos contra bucles infinitos,
  y timeouts.
- **Gamificación**: XP, estrellas por nivel (3 = resolver a la primera
  sin pistas), rangos Bronce → IOI, jefes al final de cada mundo.
- **Bilingüe ES/EN** desde el menú.

## El camino original / Original curriculum (mundos 1–8)

> Tabla histórica del MVP. Hoy hay 15 mundos + Halloween; ver
> "Estado actual" más abajo.

| Mundo | Tema | Niveles |
|-------|------|---------|
| 1 | `cout`, `cin`, variables, aritmética, `%` | 10 |
| 2 | `if/else`, comparaciones, `&&`, `\|\|` | 10 |
| 3 | `for`, `while`, acumuladores, dígitos, bucles anidados | 10 |
| 4 | Arreglos `int a[]`, `char s[]`, `strlen`, recorridos | 10 |
| 5 | Funciones, `return`, recursión (fact, fib, mcd, primos) | 10 |
| 6 | Burbuja, selección, búsqueda lineal y **binaria** | 8 |
| 7 | Pila, cola, frecuencias, paréntesis, merge | 8 |
| 8 | **Prefix sums, sliding window, greedy, DP, DFS, Kadane** | 8 |

## Ejecutar / Run

### Web (sin instalar nada para el jugador)

```bash
flutter pub get
flutter run -d chrome        # desarrollo
flutter build web --release  # producción → build/web/
```

El contenido de `build/web/` es estático: súbelo a GitHub Pages,
Netlify, itch.io o cualquier hosting. El workflow incluido lo publica
en GitHub Pages automáticamente.

### Android (APK)

```bash
flutter build apk --release            # un solo APK
flutter build apk --release --split-per-abi   # APKs más livianos
```

Requiere Android SDK. **Alternativa sin instalar nada**: sube el repo a
GitHub y el workflow `.github/workflows/build.yml` compila el APK y lo
deja como artefacto descargable.

## Arquitectura

```
lib/
  data/        mundos y niveles (contenido)
  engine/      runner (JSCPP vía flutter_js / Web Worker), juez, bloques
  services/    progreso persistente (SharedPreferences)
  ui/          mapa, pantalla de batalla, editores, resultados
assets/vendor/ JSCPP.es5.min.js + runner.js (wrapper con límite de pasos)
web/           jscpp_worker.js (worker para la versión web)
```

### Backend de ejecución

| Plataforma | Implementación |
|------------|----------------|
| Web        | Web Worker + JSCPP (terminable → timeout real) |
| Android    | flutter_js (QuickJS) + JSCPP |
| Tests      | runners falsos en `test/` |

`runner.js` usa el modo *debugger* de JSCPP para contar pasos y cortar
bucles infinitos de forma determinista (`maxOps` por nivel).

### Nota sobre C++ soportado

JSCPP soporta un subconjunto educativo de C++ (verificado end-to-end):
`iostream`, `cstdio`, `cstdlib`, `cstring`, `cmath`, `cctype`, `ctime`,
`iomanip`, arreglos C 1D/2D, `char[]`, funciones, recursión moderada.

**Limitaciones conocidas** (probadas en `tools/engine_test.js`):
- Sin `std::vector`, `std::string`, `<algorithm>` ni `struct` propios
  (los niveles que los necesitan usan el g++ remoto; ver formato grader).
- `strcmp` de `cstring` está roto (los niveles comparan `s[i]` a mano).
- Las llamadas a función son costosas (~ms c/u): la recursión sirve
  solo para profundidades pequeñas; los niveles la usan así
  (fact, mcd, dígitos, DFS en rejillas ≤ 4×4) y fib se enseña iterativo.
- Bucles grandes son lentos: los niveles mantienen ≤ ~2k iteraciones.
- Sin compilador real ni `bits/stdc++.h`: las estructuras y ordenamientos
  se implementan **a mano** — además es lo correcto pedagógicamente para
  la IOI. El compilador remoto ya existe (`runner_remote.dart`).

## Estado actual / Current state (para personas e IAs)

> Esta sección resume cómo está hecho el juego **hoy**. Si sos una IA que
> va a modificar el repo, leela entera antes de tocar código.

### Para quién y reglas de producto

- Jugador principal: un niño principiante que se prepara para la **OBI
  de Bolivia** (Departamental → Nacional → campamento → IOI). El padre no
  es técnico y mira el avance desde el panel de admin.
- Objetivo: práctica diaria con baja frustración. Reglas que no se rompen:
  - No introducir fuerza bruta, comparación lenta vs rápida ni algoritmos
    nuevos antes de los mundos que los enseñan.
  - No anticipar nombres ni detalles de gorritos/recompensas no obtenidas.
  - El progreso del niño es sagrado: nunca borrar sin confirmación y
    fusionar siempre de forma conservadora (máximos / uniones).
  - UI usable con touchpad: scrollbars anchas y visibles, flechas y
    PgUp/PgDn, tooltips cortos en botones, celular de ~390 px.
  - Textos en español rioplatense (voseo) con humor gatuno; casi todo es
    bilingüe ES/EN con pares `xxxEs` / `xxxEn` o `L.instance.pick(es, en)`.

### Contenido

- Campaña: `lib/data/world1.dart` … `world15.dart` (+ `world_more.dart`
  con niveles extra de los mundos 1–3), registrados en `worlds.dart`.
  IDs `w<mundo>l<nivel>`; el nivel 10 de cada mundo suele ser el jefe
  (`boss: true`). `Level` está en `lib/models.dart`.
- Halloween (`halloween.dart`, `halloween_screen.dart`): laboratorio con
  formato OBI completo, subtareas y puntaje parcial (p. ej. 50/100).
- Otras actividades: simulacros (`contest*.dart`), OBI/IOI/CSP-J
  (`obi_tasks.dart`, `ioi_tasks.dart`, `cspj.dart`), gimnasio de
  matemática, "Escribir de memoria" (`recall_snippets.dart`), "Sé la
  computadora" (`trace_exercises.dart`), problemas del entrenador
  (`coach_problems.dart`, tabla Supabase `coach_problems`).

### Formato grader (estilo OBI) — lo más importante

La OBI (ver modelo de examen en obi.org.bo) y la IOI no usan `cin`/`cout`
en la solución: el alumno completa **solo una función** en `<tarea>.cpp`,
y un `grader.cpp` oculto lee la entrada, llama a la función e imprime lo
que devuelve. El juego imita eso en la campaña.

- Definición: `lib/data/grader_specs.dart`, mapa `kGraderSpecs`
  (`levelId → GraderSpec`). Hoy cubre **los mundos 1–3** (46 niveles).
  Los mundos 4+ siguen en formato clásico `cin`/`cout` (pendiente migrar).
- `GraderSpec(sigs, main, es, en, {storyEs, storyEn})`:
  - `sigs`: firmas que el alumno implementa, p. ej.
    `['int perimetro(int h, int w)', 'int area(int h, int w)']`.
  - `main`: cuerpo del `main` del grader (lee, llama, imprime).
  - `es`/`en`: consigna corta; `storyEs/En` reemplaza historias que
    hablaban de `cout`.
- Código inicial (`starter`) igual al `placa.cpp` oficial:

  ```cpp
  #include "perimetro.h"

  int perimetro(int h, int w)
  {
      // Tu codigo aqui
      return 0;
  }
  ```

- Al ejecutar, `wrap(code)` quita el `#include "<tarea>.h"` virtual,
  antepone includes y agrega el `main` del grader. Los tests del nivel
  (`samples`/`tests` con entrada/salida de texto) no cambian.
- Convenciones de nombres (como OBI / open-r1/ioi): funciones cortas en
  minúscula con `_` (`suma`, `es_par`, `fizz`), parámetros de 1–2 letras
  (`n`, `a`, `h`, `w`). Tipos como en la OBI: `int`, `long long`, `bool`,
  `char`, `std::string`, `std::vector<int>`. **No** inventar funciones de
  salida (`responder`, `dibujar`) ni usar `char*` / `int a[]`.
- Dónde corre:
  - Números / bool / char → intérprete local JSCPP (instantáneo).
  - Si alguna firma usa `string` o `vector` (`GraderSpec.remote`) → g++
    real en la nube (`lib/engine/runner_remote.dart`, Wandbox por
    defecto, configurable con `--dart-define=JUDGE_URL=...`). Tarda unos
    segundos y tiene límite de uso por minuto.
  - Dibujos con asteriscos (pirámide, escalera) quedan en `cout` porque
    en la OBI no hay problemas así.
  - Desde el mundo 6 todo nivel de código usa el juez remoto
    (`autoRemoteJudge` en `level_screen.dart`).
- Interruptor: botón "🧩 Grader" en cada nivel; `GraderPref` guarda la
  elección en `SharedPreferences` (`grader_format`, activado por
  defecto). Desactivado → `graderFor()` devuelve `null` y el nivel vuelve
  a `cin`/`cout`.
- Halloween y los simulacros OBI usan además `ObiJudge`
  (`lib/engine/obi_judge.dart`) y `ObiTask` (`lib/data/obi_models.dart`):
  compila `<tarea>.h + <tarea>.cpp + grader` como un programa, mapea los
  errores a `<tarea>.cpp:LINEA` y puntúa por subtareas.
- Al agregar un nivel grader: escribir la firma y el `main`, y comprobar
  a mano con una solución correcta que pase todos los casos del nivel.
  `test/grader_specs_test.dart` solo verifica que cada spec apunte a un
  nivel real y arme un programa completo.

### Ayudas pedagógicas al jugar un nivel (`lib/ui/level_screen.dart`)

- **Pista gratis adaptativa** (`lib/engine/adaptive_hint.dart`): en
  problemas largos/jefes se ofrece a los 3 min sin avanzar; en cortos a
  los 5 min, tras contestar una pregunta de 2 opciones
  (`lib/data/hint_quiz.dart`). Mira el código y el último resultado (falta
  `return`, `cin` en modo grader, error de compilación, ejemplo distinto)
  y dice qué revisar, sin dar la solución.
- **Coach** (`lib/engine/coach.dart`): traduce errores en pistas; las
  rachas de fallos escalan la ayuda y disparan charlas de mentalidad
  (`lib/data/profe_talks.dart`).
- **Así lo resolvió un experto** (llega con el PR #57;
  `lib/data/expert_solutions.dart`,
  `lib/ui/expert_screen.dart`): tras la primera victoria en jefes y
  niveles difíciles de los mundos 1–3, recorre la solución línea por
  línea con el Profe. Se muestra una vez por nivel (marca
  `talk_exp_<id>`), nunca en modo examen. Las soluciones usan las mismas
  firmas que `grader_specs.dart`.
- Victoria: estrellas, XP, Miaudólares, gatos, Gorrito Gatuno, cartas
  doradas (`victory.dart`, `golden_card.dart`). El tutorial experto va
  después de los diálogos de recompensa.
- Personajes y tutoriales: `lib/ui/professor.dart` (`ProfessorDialog`,
  `SpotlightTutorial`), lección grader en `obi_lesson.dart`, charla de la
  Departamental con voz en `departamental_talk.dart`.

### Progreso, perfiles y nube

- `lib/services/progress.dart` (`Progress.instance`): todo el estado local
  en `SharedPreferences`, por **perfil** (`Profile`, varios por
  dispositivo). Marcas sueltas viven en `mathGym` con prefijos
  (`talk_<id>`, `mem_<deck>`, …) para que se sincronicen sin cambiar el
  esquema.
- Nube: Supabase (`lib/services/cloud.dart`, migraciones en
  `supabase/migrations/`). Tablas: `profiles`, `progress_snapshots` (un
  snapshot JSON por usuario), `events` (telemetría), `admin_emails`,
  `coach_problems`.
- Cuenta ↔ perfil: `Profile.acct` guarda el user id; el snapshot lleva
  `pn`/`pe` (nombre/emoji). Al iniciar sesión en un dispositivo nuevo,
  `linkAccount()` abre o crea el perfil de la cuenta. **Solo el perfil
  enlazado sube cambios**; la sincronización es pull → merge (máximos y
  uniones) → push, así dos dispositivos no se pisan.
- Telemetría: `Cloud.log(type, levelId:, data:)` encola el `data` **por
  referencia**: copiá (`Map.of`) cualquier mapa que después se limpie.
  El panel de admin (`admin_screen.dart`) arma el informe de escritura,
  tiempos, errores y abandonos con esos eventos.
- Antes de modificar datos reales en Supabase, hacer un respaldo.

### Desarrollo

```bash
flutter analyze
flutter test
flutter build web --release \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

- `analyze` tiene avisos viejos (`withOpacity`, código muerto en la
  tienda); no agregar errores ni avisos nuevos.
- Cada push a `main` publica en GitHub Pages (`.github/workflows/build.yml`).
  Si varios merges caen juntos, el deploy puede fallar por "in progress
  deployment": volver a correr el workflow.
- Música de jefes y memes: `assets/` (fragmentos de canciones reales;
  revisar derechos si el juego se hace público).

### Pendiente (roadmap)

- Migrar los mundos 4+ al formato grader.
- Cuaderno de errores con repasos a 3 y 10 días; pantalla "Mi semana";
  reportes semanales para el padre.
- Simulacros con enunciados largos; etiquetas de dificultad;
  cierre de mundo (repaso + Ronda Coder + gimnasio) para mundos 4+.
- Más tutoriales "Así lo resolvió un experto" a medida que avanza.

