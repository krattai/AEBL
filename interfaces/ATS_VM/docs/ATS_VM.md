The Airtime VM images is compressed from 2.6GB to 0.98GB using 7zip.  For linux, you'll need to install p7zip or p7zip-full.

The file is located here:
https://www.dropbox.com/s/ojvw90ce3subom0/ATS_vm.7z?dl=0

If anything is broken, let us know on the AEBL project site:
https://github.com/krattai/AEBL

NB:  This is a standard, unmodified, full install of Airtime 2.5.1.  Anything else that will be for my specific purpose will not go on this VM.

~~~~~~~~~~~

ATS_VM.vdi is an Airtime Virtual Machine installation.  This virtual machine is distributed under a general BSD license and otherwise is under absolutley no guarantee or warranty of functionality or support.

~~~~~~~~

Of course, it requires virtualbox to use:
https://www.virtualbox.org/

It will run with 384MB of RAM but that can be increased if you have the resources, as well, it should probably have sound enabled in VM and set network to bridge on VM.

The install is:
Ubuntu 14.04 32bit server - bare bones with openssh
Airtime 2.5.1 - full

Ubuntu is installed with LVM, so the smallish 4GB drive can be expanded with another virtual drive, and can probably be mirrored to a larger virtual drive, as well.

Ubuntu is configured with Samba, IPv6 & zeroconf for network discovery, so it has a public (but not routable) IPv6 through gogo6.  It is viewable viewable in network browser and has a share folder called ctrl.  It has a hostname of AEBL-ATS-VM and services can be discovered with Bonjour (Rendevous), Avahi, Zeroconf.

Airtime is a fresh install, so the admin username and password is admin/admin.  All other passwords on the system should be set to password, including those for icecast2.

To access the Airtime tool, open your browser and type in the following address:
http://aebl-ats-vm.local/

or (this MIGHT work) perhaps simply:
http://aebl-ats-vm/

Log in with the default -> admin / admin and set up Airtime.

If you cannot log in with those addresses above, you may need to install Bonjour / Avahi / Zeroconf on your system.  Otherwise, log into your network router and find the AEBL-ATS-VM IP address and you can log into Airtime using that IP.

For any potential support, please visit:
https://github.com/krattai/AEBL
