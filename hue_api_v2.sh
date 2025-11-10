#!/bin/bash


[ "$1" = "hue" ] && BRIDGE=$HUE || BRIDGE="$1"


api_key=$( echo "$BRIDGE" | cut -d "/" -f5 )
bridge=$( echo "$BRIDGE" | cut -d "/" -f3 )

url="https://${bridge}/clip/v2"


get_sensor_id()
{
device_name="$1"
req=$( curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/device" | jq -r ".data[] | select(.metadata.name == \"$device_name\")" )
motion_id=$( echo "$req" | jq -r '.services[] | select(.rtype == "motion") | .rid ' )
echo $motion_id
}


sensors_off()
{
sensors=("$@")
for sensor_name in "${sensors[@]}"; do
	sensor_id=$( get_sensor_id "$sensor_name" )
	state=$( curl -s -k -X GET -H "hue-application-key: ${api_key}" "${url}/resource/motion/${sensor_id}" | jq -r .data[0].enabled )

	if [ "$state" != "false" ]; then
		curl -s -k -X PUT -H "hue-application-key: ${api_key}" -d '{"enabled": false}' "${url}/resource/motion/${sensor_id}"
		tg_api.sh sendMessage "$DomoticzBot" "$ChatLog" "🚷 ${sensor_name} OFF" mute
	fi
done
}


sensors_on()
{
curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/device" | jq -c '.data[] | select(.product_data.product_name == "Hue motion sensor") | {name: .metadata.name, services: .services[] | select(.rtype == "motion")}' | while read -r line
do
	sensor_name=$( echo "$line" | jq -r '.name' )
	sensor_id=$( echo "$line" | jq -r '.services.rid' )
	state=$( curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/motion/${sensor_id}" | jq -r .data[0].enabled )

	if [ "$state" != "true" ]; then
		curl -s -k -X PUT -H "hue-application-key: ${api_key}" -d '{"enabled": true}' "${url}/resource/motion/${sensor_id}"
		tg_api.sh sendMessage "$DomoticzBot" "$ChatLog" "🏃‍♂️‍➡️ $sensor_name auto ON" mute
	fi
done
}


outdoor_sensors_on()
{
curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/device" | jq -c '.data[] | select(.product_data.product_name == "Hue outdoor motion sensor") | {name: .metadata.name, services: .services[] | select(.rtype == "motion")}' | while read -r line
do
	sensor_name=$( echo "$line" | jq -r '.name' )
	sensor_id=$( echo "$line" | jq -r '.services.rid' )
	state=$( curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/motion/${sensor_id}" | jq -r .data[0].enabled )

	if [ "$state" != "true" ]; then
		curl -s -k -X PUT -H "hue-application-key: ${api_key}" -d '{"enabled": true}' "${url}/resource/motion/${sensor_id}"
		tg_api.sh sendMessage "$DomoticzBot" "$ChatLog" "🏃‍♂️‍➡️ $sensor_name auto ON" mute
        fi
done
}


get_scenes()
{
room_id="$1"
curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/scene?room_id=$room_id" | jq .data
}


get_rooms()
{
curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/room" | jq .data
}


get_room_id()
{
room_name="$1"
room_id=$( curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/room" | jq -r ".data[] | select(.metadata.name == \"$room_name\")" | jq -r .id )
echo $room_id
}


get_scene_id()
{
scene_name="$1"
scene_id=$( curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/scene" | jq -r ".data[] | select(.metadata.name == \"$scene_name\")" | jq -r .id )
echo $scene_id
}


toggle_scene()
{
state="$2"
scene_id="$1"
if [ "$state" = "on" ]; then
	curl -s -k -X PUT -H 'Content-Type': 'application/json' -H "hue-application-key: $api_key" "$url/resource/scene/$scene_id" -d '{"recall":{"action": "active"}}' > /dev/null
elif [ "$state" = "off" ]; then
	light_ids=$( curl -s -k -H "hue-application-key: $api_key" "$url/resource/scene/$scene_id" | jq -r '.data[0].actions[].target.rid')
	for light_id in $light_ids; do
		toggle_light "$light_id" off
	done
else
	echo 'Bad argument: should be "on" or "off"'
	exit 1
fi
}


toggle_light()
{
state="$2"
light_id="$1"
if [ "$state" = "off" ]; then
	curl -s -k -X PUT -H "hue-application-key: $api_key"  -H "Content-Type: application/json" "$url/resource/light/$light_id" -d '{"on":{"on": false}}' > /dev/null
elif [ "$state" = "on" ]; then
	curl -s -k -X PUT -H "hue-application-key: $api_key"  -H "Content-Type: application/json" "$url/resource/light/$light_id" -d '{"on":{"on": true}}' > /dev/null
else
	echo 'Bad argument: should be "on" or "off"'
	exit 1
fi
}

case "$2" in
        "sensors_on")
		"$2"
                outdoor_sensors_on
		;;
	"sensors_off")
		shift 2
		# Pass all sensors name as arguments, example: "Bedroom Sensor" "Kitchen Sensor"
		sensors_off "$@"
		;;
	"get_sensor_id")
		"$2" "$3"
		;;
        "get_room_id")
                "$2" "$3"
                ;;
        "get_scene_id")
                "$2" "$3"
                ;;
        "rooms")
		get_rooms
		;;
	"scenes")
		room_id=$( get_room_id "$3" )
		get_scenes $room_id
		;;
	"scene")
		scene_id=$( get_scene_id "$3" )
		toggle_scene "$scene_id" "$4"
		;;
	*)
		echo "Usage $0 [bridge] [scene | scenes | rooms | sensors_on | sensors_off | get_sensor_id | get_room_id | get_scene_id]"
		exit 1
		;;
esac


exit 0



