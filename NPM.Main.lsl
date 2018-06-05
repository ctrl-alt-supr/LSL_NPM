#ifndef NPM_CONFIG
    #define NPM_CONFIG
    #include "NPM.Config"
#endif
//#ifndef NPM_PROTOCOL
//  #define NPM_PROTOCOL
//  #include "NPM.Protocol"
//#endif
#ifndef NPM_COMMON
    #define NPM_COMMON
    #include "NPM.Common"
#endif
vector gHome=ZERO_VECTOR;
vector gDestination=ZERO_VECTOR;
vector gOldPos=ZERO_VECTOR;
float gLastOld=-1;

updateOldPos(){
    if(gOldPos!=llGetPos){
        gOldPos=llGetPos();
        gLastOld=llGetTime();
    }
}

vector gShape=CFG_MOVE_SHAPE_FREE;
integer gOn=FALSE;
integer gRunning=FALSE;

default{
    state_entry(){
        llOwnerSay("reset");
        gHome=llGetPos();
        llSetTimerEvent(1.0);   //recalculte movement every second
    }
    on_rez(integer param){
        llSetRot(llEuler2Rot(<0,llFrand(PI-PI/2.0),llFrand(TWO_PI)>));
    }
    timer(){
        if(gOn && !gRunning){
            //If task should be started, do it
            gRunning=TRUE;
        }else if(!gOn && gRunning){
            //If task should be stopped, do it
            gRunning=FALSE;
            stopMovement();  
        }
        if(gRunning){
            updateOldPos();
            if(llGetTime()-gLastOld>=10){
                //The task has been stuck in the same position for a while now, make
                //something about it.
            }else{
                fixVelAndRot([CFG_MOV_HABITAT]);
                startMovement(pos+vel,rot,1.0);        //start moving and turning 
            }
        }
    }       
    touch_start(integer num){
        gOn = gOn^1;
    }
    not_at_target(){
        performMovement();
    }
}