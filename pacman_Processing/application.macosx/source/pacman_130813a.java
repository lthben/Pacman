import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.Frame; 
import java.awt.BorderLayout; 
import controlP5.*; 
import processing.serial.*; 
import ddf.minim.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pacman_130813a extends PApplet {

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

boolean isKeyInputAllowed; //during game screen freezes (e.g. round starting) to prevent players from moving the characters 


public void setup() {

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

public void draw() { //shows the Main Menu
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


public void serialEvent(Serial myPort) {
        String inString = myPort.readStringUntil('\n');

        //        println("serial event");

        if (inString != null) {
                inString = trim(inString);
                int[] pinValues = PApplet.parseInt(split(inString, ","));

                if (pinValues.length >= 8) {

                        if (isKeyInputAllowed == true) {

                                if (pinValues[0] == 1) {
                                        gf.isGhostUp = true;
                                } else gf.isGhostUp = false;

                                if (pinValues[1] == 1) {
                                        gf.isGhostDown = true;
                                } else gf.isGhostDown = false;

                                if (pinValues[2] == 1) {
                                        gf.isGhostLeft = true;
                                } else gf.isGhostLeft = false;

                                if (pinValues[3] == 1) {
                                        gf.isGhostRight = true;
                                } else gf.isGhostRight = false;

                                if (pinValues[4] == 1) {
                                        gf.isPacmanUp = true;
                                } else gf.isPacmanUp = false;

                                if (pinValues[5] == 1) {
                                        gf.isPacmanDown = true;
                                } else gf.isPacmanDown = false;

                                if (pinValues[6] == 1) {
                                        gf.isPacmanLeft = true;
                                } else gf.isPacmanLeft = false;

                                if (pinValues[7] == 1) {
                                        gf.isPacmanRight = true;
                                } else gf.isPacmanRight = false;

                                if (pinValues[8] == 1) {

                                        println("coin inserted");

                                        mySound.trigger_insert_coin_sound();

                                        gf.timeCoinStart = millis();

                                        gf.isCoinInserted = true;
                                } else {
                                        //gf.isCoinInserted = false;
                                }

                                //                                println(pinValues);
                        } else {
                                gf.isGhostUp = gf.isGhostDown = gf.isGhostLeft = gf.isGhostRight = false;
                                gf.isPacmanUp = gf.isPacmanDown = gf.isPacmanLeft = gf.isPacmanRight = false;
                        }
                }
        }
}



class Data {

        String line;
        PrintWriter output;
        BufferedReader reader;

        Data () {
        }

        public void write_to_file() {
                output = createWriter(maze.saveFileName);

                output.println(maze.xNumTiles);
                output.println(maze.yNumTiles);

                for (int j = 0; j < maze.yNumTiles; j++) {
                        for (int i = 0; i < maze.xNumTiles; i++) {
                                int tileID = maze.convertToTileID(i, j);
                                output.println(tileID + " " + maze.isActiveTiles[i][j] + " " + maze.hasEnergizer[i][j] + 
                                        " " + maze.hasDot[i][j] + " " + maze.isTunnelTile[i][j] + " " + maze.isPacmanStartTile[i][j] +
                                        " " + maze.isGhostStartTile[i][j] + " " + maze.isBonusTile[i][j]);
                        }
                }
                output.flush();
                output.close();
        }

        public void read_from_file(String fileName) {
                reader = createReader(fileName);

                catch_exception();
                game.xNumTiles = PApplet.parseInt(line);
                catch_exception();
                game.yNumTiles = PApplet.parseInt(line);
                
                game.init();

                for (int k = 0; k < game.xNumTiles * game.yNumTiles; k++) {
                        catch_exception();
                        read_one_tile();
                }
        }
        
        public void read_from_file() {
                reader = createReader(game.loadFileName);

                catch_exception();
                game.xNumTiles = PApplet.parseInt(line);
                catch_exception();
                game.yNumTiles = PApplet.parseInt(line);
                
                game.init();

                for (int k = 0; k < game.xNumTiles * game.yNumTiles; k++) {
                        catch_exception();
                        read_one_tile();
                }
        }

        public void catch_exception() {
                try {
                        line = reader.readLine();
                }
                catch (IOException e) {
                        e.printStackTrace();
                        line = null;
                }
        }

        public void read_one_tile() {
                if (line == null) {
                } else {

                        String[] pieces = split(line, ' ');
                        int j = PApplet.parseInt(pieces[0]) / game.xNumTiles;
                        int i = PApplet.parseInt(pieces[0]) % game.xNumTiles;

                        game.isActiveTiles[i][j] = PApplet.parseBoolean(pieces[1]);
                        game.hasEnergizer[i][j] = PApplet.parseBoolean(pieces[2]);
                        game.hasDot[i][j] = PApplet.parseBoolean(pieces[3]);
                        game.isTunnelTile[i][j] = PApplet.parseBoolean(pieces[4]);
                        game.isPacmanStartTile[i][j] = PApplet.parseBoolean(pieces[5]);
                        game.isGhostStartTile[i][j] = PApplet.parseBoolean(pieces[6]);
                        game.isBonusTile[i][j] = PApplet.parseBoolean(pieces[7]);
                }
        }
}

GameFrame gf;

class Game { //class for game screen

        String loadFileName;

        boolean[][] isActiveTiles, hasEnergizer, hasDot, isTunnelTile, isPacmanStartTile, isGhostStartTile, isBonusTile;  

        int xNumTiles, yNumTiles;
        int tileSize;

        Game() {
        }

        public void init() {
                isActiveTiles = new boolean[xNumTiles][yNumTiles];
                hasEnergizer = new boolean[xNumTiles][yNumTiles];
                hasDot = new boolean[xNumTiles][yNumTiles];
                isTunnelTile = new boolean[xNumTiles][yNumTiles];
                isPacmanStartTile = new boolean[xNumTiles][yNumTiles];
                isGhostStartTile = new boolean[xNumTiles][yNumTiles];
                isBonusTile = new boolean[xNumTiles][yNumTiles];

                setTileSize();
        }

        public void setTileSize() {
                if (xNumTiles > yNumTiles) tileSize = PApplet.parseInt ( 0.8f * displayW / xNumTiles );
                if (yNumTiles >= xNumTiles ) tileSize = PApplet.parseInt ( 0.8f * displayH / yNumTiles );

                //                println("displayW: " + displayW);
        }

        public void run() {
                //create a new window for the GUI. Size includes the border.
                //                gf = addGameFrame("Pacman", tileSize*xNumTiles + 1, tileSize*yNumTiles + 23); 
                gf = addGameFrame("Pacman", displayW, displayH);
        }
}

public GameFrame addGameFrame(String theName, int theWidth, int theHeight) {
        Frame f = new Frame(theName);
        GameFrame p = new GameFrame(this, theWidth, theHeight);
        f.add(p);
        p.init();
        f.setTitle(theName);
        f.setSize(p.w, p.h);
        f.setLocation(0, 0);
        f.setResizable(false);
        f.setUndecorated(true);
        f.setVisible(true);
        return p;
}

//in-game characters
Pacman pacman; 
Ghost ghost;

//out-of-game characters
Pacman pacmax; 
Ghost blinky; 

Score score;

public class GameFrame extends PApplet {
        int w, h;
        int tileSize = game.tileSize;
        int xNumTiles = game.xNumTiles;
        int yNumTiles = game.yNumTiles;

        Object parent;

        boolean isPacmanUp, isPacmanDown, isPacmanLeft, isPacmanRight, isGhostUp, isGhostDown, isGhostLeft, isGhostRight;

        long timeNow, timeCoinStart, timeGameStart, timeGameOverStart, timePacmanEaten, timeGhostEaten;

        boolean isCoinInserted;
        boolean isGameStarted;

        boolean hasCheckedPacmanEaten;

        GameFrame(Object theParent, int theWidth, int theHeight) {
                parent = theParent;
                w = theWidth;
                h = theHeight;
        }

        public void setup() {
                size(w, h);
                frameRate(60);

                pacman = new Pacman(this);
                pacmax = new Pacman(this); 

                ghost = new Ghost(this);
                blinky = new Ghost(this);

                pacman.init();
                ghost.init();

                pacmax.init();
                blinky.init();

                backgroundImage.resize(xNumTiles * tileSize, yNumTiles * tileSize);
                bonusImage.resize(tileSize+10, tileSize+10);
                energizerImage.resize(tileSize+10, tileSize+10);

                score = new Score(this);

                myScreen = new Screen(this);
        }

        public void draw() {
                background(0);  

                timeNow = millis();

                check_for_coin_insert();   

                myScreen.run();

                check_for_game_start();

                check_for_round_start();

                check_for_game_over();
        }

        public void initialise_new_game() { // after each game is played

                data.read_from_file("maxus2.txt");

                mySound.initialise();

                pacman.init();
                ghost.init();

                score.initialise();
        }

        public void display_game_screen() { // the main game screen

                        myScreen.screenMode = myScreen.DISPLAY_GAME_SCREEN;

                pushMatrix();

                calc_screen_translation();

                imageMode(CORNER);
                image(backgroundImage, 0, 0);

                // draw_grid();

                draw_game_assets();

                pacman.update(isPacmanUp, isPacmanDown, isPacmanLeft, isPacmanRight);
                ghost.update(isGhostUp, isGhostDown, isGhostLeft, isGhostRight);

                pacman.display();
                ghost.display();

                score.run(pacman.xTile, pacman.yTile, ghost.xTile, ghost.yTile);

                popMatrix();
        }

        public void calc_screen_translation() { //helper function
                if (xNumTiles > yNumTiles) { //cater for maze landscape or vertical orientation, 10% buffer on each longer side of maze
                        translate(displayW / 10, displayH / 2 - yNumTiles * tileSize / 2);
                } else {
                        translate(displayW / 2 - xNumTiles * tileSize / 2, displayH / 10);
                }
        }

        public void draw_grid() { //helper function

                // draw grid
                for (int i = 0; i <= xNumTiles; i++) {
                        stroke(100);
                        line(i * tileSize, 0, i * tileSize, yNumTiles * tileSize);
                }

                for (int j = 0; j <= yNumTiles; j++) {
                        stroke(100);
                        line(0, j * tileSize, xNumTiles * tileSize, j * tileSize);
                }
        }

        public void draw_game_assets() { //helper function
                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                if (game.isActiveTiles[i][j]) {
                                        //                                       fill(0,0);
                                        //                                        rect(i * tileSize, j * tileSize, tileSize, tileSize);
                                }
                                if (game.hasEnergizer[i][j]) {
                                        noStroke();
                                        fill(255, 50);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize + 0.1f*tileSize*sin(frameCount/6), tileSize + 0.1f*tileSize*sin(frameCount/6) ); 
                                        imageMode(CENTER);
                                        image(energizerImage, i * tileSize + tileSize/2, j * tileSize + tileSize/2);
                                }
                                if (game.hasDot[i][j]) {
                                        fill(255, 255, 0);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize/4 + 0.05f*tileSize*sin(frameCount/8), tileSize/4 + 0.05f*tileSize*sin(frameCount/8));
                                }
                                if (game.isTunnelTile[i][j]) {
                                        //                                        fill(255, 100);
                                        //                                        rect(i * tileSize, j * tileSize, tileSize, tileSize);
                                }
                                if (game.isBonusTile[i][j] && score.hasBonusAppeared) {
                                        noStroke();
                                        fill(255, 50);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize*3 + 0.3f*tileSize*sin(frameCount/4), tileSize*3 + 0.3f*tileSize*sin(frameCount/4) ); 

                                        imageMode(CENTER);
                                        image(bonusImage, i * tileSize + tileSize/2, j * tileSize + tileSize/2);
                                }
                        }
                }
        }

        public void check_for_game_start () {

                if (isGameStarted == true) {
                        if ( (timeNow - timeGameStart) / 1000 < 5) { 
                                display_game_start_text();
                        } else { //after opening sequence has played
                                isGameStarted = false;

                                isKeyInputAllowed = true;

                                mySound.play_chase_mode_song();
                        }
                }
        }

        public void check_for_round_start() {
                if (pacman.isEaten == true && pacman.noOfLifes != 0 ) {

                        if ( (timeNow - timePacmanEaten) / 1000 < 2) {

                                //pac_man goes transparent
                                //pacman_death.wav - 2 sec


                                mySound.play_pacman_death_song();


                                fill(150, 100);
                                rect(0, 0, displayW, displayH);
                        } else {
                                pacman.go_to_start_position();
                                ghost.go_to_start_position();

                                pacman.isEaten = false;

                                isKeyInputAllowed = true;

                                pacman.noOfLifes--;

                                mySound.play_chase_mode_song();
                        }
                }
        }

        public void check_for_game_over() {

                if (score.isGameOver == true) {
                        if ( (timeNow - timeGameOverStart) / 1000 < 5) {
                                display_game_over_text();
                        } else {
                                player5.pause(); //cut off the weird trailing sound

                                score.isGameOver = false;

                                isKeyInputAllowed = true;

                                myScreen.screenMode = myScreen.DISPLAY_HIGHSCORE_SCREEN;

                                myScreen.timeStart = millis(); // to enable off-game screen rotation

                                initialise_new_game();
                        }
                }
        }


        public void display_game_start_text() {
                //screen overlay
                //opening_song.wav - 4 sec
                //"get ready"

                fill(150, 100);
                rect(0, 0, displayW, displayH);

                textFont(myFont);
                textAlign(CENTER);
                textSize(displayH/30);
                fill(255);
                text("Get Ready!", displayW/2, displayH/2);

                mySound.play_opening_song();

                isKeyInputAllowed = false;
        }

        public void display_round_start_text() {
                // screen overlay
                // "get ready"
        }

        public void display_game_over_text () {
                //screen overlay
                //game_over.wav - 5 sec
                //announce winner and score

                fill(150, 100);
                rect(0, 0, displayW, displayH);

                textFont(myFont);
                textAlign(CENTER);
                textSize(displayH/20);
                fill(255);
                text("Game Over", displayW/2, 3*displayH/7);

                if (score.winnerName == "Pacmax") {
                        text("Winner is Pacmax! Your score is " + score.score, displayW/2, 4*displayH/7);
                } else {
                        text("Winner is Blinky!", displayW/2, 4*displayH/7);
                }

                mySound.play_game_over_song();

                isKeyInputAllowed = false;
        }

        public void check_for_coin_insert() {

                if (isCoinInserted == true) {

                        if (myScreen.screenMode != myScreen.DISPLAY_GAME_SCREEN) {

                                if ( (timeNow - timeCoinStart) / 1000 == 1 ) {

                                        myScreen.screenMode = myScreen.DISPLAY_GAME_SCREEN;

                                        isCoinInserted = false;

                                        isGameStarted = true;

                                        isKeyInputAllowed = false;

                                        timeGameStart = millis();
                                }
                        }
                }
        }

