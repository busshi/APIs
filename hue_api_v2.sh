#!/bin/bash


[ -z $1 ] && { echo "Missing bridge argument"; exit 1; }

api_key=$( echo "$1" | cut -d "/" -f5 )

bridge=$( echo "$1" | cut -d "/" -f3 )

url="https://${bridge}/clip/v2"



check_sensors()
{
curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/device" | jq -r '.data[] | select(.product_data.product_name == "Hue motion sensor") | . as $parent | .services[] | select(.rtype == "motion") | .rid' | while read -r sensor_id
do
   	state=$( curl -s -k -X GET -H "hue-application-key: $api_key" "$url/resource/motion/$sensor_id" | jq -r .data[0].enabled )
	if [ "$state" != "true" ]; then
		curl -s -k -X PUT -H "hue-application-key: $api_key" -d '{"enabled": true}' "$url/resource/motion/$sensor_id"
#		name=$( curl -s -k -X GET "hue-application-key: $api_key" "$url/resource/device/$sensor_id")
#		echo "name $name"
		tg_api.sh sendMessage "$DomoticzBot" "$ChatLog" "Capteur auto ON" mute
	fi
done
}

case "$2" in
        "sensors")
		check_sensors
		;;
	*)
		echo "Usage ./hue_api_v2.sh [bridge]"
		exit 1
		;;
esac


exit 0



