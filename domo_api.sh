#!/bin/bash -l


get_device_idx()
{
curl -s $Domoticz'/json.htm?type=devices' | jq --arg IDX "$1" ' .result[] | select(.Name == $IDX )' | jq -r .idx
}

get_device_value()
{
curl -s $Domoticz'/json.htm?type=devices&rid='$1 | jq -r .result[].Data
}

update_device_value()
{
curl -s $Domoticz'/json.htm?type=command&param=udevice&idx='$1'&nvalue='$3'&svalue='$2
}

get_var_idx()
{
curl -s $Domoticz'/json.htm?type=command&param=getuservariables' | jq -r --arg VAR $1 '.result[] | select(.Name==$VAR) | .idx'
}

get_var_value()
{
curl -s $Domoticz'/json.htm?type=command&param=getuservariables' | jq -r --arg NAME "$1" '.result[] | select(.Name==$NAME) | .Value'
}

update_var_value()
{
curl -s $Domoticz'/json.htm?type=command&param=updateuservariable&vname='$1'&vtype='$3'&vvalue='$2
}

change_state()
{
idx=$(get_device_idx "$2")
curl -s $Domoticz'/json.htm?type=command&param=switchlight&idx='${idx}'&switchcmd='$1
}

case "$1" in
	"get_device_idx" | "get_device_value" | "get_var_idx" | "get_var_value")
		"$1" "$2"
		;;
	"update_device_value" | "update_var_value")
		"$1" "$2" "$3" "$4"
		;;
	"On" | "Off" | "Toggle")
		change_state "$1" "$2"
		;;
	*)
		echo "Usage: domo_api.sh [toogle <device_name> | get_device_idx <name> | get_device_value <idx> | update_device_value <idx> <value> <type> | get_var_idx <name> | get_var_value <name> | update_var_value <name> <value> <type>]"
		;;
esac

exit 0
