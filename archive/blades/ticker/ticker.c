/*
 * Generic text scroller program.
 * 
 * Scrolls any string of text on a line of the screen.
 * Can use SysV shared memory to communicate with another
 * program to get messages to display.
 *
 * By Joey Hess <joey@kitenet.net>, GPL copyright 1998-2002
 * All rights reserved. See COPYING for full copyright information.
 */

#include "config.h"
#include "slang.h"
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#ifdef HAVE_GETOPT_H
#include <getopt.h>
#endif
#include <stdlib.h>
#if TIME_WITH_SYS_TIME
# include <sys/time.h>
# include <time.h>
#else
# if HAVE_SYS_TIME_H
#  include <sys/time.h>
# else
#  include <time.h>
# endif
#endif
#include <sys/ipc.h>
#include <sys/shm.h>
#include <string.h>
#include <limits.h>

/* Where to display message. 1=bottom of screen, 0=top */
int scroll_pos=0;
/* message to display */
char *message=NULL;
/* the colors to display the message in. */
char *bgcolor="black";
char *fgcolor="white";
/* how long to delay between updates, in usecs */
long delay=1000000;
/* if 1, read new messages from stdin */
int read_shm=0;
/* how long to delay between checks of the shared memory segment */
int refresh=1;
/* the max size of the shared memory segment */
int shm_size=80;
/* this points to the shared memory segment */
char *shm_p=NULL;

/* Display an error. The parameters work like printf() */
void Error(const char *fmt, ...) {
	va_list arglist;

	va_start(arglist, fmt);
	fprintf(stderr, "ticker: ");
	vfprintf(stderr, fmt, arglist);
	fprintf(stderr, "\n");
	va_end(arglist);
	
	exit(1);
}

/* Signal handler to exit safely. */
void Clean_Exit () {
	SLsmg_gotorc(SLtt_Screen_Rows - 1, 0);
	SLsmg_refresh();
	SLang_reset_tty ();
	SLsmg_reset_smg ();

	if (read_shm)
		shmdt(shm_p);

	exit(0);
}

void Init_Screen () {
	SLsig_block_signals();
	SLtt_get_terminfo();
	if (SLkp_init() == -1)
		Error("unable to initialize keyboard");
	SLang_init_tty(3, 1, 1); /* 3 = abort on ctrl-c */
	SLang_set_abort_signal(Clean_Exit);
	SLsmg_init_smg();
	SLsig_unblock_signals();
}

void ClearLine (int xoffset, int yoffset) {
	SLsmg_gotorc(yoffset,xoffset);
	SLsmg_write_nstring(NULL,SLtt_Screen_Cols);
}

void Write_Message (char *message, int xoffset, int yoffset) {
	SLsmg_gotorc(yoffset,xoffset);
	SLsmg_write_string(message);
}

void Usage () {
	printf("Usage: ticker [options] [message]\n"
"  -h      --help                  display this help\n"
"  -u      --upper                 scroll message on top of screen\n"
"  -l      --lower                 scroll message on bottom of screen\n"
"  -fcolor --foreground=color      foreground color to display message in\n"
"  -bcolor --background=color      background color to display message in\n"
"  -dsecs  --delay=secs            number of seconds between updates (may use\n"
"                                  decimals)\n"
"  -snum   --sysv=num              read messages from shared memory segment with\n"
"                                  id of num\n"
"  -Snum   --size=num              size of the shared memory segment\n"
"  -csecs  --check=secs            how often to shared memory segment for new\n"
"                                  messages\n"
"  message                         the text to scroll (optional if -s is used)\n");
	exit(-1);
}

void Parse_Params (int argc, char **argv) {
#ifdef HAVE_GETOPT_LONG
	struct option long_options[] = {
		{"help",0,NULL,'h'},
		{"upper",0,NULL,'u'},
		{"lower",0,NULL,'l'},
		{"sysv",1,NULL,'s'},
		{"foreground",1,NULL,'f'},
		{"background",1,NULL,'b'},
		{"delay",1,NULL,'d'},
		{"check",1,NULL,'c'},
		{0,0,0,0}
	};
#endif
	extern int optind;
	extern char *optarg;
	int shmid=0;
	
#if defined (HAVE_GETOPT_LONG) || defined (HAVE_GETOPT)
	int c=0;
	
	while (c != -1) {
#define PARAM_SHORT "hulf:b:d:s:c:S:"
#ifdef HAVE_GETOPT_LONG
		c=getopt_long(argc,argv,PARAM_SHORT,long_options,NULL);
#elif HAVE_GETOPT
		c=getopt(argc,argv,PARAM_SHORT);
#endif

		switch (c) {
		case 'h':
			Usage(); /* exits program */
		case 'u':
			scroll_pos=0;
			break;
		case 's':
			read_shm=1;
			shmid=atoi(optarg);
			break;
		case 'l':
			scroll_pos=1;
			break;
		case 'f':
			fgcolor=malloc(strlen(optarg)+1);
			strcpy(fgcolor,optarg);
			break;
		case 'b':
			bgcolor=malloc(strlen(optarg)+1);
			strcpy(bgcolor,optarg);
			break;
		case 'd':
			delay=atof(optarg) * 1000000;
			break;
		case 'c':
			refresh=atoi(optarg);
			break;
		case 'S':
			shm_size=atoi(optarg);
		}
	}
#else
	optind=1;
#endif /* have one of the getopts */

	if (optind < argc) { /* we were passed a message to scroll */
		/* 
		 * malloc memory for the message, instead of just setting it 
		 * equal for optind, because we want to always be able to free()
		 * message later.
		 */
		message=malloc(strlen(argv[optind])+1);
		strcpy(message,argv[optind]);
	}	
	else if (! read_shm) {
		fprintf(stderr,"Must specify a message to display.\n");
		Usage();
	}

	if (read_shm) {
		shm_p=shmat(shmid,0,SHM_RDONLY);
		if ((int)shm_p == -1) {
			perror("ticker: shmat error");
			exit(1);
		}
		if (! (optind < argc)) {
			message=malloc(shm_size+1);
			strncpy(message,shm_p,shm_size);
		}
	}
}

