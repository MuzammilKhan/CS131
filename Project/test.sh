pkill -f "proxyherd.py"

for i in "Alford" "Ball" "Hamilton" "Holiday" "Welsh"
do
  echo Starting up  $i
  python2 proxyherd.py $i &
done

sleep 5

(   echo IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1479413884.392014450;
	sleep 2;
) | telnet localhost 12720

pkill -f 'python2 proxyherd.py Welsh'

(   echo IAMAT kiwi2.cs.ucla.edu +35.068930-119.445127 1479413884.392014450;
	sleep 2;
) | telnet localhost 12720

pkill -f 'python2 proxyherd.py Holiday'

(   echo IAMAT kiwi3.cs.ucla.edu +32.068930-120.445127 1479413884.392014450;
	sleep 2;
) | telnet localhost 12721

(   echo WHATSAT kiwi.cs.ucla.edu 40 2;
	sleep 5;
) | telnet localhost 12722

pkill -f 'python2 proxyherd.py Alford'
pkill -f 'python2 proxyherd.py Hamilton'
pkill -f 'python2 proxyherd.py Ball'