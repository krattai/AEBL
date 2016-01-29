AEBL.vdi is an AEBL Virtual Machine installation.  This virtual machine is distributed under a general BSD license and otherwise is under absolutley no guarantee or warranty of functionality or support.

~~~~~~~~

Of course, it requires virtualbox to use:
https://www.virtualbox.org/

It is intended to be run with 512MB of RAM but that can be increased if you have the resources, as well, it should probably have sound enabled in VM and set network to bridge on VM.

The install is:
Ubuntu 14.04 32bit server - bare bones with openssh
AEBL core code

Ubuntu is installed with LVM, the vdi is an expanding drive up to 64GB and the LVM capability can be expanded with other virtual drives, and can probably be mirrored to a larger virtual drive, as well.

Ubuntu is configured with Samba, IPv6 & zeroconf for network discovery, so it has a public (but not routable) IPv6 through gogo6.  It is viewable viewable in network browser and has a share folder called ctrl.  It has a hostname of AEBL-ATS-VM and services can be discovered with Bonjour (Rendevous), Avahi, Zeroconf.

AEBL core is installed and therefore, with only minor exceptions, any of the AEBL functions can be provided.  The exception being that features that require AEBL to be physically connected to a video or audio playback device do not work, directly.

To access the AEBL tools, open your browser and type in the following address:
http://aebl-vm.local/

or perhaps simply:
http://aebl-vm/

Log in with the default username and password.

If you cannot log in with those addresses above, you may need to install Bonjour / Avahi / Zeroconf on your system.  Otherwise, log into your network router and find the AEBL-VM IP address and you can log into AEBL using that IP.

For any potential support, please visit:
https://github.com/krattai/AEBL
