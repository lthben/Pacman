
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
                isEaten = false;

                animSpeed = int( frameRate * 4 / speed); //set animation speed here
        }

        void update(boolean isUp_, boolean isDown_, boolean isLeft_, boolean isRight_) {
                isUp = isUp_; 
                isDown = isDown_; 
                isLeft = isLeft_; 
                isRight = isRight_;

                set_position();
        }

        void set_position() {
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
                        if (toTile < game.yNumTiles) {
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
                                xPos = (game.xNumTiles - 1) * tileSize + tileSize*19/20;
                        }
                }

                if (isRight) {
                        toTile = int( (xPos + tileSize) / tileSize );
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

        void go_to_start_position() {
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

        void init () {

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


        void display() {
                if (score.ghostMode == score.CHASE) { 
                        speed = 0.8 * defaultSpeed;
                } 
                else if (score.ghostMode == score.FRIGHTENED) {
                        speed = defaultSpeed * 1.1;
                }

                if (game.isTunnelTile[xTile][yTile]) { 
                        speed = 1.2 * defaultSpeed;
                }

                animate_images();
        }

        void animate_images() {
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

        void init() {
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

                size = 2.5*tileSize; //ghost has to look comparable in size to pacman
        }

        void display() {
                if (score.ghostMode == score.CHASE) {
                        speed = defaultSpeed * 1.05; //default speed of ghost
                }                

                if (score.hasGhostModeChanged == true) {
                        if (score.ghostMode == score.CHASE) { 

                                mySound.play_chase_mode_song();

                                speed = defaultSpeed * 1.05; //default speed of ghost

                                if (isEaten == true) { //emerging from ghost house after being eaten
                                        go_to_start_position();
                                        isEaten = false;
                                        isInGhostHouse = false;
                                }
                        } 
                        else if (score.ghostMode == score.FRIGHTENED && isInGhostHouse == false) {

                                mySound.play_frightened_mode_song();

                                speed = 0.5*defaultSpeed; //speed for frightened state
                        }
                        score.hasGhostModeChanged = false;
                }

                if (score.ghostMode == score.FRIGHTENED && isEaten == true && isInGhostHouse == false) {                 

                        send_to_ghost_house();

                        isInGhostHouse = true;
                }                

                if (isInGhostHouse == true) {

                        speed = defaultSpeed;

                        xPos += speed * dir;

                        //movement within ghost house
                        if (xPos > (xStartTile + 3)*tileSize) {
                                xPos = (xStartTile + 3)*tileSize;
                                dir *= -1;
                        }
                        if (xPos < (xStartTile - 2)*tileSize ) {
                                xPos = (xStartTile - 2)*tileSize; 
                                dir *= -1;
                        }
                } 
                else {
                        isGhostKeyInputAllowed = true;
                }

                if (game.isTunnelTile[xTile][yTile]) {
                        speed = 0.6 * defaultSpeed;
                }

                animate_images();
        }

        void send_to_ghost_house() {
                xPos = xStartTile * tileSize + tileSize/2;
                yPos = (yStartTile + 2) * tileSize + tileSize/2;
        }

        void animate_images() {
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