/*
        void keyPressed() {

                if (isKeyInputAllowed == true) {

                        if (key == CODED) {
                                if (keyCode == UP) isPacmanUp = true; 
                                if (keyCode == DOWN) isPacmanDown = true; 
                                if (keyCode == LEFT) isPacmanLeft = true; 
                                if (keyCode == RIGHT) isPacmanRight = true;
                        }
                        if (key == 'w' || key == 'W') isGhostUp = true;
                        if (key == 's' || key == 'S') isGhostDown = true;
                        if (key == 'a' || key == 'A') isGhostLeft = true;
                        if (key == 'd' || key == 'D') isGhostRight = true;

                        if (key == ' ') {
                                mySound.trigger_insert_coin_sound();

                                timeCoinStart = millis();
                                isCoinInserted = true;
                        }
                } else { 
                        isPacmanUp = isPacmanDown = isPacmanRight = isPacmanLeft = false;
                        isGhostUp = isGhostDown = isGhostRight = isGhostLeft = false;
                }
        }

        void keyReleased() {
                if (key == CODED) {
                        if (keyCode == UP) isPacmanUp = false; 
                        if (keyCode == DOWN) isPacmanDown = false; 
                        if (keyCode == LEFT) isPacmanLeft = false; 
                        if (keyCode == RIGHT) isPacmanRight = false;
                } 
                if (key == 'w' || key == 'W') isGhostUp = false;
                if (key == 's' || key == 'S') isGhostDown = false;
                if (key == 'a' || key == 'A') isGhostLeft = false;
                if (key == 'd' || key == 'D') isGhostRight = false;
        }
        */
}

