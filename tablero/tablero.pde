import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

    //Variables

//Fuente
PFont font;
//Fichas
int ficha_azul_x;
int ficha_azul_y;
int ficha_roja_x;
int ficha_roja_y;
int ficha_verde_x;
int ficha_verde_y;
int ficha_amarilla_x;
int ficha_amarilla_y;
int ficha_radius;

//Movimiento fichas
int inc_x_azul;
int inc_y_azul;
int inc_x_roja;
int inc_y_roja;
int inc_x_verde;
int inc_y_verde;
int inc_x_amarilla;
int inc_y_amarilla;

//Tiempo
int time_now;
int time_old;
int time_delta;
int cuenta;
boolean start;

//Menú
float bx1;
float by1;
float bx2;
float by2;
int tamanoCaja = 100;
boolean hover = false;
boolean bloqueado = false;

//Turnos
boolean turno = false;
boolean empieza = false;

//Momentos del juego
boolean menu = false;
boolean animacion = true;
boolean fin = false;
boolean nadie = false;

//Posibles finales
boolean ganadorrojo = false;
boolean ganadorazul = false;
boolean empate = false;

//Contador victorias
int victoriaRojos;
int victoriaAzules;

//Cronómetro fin del juego
int timer = 0;

//Tablero
boolean jugar = false;
int columnas = 7;
int filas = 6;
int [][] tablero = new int [columnas][filas];
// la columna extra la usaremos cuando no queramos poner ficha porque hemos hecho click fuera
int [] fichaactual = new int [columnas+1];
int numeroFichas;
int a;
int b;
int linea;
int columnaSeleccionada;
int columna1, columna2, columna3, columna4, columna5, columna6, columna7 = 0;

//Declaramos la variable minim
Minim minim;

//Creamos las clases de la biblioteca Minim para los archivos de audio
AudioPlayer musica_fondo;
AudioSample sonido_ficha;
AudioPlayer sonido_win;
AudioPlayer sonido_empate;

//Función pantalla inicial
void setup() {
  //Instanciamos el objeto minim pasando "this" como argumento
  minim = new Minim (this);
  
  //Cargamos los archivos de audio
  musica_fondo = minim.loadFile("data/Godeatgod.mp3"); //Autor: José Miguel Sáez Teruel
  sonido_ficha = minim.loadSample("data/ficha.mp3"); //Autor: Texaveryjr, Título original: "Stretch and pop".
  sonido_win = minim.loadFile("data/applause.mp3"); //Sample descargado de: "https://www.freesoundeffects.com/free-sounds/applause-10033/"
  sonido_empate = minim.loadFile("data/empate.mp3"); //Autor: José Miguel Sáez Teruel
  
  //Establezco un volumen determinado para cada archivo
  sonido_ficha.setGain (-15);
  sonido_win.setGain (-10);
  sonido_empate.setGain(-10);
  musica_fondo.setGain (-5);
  
  //Hago que la música de fondo se reproduzca de manera continua
  musica_fondo.loop();
  
  size (1280, 720);
  frameRate (60);
  rectMode(CENTER);

  //Posiciones fichas  
  ficha_azul_x = 0;
  ficha_azul_y = 310;

  ficha_roja_x = 590;
  ficha_roja_y = 0;

  ficha_verde_x = 700;
  ficha_verde_y = 720;

  ficha_amarilla_x = 1230;
  ficha_amarilla_y = 310;

  ficha_radius = 100;

  ////Movimiento fichas
  inc_x_azul = 6;
  inc_y_azul = 0;

  inc_x_roja = 0;
  inc_y_roja = 4;

  inc_x_verde = 0;
  inc_y_verde = -5;

  inc_x_amarilla = -5;
  inc_y_amarilla = 0;

  //Tiempo
  time_now = 0;
  time_old = 0;
  time_delta = 0;
  cuenta = 0;
  start = true;
}

