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


        void run() {
                
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

        void initialise_title_screen() {
                pacmax.xPos = 0;
                pacmax.yPos = displayH/2;

                blinky.xPos = -0.2*displayW;
                blinky.yPos = displayH/2;

                pacmax.speed = pacmax.defaultSpeed;
                blinky.speed = 1.15*blinky.defaultSpeed;

                dir = 1;

                score.ghostMode = score.CHASE;

                pacmax.isRight = true; pacman.isLeft = false;
                blinky.isRight = true; blinky.isLeft = false;
        }


        void display_title_screen() {
                // top half of screen: title 
                // bottom half of screen: switches between "insert coin" and "chase animations"
                parent.textAlign(CENTER);
                parent.textFont(myFont);
                parent.textSize(displayH/10);
                parent.fill(255, 255, 0);
                parent.text("PACMAN", 0.5*displayW, 0.3*displayH);

                parent.image(maxusLogoImage, 0.5*displayW, 0.4*displayH);

                parent.textFont(myFont);
                parent.textSize(tileSize);
                parent.fill(180);
                parent.text("2013", 0.5*displayW, 0.45*displayH);

                display_chase_animation();

                display_insert_coin_text();
        }

        void display_chase_animation() {

                pacmax.xPos += pacmax.speed * dir;
                blinky.xPos += blinky.speed * dir;

                pacmax.yPos = 0.6*displayH;
                blinky.yPos = pacmax.yPos;

                pacmax.animate_images();
                blinky.animate_images();

                if (pacmax.xPos > 1.2*displayW) {

                        pacmax.isRight = false;
                        blinky.isRight = false;

                        pacmax.isLeft = true;
                        blinky.isLeft = true;

                        pacmax.speed = 1.15*pacmax.defaultSpeed;
                        blinky.speed = pacmax.defaultSpeed;

                        dir *= -1;

                        score.ghostMode = score.FRIGHTENED;

                        pacmax.xPos = 1.2*displayW;
                        blinky.xPos = displayW;
                } 
                else if (pacmax.xPos < 0) {

                        pacmax.isLeft = false;
                        blinky.isLeft = false;

                        pacmax.isRight = true;
                        blinky.isRight = true;

                        pacmax.speed = pacmax.defaultSpeed;
                        blinky.speed = 1.15*blinky.defaultSpeed;

                        dir *= -1;

                        score.ghostMode = score.CHASE;

                        pacmax.xPos = 0;
                        blinky.xPos = -0.2*displayW;
                }
        }

        void display_insert_coin_text() {
                animFrame++;

                animSpeed = int(frameRate); 

                if (animFrame <= animSpeed) {
                        parent.textFont(myFont);
                        parent.textAlign(CENTER);
                        parent.fill(255);
                        parent.textSize(displayH/20);
                        parent.text("INSERT COIN", 0.5*displayW, 0.9*displayH);
                } 
                else {
                }
                if (animFrame > animSpeed * 2) {
                        animFrame = 0;
                }
        }

        void display_high_score_screen() {
                // fake highScore screen

                        parent.textAlign(CENTER);
                parent.textFont(myFont);

                parent.textSize(displayH/12.5); 
                parent.fill(255);
                parent.text("Highscores", 0.5*displayW, 0.15*displayH);

                parent.textAlign(LEFT);

                parent.textSize(displayH/18.75);
                parent.fill(255, 255, 0);
                parent.text("RANK", 0.1*displayW, 0.3*displayH); 
                parent.text("NAME", 0.3*displayW, 0.3*displayH); 
                parent.text("SCORE", 0.6*displayW, 0.3*displayH);

                parent.textSize(displayH/22);
                parent.fill(255);
                parent.text("1ST", 0.1*displayW, 0.35*displayH); 
                parent.text("MAXUS", 0.3*displayW, 0.35*displayH); 
                parent.text("10,000 PTS   [PERFECT!]", 0.6*displayW, 0.35*displayH);

                parent.fill(180);
                parent.text("2ND", 0.1*displayW, 0.4*displayH); 
                parent.text("METALWORKS", 0.3*displayW, 0.4*displayH); 
                parent.text("10,000 PTS   [PERFECT!]", 0.6*displayW, 0.4*displayH);

                parent.fill(255);
                parent.text("3RD", 0.1*displayW, 0.45*displayH); 
                parent.text("TOM", 0.3*displayW, 0.45*displayH); 
                parent.text("9,600 PTS", 0.6*displayW, 0.45*displayH);

                parent.fill(180);
                parent.text("4TH", 0.1*displayW, 0.5*displayH); 
                parent.text("ADAM", 0.3*displayW, 0.5*displayH); 
                parent.text("9,200 PTS", 0.6*displayW, 0.5*displayH);

                parent.fill(255);
                parent.text("5TH", 0.1*displayW, 0.55*displayH); 
                parent.text("BEN", 0.3*displayW, 0.55*displayH); 
                parent.text("8,200 PTS", 0.6*displayW, 0.55*displayH);

                parent.fill(180);
                parent.text("6TH", 0.1*displayW, 0.6*displayH); 
                parent.text("HARESH", 0.3*displayW, 0.6*displayH); 
                parent.text("7,800 PTS", 0.6*displayW, 0.6*displayH);

                parent.fill(255);
                parent.text("7TH", 0.1*displayW, 0.65*displayH); 
                parent.text("MITHRU", 0.3*displayW, 0.65*displayH); 
                parent.text("7,020 PTS", 0.6*displayW, 0.65*displayH);

                parent.fill(180);
                parent.text("8TH", 0.1*displayW, 0.7*displayH); 
                parent.text("NICO", 0.3*displayW, 0.7*displayH); 
                parent.text("6,880 PTS", 0.6*displayW, 0.7*displayH);

                parent.fill(255);
                parent.text("9TH", 0.1*displayW, 0.75*displayH); 
                parent.text("ROLLEN", 0.3*displayW, 0.75*displayH); 
                parent.text("6,400 PTS", 0.6*displayW, 0.75*displayH);

                parent.fill(180);
                parent.text("10TH", 0.1*displayW, 0.8*displayH); 
                parent.text("UPESH", 0.3*displayW, 0.8*displayH); 
                parent.text("5,800 PTS", 0.6*displayW, 0.8*displayH);

                display_insert_coin_text();
        }

        void display_char_intro_screen() {
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

        void display_score_sys_screen() {
                // explain point system

                parent.fill(255, 255, 0);
                parent.ellipse(2*displayW/7, 3*displayH/15, tileSize/2 + 0.05*tileSize*sin(frameCount/8), tileSize/2 + 0.05*tileSize*sin(frameCount/8));

                parent.textFont(myFont);
                parent.textSize(displayH/20);

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Dot - 20 PTS", 3*displayW/7, 3*displayH/15);

                parent.noStroke();
                parent.fill(255, 50);
                parent.ellipse(2*displayW/7, 5*displayH/15, tileSize + 0.1*tileSize*sin(frameCount/6), tileSize + 0.1*tileSize*sin(frameCount/6) ); 
                parent.imageMode(CENTER);
                parent.image(energizerImage, 2*displayW/7, 5*displayH/15);

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Energizer - 100 PTS", 3*displayW/7, 5*displayH/15);

                blinky.xPos = 2*displayW/7;
                blinky.yPos = 7*displayH/15;

                blinky.isRight = true;
                blinky.size = game.tileSize*2.5;
                score.ghostMode = score.FRIGHTENED;
                blinky.animate_images();

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Vulnerable Blinky - 400 PTS", 3*displayW/7, 7*displayH/15);

                parent.noStroke();
                parent.fill(255, 50);
                parent.ellipse(2*displayW/7, 9*displayH/15, tileSize*3 + 0.3*tileSize*sin(frameCount/4), tileSize*3 + 0.3*tileSize*sin(frameCount/4) ); 
                parent.image(bonusImage, 2*displayW/7, 9*displayH/15);

                parent.fill(255);
                parent.textAlign(LEFT, CENTER);
                parent.text("Maxus Bonus - 800 PTS", 3*displayW/7, 9*displayH/15);

                display_insert_coin_text();
        }
}

