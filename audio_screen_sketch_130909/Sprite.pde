/*

 NOTE: REMOVED PARENT PAPPLET FROM THIS VERSION. ADD IT BACK AGAIN WHEN YOU INTEGRATE YOUR CODE.
 
 */


class Sprite {

        PImage spriteImage;
        float xPos, yPos;
        int xTile, yTile, toTile;
        int xNumTiles, yNumTiles;
        int xStartTile, yStartTile;
        int tileSize;
        float size;
        float defaultSpeed, speed;
        boolean isUp, isDown, isLeft, isRight;
        int animFrame, animSpeed;

        Sprite () {

                imageMode(CENTER);

                tileSize = 20;

                defaultSpeed = tileSize / 6;
                speed = defaultSpeed;
                size = tileSize * 2;
                
                xNumTiles = 59;
                yNumTiles = 20;
        }

        void display(boolean isUp_, boolean isDown_, boolean isLeft_, boolean isRight_) {
                isUp = isUp_; 
                isDown = isDown_; 
                isLeft = isLeft_; 
                isRight = isRight_;

                setPosition();
        }

        void setPosition() {
                xTile= int( xPos / tileSize); 
                yTile = int( yPos / tileSize);

                if (isUp) {
                        toTile = int( (yPos - tileSize) / tileSize );
                        if (toTile >= 0) {
                                if (game.isActiveTiles[xTile][toTile]) {
                                        xPos = xTile * tileSize + tileSize/2;
                                        yPos -= speed;
                                }
                        }
                }
                if (isDown) {
                        toTile = int ( (yPos + tileSize) / tileSize );
                        if (toTile < yNumTiles) {
                                if (game.isActiveTiles[xTile][toTile]) {
                                        xPos = xTile * tileSize + tileSize/2;
                                        yPos += speed;
                                }
                        }
                }
                if (isLeft) {
                        toTile = int( (xPos - tileSize) / tileSize );
                        if (toTile > 0) {
                                if (game.isActiveTiles[toTile][yTile]) {
                                        yPos = yTile * tileSize + tileSize/2;
                                        xPos -= speed;
                                }
                        }
                        if (toTile <= 0 && game.isTunnelTile[xTile][yTile]) {
                                xPos = xNumTiles * tileSize - tileSize/20;
                        }
                }

                if (isRight) {
                        toTile = int( (xPos + tileSize) / tileSize );
                        if (toTile < xNumTiles) {
                                if (game.isActiveTiles[toTile][yTile]) {
                                        yPos = yTile * tileSize + tileSize/2;
                                        xPos += speed;
                                }
                        }
                        if (toTile >= xNumTiles && game.isTunnelTile[xTile][yTile]) { 
                                xPos = tileSize/20;
                        }
                }
        }

