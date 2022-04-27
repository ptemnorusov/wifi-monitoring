#!/bin/bash
wifi_monitoring_stop=0

#create or clear file, that contains wifi mac addresses, that we detected today
touch ./wifi-monitoring/wifi-todaysmacs
echo > ./wifi-monitoring/wifi-todaysmacs


for days in {1..1700}
do 
	# find new mac address appearing on wifi 
	newmac=$( tail -F /var/opt/unifi/tmp/logs/remote/192.168.2.35_aabbccddeeff.log | sed -un '/EVENT_STA_IP/!d;/192.168.3/{p;q}' | awk '{print $12}')
	
	# if mac address in our known mac addresses database
	if  grep -q $newmac /root/wifi-monitoring/wifi-knownmacs 
	then 
		# if it in today's file
		if grep -q $newmac /root/wifi-monitoring/wifi-todaysmacs
		then	
			echo 1 > /dev/null
		else
			#add mac address to today's file
			echo $newmac >> /root/wifi-monitoring/wifi-todaysmacs
			#get info from knownmacs db
			newclient=$(grep $newmac /root/wifi-monitoring/wifi-knownmacs | awk '{print $2}')
			echo "I see $newclient's mobile (with MAC $newmac) on our Wi-Fi network"
		fi;
	else 
		echo "I see unkonwn MAC $newmac on our Wi-Fi network"
	fi;
	
	# we stop wifi monitoring at 2 PM
	wifi_monitoring_stop=$(</root/wifi-monitoring/wifi-monitoring-stop)
	if [ "$wifi_monitoring_stop" = "1" ]; then break ; fi
	if [ $(date +%H) -gt 13 ]; then break ; fi
done

#clear file
echo > /root/wifi-monitoring/wifi-monitoring-stop

echo "Wifi monitoring stopped"
