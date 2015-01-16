/****************************************************
 *
 * audio clips: opening_song (4 sec), chase_mode, frightened_mode, pacman_death (1-2 sec), game_over (5 sec)
 * 
 * triggers: insert_coin, waka_waka, eating_bonus, eating_ghost, 
 *
 *****************************************************/


import ddf.minim.*;

AudioPlayer player;
AudioSample sample;

class Sound {

        Sound () {
                player = minim.loadFile("opening_song.wav");
                sample = minim.loadSample("insert_coin.mp3");
        }

        void play_opening_song() {
                player.pause();
                player = minim.loadFile("opening_song.wav");
                player.play();
        }

        void play_chase_mode() {
                player.pause();
                player = minim.loadFile("chase_mode.wav");
                player.loop();
        }
        
        void trigger_insert_coin() {
                sample = minim.loadSample("insert_coin");
                sample.trigger();
        }
}


void stop() {
        player.close();
        minim.stop();
        super.stop();
}

