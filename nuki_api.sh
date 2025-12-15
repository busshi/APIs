#!/bin/sh

API_URL="https://api.nuki.io/smartlock"

lock_or_unlock()
{
curl -s  -X POST -H 'Accept: application/json' -H "Authorization: Bearer $NUKI_API_TOKEN" "$API_URL/$NUKI_SENSOR_ID/action/$1"
}


case "$1" in
	"lock" | "unlock")
			lock_or_unlock $1
			;;
	*)
			echo "Usage: ./nuki.sh [lock|unlock]"
			exit 1
			;;
esac


exit 0
