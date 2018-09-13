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
sudo apt-get install --no-install-recommends --fix-missing --assume-yes htop curl git python wget apt-transport-https ca-certificates software-properties-common lm-sensors

## Add dockers official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

## Add dockers repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#Install docker
sudo apt-get update
sudo apt-get install --assume-yes docker-ce

#Get docker compose
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#setup folders to store all the config files
sudo -i
sudo mkdir -p /docker/containers/{muximux,nzbget,plex,tautulli,radarr,sonarr,handbrake,ombi}/config
sudo mkdir -p /docker/downloads/{completed/Movies,completed/TV}
sudo mkdir -p /docker/containers/plex/transcode
sudo mkdir -p /docker/containers/handbrake/{watch,output}
sudo chown -R adam:adam /docker

sudo docker-compose up -d
