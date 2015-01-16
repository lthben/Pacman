ControlP5 cp;

class MainMenu {

        boolean isMazeGenerated;

        MainMenu() {
                cp.addTextlabel("welcome_msg").setText("PACMAX by Maxus").setFont(createFont("Optimus", 48)).setPosition(25, 20).setColorValue(0xffFFff00);
                cp.addBang("maze_editor").setPosition(75, 100).setSize(150, 150);
                cp.addBang("load_game").setPosition(375, 100).setSize(150, 150);              
        }    

        void display() {
        }
}

void maze_editor() { //when button is pressed
        mazeEditor = new MazeEditor();
        not_testing();
}

void load_game() {//when button is pressed
        testing();
}

void testing() {
        data.read_from_file("maxus2.txt");
        game.run();
}

void not_testing() {
        mainMenu.display();

        if (mainMenu.isMazeGenerated) {
                maze.display();
        }
}

boolean sketchFullScreen() {
//     return false;
   return true;
}

