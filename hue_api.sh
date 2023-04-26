#!/bin/bash

list_room()
{
for id in $(seq 1 20); do
	room=$(curl -s -X GET $HUE/groups | jq . | grep "\"$id\"" -A1 | grep name | cut -d\" -f4)
	[ "$room" != "" ] && echo "$id: $room"
done
exit 0
}


toggle()
{
idx=$1
[ "$2" = "on" ] && state="true" || state="false"
curl -X PUT -d "{\"on\":${state}}" ${HUE}/groups/${idx}/action
}


toggle_home()
{
if [ "$1" = "maison" ] && [ "$2" = "off" ] ; then
        ambilight.sh off
        ambilight2.sh off
fi


if [ "$1" != "on" -a "$1" != "off" ]; then
	echo "Usage: ./hue_api.sh maison [on|off]"
	exit 1
#else
##	idx=0
##	state="$1"
#        toggle $(get_idx "En haut") off
#        toggle $(get_idx "En bas") off
fi
}



get_idx()
{
room="$1"

[ -z "$2" ] && { echo "Usage: ./hue_api.sh [room_name] [on|off]"; exit 1; }
state="$2"

while read line; do
	check=$(echo $line | grep -i "$room")
	[ "$check" != "" ] && { idx=$( echo $check | cut -d: -f1 ) && break; }
done <<< $(list_room)

[ -n "$idx" ] && toggle "$idx" "$state" || echo -e "[${room}] not found!!\nUsage: './hue_api.sh list' to list all available rooms"
}

check_salon_sensor()
{
state=$(curl -s $HUE/sensors/32 | jq -r .config.on)
#new_state=true
#[ "$state" = "false" ] && curl -X PUT $HUE/sensors/32/config -d "{\"on\": ${new_state}}"
[ "$1" = "on" ] && new_state=true || new_state=false
[ "$state" = "false" ] && curl -X PUT $HUE/sensors/32/config -d "{\"on\": $new_state}"
}


case "$1" in
        "sensor")
		check_salon_sensor $2
		;;
	"list")
		list_room
		;;
	"maison")
		toggle_home "$2"
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
		;;
	*)
		get_idx "$1" "$2"
		;;
esac



exit 0



