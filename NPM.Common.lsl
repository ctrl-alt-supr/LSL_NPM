
#ifndef NPM_CONSTANTS
    #define NPM_CONSTANTS
    #include "NPM.Constants"
#endif
//Variables used for the interpolation of position and rotation:
vector      SF_spos;            //start position
rotation    SF_srot;            //starting rotation
float       SF_stime;           //starting time
vector      SF_epos;            //ending position
rotation    SF_erot;            //ending rotation
float       SF_seconds;         //time to move that distance
float       SF_last;            //last time moved (for limiting number of moves)
integer     SF_target=-1;       //handle of last target position

integer isRestricted(vector pos){
    //Check if pos is out of simulator bounds.
    if (pos.x<=0 || pos.x>=256 || pos.y<=0 || pos.y>=256)
        return FALSE;
    //Check if pos is above groud.
    if (pos.z<llGround(pos-llGetPos()))
        return FALSE;    
    //Check if pos is still in the same parcel as the one task is in right now.      
    key curpar = llList2Key(llGetParcelDetails(llGetPos(),[PARCEL_DETAILS_ID]),0);
    key nxtpar = llList2Key(llGetParcelDetails(pos,       [PARCEL_DETAILS_ID]),0);
    if (curpar!=nxtpar)
        return FALSE;
        
    integer allowedGround=isHabitatAllowed(CFG_MOVE_HABITAT_GROUND);
    integer allowedAir=isHabitatAllowed(CFG_MOVE_HABITAT_AIR);
    integer allowedWater=isHabitatAllowed(CFG_MOVE_HABITAT_WATER);
    if(!allowedAir){
        float gnd=llGround(ZERO_VECTOR);
        float wtr=llWater(ZERO_VECTOR);
        if(allowedGround && !allowedWater){
            
        }if(allowedWater && !allowedGround){
            
        }
    }
    return TRUE;
}

//Starts moving towards a position with a rotation
startMovement(vector pos,rotation rot, float seconds)
{
    //record the current position, rotation and time
    SF_spos=llGetPos();
    SF_srot=llGetRot();
    SF_stime=llGetTime();
    SF_last=SF_stime;
    //save the requested position, rotation and time
    SF_epos=pos;
    SF_erot=rot;
    //llAxes2Rot returns two kinds of solutions, I need to detect
    //this and flip one of them.
    rotation t=<SF_srot.x-SF_erot.x,SF_srot.y-SF_erot.y,SF_srot.z-SF_erot.z,SF_srot.s-SF_erot.s>;
    if ((t.x*t.x + t.y*t.y + t.z*t.z + t.s*t.x)>0.5)
        SF_erot = <-SF_erot.x,-SF_erot.y,-SF_erot.z,-SF_erot.s>;
    SF_seconds=seconds;
            //reset the "target" position past our ending position
    llTargetRemove(SF_target);    //forget the last one    
    SF_target=llTarget(pos+(pos-SF_spos)*3.0,0.1);    //set one past where we will go
}
//Stops moving
stopMovement()        //call this to stop the motion
{
    llTargetRemove(SF_target);    //stop the non_at_target calls from happening
    SF_target=-1;
}
//Interpolates movement since startMovement is called until the destination is reached 
performMovement() 
{
    if (SF_target== -1) return;     //prevetnts last event in queue from causing problems
    float time=llGetTime();
    time = (time-SF_stime)/SF_seconds;    //calculate the percent of the time so far
    if (time>1.0)        //when the time is up,
    {
        llTargetRemove(SF_target);    //stop interpolating, force a move to the end position
        SF_target=-1;
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_POSITION,SF_epos,PRIM_ROTATION,SF_erot]);
        return;
    }
    float emit= 1.0-time;       //time backwards is emit (that is a joke ;-)
    vector pos=SF_epos*time+SF_spos*emit;        //interpolate the position
        //interpolate the rotaton. Use "nlerp" since that is good enough
    rotation rot = <
        SF_erot.x*time+SF_srot.x*emit,
        SF_erot.y*time+SF_srot.y*emit,
        SF_erot.z*time+SF_srot.z*emit,
        SF_erot.s*time+SF_srot.s*emit    //nlerp means use linear interpolation, then
    >;
                                        //normalize the rotation
    emit = llSqrt(rot.x*rot.x+rot.y*rot.y+rot.z*rot.z+rot.s*rot.s);
    rot = <rot.x/emit,rot.y/emit,rot.z/emit,rot.s/emit>;
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_POSITION,pos,PRIM_ROTATION,rot]);
}

