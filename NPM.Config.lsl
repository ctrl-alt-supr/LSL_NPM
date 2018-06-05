
#ifndef NPM_CONSTANTS
    #define NPM_CONSTANTS
    #include "NPM.Constants"
#endif
//// MOVEMENT //////////////////////////////////////////////////////////////////////////
//How far is the task able to get from its home position.
#define CFG_MOV_DISTANCE 10.0
//Stabilishes the strenght this task is deflected by obstacles
#define CFG_MOV_DEFLECT 1.0
//How far away to look for parcel/region boundaries
#define CFG_MOV_LOOKAHEAD_BOUNDS 3.0
//How far away to look for ground collisions
#define CFG_MOV_LOOKAHEAD_GROUND 1.0
//Maximun height the task is allowed to be over the ground/water level
#define CFG_MOV_MAXHEIGHT 1.0
//Sets the places this task is able to move on
#define CFG_MOV_HABITAT CFG_MOVE_HABITAT_GROUND
//Minimun speed to consider the task stopped.
#define CFG_MOV_STOPSPEED 0.1