//Función dibujar
void draw () {
    
  background (0);

  //Si la animación es verdadera, se carga la función entrada que es la que muestra la animación
  if (animacion == true) {
    entrada();
  }

  //Si menú es verdadero, se muestra el título del juego y el menú para jugar o salir
  if (menu == true) {
    tituloJuego();
    sonido_win.pause(); //Pausamos el sonido de victoria (si se está reproduciendo).
    sonido_win.rewind(); //Reiniciamos el sonido de victoria
    entrada();
    menuJuego();
  }

  //Al clicar sobre jugar, este es true, y cargamos el tablero, quitamos el menú y comprobamos las fichas y contamos las victorias, cada vez que se juega
  if (jugar == true) {
    //quienEmpieza();
    ponerTablero();
    menu = false;
    comprobador();
    victorias();
  }

  //Cuando hemos terminado la partida, fin es true. Según quien gane o si se empata, pondremos un mensaje u otro. Tras 3 segundos, volvemos al menú
  if (fin == true) {

    if (ganadorrojo == true) {
      sonido_win.play(); //Reproducimos el sonido de la victoria
      font = loadFont ("Roboto-BoldItalic-48.vlw");
      textFont(font, 80);
      fill (255, 0, 0);
      text ("Gana el jugador ROJO", 260, 330);
      musica_fondo.pause(); //Pausamos la música de fondo
      musica_fondo.rewind(); //Reiniciamos la música de fondo

    }
    if (ganadorazul == true) {
      sonido_win.play(); //Reproducimos el sonido de la victoria
      font = loadFont ("Roboto-BoldItalic-48.vlw");
      textFont(font, 80);
      fill (0, 0, 255);
      text ("Gana el jugador AZUL", 260, 330);
      musica_fondo.pause(); //Pausamos la música de fondo
      musica_fondo.rewind(); //Reiniciamos la música de fondo
    }
    if (empate == true) {
      sonido_empate.play(); //Reproducimos el sonido de empate
      font = loadFont ("Roboto-BoldItalic-48.vlw");
      textFont(font, 90);
      fill (255, 255, 0);
      text ("¡empate!", 470, 330);
      musica_fondo.pause(); //Pausamos la música de fondo
      musica_fondo.rewind(); //Reiniciamos la música de fondo
    }
    timer++;
    if (timer > 3*60) {
      menu = true;
      fin = false;
      musica_fondo.play(); //Reproducimos la música de fondo siempre que se acabe una partida
    }
  }
}

//Función para comenzar la cuenta
void cuenta() {
  if (start) {
    cuenta = cuenta + time_delta;
  }
}

//Función que resetea el tablero y sus variables, para que cada partida comience desde cero
void reset() {
  for (int i = 0; i <7; i++) {
    fichaactual[i]= 0;
    for (int j = 0; j <6; j++) {
      tablero[i][j] = 0;
    }
  }

  ganadorrojo = false;
  ganadorazul = false;
  empate = false;
  timer = 0;
  numeroFichas = 0;
}

//Función que cambia el color de las fichas y de los recuadros iniciales, dentro de la animación
void cambioColor() {

  background (0, 0, 0);
  noStroke();
  fill (0, 0, 0);
  rect (430, 310, tamanoCaja, tamanoCaja);
  rect (540, 310, tamanoCaja, tamanoCaja);
  rect (650, 310, tamanoCaja, tamanoCaja);
  rect (760, 310, tamanoCaja, tamanoCaja);

  fill (255, 0, 0);
  ellipse (ficha_azul_x, ficha_azul_y, ficha_radius, ficha_radius);  
  ellipse (ficha_roja_x, ficha_roja_y, ficha_radius, ficha_radius); 
  ellipse (ficha_verde_x, ficha_verde_y, ficha_radius, ficha_radius); 
  ellipse (ficha_amarilla_x, ficha_amarilla_y, ficha_radius, ficha_radius);

  //Llamamos a la función para que aparezca el título del juego
  tituloJuego();
}

//Función título del juego
void tituloJuego() {
  
  textSize (80);
  fill (255, 255, 255);

  //Fuente
  font = loadFont ("Roboto-BoldItalic-48.vlw");
  textFont(font, 80);
  text ("4 en Raya", 470, 200);

  //Paramos la animación y cargamos el menú
  animacion = false;
  menu = true;
}

