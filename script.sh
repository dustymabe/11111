#!/bin/bash
ignitionusers=()
afterburnusers=()
IGNITION="${IGNITION:-Ignition}"
AFTERBURN="${AFTERBURN:-AfterBurn}"
GET_ALL_SSH_AUTHORIZED_KEYS=`sudo ls -1 /{home/*/,root}/.ssh/authorized_keys.d/{ignition,afterburn} 2>/dev/null`

gather_data_for_ssh_authorized_keys(){
 if [[ $1 == "ignition" ]];then
   if [[ $2 == /home* ]];then
     ignitionusers+=$(cut -d'/' -f3 <<< "$2")", "
   else
     ignitionusers+="root, "
   fi
 elif [[ $1 == "afterburn" ]];then
   if [[ $2 == /home* ]];then
     afterburnusers+=$(cut -d'/' -f3 <<< "$2")", "
   else
     afterburnusers+="root, "
   fi
 else
     exit 1
 fi
}

generate_ui_for_ssh_authorized_keys(){
   output="ssh authorized keys were provided via ${1} for users: ${2}"
   echo "$(echo -n $output | head -c -1)" >> /run/console-login-helper-messages/issue.d/30_ssh_authorized_keys.issue
}for x in ${GET_ALL_SSH_AUTHORIZED_KEYS};
do
 provider=$(basename "$x")
 gather_data_for_ssh_authorized_keys $provider $x
done

if (( ${#ignitionusers[@]} )); then
   generate_ui_for_ssh_authorized_keys $IGNITION ${ignitionusers[@]}
fiif (( ${#afterburnusers[@]} )); then
   generate_ui_for_ssh_authorized_keys $AFTERBURN ${afterburnusers[@]}
fi
