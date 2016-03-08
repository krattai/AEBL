#!/bin/bash

wget -O btccad.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=BTCCAD=X"
wget -O usdcad.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=USDCAD=X"
wget -O gldcad.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=XAUCAD=X"
wget -O slvcad.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=XAGCAD=X"

btc=$(awk -F "\"*,\"*" '{print $2}' btccad.txt)
usd=$(awk -F "\"*,\"*" '{print $2}' usdcad.txt)
gld=$(awk -F "\"*,\"*" '{print $2}' gldcad.txt)
slv=$(awk -F "\"*,\"*" '{print $2}' slvcad.txt)

mosquitto_pub -d -t aebl/social -m "Today: bitcoin - CAD\\\$$btc, USD - CAD\\\$$usd, silver - CAD\\\$$slv, gold - CAD\\\$$gld & 1lb flour still a loaf of bread #PSA #am2p" -h "uveais.ca"

exit 0
