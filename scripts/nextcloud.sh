#! /bin/bash
#
# Provisioning script for Ansible control node

#--------- Bash settings ------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#--------- Variables ----------------------------------------------------------

# Location of provisioning scripts and files
declare PROVISIONING_SCRIPTS="/vagrant/scripts/"
# Location of files to be copied to this server
declare PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/${HOSTNAME}"

#---------- Load utility functions --------------------------------------------

source ${PROVISIONING_SCRIPTS}/util.sh

#---------- Provision host ----------------------------------------------------

log "Starting server specific provisioning tasks on host ${HOSTNAME}..."

log 'Install EPEL repository and some additional packages'
# Install baseline packages
dnf install --assumeyes \
  epel-release \
  yum-utils \
  git \
  wget \
  mariadb \


log 'Add Docker repository and install Docker on the server'
# Add Docker repository using yum-config-manager
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
dnf install --assumeyes \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin 

log 'Add vagrant user to the Docker group'
# Ensure Vagrant user is added to the Docker group  
usermod -aG docker vagrant


log 'Enable and start Docker'
# Enable and start Docker
systemctl enable --now docker
systemctl start docker

log 'Starting up clean Nextcloud instance'

# Create Nextcloud directory

mkdir -p /home/vagrant/nextcloud

# Provision docker compose file

cp "${PROVISIONING_FILES}"/docker-compose.yaml /home/vagrant/nextcloud/docker-compose.yaml



# Start docker containers using docker compose

docker compose -f /home/vagrant/nextcloud/docker-compose.yaml up -d

# Give compose some time to spin up
sleep 30


log 'Starting up provisioned Nextcloud instance'

# Create Nextcloud directory

mkdir -p /home/vagrant/nextcloud-provisioned

# Provision docker compose file

cp "${PROVISIONING_FILES}"/docker-compose-provisioned.yaml /home/vagrant/nextcloud-provisioned/docker-compose.yaml


# Start docker containers using docker compose

docker compose -f /home/vagrant/nextcloud-provisioned/docker-compose.yaml up -d

# Give compose some time to spin up
sleep 30

log 'Provision Nextcloud instance'

mkdir -p /home/vagrant/nextcloud-provisioned/nextcloud

cp -R --remove-destination "${PROVISIONING_FILES}"/nextcloud /home/vagrant/nextcloud-provisioned/

chmod -R 777 /home/vagrant/nextcloud-provisioned/nextcloud/ # DO NOT DO THIS EVER JUST FOR THE POC PLEASE GOD

sed -i 's/:8080/:8081/g'  /home/vagrant/nextcloud-provisioned/nextcloud/config/config.php

# Restore database

log 'Delete existing database tables'

mysql -h 172.19.0.2 -u nextcloud -ptest -e "DROP DATABASE nextcloud" 

mysql -h 172.19.0.2 -u nextcloud -ptest -e "CREATE DATABASE nextcloud"

log 'Restore database'

mysql -h 172.19.0.2 -u nextcloud -ptest nextcloud < "${PROVISIONING_FILES}"/nextcloud-sqlbkp-it-lab-final.sql

docker restart nextcloud-provisioned mariadb-provisioned

dnf install --assumeyes openssh-server