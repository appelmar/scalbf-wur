#!/bin/bash

# install Shim
cd ~ 
wget http://paradigm4.github.io/shim/ubuntu_14.04_shim_15.7_amd64.deb
yes | gdebi ubuntu_14.04_shim_15.7_amd64.deb
#rm /var/lib/shim/conf
#mv /home/root/conf /var/lib/shim/conf
#rm ubuntu_12.04_shim_14.12_amd64.deb
/etc/init.d/shimsvc stop

# replace standard config by user provided
cp /home/root/conf/shim.conf /var/lib/shim/conf

# Setup digest authentification
if [ -f /opt/.scidbpw ]
then
  PW=`cat /opt/.scidbpw`
else
  echo "Please enter scidb password:"
  read -s PW
fi
echo "scidb:${PW}" >> /var/lib/shim/wwwroot/.htpasswd
chmod 600 /var/lib/shim/wwwroot/.htpasswd

echo -e "\nDONE. If not yet done, please remember to remove /opt/.scidbpass after finishing your SciDB cluster installation."

