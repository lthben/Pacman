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

        void initialise() {
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

        void run(int pacman_xTile_, int pacman_yTile_, int ghost_xTile_, int ghost_yTile_) {

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

        void update_scores() {
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

                if ( (pacman_xTile == ghost_xTile && pacman_yTile == ghost_yTile) || dist(pacman.xPos, pacman.yPos, ghost.xPos, ghost.yPos) < tileSize/2   ) { //pacman and ghost meet

                        if (ghostMode == CHASE) {

                                isKeyInputAllowed = false; 
                                pacman.isUp = pacman.isDown = pacman.isRight = pacman.isLeft = ghost.isRight = ghost.isLeft = ghost.isUp = ghost.isDown = false;

                                if (pacman.isEaten == false) {
                                        gf.timePacmanEaten = millis();
                                }

                                pacman.isEaten = true;
                        } 
                        else if (ghostMode == FRIGHTENED) {

                                isGhostKeyInputAllowed = false;

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

        void display_main_score() {
                parent.fill(255);
                parent.textFont(myFont);
                parent.textAlign(LEFT, CENTER);
                parent.textSize(tileSize*1.5);           
                parent.text("score", 0, - displayH/20);

                parent.fill(255, 255, 0);
                parent.textAlign(LEFT, CENTER);
                parent.textSize(tileSize*2); 
                parent.text(score, tileSize*8, - displayH/20);
        }


        void display_pacman_assets() {

                parent.fill(255);
                parent.textFont(myFont);
                parent.textAlign(RIGHT, CENTER);

                parent.textSize(tileSize*1.5);
                parent.text("1UP", 48*tileSize, 22*tileSize); 

                for (int i = 0; i < pacman.noOfLifes; i++) {
                        imageMode(CENTER);
                        parent.image(pacmanLogoImage, 52*tileSize + i *3*tileSize, 22*tileSize, 3*tileSize, 1.5*tileSize);
                }

                parent.fill(255);
                parent.textFont(myFont);
                parent.textAlign(RIGHT, CENTER);

                parent.textSize(tileSize*1.5);
                parent.text("bonus", 48*tileSize, 25*tileSize); 

                for (int i = 0; i < noOfBonusesCollected; i++) {
                        imageMode(CENTER);
                        parent.image(bonusLogoImage, 52*tileSize + i *3*tileSize, 25*tileSize, 1.5*tileSize, 1.5*tileSize);
                }
        }

        void track_fright_mode_time() {
                if (ghostMode == FRIGHTENED) {
                        timeSinceFrightModeStarted = (millis() - timeFrightModeStarted) / 1000;

                        if (timeSinceFrightModeStarted == 4) {
                                isGhostRecovering = true; // 1 sec warning for Pacman
                        }

                        if (ghost.isEaten == false) {
                                if (timeSinceFrightModeStarted == 5) { //set the duration for Fright mode here
                                        ghostMode = CHASE;
                                        hasGhostModeChanged = true;
                                        isGhostRecovering = false;
                                }
                        } 
                        else if (ghost.isEaten == true) {
                                if ( (gf.timeNow - gf.timeGhostEaten )/1000 == 3) { //give Pacman exactly 3 secs after ghost is eaten to move freely
                                        ghostMode = CHASE;
                                        hasGhostModeChanged = true;
                                        isGhostRecovering = false;
                                }
                        }
                }
        }

        void track_bonus_appear_time() {
                if (hasBonusAppeared == true) {
                        timeSinceBonusAppeared = (millis() - timeBonusAppeared) / 1000;
                        if (timeSinceBonusAppeared == 9) { //set the duration for bonus appearance here
                                hasBonusAppeared = false;
                        }
                }
        }

        void display_text_scores() {
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

        int convert_to_tile_ID(int xTile, int yTile) {
                return xNumTiles * yTile + xTile;
        }

        void check_for_game_over() {
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

