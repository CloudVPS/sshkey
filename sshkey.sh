#!/bin/bash
#
# Script by: Leon de Jong, CloudVPS
#
# This script downloads the key of CloudVPS to the server running this script to allow support access for 24h (1 minute during testing)
#
# 

#variables, can change later. the top 3 would be simple id say.
KEYLOCATION=http://ns03.dyno.su/key
SSHFOLDER=~/.ssh
AUTHORIZEDKEYS=authorized_keys
DATE=$(date)
#tag we put after the key
CLOUDVPSKEYNAME=CloudVPS-key
#easy way to echo local user later
LOGGEDINUSER=$(whoami)


#function to check if key is allready there (i like functions)

function sshkeycheck()
{
if [[ $(grep $CLOUDVPSKEYNAME $SSHFOLDER/$AUTHORIZEDKEYS  ) = *CloudVPS-key ]]; then
	echo "Key allready exists"
	exit 42
fi 
}
sshkeycheck

if [ ! -d "$SSHFOLDER" ]; then
	mkdir $SSHFOLDER
fi

curl -s -L $KEYLOCATION >> $SSHFOLDER/$AUTHORIZEDKEYS
echo "Added CloudVPS key to authorized keys for $LOGGEDINUSER"

echo "sed -i '/$CLOUDVPSKEYNAME/d' $SSHFOLDER/$AUTHORIZEDKEYS | at now + 1 minutes
sed -i '/# Last time CloudVPS key was added/d' $SSHFOLDER/$AUTHORIZEDKEYS
sed -i "1 i\# Last time CloudVPS key was added $DATE " $SSHFOLDER/$AUTHORIZEDKEYS


