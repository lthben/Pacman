
Minim minim;
Sound mySound;
Screen myScreen;

PFont myFont;
int displayW, displayH;

Game game;

PImage backgroundImage, bonusImage, energizerImage;


void setup() {
        size(displayWidth, displayHeight);
        
        backgroundImage = loadImage("grid.png");
        bonusImage = loadImage("maxusBonus.png");
        energizerImage = loadImage("energizer.png");

        minim = new Minim(this);

        game = new Game();
        
        mySound = new Sound();
        myScreen = new Screen();

        myFont = loadFont("Optimus-32.vlw");
        textFont(myFont, 32);

        displayW = width;
        displayH = height;     
        
}



void draw() {
        background(0);

        myScreen.run();
}


void keyPressed() {
        switch(key) {
                case('a'): 
                case('A'):
                mySound.play_opening_song();
                break;
                case('s'): 
                case('S'):
                mySound.play_chase_mode();
                break;
                case('d'): 
                case('D'):
                sample.trigger();
                break;
                case('z'):
                myScreen.screenMode = myScreen.DISPLAY_TITLE_SCREEN;
                break;
                case('x'):
                myScreen.screenMode = myScreen.DISPLAY_HIGHSCORE_SCREEN;
                break;
        }
}

