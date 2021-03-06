/* ctrlwtch.c: manages ctrl folder content

Copyright (C) 2014 Uvea I. S., Kevin Rattai
Date created:	October 10, 2014

Build and compare against ctrlwtch.bak not managed by git

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

	printf("\n\nThis applications manages the ctrl folder\n");
	system("ctrlwtch.sh");
}
