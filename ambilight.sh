#!/bin/bash

file="${API}/.loginTV"

randomString()
{
    xxd -l16 -ps /dev/urandom | base64 | cut -c1-32
}

signature()
{
    echo -n "$1" | openssl dgst -sha1 -hmac "$2" -binary | base64
}

deviceSpecJson()
{
    echo "{ \"app_id\": \"gapp.id\", \"id\":\"$1\", \"device_name\" : \"heliotrope\", \"device_os\" : \"Android\", \"app_name\" : \"ApplicationName\", \"type\" : \"native\" }"
}

pair()
{
    deviceId=$(randomString 16)
    device=$(deviceSpecJson $deviceId)
    data="{ \"device\": $device, \"scope\": [\"read\", \"write\", \"control\"] }"
    response=$(curl -s -k -X POST "$TVIP/pair/request" --data "$data")

    auth_key=$(echo $response | jq .auth_key | tr -d '"')
    timestamp=$(echo $response | jq .timestamp | tr -d '"')
    timeout=$(echo $response | jq .timeout | tr -d '"')

    echo "Tape le code PIN visible sur la TV :"
    read pin

    secret_key="ZmVay1EQVFOaZhwQ4Kv81ypLAZNczV9sG4KkseXWn1NEk6cXmPKO/MCa9sryslvLCFMnNe4Z4CPXzToowvhHvA=="
    auth_timestamp="$timestamp$pin"
    case "$OSTYPE" in
      linux*)  auth_key_s=$(echo $secret_key | base64 -d) ;;
      darwin*)  auth_key_s=$(echo $secret_key | base64 -D) ;;
    esac
    signature=$(signature $auth_key_s $auth_timestamp)

    auth="{\"device\":{\"device_name\":\"heliotrope\",\"device_os\":\"Android\",\"app_name\":\"ApplicationName\",\"type\":\"native\",\"app_id\":\"app.id\",\"id\":\"$deviceId\"},\"auth\":{\"auth_AppId\":\"1\",\"pin\":$pin,\"auth_timestamp\":\"$auth_timestamp\",\"auth_signature\":\"$signature\"}}"
    response=$(curl -k -s --digest --user $deviceId:$auth_key -X POST "$TVIP/pair/grant" --data "$auth")

    echo "$deviceId:$auth_key" > $file
}

get()
{
curl -k -s --digest --user $mdp -X GET $TVIP$1 || curl -k -s --digest --user $mdp -X GET $TVIP2$1
}

post()
{
curl -k -s --digest --user $mdp -X POST $TVIP$1 || curl -k -s --digest --user $mdp -X POST $TVIP2$1
}

app()
{
curl -k -s --digest --user $mdp -X POST "${TVIP}/activities/launch" -d "$1" || curl -k -s --digest --user $mdp -X POST "${TVIP2}/activities/launch" -d "$1"
}


[ ! -f $file ] && pair

mdp=$( cat "$file" )

power_on()
{
status=$( get "/powerstate" | jq -r ' .powerstate ' )
if [ "$status" != "On" ] ; then
	post "/input/key -d {\"key\":\"Standby\"}"
#	post "/input/key -d {\"key\":\"WatchTV\"}"
        sleep 1
        post "/ambilight/currentconfiguration -d {\"styleName\":\"FOLLOW_VIDEO\",\"isExpert\":\"false\",\"menuSetting\"=\"NATURAL\"}"
        sleep 2
#        post "/input/key -d {\"key\":\"WatchTV\"}"
        domo_api.sh update_var_value "TVpowerstate" "On" "2"
#        [[ $(date +%H | bc) -ge 22 -o $(date +%H | bc) -lt 8 ] && ambilight.sh vol10
fi
}

case "$1" in
	"on")
		power_on
	#	status=$( get "/powerstate" | jq -r ' .powerstate ' )
	#	if [ "$status" = "Off" -o "$status" = "Standby" ] ; then
#			curl http://192.168.1.135:8008/apps/ChromeCast -X POST
			#post "/apps/ChromeCast"
	#		post "/input/key -d {\"key\":\"WatchTV\"}"
	#		sleep 1
	#		post "/ambilight/currentconfiguration -d {\"styleName\":\"FOLLOW_VIDEO\",\"isExpert\":\"false\",\"menuSetting\"=\"NATURAL\"}"
	#		sleep 2
	#		post "/input/key -d {\"key\":\"WatchTV\"}"
	#		updateVAR On
	#		[ $(date +%H | bc) -ge 22 -o $(date +%H | bc) -lt 8 ] && ambilight.sh vol10
	#	fi
		;;
        "off")
		status=$( get "/powerstate" | jq -r .powerstate )
	        if [ "$status" = "On" ] ; then
			post "/input/key -d {\"key\":\"Standby\"}"
			domo_api.sh update_var_value "TVpowerstate" "Standby" "2"