//Función que carga la animación
void entrada() {
  background (0, 0, 0);
  
  //Rectángulos animación
  stroke (255, 217, 0);
  fill (255, 255, 255);
  rect (480, 310, tamanoCaja, tamanoCaja);
  rect (590, 310, tamanoCaja, tamanoCaja);
  rect (700, 310, tamanoCaja, tamanoCaja);
  rect (810, 310, tamanoCaja, tamanoCaja);

  //Colores fichas animación
  fill (0, 0, 255);
  ellipse (ficha_azul_x, ficha_azul_y, ficha_radius, ficha_radius);

  fill (255, 0, 0);
  ellipse (ficha_roja_x, ficha_roja_y, ficha_radius, ficha_radius);

  fill (0, 255, 0);
  ellipse (ficha_verde_x, ficha_verde_y, ficha_radius, ficha_radius);

  fill (255, 255, 0);
  ellipse (ficha_amarilla_x, ficha_amarilla_y, ficha_radius, ficha_radius);

  //Movimiento fichas animación
  ficha_azul_x = ficha_azul_x + inc_x_azul;
  ficha_azul_y = ficha_azul_y + inc_y_azul;

  ficha_roja_x = ficha_roja_x + inc_x_roja;
  ficha_roja_y = ficha_roja_y + inc_y_roja;

  ficha_verde_x = ficha_verde_x + inc_x_verde;
  ficha_verde_y = ficha_verde_y + inc_y_verde;

  ficha_amarilla_x = ficha_amarilla_x + inc_x_amarilla;
  ficha_amarilla_y = ficha_amarilla_y + inc_y_amarilla;

  //Establecemos en qué posición termina la animación de las fichas
  if (ficha_azul_x >= 480) {
    inc_x_azul = 0;
  }

  if (ficha_roja_y >= 310) {
    inc_y_roja = 0;
  }

  if (ficha_verde_y <= 310) {
    inc_y_verde = 0;
  }

  if (ficha_amarilla_x <= 810) {
    inc_x_amarilla = 0;
    cambioColor();
  }

  //Cronómetro
  time_now = millis();
  time_delta = time_now - time_old;
  time_old = time_now;

  //Llamamos a la función cuenta
  cuenta();

  //Posición contenedor de selección
  bx1 = 310;
  by1 = 540;
  bx2 = 970;
  by2 = 540;
}

//Función menú del juego
void menuJuego() {

  strokeWeight (1);
  fill (255, 0, 0);
  rect (bx1, by1, 140, 60);
  fill (0, 0, 255);
  rect (bx2, by2, 140, 60);

  //Cargamos varios tipos de fuente
  font = loadFont ("Roboto-Bold-48.vlw");
  textFont(font, 46);
  fill (255, 255, 0);
  text ("Jugar", 250, 550);
  font = loadFont ("Roboto-Light-48.vlw");
  textFont(font, 46);
  fill (255, 255, 255);
  text ("Salir", 920, 550);

  //Esto lo usé para delimitar áreas de columnas, cajas, etc.
  //text("X"+mouseX, 100, 100);
  //text("Y"+mouseY, 100, 150);

  //Condición para el comportamiento del ratón sobre contenedor 1 (hover)
  if (mouseX > bx1-tamanoCaja && mouseX < bx1+tamanoCaja && 
    mouseY > by1-tamanoCaja && mouseY < by1+tamanoCaja) {

    //Activo hover para que al situar el ratón sobre las cajas, haga un efecto
    hover = true;

    //Si el boolean bloqueado es falso, activo el efecto hover para la caja JUGAR
    if (bloqueado == false) { 
      stroke(255); 
      fill(153);
    }
  } else {
    stroke(153);
    fill(153);
    
    //Desactivo el efecto "hover"
    hover = false;
  }
  //Dibujamos el contenedor 1 (JUGAR)
  noFill();
  rect (bx1, by1, 140, 60);

  //Condición para el comportamiento del ratón sobre contenedor 2 (hover)
  if (mouseX > bx2-tamanoCaja && mouseX < bx2+tamanoCaja && 
    mouseY > by2-tamanoCaja && mouseY < by2+tamanoCaja) {

    //Si el boolean bloqueado es falso, activo el efecto hover para la caja SALIR
    if (bloqueado == false) { 
      stroke(255);
      fill(153);
    }
  } else {
    stroke(153);
    fill(153);

    //Desactivo el efecto "hover"
    hover = false;
  }

  //Dibujamos el contenedor 2 (SALIR)
  noFill();
  rect (bx2, by2, 140, 60);
}

