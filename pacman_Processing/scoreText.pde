class ScoreText {

        String scoreType;
        color textColor;
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

        void display(String scoreType, int xTile, int yTile) {

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

