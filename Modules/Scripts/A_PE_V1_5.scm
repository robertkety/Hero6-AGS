AGSScriptModule    Akumayo This update features an option to run the emmision continuously, resulting in an easier interface. Akumayo's Particle Engine 1.5 �-  // Main script for module 'Akumayo's Particle Engine'

/*

Most commentary will be found in the repeatedly_excecute,
where it is needed.

*/

//==========================================================

#DEFINE Particles_To_Use 1000

Particles game_particle[Particles_To_Use];  //Creates particles with a user definable integer

//==========================================================

int particles_alive = 0;

//==========================================================

int particle_remove_x_min = 0;
int particle_remove_x_max = 320;
int particle_remove_y_min = 0;
int particle_remove_y_max = 200;

//==========================================================

bool deviate_x = false;
bool deviate_y = false;

//==========================================================

int fade_out_resistance;

//==========================================================

bool continuous_movement_going = false;

//==========================================================

int cont_particle_x;
int cont_particle_y;
int cont_life_min;
int cont_life_max;
int cont_amount_to_emit;
int cont_amount_spawned_so_far;
int cont_i_s;
int cont_a_s;
int cont_i_t;
int cont_a_t;
int cont_t_f;
int cont_f_r;
int cont_x_g;
int cont_y_g;
int cont_g_r_i;
int cont_g_r_a;
int cont_s_i;
int cont_s_a;

//==========================================================

int particles_on_screen = 0;

//==========================================================

function Toggle_Particle_Deviation(int deviate_on_x_axis, int deviate_on_y_axis) {
  deviate_x = deviate_on_x_axis;
  deviate_y = deviate_on_y_axis;
}

//==========================================================

function Particle_Removal_Boundries(int removal_x_min, int removal_x_max, int removal_y_min, int removal_y_max) {
  particle_remove_x_min = removal_x_min;
  particle_remove_x_max = removal_x_max;
  particle_remove_y_min = removal_y_min;
  particle_remove_y_max = removal_y_max;
}

//==========================================================

function Remove_All_Particles() {
  int removal_counter = 0;
  while (removal_counter <= Particles_To_Use - 1) {
    if (game_particle[removal_counter].alive == true) {
      game_particle[removal_counter].alive = false;
      particles_on_screen --;
    }
    removal_counter ++;
  }
}

//==========================================================

function Edit_Particle_Values(int min_speed,int max_speed,int min_trans,int max_trans, int trans_fadeout, int fadeout_resistance,int x_grav,int y_grav,int grav_resistance_min, int grav_resistance_max,int spriteslot_min,int spriteslot_max) {
  
  cont_i_s = min_speed;
  cont_a_s = max_speed;
  cont_i_t = min_trans;
  cont_a_t = max_trans;
  cont_t_f = trans_fadeout;
  cont_f_r = fadeout_resistance;
  cont_x_g = x_grav;
  cont_y_g = y_grav;
  cont_g_r_i = grav_resistance_min;
  cont_g_r_a = grav_resistance_max;
  cont_s_i = spriteslot_min;
  cont_s_a = spriteslot_max;
  
  bool Emit_Particles_Void = false;
  if (fadeout_resistance < 0) Emit_Particles_Void = true;
  fade_out_resistance = fadeout_resistance;
  if (grav_resistance_min < 0 || grav_resistance_max < 0) Emit_Particles_Void = true;
  if (grav_resistance_min > grav_resistance_max) Emit_Particles_Void = true;
  if (min_speed > max_speed) Emit_Particles_Void = true;
  if (min_trans > max_trans) Emit_Particles_Void = true;
  if (spriteslot_min > spriteslot_max) Emit_Particles_Void = true;
  if (Emit_Particles_Void == false) {
    int var_set_counter = 0;
    while (var_set_counter <= Particles_To_Use - 1) {
      if (game_particle[var_set_counter].alive == false) {
        game_particle[var_set_counter].speed = Random(max_speed-min_speed) + min_speed;
        game_particle[var_set_counter].trans = Random(max_trans-min_trans) + min_trans;
        game_particle[var_set_counter].X_Gravity = x_grav;
        game_particle[var_set_counter].Y_Gravity = y_grav;
        game_particle[var_set_counter].fadeout = trans_fadeout;
        game_particle[var_set_counter].sprite = Random(spriteslot_max-spriteslot_min) + spriteslot_min;
        game_particle[var_set_counter].grav_resistance = Random(grav_resistance_max-grav_resistance_min) + grav_resistance_min;
      }
      var_set_counter ++;
    }
  }
  else
    AbortGame("The Emit_Particles function called invalid parameters where some minimum was greater than a maximum, or where some resistance was less than 0.  Please repair the script, or contact the game's author about this problem.");
}