vector getVectorInside(vector origin, string shape) {
    iPos=origin;
    float driftRange = llFrand(CFG_MOV_DISTANCE);
    float a = llFrand(TWO_PI);
    float b = llFrand(TWO_PI);
    float c = llFrand(PI);
    if(shape == CFG_MOVE_SHAPE_SQUARE) return <iPos.x + driftRange, iPos.y + llFrand(CFG_MOV_DISTANCE), iPos.z>;
    if(shape == CFG_MOVE_SHAPE_CIRCLE) return <iPos.x + driftRange * llCos(a), iPos.y + driftRange * llSin(b), iPos.z>;
    if(shape == CFG_MOVE_SHAPE_SPHERE) return iPos + <driftRange * llCos(a) * llCos(b), driftRange * llCos(a) * llSin(b), driftRange * llSin(a)>;
    if(shape == CFG_MOVE_SHAPE_UPPERHEMISPHERE) return iPos + <driftRange * llCos(a) * llCos(b), driftRange * llCos(a) * llSin(b), driftRange * llSin(c)>;
    if(shape == CFG_MOVE_SHAPE_LOWERHEMISPHERE) return iPos + <driftRange * llCos(a) * llCos(b), driftRange * llCos(a) * llSin(b), -driftRange * llSin(c)>;
    if(shape == CFG_MOVE_SHAPE_ELIPSOID) return iPos + <driftRange * llCos(a) * llCos(b), llFrand(CFG_MOV_DISTANCE) * llCos(a) * llSin(b), driftRange * llSin(a)>;
    if(shape == CFG_MOVE_SHAPE_UPPERHEMIELIPSOID) return iPos + <driftRange * llCos(a) * llCos(b), llFrand(CFG_MOV_DISTANCE) * llCos(a) * llSin(b), driftRange * llSin(c)>;
    if(shape == CFG_MOVE_SHAPE_LOWERHEMIELIPSOID) return iPos + <driftRange * llCos(a) * llCos(b), llFrand(CFG_MOV_DISTANCE) * llCos(a) * llSin(b), -driftRange * llSin(c)>;
    return iPos;
}
list isHabitatAllowed(string habitat){
    list allowedHabitats=[CFG_MOV_HABITAT];
    integer foundGround=llListFindList(allowedHabitats,[habitat]);
    return (foundGround>-1);
}
vector adjustHeightToGround(){
    vector vTarget = llGetPos();
    vector vScale = llGetScale();
    vTarget.z = llGround( ZERO_VECTOR )+vScale.z/2;
    llSetRegionPos(vTarget);
    return vTarget;
}
vector adjustHeightToWater(){
    vector vTarget = llGetPos();
    vector vScale = llGetScale();
    vTarget.z = llWater( ZERO_VECTOR )+vScale.z/2;
    llSetRegionPos(vTarget);
    return vTarget;
}
vector adjustHeightToGroundOrWater(){
    vector vTarget = llGetPos();
    vector vScale = llGetScale();
    vTarget.z = llGround( ZERO_VECTOR )+vScale.z/2;
    float fWaterLevel = llWater( ZERO_VECTOR );
    if( vTarget.z < fWaterLevel )
        vTarget.z = fWaterLevel;
    llSetRegionPos(vTarget);
    return vTarget;
}
list fixVelAndRot(list habitats){
    list toRet=[ZERO_VECTOR, ZERO_ROTATION];
    integer allowedGround=isHabitatAllowed(CFG_MOVE_HABITAT_GROUND);
    integer allowedAir=isHabitatAllowed(CFG_MOVE_HABITAT_AIR);
    integer allowedWater=isHabitatAllowed(CFG_MOVE_HABITAT_WATER);
    
    vector pos=llGetPos();       //get my current position
    rotation rot=llGetRot();       //and rotation

    if(!allowedAir && !allowedWater){
        //If the task should be always grounded, we try to mantain all rotations but the z at 0, so no extrange spins are
        //performed
        rot=<0.0,0.0,rot.z,rot.s>;
        llSetRot(rot);
        //The position is adjusted so the task touches the ground in this case
        pos=adjustHeightToGround();
    }
    vector vel=<1,0,0>*rot;      //use my direction as velocity

        //here are the RULES that give this critter behavior:
        //first (four) rule(s): Avoid the edges of the sim and parcel.
    vector xvel=llVecNorm(<vel.x,0,0>);   //get orthagonal components of velocity
    vector yvel=llVecNorm(<0,vel.y,0>);
    
    if (isRestricted(pos+CFG_MOV_LOOKAHEAD_BOUNDS*xvel))     //so you can pong off the edges of the sim
    {
        vel -= CFG_MOV_DEFLECT*xvel;    //slow down as you approach X edge.
        //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
    }
    if (isRestricted(pos-CFG_MOV_LOOKAHEAD_BOUNDS*xvel))   //checking both sides makes me
    {
        vel += CFG_MOV_DEFLECT*xvel;         //accelerate away from walls
        //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
    }
    if (isRestricted(pos+CFG_MOV_LOOKAHEAD_BOUNDS*yvel))     //do the same thing in Y
    {
        vel -= CFG_MOV_DEFLECT*yvel;
        //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
    }
    if (isRestricted(pos-CFG_MOV_LOOKAHEAD_BOUNDS*yvel)){
        vel += CFG_MOV_DEFLECT*yvel;
        //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
    }
        

        //I could use LOOKAHEAD to avoid running into the water (I do that for the
        //ground below) but I thought it would be fun to allow this flyer to hit the
        //water and THEN accelerate it up to fly back out.
    float wat=llWater(ZERO_VECTOR);
    if (pos.z<wat)         //after I have already dipped into the water,
        vel += <0,0,1>*CFG_MOV_DEFLECT;             //accelerate back up
    
        //if you don't have some sort of CFG_MOV_MAXHEIGHT test, the critter would fly up
        //and never come back. I turn back at CFG_MOV_MAXHEIGHT above the land OR water.
        //(if you just tested land, you would have trouble when the water was
        //over CFG_MOV_MAXHEIGHT deep)
    float gnd=llGround(ZERO_VECTOR);
    if (gnd>wat)
        wat=gnd;        //use the max of water and ground for height limit test
    if (pos.z>(wat+CFG_MOV_MAXHEIGHT))  //if I get too high
        vel -= <0,0,1>*CFG_MOV_DEFLECT;     //accelerate back down

        //When the critter gets within LOOKAHEAD meters of the ground, I start
        //accelerating back up. Using the ground normal makes it turn sideways
        //away from cliffs instead of just turning up.
    vector npos=pos+vel;        //next position
    if ((npos.z-LOOKAHEAD)<gnd)     //if my next position is too close to the ground
        vel += llGroundNormal(vel)*CFG_MOV_DEFLECT;     //CFG_MOV_DEFLECT away from the ground normal

        //I'm limiting this critter to 1 meter per second, you could go faster
        //but beware, llAxes2Rot requires unit vectors! You would have to
        //calculate a separate vector that is the normalized velocity and use that below.
    vel = llVecNorm(vel);       //limit my velocity to 1m/sec
    
        //here I convert the velocity vector into a rotation. These steps result in the
        //prim always rotating to keep the head "up". Actually the local Y axis is always
        //parallell to the XY plane, the local Z axis is allowed to rotate away from
        //straight up to turn the nose in the direction of movement.
    vector lft=llVecNorm(<0,0,1>%vel);
    rot = llAxes2Rot(vel,lft,vel%lft);  //calculate new rotation in direction of vel

        //The test may invalate each other so I do another test here and 
        //try to do something smarter to avoid getting stuck.
    if (isRestricted(pos+vel))        //final test: If I'm still going out of bounds,
    {
        if (llVecMag(lft)<0.5)      //detect Gymbol lock!
            lft=<0,1,0>;            //and make a hard left turn in this unusual case.
        vel = llVecNorm(vel+lft*(llFrand(2.0)-1.0));  //randomly turn left or right
        lft=llVecNorm(<0,0,1>%vel);             //to try to get out of edge lock
        rot = llAxes2Rot(vel,lft,vel%lft);      //re-calc the rotation
        vel=ZERO_VECTOR;            //stop and wait for rotation to turn me
    }

    toRet=[vel, rot];
    return toRet;
}