ControlP5 cp;

class MainMenu {

        boolean isMazeGenerated;

        MainMenu() {
                cp.addTextlabel("welcome_msg").setText("PACMAX by Maxus").setFont(createFont("Optimus", 48)).setPosition(25, 20).setColorValue(0xffFFff00);
                cp.addBang("maze_editor").setPosition(75, 100).setSize(150, 150);
                cp.addBang("load_game").setPosition(375, 100).setSize(150, 150);              
        }    

        public void display() {
        }
}

public void maze_editor() { //when button is pressed
        mazeEditor = new MazeEditor();
        not_testing();
}

public void load_game() {//when button is pressed
        testing();
}

public void testing() {
        data.read_from_file("maxus2.txt");
        game.run();
}

public void not_testing() {
        mainMenu.display();

        if (mainMenu.isMazeGenerated) {
                maze.display();
        }
}

public boolean sketchFullScreen() {
//     return false;
   return true;
}

MazeFrame mf;

class Maze {

        boolean[][] isActiveTiles, hasEnergizer, hasDot, isTunnelTile, isPacmanStartTile, isGhostStartTile, isBonusTile;  

        int xNumTiles, yNumTiles, tileSize;
        
        String saveFileName;

        Maze() {
                xNumTiles = yNumTiles = tileSize = 1;
        }

        public void init() {
                isActiveTiles = new boolean[xNumTiles][yNumTiles];
                hasEnergizer = new boolean[xNumTiles][yNumTiles];
                hasDot = new boolean[xNumTiles][yNumTiles];
                isTunnelTile = new boolean[xNumTiles][yNumTiles];
                isPacmanStartTile = new boolean[xNumTiles][yNumTiles];
                isGhostStartTile = new boolean[xNumTiles][yNumTiles];
                isBonusTile = new boolean[xNumTiles][yNumTiles];

                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                isActiveTiles[i][j] = false;
                                hasEnergizer[i][j] = false;
                                hasDot[i][j] = false;
                                isTunnelTile[i][j] = false;
                                isPacmanStartTile[i][j] = false;
                                isGhostStartTile[i][j] = false;
                                isBonusTile[i][j] = false;
                        }
                }

                setTileSize();

                mf = addMazeFrame("maze", tileSize*xNumTiles + 1, tileSize*yNumTiles + 23); //create a new window for the GUI. Size includes the border.
        }

        public void display() {
        }

        public void setTileSize() {
                if (xNumTiles > yNumTiles) tileSize = PApplet.parseInt ( (0.8f * displayW) / xNumTiles );
                if (yNumTiles >= xNumTiles ) tileSize = PApplet.parseInt ( (0.8f * displayH) / yNumTiles );
        }

        public int getTileID(int xPos, int yPos) {
                int xTile, yTile;
                xTile = xPos / tileSize;
                yTile = yPos / tileSize;

                return convertToTileID(xTile, yTile);
        }

        public int convertToTileID(int xTile, int yTile) {
                return xNumTiles * yTile + xTile;
        }
        

        public void clearMaze() {
                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                isActiveTiles[i][j] = false;
                                hasEnergizer[i][j] = false;
                                hasDot[i][j] = false;
                                isTunnelTile[i][j] = false;
                                isPacmanStartTile[i][j] = false;
                                isBonusTile[i][j] = false;
                                isGhostStartTile[i][j] = false;
                        }
                }
        }
}

public MazeFrame addMazeFrame(String theName, int theWidth, int theHeight) {
        Frame f = new Frame(theName);
        MazeFrame p = new MazeFrame(this, theWidth, theHeight);
        f.add(p);
        p.init();
        f.setTitle(theName);
        f.setSize(p.w, p.h);
        f.setLocation(600, 50);
        f.setResizable(false);
        f.setVisible(true);
        return p;
}

public class MazeFrame extends PApplet {
        int w, h;

        Object parent;
        ControlP5 cp5;

        public void setup() {
                size(w, h);
                frameRate(15);
                cp5 = new ControlP5(this);
        }

        public void draw() {
                background(0);

                // draw grid
                for (int i = 0; i <= maze.xNumTiles; i++) {
                        stroke(100);
                        line(i * maze.tileSize, 0, i * maze.tileSize, maze.yNumTiles * maze.tileSize);
                }

                for (int j = 0; j <= maze.yNumTiles; j++) {
                        stroke(100);
                        line(0, j * maze.tileSize, maze.xNumTiles * maze.tileSize, j * maze.tileSize);
                }

                // draw maze
                for (int i = 0; i < maze.xNumTiles; i++) {
                        for (int j = 0; j < maze.yNumTiles; j++) {
                                if (maze.isActiveTiles[i][j]) {
                                        fill(100);
                                        rect(i * maze.tileSize, j * maze.tileSize, maze.tileSize, maze.tileSize);
                                }
                                if (maze.hasEnergizer[i][j]) {
                                        fill(255); 
                                        noStroke();
                                        ellipse(i * maze.tileSize + maze.tileSize/2, j * maze.tileSize + maze.tileSize/2, maze.tileSize, maze.tileSize);
                                }
                                if (maze.hasDot[i][j]) {
                                        fill(255, 255, 0);
                                        ellipse(i * maze.tileSize + maze.tileSize/2, j * maze.tileSize + maze.tileSize/2, maze.tileSize/4, maze.tileSize/4);
                                }
                                if (maze.isTunnelTile[i][j]) {
                                        fill(255, 0, 180, 100);
                                        rect(i * maze.tileSize, j * maze.tileSize, maze.tileSize, maze.tileSize);
                                }
                                if (maze.isPacmanStartTile[i][j]) {
                                        fill(255, 255, 0);
                                        textSize(maze.tileSize); 
                                        textAlign(CENTER, TOP);
                                        text("P", i * maze.tileSize + maze.tileSize/2, j * maze.tileSize);
                                }
                                if (maze.isGhostStartTile[i][j]) {
                                        fill(105, 0, 255);
                                        textSize(maze.tileSize); 
                                        textAlign(CENTER, TOP);
                                        text("G", i * maze.tileSize + maze.tileSize/2, j * maze.tileSize);
                                }
                                if (maze.isBonusTile[i][j]) {
                                        fill(255, 0, 68);
                                        textSize(maze.tileSize); 
                                        textAlign(CENTER, TOP);
                                        text("B", i * maze.tileSize + maze.tileSize/2, j * maze.tileSize);
                                }
                        }
                }
        }


        private MazeFrame() {
        }

        public MazeFrame(Object theParent, int theWidth, int theHeight) {
                parent = theParent;
                w = theWidth;
                h = theHeight;
        }

        public ControlP5 control() {
                return cp5;
        }

        public void mousePressed(MouseEvent e) {

                int xTile; 
                int yTile;
                xTile = mouseX / maze.tileSize; 
                yTile = mouseY / maze.tileSize;

                if (mainMenu.isMazeGenerated) {
                        switch (mazeEditor.mazeDrawMode) {
                                case(DRAW_ACTIVE_TILE):
                                maze.isActiveTiles[xTile][yTile] = !maze.isActiveTiles[xTile][yTile];
                                break;

                                case(DRAW_ENERGIZER):
                                maze.hasEnergizer[xTile][yTile] = !maze.hasEnergizer[xTile][yTile];
                                break;

                                case(DRAW_DOT):
                                maze.hasDot[xTile][yTile] = !maze.hasDot[xTile][yTile];
                                break;

                                case(DRAW_TUNNEL_TILE):
                                maze.isTunnelTile[xTile][yTile] = !maze.isTunnelTile[xTile][yTile];
                                break;

                                case(DRAW_PACMAN_START_TILE):
                                maze.isPacmanStartTile[xTile][yTile] = !maze.isPacmanStartTile[xTile][yTile];
                                break;

                                case(DRAW_GHOST_START_TILE):
                                maze.isGhostStartTile[xTile][yTile] = !maze.isGhostStartTile[xTile][yTile];
                                break;

                                case(DRAW_BONUS_TILE):
                                maze.isBonusTile[xTile][yTile] = !maze.isBonusTile[xTile][yTile];
                                break;
                        }
                }
        }
}   

