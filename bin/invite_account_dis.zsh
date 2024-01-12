#!/bin/zsh

echo 1:host
echo 2:did

d=${0:a:h}
dd=${0:a:h:h}
admin_password=`cat $dd/config.json|jq -r .admin_password`
if [ -n "$1" ];then
        host=$1
else
        host=syu.is
fi

if [ -n "$2" ];then
        did=$2
fi

url=https://$host/xrpc/com.atproto.admin.disableAccountInvites

json="{\"account\":\"$did\"}"
echo $url
curl -X POST -u admin:${admin_password} -H "Content-Type: application/json" -d "$json" -sL $url

json="{\"did\":\"$did\"}"
url=https://$host/xrpc/com.atproto.admin.deleteAccount
echo $url
curl -X POST -u admin:${admin_password} -H "Content-Type: application/json" -d "$json" -sL $url
