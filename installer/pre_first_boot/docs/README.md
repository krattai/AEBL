This folder would contain any relevant documents specifically pertaining to an AEBL image that has not yet been run for the first time.

Although the bash scripter installer works, should investigate open source installers for best practices and standardizations.

~~~~~~~~~~

20190401 - kr

A goal is to ultimately have the smallest possible linux base and build from there.  This would be useful for downloading a tiny core that would build itself, like net-install distros.  Of course, it should be simple enough for someone to create their own core to install AEBL distros to, as well.

Right now, a base (current) debian base (using defaults) is 1.4GB raw and 410MB 7z compressed.  Not bad, but would like core to be at least under 1GB.  Will have to discover options to maintain debian core, but keep small.  Why debian?  Because it is a broadly installable distro.  Other *NIX (like) lines may not install on enough platforms.

To build from a base, default, tiny debian with only ssh and core utils:

su
nano /etc/sudoers
# adjust tom for what ever user name desirable.  AELB uses pi user, as scripts are based on that user
tom ALL=(ALL) NOPASSWD:ALL
exit

sudo apt update
sudo apt install -y sudo net-tools
