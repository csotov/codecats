/// Longer, contest-style Spanish statements for worlds 1–3: they tell the
/// story and what the samples mean, without saying how to solve it.
/// [hints] are a bit longer than the originals and [opts] feed the
/// "¿Qué hace tu código?" quiz (the first option is the right one).
class ProblemText {
  const ProblemText(this.es, this.hints, this.opts);
  final String es;
  final List<String> hints;
  final List<String> opts;
}

ProblemText? problemTextFor(String levelId) => kProblemTexts[levelId];

const kProblemTexts = <String, ProblemText>{
  'w1l1': ProblemText(
    'Todo gato guerrero entra a la arena saludando. El jurado de la arena '
    'solo te deja pasar si tu programa saluda con la palabra exacta: '
    'Hola. Ojo: para el jurado, "hola" o "Hola!" no son lo mismo.\n'
    'En el ejemplo no hay entrada y la salida es Hola.',
    [
      'El jurado compara letra por letra, también mayúsculas y signos. '
          'Fijate que tu respuesta sea exactamente la del ejemplo.',
      'Un texto en C++ siempre va entre comillas dobles. Lo que está '
          'adentro de las comillas es lo que se va a mostrar.',
    ],
    [
      'Devuelve siempre la palabra Hola, sin leer nada.',
      'Lee una palabra y la devuelve igual.',
      'Devuelve la palabra Hola tantas veces como diga la entrada.',
      'Devuelve hola en minúsculas.',
    ],
  ),
  'w1l2': ProblemText(
    'La arena tiene un cartel de dos líneas. Arriba tiene que decir Code y '
    'abajo Arena, cada palabra en su propia línea.\n'
    'En el ejemplo no hay entrada: la primera línea de la salida es Code '
    'y la segunda es Arena.',
    [
      'Hay dos cosas para responder, una por línea. Pensá qué va en la '
          'primera y qué va en la segunda.',
      'Revisá las mayúsculas: Code y Arena empiezan con mayúscula y el '
          'resto va en minúscula.',
    ],
    [
      'Da dos palabras fijas: Code primero y Arena después.',
      'Da la palabra CodeArena junta en una sola línea.',
      'Da Arena primero y Code después.',
      'Lee dos palabras y las devuelve.',
    ],
  ),
  'w1l3': ProblemText(
    'En la arena vive un loro que repite todo lo que escucha. Le dicen un '
    'número y él dice exactamente el mismo número.\n'
    'En el primer ejemplo el loro escucha 7 y responde 7. En el segundo '
    'escucha 42 y responde 42.',
    [
      'El número que escucha el loro ya llega a tu código. No hay que '
          'inventar ningún número nuevo.',
      'Si te sale siempre el mismo número para cualquier entrada, '
          'probablemente estás respondiendo un número fijo en vez del que '
          'llegó.',
    ],
    [
      'Devuelve el mismo número que recibe.',
      'Devuelve el número siguiente al que recibe.',
      'Devuelve siempre 7.',
      'Devuelve el doble del número que recibe.',
    ],
  ),
  'w1l4': ProblemText(
    'Dos gatos juntan sus croquetas para la cena. El primero tiene a '
    'croquetas y el segundo tiene b. ¿Cuántas croquetas hay en total?\n'
    'En el primer ejemplo un gato tiene 3 y el otro 4: juntos tienen 7. '
    'En el segundo tienen 10 y 25, y juntos llegan a 35.',
    [
      'Pensá qué cuenta hacés vos con lápiz y papel cuando dos amigos '
          'juntan sus croquetas en un mismo plato.',
      'Probá el ejemplo a mano: con 3 y 4 tiene que salir 7. Si te sale '
          '12 o -1, usaste otra operación.',
    ],
    [
      'Junta las croquetas de los dos gatos y da el total.',
      'Da cuántas croquetas más tiene uno que el otro.',
      'Da las croquetas del primer gato nada más.',
      'Multiplica las croquetas de los dos gatos.',
    ],
  ),
  'w1l5': ProblemText(
    'La poción del michi se prepara con dos ingredientes. Su poder es el '
    'producto de los dos valores.\n'
    'En el primer ejemplo los ingredientes valen 6 y 7, y el poder es '
    '42. En el segundo valen 12 y 3, y el poder es 36.',
    [
      'En C++ cada operación tiene su símbolo. La multiplicación no se '
          'escribe con una x.',
      'Los números pueden ser grandes, por eso la función usa long long. '
          'No lo cambies por int.',
    ],
    [
      'Multiplica los dos valores y da el resultado.',
      'Suma los dos valores.',
      'Da el mayor de los dos valores.',
      'Da el primer valor repetido dos veces.',
    ],
  ),
  'w1l6': ProblemText(
    'Cada siesta extra le da al gato un nivel más. Te dicen en qué nivel '
    'está ahora y tenés que decir en qué nivel queda después de una '
    'siesta más.\n'
    'En el primer ejemplo está en el nivel 9 y queda en el 10. En el '
    'segundo empieza en 0 y queda en 1.',
    [
      'Una sola siesta sube exactamente un nivel, ni más ni menos.',
      'Probá con el 0 del segundo ejemplo: el resultado no puede quedar '
          'en 0.',
    ],
    [
      'Devuelve el número que recibe más uno.',
      'Devuelve el número que recibe menos uno.',
      'Devuelve siempre 10.',
      'Devuelve el doble del número que recibe.',
    ],
  ),
  'w1l7': ProblemText(
    'El michi tiene a latas de atún para repartir entre b gatos, en partes '
    'iguales y sin abrir ninguna lata. Hay que decir cuántas latas le '
    'tocan a cada gato y cuántas sobran.\n'
    'En el primer ejemplo hay 17 latas y 5 gatos: a cada uno le tocan 3 '
    'y sobran 2. En el segundo hay 10 latas y 2 gatos: a cada uno le '
    'tocan 5 y no sobra ninguna.',
    [
      'Son dos respuestas distintas: lo que le toca a cada gato y lo que '
          'sobra. C++ tiene un símbolo para cada una.',
      'Con 17 latas y 5 gatos, repartir de a 5 entra 3 veces (15 latas). '
          'Lo que queda afuera de esas 15 es lo que sobra.',
    ],
    [
      'Calcula cuántas le tocan a cada gato y cuántas sobran.',
      'Calcula el total de latas y cuántos gatos hay.',
      'Calcula cuántas le tocan a cada gato, con decimales.',
      'Calcula cuántas faltan para que no sobre ninguna.',
    ],
  ),
  'w1l8': ProblemText(
    'El gato entrenó m minutos y quiere contarlo en horas y minutos, como '
    'en un reloj. Primero van las horas completas y después los minutos '
    'que no llegan a formar otra hora.\n'
    'En el primer ejemplo entrenó 130 minutos: son 2 horas y 10 '
    'minutos. En el segundo entrenó 59: todavía no llega a una hora, '
    'así que son 0 horas y 59 minutos.',
    [
      'Una hora tiene 60 minutos. Pensá cuántas veces entra 60 en los '
          'minutos que te dan.',
      'Este problema se parece mucho al de repartir el atún: las horas '
          'son lo que le toca a cada uno y los minutos son lo que sobra.',
    ],
    [
      'Convierte los minutos en horas completas y minutos sobrantes.',
      'Convierte las horas en minutos.',
      'Divide los minutos por 100 para sacar las horas.',
      'Suma 60 a los minutos.',
    ],
  ),
  'w1l9': ProblemText(
    'Dos gatos están sentados en las cajas a y b, y quieren cambiarse de '
    'lugar. Hay que mostrar las cajas después del cambio.\n'
    'En el primer ejemplo los gatos están en 3 y 8, y después del cambio '
    'quedan 8 y 3. En el segundo están en -1 y 5, y quedan 5 y -1.',
    [
      'El orden importa: el que estaba segundo ahora va primero.',
      'Si te sale igual que la entrada, estás devolviendo los valores en '
          'el mismo orden en que llegaron.',
    ],
    [
      'Da los dos números en el orden contrario.',
      'Da los dos números en el mismo orden.',
      'Da la suma de los dos números.',
      'Da solo el número más grande.',
    ],
  ),
  'w1l20': ProblemText(
    'El gato contable recibe dos números y hace tres cuentas de una vez: '
    'cuánto dan juntos, cuánto más tiene el primero que el segundo y '
    'cuánto da uno por el otro.\n'
    'Con 7 y 3 el gato anota 10, 4 y 21. Con 2 y 5 anota 7, -3 y 10. '
    'Fijate que el segundo resultado puede dar negativo.',
    [
      'Cada una de las tres respuestas es una cuenta distinta con los '
          'mismos dos números.',
      'En la resta el orden importa: 2 y 5 tienen que dar -3, no 3.',
    ],
    [
      'Hace tres cuentas con los dos números: suma, resta y multiplicación.',
      'Suma los dos números tres veces.',
      'Hace la suma, la división y el resto.',
      'Multiplica los números y después le suma 3.',
    ],
  ),
  'w1l21': ProblemText(
    'En la manada hay n gatos y cada uno come k croquetas en la cena. El '
    'cocinero quiere saber cuántas croquetas tiene que preparar en '
    'total.\n'
    'En el primer ejemplo hay 3 gatos y cada uno come 4: hacen falta 12 '
    'croquetas. En el segundo hay 10 gatos que comen 2 cada uno: hacen '
    'falta 20.',
    [
      'Imaginá a los 3 gatos en fila, cada uno con su plato de 4. Contá '
          'todas las croquetas de todos los platos.',
      'Hay una operación que es como sumar k muchas veces seguidas.',
    ],
    [
      'Calcula cuántas croquetas comen todos los gatos juntos.',
      'Calcula cuántas croquetas come un solo gato.',
      'Suma la cantidad de gatos y la de croquetas.',
      'Calcula cuántos gatos hay por croqueta.',
    ],
  ),
  'w1l22': ProblemText(
    'El arenero del gato es un rectángulo de largo l y ancho a. El dueño '
    'quiere saber cuánta arena entra (el área) y cuánta cinta necesita '
    'para rodearlo entero (el perímetro).\n'
    'Para un arenero de 3 por 4, entran 12 cuadraditos de arena y la '
    'cinta mide 14. Para uno de 5 por 5, entran 25 cuadraditos y la '
    'cinta mide 20.',
    [
      'El área cuenta cuántos cuadraditos de 1x1 entran adentro. El '
          'perímetro cuenta cuánto mide el borde.',
      'Para el perímetro dibujá el rectángulo y escribí la medida de sus '
          'cuatro lados. ¿Cuántos lados miden l y cuántos miden a?',
    ],
    [
      'Calcula cuánto mide la superficie y cuánto mide el borde.',
      'Calcula el borde y lo da dos veces.',
      'Suma el largo y el ancho, y después los multiplica.',
      'Calcula solo la superficie.',
    ],
  ),
  'w1l23': ProblemText(
    'El gato durmió h horas y m minutos. El veterinario anota la siesta '
    'solo en minutos, así que hay que decir cuántos minutos durmió en '
    'total.\n'
    'En el primer ejemplo durmió 2 horas y 30 minutos, o sea 150 '
    'minutos. En el segundo durmió 0 horas y 45 minutos, o sea 45.',
    [
      'Primero pensá cuántos minutos hay en las horas completas, y '
          'después qué hacés con los minutos que ya venían sueltos.',
      'Revisá con el ejemplo: 2 horas no son 2 minutos ni 120 + 2.',
    ],
    [
      'Pasa las horas a minutos y les suma los minutos sueltos.',
      'Suma las horas y los minutos.',
      'Pasa los minutos a horas.',
      'Multiplica las horas por los minutos.',
    ],
  ),
  'w1l24': ProblemText(
    'Ahora al revés: el gato durmió t minutos y quiere decirlo como en un '
    'reloj, con horas y minutos.\n'
    'En el primer ejemplo durmió 150 minutos, que son 2 horas y 30 '
    'minutos. En el segundo durmió 45 minutos: no llega a una hora, así '
    'que son 0 horas y 45 minutos.',
    [
      'Es lo contrario del problema anterior. Las horas son las veces que '
          'entra 60 completo en t.',
      'Los minutos que quedan son lo que sobra después de sacar esas '
          'horas completas. C++ tiene un símbolo para "lo que sobra".',
    ],
    [
      'Separa los minutos en horas completas y minutos que sobran.',
      'Pasa las horas a minutos.',
      'Divide los minutos por 100.',
      'Da los minutos y las horas al revés.',
    ],
  ),
  'w1l25': ProblemText(
    'El Profe pesó a tres gatitos y quiere anotar un solo número: el peso '
    'promedio. Ese número es cuánto pesaría cada uno si los tres '
    'pesaran lo mismo. En la libreta del Profe no hay decimales, así '
    'que si no da exacto se anota la parte entera.\n'
    'En el primer ejemplo los gatitos pesan 3, 4 y 5, y el promedio es '
    '4. En el segundo pesan 1, 1 y 2: el promedio exacto sería 1,33..., '
    'así que el Profe anota 1.',
    [
      'Imaginá que juntás todo el peso de los tres gatitos y lo repartís '
          'en partes iguales entre ellos. ¿Cuánto le toca a cada uno?',
      'Con números enteros, C++ corta los decimales al dividir: 7 / 3 da '
          '2. Ojo con los paréntesis: el orden de las cuentas cambia el '
          'resultado.',
    ],
    [
      'Calcula el peso promedio de los tres gatitos, sin decimales.',
      'Da el peso del gatito del medio.',
      'Da el peso total de los tres gatitos.',
      'Da el peso del gatito más pesado.',
    ],
  ),
  'w1l10': ProblemText(
    'JEFE: el gato del teclado forja un escudo rectangular de alto h y '
    'ancho w. Para terminarlo necesita dos números: cuánto mide el '
    'borde del escudo (el perímetro) y cuánto metal lleva adentro (el '
    'área).\n'
    'Un escudo de 3 por 5 tiene un borde de 16 y lleva 15 de metal. Uno '
    'de 10 por 10 tiene un borde de 40 y lleva 100.',
    [
      'Dibujá el escudo y anotá la medida de cada uno de sus cuatro '
          'lados. El borde es todo eso junto.',
      'El área es cuántos cuadraditos de 1x1 entran adentro. Revisá '
          'también el orden en que van las dos respuestas.',
    ],
    [
      'Calcula el borde y la superficie del escudo.',
      'Calcula la superficie dos veces.',
      'Suma el alto y el ancho, nada más.',
      'Calcula el borde de un cuadrado de lado h.',
    ],
  ),
  'w2l1': ProblemText(
    'El guardián de la puerta solo deja pasar a los gatos que saben si un '
    'número es par o impar. Los pares se pueden repartir en dos grupos '
    'iguales; los impares no.\n'
    'El 4 es PAR (dos grupos de 2). El 7 es IMPAR: al hacer dos grupos '
    'siempre sobra uno.',
    [
      'Pensá en lo que sobra al repartir el número entre 2. ¿Cuánto sobra '
          'con un par y cuánto con un impar?',
      'Para comparar en C++ se usa == (doble igual). Un solo = guarda un '
          'valor, no compara.',
    ],
    [
      'Dice si el número es par mirando lo que sobra al dividir por 2.',
      'Dice si el número es mayor que 2.',
      'Dice si el número es positivo.',
      'Divide el número por 2 y da el resultado.',
    ],
  ),
  'w2l2': ProblemText(
    'El termómetro del gato marca un número n. Si está por arriba de cero '
    'es POSITIVO, si está por abajo es NEGATIVO y si está justo en cero '
    'es CERO.\n'
    'En los ejemplos, 5 es POSITIVO, -9 es NEGATIVO y 0 es CERO.',
    [
      'Hay tres casos posibles y cada número cae en uno solo. Pensá cómo '
          'preguntar primero por uno, después por otro, y qué queda al '
          'final.',
      'Probá los tres ejemplos a mano, sobre todo el 0: no es positivo ni '
          'negativo.',
    ],
    [
      'Decide si el número es mayor, menor o igual a cero.',
      'Decide si el número es par o impar.',
      'Da el número cambiado de signo.',
      'Solo dice si el número es positivo o no.',
    ],
  ),
  'w2l3': ProblemText(
    'Dos gatos guerreros chocan sus espadas y gana el más fuerte. Te dan '
    'la fuerza de cada uno y tenés que decir la fuerza del ganador. Si '
    'son iguales, cualquiera de los dos sirve.\n'
    'Con 3 y 9 gana el de 9. Con 8 y 2 gana el de 8.',
    [
      'Hay que comparar los dos números y quedarse con uno. Pensá qué '
          'pregunta le harías a los dos gatos.',
      'Revisá que funcione con el más fuerte primero (8 2) y también '
          'segundo (3 9).',
    ],
    [
      'Compara los dos números y da el más grande.',
      'Da siempre el primer número.',
      'Da la suma de los dos números.',
      'Compara los dos números y da el más chico.',
    ],
  ),
  'w2l4': ProblemText(
    'En el gremio de gatos cada uno tiene un rango según su poder p: si '
    'es menos de 20 es C, de 20 a 49 es B, de 50 a 99 es A, y si tiene '
    '100 o más es S.\n'
    'Un gato con 75 de poder es A. Uno con 15 es C. Uno con 120 es S.',
    [
      'Ordená las preguntas: si empezás por el rango más alto, cada '
          'pregunta siguiente ya sabe que el poder no llegaba al anterior.',
      'Probá los bordes: 20 tiene que dar B, 50 tiene que dar A y 100 '
          'tiene que dar S. Una letra va entre comillas simples: \'A\'.',
    ],
    [
      'Elige una letra según en qué tramo está el poder.',
      'Elige la letra según si el poder es par o impar.',
      'Da el poder dividido por 20.',
      'Da siempre la letra S si el poder es positivo.',
    ],
  ),
  'w2l5': ProblemText(
    'En el calendario de la arena algunos años son bisiestos y tienen un '
    'día más. Un año es bisiesto si es múltiplo de 4, pero no si es '
    'múltiplo de 100... salvo que también sea múltiplo de 400.\n'
    '2024 es BISIESTO. 2023 es NORMAL. 1900 es múltiplo de 100 y no de '
    '400, así que es NORMAL. 2000 es múltiplo de 400, así que es '
    'BISIESTO.',
    [
      'Leé la regla con calma y separala en partes: "múltiplo de 4 y no '
          'de 100" es una parte; "múltiplo de 400" es la otra.',
      'En C++, && significa "y también" y || significa "o". Probá los '
          'cuatro ejemplos, sobre todo 1900 y 2000.',
    ],
    [
      'Revisa las reglas de múltiplos de 4, 100 y 400 para decidir.',
      'Dice bisiesto si el año es múltiplo de 4, sin más reglas.',
      'Dice bisiesto si el año es par.',
      'Dice bisiesto si el año es múltiplo de 100.',
    ],
  ),
  'w2l6': ProblemText(
    'Hay tres cofres con a, b y c monedas de oro. El gato pirata se queda '
    'con el cofre que tiene más y quiere saber cuántas monedas tiene '
    'ese cofre.\n'
    'Con 3, 9 y 5, el cofre más lleno tiene 9. Con 7, 7 y 7 todos '
    'tienen lo mismo, así que la respuesta es 7.',
    [
      'Mirá los cofres de a uno, como un pirata: recordá el mejor que '
          'viste hasta ahora y cambialo si aparece uno mejor.',
      'Probá también con el más grande en la primera o en la última '
          'posición, no solo en el medio.',
    ],
    [
      'Compara los tres números y da el más grande.',
      'Da el número del medio.',
      'Suma los tres números.',
      'Compara solo los dos primeros.',
    ],
  ),
  'w2l7': ProblemText(
    'El michi encontró una calculadora mágica. Le das un número a, un '
    'símbolo op y otro número b, y ella hace la cuenta que indica el '
    'símbolo: +, - o *.\n'
    '5 + 3 da 8. 10 - 4 da 6. 6 * 7 da 42.',
    [
      'Primero hay que averiguar qué símbolo llegó, y según eso elegir la '
          'cuenta.',
      'Un símbolo es un char y se compara con comillas simples: op == '
          '\'+\'.',
    ],
    [
      'Mira el símbolo y hace la cuenta que corresponde.',
      'Siempre suma los dos números.',
      'Hace las tres cuentas y da la más grande.',
      'Da el símbolo que recibió.',
    ],
  ),
  'w2l8': ProblemText(
    'La gatera de la fortaleza solo se abre para gatos con ataque a de al '
    'menos 50 y escudo e de al menos 30. Si cumple las dos cosas, está '
    'LISTO; si le falta alguna, FALTA.\n'
    'Con ataque 60 y escudo 40 está LISTO. Con 60 y 10 FALTA escudo. '
    'Con 50 y 30 justo llega: LISTO.',
    [
      'Las dos condiciones tienen que cumplirse a la vez. Pensá qué '
          'palabra de C++ junta dos condiciones así.',
      'Mirá el tercer ejemplo: 50 y 30 cuentan como suficientes. Revisá '
          'si usaste > o >=.',
    ],
    [
      'Revisa que el ataque y el escudo lleguen los dos al mínimo.',
      'Revisa que al menos uno de los dos llegue al mínimo.',
      'Revisa solo el ataque.',
      'Suma ataque y escudo y revisa si pasa de 80.',
    ],
  ),
  'w2l9': ProblemText(
    'El gato quiere armar una caja triangular con tres palitos de largo a, '
    'b y c. No siempre se puede: si un palito es demasiado largo, los '
    'otros dos no llegan a tocarse en la punta.\n'
    'Con 3, 4 y 5 sí se arma (SI). Con 1, 1 y 10 el palito de 10 es '
    'demasiado largo (NO). Con 5, 5 y 5 sí se arma.',
    [
      'Cada palito tiene que ser más corto que los otros dos juntos. Eso '
          'son tres preguntas, una por palito.',
      'Si los otros dos suman justo lo mismo, quedan acostados en línea '
          'y no es un triángulo. Revisá si usaste > o >=.',
    ],
    [
      'Revisa que cada lado sea más corto que la suma de los otros dos.',
      'Revisa que los tres lados sean distintos.',
      'Revisa que la suma de los tres lados sea par.',
      'Revisa solo que el primer lado sea el más corto.',
    ],
  ),
  'w2l20': ProblemText(
    'Si una caja existe, el gato quiere meterse. El gato mide g y la caja '
    'mide c. Entra si la caja es al menos del tamaño del gato.\n'
    'Un gato de 3 entra en una caja de 5 (SI). Uno de 6 no entra en una '
    'caja de 2 (NO).',
    [
      'Es una sola comparación entre el gato y la caja. Pensá qué pasa si '
          'miden exactamente lo mismo.',
      'Revisá el orden: es el gato el que tiene que caber en la caja, no '
          'al revés.',
    ],
    [
      'Compara el tamaño del gato con el de la caja.',
      'Revisa si la caja es más chica que el gato.',
      'Revisa si los dos tamaños son pares.',
      'Da la diferencia entre la caja y el gato.',
    ],
  ),
  'w2l21': ProblemText(
    'El termómetro de la heladera del atún marca n grados. Hay que decir '
    'si está arriba del cero, abajo o justo en cero.\n'
    '5 grados es POSITIVO. -3 grados es NEGATIVO. Y 0 grados sería '
    'CERO.',
    [
      'Hay tres casos y cada número cae en uno solo. Preguntá por uno, '
          'después por otro, y lo que queda es el tercero.',
      'No te olvides del 0: aunque no está en los ejemplos, el jurado lo '
          'va a probar.',
    ],
    [
      'Decide si el número es mayor, menor o igual a cero.',
      'Decide si el número es par o impar.',
      'Da siempre que es positivo.',
      'Da el número sin el signo.',
    ],
  ),
  'w2l22': ProblemText(
    'Tres gatitos se suben a la balanza: pesan a, b y c. El veterinario '
    'quiere saber cuánto pesa el más liviano.\n'
    'Con 3, 1 y 2 el más liviano pesa 1. Con 5, 5 y 5 pesan todos lo '
    'mismo, así que la respuesta es 5.',
    [
      'Mirá los pesos de a uno y recordá el más liviano que viste hasta '
          'ahora. Cambialo si aparece uno más liviano.',
      'Probá con el más liviano en distintas posiciones: primero, en el '
          'medio y último.',
    ],
    [
      'Compara los tres números y da el más chico.',
      'Compara los tres números y da el más grande.',
      'Da el número del medio.',
      'Da el primer número.',
    ],
  ),
  'w2l23': ProblemText(
    'Los premios de la arena vienen en paquetes de 5. El michi tiene n '
    'premios y quiere saber si los puede armar en paquetes completos '
    'sin que sobre ninguno.\n'
    'Con 10 premios arma 2 paquetes justos (SI). Con 7 arma uno y le '
    'sobran 2 (NO).',
    [
      'La clave es lo que sobra al armar los paquetes. ¿Cuánto tiene que '
          'sobrar para que diga SI?',
      'Ya resolviste uno muy parecido: el de par o impar. Ahí los '
          'paquetes eran de 2.',
    ],
    [
      'Revisa si al repartir de a 5 no sobra nada.',
      'Revisa si el número termina en 5.',
      'Revisa si el número es mayor que 5.',
      'Divide el número por 5 y da el resultado.',
    ],
  ),
  'w2l24': ProblemText(
    'El Profe corrige con letras. Con 90 puntos o más es una A, con 70 o '
    'más es una B, con 50 o más es una C, y si no llega a 50 es una D.\n'
    'Con 95 puntos la nota es A. Con 70 puntos justo, la nota es B.',
    [
      'El orden de las preguntas importa: 95 también es "70 o más". '
          'Pensá por qué conviene empezar por la nota más alta.',
      'Revisá los bordes 90, 70 y 50, y también un puntaje bajito como '
          '10.',
    ],
    [
      'Elige la letra según en qué tramo está el puntaje.',
      'Da A si el puntaje es par y B si es impar.',
      'Da siempre A si el puntaje pasa de 50.',
      'Da el puntaje dividido por 10.',
    ],
  ),
  'w2l25': ProblemText(
    'El gato encontró tres palitos de largos a, b y c y quiere armar un '
    'triángulo. Si un palito es demasiado largo, los otros dos no '
    'alcanzan a cerrarlo.\n'
    'Con 3, 4 y 5 se arma (SI). Con 1, 2 y 3 los dos cortos quedan '
    'acostados sobre el largo y no se forma la punta (NO).',
    [
      'Hay que revisar cada palito contra los otros dos juntos. Son tres '
          'revisiones y tienen que cumplirse todas.',
      'El segundo ejemplo es el truco: 1 + 2 da justo 3 y eso no alcanza.',
    ],
    [
      'Revisa que cada lado sea más corto que la suma de los otros dos.',
      'Revisa que la suma de los tres lados sea mayor que 10.',
      'Revisa que los tres lados sean iguales.',
      'Revisa solo que el lado más largo sea el último.',
    ],
  ),
  'w2l10': ProblemText(
    'JEFE: el gato jefe te reta a piedra, papel o tijeras. Cada jugada es '
    'un número: 0 es piedra, 1 es papel y 2 es tijeras. La piedra le '
    'gana a las tijeras, las tijeras al papel y el papel a la piedra.\n'
    'Si vos sacás piedra (0) y el jefe tijeras (2), GANAS. Si sacás '
    'papel (1) y él tijeras (2), PIERDES. Si los dos sacan tijeras, '
    'EMPATAS.',
    [
      'Empezá por el caso más fácil: ¿cuándo es empate? Después pensá en '
          'cuáles son exactamente las tres maneras de ganar.',
      'Si no es empate y no es ninguna de las tres maneras de ganar, ¿qué '
          'queda? Probá los tres ejemplos a mano.',
    ],
    [
      'Revisa el empate y las tres formas de ganar; lo demás es perder.',
      'Gana el que sacó el número más grande.',
      'Gana siempre el jugador, salvo que empaten.',
      'Gana el que sacó el número más chico.',
    ],
  ),
  'w3l1': ProblemText(
    'El gato cuenta sus croquetas en voz alta, de una en una, empezando '
    'por la 1 hasta llegar a la n.\n'
    'Si tiene 4 croquetas dice 1, 2, 3 y 4. Si tiene 1 sola, dice 1.',
    [
      'Hay que repetir lo mismo muchas veces, cambiando el número cada '
          'vez. Pensá dónde empieza la cuenta y dónde termina.',
      'Revisá los bordes: ¿tu cuenta llega a decir n, o se queda en n-1?',
    ],
    [
      'Cuenta desde 1 hasta n, de uno en uno.',
      'Cuenta desde 0 hasta n-1.',
      'Cuenta desde n hasta 1.',
      'Da solo el número n.',
    ],
  ),
  'w3l2': ProblemText(
    'El portal mágico se abre con una cuenta regresiva: empieza en n y '
    'baja de uno en uno hasta el 1.\n'
    'Con 3 la cuenta es 3, 2, 1. Con 5 es 5, 4, 3, 2, 1.',
    [
      'Es como contar croquetas, pero al revés. Pensá dónde empieza, '
          'dónde termina y hacia dónde se mueve el número.',
      'Revisá que la cuenta termine en 1 y no en 0.',
    ],
    [
      'Cuenta hacia atrás desde n hasta 1.',
      'Cuenta desde 1 hasta n.',
      'Cuenta hacia atrás desde n hasta 0.',
      'Da solo el número 1.',
    ],
  ),
  'w3l3': ProblemText(
    'En la bolsa de premios, el primer día el gato pone 1 premio, el '
    'segundo día 2, el tercero 3... y así hasta el día n. ¿Cuántos '
    'premios hay en la bolsa al final?\n'
    'Después de 5 días hay 1+2+3+4+5 = 15 premios. Después de 10 días '
    'hay 55.',
    [
      'Necesitás una bolsa que empiece vacía y a la que cada día le '
          'agregás algo. ¿Qué le agregás el día i?',
      'Revisá que la bolsa empiece en 0 y que se sumen todos los días, '
          'también el último.',
    ],
    [
      'Suma todos los números desde 1 hasta n.',
      'Da el número n multiplicado por 2.',
      'Suma solo los números pares hasta n.',
      'Cuenta cuántos números hay desde 1 hasta n.',
    ],
  ),
  'w3l4': ProblemText(
    'La alcancía del gato tiene varias monedas, cada una con su valor. El '
    'gato quiere saber cuánta plata tiene en total.\n'
    'En el primer ejemplo hay 4 monedas: 3, 5, 2 y 10, que suman 20. En '
    'el segundo hay 3 monedas de 1, que suman 3.',
    [
      'Recorré las monedas de una en una, como si las sacaras de la '
          'alcancía, y andá anotando cuánto llevás.',
      'La primera moneda está en la posición 0. Revisá que no te salteés '
          'ni la primera ni la última.',
    ],
    [
      'Recorre todas las monedas y suma sus valores.',
      'Cuenta cuántas monedas hay.',
      'Da el valor de la moneda más grande.',
      'Suma solo la primera y la última moneda.',
    ],
  ),
  'w3l5': ProblemText(
    'El gato cazador revisa una fila de ratones con números. Solo le '
    'interesan los que tienen número par. ¿Cuántos ratones pares hay?\n'
    'En la fila 2, 3, 4, 7, 8 hay 3 pares: 2, 4 y 8. En la fila 1, 3, 5 '
    'no hay ninguno: la respuesta es 0.',
    [
      'Hay que mirar cada ratón y decidir si cuenta o no. Necesitás un '
          'contador que empiece en 0.',
      'Ojo: hay que contar cuántos son pares, no sumar sus números.',
    ],
    [
      'Recorre los números y cuenta cuántos son pares.',
      'Suma los números pares.',
      'Cuenta cuántos números hay en total.',
      'Da el número par más grande.',
    ],
  ),
  'w3l6': ProblemText(
    'El gato hace zoomies: en la vuelta 1 corre 1 metro, y en cada vuelta '
    'nueva multiplica lo que corría por el número de esa vuelta. El '
    'factorial de n es 1 × 2 × 3 × ... × n y crece muy rápido.\n'
    'El factorial de 5 es 1×2×3×4×5 = 120. El factorial de 3 es 6.',
    [
      'Es parecido a la bolsa de premios, pero multiplicando en vez de '
          'sumar. Pensá con qué número tiene que empezar la cuenta.',
      'Si la cuenta empieza en 0, todo da 0. Y para 20! hace falta long '
          'long, porque no entra en un int.',
    ],
    [
      'Multiplica todos los números desde 1 hasta n.',
      'Suma todos los números desde 1 hasta n.',
      'Multiplica n por 2, n veces.',
      'Da n multiplicado por n.',
    ],
  ),
  'w3l7': ProblemText(
    'El gato raya la pared con la tabla de multiplicar del n, de n × 1 '
    'hasta n × 10, todo en una misma fila.\n'
    'La tabla del 3 es 3, 6, 9, ..., 30. La del 7 es 7, 14, 21, ..., 70.',
    [
      'Son siempre 10 resultados. Pensá qué cambia de uno al siguiente y '
          'qué queda siempre igual.',
      'Revisá que empiece en n × 1 y termine en n × 10.',
    ],
    [
      'Da los resultados de multiplicar n por 1, 2, ..., 10.',
      'Da los números del 1 al 10.',
      'Suma n diez veces y da solo el total.',
      'Da los resultados de multiplicar n por 0, 1, ..., 9.',
    ],
  ),
  'w3l8': ProblemText(
    'El michi escribe un número y suma sus cifras, una por una.\n'
    'Las cifras de 1234 son 1, 2, 3 y 4, que suman 10. Las de 999 '
    'suman 27.',
    [
      'Hay una cuenta que te da la última cifra de un número, y otra que '
          'la borra. Probalas con 1234 en papel.',
      'Repetí mientras queden cifras. Pensá qué pasa con el número 0.',
    ],
    [
      'Separa las cifras del número y las suma.',
      'Cuenta cuántas cifras tiene el número.',
      'Da la última cifra del número.',
      'Da el número dividido por 10.',
    ],
  ),
  'w3l9': ProblemText(
    'El gato apila gatitos en forma de pirámide: arriba hay 1, en la '
    'segunda fila 2, y así hasta la fila n. Cada gatito se dibuja con '
    'un asterisco.\n'
    'Con 3 filas se dibuja *, después ** y después ***. Con 1 fila es '
    'solo *.',
    [
      'Hay que repetir algo para cada fila, y dentro de cada fila repetir '
          'otra cosa. ¿Cuántos asteriscos lleva la fila i?',
      'No te olvides de saltar de línea al terminar cada fila.',
    ],
    [
      'Dibuja n filas y la fila i tiene i asteriscos.',
      'Dibuja n filas de n asteriscos.',
      'Dibuja una sola fila de n asteriscos.',
      'Dibuja la pirámide al revés, de n a 1.',
    ],
  ),
  'w3l20': ProblemText(
    'Un gatito sube una escalera de n escalones. Cada escalón tiene '
    'pintado su número y el gatito suma los números de todos los '
    'escalones que pisa.\n'
    'Con 5 escalones suma 1+2+3+4+5 = 15. Con 1 escalón suma 1.',
    [
      'Empezá con la cuenta en 0 y en cada escalón agregale su número.',
      'Revisá que el último escalón también se sume.',
    ],
    [
      'Suma todos los números desde 1 hasta n.',
      'Cuenta cuántos escalones hay.',
      'Da el número del último escalón.',
      'Suma solo los escalones pares.',
    ],
  ),
  'w3l21': ProblemText(
    'El gato salta por las baldosas, pero solo pisa las que tienen número '
    'par, desde la 2 hasta la n.\n'
    'Con 7 baldosas pisa la 2, la 4 y la 6. Con 2 baldosas pisa solo la '
    '2.',
    [
      'Pensá en qué baldosa empieza y de a cuánto salta cada vez.',
      'Revisá el final: si n es impar, la última baldosa par es n - 1.',
    ],
    [
      'Da los números pares desde 2 hasta n.',
      'Da todos los números desde 1 hasta n.',
      'Da los números impares hasta n.',
      'Cuenta cuántos pares hay hasta n.',
    ],
  ),
  'w3l22': ProblemText(
    'El michi tiene n croquetas y quiere repartirlas en partes iguales '
    'entre sus amigos, sin que sobre ninguna. ¿De cuántas maneras '
    'distintas se puede elegir la cantidad de amigos?\n'
    'Con 6 croquetas se puede repartir entre 1, 2, 3 o 6 amigos: son 4 '
    'maneras. Con 7 croquetas solo entre 1 o 7: son 2 maneras.',
    [
      'Para cada cantidad posible de amigos, preguntate si al repartir '
          'sobran croquetas. Las cantidades van de 1 a n.',
      'Hay que contar cuántas veces no sobra nada. Revisá con 6 que te '
          'den 4.',
    ],
    [
      'Cuenta cuántos números dividen a n sin que sobre nada.',
      'Suma todos los números que dividen a n.',
      'Da el divisor más grande de n, sin contar n.',
      'Dice si n es par o impar.',
    ],
  ),
  'w3l23': ProblemText(
    'El primer día el gato tiene 1 juguete, y cada día que pasa la '
    'cantidad se duplica. ¿Cuántos juguetes tiene después de n días?\n'
    'Después de 3 días tiene 1 → 2 → 4 → 8, o sea 8 juguetes. Después '
    'de 0 días sigue con 1.',
    [
      'Empezá con 1 juguete y repetí lo que pasa cada día, n veces.',
      'Si te sale 0 o 2·n, revisá con qué empezás y qué hacés cada día.',
    ],
    [
      'Empieza en 1 y lo duplica n veces.',
      'Multiplica n por 2.',
      'Suma 2 n veces.',
      'Multiplica n por sí mismo.',
    ],
  ),
  'w3l24': ProblemText(
    'El gato se mira en el espejo y su número aparece con las cifras al '
    'revés.\n'
    'El 123 en el espejo es 321. El 5 sigue siendo 5.',
    [
      'Ya sabés sacar la última cifra de un número y borrarla. Pensá cómo '
          'ir armando el número nuevo con esas cifras.',
      'Cada cifra nueva que agregás empuja a las anteriores un lugar a la '
          'izquierda. ¿Qué cuenta hace eso?',
    ],
    [
      'Da el número con las cifras en el orden contrario.',
      'Suma las cifras del número.',
      'Da la última cifra del número.',
      'Da el número cambiado de signo.',
    ],
  ),
  'w3l25': ProblemText(
    'El gato dibuja una escalera con estrellas: el primer escalón tiene '
    '1, el segundo 2 y así hasta el escalón n.\n'
    'Con 3 escalones dibuja *, después ** y después ***. Con 1 escalón '
    'dibuja solo *.',
    [
      'Hay que repetir algo para cada escalón y, adentro, repetir otra '
          'cosa. ¿Cuántas estrellas lleva el escalón i?',
      'Al terminar cada escalón hay que saltar de línea.',
    ],
    [
      'Dibuja n filas y la fila i tiene i estrellas.',
      'Dibuja n filas de n estrellas.',
      'Dibuja una sola fila de n estrellas.',
      'Dibuja la escalera al revés, de n a 1.',
    ],
  ),
  'w3l10': ProblemText(
    'JEFE: el juego favorito de los jueces. Los gatos cuentan del 1 al n, '
    'pero en vez de algunos números gritan palabras: si el número es '
    'múltiplo de 3 dicen FIZZ, si es múltiplo de 5 dicen BUZZ, y si es '
    'múltiplo de los dos dicen FIZZBUZZ. Los demás números se dicen '
    'normales.\n'
    'Hasta 5 se dice 1, 2, FIZZ, 4, BUZZ. El 15 es múltiplo de 3 y de '
    '5, así que se dice FIZZBUZZ.',
    [
      'Recorré los números del 1 al n y decidí qué decir para cada uno. '
          'Hay cuatro casos posibles.',
      'El orden de las preguntas es la trampa: el 15 también es múltiplo '
          'de 3. ¿Qué caso conviene revisar primero?',
    ],
    [
      'Cuenta del 1 al n y cambia los múltiplos de 3 y 5 por palabras.',
      'Cuenta del 1 al n y solo dice FIZZ en los pares.',
      'Dice FIZZBUZZ para todos los números.',
      'Cuenta solo los múltiplos de 3 y de 5.',
    ],
  ),
};
