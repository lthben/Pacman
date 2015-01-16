static final int DRAW_ACTIVE_TILE = 1;
static final int DRAW_ENERGIZER = 2;
static final int DRAW_DOT = 3;
static final int DRAW_TUNNEL_TILE = 4;
static final int DRAW_PACMAN_START_TILE = 5;
static final int DRAW_GHOST_START_TILE = 6;
static final int DRAW_BONUS_TILE = 7;

EditorFrame ef;

class MazeEditor {

        int mazeDrawMode; 
        boolean isDrawActiveTile, isDrawEnergizer, isDrawDot, isDrawTunnelTile, isDrawPacmanStartTile, isDrawGhostStartTile, isDrawBonusTile;

        MazeEditor() {
                ef = addEditorFrame("maze editor", 450, 800); //create a new window for the GUI

                mazeDrawMode = DRAW_ACTIVE_TILE;
        }
}



EditorFrame addEditorFrame(String theName, int theWidth, int theHeight) {
        Frame f = new Frame(theName);
        EditorFrame p = new EditorFrame(this, theWidth, theHeight);
        f.add(p);
        p.init();
        f.setTitle(theName);
        f.setSize(p.w, p.h);
        f.setLocation(50, 50);
        f.setResizable(false);
        f.setVisible(true);
        return p;
}

public class EditorFrame extends PApplet {
        int w, h;

        Object parent;
        ControlP5 cp5;

        Toggle Tog1, Tog2, Tog3, Tog4, Tog5, Tog6, Tog7;

        public void setup() {
                size(w, h);
                frameRate(15);
                cp5 = new ControlP5(this); 

                //size of maze
                cp5.addTextlabel("size_of_maze").setText("Size of Maze").setPosition(25, 20).setColorValue(0xffFFff00).setFont(createFont("Georgia", 20));

                cp5.addTextfield("enter_num_of_horizontal_tiles").setPosition(30, 50).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);
                cp5.addTextfield("enter_num_of_vertical_tiles").setPosition(30, 120).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);

                cp5.addBang("generate").setPosition(300, 100).setSize(60, 60);

                //draw modes
                cp5.addTextlabel("draw_modes").setText("Draw Modes").setPosition(25, 270).setColorValue(0xffFFff00).setFont(createFont("Georgia", 20));

                Tog1 = cp5.addToggle("draw_Active_Tile").setSize(50, 50).setPosition(30, 300);
                Tog2 = cp5.addToggle("draw_Energizer").setSize(50, 50).setPosition(130, 300);
                Tog3 = cp5.addToggle("draw_Dot").setSize(50, 50).setPosition(230, 300);
                Tog4 = cp5.addToggle("draw_Tunnel_Tile").setSize(50, 50).setPosition(330, 300);
                Tog5 = cp5.addToggle("draw_Pacman").setSize(50, 50).setPosition(30, 380);
                Tog6 = cp5.addToggle("draw_Ghost").setSize(50, 50).setPosition(130, 380);
                Tog7 = cp5.addToggle("draw_Bonus").setSize(50, 50).setPosition(230, 380);

                cp5.addBang("clear_maze").setPosition(30, 470).setSize(60, 60).setColorForeground(0xffff0000);

                //file IO
                cp5.addTextlabel("file_IO").setText("Save / Load").setPosition(25, 570).setColorValue(0xffFFff00).setFont(createFont("Georgia", 20));

                cp5.addTextfield("enter_save_file_name").setPosition(30, 600).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);
                cp5.addTextfield("enter_load_file_name").setPosition(30, 680).setSize(200, 40).setFont(createFont("Georgia", 15)).setColorValue(0xffFFF705);

                cp5.addBang("save_to_file").setPosition(300, 600).setSize(40, 40);
                cp5.addBang("load_file").setPosition(300, 680).setSize(40, 40);
        }

        public void draw() {
                background(0);
        }


        private EditorFrame() {
        }

        public EditorFrame(Object theParent, int theWidth, int theHeight) {
                parent = theParent;
                w = theWidth;
                h = theHeight;
        }

        public ControlP5 control() {
                return cp5;
        }

        void enter_num_of_horizontal_tiles(String theText) {
                if (!mainMenu.isMazeGenerated) {
                        maze.xNumTiles = int(theText);
                        println("no. of horizontal tiles: " + maze.xNumTiles);
                }
        }

        void enter_num_of_vertical_tiles(String theText) {
                if (!mainMenu.isMazeGenerated) {
                        maze.yNumTiles = int(theText);
                        println("no. of vertical tiles: " + maze.yNumTiles);
                }
        }

        void generate() {
                if (maze.xNumTiles!=1 && maze.yNumTiles!=1) {
                        mainMenu.isMazeGenerated = true;
                        maze.init();
                } else {
                        println("please enter the no. of horizontal and vertical tiles");
                }
        }

        //error checking to ensure only one toggle is active at any one time
        void draw_Active_Tile(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_ACTIVE_TILE;

                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        void draw_Energizer(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_ENERGIZER;

                        Tog1.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        void draw_Dot(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_DOT;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog4.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        void draw_Tunnel_Tile(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_TUNNEL_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog5.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        void draw_Pacman(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_PACMAN_START_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false);
                        Tog6.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        void draw_Ghost(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_GHOST_START_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false);
                        Tog5.setState(false);
                        Tog7.setState(false);
                }
        }

        //error checking to ensure only one toggle is active at any one time
        void draw_Bonus(boolean b) {
                if (b) {
                        mazeEditor.mazeDrawMode = DRAW_BONUS_TILE;

                        Tog1.setState(false); 
                        Tog2.setState(false); 
                        Tog3.setState(false); 
                        Tog4.setState(false);
                        Tog5.setState(false);
                        Tog6.setState(false);
                }
        }

        void clear_maze() {
                maze.clearMaze();
                println("maze cleared");
        }

        void enter_save_file_name(String theText) {
                maze.saveFileName = theText;
                println("saveFileName: " + theText);
        }

        void enter_load_file_name(String theText) {
                game.loadFileName = theText;
                println("loadFileName: " + theText);
        }

        void save_to_file() {
                data.write_to_file();
                println("maze saved to: " + maze.saveFileName);
        }

        void load_file() {
                data.read_from_file();
                game.run();
                println(game.loadFileName + " loaded");
        }
}   