list ORIGINAL_fixVelAndRot(integer habitat){
        list toRet=[ZERO_VECTOR, ZERO_ROTATION];
        //FindGroundOrWater();
        vector pos=llGetPos();       //get my current position
        rotation rot=llGetRot();       //and rotation
        rot=<0.0,0.0,rot.z,rot.s>;
        llSetRot(rot);
        
        vector vel=<1,0,0>*rot;      //use my direction as velocity

            //here are the RULES that give this critter behavior:
            //first (four) rule(s): Avoid the edges of the sim and parcel.
        vector xvel=llVecNorm(<vel.x,0,0>);   //get orthagonal components of velocity
        vector yvel=llVecNorm(<0,vel.y,0>);
        
        integer isOk=!isRestricted(pos);
        llOwnerSay("Current loc is "+(string)isOk);

        if (isRestricted(pos+CFG_MOV_LOOKAHEAD_BOUNDS*xvel))     //so you can pong off the edges of the sim
        {
            vel -= CFG_MOV_DEFLECT*xvel;    //slow down as you approach X edge.
            //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
        }
        if (isRestricted(pos-CFG_MOV_LOOKAHEAD_BOUNDS*xvel))   //checking both sides makes me
        {
            vel += CFG_MOV_DEFLECT*xvel;         //accelerate away from walls
            //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
        }
        if (isRestricted(pos+CFG_MOV_LOOKAHEAD_BOUNDS*yvel))     //do the same thing in Y
        {
           vel -= CFG_MOV_DEFLECT*yvel;
           //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
        }
        if (isRestricted(pos-CFG_MOV_LOOKAHEAD_BOUNDS*yvel)){
            vel += CFG_MOV_DEFLECT*yvel;
            //llSetRot(llGetRot() * llEuler2Rot(<0,0,90 * flag * DEG_TO_RAD>));
        }
            

            //I could use LOOKAHEAD to avoid running into the water (I do that for the
            //ground below) but I thought it would be fun to allow this flyer to hit the
            //water and THEN accelerate it up to fly back out.
        float wat=llWater(ZERO_VECTOR);
        if (pos.z<wat)         //after I have already dipped into the water,
            vel += <0,0,1>*CFG_MOV_DEFLECT;             //accelerate back up
        
            //if you don't have some sort of CFG_MOV_MAXHEIGHT test, the critter would fly up
            //and never come back. I turn back at CFG_MOV_MAXHEIGHT above the land OR water.
            //(if you just tested land, you would have trouble when the water was
            //over CFG_MOV_MAXHEIGHT deep)
        float gnd=llGround(ZERO_VECTOR);
        if (gnd>wat)
            wat=gnd;        //use the max of water and ground for height limit test
        if (pos.z>(wat+CFG_MOV_MAXHEIGHT))  //if I get too high
            vel -= <0,0,1>*CFG_MOV_DEFLECT;     //accelerate back down

            //When the critter gets within CFG_MOV_LOOKAHEAD_GROUND meters of the ground, I start
            //accelerating back up. Using the ground normal makes it turn sideways
            //away from cliffs instead of just turning up.
        vector npos=pos+vel;        //next position
        if ((npos.z-CFG_MOV_LOOKAHEAD_GROUND)<gnd)     //if my next position is too close to the ground
            vel += llGroundNormal(vel)*CFG_MOV_DEFLECT;     //CFG_MOV_DEFLECT away from the ground normal

            //I'm limiting this critter to 1 meter per second, you could go faster
            //but beware, llAxes2Rot requires unit vectors! You would have to
            //calculate a separate vector that is the normalized velocity and use that below.
        vel = llVecNorm(vel);       //limit my velocity to 1m/sec
        
            //here I convert the velocity vector into a rotation. These steps result in the
            //prim always rotating to keep the head "up". Actually the local Y axis is always
            //parallell to the XY plane, the local Z axis is allowed to rotate away from
            //straight up to turn the nose in the direction of movement.
        vector lft=llVecNorm(<0,0,1>%vel);
        rot = llAxes2Rot(vel,lft,vel%lft);  //calculate new rotation in direction of vel

            //The test may invalate each other so I do another test here and 
            //try to do something smarter to avoid getting stuck.
        if (isRestricted(pos+vel))        //final test: If I'm still going out of bounds,
        {
            if (llVecMag(lft)<0.5)      //detect Gymbol lock!
                lft=<0,1,0>;            //and make a hard left turn in this unusual case.
            vel = llVecNorm(vel+lft*(llFrand(2.0)-1.0));  //randomly turn left or right
            lft=llVecNorm(<0,0,1>%vel);             //to try to get out of edge lock
            rot = llAxes2Rot(vel,lft,vel%lft);      //re-calc the rotation
            vel=ZERO_VECTOR;            //stop and wait for rotation to turn me
        }

        toRet=[vel, rot];
        return toRet;
}