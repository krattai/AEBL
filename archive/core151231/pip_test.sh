kfifo fifo
chmod 777 fifo
omxplayer --layer 2 --win "475 300 650 400" "mp4/Revolution OS.mp4" <fifo &
echo -n " " > fifo
echo -n " " > fifo
