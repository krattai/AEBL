The AEBL base image is a slightly modified Raspbian image.

Slightly modified means that the the image has software installed to allow for the loading of branding boot images and also includes core OAuth src in order to allow AEBL to be used on social media networks.

These were installed on the image simply to test the features and were not removed, as that would simply require them to be installed once again on the first boot install procedure, waisting code and user time.

The /etc/init.d direcotry on the pre-boot image also contains the bootup.sh script as noted in the pre_first_boot source directory, which does some housekeeping functions (in the event they are necessary to remove original testing) and starts the core AEBL install script create-sys.sh, which is also noted in the pre_first_boot source directory.

The pre_first_boot scripts are in place strictly to indicate the code that is on the base image.

The base image was created as it is, in order to ensure the longevity of the image, without causing people to have to download a new image, every time a new release occured.