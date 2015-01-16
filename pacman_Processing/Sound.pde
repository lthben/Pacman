/****************************************************
 *
 * audio clips: opening_song (5 sec), chase_mode, frightened_mode, pacman_death (2 sec), game_over (5 sec)
 * 
 * triggers: insert_coin, eating_dot, eating_bonus, eating_ghost, 
 *
 *****************************************************/


import ddf.minim.*;

Playable player1, player2, player3, player4, player5;
AudioSample sample1, sample2, sample3, sample4, sample5;

class Sound {
        
        boolean hasPlayedOpeningSong, hasPlayedGameOverSong, hasPlayedPacmanDeathSong;

        Sound () {

                player1 = minim.loadFile("opening_song.wav");
                player2 = minim.loadFile("chase_mode.wav");
                player3 = minim.loadFile("frightened_mode.wav");
                player4 = minim.loadFile("pacman_death.wav");
                player5 = minim.loadFile("game_over.wav");

                sample1 = minim.loadSample("insert_coin.mp3");
                sample2 = minim.loadSample("eating_dot.wav");
                sample3 = minim.loadSample("eating_bonus.wav");
                sample4 = minim.loadSample("eating_ghost.wav");
                sample5 = minim.loadSample("eating_energizer.wav");
                
                hasPlayedOpeningSong = hasPlayedGameOverSong = hasPlayedPacmanDeathSong = false;
        }
        
        

        void play_opening_song() {
                player2.pause(); 
                player3.pause(); 
                player4.pause(); 
                player5.pause();
                player1.play();
        }
        
        void rewind_opening_song() {
                 player1.rewind();       
        }

        void play_chase_mode_song() {
                player1.pause(); 
                player3.pause(); 
                player4.pause(); 
                player5.pause();
                player2.loop();
        }

        void play_frightened_mode_song() {
                player2.pause(); 
                player1.pause(); 
                player4.pause(); 
                player5.pause();
                player3.loop();
        }

        void play_pacman_death_song() {
                player1.pause(); 
                player2.pause(); 
                player3.pause(); 
                player5.pause();
                player4.play();
        }
        
        void rewind_pacman_death_song(){
                player4.rewind();
        }

        void play_game_over_song() {
                player1.pause();
                player2.pause();
                player3.pause();
                player4.pause();
                player5.play();
        }
        
        void rewind_game_over_song() {
                player5.rewind();
        }

        void trigger_insert_coin_sound() {
                sample1.trigger();
        }

        void trigger_eating_dot_sound() {
                sample5.trigger();
        }

        void trigger_eating_bonus_sound() {
                sample3.trigger();
        }

        void trigger_eating_ghost_sound() {
                sample4.trigger();
        }

        void trigger_eating_energizer_sound() {
                sample3.trigger();
        }
}


void stop() {
        sample1.close();
        sample2.close();
        sample3.close();
        sample4.close();
        sample5.close();
        minim.stop();
        super.stop();
}

