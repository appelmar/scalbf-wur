#!/bin/bash

apt-get install --no-install-recommends -y libboost-dev libcurl4-openssl-dev libpqxx3-dev gcc-4.9 g++-4.9 liblog4cxx10-dev


cd /tmp

# Build from source and create a binary installer package
git clone https://github.com/appelmar/scidb4geo --branch dev-15.7
cd scidb4geo

make SCIDB=/opt/scidb/15.7

cd install
chmod +x setup.sh
yes | ./setup.sh


cp ../libscidb4geo.so /opt/scidb/15.7/lib/scidb/plugins/

#su scidb <<'EOF'
#/opt/scidb/15.7/bin/iquery -aq "load_library('scidb4geo')"
#EOF

cd ../../
rm -Rf scidb4geo
