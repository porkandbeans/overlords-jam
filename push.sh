#!/usr/bin/env bash

# simple bash script I tinkered to make pushing a little bit easier for myself

CMESG=$1
if [ -z "$CMESG" ]
then
	CMESG="lazy auto push"
fi

sudo cat /root/github_keys
git add -A
git commit -m "$CMESG"
git push
clear
echo "Done! screen cleared to protect github key."
