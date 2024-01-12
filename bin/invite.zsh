#!/bin/zsh

echo 1:host

d=${0:a:h}
dd=${0:a:h:h}
admin_password=`cat $dd/config.json|jq -r .admin_password`
if [ -n "$1" ];then
	host=$1
else
	host=syu.is
fi
url=https://$host/xrpc/com.atproto.server.createInviteCode
json="{\"useCount\":1}"
curl -X POST -u admin:${admin_password} -H "Content-Type: application/json" -d "$json" -sL $url | jq -r .code
