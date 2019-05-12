#!/bin/bash
# 2019-05-12 alexc
# copy cell phone Photos and Screenshots

CONF="./phonePhotoCopy.conf"
if [ -f "$CONF" ]; then
	source $CONF
else
	tee $CONF >>/dev/null <<END
# 2019-05-12 alexc
# copy cell phone Photos and Screenshots

# configurations to phonePhotoCopy.sh
# cell phone ftp ip / port / username / password
IP="<phone ip>"
PORT="<ftp port>"
USER="<user>"
PASS="<pass>"
# copy destination
DEST="~/Pictures"
PICFILE="*.jpg"
VIDFILE="*.mp4"
END
	echo "No config file found."
	echo "Create new conf file with name phonePhotoCopy.conf."
	echo "Edit that conf file and run this script again."
	echo "Quit now."
	exit 2
fi

# code
WGETOPT='-nc -nv --show-progress'
FTPEXIST=`nc -vz $IP $PORT 2>&1 | grep succeeded`
if [ -z "$FTPEXIST" ]; then
	echo "Cannot find your phone at $IP:$PORT."
	echo "Quit now."
	exit 1
else
	echo "Copying DCIM photos..."
	wget $WGETOPT -P "$DEST/DCIM" "ftp://$USER:$PASS@$IP:$PORT/DCIM/$PICFILE"
	echo "Copying DCIM Videos..."
	wget $WGETOPT -P "$DEST/Video" "ftp://$USER:$PASS@$IP:$PORT/DCIM/Video/$VIDFILE"
	echo "Copying DCIM Selfies..."
	wget $WGETOPT -P "$DEST/Selfie" "ftp://$USER:$PASS@$IP:$PORT/DCIM/Selfie/$PICFILE"
	echo "Copying Screenshots..."
	wget $WGETOPT -P "$DEST/Screenshots" "ftp://$USER:$PASS@$IP:$PORT/Pictures/Screenshots/$PICFILE"
	echo "Finish."
fi
