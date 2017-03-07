#!/bin/bash

# install Rserve and r_exec
#apt-get install -qq --fix-missing -y --force-yes scidb-14.12-libboost1.54-all-dev liblog4cxx10-dev libpqxx3-dev
Rscript --vanilla -e 'install.packages(c("Rserve"), repos="http://cran.rstudio.com/")'
git clone https://github.com/appelmar/r_exec.git 
cd r_exec 
make SCIDB=/opt/scidb/15.7
cp *.so /opt/scidb/15.7/lib/scidb/plugins
cd ..
rm -Rf r_exec



