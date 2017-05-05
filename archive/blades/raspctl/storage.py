import json
import copy
import hashlib

DEFAULT_DATA = {
    "alarms": [],
    "commands": [],
    "config": {},
    "radio": {"Proton Radio": "http://protonradio.com:8000"},
    "user": [{"id_": "admin", "password": hashlib.sha256("admin").hexdigest()}],
}

_data = None

def _read_file():
    try:
        with open('data.dat') as f:
            return json.loads(f.read())
    except:
        return {}

def read(table=None):
    global _data
    if not _data: # Chache is empty
        default_data = copy.deepcopy(DEFAULT_DATA)
        default_data.update(_read_file())
        _data = copy.deepcopy(default_data)

    return _data if table == None else _data[table]

def save(data):
    if type(data) != dict and set(DEFAULT_DATA) != set(data):
        print data
        raise Exception("You are trying to save something with the wrong format!")
    try:
        with open('data.dat', 'w') as f:
            f.write(json.dumps(data))
    except:
        print "Problem when saving data in the DDBB..."
        raise

def save_table(table, data):
    ddbb = read()
    ddbb[table] = data
    save(ddbb)
    _data = None # Invalidate the cache


def get_by_id(table, id_record, default={}):
    record = filter(lambda x: x['id_'] == id_record, read(table))
    return  record[0] if record else default

def replace(table, record):
    data = read()
    return map(lambda x: record if x['id_'] == record['id_'] else x, data[table])

def delete(table, id):
    data = read()
    data[table] = filter(lambda x: x['id_'] != id,  data[table])
    save(data)
