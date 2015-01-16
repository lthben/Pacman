Pacman pacman;
Ghost ghost;
Score score;

class Game {

        String loadFileName;

        boolean[][] isActiveTiles, hasEnergizer, hasDot, isTunnelTile, isPacmanStartTile, isGhostStartTile, isBonusTile;  

        boolean isPacmanUp, isPacmanDown, isPacmanLeft, isPacmanRight, isGhostUp, isGhostDown, isGhostLeft, isGhostRight;

        int xNumTiles, yNumTiles;
        int tileSize;

        int w, h;


        Game() {
                tileSize = 20;
                xNumTiles = 59;
                yNumTiles = 20;

                pacman = new Pacman();
                ghost = new Ghost();
                score = new Score();

                pacman.init();
                ghost.init();

                backgroundImage.resize(xNumTiles * tileSize, yNumTiles * tileSize);
                bonusImage.resize(tileSize+10, tileSize+10);
                energizerImage.resize(tileSize+10, tileSize+10);
        }

        void init() {
                isActiveTiles = new boolean[xNumTiles][yNumTiles];
                hasEnergizer = new boolean[xNumTiles][yNumTiles];
                hasDot = new boolean[xNumTiles][yNumTiles];
                isTunnelTile = new boolean[xNumTiles][yNumTiles];
                isPacmanStartTile = new boolean[xNumTiles][yNumTiles];
                isGhostStartTile = new boolean[xNumTiles][yNumTiles];
                isBonusTile = new boolean[xNumTiles][yNumTiles];

                //                setTileSize();
        }

        void setTileSize() {
                if (xNumTiles > yNumTiles) tileSize = int ( 0.8 * displayW / xNumTiles );
                if (yNumTiles >= xNumTiles ) tileSize = int ( 0.8 * displayH / yNumTiles );
        }

        void run() {
                background(0);       

                pushMatrix();

                calcScreenTranslation();

                imageMode(CORNER);
                image(backgroundImage, 0, 0);

                //drawGrid();

                drawAssets();

                pacman.display(isPacmanUp, isPacmanDown, isPacmanLeft, isPacmanRight);
                pacman.update();
                ghost.display(isGhostUp, isGhostDown, isGhostLeft, isGhostRight);
                ghost.update();

                score.run(pacman.xTile, pacman.yTile, ghost.xTile, ghost.yTile);

                popMatrix();
        }

        void calcScreenTranslation() {
                if (xNumTiles > yNumTiles) { //cater for maze landscape or vertical orientation, 10% buffer on each longer side of maze
                        translate(displayW / 10, displayH / 2 - yNumTiles * tileSize / 2);
                } else {
                        translate(displayW / 2 - xNumTiles * tileSize / 2, displayH / 10);
                }
        }

        void drawGrid() {

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

        void drawAssets() {
                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                if (game.isActiveTiles[i][j]) {
                                        //                                        fill(0,0);
                                        //                                        rect(i * tileSize, j * tileSize, tileSize, tileSize);
                                }
                                if (game.hasEnergizer[i][j]) {
                                        noStroke();
                                        fill(255, 50);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize + 0.5*tileSize*sin(frameCount/6), tileSize + 0.5*tileSize*sin(frameCount/6) ); 
                                        imageMode(CENTER);
                                        image(energizerImage, i * tileSize + tileSize/2, j * tileSize + tileSize/2);
                                }
                                if (game.hasDot[i][j]) {
                                        fill(255, 255, 0);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize/4 + (tileSize/20)*sin(frameCount/8), tileSize/4 + (tileSize/20)*sin(frameCount/8));
                                }
                                if (game.isTunnelTile[i][j]) {
                                        //                                        fill(0,0);
                                        //                                        rect(i * tileSize, j * tileSize, tileSize, tileSize);
                                }
                                if (game.isBonusTile[i][j] && score.hasBonusAppeared) {
                                        noStroke();
                                        fill(255, 255, 0, 100);
                                        ellipse(i * tileSize + tileSize/2, j * tileSize + tileSize/2, tileSize*3 + 0.5*tileSize*sin(frameCount/6), tileSize*3 + 0.5*tileSize*sin(frameCount/6) ); 

                                        imageMode(CENTER);
                                        image(bonusImage, i * tileSize + tileSize/2, j * tileSize + tileSize/2);
                                }
                        }
                }
        }
}

