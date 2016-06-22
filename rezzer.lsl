integer myChannel;
key targetKey;
integer listenHandle;
default
{
    state_entry()
    {
        // set up a sit target
        llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);
    }


    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            key av = llAvatarOnSitTarget();
            if (av)
            {
                targetKey = llAvatarOnSitTarget();
                llOwnerSay("sitter: "+(string) targetKey);

                // choose a random channel to use, and listen on it
                myChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
                llOwnerSay("selected random channel: "+(string)myChannel);
                listenHandle = llListen(myChannel, "", NULL_KEY, "");

                // rez the object and pass it the channel it should use
                llRezObject("rezee", llGetPos() + <0, 0, 2>, ZERO_VECTOR, ZERO_ROTATION, myChannel);
            } else {
                // person has stood
                llRegionSay(myChannel,"DETACH");
            }
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        // wait for a message from the rezee, so we know it's alive and ready to attach
        // when we hear from it, tell it to attach to our victim
        if (message == "READY") {
            llOwnerSay("rezzed object ready, sending attach command for target "+(string)targetKey);
            llRegionSay(myChannel, "ATTACHTO "+(string)targetKey);
            llListenRemove(listenHandle);
        }
    }

}
