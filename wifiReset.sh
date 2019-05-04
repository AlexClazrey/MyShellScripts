#!/bin/bash
# 2019-05-03 alexc
# when network-manager tells you wifi connection problems
# this will solve most problems.

# save connecting wifi ssid
SSID=`nmcli d | grep -w connecting | awk '{print $5}'`
ConnectedSSID=`nmcli d | grep -w connected | awk '{print $4}'`
if [ -z "$ConnectedSSID" ] ; then
	if [ -z "$SSID" ] ; then
		echo 'Cannot determine which wifi you are trying to connect.'
		echo 'You need to connect to later it by youself.'
	else
		echo "The wifi you are trying to connect is $SSID."
	fi
else
	echo "You are now connected to $ConnectedSSID."
fi

# reinstall driver module
echo
echo 'Reactivating wifi driver module...'
sudo modprobe -r 8723bu
sudo modprobe -v 8723bu
# disable and enable wifi
echo
echo 'Disabling and re-enabling wifi...'
nmcli radio wifi off
nmcli radio wifi on
# wait 2 seconds for device to init
echo 'Wait 2 seconds for initiating device...'
sleep 2s
# list connections
echo
echo 'Here are your saved connections:'
nmcli c

# judge if the connection is saved
# quotes are necessary.
if [ -z "$SSID" ] ; then
	SSID=$ConnectedSSID
fi
if [ -n "$SSID" ] ; then
	HasSaved=`nmcli c | grep -w $SSID`
	echo
	if [ -z "$HasSaved" ] ; then
		echo "The connection you were trying to connect / you were connected has not be saved."
		echo "You need to connect to it by yourself."
	else
		echo "Trying to connect to $SSID..."
		nmcli c up $SSID
	fi
fi

AutoSSID=`nmcli d | grep -w connecting | awk '{print $5}'`
if [ -n "$AutoSSID" ] ; then
	# wait for 5 seconds if it's auto connecting
	echo
	echo "It's auto connecting to $AutoSSID."
	echo "Let's wait 5 seconds for auto-connection..."
	sleep 5s
fi

# print wifi state
echo
echo 'Now check your wireless devices states:'
nmcli d

