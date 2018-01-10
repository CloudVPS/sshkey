#!/bin/bash
#
# Script by: Leon de Jong, CloudVPS
#
# This script downloads the key of CloudVPS to the server running this script to allow support access
#
# future functions: 
# - auto removal of said key to keep authorized_keys clean
# - adding of comment to authorized_keys to show last CloudVPS login date
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

echo "sed -i '/$CLOUDVPSKEYNAME/d' $SSHFOLDER/$AUTHORIZEDKEYS | mail -s at test -t leon@cloudvps.com" | at now + 1 minutes
sed -i '1 i\^# Last time CloudVPS key was added: ' $SSHFOLDER/$AUTHORIZEDKEYS 