//==========================================================

function Single_Emit_Particles(int particle_x, int particle_y, int life_min,int life_max, int amount_to_emit) {
  int var_set_counter = 0;
  int amount_spawned_so_far = 0;
  bool Emit_Particles_Void = false;
  if (life_min > life_max) Emit_Particles_Void = true;
  if (Emit_Particles_Void == false) {
    while (var_set_counter <= Particles_To_Use - 1) {
      if (game_particle[var_set_counter].alive == false && amount_spawned_so_far < amount_to_emit) {
        game_particle[var_set_counter].x_pos = particle_x;
        game_particle[var_set_counter].y_pos = particle_y;
        game_particle[var_set_counter].lifespan = Random(life_max-life_min) + life_min;
        game_particle[var_set_counter].alive = true;
        particles_on_screen ++;
        amount_spawned_so_far ++;
      }
      var_set_counter ++;
    }
  }
  else
    AbortGame("The Emit_Particles function called invalid parameters where some minimum was greater than a maximum.  Please repair the script, or contact the game's author about this problem.");
}

//==========================================================

function Continuous_Emit_Particles_Go(int particle_x, int particle_y, int life_min, int life_max, int amount_on_screen) {
  cont_particle_x = particle_x;
  cont_particle_y = particle_y;
  cont_life_min = life_min;
  cont_life_max = life_max;
  cont_amount_to_emit = amount_on_screen;
  cont_amount_spawned_so_far = 0;
  continuous_movement_going = true;
}

//==========================================================

function Continuous_Emit_Particles_Stop() {
  continuous_movement_going = false;
}

//==========================================================

