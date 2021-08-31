#!/bin/bash


[ -z $3 ] && duree=5 || duree=$3
[ -z $4 ] && position=1 || position=$4

case "$5" in
   "rouge")
	couleur="#FF0000"
	;;
   "bleu")
	couleur="#0000FF"
	;;
   "vert")
	couleur="#00FF00"
	;;
   *)
	couleur="#FFFFFF"
	;;
esac

if [ -z "$1" ] || [ -z "$2" ] ; then
	echo "Usage: tv.sh <Titre> <Message> <Durée> <Position : 0 HD|1 HG|2 BD|3 BG|4 Centre> <couleur : rouge|bleu|vert>"
	exit 1
fi

case "$1" in
   "boubou")
	curl -s -H "Content-Type; application/json" -X POST $PIPUP/notify -d '{"message": "'$2'", "messageSize": "'$3'", "position": 1, "duration": 2, "backgroundColor": "#00000000"}'
	;;
   *)
	data=$( cat $API/.notif.json | sed "s/titre/$1/" | sed "s/msg/$2/" | sed "s/duree/$duree/" | sed "s/endroit/$position/" | sed "s/couleur/$couleur/")
	curl -s --header "Content-Type: application/json" -X POST $PIPUP/notify -d "$data"
	;;
esac


exit 0

