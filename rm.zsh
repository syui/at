#!/bin/zsh
d=${0:a:h}
dh=${0:a:h:h}
atp=$dh/atproto
at=$dh/at
atv=$dh/atenv

sudo rm -rf $atp/data
#sudo rm -rf $atp/services/pds/*.sqlite*
#sudo rm -rf $atp/services/pds/actors

cp -rf $atp/.*.env $atv/
cp -rf $atp/compose.yaml $atv/

docker-rm () {
        case $1 in
                (v) docker volume rm $(docker volume ls -qf dangling=true) ;;
                (p) docker rm $(docker ps -aq) ;;
                (i) docker rmi $(docker images -q) ;;
                (n) docker rm $(docker network ls -q) ;;
        esac
}

case $1 in
	a)
		docker-rm v
		docker-rm p
		docker-rm i
		docker-rm n
		;;
	*)
		echo docker-rm : a
		;;
esac
