import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

class Screen {

        int screenMode;
        final static int DISPLAY_TITLE_SCREEN = 1;
        final static int DISPLAY_HIGHSCORE_SCREEN = 2;

        int animFrame, animSpeed;

        Pacman pacmax;
        Ghost blinky;

        int dir;

        Screen() {
                screenMode = DISPLAY_TITLE_SCREEN;

                pacmax = new Pacman();
                blinky = new Ghost();

                pacmax.xPos = 0;
                pacmax.yPos = height/2;

                blinky.xPos = -0.2*width;
                blinky.yPos = height/2;
                blinky.size *= 1.3;

                pacmax.speed = pacmax.defaultSpeed;
                blinky.speed = 1.15*blinky.defaultSpeed;

                dir = 1;

                score.ghostMode = score.CHASE;

                pacmax.isRight = true;
                blinky.isRight = true;
        }


        void run() {

                //                println(frameRate);
                switch(screenMode) {
                        case(DISPLAY_TITLE_SCREEN):
                        display_title_screen();
                        break;       
                        case(DISPLAY_HIGHSCORE_SCREEN):
                        display_high_score_screen();
                        break;
                }
        }


        void display_title_screen() {
                // top half of screen: title 
                // bottom half of screen: switches between "insert coin" and "chase animations"
                textAlign(CENTER);
                textSize(96);
                fill(255, 255, 0);
                text("PACMAN", 0.5*width, 0.3*height);

                textSize(28);
                fill(130);
                text("Maxus", 0.5*width, 0.4*height);
                text("2013", 0.5*width, 0.45*height);

                display_insert_coin_text();

                display_chase_animation();
        }

        void display_insert_coin_text() {
                animFrame++;

                animSpeed = int(frameRate); 

                if (animFrame <= animSpeed) {
                        fill(255);
                        textSize(42);
                        text("INSERT COIN", 0.5*width, 0.8*height);
                } else {
                }
                if (animFrame > 2*animSpeed) {
                        animFrame = 0;
                }
        }

        void display_chase_animation() {

                pacmax.xPos += pacmax.speed * dir;
                blinky.xPos += blinky.speed * dir;

                pacmax.yPos = 0.6*height;
                blinky.yPos = pacmax.yPos;

                pacmax.animateImages();
                blinky.animateImages();

                if (pacmax.xPos > 1.2*width) {

                        pacmax.isRight = false;
                        blinky.isRight = false;

                        pacmax.isLeft = true;
                        blinky.isLeft = true;

                        pacmax.speed = 1.15*pacmax.defaultSpeed;
                        blinky.speed = pacmax.defaultSpeed;

                        dir *= -1;

                        score.ghostMode = score.FRIGHTENED;
                        
                        pacmax.xPos = 1.2*width;
                        blinky.xPos = width;
                        
                } else if (pacmax.xPos < 0) {

                        pacmax.isLeft = false;
                        blinky.isLeft = false;

                        pacmax.isRight = true;
                        blinky.isRight = true;
                        
                        pacmax.speed = pacmax.defaultSpeed;
                        blinky.speed = 1.15*blinky.defaultSpeed;

                        dir *= -1;

                        score.ghostMode = score.CHASE;

                        pacmax.xPos = 0;
                        blinky.xPos = -0.2*width;
                }
        }

        void display_high_score_screen() {
                // fake highScore screen
                textAlign(CENTER);
                textSize(72);
                fill(255, 255, 0);
                text("Highscores", 0.5*width, 0.1*height);
        }

        void display_game_start_screen() {
                //screen overlay
                //opening_song.wav - 4 sec
                //"get ready"
        }

        void display_game_screen() {
                // put in original code here
                // displays game mode screen
                // chase_mode.wav, frightened_mode.wav
        }

        void display_pacman_dies_screen() {
                //pac_man goes transparent
                //pacman_death.wav - 2 sec
        }

        void display_round_start_screen() {
                // screen overlay
                // "get ready"
        }

        void display_game_over_screen () {
                //screen overlay
                //game_over.wav - 5 sec
                //announce winner and score
        }
}


boolean sketchFullScreen() {
        //        return false;
        return true;
}