static final int DRAW_ACTIVE_TILE = 1;
static final int DRAW_ENERGIZER = 2;
static final int DRAW_DOT = 3;
static final int DRAW_TUNNEL_TILE = 4;
static final int DRAW_PACMAN_START_TILE = 5;
static final int DRAW_GHOST_START_TILE = 6;
static final int DRAW_BONUS_TILE = 7;

EditorFrame ef;

class MazeEditor {

        int mazeDrawMode; 
        boolean isDrawActiveTile, isDrawEnergizer, isDrawDot, isDrawTunnelTile, isDrawPacmanStartTile, isDrawGhostStartTile, isDrawBonusTile;

        MazeEditor() {
                ef = addEditorFrame("maze editor", 450, 800); //create a new window for the GUI

                mazeDrawMode = DRAW_ACTIVE_TILE;
        }
}



public EditorFrame addEditorFrame(String theName, int theWidth, int theHeight) {
        Frame f = new Frame(theName);
        EditorFrame p = new EditorFrame(this, theWidth, theHeight);
        f.add(p);
        p.init();
        f.setTitle(theName);
        f.setSize(p.w, p.h);
        f.setLocation(50, 50);
        f.setResizable(false);
        f.setVisible(true);
        return p;
}

public class EditorFrame extends PApplet {
        int w, h;

        Object parent;
        ControlP5 cp5;

        Toggle Tog1, Tog2, Tog3, Tog4, Tog5, Tog6, Tog7;

