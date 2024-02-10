string game_name = "Ball Throwing Game 2.3"; //The name of the object that rezzes this ball.
integer comchannel;

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
                        llSetPrimitiveParams(
                            [PRIM_PHYSICS, TRUE,
                            PRIM_TEMP_ON_REZ, TRUE]);
                        comchannel = param;
                        //llSay(0,(string)comchannel);
                        //llSetTimerEvent(timeout);
                        llListen(comchannel, "", NULL_KEY, ""); 
                        llSetTimerEvent(2.5);
                    }
    }
    no_sensor()
        {
            llDie();
        }
    listen(integer channel, string name, key id, string message)
        {
            if (message == "delete")
                {
                    llDie();
                }  
        } 
    timer()
        {
            llSensor(game_name, "", SCRIPTED, 20.0, PI);
        }

}