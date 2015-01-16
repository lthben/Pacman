
class Data {

        String line;
        PrintWriter output;
        BufferedReader reader;

        Data () {
        }

        void write_to_file() {
                output = createWriter(maze.saveFileName);

                output.println(maze.xNumTiles);
                output.println(maze.yNumTiles);

                for (int j = 0; j < maze.yNumTiles; j++) {
                        for (int i = 0; i < maze.xNumTiles; i++) {
                                int tileID = maze.convertToTileID(i, j);
                                output.println(tileID + " " + maze.isActiveTiles[i][j] + " " + maze.hasEnergizer[i][j] + 
                                        " " + maze.hasDot[i][j] + " " + maze.isTunnelTile[i][j] + " " + maze.isPacmanStartTile[i][j] +
                                        " " + maze.isGhostStartTile[i][j] + " " + maze.isBonusTile[i][j]);
                        }
                }
                output.flush();
                output.close();
        }

        void read_from_file(String fileName) {
                reader = createReader(fileName);

                catch_exception();
                game.xNumTiles = int(line);
                catch_exception();
                game.yNumTiles = int(line);
                
                game.init();

                for (int k = 0; k < game.xNumTiles * game.yNumTiles; k++) {
                        catch_exception();
                        read_one_tile();
                }
        }
        
        void read_from_file() {
                reader = createReader(game.loadFileName);

                catch_exception();
                game.xNumTiles = int(line);
                catch_exception();
                game.yNumTiles = int(line);
                
                game.init();

                for (int k = 0; k < game.xNumTiles * game.yNumTiles; k++) {
                        catch_exception();
                        read_one_tile();
                }
        }

        void catch_exception() {
                try {
                        line = reader.readLine();
                }
                catch (IOException e) {
                        e.printStackTrace();
                        line = null;
                }
        }

        void read_one_tile() {
                if (line == null) {
                } else {

                        String[] pieces = split(line, ' ');
                        int j = int(pieces[0]) / game.xNumTiles;
                        int i = int(pieces[0]) % game.xNumTiles;

                        game.isActiveTiles[i][j] = boolean(pieces[1]);
                        game.hasEnergizer[i][j] = boolean(pieces[2]);
                        game.hasDot[i][j] = boolean(pieces[3]);
                        game.isTunnelTile[i][j] = boolean(pieces[4]);
                        game.isPacmanStartTile[i][j] = boolean(pieces[5]);
                        game.isGhostStartTile[i][j] = boolean(pieces[6]);
                        game.isBonusTile[i][j] = boolean(pieces[7]);
                }
        }
}

