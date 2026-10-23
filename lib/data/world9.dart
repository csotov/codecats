import '../models.dart';
import 'catalog.dart';

/// World 9 — Graphs via mazes: grids, flood fill, BFS, components.
/// Everything iterative (explicit stack/queue) — the competitive pattern.
final world9 = World(
  id: 'w9',
  titleEs: 'Laberinto de Grafos',
  titleEn: 'Graph Labyrinth',
  descEs: 'Recorre mapas como un explorador: BFS, flood fill y componentes.',
  descEn: 'Explore maps like an adventurer: BFS, flood fill and components.',
  icon: '⬡',
  levels: [
    lvl(
      id: 'w9l1',
      tEs: 'El mapa del tesoro',
      tEn: 'The treasure map',
      sEs: 'Antes de entrar al laberinto debes saber cuántos muros '
          'tiene. Cada # es una pared.',
      sEn: 'Before entering the labyrinth you must know how many '
          'walls it has. Each # is a wall.',
      dEs: 'Lee un mapa de n filas y m columnas. Cuenta cuántas '
          'casillas son muro (#) e imprime el total.',
      dEn: 'Read a map of n rows and m columns. Count how many '
          'cells are walls (#) and print the total.',
      iEs: 'n m / n líneas de m caracteres (. o #).',
      iEn: 'n m / n lines of m characters (. or #).',
      oEs: 'El número de muros.',
      oEn: 'The number of walls.',
      samples: [
        ['3 4\n####\n#..#\n####', '10'],
        ['2 5\n.....\n#..#.', '2'],
      ],
      tests: [
        ['4 4\n#..#\n.##.\n.##.\n#..#', '8'],
        ['1 1\n.', '0'],
        ['5 6\n######\n#....#\n#.##.#\n#....#\n######', '20'],
      ],
      cEs: ['1 ≤ n, m ≤ 20'],
      cEn: ['1 ≤ n, m ≤ 20'],
      hEs: [
        'Usa char c; cin >> c salta espacios y saltos de línea — '
            'puedes leer los n*m caracteres seguidos.',
        'Recorre i de 0 a n*m-1 y suma 1 cada vez que c sea #.',
      ],
      hEn: [
        'Use char c; cin >> c skips spaces and newlines — you can '
            'read the n*m characters in a row.',
        'Loop i from 0 to n*m-1 and add 1 whenever c is #.',
      ],
      xp: 500,
      concepts: const ['grids', 'chars'],
    ),
    lvl(
      id: 'w9l2',
      tEs: 'Vecinos libres',
      tEn: 'Free neighbors',
      sEs: 'Un explorador quiere saber hacia dónde puede moverse. '
          'Desde una casilla puede ir arriba, abajo, izquierda o derecha.',
      sEn: 'An explorer wants to know where he can move. '
          'From a cell he can go up, down, left or right.',
      dEs: 'Lee el mapa y una casilla (fila r, columna c, ambas '
          'empezando en 0). Imprime cuántos vecinos (arriba, abajo, '
          'izquierda, derecha) NO son muro ni están fuera del mapa.',
      dEn: 'Read the map and a cell (row r, column c, both '
          '0-indexed). Print how many neighbors (up, down, '
          'left, right) are NOT walls nor outside the map.',
      iEs: 'n m / n líneas / r c.',
      iEn: 'n m / n lines / r c.',
      oEs: 'Un número del 0 al 4.',
      oEn: 'A number from 0 to 4.',
      samples: [
        ['3 3\n###\n#.#\n###\n1 1', '0'],
        ['4 4\n....\n.##.\n.##.\n....\n0 0', '2'],
      ],
      tests: [
        ['3 4\n####\n#..#\n####\n1 1', '1'],
        ['4 4\n....\n.##.\n.##.\n....\n2 2', '2'],
        ['5 5\n#####\n#...#\n#.#.#\n#...#\n#####\n2 2', '4'],
      ],
      cEs: ['1 ≤ n, m ≤ 20', 'la casilla dada nunca es muro'],
      cEn: ['1 ≤ n, m ≤ 20', 'the given cell is never a wall'],
      hEs: [
        'Guarda el mapa en char g[20][20].',
        'Los 4 vecinos de (r,c): (r-1,c), (r+1,c), (r,c-1), (r,c+1). '
            'Cuidado con los bordes: nr debe estar entre 0 y n-1.',
      ],
      hEn: [
        'Store the map in char g[20][20].',
        'The 4 neighbors of (r,c): (r-1,c), (r+1,c), (r,c-1), (r,c+1). '
            'Watch the borders: nr must be between 0 and n-1.',
      ],
      xp: 500,
      concepts: const ['grids', '4 directions'],
    ),
    lvl(
      id: 'w9l3',
      tEs: 'Marcando territorio',
      tEn: 'Claiming territory',
      sEs: 'El gato explorador empieza en S y marca todo lo que '
          'puede alcanzar. ¿Cuántas casillas conquista?',
      sEn: 'The explorer cat starts at S and marks everything it '
          'can reach. How many cells does it conquer?',
      dEs: 'Lee el mapa. Desde S puedes moverte a casillas vecinas '
          'que no sean muro (#). Imprime cuántas casillas alcanzas, '
          'contando también la S.',
      dEn: 'Read the map. From S you can move to neighbor cells '
          'that are not walls (#). Print how many cells you reach, '
          'counting S itself too.',
      iEs: 'n m / n líneas con . # y una S.',
      iEn: 'n m / n lines with . # and one S.',
      oEs: 'Casillas alcanzables desde S.',
      oEn: 'Cells reachable from S.',
      samples: [
        ['3 4\n#S.#\n...#\n#..#', '7'],
        ['2 3\nS#.\n.#.', '2'],
      ],
      tests: [
        ['4 4\n....\n.##.\n.#S.\n....', '13'],
        ['1 5\nS#..#', '1'],
        ['5 5\n#####\n#S..#\n#.###\n#...#\n#####', '7'],
      ],
      cEs: ['1 ≤ n, m ≤ 20', 'hay exactamente una S'],
      cEn: ['1 ≤ n, m ≤ 20', 'there is exactly one S'],
      hEs: [
        'Idea: flood fill. Guarda una matriz vis[n][m] para no '
            'visitar dos veces la misma casilla.',
        'Usa dos arreglos qr[], qc[] como cola: mete S, saca casilla '
            'por casilla y mete sus vecinos libres.',
        'Cada casilla que saques de la cola suma 1.',
      ],
      hEn: [
        'Idea: flood fill. Keep a vis[n][m] matrix so you never '
            'visit the same cell twice.',
        'Use two arrays qr[], qc[] as a queue: push S, pop cell by '
            'cell and push its free neighbors.',
        'Every cell you pop from the queue adds 1.',
      ],
      xp: 520,
      concepts: const ['flood fill', 'BFS/DFS', 'visited'],
    ),
    lvl(
      id: 'w9l4',
      tEs: '¿Llegas a la meta?',
      tEn: 'Can you reach the goal?',
      sEs: 'La salida E brilla al otro lado del laberinto. '
          'Pero no todos los mapas tienen camino…',
      sEn: 'The exit E glows across the labyrinth. '
          'But not every map has a path…',
      dEs: 'Lee el mapa con S (inicio) y E (salida). Imprime SI si '
          'existe un camino de S a E moviéndote por casillas sin '
          'muro, o NO si no existe.',
      dEn: 'Read the map with S (start) and E (exit). Print SI if '
          'a path exists from S to E moving through non-wall cells, '
          'or NO if it does not.',
      iEs: 'n m / n líneas con . # S E.',
      iEn: 'n m / n lines with . # S E.',
      oEs: 'SI o NO.',
      oEn: 'SI or NO.',
      samples: [
        ['3 4\nS..#\n##.#\nE..#', 'SI'],
        ['5 5\nS....\n#####\n.....\n#####\n....E', 'NO'],
      ],
      tests: [
        ['3 3\nS#E\n.#.\n...', 'SI'],
        ['4 4\nS...\n.##.\n.##E\n....', 'SI'],
        ['2 2\nSE\n##', 'SI'],
      ],
      cEs: ['1 ≤ n, m ≤ 20'],
      cEn: ['1 ≤ n, m ≤ 20'],
      hEs: [
        'Haz el mismo flood fill desde S que el nivel anterior.',
        'Al final revisa si la casilla de E quedó marcada como '
            'visitada.',
      ],
      hEn: [
        'Do the same flood fill from S as the previous level.',
        'At the end check whether the E cell ended up marked as '
            'visited.',
      ],
      xp: 520,
      concepts: const ['flood fill', 'reachability'],
    ),
    lvl(
      id: 'w9l5',
      tEs: 'El camino más corto',
      tEn: 'The shortest path',
      sEs: 'El héroe no solo quiere llegar: quiere llegar con el '
          'menor número de pasos. Eso lo hace el poderoso BFS.',
      sEn: 'The hero does not just want to arrive: he wants the '
          'fewest steps. That is what mighty BFS does.',
      dEs: 'Lee el mapa con S y E. Imprime el mínimo número de '
          'pasos para ir de S a E (cada movimiento a vecino cuenta '
          '1). Si no hay camino, imprime -1.',
      dEn: 'Read the map with S and E. Print the minimum number '
          'of steps from S to E (each neighbor move counts 1). '
          'If there is no path, print -1.',
      iEs: 'n m / n líneas con . # S E.',
      iEn: 'n m / n lines with . # S E.',
      oEs: 'Pasos mínimos, o -1.',
      oEn: 'Minimum steps, or -1.',
      samples: [
        ['3 4\nS..#\n##.#\nE..#', '6'],
        ['2 2\nSE\n##', '1'],
      ],
      tests: [
        ['4 4\nS...\n###.\n...#\n.#.E', '-1'],
        ['3 3\nS#E\n...\n...', '4'],
        ['5 5\nS....\n.###.\n.#.#.\n.#.#.\n.###E', '8'],
      ],
      cEs: ['1 ≤ n, m ≤ 20'],
      cEn: ['1 ≤ n, m ≤ 20'],
      hEs: [
        'BFS: en vez de marcar visitado, guarda dis[r][c] = '
            'pasos desde S. Inicia todo en -1.',
        'Cuando sacas (r,c), cada vecino libre con dis -1 recibe '
            'dis[r][c] + 1 y entra a la cola.',
        'La respuesta es dis de la casilla E.',
      ],
      hEn: [
        'BFS: instead of marking visited, store dis[r][c] = '
            'steps from S. Initialize everything to -1.',
        'When you pop (r,c), every free neighbor with dis -1 gets '
            'dis[r][c] + 1 and enters the queue.',
        'The answer is the dis of the E cell.',
      ],
      xp: 540,
      concepts: const ['BFS', 'shortest path', 'distances'],
    ),
    lvl(
      id: 'w9l6',
      tEs: '¿Cuántas habitaciones?',
      tEn: 'How many rooms?',
      sEs: 'El castillo tiene varias habitaciones separadas por '
          'muros. Cada grupo de casillas juntas es una habitación.',
      sEn: 'The castle has several rooms separated by walls. '
          'Each group of connected cells is a room.',
      dEs: 'Lee el mapa con . (piso) y # (muro). Imprime cuántas '
          'habitaciones hay: grupos de casillas . conectadas entre '
          'sí por los 4 lados.',
      dEn: 'Read the map with . (floor) and # (wall). Print how '
          'many rooms there are: groups of . cells connected '
          'through the 4 sides.',
      iEs: 'n m / n líneas con . y #.',
      iEn: 'n m / n lines with . and #.',
      oEs: 'Número de habitaciones.',
      oEn: 'Number of rooms.',
      samples: [
        ['3 4\n....\n####\n....', '2'],
        ['2 2\n.#\n#.', '2'],
      ],
      tests: [
        ['4 4\n.#..\n.#.#\n...#\n##.#', '1'],
        ['1 5\n.#.#.', '3'],
        ['5 5\n.....\n.###.\n.#.#.\n.###.\n.....', '2'],
      ],
      cEs: ['1 ≤ n, m ≤ 20'],
      cEn: ['1 ≤ n, m ≤ 20'],
      hEs: [
        'Recorre TODAS las casillas. Cuando encuentres un . no '
            'visitado, nace una habitación nueva: súmala y haz '
            'flood fill desde ahí.',
        'El truco: el flood fill marca la habitación completa, así '
            'la siguiente . sin visitar pertenece a otra.',
      ],
      hEn: [
        'Scan ALL cells. When you find an unvisited ., a new room '
            'is born: count it and flood fill from there.',
        'The trick: the flood fill marks the whole room, so the '
            'next unvisited . belongs to a different one.',
      ],
      xp: 520,
      concepts: const ['connected components', 'flood fill'],
    ),
    lvl(
      id: 'w9l7',
      tEs: 'La habitación más grande',
      tEn: 'The biggest room',
      sEs: 'El gato quiere la habitación más grande del castillo '
          'para dormir la siesta.',
      sEn: 'The cat wants the biggest room in the castle '
          'for its nap.',
      dEs: 'Lee el mapa con . y #. Imprime el tamaño (número de '
          'casillas) de la habitación más grande.',
      dEn: 'Read the map with . and #. Print the size (number of '
          'cells) of the biggest room.',
      iEs: 'n m / n líneas con . y #.',
      iEn: 'n m / n lines with . and #.',
      oEs: 'El tamaño máximo.',
      oEn: 'The maximum size.',
      samples: [
        ['3 4\n....\n####\n....', '4'],
        ['2 2\n.#\n#.', '1'],
      ],
      tests: [
        ['4 4\n.#..\n.#.#\n...#\n##.#', '9'],
        ['3 3\n...\n...\n...', '9'],
        ['5 5\n.#.#.\n#.#.#\n.#.#.\n#.#.#\n.#.#.', '1'],
      ],
      cEs: ['1 ≤ n, m ≤ 20'],
      cEn: ['1 ≤ n, m ≤ 20'],
      hEs: [
        'Igual que contar habitaciones, pero dentro del flood fill '
            'cuenta cuántas casillas sacas de la cola.',
        'Guarda el mejor (máximo) de todos los conteos.',
      ],
      hEn: [
        'Same as counting rooms, but inside the flood fill count '
            'how many cells you pop from the queue.',
        'Keep the best (maximum) of all counts.',
      ],
      xp: 540,
      concepts: const ['connected components', 'flood fill'],
    ),
    lvl(
      id: 'w9l8',
      tEs: 'Tesoros al alcance',
      tEn: 'Treasures within reach',
      sEs: 'Hay tesoros (T) escondidos por el laberinto, pero el '
          'héroe solo tiene energía para dar K pasos.',
      sEn: 'Treasures (T) are hidden around the labyrinth, but '
          'the hero only has energy for K steps.',
      dEs: 'Lee el mapa con S, ., # y tesoros T. Imprime cuántos '
          'tesoros puede alcanzar el héroe caminando a lo sumo K '
          'pasos desde S.',
      dEn: 'Read the map with S, ., # and treasures T. Print how '
          'many treasures the hero can reach walking at most K '
          'steps from S.',
      iEs: 'n m k / n líneas.',
      iEn: 'n m k / n lines.',
      oEs: 'Tesoros alcanzables.',
      oEn: 'Reachable treasures.',
      samples: [
        ['3 4 2\nS.T#\n.T.#\n..T#', '2'],
        ['3 4 1\nS.T#\n.T.#\n..T#', '0'],
      ],
      tests: [
        ['4 4 3\nS..T\n.##.\nT.T.\n....', '2'],
        ['2 3 0\nSTT\nTTT', '0'],
        ['5 5 6\nS...#\n###.#\n#T#.#\n#.#T#\n#...#', '1'],
      ],
      cEs: ['1 ≤ n, m ≤ 20', '0 ≤ k ≤ 400'],
      cEn: ['1 ≤ n, m ≤ 20', '0 ≤ k ≤ 400'],
      hEs: [
        'Haz el BFS con distancias desde S (como el nivel del '
            'camino más corto).',
        'Al sacar cada casilla, si es una T y su distancia es '
            '≤ k, cuéntala.',
      ],
      hEn: [
        'Run the BFS with distances from S (like the shortest '
            'path level).',
        'When popping each cell, if it is a T and its distance is '
            '≤ k, count it.',
      ],
      xp: 550,
      concepts: const ['BFS', 'distance limit'],
    ),
    lvl(
      id: 'w9l9',
      tEs: '¿A qué distancia queda?',
      tEn: 'How far is it?',
      sEs: 'El explorador señala una casilla del mapa y pregunta: '
          '¿cuántos pasos me toma llegar ahí?',
      sEn: 'The explorer points to a cell on the map and asks: '
          'how many steps does it take me to get there?',
      dEs: 'Lee el mapa con S y luego una casilla destino (r, c). '
          'Imprime la distancia mínima en pasos desde S, o -1 si '
          'no se puede llegar.',
      dEn: 'Read the map with S and then a target cell (r, c). '
          'Print the minimum steps from S, or -1 if it cannot '
          'be reached.',
      iEs: 'n m / n líneas / r c.',
      iEn: 'n m / n lines / r c.',
      oEs: 'Distancia mínima, o -1.',
      oEn: 'Minimum distance, or -1.',
      samples: [
        ['3 4\nS..#\n##.#\n...#\n2 0', '6'],
        ['3 4\nS..#\n##.#\n...#\n2 3', '-1'],
      ],
      tests: [
        ['4 4\nS...\n.##.\n.##.\n....\n3 3', '6'],
        ['2 3\nS..\n###\n1 2', '-1'],
        ['5 5\nS....\n#####\n.....\n#####\n....#\n2 0', '-1'],
      ],
      cEs: ['1 ≤ n, m ≤ 20'],
      cEn: ['1 ≤ n, m ≤ 20'],
      hEs: [
        'Es exactamente el BFS con dis[][] — solo que la meta '
            'ahora viene como coordenada y puede ser un muro o '
            'casilla aislada (resultado -1).',
      ],
      hEn: [
        'It is exactly the BFS with dis[][] — only the target '
            'now comes as a coordinate and may be a wall or an '
            'isolated cell (result -1).',
      ],
      xp: 560,
      concepts: const ['BFS', 'distances'],
    ),
    lvl(
      id: 'w9l10',
      tEs: 'JEFE: La gran huida',
      tEn: 'BOSS: The great escape',
      sEs: '¡El dragón despertó! El laberinto tiene varias salidas '
          'E. Corre a la MÁS cercana.',
      sEn: 'The dragon woke up! The labyrinth has several '
          'exits E. Run to the CLOSEST one.',
      dEs: 'Lee el mapa con una S y varias salidas E. Imprime el '
          'mínimo número de pasos para llegar a CUALQUIER salida. '
          'Si ninguna es alcanzable, imprime -1.',
      dEn: 'Read the map with one S and several exits E. Print '
          'the minimum steps to reach ANY exit. If none is '
          'reachable, print -1.',
      iEs: 'n m / n líneas con . # S y varias E.',
      iEn: 'n m / n lines with . # S and several E.',
      oEs: 'Distancia a la salida más cercana, o -1.',
      oEn: 'Distance to the nearest exit, or -1.',
      samples: [
        ['4 5\nS...#\n###.#\n#E..#\n#.#.E', '7'],
        ['3 5\nS.#E.\n.##..\nE....', '2'],
      ],
      tests: [
        ['5 5\nS....\n#####\n#...#\n#.###\n#E###', '-1'],
        ['4 4\nS##.\n##.#\n..#E\nE..#', '-1'],
        ['6 6\nS....#\n.###.#\n.#.#.#\n.#.#.#\n.#...#\n.###E#', '9'],
      ],
      cEs: ['1 ≤ n, m ≤ 20'],
      cEn: ['1 ≤ n, m ≤ 20'],
      hEs: [
        'BFS desde S como siempre, pero al sacar cada casilla '
            'revisa si es una E.',
        'El BFS saca las casillas en orden de distancia — puedes '
            'guardar el mínimo de distancias de todas las E, o '
            'mejor: para apenas veas la primera E (esa ES la más '
            'cercana).',
      ],
      hEn: [
        'BFS from S as usual, but when popping each cell check '
            'if it is an E.',
        'BFS pops cells in distance order — you can keep the '
            'minimum distance over all E cells, or better: stop '
            'as soon as you see the first E (that IS the closest).',
      ],
      xp: 700,
      boss: true,
      concepts: const ['BFS', 'multi-target', 'boss'],
    ),
  ],
);
