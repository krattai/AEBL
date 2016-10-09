#include <newt.h>
#include <stdlib.h>
#include <string.h>
 
int main(int argc, char* argv[])
{
 
    /* required variables and string */
    unsigned int uiRows, uiCols;
    const char pcText[] = "Welcome to Newt and FLOSS !!!";
 
    /* initialization stuff */
    newtInit();
    newtCls();
 
    /* determine current terminal window size */
    uiRows = uiCols = 0;
    newtGetScreenSize(&uiCols, &uiRows);
 
    /* draw standard help and string on root window */
    newtPushHelpLine(NULL);
    newtDrawRootText((uiCols-strlen(pcText))/2, uiRows/2, pcText);
 
    /* cleanup after getting a keystroke */
    newtWaitForKey();
    newtFinished();
 
    return 0;
 
}


