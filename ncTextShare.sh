#!/bin/bash
# 2019-05-04 alexc
# This will open a netcat server listening on port 5555,
# waiting for an nc or telnet client.
# They can send text to each other.

IP=`hostname -I`
IP="${IP##*( )}"
IP="${IP%%*( )}"
PORT=5555
echo "-----------           Description           -----------"
echo "For compatibility with Telnet,"
echo "line ending is CRLF, input/output is line-buffered."
echo "Local Ip address/es of this machine is/are $IP"
echo "Start listening on port $PORT." 
echo "Netcat runs in verbose mode to output connection info."
echo "-----------  Press Ctrl-C / Ctrl-D to exit  -----------"
cat <(echo Connected to $IP port $PORT.) - | stdbuf -oL sed 's/$/\r/' | nc -vNl 5555 | stdbuf -oL sed ''

