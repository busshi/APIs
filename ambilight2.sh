#!/bin/bash -l

get()
{
curl -k -s -X GET $TV2IP$1 || curl -k -s -X GET $TV2IP2$1
}

post()
{
curl -k -s -X POST $TV2IP$1 || curl -k -s -X POST $TV2IP2$1
}

app()
{
curl -k -s -X POST $TV2IP"/activities/launch" -d "$1" || curl -k -s -X POST $TV2IP2"/activities/launch" -d "$1"
}



case "$1" in
	"allow_power_on")
		post "/menuitems/settings/update -d {\"values\":[{\"value\":{\"Nodeid\":2131230736,\"data\":{\"selected_item\":1}}}]"
		;;
	"on")
		status=$( get "/powerstate" | jq -r ' .powerstate ' )
		if [ "$status" = "Off" -o "$status" = "Standby" ] ; then
			post "/input/key -d {\"key\":\"Standby\"}"
			sleep 2
			post "/ambilight/currentconfiguration -d {\"styleName\":\"FOLLOW_VIDEO\",\"isExpert\":\"false\",\"menuSetting\"=\"NATURAL\"}"
			sleep 1
			post "/input/key -d {\"key\":\"WatchTV\"}"
		        orange_decoder.sh on
                        h=$( date +%H | bc )
                        [ $h -lt 6 -o $h -gt 18 ] && { sleep 2; post "/HueLamp/power -d {\"power\":\"On\"}"; } || { sleep 2; post "/HueLamp/power -d {\"power\":\"Off\"}"; }
			domo_api.sh update_var_value "TV2powerstate" "On" "2"
		fi
                ;;
        "off")
		status=$( get "/powerstate" | jq -r .powerstate )
	        if [ "$status" = "On" ] ; then
			post "/HueLamp/power -d {\"power\":\"Off\"}"
			sleep 2
			post "/input/key -d {\"key\":\"Standby\"}"
			domo_api.sh update_var_value "TV2powerstate" "Standby" "2"
		fi
		orange_decoder.sh off
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
	"tv")
		post "/input/key -d {\"key\":\"WatchTV\"}"
		;;
        "ambi")
                post "/ambilight/currentconfiguration -d {\"styleName\":\"FOLLOW_VIDEO\",\"isExpert\":\"false\",\"menuSetting\"=\"NATURAL\"}"
                ;;
 #       "ambiOff")
#		post "ambilight/currentconfiguration -d {\"styleName\":\"OFF\", \"isExpert\":\"false\"}"
 #               post "/HueLamp/power -d {\"power\":\"Off\"}"
  #              ;;
        "hue")
		post "/HueLamp/power -d {\"power\":\"On\"}"
                ;;
        "hueOff")
		post "/HueLamp/power -d {\"power\":\"Off\"}"
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
		get "/HueLamp/power" | jq -r '.power'
		;;
	"ambiconfig")
		get "/ambilight/currentconfiguration" | jq -r .styleName
		;;
	"system")
		get "/system"
		;;
	"update")
		check=$( get "/powerstate" | jq -r '.powerstate' )
		domo_api.sh update_var_value "TV2powerstate" "$check" "2"
		;;
        *)
                echo "Mauvais paramètre... => ambilight2.sh [commande]"
                exit 1
                ;;
esac

exit 0

