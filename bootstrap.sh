#!/bin/bash

# Check to see if an unattended upgrade is happening
i=0
tput sc
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
  case $(($i % 4)) in
    0 ) j="-" ;;
    1 ) j="\\" ;;
    2 ) j="|" ;;
    3 ) j="/" ;;
  esac
  tput rc
  echo -en "\r[$j] Waiting for other software managers to finish..."
  sleep 0.5
  ((i=i+1))
done

# Install some base apps

sudo apt-get -q update
sudo apt-get install --no-install-recommends --fix-missing --assume-yes htop curl git python wget apt-transport-https ca-certificates software-properties-common

## Add dockers official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

## Add dockers repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#Install docker
sudo apt-get update
sudo apt-get install --assume-yes docker-ce

#Add the ubuntu user to the docker group
sudo usermod -a -G docker $USER

#setup folders to store all the config files
sudo mkdir -p /docker/containers/{muximux,nzbget,plex,plexpy,radarr,sonarr,handbrake}/config
sudo mkdir -p /docker/downloads/{completed/Movies,completed/TV}
sudo mkdir -p /docker/containers/plex/transcode
sudo mkdir -p /docker/containers/handbrake/{watch,output}
sudo chown -R ubuntu:ubuntu /docker

docker run \
-d \
--name plex \
--net=host \
-e TZ="Europe/London" \
-e PLEX_UID=1000 -e PLEX_GID=1000 \
-v /docker/containers/plex/config:/config \
-v /movies:/movies \
-v /tv:/TV \
-v /homevideos:/home \
-v /docker/containers/plex/transcode:/transcode \
plexinc/pms-docker

docker create \
--name nzbget \
-p 6789:6789 \
-e PUID=1000 -e PGID=1000 \
-v /docker/containers/nzbget/config:/config \
-v /docker/downloads:/downloads \
-v /movies:/movies \
-v /tv:/TV \
linuxserver/nzbget

docker create \
--name sonarr \
-p 8989:8989 \
-e PUID=1000 -e PGID=1000 \
-v /etc/localtime:/etc/localtime:ro \
-v /docker/containers/sonarr/config:/config \
-v /tv:/TV \
-v /docker/downloads/completed/TV:/downloads/completed/TV \
linuxserver/sonarr

docker create \
--name=radarr \
-v /docker/containers/radarr/config:/config \
-v /movies:/movies \
-v /docker/downloads/completed/Movies:/downloads/completed/Movies \
-e PGID=1000 -e PUID=1000  \
-e TZ="Europe/London" \
-p 7878:7878 \
linuxserver/radarr

docker run \
--name=HandBrakeCLI \
--cap-add=SYS_NICE \
-v /docker/containers/handbrake/watch:/watch:ro \
-v /docker/containers/handbrake/output:/output:rw \
-v /docker/containers/handbrake/config:/config:rw \
coppit/handbrake

docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
v2tec/watchtower

docker create \
--name=plexpy \
-v /etc/localtime:/etc/localtime:ro \
-v /docker/containers/plexpy/config:/config \
-v "/docker/containers/plex/config/Library/Application Support/Plex Media Server/Logs":/logs:ro \
-e PGID=1000 -e PUID=1000  \
-p 8181:8181 \
linuxserver/plexpy

docker create \
--name=muximux \
-p 80:80 \
-p 443:443 \
-v /docker/containers/muximux/config:/config \
linuxserver/muximux

docker run \
-d --cap-add SYS_PTRACE \
--security-opt apparmor:unconfined \
-v /proc:/host/proc:ro \
-v /sys:/host/sys:ro \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /opt/netdata/overrides:/etc/netdata/override \
-p 19999:19999 titpetric/netdata \

##Set all containers to auto restart
docker update --restart=always $(docker ps -a -q)