//Función que pone el tablero en la pantalla
void ponerTablero() {

  a = 0;
  b = 0;

  //Hago dos bucles, uno dentro del otro, para recorrer el tablero y le indico el color de cada ficha según la condición
  for (a = 0; a < 7; a++) {
    for (b = 0; b < 6; b++) {

      pushMatrix();
      translate (360, 80);
      stroke (255);
      noFill();
      stroke(255, 206, 0);
      rect (a*100, b*100, 100, 100);

      if (tablero[a][b] == 1) {
        fill (255, 0, 0);
        ellipse (a*100, b*100, 100, 100);
      }
      if (tablero[a][b] == 2) {
        fill(0, 0, 255);
        ellipse (a*100, b*100, 100, 100);
      }
      popMatrix();
    }
  }

  //Escribo el número de victorias acumuladas de cada jugador al lado del tablero
  font = loadFont ("Roboto-BoldItalic-48.vlw");
  textFont(font, 50);
  fill (0, 0, 255);
  text ("Azul: "+victoriaAzules, 30, 560);
  fill (255, 0, 0);
  text ("Rojo: "+victoriaRojos, 30, 500);
}

/*void quienEmpieza() {
 if (empieza == false) {
 fill (0, 0, 255);
 text ("Empieza el jugador azul", 100, 100);
 }
 if (empieza == true) {
 fill (255, 0, 0);
 text ("Empieza el jugador rojo", 100, 100);
 }
 }*/

//Creo condiciones para que se tiren fichas siempre dentro del tablero y cambio el turno después de cada ficha tirada
void tirarFicha() {
  if (columnaSeleccionada != 7) {
    if (fichaactual[columnaSeleccionada] < 7) {

      if (turno == true) {
        tablero[columnaSeleccionada][6-fichaactual[columnaSeleccionada]]=1;
        numeroFichas++;
      }
      if (turno == false) {
        tablero[columnaSeleccionada][6-fichaactual[columnaSeleccionada]]=2;
        numeroFichas++;
      }
    }
    turno = !turno;
  }
}

//Función que indica el área de cada columna para saber donde colocar la dicha con cada click de ratón. Cada vez que se tira una ficha, se suma en la columna seleccionada
void mouseClicked() {
  
  if (jugar == true) {
    if (mouseX < 312 && mouseY >= 34 && mouseY <= 633) {
      columnaSeleccionada = 7;
      sonido_ficha.trigger();
    }
    if (mouseX >= 312 && mouseY >= 34 && mouseX <= 410 && mouseY <= 633) {
      columna1++;
      columnaSeleccionada = 0;
      sonido_ficha.trigger();
      //text ("columna 1 = "+columna1, 100, 40);
    } else if
      (mouseX >= 412 && mouseY >= 34 && mouseX <= 510 && mouseY <= 633) {
      columna2++;
      //text ("columna 2 = "+columna2, 100, 40);
      columnaSeleccionada = 1;
      sonido_ficha.trigger();
    } else if
      (mouseX >= 512 && mouseY >= 34 && mouseX <= 610 && mouseY <= 633) {
      columna3++;
      //text ("columna 3 = "+columna3, 30, 40);
      columnaSeleccionada = 2;
      sonido_ficha.trigger();
    } else if
      (mouseX >= 612 && mouseY >= 34 && mouseX <= 710 && mouseY <= 633) {
      columna4++;
      //text ("columna 4 = "+columna4, 30, 40);
      columnaSeleccionada = 3;
      sonido_ficha.trigger();
    } else if
      (mouseX >= 712 && mouseY >= 34 && mouseX <= 810 && mouseY <= 633) {
      columna5++;
      //text ("columna 5 = "+columna5, 30, 40);
      columnaSeleccionada = 4;
      sonido_ficha.trigger();
    } else if
      (mouseX >= 812 && mouseY >= 34 && mouseX <= 910 && mouseY <= 633) {
      columna6++;
      //text ("columna 6 = "+columna6, 30, 40);
      columnaSeleccionada = 5;
      sonido_ficha.trigger();
    } else if
      (mouseX >= 912 && mouseY >= 34 && mouseX <= 1010 && mouseY <= 633) {
      columna7++;
      //text ("columna 7 = "+columna7, 30, 40);
      columnaSeleccionada = 6;
      sonido_ficha.trigger();
    } else if
      (mouseY >= 34 && mouseX >= 1010 && mouseY <= 633) {
      columnaSeleccionada = 7;
      sonido_ficha.trigger();
    }

    //text ("numero fichas" +numeroFichas, 300, 300);
    
    //Incremento la ficha actual y llamo a la función ficha de nuevo
    fichaactual[columnaSeleccionada]++;
    tirarFicha();
  } 

  if (menu == true) {

    //Condición para que, según en qué caja cliquemos, empiece el juego o se salga del programa
    if (mouseX >= 900 && mouseY >= 514 && mouseX <= 1042 && mouseY <= 572) {
      exit();
    }
    if (mouseX >= 242 && mouseY >= 514 && mouseX <= 380 && mouseY <= 570) {
      reset();
      jugar = true;
    }
  }

  //Condición para que se produzca el empate
  if (numeroFichas == 42) {
    jugar = false;
    fin = true;
    empate = true;
  }
}

