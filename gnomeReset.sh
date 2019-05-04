#/bin/bash
# 2019-05-03 alexc
# End gnome session in case it's stuck or mal-functioning.

GNOMELINE=`who -a | grep -w ":0"`
echo 'Your Gnome runs on:'
echo $GNOMELINE
PID=`echo $GNOMELINE | awk '{print $7}'`
echo "End this process $PID ? (yes/no)"
read answer

case $answer in 
	"yes"|"y"|"Yes"|"YES"|"Y" )
		echo "killing $PID"
		kill $PID
		;;
	[nN]o | "n" | "N" | "NO" )
		echo "Cancelled"
		;;
	*)
		echo 'Cannnot understand, exiting.'
		;;
esac

	
