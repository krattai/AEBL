omxd
======

Initially did not think that omxd would be a blade, although after consideration, omxd is probably best as a blade, as it is not necessary for AEBL functionality, but is an enhancement for those that specifically desire what it provides.

omxd may eventually become part of AEBL core, but for now, it will be a blade.

It is also great reference code.  B)

As noted in the omxd README:

omxd(1) --  daemon to maintain a playlist and play it via omxplayer
===================================================================

## SYNOPSIS

 omxd
 echo <command> [abs-path] > /var/run/omxctl
 omxd <command> [rel-path]

## DESCRIPTION

The omxd daemon plays your playlist even if you've disconnected from your
Raspberry Pi, to allow the easy implementation of various media centre apps.
Typically, start omxd from the /etc/rc.local stript at boot time.
