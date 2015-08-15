The AEBL installer scripts take the base image and adds all the necessary code to turn the appliance into an AEBL core appliance.  While still v0091, adding the noo-ebs / MQTT framework.

AEBL is based on a rolling update, so every device will become current, if it has a internet connection, based on the patching system.

The installer scripts in the git installer directory are based on a NEW appliance being installed with the most recent "version".  Each version "base" is contained in associated aeblvXXXX path.

The base does some basic housekeeping and does the important SD card prep of expanding the file system so that it utilizes the entire SD card.  This was incorporated to ensure a small pre-install image.

Once the base is installed and the file system expanded, the final install of the AEBL core is performed.  The final core files are included in the version appropriate asysXXXX path, which are zipped and stored on a drop box account, to ensure persistent access to the files, without using up undesired space on github or sourceforge.

And AEBL core appliance is ultimately a stand alone AEBL that is functional, but may be missing some of the more desirable blades or interfaces that a user might want.

While the blades or interfaces might be desirable, some people may simply not want them, choosing instead to modify the lighter weight core for their own purposes, without the additional bloat of pre-installed blades or interfaces.
