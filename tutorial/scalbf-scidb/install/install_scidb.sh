#!/bin/bash


if [ -f /opt/.scidbpw ]
then
  PW=`cat /opt/.scidbpw`
else
  echo "Please enter scidb password:"
  read -s PW
fi


#********************************************************
echo "***** Setting up passwordless SSH..."
#********************************************************
yes | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
sshpass -p ${PW} ssh-copy-id "root@localhost"
yes | ssh-copy-id -i ~/.ssh/id_rsa.pub  "root@0.0.0.0"
yes | ssh-copy-id -i ~/.ssh/id_rsa.pub  "root@127.0.0.1"


su scidb -c"yes | ssh-keygen -f /home/scidb/.ssh/id_rsa -t rsa -N ''"
su scidb -c"sshpass -p ${PW} ssh-copy-id 'scidb@localhost'"
su scidb -c"yes | ssh-copy-id -i /home/scidb/.ssh/id_rsa.pub  'scidb@0.0.0.0'"
su scidb -c"yes | ssh-copy-id -i /home/scidb/.ssh/id_rsa.pub  'scidb@127.0.0.1'"


#********************************************************
echo "***** Compiling SciDB..."
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



# Extract source code
cd /home/root/
tar -xzf /home/root/install/scidb-15.7.0.9267.tgz
mv scidb-15.7.0.9267 scidbtrunk



# Install dependencies
apt-get install -y --force-yes --no-install-recommends software-properties-common
add-apt-repository -y ppa:ubuntu-toolchain-r/test # needed for gcc-4.9,g++-4.9, and gfortran-4.9
add-apt-repository -y ppa:openjdk-r/ppa
apt-get update
apt-get install -y --force-yes --no-install-recommends expect make gcc-4.9 g++-4.9 cmake gfortran-4.9 g++ protobuf-compiler libprotobuf-dev liblog4cxx10-dev flex bison libbz2-dev libpqxx3-dev libreadline-dev libfile-fcntllock-perl libblas-dev liblapack-dev openjdk-8-jdk libcppunit-dev dpkg-dev mpich2 libmpich2-dev libscalapack-mpi-dev libscalapack-mpi1 ant ant-contrib junit libprotobuf-java unzip


wget -O- https://downloads.paradigm4.com/key | apt-key add -
echo "deb https://downloads.paradigm4.com/ ubuntu14.04/3rdparty/" >> /etc/apt/sources.list
apt-get update
apt-get install -y --force-yes --no-install-recommends scidb-15.7-libboost1.54-all-dev  scidb-15.7-cityhash scidb-15.7-libcsv scidb-15.7-libmpich2-1.2 scidb-15.7-libmpich2-dev  scidb-15.7-ant 
apt-get install -y --force-yes --no-install-recommends fakeroot build-essential debhelper fop xsltproc doxygen subversion ant-optional libpam-dev swig2.0 docbook-xsl scidb-15.7-mpich2



# Build SciDB
cd $SCIDB_SOURCE_PATH
export BOOST_INCLUDEDIR=/usr/include/
./run.py setup -f
./run.py make -j2

./deployment/deploy.sh build_fast /tmp/packages # build .deb packages
./deployment/deploy.sh scidb_install /tmp/packages $HOSTNAME # install to /opt/scidb/15.7








