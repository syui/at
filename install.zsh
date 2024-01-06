#!/bin/zsh
d=${0:a:h}
dh=${0:a:h:h}
at=$dh/at
atp=$dh/atproto

if [ ! -d $atp ];then
	cd $dh
	git clone https://github.com/bluesky-social/atproto
	cd $atp
	#git reset --hard 65254ab148cc7794aab053eb692935baf9e10b5f
fi

if [ ! -d $at ];then
	cd $dh
	git clone https://github.com/syui/at
fi

cd $dh

#cp -rf $at/caddy $atp/
cp -rf $at/compose.yaml $atp/
cp -rf $at/example.* $atp/
cp -rf $at/docker $atp/

in() {
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/zsh_completion" ] && \. "$NVM_DIR/zsh_completion"

	cd $1
	nvm use 18
	yarn install
	yarn build
}

s=$atp/services_origin/plc
u=https://github.com/did-method-plc/did-method-plc
if [ ! -d $s ];then
	git clone $u $s
	cp -rf $atp/docker/plc/Dockerfile $atp/services_origin/plc/packages/server/Dockerfile
	cp -rf $atp/docker/pds/Dockerfile $atp/services/pds/Dockerfile
	cp -rf $atp/docker/bsky/Dockerfile $atp/services/bsky/Dockerfile
	in $s
fi

s=$atp/services_origin/bgs
u=https://github.com/bluesky-social/indigo
if [ ! -d $s ];then
	git clone $u $s
	in $s
fi

if [ -f $atp/example.pds.env ];then
	mv $atp/example.pds.env $atp/.pds.env
	echo PDS_JWT_SECRET="$(openssl rand --hex 16)" >> $atp/.pds.env
	echo PDS_REPO_SIGNING_KEY_K256_PRIVATE_KEY_HEX="$(openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32)" >> $atp/.pds.env
	echo PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX="$(openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32)" >> $atp/.pds.env
fi
if [ -f $atp/example.plc.env ];then
	mv $atp/example.plc.env $atp/.plc.env
fi
if [ -f $atp/example.bgs.env ];then
	mv $atp/example.bgs.env $atp/.bgs.env
fi
if [ -f $atp/example.bsky.env ];then
	mv $atp/example.bsky.env $atp/.bsky.env
fi
if [ -f $atp/example.ozone.env ];then
	mv $atp/example.ozone.env $atp/.ozone.env
fi
