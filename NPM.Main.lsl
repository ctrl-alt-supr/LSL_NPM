#ifndef PET_CONFIG
    #define PET_CONFIG
    #include "NPM.Config"
#endif
#ifndef PET_PROTOCOL
    #define PET_PROTOCOL
    //#include "NPM.Protocol"
#endif
#ifndef PET_COMMON
    #define PET_COMMON
    #include "NPM.Common"
#endif
vector gHome=ZERO_VECTOR;
vector gShape=CFG_MOVE_SHAPE_FREE;

default
{
    state_entry()
    {
        llOwnerSay("reset");
        //llParticleSystem(params);
        gHome=llGetPos();
        llSetTimerEvent(1.0);   //recalculte movement every second
    }
    
    on_rez(integer param)
    {       //turn to a random direction on rez
        llSetRot(llEuler2Rot(<0,llFrand(PI-PI/2.0),llFrand(TWO_PI)>));
    }
    
    timer()     //every second calculate a new direction to turn
    {
        fixVelAndRot();
        startMovement(pos+vel,rot,1.0);        //start moving and turning 
    }
            //once not_at_target is running, even the build dialog cannot change the position
            //or rotation without it being changed back. So I added this touch to stop the
            //critter so I could move it or rotate it, then touch start it moving again.
    touch_start(integer num)
    {
        if ((run = run^1) ==0)      //toggle the run flag
        {
            llSetTimerEvent(0);
            stopMovement();               //demonstrate how to use SFstop!
            //llParticleSystem([]);   //turn off the smoke while stopped.
            llOwnerSay("stopped");
        }
        else
        {
            llSetTimerEvent(1.0);       //the next call to SFrame in timer will start it up again
            //llParticleSystem(params);
            llOwnerSay("running");
        }
    }
        //The whole thing fails to work if you don't have a not_at_target event with 
        //a call to SFnotat (or a copy of the code from SFnotat) inside it.
        //(I forget every other time!)
    not_at_target()
    {
        performMovement();
    }
}