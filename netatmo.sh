#!/bin/sh

API_URL="https://api.netatmo.com/api"
TOKEN_URL="https://api.netatmo.com/oauth2/token"


refresh_token() {
	refresh_token=$( domo_api.sh get_var_value "netatmo_token" )

	req=$( curl -s -X POST -d "grant_type=refresh_token" -d "refresh_token=${refresh_token}" -d "client_id=${NETATMO_CLIENT_ID}" -d "client_secret=${NETATMO_CLIENT_SECRET}" "$TOKEN_URL" )

	new_refresh_token=$( echo "$req" | jq -r .refresh_token )
	new_token=$( echo "$req" | jq -r .access_token )

	# update refresh token in db
	domo_api.sh update_var_value "netatmo_refresh" "$new_refresh_token" 2
	domo_api.sh update_var_Value "netatmo_token" "$new_token" 2
}

switch_thermostat_schedule() {
	token=$( domo_api.sh get_var_value "netatmo_token" )

	req=$(curl -X POST "${API_URL}/switchhomeschedule?home_id=${NETATMO_HOME_ID}&schedule_id=${schedule_id}" -H "accept: application/json" -H "Authorization: Bearer ${token}")
[ "$( echo $req | jq -r .status )" = "ok" ] && echo "[ OK ]" || { refresh_token; switch_thermostat_schedule; }
}

case "$1" in
	"away")
			schedule_id=${NETATMO_AWAY_SCHEDULE_ID}
			;;
	"home")
			schedule_id=${NETATMO_HOME_SCHEDULE_ID}
			;;
	*)
			echo "Usage: ./netatmo.sh [home | away]"
			exit 1
			;;
esac

switch_thermostat_schedule


exit 0
