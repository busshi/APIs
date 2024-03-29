#!/bin/sh

API_URL="https://api.netatmo.com/api"
TOKEN_URL="https://api.netatmo.com/oauth2/token"


refresh_token() {
	refresh_token=$( domo_api.sh get_var_value "netatmo_refresh" )

	req=$( curl -s -d "grant_type=refresh_token" -d "refresh_token=${refresh_token}" -d "client_id=${NETATMO_CLIENT_ID}" -d "client_secret=${NETATMO_CLIENT_SECRET}" "$TOKEN_URL" )

	new_refresh_token=$( echo "$req" | jq -r .refresh_token )
	new_token=$( echo "$req" | jq -r .access_token )

	if [ -n "$new_refresh_token" -a -n "$new_token" ]; then
		# update refresh token in db
		domo_api.sh update_var_value "netatmo_refresh" "$new_refresh_token" 2
		domo_api.sh update_var_value "netatmo_api" "$new_token" 2
		echo "Variables updated!"
	else
		echo "Error: $req"
		exit 1
	fi
}

get_token() {
	token=$( domo_api.sh get_var_value "netatmo_api" )
}

switch_thermostat_schedule() {
	get_token
	req=$(curl -s -X POST "${API_URL}/switchhomeschedule?home_id=${NETATMO_HOME_ID}&schedule_id=${schedule_id}" -H "accept: application/json" -H "Authorization: Bearer ${token}")
[ "$( echo $req | jq -r .status )" = "ok" ] && echo "[ OK ] Switched $1." || { refresh_token; switch_thermostat_schedule "$1"; }
}

set_thermostat_mode() {
	get_token
        req=$(curl -s -X POST "${API_URL}/setthermmode?home_id=${NETATMO_HOME_ID}&mode=${therm_mode}" -H "accept: application/json" -H "Authorization: Bearer ${token}")
[ "$( echo $req | jq -r .status )" = "ok" ] && echo "[ OK ] Switched $1." || { refresh_token; set_thermostat_mode "$1"; }
}

case "$1" in
	"away")
			#schedule_id=${NETATMO_AWAY_SCHEDULE_ID}
			therm_mode="away"
			;;
	"home")
			#schedule_id=${NETATMO_HOME_SCHEDULE_ID}
			therm_mode="schedule"
			;;
	"hg")
			therm_mode="hg"
			;;
	*)
			echo "Usage: ./netatmo.sh [home | away]"
			exit 1
			;;
esac

#switch_thermostat_schedule
set_thermostat_mode "$1"

exit 0
