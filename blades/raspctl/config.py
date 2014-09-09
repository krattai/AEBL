import json
import sys
import storage

# sys.path[0] is set by the python interpreter to the directory where the
# executed script, like this very file, resides.  Furthermore, the current
# working directory can point to anywhere and sys.path[0] will still be set
# correctly.
ROOT = sys.path[0]
PATH_SESSION = "/tmp/.raspctl_session_"

default_config = {
    "SHOW_DETAILED_INFO": False,
    "SHOW_TODO":  False,
    "COMMAND_EXECUTION": True,
    "SERVICE_EXECUTION": True,
    "SERVICES_FAVORITES": [],
    "PORT": 8086,
    "AUTH_WHITELIST": [],
}

SERVICE_VALID_ACTIONS = ("reload", "start", "stop", "restart", "status")

CURRENT_TAB = ""

def load_config():
    configuration = storage.read('config')

    for k, v in default_config.items():
        # http://oi45.tinypic.com/nnqrl1.jpg
        setattr(sys.modules[__name__], k, configuration.get(k, v))

def save_configuration(conf):
    configuration = storage.read()
    configuration['config'].update(conf)
    storage.save(configuration)
    # After saving the new configuration, we must load it again
    load_config()
