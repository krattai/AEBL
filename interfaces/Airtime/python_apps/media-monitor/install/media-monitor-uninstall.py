# -*- coding: utf-8 -*-

import os
import sys
from configobj import ConfigObj

if os.geteuid() != 0:
    print "Please run this as root."
    sys.exit(1)

PATH_INI_FILE = '/etc/airtime/media-monitor.cfg'

def remove_path(path):
    os.system('rm -rf "%s"' % path)

def get_current_script_dir():
  current_script_dir = os.path.realpath(__file__)
  index = current_script_dir.rindex('/')
  return current_script_dir[0:index]

def remove_monit_file():
    os.system("rm -f /etc/monit/conf.d/monit-airtime-media-monitor.cfg")

try:
    # load config file
    try:
        config = ConfigObj(PATH_INI_FILE)
    except Exception, e:
        print 'Error loading config file: ', e
        sys.exit(1)

    os.system("invoke-rc.d airtime-media-monitor stop")
    os.system("rm -f /etc/init.d/airtime-media-monitor")
    os.system("update-rc.d -f airtime-media-monitor remove >/dev/null 2>&1")

    print "Removing monit file"
    remove_monit_file()

    print "Removing log directories"
    remove_path(config["log_dir"])

    print "Removing symlinks"
    os.system("rm -f /usr/bin/airtime-media-monitor")

    print "Removing application files"
    remove_path(config["bin_dir"])

    print "Uninstall complete."
except Exception, e:
    print "exception:" + str(e)