        public void setup() {
                size(w, h);
                frameRate(15);
                cp5 = new ControlP5(this); 

                //size of maze
                cp5.addTextlabel("size_of_maze").setText("Size of Maze").setPosition(25, 20).setColorValue(0xffFFff00).setFont(createFont("Georgia", 20));

                cp5.addTextfield("enter_num_of_horizontal_tiles").setPosition(30, 50).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);
                cp5.addTextfield("enter_num_of_vertical_tiles").setPosition(30, 120).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);

                cp5.addBang("generate").setPosition(300, 100).setSize(60, 60);

                //draw modes
                cp5.addTextlabel("draw_modes").setText("Draw Modes").setPosition(25, 270).setColorValue(0xffFFff00).setFont(createFont("Georgia", 20));

                Tog1 = cp5.addToggle("draw_Active_Tile").setSize(50, 50).setPosition(30, 300);
                Tog2 = cp5.addToggle("draw_Energizer").setSize(50, 50).setPosition(130, 300);
                Tog3 = cp5.addToggle("draw_Dot").setSize(50, 50).setPosition(230, 300);
                Tog4 = cp5.addToggle("draw_Tunnel_Tile").setSize(50, 50).setPosition(330, 300);
                Tog5 = cp5.addToggle("draw_Pacman").setSize(50, 50).setPosition(30, 380);
                Tog6 = cp5.addToggle("draw_Ghost").setSize(50, 50).setPosition(130, 380);
                Tog7 = cp5.addToggle("draw_Bonus").setSize(50, 50).setPosition(230, 380);

                cp5.addBang("clear_maze").setPosition(30, 470).setSize(60, 60).setColorForeground(0xffff0000);

                //file IO
                cp5.addTextlabel("file_IO").setText("Save / Load").setPosition(25, 570).setColorValue(0xffFFff00).setFont(createFont("Georgia", 20));

                cp5.addTextfield("enter_save_file_name").setPosition(30, 600).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);
                cp5.addTextfield("enter_load_file_name").setPosition(30, 680).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);

                cp5.addBang("save_to_file").setPosition(300, 600).setSize(40, 40);
                cp5.addBang("load_file").setPosition(300, 680).setSize(40, 40);
        }

        public void draw() {
                background(0);
        }


        private EditorFrame() {
        }

        public EditorFrame(Object theParent, int theWidth, int theHeight) {
                parent = theParent;
                w = theWidth;
                h = theHeight;
        }

        public ControlP5 control() {
                return cp5;
        }

        public void enter_num_of_horizontal_tiles(String theText) {
                if (!mainMenu.isMazeGenerated) {
                        maze.xNumTiles = PApplet.parseInt(theText);
                        println("no. of horizontal tiles: " + maze.xNumTiles);
                }
        }

        public void enter_num_of_vertical_tiles(String theText) {
                if (!mainMenu.isMazeGenerated) {
                        maze.yNumTiles = PApplet.parseInt(theText);
                        println("no. of vertical tiles: " + maze.yNumTiles);
                }
        }

        public void generate() {
                if (maze.xNumTiles!=1 && maze.yNumTiles!=1) {
                        mainMenu.isMazeGenerated = true;
                        maze.init();
                } else {
                        println("please enter the no. of horizontal and vertical tiles");
                }
        }

        //error checking to ensure only one toggle is active at any one time
        public void draw_Active_Tile(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_ACTIVE_TILE;

                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        public void draw_Energizer(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_ENERGIZER;

                        Tog1.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        public void draw_Dot(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_DOT;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog4.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        public void draw_Tunnel_Tile(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_TUNNEL_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        public void draw_Pacman(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_PACMAN_START_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        public void draw_Ghost(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_GHOST_START_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false);
                        Tog5.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        public void draw_Bonus(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_BONUS_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false);
                        Tog5.setState(false);
                        Tog6.setState(false);
                }
        }

        public void clear_maze() {
                maze.clearMaze();
                println("maze cleared");
        }

        public void enter_save_file_name(String theText) {
                maze.saveFileName = theText;
                println("saveFileName: " + theText);
        }

        public void enter_load_file_name(String theText) {
                game.loadFileName = theText;
                println("loadFileName: " + theText);
        }

        public void save_to_file() {
                data.write_to_file();
                println("maze saved to: " + maze.saveFileName);
        }

        public void load_file() {
                data.read_from_file();
                game.run();
                println(game.loadFileName + " loaded");
        }
}   

/*
 270 dots x 20 points = 5,400 points
 6 energizers x 100 points = 600 points
 6 ghosts eaten x  400 points = 2,400 points
 2 bonuses x 800 = 1,600 points
 TOTAL = 10,000 points perfect score
 */

class Score {

        int score;

        PApplet parent;

        int pacman_xTile, pacman_yTile, ghost_xTile, ghost_yTile;

        int xNumTiles, yNumTiles;
        int tileSize;

        int ghostMode; 
        static final int CHASE = 1;
        static final int FRIGHTENED = 2;

        boolean isGhostRecovering;

        int ghostEatenXTile, ghostEatenYTile;
        int bonusXTile, bonusYTile;

        boolean hasGhostModeChanged;

        int timeFrightModeStarted, timeSinceFrightModeStarted;
        int timeBonusAppeared, timeSinceBonusAppeared;

        int noOfBonusesCollected; //a bonus will appear for 9 sec when 70 or 170 dots have been eaten
        boolean hasBonusAppeared;

        //        boolean isGameOver, isRoundStart;

        int dotsEaten, energizersEaten;

        boolean isGameOver;

        String winnerName;

        boolean[][] isDotScoreDisplayed, isEnergizerScoreDisplayed;
        boolean isGhostEatenScoreDisplayed, isBonusScoreDisplayed;

        ScoreText[] scoreTextArray;
        ScoreText ghostScoreText, bonusScoreText;

        PImage pacmanLogoImage, bonusLogoImage;

        Score(PApplet frame) {
                score = 0;
                parent = frame;

                ghostMode = CHASE;
                hasGhostModeChanged = false;

                noOfBonusesCollected = 0;
                hasBonusAppeared = false;

                dotsEaten = energizersEaten = 0;

                tileSize = game.tileSize;
                xNumTiles = game.xNumTiles;
                yNumTiles = game.yNumTiles;

                pacmanLogoImage = loadImage("pacmax.png");
                bonusLogoImage = loadImage("maxusBonus.png");

                isDotScoreDisplayed = new boolean[xNumTiles][yNumTiles];
                isEnergizerScoreDisplayed = new boolean[xNumTiles][yNumTiles]; 
                isGhostEatenScoreDisplayed = isBonusScoreDisplayed = false;

                scoreTextArray = new ScoreText[xNumTiles*yNumTiles]; //for dots and energizers only

                for (int i = 0; i < xNumTiles*yNumTiles; i++) {
                        scoreTextArray[i] = new ScoreText(parent);
                }

                ghostScoreText = new ScoreText(parent);
                bonusScoreText = new ScoreText(parent);
        } 

        public void initialise() {
                score = 0;
                ghostMode = CHASE;

                noOfBonusesCollected = 0;
                hasBonusAppeared = false;

                for (int i=0; i< xNumTiles; i++) {
                        for (int j=0; j<yNumTiles; j++) {
                                isDotScoreDisplayed[i][j] = false;
                                isEnergizerScoreDisplayed[i][j] = false;
                        }
                }

                isGhostEatenScoreDisplayed = isBonusScoreDisplayed = false;

                dotsEaten = energizersEaten = 0;
        }

        public void run(int pacman_xTile_, int pacman_yTile_, int ghost_xTile_, int ghost_yTile_) {

                pacman_xTile = pacman_xTile_;
                pacman_yTile = pacman_yTile_;
                ghost_xTile = ghost_xTile_;
                ghost_yTile = ghost_yTile_;

                display_pacman_assets(); 

                track_fright_mode_time();

                track_bonus_appear_time();

                update_scores();

                display_main_score();

                display_text_scores();

                check_for_game_over();
        }

        public void update_scores() {
                if (game.hasDot[pacman_xTile][pacman_yTile] == true) { //pacman eats dot

                        mySound.trigger_eating_dot_sound();

                        game.hasDot[pacman_xTile][pacman_yTile] = false;

                        isDotScoreDisplayed[pacman_xTile][pacman_yTile] = true;   

                        score += 20;
                        dotsEaten++;

                        if (dotsEaten == 70 || dotsEaten == 170) { //set the dot count here for the bonus to appear
                                hasBonusAppeared = true;
                                timeBonusAppeared = millis();
                        }
                }

                if (game.hasEnergizer[pacman_xTile][pacman_yTile] == true) { //pacman eats energizer

                        mySound.trigger_eating_energizer_sound();

                        game.hasEnergizer[pacman_xTile][pacman_yTile] = false;

                        isEnergizerScoreDisplayed[pacman_xTile][pacman_yTile] = true;

                        energizersEaten++;
                        score += 100;

                        ghostMode = FRIGHTENED;
                        hasGhostModeChanged = true;

                        timeFrightModeStarted = millis();
                }

                if (game.isBonusTile[pacman_xTile][pacman_yTile] == true) { // pacman eats bonus
                        if (hasBonusAppeared == true) {

                                mySound.trigger_eating_bonus_sound();

                                hasBonusAppeared = false;
                                isBonusScoreDisplayed = true;

                                bonusXTile = pacman_xTile;
                                bonusYTile = pacman_yTile; 

                                noOfBonusesCollected++;
                                score += 800;
                        }
                }

                if ( (pacman_xTile == ghost_xTile && pacman_yTile == ghost_yTile) || dist(pacman.xPos, pacman.yPos, ghost.xPos, ghost.yPos) < tileSize   ) { //pacman and ghost meet

                        if (ghostMode == CHASE) {
                                
                                isKeyInputAllowed = false;
                                
                                if (pacman.isEaten == false) {
                                        gf.timePacmanEaten = millis();
                                }
                                
                                pacman.isEaten = true;

                        } 
                        else if (ghostMode == FRIGHTENED) {
                                
                                mySound.trigger_eating_ghost_sound();

                                if (ghost.isEaten == false) {
                                        
                                        gf.timeGhostEaten = millis();

                                        isGhostEatenScoreDisplayed = true;

                                        ghostEatenXTile = pacman_xTile;
                                        ghostEatenYTile = pacman_yTile;

                                        score += 400;
                                }

                                ghost.isEaten = true;
                        }
                }
        }

        public void display_main_score() {
                parent.fill(255);
                parent.textFont(myFont);
                parent.textAlign(LEFT, CENTER);
                parent.textSize(tileSize*1.5f);           
                parent.text("score", 0, - displayH/20);

                parent.fill(255, 255, 0);
                parent.textAlign(LEFT, CENTER);
                parent.textSize(tileSize*2); 
                parent.text(score, tileSize*8, - displayH/20);
        }


        public void display_pacman_assets() {

                parent.fill(255);
                parent.textFont(myFont);
                parent.textAlign(RIGHT, CENTER);

                parent.textSize(tileSize*1.5f);
                parent.text("1UP", 48*tileSize, 22*tileSize); 

                for (int i = 0; i < pacman.noOfLifes; i++) {
                        imageMode(CENTER);
                        parent.image(pacmanLogoImage, 52*tileSize + i *3*tileSize, 22*tileSize, 3*tileSize, 1.5f*tileSize);
                }

                parent.fill(255);
                parent.textFont(myFont);
                parent.textAlign(RIGHT, CENTER);

                parent.textSize(tileSize*1.5f);
                parent.text("bonus", 48*tileSize, 25*tileSize); 

                for (int i = 0; i < noOfBonusesCollected; i++) {
                        imageMode(CENTER);
                        parent.image(bonusLogoImage, 52*tileSize + i *3*tileSize, 25*tileSize, 1.5f*tileSize, 1.5f*tileSize);
                }
        }

        public void track_fright_mode_time() {
                if (ghostMode == FRIGHTENED) {
                        timeSinceFrightModeStarted = (millis() - timeFrightModeStarted) / 1000;

                        if (timeSinceFrightModeStarted == 4) {
                                isGhostRecovering = true; // 1 sec warning for Pacman
                        }

                        if (timeSinceFrightModeStarted == 5) { //set the duration for Fright mode here
                                ghostMode = CHASE;
                                hasGhostModeChanged = true;
                                isGhostRecovering = false;
                        }
                }
        }

        public void track_bonus_appear_time() {
                if (hasBonusAppeared == true) {
                        timeSinceBonusAppeared = (millis() - timeBonusAppeared) / 1000;
                        if (timeSinceBonusAppeared == 9) { //set the duration for bonus appearance here
                                hasBonusAppeared = false;
                        }
                }
        }

        public void display_text_scores() {
                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                if (isDotScoreDisplayed[i][j] == true) {
                                        int index = convert_to_tile_ID(i, j);
                                        scoreTextArray[index].display("dot", i, j);
                                }

                                if (isEnergizerScoreDisplayed[i][j] == true) {
                                        int index = convert_to_tile_ID(i, j);
                                        scoreTextArray[index].display("energizer", i, j);
                                }
                        }
                }

                if (isGhostEatenScoreDisplayed == true) {
                        ghostScoreText.display("ghost", ghostEatenXTile, ghostEatenYTile);
                }
                if (isBonusScoreDisplayed == true) {
                        bonusScoreText.display("bonus", bonusXTile, bonusYTile);
                }
        }

        public int convert_to_tile_ID(int xTile, int yTile) {
                return xNumTiles * yTile + xTile;
        }

        public void check_for_game_over() {
                if (dotsEaten == 270 && energizersEaten == 6) {
                        isGameOver = true;
                        winnerName = "Pacmax";
                        gf.timeGameOverStart = millis();

                        dotsEaten = energizersEaten = 0;
                } 
                if (pacman.noOfLifes == 0 && dotsEaten != 0) {
                        isGameOver = true;
                        winnerName = "Blinky";
                        gf.timeGameOverStart = millis();

                        dotsEaten = energizersEaten = 0;
                }
        }
}

class Screen { //class for the non-game screens

        int screenMode;
        final static int DISPLAY_TITLE_SCREEN = 1;
        final static int DISPLAY_HIGHSCORE_SCREEN = 2;
        final static int DISPLAY_CHAR_INTRO_SCREEN = 3;
        final static int DISPLAY_SCORE_SYS_SCREEN = 4;
        final static int DISPLAY_GAME_SCREEN = 5;

        int animFrame, animSpeed;

        int dir;

        PApplet parent;

        PImage maxusLogoImage;
        PImage bonusImage, energizerImage;

        int tileSize;

        long timeStart, timeNow;
        int timeBetweenScreens;

        Screen(PApplet frame) {

                parent = frame;

                frameRate(60);

                maxusLogoImage = loadImage("maxus_logo.png");
                maxusLogoImage.resize(displayW/10, 0);

                bonusImage = loadImage("maxusBonus.png");
                bonusImage.resize(displayW/40, 0);

                energizerImage = loadImage("energizer.png");
                energizerImage.resize(displayW/30, 0);

                tileSize = game.tileSize;

                initialise_title_screen();

                timeBetweenScreens = 10; //time interval between screen changes
                
                screenMode = DISPLAY_TITLE_SCREEN;
        }


