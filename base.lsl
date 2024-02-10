//Setting To Edit--------------------------------------------------------------------
float canheight = 0.37; //The height of the can that will be used in the game.
float canwidth = 0.36168; //The width of the can that will be used in the game.
float gametimelimit = 300; // How long a game will last, in seconds, before resetting.
float menutimelimit = 60; //How long a user can open a menu, in seconds, before the menu will timeout.
float permissionstimelimit = 60; //How long, in seconds, that the game will wait for player permissions before canceling 
float chargespeed = .25; //How fast, in seconds, the game charges speed

integer ballcountlimit = 3; //How many balls a player will have.
integer maxspeed = 9; //The fastest speed that the ball will go.
integer playerdistancemax = 5; //The distance, in meters, that the player has to be away from the game to throw a ball.

//Messages that will be said by the game:
string newplayermessage = /*avatar name*/ " is now playing";
string startmessage = "Game has started. You have 3 balls. Stand 5 meters away. Go into mouselook to aim. While in mouselook click and hold to throw a ball.";
string gameinprogress = "Game is in progress. Please wait and try again later.";
string tooclosemessage = "Sorry, you are too close. You must be 5 meters away before throwing.";
string privatetimeoutmessage = " has timed out. Please close menu and try again.";
string publictimeoutmessage = " has timed out and is now open to play.";
string permissionsmessage = "Allow permissions for the game to start.";
string nopermissionsmessage = "Game Canceled. You must accept permissions to play. Please try again.";
string gameovermessage = "Game has finished and is now open for play.";
string prizemessage = "You've won a prize! Please accept your "; /* + prizename*/ 

string ballname = "[BBS] Ball Prim Example"; //Name of the ball object
string canname = "[BBS] Can Prim Example"; //Name of the can object

list gifts = ["Gift A Prim Example", "Gift B Prim Example"]; //List of inventory items that will be randomly given as gifts when score is max.


//Do Not Edit-----------------------------------------------------
key playerkey = "";
key toucher = "";

string playername;

vector tableheight; 
float playerdistance;
float calculatescoretimelimit = 5;

integer i;
integer tooclose;
integer touchcount;
integer ballcount;
integer cancount;
integer score;
integer calculatescore = FALSE;
integer gametimeout = FALSE;
integer menutimeout = FALSE;
integer permissionstimeout = FALSE;
integer speed;
integer comchannel;
integer listenhandle;
integer Key2Chan(key ID) 
    {
        return 0x80000000 | (integer)("0x"+(string)ID);
    }

list canposition;
list playerpos;

rezcans()
    {
        tableheight = llGetScale();
        float tableheightmod = (tableheight.z + canheight) * .5;
        float canrowtwo = canheight;
        float canrowthree = canheight * 2;
        float canrowfour = canheight * 3;
        float cancenterleft = canwidth * .5;
        float cancenterright = -(canwidth * .5);
        float canrowedgeleft = (canwidth * .5) + canwidth;
        float canrowedgeright = -((canwidth * .5) + canwidth);

        vector canpositionmod = <0.0, 0.0, tableheightmod>; //Height between table and first row.

        list canpos =[
            <0.0, cancenterleft, 0.0>,
            <0.0, cancenterright, 0.0>,
            <0.0, canrowedgeleft, 0.0>,
            <0.0, canrowedgeright, 0.0>,
            <0.0, 0.0, canrowtwo>,
            <0.0, canwidth, canrowtwo>,
            <0.0, -canwidth, canrowtwo>,
            <0.0, cancenterleft, canrowthree>,
            <0.0, cancenterright, canrowthree>,
            <0.0, 0.0, canrowfour>];

        llShout(comchannel, "delete");
        integer i;
        while (i < llGetListLength(canpos))    
            {
                llRezObject(canname, llGetPos() + (llList2Vector(canpos, i) + canpositionmod)*llGetRot(), ZERO_VECTOR, llGetRot(), comchannel);
                i++;    
            }
    }

shootball()
    {
            playerpos = llGetObjectDetails(playerkey, [OBJECT_POS, OBJECT_ROT]);
            rotation Rot = llGetCameraRot();
            llRezAtRoot(ballname, llGetCameraPos() + <1, 0.0, 0.0>*Rot, (speed*1.7)*llRot2Fwd(Rot), Rot, comchannel);
            llSay(0, "Ball speed was " + (string)speed);
            speed = 0;
    }

sayto_player(string message)
    {
        llRegionSayTo(playerkey,0, message);
    }

sayto_nonplayer(key id, string message)
    {
        llRegionSayTo(id, 0, message);
    }

gameover()
    {
        if (score == 1)
            {
                llSay(0, playername + " has knocked down " + (string)score + " can.");
            }
        else
            {
                llSay(0, playername + " has knocked down " + (string)score + " cans.");
            }
        llSay(0, gameovermessage);
        llSay(comchannel, "delete");
        
        if (score == 10)
            {
                
                i += llRound(llFrand(llGetListLength(gifts)));
                string prizename = llList2String(gifts, i);
                llRegionSayTo(playerkey, 0, prizemessage + prizename);
                llGiveInventory(playerkey, prizename);
            }
        llResetScript();
    }

