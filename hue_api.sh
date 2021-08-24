#!/bin/bash

case "$1" in
	"maison")
		cmd=0
		;;
        "salon")
		cmd=6
		;;
   	"cuisine")
		cmd=4
		;;
	"chambre")
		cmd=2
		;;
	"robin")
		cmd=12
		;;
	"alarme")
		requete=$( curl -X GET $HUE/lights/4 )
		etat=$( echo $requete | jq .state.on )
		bri=$( echo $requete | jq .state.bri )
		hue=$( echo $requete | jq .state.hue )
		sat=$( echo $requete | jq .state.sat )
		curl -X PUT -d '{"on":true,"bri":254,"hue":0,"sat":254,"alert":"select"}' $HUE/lights/4/state
		sleep 5
		if [ $etat = "false" ] ; then
			curl -X PUT -d '{"on":false}' $HUE/lights/4/state
		else
			curl -X PUT -d '{"on":true,"bri":'$bri',"hue":'$hue',"sat":'$sat',"alert":"none"}' $HUE/lights/4/state
		fi
		exit 0
		;;
	*)
		echo "Mauvaise syntaxe => ./hue.sh <salon|cuisine|chambre|robin|muscu|maison> <on|off>"
		exit 1
		;;
esac

case "$2" in
	"off")
		cmd2=false}
		;;
	"on")
		cmd2=true}
		;;
	*)
		if [ ! $1 = "alarme" ] ; then
			echo "Mauvaise syntaxe => ./hue.sh <salon|cuisine|chambre|robin|muscu|maison> <on|off>"
			exit 1
		fi
		;;
esac

curl -X PUT -d '{"on":'$cmd2 $HUE/groups/$cmd/action


if [ "$1" = "maison" ] && [ "$2" = "off" ] ; then
#	for name in "Lumière Entrée" "Lumière Couloir" "Lumière Salle de Bain" "Lumière WC" ; do
#		idx=$( domo_api.sh get_device_idx "$name" )
#		curl -s $Domoticz'/json.htm?type=command&param=switchlight&idx='$idx'&switchcmd=Off'
#	done
	ambilight.sh off
	ambilight2.sh off
fi

exit 0



