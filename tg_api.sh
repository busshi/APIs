#!/bin/bash

case "$1" in
   "sendMessage")
        if [ "$5" = "mute" ] ; then
                curl -s -d "chat_id=$3" -d 'disable_notification=true' --data-urlencode "text=$4" 'https://api.telegram.org/bot'$2'/'$1
        else
                curl -s -d "chat_id=$3" --data-urlencode "text=$4" 'https://api.telegram.org/bot'$2'/'$1
        fi
        ;;
   "sendPhoto")
        curl -s -X POST 'https://api.telegram.org/bot'$2'/'$1 -F chat_id=$3 -F parse_mode=HTML -F caption="$5" -F photo="$4"
        ;;
   "sendVideo")
	curl -X POST 'https://api.telegram.org/bot'$2'/'$1 -F chat_id=$3 -F video='@'"$4"
	;;
   "sendDocument")
        curl -s -F 'chat_id='$3 'https://api.telegram.org/bot'$2'/'$1 -F 'document=@'"$4"
        ;;
   "sendSticker")
        curl -s -X POST 'https://api.telegram.org/bot'$2'/'$1 -F "sticker=$4" -F "chat_id=$3"
        ;;
   "sendDice")
        curl -s -X POST 'https://api.telegram.org/bot'$2'/'$1 -F "emoji=$4" -F "chat_id=$3"
        ;;
   "sendPoll")
        curl -s -X POST 'https://api.telegram.org/bot'"$2"'/'"$1"'?chat_id='"$3"'&question='"$4"'&options=%5B'"$5"'%5D&is_anonymous=False&disable_notification=True'
        ;;
   "inlineKb")
#	kb='{"text":"1","callback_data":"done"}'
	curl -s -k -X POST -H 'Content-Type: application/json' --data "{\"text\":\"$4\", \"chat_id\":\"$3\", \"reply_markup\":{\"inline_keyboard\":[[$5]]}}" "https://api.telegram.org/bot$2/sendMessage"
	;;
   "removeKb")
        curl -s -k -X POST -H 'Content-Type: application/json' --data '{"text":"🕳", "chat_id":"'$3'", "reply_markup":{"remove_keyboard":true}}' 'https://api.telegram.org/bot'$2'/sendMessage'
        ;;
   "forceReply")
        curl s -k -X POST -H 'Content-Type: application/json' --data '{"text":"'$4'", "chat_id":"'$3'", "reply_to_msg_id": "'$5'", "reply_markup":{"force_reply":true, "selective":true}}' 'https://api.telegram.org/bot'$2'/sendMessage'
        ;;
   "kick")
        curl -s -X POST 'https://api.telegram.org/bot'$BusshiBot'/KickChatMember' -d '{"chat_id": "'$1'", "user_id": '$2'}'
        ;;
   *)
        echo "Mauvaise syntaxe => actions.sh <sendMessage|sendPhoto|sendDocument|sendSticker|sendDice|sendPoll|inlineKb|removeKb|forceReply|kick> <BotToken> <Dest> <message|question|msg_id|...>"
        ;;
esac

exit 0


