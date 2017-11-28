#!/bin/bash 
 COUNTER=0
while [  $COUNTER -lt 5 ]; do
kill $(pgrep telegram-cli)
function print_logo() {
	echo -e "\e[38;5;77m"   
echo -e "       CH > @RELAX_MUSIC_4            "
echo -e "       CH > @RELAX_MUSIC_4           "
echo -e "       CH > @RELAX_MUSIC_4    "
echo -e "       CH > @RELAX_MUSIC_4     "
echo -e "       CH > @RELAX_MUSIC_4          \e[38;5;88m"
echo -e ""
echo -e ""
echo -e ""
echo -e "\e[33m        _____    _        _    _    _____    Dev @Tel_i_i56\e[0m"
echo -e "\e[33m       |_   _|__| |__    / \  | | _| ____|   Dev @Ayngel_K\e[0m"
echo -e "\e[33m         | |/ __| '_ \  / _ \ | |/ /  _|     Dev @TOTATY98\e[0m"
echo -e "\e[33m         | |\__ \ | | |/ ___ \|   <| |___    Dev @Alo0oshi_9\e[0m"
echo -e "\e[33m         |_||___/_| |_/_/   \_\_|\_\_____|   Dev @Jajsjsjssjjs\e[0m"
echo -e "\e[33m                                             Dev @kazzrr\e[0m"
}
sleep 2
if [ ! -f ./tg ]; then
echo -e ""
echo -e "\e[33m        _____    _        _    _    _____    Dev @Tel_i_i56"
echo -e "\e[33m       |_   _|__| |__    / \  | | _| ____|   Dev @Ayngel_K"
echo -e "\e[33m         | |/ __| '_ \  / _ \ | |/ /  _|     Dev @TOTATY98"
echo -e "\e[33m         | |\__ \ | | |/ ___ \|   <| |___    Dev @Alo0oshi_9"
echo -e "\e[33m         |_||___/_| |_/_/   \_\_|\_\_____|   Dev @Jajsjsjssjjs"
echo -e "\e[33m                                             Dev @kazzrr"
    echo "tg لا يوجد ملف"
    echo "Run $0 install"
    exit 1
 fi
 sleep 2
  print_logo
   echo -e ""
echo -e ""
echo -e "        \e[38;5;300mOperation | Starting Bot"
echo -e "        Source | TSHAKE Version 28 March 2017"
echo -e "        CH  | @RELAX_MUSIC_4"
echo -e "        Dev | @Tel_i_i56"
echo -e "        Dev | @Ayngel_K"
echo -e "        Dev | @TOTATY98"
echo -e "        Dev | @Alo0oshi_9"
echo -e "        Dev | @Jajsjsjssjjs"
echo -e "        Dev | @kazzrr"
echo -e "        \e[38;5;40m"

   ./tg -s ./BMW.lua
sleep 3
done
