#!/usr/bin/env python

# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Watch for channel request and assign channel based on prior or unassigned chan
#
# This software is based on an unknown license, but is available
# with no license statement from here:
# http://stackoverflow.com/questions/31775450/publish-and-subscribe-with-paho-mqtt-client
#
# All changes will be under BSD 2 clause license.  Code of unknown license
# will be removed and replaced with code that will be BSD 2 clause
#
# Portions of this code is based on the noo-ebs project:
#     https://github.com/krattai/noo-ebs
#
# And portions of this code is based on the AEBL project:
#     https://github.com/krattai/AEBL
#

import os
import paho.mqtt.client as mqtt

# reference to MQTT python found here: http://mosquitto.org/documentation/python/

# requires:  sudo pip install paho-mqtt
# pip requires: sudo apt-get install python-pip

message = 'ON'
def on_connect(mosq, obj, rc):
    mqttc.subscribe("request/chan", 0)
    print("rc: " + str(rc))

def on_message(mosq, obj, msg):
    global message
    print(msg.topic + " " + str(msg.qos) + " " + str(msg.payload))
    message = msg.payload

    if os.path.isfile('chan/' + str(msg.payload)):
        # get channel from file
        fchan = open("chan/" + str(msg.payload))
        chan = fchan.readline()
        chan = chan.rstrip('\n')
        fchan.close()
    else:
        # get next channel, create file and insert channel
        fchan = open("chan/.0chan","r+")
        chan = fchan.readline()
        chan = chan.rstrip('\n')
        nchan = int(chan) + 1
        fchan.seek(0, 0)
        fchan.write(repr(nchan).zfill(6) + "\n")
        fchan.close()
        fchan = open("chan/" + str(msg.payload),"w+")
        fchan.write(chan + "\n")
        fchan.close()

    mqttc.publish("response/" + str(msg.payload),chan);

#     fchan = open("chan/.0chan")
#     chan = fchan.readline()
#     fchan.close()
#     chan = chan.rstrip('\n')

    # publish channel
#    mqttc.publish("response/" + str(msg.payload),msg.payload);

#    if 'ACK' in message:
#        mqttc.publish("alive/chan","NAK");
#    if 'TEST' in message:
#        os.system("/home/user/scripts/test.sh")
#         mqttc.publish("test/output","NAK");
#    mqttcb.publish("test/output",msg.payload);

def on_publish(mosq, obj, mid):
    print("mid: " + str(mid))

def on_subscribe(mosq, obj, mid, granted_qos):
    print("Subscribed: " + str(mid) + " " + str(granted_qos))

def on_log(mosq, obj, level, string):
    print(string)

mqttc = mqtt.Client()
# Assign event callbacks
mqttc.on_message = on_message
mqttc.on_connect = on_connect
mqttc.on_publish = on_publish
mqttc.on_subscribe = on_subscribe

# Connect
mqttc.connect("ihdn.ca", 1883,60)
# mqttc.connect("2001:dead::beef:1", 1883,60)

# mosquitto_sub -h 2001:dead::beef -t "hello/+" -t "ihdn/+" -t "test/+"

# Continue the network loop
mqttc.loop_forever()

