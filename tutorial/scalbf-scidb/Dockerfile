FROM ubuntu:14.04
MAINTAINER Marius Appel <marius.appel@uni-muenster.de>

# Change this password before deployment!
RUN echo 'xxxx.xxxx.xxxx'  >> /opt/.scidbpw
RUN chmod 600 /opt/.scidbpw

ARG SCIDB_HOSTNAME
ENV SCIDB_HOSTNAME ${SCIDB_HOSTNAME:-scalbf-wur}
ENV HOSTNAME $SCIDB_HOSTNAME

EXPOSE 22 8083 1239 5432 

# Set environment and locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN export LANGUAGE=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && locale-gen en_US.UTF-8 && dpkg-reconfigure locales && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_MESSAGES=n_US.UTF-8 && env



# install basic packages
RUN apt-get -qq update && apt-get install --fix-missing -y --force-yes --no-install-recommends \
	openssh-server \
	openssl \
	sudo \
	wget \
	gdebi \
	nano \  
	sshpass \ 
	git-core \ 
	apt-transport-https \
	net-tools \
	libedit-dev \
	libtool \
	autotools-dev \
	supervisor


# Configure users
RUN useradd --home /home/scidb --create-home --uid 1006 --group sudo --shell /bin/bash scidb && \
	echo 'root:'$(cat /opt/.scidbpw) | chpasswd && \
	echo 'scidb:'$(cat /opt/.scidbpw) | chpasswd 


RUN mkdir /var/run/sshd && mkdir /home/scidb/data && mkdir /home/scidb/catalog && mkdir /home/root/ && mkdir /home/root/install && mkdir /home/root/conf

# Configure SSH
RUN mkdir ~/.ssh && sed -i 's/PermitRootLogin.*/#PermitRootLogin/g' /etc/ssh/sshd_config && echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config && stop ssh && start ssh

WORKDIR /home/root/install 

# Install SciDB
COPY conf/iquery.conf /home/root/conf/
COPY install/scidb-15.7.0.9267.tgz  /home/root/install/
COPY install/install_scidb.sh  /home/root/install/
RUN chmod +x install_scidb.sh; sync && export HOSTNAME=$SCIDB_HOSTNAME && /etc/init.d/ssh start && echo $(grep $(hostname) /etc/hosts | cut -f1) $SCIDB_HOSTNAME >> /etc/hosts && echo $SCIDB_HOSTNAME > /etc/hostname  && ./install_scidb.sh

# Install GDAL
COPY install/install_gdal.sh /home/root/install/
RUN chmod +x install_gdal.sh; sync &&  ./install_gdal.sh

# Initialize SciDB
COPY conf/scidb_docker.ini /home/root/conf/
COPY install/init_scidb.sh  /home/root/install/
RUN chmod +x init_scidb.sh; sync && sed -i 's/db_passwd.*/#db_passwd/g' /home/root/conf/scidb_docker.ini && echo "db_passwd=$(cat /opt/.scidbpw)" >> /home/root/conf/scidb_docker.ini && export HOSTNAME=$SCIDB_HOSTNAME && /etc/init.d/ssh start && echo $(grep $(hostname) /etc/hosts | cut -f1) $SCIDB_HOSTNAME >> /etc/hosts && echo $SCIDB_HOSTNAME > /etc/hostname  && ./init_scidb.sh

# Install shim
COPY install/install_shim.sh /home/root/install/
COPY conf/shim.conf /home/root/conf/
RUN chmod +x install_shim.sh; sync && export HOSTNAME=$SCIDB_HOSTNAME && /etc/init.d/ssh start && echo $(grep $(hostname) /etc/hosts | cut -f1) $SCIDB_HOSTNAME >> /etc/hosts && echo $SCIDB_HOSTNAME > /etc/hostname  && ./install_shim.sh

# Install scidb4geo
COPY install/install_scidb4geo.sh /home/root/install/
RUN chmod +x install_scidb4geo.sh; sync && export HOSTNAME=$SCIDB_HOSTNAME && /etc/init.d/ssh start && service postgresql start && echo $(grep $(hostname) /etc/hosts | cut -f1) $SCIDB_HOSTNAME >> /etc/hosts && echo $SCIDB_HOSTNAME > /etc/hostname && cd /home/root/install && ./install_scidb4geo.sh

# Install R 
COPY install/install_R.sh /home/root/install/
RUN chmod +x install_R.sh; sync && ./install_R.sh

# Install r_exec
COPY install/install_r_exec.sh /home/root/install/
RUN chmod +x install_r_exec.sh; sync &&  ./install_r_exec.sh

# Install R packages
COPY install/install.packages.R /home/root/install/
RUN Rscript install.packages.R


COPY conf/supervisord.conf 	/etc/supervisor/conf.d/
COPY container_startup.sh 	/opt/container_startup.sh 
RUN  chmod +x /opt/container_startup.sh 

CMD "/usr/bin/supervisord"



