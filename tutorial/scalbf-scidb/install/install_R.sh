#!/bin/bash

# install R 
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list 
apt-get -qq update
apt-get install -qq --fix-missing -y --force-yes r-base r-base-dev
Rscript --vanilla -e 'install.packages(c("devtools"), repos="http://cran.rstudio.com/")'
