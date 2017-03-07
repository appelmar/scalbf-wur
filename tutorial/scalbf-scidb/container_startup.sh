#!/bin/bash
# This script automatically starts all relevant services on the container

#export SCIDB_BIN=/opt/scidb/14.12/bin

echo -e "\n\nStarting required services..."
service ssh start 
sleep 2
echo -e "... sshd started"

service postgresql start
sleep 30
echo -e "... postgresql started"

sudo -H -u scidb bash -c '/opt/scidb/15.7/bin/scidb.py stopall scidb_docker' 
sudo -H -u scidb bash -c '/opt/scidb/15.7/bin/scidb.py startall scidb_docker' 
sleep 5
echo -e "... scidb started"

service shimsvc start  
sleep 5
echo -e "... shim started"

R CMD Rserve --vanilla &>/dev/null
sleep 2
echo -e "... rserve started"


su - scidb -c"/opt/scidb/15.7/bin/iquery -anq \"load_library('r_exec');\""
su - scidb -c"/opt/scidb/15.7/bin/iquery -anq \"load_library('scidb4geo');\""
su - scidb -c"/opt/scidb/15.7/bin/iquery -anq \"load_library('dense_linear_algebra');\""
echo -e "... scidb plugins loaded"

