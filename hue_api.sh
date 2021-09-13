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
		r=$( curl -X GET ${HUE}/lights/4 )
		state=$( echo $r | jq .state.on )
		bri=$( echo $r | jq .state.bri )
		hue=$( echo $r | jq .state.hue )
		sat=$( echo $r | jq .state.sat )
		curl -X PUT -d '{"on":true,"bri":254,"hue":0,"sat":254,"alert":"select"}' ${HUE}/lights/4/state
		sleep 5
		if [ "$state" = "false" ] ; then
			curl -X PUT -d '{"on":false}' ${HUE}/lights/4/state
		else
			curl -X PUT -d '{"on":true,"bri":'${bri}',"hue":'${hue}',"sat":'${sat}',"alert":"none"}' ${HUE}/lights/4/state
		fi
		exit 0
		;;
	*)
		echo "Usage: ./hue_api.sh <salon|cuisine|chambre|robin|muscu|maison> <on|off>"
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
			echo "Usage: ./hue_api.sh <salon|cuisine|chambre|robin|muscu|maison> <on|off>"
			exit 1
		fi
		;;
esac

curl -X PUT -d '{"on":'${cmd2} ${HUE}/groups/${cmd}/action


if [ "$1" = "maison" ] && [ "$2" = "off" ] ; then
	ambilight.sh off
	ambilight2.sh off
fi

exit 0