//Función que indica a las teclas del teclado que hagan la misma función que los clicks de ratón
void keyPressed() {
  mouseClicked();
}

//Función que comprueba, en el tablero, de qué manera se ha ganado
void comprobador() {
  
  //Comprobamos filas y columnas para cada opción posible de victoria
  for (int i = 0; i < columnas; i++) {
    for (int j = 0; j < filas-3; j++) {
      if (tablero[i][j] == 1 && tablero[i][j+1] == 1 && tablero[i][j+2]==1 && tablero[i][j+3]==1) {
        print ("gana rojo vertical");
        jugar = false;
        fin = true;
        ganadorrojo = true;
      }
    }
  }
  for (int i = 0; i < columnas-3; i++) {
    for (int j = 0; j < filas; j++) {
      if (tablero[i][j] == 1 && tablero[i+1][j] == 1 && tablero[i+2][j]==1 && tablero[i+3][j]==1) {
        print ("gana rojo horizontal");
        jugar = false;
        fin = true;
        ganadorrojo = true;
      }
    }
  }
  for (int i = 0; i < columnas-4; i++) {
    for (int j = 0; j < filas-3; j++) {
      if (tablero[i][j] == 1 && tablero[i+1][j+1] == 1 && tablero[i+2][j+2]==1 && tablero[i+3][j+3]==1) {
        print ("gana rojo diagonal abajo");
        jugar = false;
        fin = true;
        ganadorrojo = true;
      }
    }
  }
  for (int i = 0; i < columnas-4; i++) {
    for (int j = 3; j < filas; j++) {
      if (tablero[i][j] == 1 && tablero[i+1][j-1] == 1 && tablero[i+2][j-2]==1 && tablero[i+3][j-3]==1) {
        print ("gana rojo diagonal arriba");
        jugar = false;
        fin = true;
        ganadorrojo = true;
      }
    }
  }
  for (int i = 0; i < columnas; i++) {
    for (int j = 0; j < filas-3; j++) {
      if (tablero[i][j] == 2 && tablero[i][j+1] == 2 && tablero[i][j+2]==2 && tablero[i][j+3]==2) {
        jugar = false;
        fin = true;
        ganadorazul = true;
        print ("gana azul vertical");
      }
    }
  }
  for (int i = 0; i < columnas-3; i++) {
    for (int j = 0; j < filas; j++) {
      if (tablero[i][j] == 2 && tablero[i+1][j] == 2 && tablero[i+2][j]==2 && tablero[i+3][j]==2) {
        print ("gana azul horizontal");
        jugar = false;
        fin = true;
        ganadorazul = true;
      }
    }
  }
  for (int i = 0; i < columnas-4; i++) {
    for (int j = 0; j < filas-3; j++) {
      if (tablero[i][j] == 2 && tablero[i+1][j+1] == 2 && tablero[i+2][j+2]==2 && tablero[i+3][j+3]==2) {
        print ("gana azul diagonal abajo");
        jugar = false;
        fin = true;
        ganadorazul = true;
      }
    }
  }
  for (int i = 0; i < columnas-4; i++) {
    for (int j = 3; j < filas; j++) {
      if (tablero[i][j] == 2 && tablero[i+1][j-1] == 2 && tablero[i+2][j-2]==2 && tablero[i+3][j-3]==2) {
        print ("gana azul diagonal arriba");
        jugar = false;
        fin = true;
        ganadorazul = true;
      }
    }
  }
}

//Función que cuenta las victorias de los dos jugadores mediante condiciones
void victorias() {

  if (ganadorrojo == true) {
    victoriaRojos++;
  }

  if (ganadorazul == true) {
    victoriaAzules++;
  }
}
