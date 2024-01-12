#!/bin/zsh

echo 1:host

d=${0:a:h}
dd=${0:a:h:h}
if [ -n "$1" ];then
	host=$1
else
	host=syu.is
fi
echo $host

plc=https://plc.${host}
plc_ex=$plc/export
j=$d/at_plc.${host}.json
atr=$HOME/.cargo/bin/atr
plc_n=$d/at_plc_n.txt

#curl -sL "https://$host/xrpc/com.atproto.identity.resolveHandle?handle=${handle}"

unset timed

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

plc(){
	timed=1970-01-01
	curl -sL "${plc_ex}?after=${timed}"|jq -s . >! $j
	n=`cat $j|jq length`
	s=0
	if [ -f $plc_n ];then
		s=`cat $plc_n`
	fi
	n=$((n - 1))
	if [ $s -ge $n ];then
		echo $s $n
		exit
	fi
	for ((i=$s;i<=$n;i++))
	do
		tt=`cat $j|jq -r ".[$i].operation|.alsoKnownAs|.[0]"|cut -d / -f 3-`
		did=`cat $j|jq -r ".[$i].did"`
		echo "$tt [$i] $did"
		#atr @ $tt -p "[$i] $did"
		case $tt in
			a.syu.is|aa.syu.is|aaa.syu.is|0.syu.is)
				$d/invite_account_dis.zsh $host $did
				;;
		esac
		atr follow $did
	done
	echo $n >! $plc_n
}

plc
