GameFrame gf;

class Game { //class for game screen

        String loadFileName;

        boolean[][] isActiveTiles, hasEnergizer, hasDot, isTunnelTile, isPacmanStartTile, isGhostStartTile, isBonusTile;  

        int xNumTiles, yNumTiles;
        int tileSize;

        Game() {
        }

        void init() {
                isActiveTiles = new boolean[xNumTiles][yNumTiles];
                hasEnergizer = new boolean[xNumTiles][yNumTiles];
                hasDot = new boolean[xNumTiles][yNumTiles];
                isTunnelTile = new boolean[xNumTiles][yNumTiles];
                isPacmanStartTile = new boolean[xNumTiles][yNumTiles];
                isGhostStartTile = new boolean[xNumTiles][yNumTiles];
                isBonusTile = new boolean[xNumTiles][yNumTiles];

                setTileSize();
        }

        void setTileSize() {
                if (xNumTiles > yNumTiles) tileSize = int ( 0.8 * displayW / xNumTiles );
                if (yNumTiles >= xNumTiles ) tileSize = int ( 0.8 * displayH / yNumTiles );

                //                println("displayW: " + displayW);
        }

        void run() {
                //create a new window for the GUI. Size includes the border.
                //                gf = addGameFrame("Pacman", tileSize*xNumTiles + 1, tileSize*yNumTiles + 23); 
                gf = addGameFrame("Pacman", displayW, displayH);
        }
}