        public void run() {
                
                timeNow = millis();
                
                if (screenMode == DISPLAY_HIGHSCORE_SCREEN) {
                        if ( (timeNow - timeStart)/1000 == timeBetweenScreens) {
                                screenMode = DISPLAY_CHAR_INTRO_SCREEN;
                                timeStart = millis();
                        }
                } else if (screenMode == DISPLAY_CHAR_INTRO_SCREEN) {
                        if ( (timeNow - timeStart)/1000 == timeBetweenScreens) {
                                screenMode = DISPLAY_SCORE_SYS_SCREEN;
                                timeStart = millis();
                        }
                } else if (screenMode == DISPLAY_SCORE_SYS_SCREEN) {
                        if ( (timeNow - timeStart)/1000 == timeBetweenScreens) {
                                initialise_title_screen();
                                screenMode = DISPLAY_TITLE_SCREEN;
                                timeStart = millis();
                        }
                } else if (screenMode == DISPLAY_TITLE_SCREEN) {
                        if ( (timeNow - timeStart)/1000 == timeBetweenScreens * 2) {
                                screenMode = DISPLAY_HIGHSCORE_SCREEN;
                                timeStart = millis();
                        }
                }
                
                switch(screenMode) {
                        case(DISPLAY_TITLE_SCREEN):
                        display_title_screen();
                        break;       
                        case(DISPLAY_HIGHSCORE_SCREEN):
                        display_high_score_screen();
                        break;
                        case(DISPLAY_CHAR_INTRO_SCREEN):
                        display_char_intro_screen();
                        break;
                        case(DISPLAY_SCORE_SYS_SCREEN):
                        display_score_sys_screen();
                        break;
                        case(DISPLAY_GAME_SCREEN):
                        gf.display_game_screen();
                        break;
                }
        }

        public void initialise_title_screen() {
                pacmax.xPos = 0;
                pacmax.yPos = displayH/2;

                blinky.xPos = -0.2f*displayW;
                blinky.yPos = displayH/2;

                pacmax.speed = pacmax.defaultSpeed;
                blinky.speed = 1.15f*blinky.defaultSpeed;

                dir = 1;

                score.ghostMode = score.CHASE;

                pacmax.isRight = true; pacman.isLeft = false;
                blinky.isRight = true; blinky.isLeft = false;
        }


        public void display_title_screen() {
                // top half of screen: title 
                // bottom half of screen: switches between "insert coin" and "chase animations"
                parent.textAlign(CENTER);
                parent.textFont(myFont);
                parent.textSize(displayH/10);
                parent.fill(255, 255, 0);
                parent.text("PACMAN", 0.5f*displayW, 0.3f*displayH);

                parent.image(maxusLogoImage, 0.5f*displayW, 0.4f*displayH);

                parent.textFont(myFont);
                parent.textSize(tileSize);
                parent.fill(180);
                parent.text("2013", 0.5f*displayW, 0.45f*displayH);

                display_chase_animation();

                display_insert_coin_text();
        }

        public void display_chase_animation() {

                pacmax.xPos += pacmax.speed * dir;
                blinky.xPos += blinky.speed * dir;

                pacmax.yPos = 0.6f*displayH;
                blinky.yPos = pacmax.yPos;

                pacmax.animate_images();
                blinky.animate_images();

                if (pacmax.xPos > 1.2f*displayW) {

                        pacmax.isRight = false;
                        blinky.isRight = false;

                        pacmax.isLeft = true;
                        blinky.isLeft = true;

                        pacmax.speed = 1.15f*pacmax.defaultSpeed;
                        blinky.speed = pacmax.defaultSpeed;

                        dir *= -1;

                        score.ghostMode = score.FRIGHTENED;

                        pacmax.xPos = 1.2f*displayW;
                        blinky.xPos = displayW;
                } 
                else if (pacmax.xPos < 0) {

                        pacmax.isLeft = false;
                        blinky.isLeft = false;

                        pacmax.isRight = true;
                        blinky.isRight = true;

                        pacmax.speed = pacmax.defaultSpeed;
                        blinky.speed = 1.15f*blinky.defaultSpeed;

                        dir *= -1;

                        score.ghostMode = score.CHASE;

                        pacmax.xPos = 0;
                        blinky.xPos = -0.2f*displayW;
                }
        }

        public void display_insert_coin_text() {
                animFrame++;

                animSpeed = PApplet.parseInt(frameRate); 

                if (animFrame <= animSpeed) {
                        parent.textFont(myFont);
                        parent.textAlign(CENTER);
                        parent.fill(255);
                        parent.textSize(displayH/20);
                        parent.text("INSERT COIN", 0.5f*displayW, 0.9f*displayH);
                } 
                else {
                }
                if (animFrame > animSpeed * 2) {
                        animFrame = 0;
                }
        }

        public void display_high_score_screen() {
                // fake highScore screen

                        parent.textAlign(CENTER);
                parent.textFont(myFont);

                parent.textSize(displayH/12.5f); 
                parent.fill(255);
                parent.text("Highscores", 0.5f*displayW, 0.15f*displayH);

                parent.textAlign(LEFT);

                parent.textSize(displayH/18.75f);
                parent.fill(255, 255, 0);
                parent.text("RANK", 0.1f*displayW, 0.3f*displayH); 
                parent.text("NAME", 0.3f*displayW, 0.3f*displayH); 
                parent.text("SCORE", 0.6f*displayW, 0.3f*displayH);

                parent.textSize(displayH/22);
                parent.fill(255);
                parent.text("1ST", 0.1f*displayW, 0.35f*displayH); 
                parent.text("MAXUS", 0.3f*displayW, 0.35f*displayH); 
                parent.text("10,000 PTS   [PERFECT!]", 0.6f*displayW, 0.35f*displayH);

                parent.fill(180);
                parent.text("2ND", 0.1f*displayW, 0.4f*displayH); 
                parent.text("METALWORKS", 0.3f*displayW, 0.4f*displayH); 
                parent.text("10,000 PTS   [PERFECT!]", 0.6f*displayW, 0.4f*displayH);

                parent.fill(255);
                parent.text("3RD", 0.1f*displayW, 0.45f*displayH); 
                parent.text("TOM", 0.3f*displayW, 0.45f*displayH); 
                parent.text("9,600 PTS", 0.6f*displayW, 0.45f*displayH);

                parent.fill(180);
                parent.text("4TH", 0.1f*displayW, 0.5f*displayH); 
                parent.text("ADAM", 0.3f*displayW, 0.5f*displayH); 
                parent.text("9,200 PTS", 0.6f*displayW, 0.5f*displayH);

                parent.fill(255);
                parent.text("5TH", 0.1f*displayW, 0.55f*displayH); 
                parent.text("BEN", 0.3f*displayW, 0.55f*displayH); 
                parent.text("8,200 PTS", 0.6f*displayW, 0.55f*displayH);

                parent.fill(180);
                parent.text("6TH", 0.1f*displayW, 0.6f*displayH); 
                parent.text("HARESH", 0.3f*displayW, 0.6f*displayH); 
                parent.text("7,800 PTS", 0.6f*displayW, 0.6f*displayH);

                parent.fill(255);
                parent.text("7TH", 0.1f*displayW, 0.65f*displayH); 
                parent.text("MITHRU", 0.3f*displayW, 0.65f*displayH); 
                parent.text("7,020 PTS", 0.6f*displayW, 0.65f*displayH);

                parent.fill(180);
                parent.text("8TH", 0.1f*displayW, 0.7f*displayH); 
                parent.text("NICO", 0.3f*displayW, 0.7f*displayH); 
                parent.text("6,880 PTS", 0.6f*displayW, 0.7f*displayH);

                parent.fill(255);
                parent.text("9TH", 0.1f*displayW, 0.75f*displayH); 
                parent.text("ROLLEN", 0.3f*displayW, 0.75f*displayH); 
                parent.text("6,400 PTS", 0.6f*displayW, 0.75f*displayH);

                parent.fill(180);
                parent.text("10TH", 0.1f*displayW, 0.8f*displayH); 
                parent.text("UPESH", 0.3f*displayW, 0.8f*displayH); 
                parent.text("5,800 PTS", 0.6f*displayW, 0.8f*displayH);

                display_insert_coin_text();
        }

