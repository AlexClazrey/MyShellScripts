# My Shell Scripts

These are my shell scripts to make my little Ubuntu devices awesome.  
Currently I have three.

## wifiReset.sh

Persuming you are using the [8723bu][1] driver, it can get you out of random realtek wireless adapter re-connecting issues, at least, for now.

## gnomeReset.sh

When your Gnome Desktop is mal-functioning, change to tty mode and run it.

## ncTextShare.sh

Based on netcat, you can share text with telnet on Windows or nc on other Unix machines.  
Server runs this script, listening connections on port 5555.  
For telnet client, run 'telnet [address] 5555'.  
For nc client, run 'nc [address] 5555'.  

[1]: http://github.com/lwfinger/rtl8723bu