#!/usr/bin/bash
generate_issue_message(){
   echo "ssh authorized keys were provided via ${1} for users: ${2}"
}
main() {

    ignitionusers=''
    afterburnusers=''

    # Check for keys for all users with a home directory
    for userhome in /home/*; do
        user=$(basename $userhome)
        if [ -f $userhome/.ssh/authorized_keys.d/ignition ];then
            ignitionusers+=" $user,"
        fi
        if [ -f $userhome/.ssh/authorized_keys.d/afterburn ];then
            afterburnusers+=" $user,"
        fi
    done

    # Check for keys for the root user
    userhome=/root
    user=root
    if [ -f $userhome/.ssh/authorized_keys.d/ignition ]; then
        ignitionusers+=" $user,"
    fi
    if [ -f $userhome/.ssh/authorized_keys.d/afterburn ]; then
        afterburnusers+=" $user,"
    fi

    # Pull trailing comma off the end of each string of users
    ignitionusers=${ignitionusers:0:-1}
    afterburnusers=${afterburnusers:0:-1}
    
    output=''
    if [ "$ignitionusers" != '' ]; then
        output+="$(generate_ui_for_ssh_authorized_keys Ignition "${ignitionusers}")"
    fi
    if [ "$afterburnusers" != '' ]; then
        output+="$(generate_ui_for_ssh_authorized_keys Afterburn "${afterburnusers}")"
    fi
    if [ -n $output ]; then
        echo "$output" > /run/console-login-helper-messages/issue.d/30_ssh_authorized_keys.issue
    else
        echo "No authorized keys provided by Ignition or Afterburn" \
             > /run/console-login-helper-messages/issue.d/30_ssh_authorized_keys.issue
    fi
}

main