        public void display_char_intro_screen() {
                //intro the characters

                pacmax.xPos = displayW/4;
                pacmax.yPos = 2*displayH/5;

                pacmax.speed = tileSize/6;
                pacmax.isRight = true;

                pacmax.size = tileSize*3;

                pacmax.animate_images();

                parent.textFont(myFont);
                parent.fill(255);
                parent.textAlign(CENTER);

                parent.textSize(displayH/30);
                parent.text("Pacmax", displayW/4, 3*displayH/5);

                parent.textSize(displayH/15);
                parent.text("VS", displayW/2, displayH/2);

                blinky.xPos = 3*displayW/4;
                blinky.yPos = 2*displayH/5;

                blinky.speed = tileSize/6;
                blinky.isLeft = true; 

                blinky.size = tileSize*4;

                blinky.animate_images();

                parent.textSize(displayH/30);
                parent.text("Blinky", 3*displayW/4, 3*displayH/5);

                display_insert_coin_text();
        }

        public void display_score_sys_screen() {
                // explain point system

                parent.fill(255, 255, 0);
                parent.ellipse(2*displayW/7, 3*displayH/15, tileSize/2 + 0.05f*tileSize*sin(frameCount/8), tileSize/2 + 0.05f*tileSize*sin(frameCount/8));

                parent.textFont(myFont);
                parent.textSize(displayH/20);

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Dot - 20 PTS", 3*displayW/7, 3*displayH/15);

                parent.noStroke();
                parent.fill(255, 50);
                parent.ellipse(2*displayW/7, 5*displayH/15, tileSize + 0.1f*tileSize*sin(frameCount/6), tileSize + 0.1f*tileSize*sin(frameCount/6) ); 
                parent.imageMode(CENTER);
                parent.image(energizerImage, 2*displayW/7, 5*displayH/15);

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Energizer - 100 PTS", 3*displayW/7, 5*displayH/15);

                blinky.xPos = 2*displayW/7;
                blinky.yPos = 7*displayH/15;

                blinky.isRight = true;
                blinky.size = game.tileSize*2.5f;
                score.ghostMode = score.FRIGHTENED;
                blinky.animate_images();

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Vulnerable Blinky - 400 PTS", 3*displayW/7, 7*displayH/15);

                parent.noStroke();
                parent.fill(255, 50);
                parent.ellipse(2*displayW/7, 9*displayH/15, tileSize*3 + 0.3f*tileSize*sin(frameCount/4), tileSize*3 + 0.3f*tileSize*sin(frameCount/4) ); 
                parent.image(bonusImage, 2*displayW/7, 9*displayH/15);

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Maxus Bonus - 800 PTS", 3*displayW/7, 9*displayH/15);

                display_insert_coin_text();
        }
}

/****************************************************
 *
 * audio clips: opening_song (5 sec), chase_mode, frightened_mode, pacman_death (2 sec), game_over (5 sec)
 * 
 * triggers: insert_coin, eating_dot, eating_bonus, eating_ghost, 
 *
 *****************************************************/




Playable player1, player2, player3, player4, player5;
AudioSample sample1, sample2, sample3, sample4, sample5;

class Sound {
        
        Sound () {
                                
                player1 = minim.loadFile("opening_song.wav");
                player2 = minim.loadFile("chase_mode.wav");
                player3 = minim.loadFile("frightened_mode.wav");
                player4 = minim.loadFile("pacman_death.wav");
                player5 = minim.loadFile("game_over.wav");

                sample1 = minim.loadSample("insert_coin.mp3");
                sample2 = minim.loadSample("eating_dot.wav");
                sample3 = minim.loadSample("eating_bonus.wav");
                sample4 = minim.loadSample("eating_ghost.wav");
                sample5 = minim.loadSample("eating_energizer.wav");
        }

        public void initialise() {
                player1.rewind();
                player2.rewind();
                player3.rewind();
                player4.rewind();
                player5.rewind();
        }

        public void play_opening_song() {
                player2.pause(); 
                player3.pause(); 
                player4.pause(); 
                player5.pause();
                player1.play();
        }

        public void play_chase_mode_song() {
                player1.pause(); 
                player3.pause(); 
                player4.pause(); 
                player5.pause();
                player2.loop();
        }

        public void play_frightened_mode_song() {
                player2.pause(); 
                player1.pause(); 
                player4.pause(); 
                player5.pause();
                player3.loop();
        }

        public void play_pacman_death_song() {
                player1.pause(); 
                player2.pause(); 
                player3.pause(); 
                player5.pause();
                player4.play();
        }

        public void play_game_over_song() {
                player1.pause();
                player2.pause();
                player3.pause();
                player4.pause();
                player5.play();
        }

        public void trigger_insert_coin_sound() {
                sample1.trigger();
        }

        public void trigger_eating_dot_sound() {
                sample5.trigger();
        }

        public void trigger_eating_bonus_sound() {
                sample3.trigger();
        }

        public void trigger_eating_ghost_sound() {
                sample4.trigger();
        }

        public void trigger_eating_energizer_sound() {
                sample3.trigger();
        }

}


public void stop() {
        sample1.close();
        sample2.close();
        sample3.close();
        sample4.close();
        sample5.close();
        minim.stop();
        super.stop();
}


class Sprite {

        PImage spriteImage;
        PApplet parent;
        float xPos, yPos;
        int xTile, yTile, toTile;
        int xStartTile, yStartTile;
        int tileSize;
        float size;
        float defaultSpeed, speed;
        boolean isUp, isDown, isLeft, isRight;
        
        boolean isEaten;
        
        int animFrame, animSpeed;
        

        Sprite (PApplet frame) {
                parent = frame;

                parent.imageMode(CENTER);

                defaultSpeed = game.tileSize/6;
                speed = defaultSpeed;
                tileSize = game.tileSize;
                size = game.tileSize * 2;

                animSpeed = PApplet.parseInt( frameRate * 4 / speed); //set animation speed here
        }

        public void update(boolean isUp_, boolean isDown_, boolean isLeft_, boolean isRight_) {
                isUp = isUp_; 
                isDown = isDown_; 
                isLeft = isLeft_; 
                isRight = isRight_;

                set_position();
        }

        public void set_position() {
                xTile= PApplet.parseInt( xPos / tileSize); 
                yTile = PApplet.parseInt( yPos / tileSize);

                if (isUp) {
                        toTile = PApplet.parseInt( (yPos - tileSize) / tileSize );
                        if (toTile >= 0) {
                                if (game.isActiveTiles[xTile][toTile]) {
                                        xPos = xTile * tileSize + tileSize/2;
                                        yPos -= speed;
                                }
                        }
                }
                if (isDown) {
                        toTile = PApplet.parseInt ( (yPos + tileSize) / tileSize );
                        if (toTile < game.yNumTiles) {
                                if (game.isActiveTiles[xTile][toTile]) {
                                        xPos = xTile * tileSize + tileSize/2;
                                        yPos += speed;
                                }
                        }
                }
                if (isLeft) {
                        toTile = PApplet.parseInt( (xPos - tileSize) / tileSize );
                        if (toTile > 0) {
                                if (game.isActiveTiles[toTile][yTile]) {
                                        yPos = yTile * tileSize + tileSize/2;
                                        xPos -= speed;
                                }
                        }
                        if (toTile <= 0 && game.isTunnelTile[xTile][yTile]) {
                                xPos = (game.xNumTiles - 1) * tileSize + tileSize*19/20;
                        }
                }

                if (isRight) {
                        toTile = PApplet.parseInt( (xPos + tileSize) / tileSize );
                        if (toTile < game.xNumTiles) {
                                if (game.isActiveTiles[toTile][yTile]) {
                                        yPos = yTile * tileSize + tileSize/2;
                                        xPos += speed;
                                }
                        }
                        if (toTile >= game.xNumTiles && game.isTunnelTile[xTile][yTile]) { 
                                xPos = tileSize/20;
                        }
                }
        }

        public void go_to_start_position() {
                xPos = xStartTile * tileSize + tileSize /2;
                yPos = yStartTile * tileSize + tileSize /2;
        }
}

