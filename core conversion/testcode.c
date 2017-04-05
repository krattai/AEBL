/* testcode.c: created to test code and theory prior to adding to core code

Copyright (C) 2017 Uvea I. S., Kevin Rattai
Date created: April 3, 2017

*/

#include <stdio.h>
#include <stdlib.h>

/* for run.c testing */
#include <sys/types.h>
#include <unistd.h>

int main ()
{
/* var and const defs */

    const char AEBL_TEST[] = "/home/pi/.aebltest",
               AEBL_SYS[] = "/home/pi/.aeblsys",
               TEMP_DIR[] = "/home/pi/tmp",
               T_STO[] = "/run/shm",
               T_SCR[] = "/run/shm/scripts",
               LOCAL_SYS[] = "${T_STO}/.local", /* will be used in conj with path */
               NETWORK_SYS[] = "${T_STO}/.network", /* will be used in conj with path */
               OFFLINE_SYS[] = "${T_STO}/.offline"; /* will be used in conj with path */


    const char NOTHING_NEW[] = "${T_STO}/.nonew";
    const char NEW_PL[] = "${T_STO}/.newpl";
    const char CRONCOMMFILE[] = "${T_STO}/.tempcron";

/* oops, the following need to be converted to c syntax and function
    char IPw0[] = $(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1);
    char MACw0[] = $(ip link show wlan0 | awk '/ether/ {print $2}');
    char IPe0[] = $(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1);
    char MACe0[] = $(ip link show eth0 | awk '/ether/ {print $2}');
*/

    int retcode;
   printf("PATH : %s\n", getenv("PATH"));
   printf("HOME : %s\n", getenv("HOME"));
   printf("ROOT : %s\n", getenv("ROOT"));

   return(0);
}
