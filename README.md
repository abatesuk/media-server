# Description
***

This is all the files used to setup my personal media server running in a VM using Ubuntu 16.04. It uses [Docker](https://www.docker.com) for containerization of the applications (plex, plexpy, sonarr, radarr, nzbget, muximux, watchdog, handbrake).


## Prerequisites:
***

[Vagrant](http://vagrantup.com) is a free tool that automates the creation of VM's using VirtualBox. It provides a small set of command-line tools that kick off provisioning of a VM via VirtualBox.
[VirtualBox](http://www.virtualbox.org) is a free virtualization platform that allows the creation of virtual machines on a local workstation.

### Setup Prerequisites:
***

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) ( and corresponding VirtualBox Extension Pack )
2. Install [Vagrant](https://www.vagrantup.com/downloads.html)
3. Install teh Vagrant plugin [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)


   ```
   $ vagrant plugin install vagrant-hostsupdater
   ```