#			sleep 5
#			post "/menuitems/settings/update -d {\"values\":[{\"value\":{\"Nodeid\":2131230774,\"Controllable\":\"true\",\"available\":\"true\",\"data\":{\"value\":\"false\"}}}]}"
		fi
		;;
#	"allow_power_on")
 #		post "/menuitems/settings/update -d {\"values\":[{\"value\":{\"Nodeid\":2131230736,\"data\":{\"selected_item\":1}}}]}"
#		;;
	"volume")
		get "/audio/volume" | jq .current
		;;
        "+")
                post "/input/key -d {\"key\":\"VolumeUp\"}"
                post "/input/key -d {\"key\":\"VolumeUp\"}"
		;;
        "-")
                post "/input/key -d {\"key\":\"VolumeDown\"}"
		post "/input/key -d {\"key\":\"VolumeDown\"}"
                ;;
        "mute")
                post "/input/key -d {\"key\":\"Mute\"}"
                ;;
        "ok")
                post "/input/key -d {\"key\":\"Confirm\"}"
                ;;
        "back")
                post "/input/key -d {\"key\":\"Back\"}"
                ;;
	"rewind")
		post "/input/key -d {\"key\":\"Rewind\"}"
		;;
	"forward")
		post "/input/key -d {\"key\":\"FastForward\"}"
		;;
	"prev")
		post "/input/key -d {\"key\":\"Previous\"}"
		;;
	"next")
		post "/input/key -d {\"key\":\"Next\"}"
		;;
        "play")
                post "/input/key -d {\"key\":\"Play\"}"
                ;;
        "pause")
                post "/input/key -d {\"key\":\"Pause\"}"
                ;;
        "stop")
                post "/input/key -d {\"key\":\"Stop\"}"
                ;;
        "++")
                post "/input/key -d {\"key\":\"ChannelStepUp\"}"
                ;;
        "--")
                post "/input/key -d {\"key\":\"ChannelStepDown\"}"
                ;;
	"options")
		post "/input/key -d {\"key\":\"Options\"}"
		;;
	"info")
		post "/input/key -d {\"key\":\"Info\"}"
		;;
        "home")
                post "/input/key -d {\"key\":\"Home\"}"
                ;;
	"source")
		post "/input/key -d {\"key\":\"Source\"}"
		;;
	"tv")
		post "/input/key -d {\"key\":\"WatchTV\"}"
		;;
        "h")
                post "/input/key -d {\"key\":\"CursorUp\"}"
                ;;
        "b")
                post "/input/key -d {\"key\":\"CursorDown\"}"
                ;;
        "g")
                post "/input/key -d {\"key\":\"CursorLeft\"}"
                ;;
        "d")
                post "/input/key -d {\"key\":\"CursorRight\"}"
                ;;
	"green")
		post "/input/key -d {\"key\":\"GreenColour\"}"
		;;
	"yellow")
		post "/input/key -d {\"key\":\"YellowColour\"}"
		;;
	"red")
		post "/input/key -d {\"key\":\"RedColour\"}"
		;;
	"blue")
		post "/input/key -d {\"key\":\"BlueColour\"}"
		;;
        "ambi")
                post "/ambilight/currentconfiguration -d {\"styleName\":\"FOLLOW_VIDEO\",\"isExpert\":\"false\",\"menuSetting\"=\"NATURAL\"}"
                ;;
        "ambiOff")
                post "/ambilight/power -d {\"power\":\"off\"}"
                ;;
        "hue")
                post "/menuitems/settings/update -d {\"values\":[{\"value\":{\"Nodeid\":2131230774,\"Controllable\":\"true\",\"available\":\"true\",\"data\":{\"value\":\"true\"}}}]}"
                ;;
        "hueOff")
                post "/menuitems/settings/update -d {\"values\":[{\"value\":{\"Nodeid\":2131230774,\"Controllable\":\"true\",\"available\":\"true\",\"data\":{\"value\":\"false\"}}}]}"
                ;;
        "lounge")
                post "/ambilight/lounge -d {\"color\":{\"hue\":110,\"saturation\":38,\"brightness\":255},\"colordelta\":{\"hue\":0,\"saturation\":1,\"brightness\":0},\"speed\":20,\"mode\":\"Default\"}"
                sleep 3
		post "/menuitems/settings/update -d {\"values\":[{\"value\":{\"Nodeid\":2131230774,\"Controllable\":\"true\",\"available\":\"true\",\"data\":{\"value\":\"true\"}}}]}"
                ;;
	"sieste")
                post "/ambilight/lounge -d {\"color\":{\"hue\":20,\"saturation\":254,\"brightness\":50},\"colordelta\":{\"hue\":0,\"saturation\":1,\"brightness\":0},\"speed\":20,\"mode\":\"Default\"}"
                sleep 3
		post "/menuitems/settings/update -d {\"values\":[{\"value\":{\"Nodeid\":2131230774,\"Controllable\":\"true\",\"available\":\"true\",\"data\":{\"value\":\"true\"}}}]}"
                ;;
	"molotov")
