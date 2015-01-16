MazeFrame mf;

class Maze {

        boolean[][] isActiveTiles, hasEnergizer, hasDot, isTunnelTile, isPacmanStartTile, isGhostStartTile, isBonusTile;  

        int xNumTiles, yNumTiles, tileSize;
        
        String saveFileName;

        Maze() {
                xNumTiles = yNumTiles = tileSize = 1;
        }

        void init() {
                isActiveTiles = new boolean[xNumTiles][yNumTiles];
                hasEnergizer = new boolean[xNumTiles][yNumTiles];
                hasDot = new boolean[xNumTiles][yNumTiles];
                isTunnelTile = new boolean[xNumTiles][yNumTiles];
                isPacmanStartTile = new boolean[xNumTiles][yNumTiles];
                isGhostStartTile = new boolean[xNumTiles][yNumTiles];
                isBonusTile = new boolean[xNumTiles][yNumTiles];

                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                isActiveTiles[i][j] = false;
                                hasEnergizer[i][j] = false;
                                hasDot[i][j] = false;
                                isTunnelTile[i][j] = false;
                                isPacmanStartTile[i][j] = false;
                                isGhostStartTile[i][j] = false;
                                isBonusTile[i][j] = false;
                        }
                }

                setTileSize();

                mf = addMazeFrame("maze", tileSize*xNumTiles + 1, tileSize*yNumTiles + 23); //create a new window for the GUI. Size includes the border.
        }

        void display() {
        }

        void setTileSize() {
                if (xNumTiles > yNumTiles) tileSize = int ( (0.8 * displayW) / xNumTiles );
                if (yNumTiles >= xNumTiles ) tileSize = int ( (0.8 * displayH) / yNumTiles );
        }

        int getTileID(int xPos, int yPos) {
                int xTile, yTile;
                xTile = xPos / tileSize;
                yTile = yPos / tileSize;

                return convertToTileID(xTile, yTile);
        }

        int convertToTileID(int xTile, int yTile) {
                return xNumTiles * yTile + xTile;
        }
        

        void clearMaze() {
                for (int i = 0; i < xNumTiles; i++) {
                        for (int j = 0; j < yNumTiles; j++) {
                                isActiveTiles[i][j] = false;
                                hasEnergizer[i][j] = false;
                                hasDot[i][j] = false;
                                isTunnelTile[i][j] = false;
                                isPacmanStartTile[i][j] = false;
                                isBonusTile[i][j] = false;
                                isGhostStartTile[i][j] = false;
                        }
                }
        }
}

MazeFrame addMazeFrame(String theName, int theWidth, int theHeight) {
        Frame f = new Frame(theName);
        MazeFrame p = new MazeFrame(this, theWidth, theHeight);
        f.add(p);
        p.init();
        f.setTitle(theName);
        f.setSize(p.w, p.h);
        f.setLocation(600, 50);
        f.setResizable(false);
        f.setVisible(true);
        return p;
}

public class MazeFrame extends PApplet {
        int w, h;

        Object parent;
        ControlP5 cp5;

        public void setup() {
                size(w, h);
                frameRate(15);
                cp5 = new ControlP5(this);
        }

        public void draw() {
                background(0);

                // draw grid
                for (int i = 0; i <= maze.xNumTiles; i++) {
                        stroke(100);
                        line(i * maze.tileSize, 0, i * maze.tileSize, maze.yNumTiles * maze.tileSize);
                }

                for (int j = 0; j <= maze.yNumTiles; j++) {
                        stroke(100);
                        line(0, j * maze.tileSize, maze.xNumTiles * maze.tileSize, j * maze.tileSize);
                }

                // draw maze
                for (int i = 0; i < maze.xNumTiles; i++) {
                        for (int j = 0; j < maze.yNumTiles; j++) {
                                if (maze.isActiveTiles[i][j]) {
                                        fill(100);
                                        rect(i * maze.tileSize, j * maze.tileSize, maze.tileSize, maze.tileSize);
                                }
                                if (maze.hasEnergizer[i][j]) {
                                        fill(255); 
                                        noStroke();
                                        ellipse(i * maze.tileSize + maze.tileSize/2, j * maze.tileSize + maze.tileSize/2, maze.tileSize, maze.tileSize);
                                }
                                if (maze.hasDot[i][j]) {
                                        fill(255, 255, 0);
                                        ellipse(i * maze.tileSize + maze.tileSize/2, j * maze.tileSize + maze.tileSize/2, maze.tileSize/4, maze.tileSize/4);
                                }
                                if (maze.isTunnelTile[i][j]) {
                                        fill(255, 0, 180, 100);
                                        rect(i * maze.tileSize, j * maze.tileSize, maze.tileSize, maze.tileSize);
                                }
                                if (maze.isPacmanStartTile[i][j]) {
                                        fill(255, 255, 0);
                                        textSize(maze.tileSize); 
                                        textAlign(CENTER, TOP);
                                        text("P", i * maze.tileSize + maze.tileSize/2, j * maze.tileSize);
                                }
                                if (maze.isGhostStartTile[i][j]) {
                                        fill(105, 0, 255);
                                        textSize(maze.tileSize); 
                                        textAlign(CENTER, TOP);
                                        text("G", i * maze.tileSize + maze.tileSize/2, j * maze.tileSize);
                                }
                                if (maze.isBonusTile[i][j]) {
                                        fill(255, 0, 68);
                                        textSize(maze.tileSize); 
                                        textAlign(CENTER, TOP);
                                        text("B", i * maze.tileSize + maze.tileSize/2, j * maze.tileSize);
                                }
                        }
                }
        }


        private MazeFrame() {
        }

        public MazeFrame(Object theParent, int theWidth, int theHeight) {
                parent = theParent;
                w = theWidth;
                h = theHeight;
        }

        public ControlP5 control() {
                return cp5;
        }

        void mousePressed(MouseEvent e) {

                int xTile; 
                int yTile;
                xTile = mouseX / maze.tileSize; 
                yTile = mouseY / maze.tileSize;

                if (mainMenu.isMazeGenerated) {
                        switch (mazeEditor.mazeDrawMode) {
                                case(DRAW_ACTIVE_TILE):
                                maze.isActiveTiles[xTile][yTile] = !maze.isActiveTiles[xTile][yTile];
                                break;

                                case(DRAW_ENERGIZER):
                                maze.hasEnergizer[xTile][yTile] = !maze.hasEnergizer[xTile][yTile];
                                break;

                                case(DRAW_DOT):
                                maze.hasDot[xTile][yTile] = !maze.hasDot[xTile][yTile];
                                break;

                                case(DRAW_TUNNEL_TILE):
                                maze.isTunnelTile[xTile][yTile] = !maze.isTunnelTile[xTile][yTile];
                                break;

                                case(DRAW_PACMAN_START_TILE):
                                maze.isPacmanStartTile[xTile][yTile] = !maze.isPacmanStartTile[xTile][yTile];
                                break;

                                case(DRAW_GHOST_START_TILE):
                                maze.isGhostStartTile[xTile][yTile] = !maze.isGhostStartTile[xTile][yTile];
                                break;

                                case(DRAW_BONUS_TILE):
                                maze.isBonusTile[xTile][yTile] = !maze.isBonusTile[xTile][yTile];
                                break;
                        }
                }
        }
}   

