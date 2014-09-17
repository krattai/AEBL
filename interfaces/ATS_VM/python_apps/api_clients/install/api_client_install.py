import os
import shutil
import sys
from configobj import ConfigObj

def get_current_script_dir():
    return os.path.dirname(os.path.realpath(__file__))

def copy_dir(src_dir, dest_dir):
    if (os.path.exists(dest_dir)) and (dest_dir != "/"):
        shutil.rmtree(dest_dir)
    if not (os.path.exists(dest_dir)):
        #print "Copying directory "+os.path.realpath(src_dir)+" to "+os.path.realpath(dest_dir)
        shutil.copytree(src_dir, dest_dir)

PATH_INI_FILE = '/etc/airtime/api_client.cfg'

current_script_dir = get_current_script_dir()

if not os.path.exists(PATH_INI_FILE):
    shutil.copy('%s/../api_client.cfg'%current_script_dir, PATH_INI_FILE)

"""load config file"""
try:
    config = ConfigObj("%s/../api_client.cfg" % current_script_dir)
except Exception, e:
    print 'Error loading config file: ', e
    sys.exit(1)

#copy python files
copy_dir("%s/../../api_clients"%current_script_dir, config["bin_dir"])
