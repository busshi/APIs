#!/bin/bash -l

cmd()
{
cmd=0
[ "$1" = "ok" ] && cmd=352
[ "$1" = "netflix" ] && cmd=70
[ "$1" = "on" -o "$1" = "off" ] && cmd=116

[[ $cmd -gt 0 ]] && curl -s "${ORANGE}/remoteControl/cmd?operation=01&key=${cmd}&mode=0"
}

powerstate()
{
standby=$(curl -s "${ORANGE}/remoteControl/cmd?operation=10" | jq -r .result.data.activeStandbyState)
[ $standby -eq 1 -a "$1" = "on" ] && cmd on && echo -e "\nDecoder ON" && sleep 3 && cmd ok
[ $standby -eq 0 -a "$1" = "off" ] && cmd off && echo -e "\nDecoder OFF"
}


case "$1" in
	"on" | "off")
		powerstate "$1"
		;;
	"ok" | "netflix")
		cmd "$1"
		;;
	*)
		echo "Usage: ./orange.sh [ on | off | ok ]"
		;;
esac

exit 0
