#!/bin/bash

wget -O btccad.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=BTCCAD=X"
wget -O usdcad.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=USDCAD=X"
wget -O gldcad.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=XAUCAD=X"

btc=$(awk -F "\"*,\"*" '{print $2}' btccad.txt)
usd=$(awk -F "\"*,\"*" '{print $2}' usdcad.txt)
gld=$(awk -F "\"*,\"*" '{print $2}' gldcad.txt)

mosquitto_pub -d -t aebl/social -m "Today's bitcoin rate CAD\\\$$btc and USD rate CAD\\\$$usd and gold rate CAD\\\$$gld #PSA #am2p" -h "uveais.ca"
