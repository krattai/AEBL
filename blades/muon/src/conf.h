/*
 * conf.h - parse config file
 *
 * Copyright (C) 2014 - 2016, Xiaoxiao <i@pxx.io>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef CONF_H
#define CONF_H

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

#define MODE_SERVER 1
#define MODE_CLIENT 2

typedef struct
{
    int mode;
    int daemon;
    int mtu;
    int route;
    int nat;
    int delay;
    int duplicate;
    char pidfile[64];
    char logfile[64];
    char user[16];
    char server[64];
    int  port[2];
    char key[128];
    int  klen;
    char tunif[16];
    char address[16];
    char address6[64];
#ifdef TARGET_DARWIN
    char peer[16];
#endif
} conf_t;

extern int parse_args(int argc, char **argv, conf_t *conf);

#endif // CONF_H
