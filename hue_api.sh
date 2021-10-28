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
[ "$state" = "on" ] && state="true" || state="false"
curl -X PUT -d "{\"on\":${state}}" ${HUE}/groups/${idx}/action
}


toggle_home()
{
if [ "$2" != "on" -a "$2" != "off" ]; then
	echo "Usage: ./hue_api.sh maison [on|off]"
	exit 1
else
	idx=0
	state="$2"
	toggle
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

[ -n "$idx" ] && toggle || echo -e "[${room}] not found!!\nUsage: './hue_api.sh list' to list all available rooms"
}



case "$1" in
	"list")
		list_room
		;;
	"maison")
		toggle_home "$1" "$2"
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



if [ "$1" = "maison" ] && [ "$2" = "off" ] ; then
	ambilight.sh off
	ambilight2.sh off
fi


exit 0



