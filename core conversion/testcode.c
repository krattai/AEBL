/* testcode.c: created to test code and theory prior to adding to core code

Copyright (C) 2017 Uvea I. S., Kevin Rattai
Date created: April 3, 2017

*/

#include <stdio.h>
#include <stdlib.h>

int main ()
{
   printf("PATH : %s\n", getenv("PATH"));
   printf("HOME : %s\n", getenv("HOME"));
   printf("ROOT : %s\n", getenv("ROOT"));

   return(0);
}
