/* main.c: replacement for startup.sh and run.sh
           this is the master program that starts and manages system

Copyright (C) 2014 Uvea I. S., Kevin Rattai
Date created:	October 10, 2014

*/

#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

void main(void)
{
    char AEBL_TEST="/home/pi/.aebltest",
         AEBL_SYS="/home/pi/.aeblsys",
         TEMP_DIR="/home/pi/tmp",
         T_STO="/run/shm",
         T_SCR="/run/shm/scripts",
         LOCAL_SYS="${T_STO}/.local", /* will be used in conj with path */
         NETWORK_SYS="${T_STO}/.network", /* will be used in conj with path */
         OFFLINE_SYS="${T_STO}/.offline"; /* will be used in conj with path */

	printf("\n\nThis applications manages the system\n");
	system("startup.sh");
	system("run.sh");

}