GameFrame addGameFrame(String theName, int theWidth, int theHeight) {
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

        void setup() {
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

        void draw() {
                background(0);  

                timeNow = millis();

                check_for_coin_insert();   

                myScreen.run();

                check_for_game_start();

                check_for_round_start();

                check_for_game_over();
        }

        void initialise_new_game() { // after each game is played

                data.read_from_file("maxus2.txt");

                pacman.init();
                ghost.init();

                pacmax.init();
                blinky.init();

                score.initialise();

                myScreen.initialise_title_screen();
        }

        void display_game_screen() { // the main game screen

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

        void calc_screen_translation() { //helper function
                if (xNumTiles > yNumTiles) { //cater for maze landscape or vertical orientation, 10% buffer on each longer side of maze
                        translate(displayW / 10, displayH / 2 - yNumTiles * tileSize / 2);
                } 
                else {
                        translate(displayW / 2 - xNumTiles * tileSize / 2, displayH / 10);
                }
        }

        void draw_grid() { //helper function

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

        void draw_game_assets() { //helper function
                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                if (game.isActiveTiles[i][j]) {
                                        //                                       fill(0,0);
                                        //                                        rect(i * tileSize, j * tileSize, tileSize, tileSize);
                                }
                                if (game.hasEnergizer[i][j]) {
                                        noStroke();
                                        fill(255, 50);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize + 0.1*tileSize*sin(frameCount/6), tileSize + 0.1*tileSize*sin(frameCount/6) ); 
                                        imageMode(CENTER);
                                        image(energizerImage, i * tileSize + tileSize/2, j * tileSize + tileSize/2);
                                }
                                if (game.hasDot[i][j]) {
                                        fill(255, 255, 0);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize/4 + 0.05*tileSize*sin(frameCount/8), tileSize/4 + 0.05*tileSize*sin(frameCount/8));
                                }
                                if (game.isTunnelTile[i][j]) {
                                        //                                        fill(255, 100);
                                        //                                        rect(i * tileSize, j * tileSize, tileSize, tileSize);
                                }
                                if (game.isBonusTile[i][j] && score.hasBonusAppeared) {
                                        noStroke();
                                        fill(255, 50);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize*3 + 0.3*tileSize*sin(frameCount/4), tileSize*3 + 0.3*tileSize*sin(frameCount/4) ); 

                                        imageMode(CENTER);
                                        image(bonusImage, i * tileSize + tileSize/2, j * tileSize + tileSize/2);
                                }
                        }
                }
        }

        void check_for_game_start () {

                if (isGameStarted == true) {

                        initialise_new_game();

                        if ( timeNow - timeGameStart < 5000) { 

                                if (mySound.hasPlayedOpeningSong == false) {
                                        mySound.play_opening_song();
                                        mySound.hasPlayedOpeningSong = true;
                                }

                                display_game_start_text();
                        } 
                        else { //after opening sequence has played
                                isGameStarted = false;

                                isKeyInputAllowed = true;

                                mySound.play_chase_mode_song();

                                mySound.rewind_opening_song();

                                mySound.hasPlayedOpeningSong = false;
                        }
                }
        }

        void check_for_round_start() {
                if (pacman.isEaten == true && pacman.noOfLifes != 0 ) {

                        if ( timeNow - timePacmanEaten < 2000 ) {

                                isKeyInputAllowed = false;
                                pacman.isUp = pacman.isDown = pacman.isRight = pacman.isLeft = ghost.isRight = ghost.isLeft = ghost.isUp = ghost.isDown = false;

                                if (mySound.hasPlayedPacmanDeathSong == false) {
                                        mySound.play_pacman_death_song();
                                        mySound.hasPlayedPacmanDeathSong = true;
                                }

                                fill(150, 100);
                                rect(0, 0, displayW, displayH);
                        } 
                        else {
                                pacman.go_to_start_position();
                                ghost.go_to_start_position();

                                pacman.isEaten = false;

                                isKeyInputAllowed = true;

                                pacman.noOfLifes--;

                                mySound.rewind_pacman_death_song();
                                mySound.hasPlayedPacmanDeathSong = false;

                                mySound.play_chase_mode_song();
                        }
                }
        }

        void check_for_game_over() {

                if (score.isGameOver == true) {
                        if ( (timeNow - timeGameOverStart) / 1000 < 6) {

                                display_game_over_text();

                                if (mySound.hasPlayedGameOverSong == false) {
                                        mySound.play_game_over_song();
                                        mySound.hasPlayedGameOverSong = true;
                                }
                        } 
                        else {
                                mySound.rewind_game_over_song();
                                mySound.hasPlayedGameOverSong = false;

                                score.isGameOver = false;

                                isKeyInputAllowed = true;

                                myScreen.screenMode = myScreen.DISPLAY_HIGHSCORE_SCREEN;

                                myScreen.timeStart = millis(); // to enable off-game screens

                                        initialise_new_game();
                        }
                }
        }


        void display_game_start_text() {

                fill(150, 100);
                rect(0, 0, displayW, displayH);

                textFont(myFont);
                textAlign(CENTER);
                textSize(displayH/30);
                fill(255);
                text("Get Ready!", displayW/2, displayH/2);

                isKeyInputAllowed = false;
        }

        void display_round_start_text() {
                // screen overlay
                // "get ready"
        }

        void display_game_over_text () {

                fill(150, 100);
                rect(0, 0, displayW, displayH);

                textFont(myFont);
                textAlign(CENTER);
                textSize(displayH/20);
                fill(255);
                text("Game Over", displayW/2, 3*displayH/7);

                if (score.winnerName == "Pacmax") {
                        text("Winner is Pacmax! Your score is " + score.score, displayW/2, 4*displayH/7);
                } 
                else {
                        text("Winner is Blinky!", displayW/2, 4*displayH/7);
                }

                isKeyInputAllowed = false;
        }

        void check_for_coin_insert() {

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

        //comment out if using Arduino buttons
        void keyPressed() {

                if (isKeyInputAllowed == true) {

                        if (key == CODED) {
                                if (keyCode == UP) isPacmanUp = true; 
                                if (keyCode == DOWN) isPacmanDown = true; 
                                if (keyCode == LEFT) isPacmanLeft = true; 
                                if (keyCode == RIGHT) isPacmanRight = true;
                        }

                        if (isGhostKeyInputAllowed == true) {
                                if (key == 'w' || key == 'W') isGhostUp = true;
                                if (key == 's' || key == 'S') isGhostDown = true;
                                if (key == 'a' || key == 'A') isGhostLeft = true;
                                if (key == 'd' || key == 'D') isGhostRight = true;
                        }

                        if (key == ' ') {
                                mySound.trigger_insert_coin_sound();

                                timeCoinStart = millis();
                                isCoinInserted = true;
                        }
                } 
                else { 
                        isPacmanUp = isPacmanDown = isPacmanRight = isPacmanLeft = false;
                        isGhostUp = isGhostDown = isGhostRight = isGhostLeft = false;
                }
        }

        //comment out if using Arduino buttons
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
}