//------------------------------------------------------------------
default
    {
        state_entry()
            {
                comchannel = Key2Chan(llGetKey());
                llShout(comchannel, "delete");
                listenhandle = llListen(comchannel, "", NULL_KEY, "");

            }
        touch_start(integer index)
            {
                if (playerkey == llDetectedKey(0))
                    {
                        llDialog(playerkey, "What would you like to do?", ["Quit","Cancel"], comchannel);
                        gametimeout = TRUE;
                        llSetTimerEvent(gametimelimit);
                    }
                else if (playerkey == "" && toucher == "")
                    {
                        toucher = llDetectedKey(0);
                        llDialog(toucher, "What would you like to do?", ["Play","Cancel"], comchannel);
                        menutimeout = TRUE;
                        llSetTimerEvent(menutimelimit);
                    }
                else if (playerkey != "")
                    {
                        sayto_nonplayer(llDetectedKey(0), gameinprogress);
                    }            
            }
        run_time_permissions(integer perm)
            {
                if (PERMISSION_TAKE_CONTROLS && PERMISSION_TRACK_CAMERA && perm)
                    {
                        rezcans();
                        permissionstimeout = FALSE;
                        llSetTimerEvent(gametimelimit);
                        gametimeout = TRUE;
                        llTakeControls(CONTROL_ML_LBUTTON, TRUE, TRUE);
                        sayto_player(startmessage);
                    }    
                else 
                    {
                        sayto_player(nopermissionsmessage);
                        llSay(0, gameovermessage);
                    }
            }
        control(key id, integer held, integer change)
            {
                playerpos = llGetObjectDetails(playerkey, [OBJECT_POS, OBJECT_ROT]);
                float playerdistance = llVecDist(llList2Vector(playerpos, 0), llGetPos());
                if (id == playerkey && CONTROL_ML_LBUTTON && change && playerdistance > playerdistancemax && i != 1 && ballcount != ballcountlimit)
                    {
                        if (touchcount == 0)
                            {
                                i = 0;
                                gametimeout = FALSE;
                                llSetTimerEvent(chargespeed);
                                touchcount ++;
                            }
                        else if (touchcount == 1)
                            {
                                shootball();
                                llSetTimerEvent(0);
                                touchcount = 0;
                                gametimeout = TRUE;
                                llSetTimerEvent(gametimelimit);
                                llRegionSayTo(playerkey, 0, "Ball " + (string)(ballcount + 1));
                                ballcount++;
                                if (ballcount >= ballcountlimit)
                                    {
                                        llRegionSayTo(playerkey, 0, "Score is being calculated.");
                                        gametimeout = FALSE;
                                        calculatescore = TRUE;
                                        llSetTimerEvent(calculatescoretimelimit);
                                    }
                            }
                    }
                else if (CONTROL_ML_LBUTTON && change && playerdistance < playerdistancemax )
                    {                        
                        i++;

                        if (i == 1)
                            {
                                sayto_player(tooclosemessage);
                            }
                        else
                            {
                                i = 0;
                                touchcount = 0;
                                gametimeout = TRUE;
                                llSetTimerEvent(gametimelimit);
                            }
                    }
            }
        listen(integer channel, string name, key id, string message)
            {
                
                if (message == "Play")
                    {                     
                        menutimeout = FALSE;   
                        playerkey = toucher;
                        toucher = "";
                        playername = llKey2Name(playerkey);   
                        llSay(0, playername + newplayermessage);   
                        sayto_player(permissionsmessage);
                        llSetTimerEvent(permissionstimelimit); 
                        permissionstimeout = TRUE;
                        llRequestPermissions(playerkey, PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA);                       
                    }
                else if (message == "Quit")
                    {
                        llSay(0, "Game has finished and is now open for play.");
                        llResetScript();
                    }
               else if (message == "Cancel" && playerkey == "")
                    {
                        toucher = "";
                    } 
                else if (message == "score")
                    {
                        cancount++;
                        score++;
                        if (cancount >= 10)
                            {
                                gameover();
                            }
                    }
                else if (message == "noscore")
                    {
                        cancount++;
                        if (cancount >= 10)
                            {
                                gameover();
                            }
                    }
                else 
                    {
                        //Do Nothing
                    }    
            }
        timer()
            {
                if (menutimeout == TRUE)
                    {
                        llRegionSayTo(toucher, 0, "Menu" + privatetimeoutmessage);
                        toucher = "";
                    }
                else if (permissionstimeout == TRUE)
                    {
                        llRegionSayTo(playerkey, 0, "Permissions" + privatetimeoutmessage);
                        llSay(0, "Game" + publictimeoutmessage);
                        llResetScript();
                    }
                else if (gametimeout == TRUE)
                    {
                        llSay(0, "Game" + publictimeoutmessage);
                        llResetScript();
                    }
                else if (calculatescore == TRUE)
                    {
                        llShout(comchannel, "calculate score");
                        llSetTimerEvent(0);
                        calculatescore == FALSE;
                    }
                else
                    {
                        if (speed < maxspeed)  
                            {                  
                                speed++;  
                                llRegionSayTo(playerkey, 0,"Strength is " + (string)llRound(speed));
                            }
                        else
                            { 
                                speed = maxspeed;
                                while (i < 0)
                                    {
                                        llRegionSayTo(playerkey, 0, "Strength is maxed.");
                                        i++;
                                    }
                            }
                    }
            }
    }