int Is_ExtraLong(int len) {
	if (len > SLtt_Screen_Cols - 2)
		return 1;
	else
		return 0;
}

void Handle_KeyPress(int key) {
	switch (key) {
	case '+':
	case SL_KEY_UP:
		delay=delay / 1.25;
		break;
	case '-':
	case SL_KEY_DOWN:
		/*
		 * Anything less than 5 is a trap we cannot get out of with a 
		 * multiplication factor of 1.25, because of rounding.
		 */
		if (delay < 5)
			delay=5;
		else if (delay * 1.25 <= LONG_MAX)
			delay=delay * 1.25;
		else
			delay=LONG_MAX;

		break;
	case ' ':
		/* Pause for a keypress */
		while (! SLang_input_pending(600)) {}
		SLkp_getkey(); /* discard */
		break;
	}
}

int main (int argc, char **argv) {
	int x, len, extralong, ypos, cursorpos;
	struct timeval tv;
	time_t now, oldtime=time(NULL);
	char *newmessage=NULL;
	
	Parse_Params(argc,argv);
	Init_Screen();
	SLtt_set_color(1,"",fgcolor,bgcolor);
	SLsmg_set_color(1);

	if (scroll_pos) {
		ypos=SLtt_Screen_Rows-1;
		cursorpos=0;
	}
	else {
		ypos=0;
		cursorpos=SLtt_Screen_Rows-1;
	}

	len=strlen(message);
	extralong=Is_ExtraLong(len);

	x=SLtt_Screen_Cols;
	while (1) {
		x--;
		/* See if it's time to reset x. */
		if (x == -1 * len - 2) {
			/*
			 * For strings shorter than the screen
			 * width, we need to behave one way, while
			 * we behave a different way for longer strings. 
			 */
			if (extralong) {
				x= -1;
			}
			else {
				x=SLtt_Screen_Cols - len - 2;
			}

			/* See if there is a newmessage waiting to scroll on. */
			if (newmessage != NULL) {
				free(message);
				message=newmessage;
				newmessage=NULL;
	
				len=strlen(message);
				extralong=Is_ExtraLong(len);

				x=SLtt_Screen_Cols;
			}
		}
		
		/* See if we need to check the shared memory segment for new
		 * data now. */
		if (read_shm && x == -1) {
			now=time(NULL);
			if (now >= oldtime + refresh) {
				oldtime=now;

				newmessage=malloc(shm_size+1);
				strncpy(newmessage,shm_p,shm_size);

				/* See if the message has actually changed. */
				if (strcmp(message,newmessage) == 0) {
					free(newmessage);
					newmessage=NULL;
				}
			}
		}

		/*
		 * Accomplish what looks like continuous scrolling
		 * by actually scrolling 2 copies of the message.
		 */
		ClearLine(0,ypos);
		Write_Message(message,x,ypos);
		/*
		 * If a newmessage is waiting to come on, we don't scroll the
		 * second copy. This makes the screen clear eventually so the
		 * newmessage can come on.
		 */
		if (newmessage == NULL) {
			/* In long string mode have to reposition the second
			 * string. */
			if (extralong)
				Write_Message(message,x+len+2,ypos);
			else
				Write_Message(message,x+SLtt_Screen_Cols,ypos);
		}

		SLsmg_gotorc(cursorpos,0);
		SLsmg_refresh();
		      
		/* Pause. */
		tv.tv_sec=0;
		tv.tv_usec=delay;
		select(0,0,0,0,&tv);
		
		/*
		 * Check for keypress. Could use this as a pause, but it only
		 * has 1/10th second resolution, so don't.
		 */
		while (SLang_input_pending(0))
			Handle_KeyPress(SLkp_getkey());
	}
}
