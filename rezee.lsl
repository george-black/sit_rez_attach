integer listenHandle;
key attachTarget;

default
{
    state_entry()
    {

    }

    listen(integer channel, string name, key id, string message)
    {
        // wait for a message and split it on spaces, first part is the command, second part is a parameter
        llOwnerSay("rezee got message: "+message);
        list parsedList = llParseString2List(message,[" "],[]);
        llOwnerSay("parsed list: "+llDumpList2String(parsedList,":"));

        // attach command, try attaching to the key specified in the paramter
        if (llList2String(parsedList,0) == "ATTACHTO") {
            attachTarget = llList2Key(parsedList,1);
            llOwnerSay("sending attach request to "+(string)attachTarget);
            llRequestPermissions(attachTarget, PERMISSION_ATTACH);

        // detach command, detach or self-destruct
        } else if (llList2String(parsedList,0) == "DETACH") {
            llDie();
            integer perm = llGetPermissions();
            if(perm & PERMISSION_ATTACH) {
                llDetachFromAvatar();
            }
        } else {
            llOwnerSay("got a strange message: "+message);
        }
    }

    // we have gained permission!  complete the attach
    run_time_permissions( integer vBitPermissions )
    {
        if ( vBitPermissions & PERMISSION_ATTACH )
            llAttachToAvatarTemp( ATTACH_LHAND );
        else
            llOwnerSay( "Permission to attach denied" );
    }

    // when we start up, activate the listener on our secret channel and ping the rezzer so
    // that it knows we are ready.  also set a self-destruct timer.
    on_rez(integer rez)
    {
        if (rez != 0) {
            llOwnerSay("sending ready message on channel "+(string)rez);
            listenHandle = llListen(rez, "", NULL_KEY, "");
            llRegionSay(rez,"READY");
            llSetTimerEvent(60.0);
        }
    }

    // self-destruct timer went off. bye!
    timer() {
        llOwnerSay("attach timed out");
        llDie();
    }

    // we have successfully attached to the avatar.  cancel the timer.
    attach(key id)
    {
        if (id) {
            llOwnerSay( "The object is attached to " + llKey2Name(id) );
            llSetTimerEvent(0.0); // cancel the self-destruct
            llRequestPermissions(id, PERMISSION_ATTACH );
        } else {
            llOwnerSay( "The object is not attached");
        }
    }
}