/**********************************
 *
 *        PACMAN
 *
 ***********************************/

class Pacman extends Sprite {

        int noOfLifes;

        Pacman (PApplet frame ) {

                super(frame);
        }

        public void init () {

                noOfLifes = 3;
                
                spriteImage = loadImage("pacmax.png");

                for (int i = 0; i < game.xNumTiles; i++) {
                        for (int j = 0; j < game.yNumTiles; j++) {
                                if (game.isPacmanStartTile[i][j]) {
                                        xPos = i * tileSize + tileSize/2;
                                        yPos = j * tileSize + tileSize/2;

                                        xStartTile = i;
                                        yStartTile = j;
                                }
                        }
                }
                
                isEaten = false;
        }


        public void display() {
                if (score.ghostMode == score.CHASE) { 
                        speed = 0.8f * defaultSpeed;
                } 
                else if (score.ghostMode == score.FRIGHTENED) {
                        speed = defaultSpeed * 1.1f;
                }

                if (game.isTunnelTile[xTile][yTile]) { 
                        speed = 1.2f * defaultSpeed;
                }

                animate_images();
        }

        public void animate_images() {
                parent.imageMode(CENTER);

                animFrame++;

                //                                println("animSpeed: " + animSpeed + "    " + "speed: " + speed + "    " + "frameRate: " + frameRate);

                if (isUp == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxU1.png");
                        }                                
                        else {
                                spriteImage = loadImage("pacmaxU2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        parent.image(spriteImage, xPos, yPos, size, 2*size);
                } 
                else if (isDown == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxD1.png");
                        } 
                        else {
                                spriteImage = loadImage("pacmaxD2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        parent.image(spriteImage, xPos, yPos, size, 2*size);
                } 
                else if (isLeft == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxL1.png");
                        } 
                        else {
                                spriteImage = loadImage("pacmaxL2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        parent.image(spriteImage, xPos, yPos, 2*size, size);
                } 
                else if (isRight == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxR1.png");
                        } 
                        else {
                                spriteImage = loadImage("pacmaxR2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        parent.image(spriteImage, xPos, yPos, 2*size, size);
                } 
                else { //when standing still
                        spriteImage = loadImage("pacmaxR1.png");
                        parent.image(spriteImage, xPos, yPos, 2*size, size);
                }
        }
}


/**********************************
 *
 *        GHOST
 *
 ***********************************/

class Ghost extends Sprite {

        boolean isInGhostHouse;
        int dir;

        Ghost (PApplet frame ) {
                super(frame);
        }

        public void init() {
                spriteImage = loadImage("blinky.png");
                isEaten = isInGhostHouse = false;

                dir = 1;

                for (int i = 0; i < game.xNumTiles; i++) {
                        for (int j = 0; j < game.yNumTiles; j++) {
                                if (game.isGhostStartTile[i][j]) {
                                        xPos = i * tileSize + tileSize/2;
                                        yPos = j * tileSize + tileSize/2;

                                        xStartTile = i;
                                        yStartTile = j;
                                }
                        }
                }
                
                size = 2.5f*tileSize; //ghost has to look comparable in size to pacman
        }

        public void display() {
                if (score.ghostMode == score.CHASE) {
                        speed = defaultSpeed * 1.05f; //default speed of ghost
                }                

                if (score.hasGhostModeChanged == true) {
                        if (score.ghostMode == score.CHASE) { 

                                mySound.play_chase_mode_song();

                                speed = defaultSpeed * 1.05f; //default speed of ghost

                                if (isEaten == true) { //emerging from ghost house after being eaten
                                        go_to_start_position();
                                        isEaten = false;
                                        isInGhostHouse = false;
                                }
                        } 
                        else if (score.ghostMode == score.FRIGHTENED && isInGhostHouse == false) {

                                mySound.play_frightened_mode_song();

                                speed = 0.5f*defaultSpeed; //speed for frightened state
                        }
                        score.hasGhostModeChanged = false;
                }

                if (score.ghostMode == score.FRIGHTENED && isEaten == true && isInGhostHouse == false) {                 

                        send_to_ghost_house();

                        isInGhostHouse = true;
                }                

                if (isInGhostHouse == true) {

                        //disable keys
                        gf.isGhostLeft = gf.isGhostRight = gf.isGhostUp = gf.isGhostDown = false;

                        speed = defaultSpeed;

                        xPos += speed * dir;

                        //movement within ghost house
                        if (xPos > (xStartTile + 3)*tileSize || xPos < (xStartTile - 2)*tileSize ) { 
                                dir *= -1;
                        }
                }

                if (game.isTunnelTile[xTile][yTile]) {
                        speed = 0.6f * defaultSpeed;
                }

                animate_images();
        }

        public void send_to_ghost_house() {
                xPos = xStartTile * tileSize + tileSize/2;
                yPos = (yStartTile + 2) * tileSize + tileSize/2;
        }

        public void animate_images() {
                parent.imageMode(CENTER);

                //                println("animSpeed: " + animSpeed + "    " + "speed: " + speed + "    " + "frameRate: " + frameRate);


                if (isUp == true && isInGhostHouse == false) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyU1Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyU1.png");
                                }
                        }                                
                        else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyU2Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyU2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } 
                else if (isDown == true && isInGhostHouse == false) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyD1Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyD1.png");
                                }
                        }                                
                        else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyD2Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyD2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } 
                else if (isLeft == true && isInGhostHouse == false) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyL1Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyL1.png");
                                }
                        }                                
                        else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyL2Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyL2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } 
                else if (isRight == true && isInGhostHouse == false) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyR1Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyR1.png");
                                }
                        }                                
                        else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyR2Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyR2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } 
                else if (isInGhostHouse == true) {
                        if (animFrame++ <= animSpeed * 6) {
                                spriteImage = loadImage("eye1.png");
                        } 
                        else {
                                spriteImage = loadImage("eye2.png");
                        }
                        if (animFrame > 2 * animSpeed * 6) {
                                animFrame = 0;
                        }
                }

                else { //when not moving
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyD1Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyD1.png");
                                }
                        }                                
                        else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyD1Blue.png");
                                } 
                                else {
                                        spriteImage = loadImage("blinkyD1.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                }

                parent.image(spriteImage, xPos, yPos, size, size);
        }
}

class ScoreText {

        String scoreType;
        int textColor;
        int opacity;
        int size; 
        int fadeSpeed;
        String scoreText;

        PApplet parent;

        ScoreText(PApplet p) {
                opacity = 255;
                fadeSpeed = 5;
                parent = p;
        }

        public void display(String scoreType, int xTile, int yTile) {

                if (scoreType == "dot") {
                        textColor = color(255);
                        size = game.tileSize/2;
                        scoreText = "+20";
                        fadeSpeed = 5;
                } 
                else if (scoreType == "energizer") {
                        textColor = color(255);
                        size = game.tileSize;
                        scoreText = "+100";
                        fadeSpeed = 3;
                }
                else if (scoreType == "ghost") {
                        textColor = color(255);
                        size = game.tileSize*2;
                        scoreText = "+400";
                        fadeSpeed = 2;
                }
                else if (scoreType == "bonus") {
                        textColor = color(255);
                        size = game.tileSize*3;
                        scoreText = "+800";
                        fadeSpeed = 1;
                }

                if (opacity <= 0 && scoreType == "dot") {
                        score.isDotScoreDisplayed[xTile][yTile] = false;
                } 
                else if (opacity <= 0 && scoreType == "energizer") {
                        score.isEnergizerScoreDisplayed[xTile][yTile] = false;
                }
                else if (opacity <= 0 && scoreType == "ghost") {
                        score.isGhostEatenScoreDisplayed = false;
                        opacity = 255;
                }
                else if (opacity <= 0 && scoreType == "bonus") {
                        score.isBonusScoreDisplayed = false;
                        opacity = 255;
                }

                parent.fill(textColor, opacity);
                parent.textFont(myFont, size);
                parent.text(scoreText, xTile * game.tileSize, yTile * game.tileSize - game.tileSize/2);
                
                opacity -= fadeSpeed;
        }
}

        static public void main(String[] passedArgs) {
                String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "pacman_130813a" };
                if (passedArgs != null) {
                  PApplet.main(concat(appletArgs, passedArgs));
                } else {
                  PApplet.main(appletArgs);
                }
        }
}
