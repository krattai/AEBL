#!/usr/bin/env python

# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# This script watches MQTT channel and publishes to social media on trigger.
#
# Trigger is #am2p on channel
#   Same trigger, by user fires ITTT recipe to push to other social media
#
# usage:
#   mosquitto_pub -d -t aebl/social -m "If this posts, then it worked.  :) #am2p " -h "uveais.ca"
#
# Special char handling requires \ escape char, as in \$:
#     mosquitto_pub -d -t aebl/social -m "Today's bitcoin rate CAD\\\$576.5844 US$ rate CAD\\\$1.3769 #PSA #am2p" -h "uveais.ca"
#
# The above will drop first and third \ and then pub to twitter with tcli.sh drops the other \ for final publish to twitter.

import os

import paho.mqtt.client as mqtt
# Unknown license, code found here:  http://stackoverflow.com/questions/31775450/publish-and-subscribe-with-paho-mqtt-client

# reference to MQTT python found here: http://mosquitto.org/documentation/python/

# requires:  sudo pip install paho-mqtt
# pip requires: sudo apt-get install python-pip

message = 'ON'
def on_connect(mosq, obj, rc):
# subscribe([("my/topic", 0), ("another/topic", 2)])
#    mqttc.subscribe("aebl/hello", 0)
#    mqttc.subscribe("aebl/alive", 0)
    mqttc.subscribe("aebl/social", 0)
    print("rc: " + str(rc))

def on_message(mosq, obj, msg):
    global message
    print(msg.topic + " " + str(msg.qos) + " " + str(msg.payload))
    message = msg.payload
#    mqttc.publish("uvea/world",msg.payload);
    if '#am2p' in message:
        mqttc.publish("aebl/social","Publishing to social media.");
#         $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "Publishin to social media, with a link. http://embracingopen.blogspot.ca/ #am2p"
# ex: os.system("./args.sh %s %s %s" % (value1,value2,value3)) 
        os.system("/home/kevin/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s \"%s\"" % (message))
 
#    mqttcb.publish("uvea/world",msg.payload);

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
# mqttc.connect("localhost", 1883,60)

# mqttc.connect("2001:5c0:1100:dd00:240:63ff:fefd:d3f1", 1883,60)
# mqttc.connect("2001:5c0:1100:dd00:ba27:ebff:fe2c:41d7", 1883,60)
mqttc.connect("uveais.ca", 1883,60)

# Continue the network loop
mqttc.loop_forever()