#		app '{"id":"tv.molotov.app","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=tv.molotov.app }","component":{"packageName":"tv.molotov.app","className":"tv.molotov.android.ui.common.splash.SplashActivity"}},"label":"Molotov"}'
		app '{"id":"tv.molotov.app","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=tv.molotov.app }","component":{"packageName":"tv.molotov.app","className":"tv.molotov.android.splash.SplashActivity"}},"label":"Molotov"}'
		;;
	"netflix")
		app '{"id":"com.netflix.ninja","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.netflix.ninja }","component":{"packageName":"com.netflix.ninja","className":"com.netflix.ninja.MainActivity"}},"label":"Netflix"}'
		;;
        "prime")
 		app '{"id":"com.amazon.amazonvideo.livingroom","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.amazon.amazonvideo.livingroom }","component":{"packageName":"com.amazon.amazonvideo.livingroom","className":"com.amazon.ignition.IgnitionActivity"}},"label":"Prime Video"}'
		;;
	"kodi")
		app '{"id":"org.xbmc.kodi","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=org.xbmc.kodi }","component":{"packageName":"org.xbmc.kodi","className":"org.xbmc.kodi.Splash"}},"label":"Kodi"}'
		;;
	"youtube")
		app '{"id":"com.google.android.apps.youtube.tv.activity.ShellActivity-com.google.android.youtube.tv","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.google.android.youtube.tv cmp=com.google.android.youtube.tv/com.google.android.apps.youtube.tv.activity.ShellActivity }","component":{"packageName":"com.google.android.youtube.tv","className":"com.google.android.apps.youtube.tv.activity.ShellActivity"}},"label":"YouTube"}'
		;;
	"canal")
		app '{"id":"com.canal.android.canal","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.canal.android.canal }","component":{"packageName":"com.canal.android.canal","className":"com.canal.ui.tv.TvMainActivity"}},"label":"Canal"}'
		;;
	"plex")
             	app '{"id":"com.plexapp.android","order":0,"intent":{"action":"Intent{act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.plexapp.android }","component":{"packageName":"com.plexapp.android","className":"com.plexapp.plex.activities.SplashActivity"}},"label":"Plex"}'
		;;
       	"powerstate")
		get "/powerstate" | jq -r .powerstate
		;;
	"config")
		get "/menuitems/settings/structure"
		;;
	"appli")
		get "/activities/current"
		;;
	"ambiHueStatus")
		get "/menuitems/settings/current -d {\"nodes\":[{\"nodeid\":2131230774}]}" |  jq '.values[].value.data.value'
		;;
	"ambiconfig")
		get "/ambilight/currentconfiguration" | jq -r .styleName
		;;
	"system")
		get "/system"
		;;
	"update")
		check=$( get "/powerstate" | jq -r '.powerstate' )
		updateVAR "$check"
		;;
	"goto_sleep")
#		orange_decoder.sh off
		power_on &
		sleep 15
		vol=$( get "/audio/volume" | jq .current )
		while [[ $vol -gt 10 ]] ; do
			post "/input/key -d {\"key\":\"VolumeDown\"}"
			vol=$(( $vol - 1 ))
		done
		;;
        *)
                echo "Usage: ./ambilight.sh [command]"
                exit 1
                ;;
esac

exit 0
