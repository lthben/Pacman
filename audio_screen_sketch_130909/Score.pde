/*
 270 dots x 20 points = 5,400 points
 6 energizers x 100 points = 600 points
 2 bonuses x 800 = 1,600 points
 6 ghosts eaten x  400 points = 2,400 points
 TOTAL = 10,000 points perfect score
 */

class Score {

        int score, highScore;

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

        int dotsEaten;

        boolean[][] isDotScoreDisplayed, isEnergizerScoreDisplayed;
        boolean isGhostEatenScoreDisplayed, isBonusScoreDisplayed;

        ScoreText[] scoreTextArray;
        ScoreText ghostScoreText, bonusScoreText;

        PImage pacmanLogoImage, bonusLogoImage;

        Score() {
                score = highScore = 0;


                ghostMode = CHASE;
                hasGhostModeChanged = false;

                noOfBonusesCollected = 0;
                hasBonusAppeared = false;
                //                isGameOver = isRoundStart = false;
                dotsEaten = 0;
                tileSize = 20;
                xNumTiles = 59;
                yNumTiles = 20;

                pacmanLogoImage = loadImage("pacmax.png");
                bonusLogoImage = loadImage("maxusBonus.png");

                isDotScoreDisplayed = new boolean[xNumTiles][yNumTiles];
                isEnergizerScoreDisplayed = new boolean[xNumTiles][yNumTiles]; 
                isGhostEatenScoreDisplayed = isBonusScoreDisplayed = false;

                scoreTextArray = new ScoreText[xNumTiles*yNumTiles]; //for dots and energizers only

                for (int i = 0; i < xNumTiles*yNumTiles; i++) {
                        scoreTextArray[i] = new ScoreText();
                }

                ghostScoreText = new ScoreText();
                bonusScoreText = new ScoreText();
        } 

        void run(int pacman_xTile_, int pacman_yTile_, int ghost_xTile_, int ghost_yTile_) {

                pacman_xTile = pacman_xTile_;
                pacman_yTile = pacman_yTile_;
                ghost_xTile = ghost_xTile_;
                ghost_yTile = ghost_yTile_;

                displayPacmanAssets(); 

                trackFrightModeTime();

                trackBonusAppearTime();

                updateScores();

                displayMainScore();

                displayTextScores();
        }

        void updateScores() {
                if (game.hasDot[pacman_xTile][pacman_yTile] == true) {
                        game.hasDot[pacman_xTile][pacman_yTile] = false;

                        isDotScoreDisplayed[pacman_xTile][pacman_yTile] = true;   

                        score += 20;
                        dotsEaten++;

                        if (dotsEaten == 7 || dotsEaten == 170) { //set the dot count here for the bonus to appear
                                hasBonusAppeared = true;
                                timeBonusAppeared = millis();
                        }
                }

                if (game.hasEnergizer[pacman_xTile][pacman_yTile] == true) {
                        game.hasEnergizer[pacman_xTile][pacman_yTile] = false;

                        isEnergizerScoreDisplayed[pacman_xTile][pacman_yTile] = true;

                        score += 100;

                        ghostMode = FRIGHTENED;
                        hasGhostModeChanged = true;

                        timeFrightModeStarted = millis();
                }

                if (game.isBonusTile[pacman_xTile][pacman_yTile] == true) {
                        if (hasBonusAppeared == true) {
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

                                pacman.noOfLifes--;

                                roundStart();
                        } else if (ghostMode == FRIGHTENED) {
                                if (ghost.isEaten == false) {
                                        isGhostEatenScoreDisplayed = true;

                                        ghostEatenXTile = pacman_xTile;
                                        ghostEatenYTile = pacman_yTile;

                                        score += 400;
                                }
                                ghost.isEaten = true;
                        }
                }
        }

        void displayMainScore() {
                parent.fill(255, 255, 0);
                parent.textFont(myFont);
                parent.textSize(tileSize);
                parent.text("score:  " + score, 0, - displayH/10);
        }


        void displayPacmanAssets() {
                for (int i = 0; i < pacman.noOfLifes; i++) {
                        imageMode(CENTER);
                        parent.image(pacmanLogoImage, 7.3*displayWidth/10 + i *2*tileSize, 5.2*displayH/10, 2*tileSize, tileSize);
                }

                for (int i = 0; i < noOfBonusesCollected; i++) {
                        imageMode(CENTER);
                        parent.image(bonusLogoImage, 7.3*displayWidth/10 + i *2*tileSize, 5.6*displayH/10, tileSize, tileSize);
                }
        }

        void trackFrightModeTime() {
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

        void trackBonusAppearTime() {
                if (hasBonusAppeared == true) {
                        timeSinceBonusAppeared = (millis() - timeBonusAppeared) / 1000;
                        if (timeSinceBonusAppeared == 9) { //set the duration for bonus appearance here
                                hasBonusAppeared = false;
                        }
                }
        }

        void roundStart() {
                pacman.goToStartPosition();
                ghost.goToStartPosition();
        }

        void displayTextScores() {
                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                if (isDotScoreDisplayed[i][j] == true) {
                                        int index = convertToTileID(i, j);
                                        scoreTextArray[index].display("dot", i, j);
                                }

                                if (isEnergizerScoreDisplayed[i][j] == true) {
                                        int index = convertToTileID(i, j);
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

        int convertToTileID(int xTile, int yTile) {
                return xNumTiles * yTile + xTile;
        }
}

