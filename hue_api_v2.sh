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

case "$2" in
        "sensors_on")
		"$2"
		;;
	"sensors_off")
		shift 2
		# Pass all sensors name as arguments, example: "Bedroom Sensor" "Kitchen Sensor"
		sensors_off "$@"
		;;
	"get_sensor_id")
		"$2" "$3"
		;;
	*)
		echo "Usage $0 [bridge] [sensors_on | sensors_off | get_sensor_id]"
		exit 1
		;;
esac


exit 0



