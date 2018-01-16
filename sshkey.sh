#!/bin/bash
#
# Script by: Leon de Jong, CloudVPS
#
# This script downloads the key of CloudVPS to the server running this script to allow support access for 24h
#variables, can change later. the top 3 would be simple id say.
KEYLOCATION=https://download.cloudvps.com/current_key
SSHFOLDER=~/.ssh
AUTHORIZEDKEYS="authorized_keys"
#variable to store date and use it later
DATE="$(date)"
EPOCH=$(date +%s)
#tag we put after the key
CLOUDVPSKEYNAME="CloudVPS-key"
#easy way to echo local user later
LOGGEDINUSER=$(whoami)

logger "CloudVPS key retrieval script ran as $LOGGEDINUSER, key from $KEYLOCATION."

# checking if we use wget or curl
command -v "curl" >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
	SSHKEY=$(curl -s -L "$KEYLOCATION")
elif [[ $? -ne 0 ]]; then
	command -v "wget" >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Both wget and curl failed. Please make sure one of these is present and functional"
		echo "Please also check firewall and internet access ($KEYLOCATION)"
		exit 1
	elif [[ $? -eq 0 ]]; then
		SSHKEY=$(wget --quiet -O - "$KEYLOCATION")
	fi
fi

# check to see if the key is already there
if [[ $(grep $CLOUDVPSKEYNAME $SSHFOLDER/$AUTHORIZEDKEYS  ) = *CloudVPS-key ]]; then
	echo "Key already exists"
    logger "SSH key already exists, failure."
	exit 42
fi

# check to see if .ssh folder & authorized_keys file exists
if [[ ! -d "$SSHFOLDER" ]]; then
	mkdir $SSHFOLDER
	chmod 700 $SSHFOLDER
fi

if [[ ! -f "$SSHFOLDER/$AUTHORIZEDKEYS" ]]; then
	touch "$SSHFOLDER/$AUTHORIZEDKEYS"
	chmod 600 "$SSHFOLDER/$AUTHORIZEDKEYS"
fi

#placing the key

# check if the SSH key is an actual pubkey
# not a 404 error html document, that would not be nice
echo $SSHKEY > .cloudkey.$EPOCH
ssh-keygen -l -f .cloudkey.$EPOCH
if [[ "$?" == 0 ]]; then
    rm .cloudkey.$EPOCH
    cp "$SSHFOLDER/$AUTHORIZEDKEYS" "$SSHFOLDER/$AUTHORIZEDKEYS.cloudvps.backup"
    echo "$SSHKEY" >> "$SSHFOLDER/$AUTHORIZEDKEYS"
else
    rm .cloudkey.$EPOCH
    echo "Retrieved SSH key is not valid."
    exit 1
fi

echo "Added CloudVPS key to authorized keys for $LOGGEDINUSER"
logger "Added CloudVPS key to authorized keys for $LOGGEDINUSER"

# logging in the authorized keyfile
sed -i '/# Last time CloudVPS key was added/d' $SSHFOLDER/$AUTHORIZEDKEYS
sed -i "1 i\# Last time CloudVPS key was added $DATE " $SSHFOLDER/$AUTHORIZEDKEYS

#create task to remove the key
# if at is available, remove the key file via at after 24 hours
# otherwise via cron at the end of the week.
command -v "at" >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "The CloudVPS key will be removed in 24 hours with at."
    echo "sed -i '/$CLOUDVPSKEYNAME/d' $SSHFOLDER/$AUTHORIZEDKEYS" | at now +24 hours
else
    echo "The CloudVPS key will be removed at the end of the week via cron."
    echo "#!/bin/bash" > /etc/cron.weekly/remove.cloudkey.$EPOCH
    # the cronjob removes itself as well
    echo -e "sed -i '/$CLOUDVPSKEYNAME/d' $SSHFOLDER/$AUTHORIZEDKEYS \nrm /etc/cron.weekly/remove.cloudkey.$EPOCH" >> /etc/cron.weekly/remove.cloudkey.$EPOCH
    chmod +x /etc/cron.weekly/remove.cloudkey.$EPOCH
fi
