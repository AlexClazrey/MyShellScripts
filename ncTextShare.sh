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
echo 'Using line ending CRLF for compatibility with telnet.'
echo "Local Ip address/es of this machine is/are $IP"
echo "Start listening on port $PORT." 
echo "Netcat runs in verbose mode to output connection info."
echo '-----------  Press Ctrl-C / Ctrl-D to exit  -----------'
cat <(echo Connected to $IP port $PORT.) - | stdbuf -o0 sed 's/$/\r/' | nc -vNl 5555

