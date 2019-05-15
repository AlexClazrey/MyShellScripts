#!/bin/bash -i
# 2019-05-07 alexc
# edit ~/.profile and ~/.bashrc
# add some package sources

TODAY=`date "+%Y-%m-%d"`
TMPDIR="/tmp/profileEdit"
RELEASE=`lsb_release -r | cut -f 2`

mkdir -p $TMPDIR
source ~/.profile
# -i is for sourcing ~/.bashrc
# scripts run non-interactively, so by default source .bashrc won't do anything.
# we need to hack through this, so added -i at top.

echo "1. Adding yarn to \$PATH:"
YARN=`command -v yarn`
if [ -z "$YARN" ]; then
	# if yarn has not been installed, uses default path
	YARNPATH='$HOME/.yarn/bin'
else
	# otherwise use its config
	YARNPATH=`yarn global bin`
fi
ADDYARN="if [ -d \"$YARNPATH\" ]; then\n\tPATH=\"$YARNPATH:\$PATH\"\nfi"
if [ -z "$(echo $PATH | grep "$YARNPATH")" ] \
	&& [ -z "$(cat ~/.profile | grep "$YARNPATH")" ]; then
	# echo -e interprets backslash
	echo "---- .profile content start ----"
	echo "" | tee -a ~/.profile
	echo "# $TODAY: add yarn global package location to path." | tee -a ~/.profile
	echo -e $ADDYARN | tee -a ~/.profile
	echo "----- .profile content end -----"
	echo
else
	echo "You have yarn global package location in \$PATH."
	echo "Skipping..."
fi
echo

echo "2. Setting alias command 'path' to show \$PATH:"
if [ -z "$(command -v path)" ]; then
	echo "---- .bashrc content start ----"
	echo "" | tee -a ~/.bashrc
	echo "# $TODAY: add command to show PATH." | tee -a ~/.bashrc
	# leave a little space before single quote for auto-highlighting to work properly in vim
	echo "alias path='echo \$PATH | tr \":\" \"\n\" '" | tee -a ~/.bashrc
	echo "----- .bashrc content end -----"
else
	echo "You have command 'path' in presence."
	echo "I will not overwrite it."
	echo "Skipping..."
fi
echo

echo "3. Increase terminal history size:"
if [[ "$HISTSIZE" -lt 3000 ]]; then
	echo "Increase HISTSIZE to 3000, HISTFILESIZE to 6000."	
	# read `info sed` to find a way to edit .bashrc file decently.
	sed -i -E 's/^HISTSIZE=[0-9]+/HISTSIZE=3000/' ~/.bashrc
	sed -i -E 's/^HISTFILESIZE=[0-9]+/HISTFILESIZE=6000/' ~/.bashrc
else
	echo "Your history size is larger than 3000."
	echo "Skipping..."
fi	
echo

echo "4. Download a script to lookup command options in manpage easily:"
if [ -z "$(command -v he)" ]; then
	echo "It's from https://superuser.com/questions/253093/searching-for-a-specific-option-in-a-man-page"
	echo "Usage: he <command-name> <an option>"
	# check if ~/.local/bin/he exists.
	HELOCA="~/.local/bin/he" 
	if [ -e "$HELOCA" ]; then
		echo "~/.local/bin/he exists, I will not overwrite it."
		echo "Skipping..."
	else
		mkdir -p ~/.local/bin
		wget -O ~/.local/bin/he https://raw.githubusercontent.com/mikelward/scripts/master/he
		chmod 755 ~/.local/bin/he
		if [ -z "$(echo $PATH | grep "$HOME/.local/bin")" ]; then
			echo "At time you don't have ~/.local/bin in \$PATH."
			echo "Maybe you need to login again for changes taking effect."
		fi
	fi
else
	echo "You have 'he' command in presence."
	echo "I will not overwrite it."
	echo "Skipping..."
fi
echo

# Add package source of Yarn and MySQL Community Version
echo "5. Add yarn and mysql community version package source:"
YARN=`apt search ^yarn$ 2>/dev/null | grep yarn`
# curl -sS means slient but showing errors.
if [ -z "$YARN" ]; then
	echo "Adding Yarn deb source and keys..."
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
else
	echo "You have added Yarn package source to apt."
	echo "Skipping..."
fi
MYSQL=`dpkg -l mysql-apt-config*`
if [[ $? -eq 0 ]]; then
	echo "You have installed mysql-apt-config."
	echo "Skipping..."
else
	echo "Download and install mysql-apt-config..."
	SQLDEBNAME=`curl -sS http://repo.mysql.com/ | grep mysql-apt-config | sort -V | tail -n 1 | cut -d '"' -f 6`
	SQLURL="https://repo.mysql.com/$SQLDEBNAME"
	wget -P $TMPDIR $SQLURL 
	sudo dpkg -i $TMPDIR/$SQLDEBNAME	
fi
echo

echo "6. Add boot-repair and fsearch ppa:"
BRP=`apt search ^boot-repair$ 2>/dev/null | grep boot-repair`
if [ -z "$BRP" ]; then
	echo "Adding ppa:yannubuntu/boot-repair ..."
	sudo add-apt-repository -y ppa:yannubuntu/boot-repair
else
	echo "You have added boot-repair ppa."
	echo "Skipping..."
fi
# check if release larger then 18.10 - bash doesn't do floats
var=$(awk 'BEGIN{ print "'18.10'"<"'$RELEASE'" }')
if [[ "$var" -eq 1 ]]; then
	echo "[INFO] Fsearch does not have official build for release upper than 18.10."
	echo "[INFO] You need to build it yourself."
	echo "[INFO] Read https://github.com/cboxdoerfer/fsearch/wiki/Build-instructions for details."
	echo "Skipping..."
else
	FSE=`apt search ^fsearch$ 2>/dev/null | grep fsearch`
	if [ -z "$FSE" ]; then
		echo "Adding ppa:christian-boxdoerfer/fsearch-daily ..."
		sudo add-apt-repository -y ppa:christian-boxdoerfer/fsearch-daily
	else
		echo "You have added fsearch ppa."
		echo "Skipping..."
	fi
fi
echo

rm -rf $TMPDIR

echo "Finished!"
echo "You need to login again for changes to take effect."

