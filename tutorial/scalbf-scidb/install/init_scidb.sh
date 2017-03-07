#!/bin/bash


if [ -f /opt/.scidbpw ]
then
  PW=`cat /opt/.scidbpw`
else
  echo "Please enter scidb password:"
  read -s PW
fi


#********************************************************
echo "***** Installing SciDB..."
#********************************************************


export SCIDB_VER=15.7
export SCIDB_SOURCE_PATH=/home/root/scidbtrunk
export SCIDB_BUILD_PATH=${SCIDB_SOURCE_PATH}/stage/build
export SCIDB_INSTALL_PATH=/opt/scidb/${SCIDB_VER}
export SCIDB_BUILD_TYPE=RelWithDebInfo
export PATH=${SCIDB_INSTALL_PATH}/bin:$PATH

# Make environment variables persistent for the whole system
echo "export SCIDB_VER=${SCIDB_VER}" >> /etc/environment 
echo "export SCIDB_SOURCE_PATH=${SCIDB_SOURCE_PATH}" >> /etc/environment 
echo "export SCIDB_BUILD_PATH=${SCIDB_BUILD_PATH}" >> /etc/environment 
echo "export SCIDB_INSTALL_PATH=${SCIDB_INSTALL_PATH}" >> /etc/environment 
echo "export SCIDB_BUILD_TYPE=${SCIDB_BUILD_TYPE}" >> /etc/environment 
echo "PATH=${SCIDB_INSTALL_PATH}/bin:$PATH" >> /etc/profile # appending does not work in /etc/environment



# replace config.ini
sed -i "s/localhost/$HOSTNAME/g" /home/root/conf/scidb_docker.ini
cp /home/root/conf/scidb_docker.ini ${SCIDB_INSTALL_PATH}/etc/config.ini

#su postgres -c"psql -c\"CREATE ROLE scidb SUPERUSER LOGIN CREATEROLE CREATEDB UNENCRYPTED PASSWORD '${PW}';\" "
cd $SCIDB_SOURCE_PATH
deployment/deploy.sh prepare_postgresql postgres $PW 0.0.0.0/0 $HOSTNAME
su postgres -c"/opt/scidb/15.7/bin/scidb.py init-syscat scidb_docker -p ${PW}"



# Run SciDB as scidb system user

echo $PW > /home/scidb/.scidbpw # will be deeleted...
chown -R scidb:scidb /home/scidb

su scidb <<'EOF'
cd ~
export PGPASSWORD=`cat /home/scidb/.scidbpw`
echo -e "${HOSTNAME}:5432:scidb_docker:scidb:${PGPASSWORD}\n" >> ~/.pgpass # to be removed
chmod 0600 ~/.pgpass # this is important, otherwise file will be ignored
/opt/scidb/15.7/bin/scidb.py initall-force scidb_docker
echo 'PATH="/opt/scidb/15.7/bin:$PATH"' >> $HOME/.bashrc # Add scidb binaries to PATH
/opt/scidb/15.7/bin/scidb.py startall scidb_docker
source ~/.bashrc
PATH=/opt/scidb/15.7/bin:$PATH
rm /home/scidb/.scidbpw
EOF

rm -Rf $SCIDB_SOURCE_PATH

echo -e "\nDONE. If not yet done, please remember to remove /opt/.scidbpass after finishing your SciDB cluster installation."



