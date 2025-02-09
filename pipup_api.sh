#!/bin/bash


[ -z $3 ] && duration=5 || duration=$3
[ -z $4 ] && position=1 || position=$4

case "$5" in
   "red")
	color="#FF0000"
	;;
   "blue")
	color="#0000FF"
	;;
   "green")
	color="#00FF00"
	;;
   *)
	color="#FFFFFF"
	;;
esac

if [ -z "$1" ] || [ -z "$2" ] ; then
	echo "Usage: pipup_api.sh <Title> <Message> <Duration> < Position : 0 TopRight | 1 TopLeft | 2 BottonRight | 3 BottomLeft | 4 Center > < color : red|blue|green >"
	exit 1
fi

case "$1" in
   "kids")
	curl -s -H "Content-Type: application/json" -X POST ${PIPUP}/notify -d '{"message": "'$2'", "messageSize": "'$3'", "position": 1, "duration": 2, "backgroundColor": "#00000000"}' ||  curl -s -H "Content-Type: application/json" -X POST ${PIPUP2}/notify -d '{"message": "'$2'", "messageSize": "'$3'", "position": 1, "duration": 2, "backgroundColor": "#00000000"}'
	;;
   *)
	sample="{\"title\":\"TITLE\",\"message\":\"MESSAGE\",\"duration\":DURATION,\"position\":POSITION,\"titleSize\":20,\"titleColor\":\"COLOR\",\"messageSize\":16,\"backgroundColor\":\"#CC000000\"}"
	data=$( echo "$sample" | sed "s/TITLE/$1/" | sed "s/MESSAGE/$2/" | sed "s/DURATION/$duration/" | sed "s/POSITION/$position/" | sed "s/COLOR/$color/" )
	curl -s -H "Content-Type: application/json" -X POST ${PIPUP}/notify -d "$data" || curl -s -H "Content-Type: application/json" -X POST ${PIPUP2}/notify -d "$data"
	;;
esac


exit 0