function repeatedly_execute() {
  
//----------------------------------------------------------
  
  //This part of the script handles the continous release
  //of particles.
  
  if (continuous_movement_going == true) {
    Edit_Particle_Values(cont_i_s, cont_a_s, cont_i_t, cont_a_t, cont_t_f, cont_f_r, cont_x_g, cont_y_g, cont_g_r_i, cont_g_r_a, cont_s_i, cont_s_a);
    int var_set_counter = 0;
    bool Emit_Particles_Void = false;
    if (cont_life_min > cont_life_max) Emit_Particles_Void = true;
    if (Emit_Particles_Void == false) {
      while (var_set_counter <= Particles_To_Use - 1) {
        if (game_particle[var_set_counter].alive == false && particles_on_screen < cont_amount_to_emit) {
          game_particle[var_set_counter].x_pos = cont_particle_x;
          game_particle[var_set_counter].y_pos = cont_particle_y;
          game_particle[var_set_counter].lifespan = Random(cont_life_max-cont_life_min) + cont_life_min;
          game_particle[var_set_counter].alive = true;
          particles_on_screen ++;
          cont_amount_spawned_so_far ++;
        }
        var_set_counter ++;
      }
    }
    else
      AbortGame("The Emit_Particles function called invalid parameters where some minimum was greater than a maximum.  Please repair the script, or contact the game's author about this problem.");
  }

//----------------------------------------------------------
  
  //This part restores the old screen if there are any
  //particles at all left on it, so that it is neither
  //leaving them there, nor constantly wiping the screen
  
  int rp_counter = 0;
  
  if (particles_alive == 1)
    RawRestoreScreen();

  while (rp_counter <= Particles_To_Use - 1) {
    if (game_particle[rp_counter].alive == true) {
      particles_alive = 1;
      rp_counter = Particles_To_Use - 1;
    }
    else particles_alive = 0;
    rp_counter ++;
  }

//----------------------------------------------------------
  
  //Now begins the updating of all the particles... how
  //fun ._.
  
  rp_counter = 0;

  while (rp_counter <= Particles_To_Use - 1) {
    if (game_particle[rp_counter].alive == true) {
      
//----------------------------------------------------------

  //Firstly, positions are updated using speed and gravity

      if (game_particle[rp_counter].X_Gravity > 0)  game_particle[rp_counter].x_pos += game_particle[rp_counter].X_Gravity - game_particle[rp_counter].speed;
      if (game_particle[rp_counter].X_Gravity < 0)  game_particle[rp_counter].x_pos += game_particle[rp_counter].X_Gravity + game_particle[rp_counter].speed;
      if (deviate_x == true) {
        if (Random(1))
          game_particle[rp_counter].x_pos += game_particle[rp_counter].X_Gravity - game_particle[rp_counter].speed;
        else
          game_particle[rp_counter].x_pos += game_particle[rp_counter].X_Gravity + game_particle[rp_counter].speed;
      }
      if (game_particle[rp_counter].Y_Gravity > 0)  game_particle[rp_counter].y_pos += game_particle[rp_counter].Y_Gravity - game_particle[rp_counter].speed;
      if (game_particle[rp_counter].Y_Gravity < 0)  game_particle[rp_counter].y_pos += game_particle[rp_counter].Y_Gravity + game_particle[rp_counter].speed;
      if (deviate_y == true) {
        if (Random(1))
          game_particle[rp_counter].y_pos += game_particle[rp_counter].Y_Gravity - game_particle[rp_counter].speed;
        else
          game_particle[rp_counter].y_pos += game_particle[rp_counter].Y_Gravity + game_particle[rp_counter].speed;
      }
      if (!Random(game_particle[rp_counter].grav_resistance))  game_particle[rp_counter].speed --;        

//----------------------------------------------------------

  //Next, transparencies are updated to their new states

      if (game_particle[rp_counter].fadeout > game_particle[rp_counter].trans) {
        if (!Random(fade_out_resistance))
          game_particle[rp_counter].trans ++;
      }
      
      game_particle[rp_counter].lifespan --;    

//----------------------------------------------------------

  //The particle is then drawn onto the screen:

      RawDrawImageTransparent(game_particle[rp_counter].x_pos, game_particle[rp_counter].y_pos, game_particle[rp_counter].sprite, game_particle[rp_counter].trans);
    }

//----------------------------------------------------------

  //Another check, this one to see if any particles are
  //out of life

    if (game_particle[rp_counter].lifespan <= 0 && game_particle[rp_counter].alive == true) {
      game_particle[rp_counter].alive = false;
      particles_on_screen --;
    }
    
//----------------------------------------------------------
  
  //This check removes particles that have left the user-
  //defined boundries

    if (game_particle[rp_counter].x_pos < particle_remove_x_min || game_particle[rp_counter].x_pos > particle_remove_x_max || game_particle[rp_counter].y_pos < particle_remove_y_min || game_particle[rp_counter].y_pos > particle_remove_y_max) {
      if (game_particle[rp_counter].alive == true) {
        particles_on_screen --;
        game_particle[rp_counter].alive = false;
      }
    }
      
//----------------------------------------------------------
  
  //Then we set the counter up, and the whole thing goes
  //again!

    rp_counter ++;
  }
} "  // Script header for module 'Akumayo's Particle Engine'
struct Particles {
  int lifespan;
  bool alive;
  int speed;
  int trans;
  int fadeout;
  int Y_Gravity;
  int X_Gravity;
  int sprite;
  int x_pos;
  int y_pos;
  int grav_resistance;
};

import function Remove_All_Particles();
import function Edit_Particle_Values(int min_speed,int max_speed,int min_trans,int max_trans, int trans_fadeout, int fadeout_resistance,int x_grav,int y_grav,int grav_resistance_min, int grav_resistance_max,int spriteslot_min,int spriteslot_max);
import function Single_Emit_Particles(int particle_x,int particle_y, int life_min,int life_max, int amount_to_emit);
import function Particle_Removal_Boundries(int removal_x_min, int removal_x_max, int removal_y_min, int removal_y_max);
import function Toggle_Particle_Deviation(int deviate_on_x_axis, int deviate_on_y_axis);
import function Continuous_Emit_Particles_Go(int particle_x, int particle_y, int life_min, int life_max, int amount_on_screen);
import function Continuous_Emit_Particles_Stop(); �;}�        ej��