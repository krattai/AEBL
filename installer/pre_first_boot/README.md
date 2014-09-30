The AEBL base image is a slightly modified Raspbian image.

Slightly modified means that the the image has software installed to allow for the loading of branding boot images and also includes core OAuth src in order to allow AEBL to be used on social media networks.

These were installed on the image simply to test the features and were not removed, as that would simply require them to be installed once again on the first boot install procedure, waisting code and user time.

The bootup.sh script on the pre-boot image also contains the bootup.sh script as noted in the pre_first_boot source directory, which starts the core AEBL install script create-sys.sh, which is also noted in the pre_first_boot source directory.
