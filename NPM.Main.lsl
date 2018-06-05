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
integer gNeedsNextDestination=FALSE;

updateOldPos(){
    if(gOldPos!=llGetPos()){
        gOldPos=llGetPos();
        gLastOld=llGetTime();
    }
}
checkDestination(){
    float dis=llVecDist(llGetPos(), gDestination);
    if(dis<=CFG_MOV_REACHED){
        gNeedsNextDestination=TRUE;
    }
}
toggleOnOff(){
    gOn = gOn^1;
}

string gShape=CFG_MOVE_SHAPE_SQUARE;
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
            if(llGetTime()-gLastOld>=30){
                //The task has been stuck in the same position for a while now, make
                //something about it. ToDo: Remove next line!!! 
                gLastOld=llGetTime();
            }else{
                checkDestination();
                if(gNeedsNextDestination || gDestination==ZERO_VECTOR){
                    gDestination=getVectorInside(gHome, gShape);
                    gNeedsNextDestination=FALSE;
                }
                //float pos=llGetPos();
                //llRotLookAt( llRotBetween( <0.0, 1.0, 0.0>, llVecNorm( <gDestination.x, gDestination.y, pos.z> - pos ) ), 1.0, 0.4 );
                list velAndRot=fixVelAndRot(gDestination, [CFG_MOV_HABITAT]);
                llOwnerSay((string)llList2Vector(velAndRot,0));
                startMovement(llGetPos()+llList2Vector(velAndRot,0),llList2Rot(velAndRot,1),1.0);        //start moving and turning 
            }
        }
    }       
    touch_start(integer num){
        toggleOnOff();
    }
    not_at_target(){
        performMovement();
    }
}