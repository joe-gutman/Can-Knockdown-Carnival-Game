rotation endrot;

integer comchannel;

vector startpos;
vector endpos;
vector cansize;

default
    {
        on_rez(integer param)
            {
                if (param == 0)
                    {
                        //Do nothing
                    }
                else
                    {
                        llSetPrimitiveParams([PRIM_PHYSICS, TRUE]);
                        startpos = llGetPos();
                        comchannel = param;
                        //llSay(0,(string)comchannel);
                        //llSetTimerEvent(timeout);
                        llListen(comchannel, "", NULL_KEY, ""); 
                    }
            }
        listen(integer channel, string name, key id, string message)
            {
                if (message == "calculate score")
                {      
                    endrot = llGetRot();
                    endpos = llGetPos();
                    cansize = llGetScale();
                    if (endpos.z <= (startpos.z -(cansize.z*.5)) || (llFabs(endrot.x) >= 0.1) )
                        {
                            //llOwnerSay( llGetObjectName() + " has fallen");
                            llShout(comchannel, "score");                       
                        }
                    else
                        {
                            //llOwnerSay( llGetObjectName() + " has not fallen");   
                            llShout(comchannel, "noscore");  
                        }

                }
            else if (message == "delete")
                {
                    llDie();
                }  
            } 
    }