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
