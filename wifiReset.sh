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
echo

# turning off wifi power save
echo "Trying to turn off wifi power save..."
# collecting config lines
# note that while loop is run in a sub-process if while is put after a pipe
i=0
while read line
do
	POWER[$i]="$line"
	((i+=1))
done <<< "$(grep -nrE "^[ ]*wifi\.powersave[ ]*=" /etc/NetworkManager/conf.d)"
if [[ ${#POWER[@]} -eq 1 ]]; then
	POWER=${POWER[0]}
	POWERFILE=$(echo $POWER | cut -d ':' -f 1)	
	POWERLINE=$(echo $POWER | cut -d ':' -f 2)
	POWERCONF=$(echo $POWER | cut -d ':' -f 3 | cut -d '#' -f 1 | cut -d ';' -f 1)
	CONFCHECK=$(echo $POWERCONF | grep -E '^[ ]*wifi\.powersave[ ]*=[ ]*[0-4][ ]*$')
	if [ -z "$CONFCHECK" ]; then
		echo "Power save settings cannot be parsed."
		echo "Skipping turning off..."
	else
		OFFCHECK=$(echo $POWERCONF | cut -d '=' -f 2 | grep '2')
		if [ -z "$OFFCHECK" ]; then
			echo "Wifi power save will be turned off."
			echo "Its configuration is in $POWERFILE"
			# this line should start with wifi.powersave=[number] so a substitution can handle that
			sudo sed -i --follow-symlinks -E "${POWERLINE},${POWERLINE}s/.*/# 0 for default value, 1 for no touch, 2 for disable, 3 for enable\n# your old setting\n#&\nwifi.powersave=2/" "$POWERFILE"
			echo "Restart Network Manager..."
			sudo service network-manager restart
		else
			echo "Wifi power save is aleady off."
		fi
	fi
else
	echo "Wifi power save settings not found."
	echo "Skipping turning off..."
fi
echo

# reinstall driver module
echo 'Reactivating wifi driver module...'
sudo modprobe -r 8723bu
sudo modprobe -v 8723bu
# disable and enable wifi
echo
echo 'Disabling and re-enabling wifi...'
nmcli radio wifi off
nmcli radio wifi on
# wait 3 seconds for device to init
echo 'Wait 3 seconds for initiating device...'
sleep 3s
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

