#!/bin/zsh

host=syu.is
name=${host%%.*}
domain=${host##*.}

d=${0:a:h}
dh=${0:a:h:h}

git_plc=https://github.com/did-method-plc/did-method-plc
git_bgs=https://github.com/bluesky-social/indigo
git_atp=https://github.com/bluesky-social/atproto
git_web=https://github.com/bluesky-social/social-app
git_fee=https://github.com/bluesky-social/feed-generator

mkdir -p $d/repos
cd $d/repos
if [ ! -d $d/repos/did-method-plc ];then
	git clone $git_plc 
fi
if [ ! -d $d/repos/indigo ];then
	git clone $git_bgs
fi
if [ ! -d $d/repos/atproto ];then
	git clone $git_atp
fi
if [ ! -d $d/repos/social-app ];then
	git clone $git_web
fi
if [ ! -d $d/repos/feed-generator ];then
	git clone $git_fee
fi

b="ADMIN_PASSWORD
MODERATOR_PASSWORD
TRIAGE_PASSWORD
SERVICE_SIGNING_KEY
IMG_URI_SALT
IMG_URI_KEY
OZONE_ADMIN_PASSWORD
OZONE_MODERATOR_PASSWORD
OZONE_TRIAGE_PASSWORD
OZONE_SIGNING_KEY_HEX
BGS_ADMIN_KEY
PDS_REPO_SIGNING_KEY_K256_PRIVATE_KEY_HEX
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX"

for ((i=1;i<=`echo $b|wc -l`;i++))
do
	f=`echo $b|awk "NR==$i"`
	o=`openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32`
	echo $f=$o
	export $f=$o
done

b="PDS_JWT_SECRET
PDS_ADMIN_PASSWORD"

for ((i=1;i<=`echo $b|wc -l`;i++))
do
	f=`echo $b|awk "NR==$i"`
	o=`openssl rand --hex 16`
	echo $f=$o
	export $f=$o
done

case $1 in
	run-env-write)
		echo MODERATION_PUSH_URL=https://admin:${OZONE_ADMIN_PASSWORD}@mod.${host} >> $d/.env/bsky
		echo MODERATION_PUSH_URL=https://admin:${OZONE_ADMIN_PASSWORD}@mod.${host} >> $d/.env/mod
		echo ADMIN_PASSWORD=$ADMIN_PASSWORD >> $d/.env/bsky
		echo MODERATOR_PASSWORD=$MODERATOR_PASSWORD >> $d/.env/bsky
		echo TRIAGE_PASSWORD=$TRIAGE_PASSWORD >> $d/.env/bsky
		echo SERVICE_SIGNING_KEY=$SERVICE_SIGNING_KEY >> $d/.env/bsky
		echo IMG_URI_SALT=$IMG_URI_SALT >> $d/.env/bsky
		echo IMG_URI_KEY=$IMG_URI_KEY >> $d/.env/bsky
		echo OZONE_ADMIN_PASSWORD=$OZONE_ADMIN_PASSWORD >> $d/.env/mod
		echo OZONE_MODERATOR_PASSWORD=$OZONE_MODERATOR_PASSWORD >> $d/.env/mod
		echo OZONE_TRIAGE_PASSWORD=$OZONE_TRIAGE_PASSWORD >> $d/.env/mod
		echo OZONE_SIGNING_KEY_HEX=$OZONE_SIGNING_KEY_HEX >> $d/.env/mod
		echo BGS_ADMIN_KEY=$BGS_ADMIN_KEY >> $d/.env/bgs
		echo PDS_JWT_SECRET=$PDS_JWT_SECRET >> $d/.env/pds
		echo PDS_ADMIN_PASSWORD=$PDS_ADMIN_PASSWORD >> $d/.env/pds
		echo PDS_REPO_SIGNING_KEY_K256_PRIVATE_KEY_HEX=$PDS_REPO_SIGNING_KEY_K256_PRIVATE_KEY_HEX >> $d/.env/pds
		echo PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX >> $d/.env/pds
	;;
	web)
		cd $d/repos/social-app/src
		if [ -n "`grep -R bsky.social .`" ];then
			for f (`grep -R bsky.social . |cut -d : -f 1`) sed -i -e "s/bsky\.social/${name}\.${domain}/g" $f
		fi
		if [ -n "`grep -R "isSandbox: false" .`" ];then
			for f (`grep -R "isSandbox: false" . |cut -d : -f 1`) sed -i -e "s/isSandbox: false/isSandbox: true/g" $f
		fi
		if [ -n "`grep -R SANDBOX .`" ];then
			for f (`grep -R SANDBOX . |cut -d : -f 1`) sed -i -e "s/SANDBOX/${name}\.${domain}/g" $f
		fi
		f=./view/com/modals/ServerInput.tsx
		if [ -n "`grep -R Bluesky.Social $f`" ] && [ -f $f ];then
			sed -i -e "s/Bluesky\.Social/${name}\.${domain}/g" $f
		fi
		f=./state/queries/preferences/moderation.ts
		if [ -n "`grep -R 'Bluesky Social' $f`" ] && [ -f $f ];then
			sed -i -e "s/Bluesky Social/${name}\.${domain}/g" $f
		fi
		f=./view/com/auth/create/Step1.tsx
		if [ -n "`grep -R 'Bluesky' $f`" ] && [ -f $f ];then
			sed -i -e "s/Bluesky/${name}\.${domain}/g" $f
		fi
		f=./lib/strings/url-helpers.ts
		if [ -n "`grep -R 'Bluesky Social' $f`" ] && [ -f $f ];then
			sed -i -e "s/Bluesky Social/${name}\.${domain}/g" $f
		fi
		f=./view/icons/Logotype.tsx
		o=$d/icons/Logotype.tsx
		if [ -n "`grep -R 'M8.478 6.252c1.503.538 2.3 1.7' $f`" ] && [ -f $f ]  && [ -f $o ];then
			cp -rf $o $f
		fi
	;;
	web-icon-dl)
		curl -sL https://raw.githubusercontent.com/bluesky-social/social-app/main/src/view/icons/Logotype.tsx -o $d/repos/social-app/src/view/icons/Logotype.tsx
		cp -rf $d/repos/social-app/src/view/icons/Logotype.tsx $d/icons/
	;;
esac
