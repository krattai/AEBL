#!/usr/bin/env python

import paho.mqtt.client as mqtt

# Unknown license, code found here:  http://stackoverflow.com/questions/31775450/publish-and-subscribe-with-paho-mqtt-client

# reference to MQTT python found here: http://mosquitto.org/documentation/python/

# requires:  sudo pip install paho-mqtt
# pip requires: sudo apt-get install python-pip

message = 'ON'
def on_connect(mosq, obj, rc):
#    mqttc.subscribe("aebl/hello", 0)
#    mqttc.subscribe("aebl/alive", 0)
    mqttc.subscribe("uvea/alive", 0)
#    mqttc.subscribe("uvea/world", 0)
    print("rc: " + str(rc))

def on_message(mosq, obj, msg):
    global message
    print(msg.topic + " " + str(msg.qos) + " " + str(msg.payload))
    message = msg.payload
#    mqttc.publish("uvea/world",msg.payload);
    mqttc.publish("uvea/world","uvea/alive - ACK");
#    mqttc.publish("uvea/world",msg.payload);
#    if 'ACK' in message:
#        mqttc.publish("uvea/world","NAK");
#
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

mqttc.connect("2001:5c0:1100:dd00:240:63ff:fefd:d3f1", 1883,60)
# mqttc.connect("2001:5c0:1100:dd00:ba27:ebff:fe2c:41d7", 1883,60)

# mosquitto_sub -h 2001:5c0:1100:dd00:ba27:ebff:fe2c:41d7 -t "hello/+" -t "aebl/+" -t "ihdn/+" -t "uvea/+"

# Continue the network loop
mqttc.loop_forever()
