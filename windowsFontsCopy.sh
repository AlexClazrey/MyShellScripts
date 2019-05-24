#!/bin/bash
# 2019-05-25 alexc
# This script copies fonts you don't have from the Windows OS installed.
# This script installs fonts into /usr/local/share/fonts

# configuration
CONF='windowsFontsCopy.conf'
if [ ! -e "$CONF" ]; then 
	tee $CONF <<END 
WINDISK=/media/xxxxxx
END
	exit 1
fi

source ./$CONF 
if [ ! -d "$WINDISK" ]; then
	echo 'Cannot access Windows OS Folder in '$CONF
	echo 'Your setting is '$WINDISK
	echo 'Abort.'
	exit 1
fi

# code
SP='/'
FONTS="$WINDISK/Windows/Fonts"
FILELIST=$(comm -13 <(fc-list | cut -d ':' -f 1 | grep -o '[^/]*$' | sort) <(ls "$FONTS" | sort) | tr '\n' $SP)

cd $FONTS
REBUILD=0
# copy ttf files
TTFS=$(echo $FILELIST | tr $SP '\n' | grep -i '.ttf')
if [ -z "$TTFS" ]; then
	echo 'no TTF need to copy.'
else
	sudo cp -v $TTFS /usr/local/share/fonts && REBUILD=1
fi

# copy otf files
OTFS=$(echo $FILELIST | tr $SP '\n' | grep -i '.otf')
if [ -z "$OTFS" ]; then
	echo 'no OTF need to copy.'
else
	sudo cp -v $OTFS /usr/local/share/fonts && REBUILD=1
fi

# copy ttc files
TTCS=$(echo $FILELIST | tr $SP '\n' | grep -i '.ttc')
if [ -z "$TTCS" ]; then
	echo 'no TTC need to copy.'
else
	sudo cp -v $TTCS /usr/local/share/fonts && REBUILD=1
fi

[[ $REBUILD -eq 1 ]] && fc-cache -f -v
