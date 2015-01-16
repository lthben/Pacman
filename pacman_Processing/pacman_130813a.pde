/******************************************************************* 
 * Date : 13 Aug - 13 Sep 2013
 *        
 * Author: Benjamin Low (Lthben@gmail.com)
 *
 * Game mechanics:
 * http://home.comcast.net/~jpittman2/pacman/pacmandossier.html#Table Of Contents
 *
 * Design reference:
 * http://www.google.com/doodles/30th-anniversary-of-pac-man
 *
 * Note:
 * Make sure Serial port number is set correctly!
 * Java 7 is installed
 * Processing libraries are installed
 ********************************************************************/

import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import processing.serial.*;


Maze maze;
MazeEditor mazeEditor;
Data data;
MainMenu mainMenu;
Game game;

Serial myPort;

int displayW, displayH;
PImage backgroundImage, bonusImage, energizerImage;

PFont myFont;

Minim minim;
Sound mySound;
Screen myScreen;

boolean isKeyInputAllowed, isGhostKeyInputAllowed; //during game screen freezes (e.g. round starting) to prevent players from moving the characters 


void setup() {

        size(600, 300);     
        frameRate(15);  
        cp = new ControlP5(this);

        data = new Data();
        mainMenu = new MainMenu();
        maze = new Maze(); //instantiate here to make xNumTiles and yNumTiles available for updating via the editor
        game = new Game();

        minim = new Minim(this);
        mySound = new Sound();

        myFont = loadFont("Optimus-32.vlw");
        textFont(myFont, 32);

        backgroundImage = loadImage("grid.png");
        bonusImage = loadImage("maxusBonus.png");
        energizerImage = loadImage("energizer.png");

        mainMenu.isMazeGenerated = false;

        displayW = displayWidth; 
        displayH = displayHeight; //have to initialise after size() declaration

        testing(); // test-run the game immediately without using the maze editor

        isKeyInputAllowed = true;

        println(Serial.list());
        //        myPort = new Serial(this, Serial.list()[0], 9600);
        myPort = new Serial(this, "/dev/tty.usbmodem1421", 9600);
        myPort.bufferUntil('\n');
}

void draw() { //shows the Main Menu
        background(0);
}

/** for exporting as application only
 public static void main(String args[]) {
 PApplet.main(new String[] { 
 "pacman_130813a"
 }
 );
 }
 */

/** for using the Arduino buttons. Need to comment out keyPressed and keyReleased code in Game tab if using buttons.
 void serialEvent(Serial myPort) {
 String inString = myPort.readStringUntil('\n');
 
 //        println("serial event");
 
 if (inString != null) {
 inString = trim(inString);
 int[] pinValues = int(split(inString, ","));
 
 if (pinValues.length >= 8) {
 
 if (isKeyInputAllowed == true) {
 
 if (pinValues[0] == 1) {
 gf.isGhostUp = true;
 } 
 else gf.isGhostUp = false;
 
 if (pinValues[1] == 1) {
 gf.isGhostDown = true;
 } 
 else gf.isGhostDown = false;
 
 if (pinValues[2] == 1) {
 gf.isGhostLeft = true;
 } 
 else gf.isGhostLeft = false;
 
 if (pinValues[3] == 1) {
 gf.isGhostRight = true;
 } 
 else gf.isGhostRight = false;
 
 if (pinValues[4] == 1) {
 gf.isPacmanUp = true;
 } 
 else gf.isPacmanUp = false;
 
 if (pinValues[5] == 1) {
 gf.isPacmanDown = true;
 } 
 else gf.isPacmanDown = false;
 
 if (pinValues[6] == 1) {
 gf.isPacmanLeft = true;
 } 
 else gf.isPacmanLeft = false;
 
 if (pinValues[7] == 1) {
 gf.isPacmanRight = true;
 } 
 else gf.isPacmanRight = false;
 
 if (pinValues[8] == 1) {
 
 println("coin inserted");
 
 mySound.trigger_insert_coin_sound();
 
 gf.timeCoinStart = millis();
 
 gf.isCoinInserted = true;
 } 
 else {
 //gf.isCoinInserted = false;
 }
 
 //                                println(pinValues);
 } 
 else {
 gf.isGhostUp = gf.isGhostDown = gf.isGhostLeft = gf.isGhostRight = false;
 gf.isPacmanUp = gf.isPacmanDown = gf.isPacmanLeft = gf.isPacmanRight = false;
 }
 }
 }
 }
 */


