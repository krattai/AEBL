#!/bin/bash

# tl;dr Execute "sudo ./exec.sh deploy". Go fap.

# RaspCTL must be executed always as a non-privileged user. But we want to execute commands
# as root, don't we? This is the reason why this scripts exists. It is the last step before
# the execution of a command as root. The command itself is never received as a paramter, is
# hardcoded here in this script; we receive the extra parameters of the command we want to
# execute as parameters of exec.sh. The script mainly check if the received parameters do not
# contain "funny" stuff such as execution of other commands, etc... Everything here as to be
# checked in "paranoid mode" because any flaw could be used for compromising the system.

# How to deploy this file. Execute "./exec.sh help" and then "sudo ./exec.sh deploy [user]".

# How it works? The script itself must be in /opt/raspctl [1] with the user/group root:root
# and with 755 permissions [2]. Then, we must allow the user that will run RaspCTL to execute
# this command without asking any password. We will do it with /etc/sudoers. I WARN you,
# if you make a mistake when editing this file - a single typo - you will be f****d up. So
# PLEASE use "visudo" command [3] for edit this file, is the right way of doing it. You must
# add a line just like the described above [4] where "rasptcl_user" must be changed by the
# user that runs RaspCTL (you can know that by executing this [5]). And pretty much this is it.
# You can test is everything is working properly by executing this command [6]

# One more thing. Every time you pull from the repo new code, exists the possibility that
# changes has been made to this file. How do you know if the file has changed or not? You
# don't. And yep, this is f*****g annoying but I'll figure out a better way to let you know
# that you need to "deploy" this file again.


# [1] Create the directory by executing
#     $ sudo mkdir -p /opt/raspctl
#     $ sudo cp exec.sh /opt/raspctl
# [2] Change the owner and permissions:
#     $ sudo chown root.root /opt/raspctl/exec.sh
#     $ sudo chmod 755 /opt/raspctl/exec.sh
# [3] This command comes with the "sudo" package
# [4] rasptcl_user  ALL = NOPASSWD: /opt/raspctl/exec.sh
# [5] echo $USER
# [6] sudo /opt/raspctl/exec.sh test



case $1 in
	"service" )
		is_valid_name=$(ls /etc/init.d | grep "^$2$")
		if [ "$is_valid_name" == "" ]; then
			exit 1
		fi
		is_valid_action=$(echo $3 | egrep "^(start|stop|restart|reload|status)$")
		if [ "$is_valid_action" == "" ]; then
			exit 1
		fi
		sudo /etc/init.d/$2 $3
		;;
	"test" )
		sudo echo "Yey! It works!"
		;;
	"deploy" )
		echo "Creating directory..."
		sudo mkdir -p /opt/raspctl
		sudo chown root.root /opt/raspctl
		echo "Copying the script..."
		sudo cp $0 /opt/raspctl
		echo "Giving permissions and changin owner..."
		sudo chown root.root /opt/raspctl/exec.sh
		sudo chmod 755 /opt/raspctl/exec.sh
		echo "Checking if we have to modify the sudoers file..."
		test=$(sudo grep exec.sh  /etc/sudoers)
		if [ "" == "$test" ]; then
			echo "Adding line to sudoers file..."
			echo "${2:-pi}  ALL = NOPASSWD: /opt/raspctl/exec.sh" >> /etc/sudoers
		else
			echo "Nop, it looks like sudoers file is OK..."
		fi
		echo "Done!"
		;;
	"help" | * )
		echo "Usage: If you want to deploy this file to /opt/raspctl/exec.sh execute:"
		echo
		echo "    $ sudo ./exec.sh deploy [username]"
		echo
		echo "Where username is the name of the user that will execute RaspCTL. The default is 'pi'."
		echo "Note: more information about this file in the comments of the file itself."
		;;
esac