        void goToStartPosition() {
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

        Pacman ( ) {

                super();
        }

        void init () {
                noOfLifes = 3;

                spriteImage = loadImage("pacmax.png");

//                for (int i = 0; i < xNumTiles; i++) {
//                        for (int j = 0; j < yNumTiles; j++) {
//                                if (game.isPacmanStartTile[i][j]) {
//                                        xPos = i * tileSize + tileSize/2;
//                                        yPos = j * tileSize + tileSize/2;
//
//                                        xStartTile = i;
//                                        yStartTile = j;
//                                }
//                        }
//                }
        }


        void update() {
                if (score.ghostMode == score.CHASE) { 
                        speed = 0.8 * defaultSpeed;
                } else if (score.ghostMode == score.FRIGHTENED) {
                        speed = defaultSpeed;
                }

                if (game.isTunnelTile[xTile][yTile]) { 
                        speed = 1.1 * defaultSpeed;
                }

                animateImages();
        }

        void animateImages() {
                imageMode(CENTER);

                animFrame++;
                animSpeed = int( frameRate / speed); // the number of frames for each animation
                //                println("animSpeed: " + animSpeed + "    " + "speed: " + speed + "    " + "frameRate: " + frameRate);

                if (isUp == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxU1.png");
                        } else {
                                spriteImage = loadImage("pacmaxU2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        image(spriteImage, xPos, yPos, size, 2*size);
                } else if (isDown == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxD1.png");
                        } else {
                                spriteImage = loadImage("pacmaxD2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        image(spriteImage, xPos, yPos, size, 2*size);
                } else if (isLeft == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxL1.png");
                        } else {
                                spriteImage = loadImage("pacmaxL2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        image(spriteImage, xPos, yPos, 2*size, size);
                } else if (isRight == true) {
                        if (animFrame <= animSpeed) {
                                spriteImage = loadImage("pacmaxR1.png");
                        } else {
                                spriteImage = loadImage("pacmaxR2.png");
                        }
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                        image(spriteImage, xPos, yPos, 2*size, size);
                } else { //when standing still
                        spriteImage = loadImage("pacmaxR1.png");
                        image(spriteImage, xPos, yPos, 2*size, size);
                }
        }
}


/**********************************
 *
 *        GHOST
 *
 ***********************************/

class Ghost extends Sprite {

        boolean isEaten;
        boolean isInGhostHouse;
        int dir;

        Ghost () {
                super();
        }

        void init() {
                spriteImage = loadImage("blinky.png");
                isEaten = isInGhostHouse = false;

                dir = 1;

//                for (int i = 0; i < xNumTiles; i++) {
//                        for (int j = 0; j < yNumTiles; j++) {
//                                if (game.isGhostStartTile[i][j]) {
//                                        xPos = i * tileSize + tileSize/2;
//                                        yPos = j * tileSize + tileSize/2;
//
//                                        xStartTile = i;
//                                        yStartTile = j;
//                                }
//                        }
//                }

                size *= 1.3; //default size of ghost as compared to 2 tile sizes
        }

        void update() {
                if (score.ghostMode == score.CHASE) {
                        speed = defaultSpeed * 1.1; //default speed of ghost
                }

                if (score.hasGhostModeChanged == true) {
                        if (score.ghostMode == score.CHASE) { 
                                spriteImage = loadImage("ghost.png");

                                speed = defaultSpeed * 1.1; //default speed of ghost

                                if (isEaten == true) { //emerging from ghost house after being eaten
                                        goToStartPosition();
                                        isEaten = false;
                                        isInGhostHouse = false;
                                }
                        } else if (score.ghostMode == score.FRIGHTENED && isInGhostHouse == false) {
                                spriteImage = loadImage("ghostFrightened.png");
                                speed = 0.6*defaultSpeed; //speed for frightened state
                        }
                        score.hasGhostModeChanged = false;
                }

                if (score.ghostMode == score.FRIGHTENED && isEaten == true && isInGhostHouse == false) { 
                        //ghost become eyes that are trapped in the ghosthouse which is assumed to be two tiles below the start tile of the ghost

                        spriteImage = loadImage("eye.png");

                        sendToGhostHouse();

                        isInGhostHouse = true;
                }

                if (isInGhostHouse == true) {

                        //disable keys
                        game.isGhostLeft = game.isGhostRight = game.isGhostUp = game.isGhostDown = false;

                        speed = defaultSpeed;

                        xPos += speed * dir;

                        if (xPos > (xStartTile + 3)*tileSize || xPos < (xStartTile - 2)*tileSize ) { //move within ghost house
                                dir *= -1;
                        }
                }

                if (game.isTunnelTile[xTile][yTile]) {
                        speed = 0.8 * defaultSpeed;
                }

                animateImages();
        }

        void sendToGhostHouse() {
                xPos = xStartTile * tileSize + tileSize/2;
                yPos = (yStartTile + 2) * tileSize + tileSize/2;
        }

        void animateImages() {
                imageMode(CENTER);

                animSpeed = int( frameRate / speed) ; // the number of frames for each animation
                //                println("animSpeed: " + animSpeed + "    " + "speed: " + speed + "    " + "frameRate: " + frameRate);

                if (isUp == true) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyU1Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyU1.png");
                                }
                        } else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyU2Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyU2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } else if (isDown == true) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyD1Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyD1.png");
                                }
                        } else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyD2Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyD2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } else if (isLeft == true) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyL1Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyL1.png");
                                }
                        } else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyL2Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyL2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } else if (isRight == true) {
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyR1Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyR1.png");
                                }
                        } else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyR2Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyR2.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                } else { //when standing still
                        if (animFrame++ <= animSpeed) {
                                if (score.ghostMode == score.FRIGHTENED) {
                                        spriteImage = loadImage("blinkyD1Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyD1.png");
                                }
                        } else {
                                if (score.ghostMode == score.FRIGHTENED && score.isGhostRecovering == false) {
                                        spriteImage = loadImage("blinkyD1Blue.png");
                                } else {
                                        spriteImage = loadImage("blinkyD1.png");
                                }
                        } 
                        if (animFrame > 2 * animSpeed) {
                                animFrame = 0;
                        }
                }

                image(spriteImage, xPos, yPos, size, size);
        }
}

