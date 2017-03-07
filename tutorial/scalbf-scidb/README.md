# scalbf-scidb
A Docker image to install [SciDB](http://www.paradigm4.com/) and additional tools.

---

This Docker image includes:

* scripts, code, and a `Dockerfile` to create a Docker image with all required software

* a small Landsat7 dataset to run  land use change monitoring with Landsat NDVI time series


## Prerequisites
- [Docker Engine](https://www.docker.com/products/docker-engine) (>1.10.0) 
- Around 15 GBs free disk space 
- Internet connection to download software and dependencies


## Getting started

_**Note**: Depending on your Docker configuration, the following commands must be executed with sudo rights._

### 1. Build the Docker image (1-2 hours)

The provided Docker image is based on a minimally sized Ubuntu OS. Among others, it includes the compilation and installation of [SciDB](http://www.paradigm4.com/), [GDAL](http://gdal.org/), SciDB extensions ([scidb4geo](https://github.com/appelmar/scidb4geo),  [scidb4gdal](https://github.com/appelmar/scidb4gdal)) and the installation of all dependencies. The image will take around 15 GBs of disk space. It can be created by executing:

```
cd scidb-scalbf
sudo docker build --tag="scidb-eo:scalbf" . # don't miss the dot
``` 

_Note that by default, this includes a rather careful SciDB configuration with relatively little demand for main memory. You may modify `conf/scidb_docker.ini` if you have a powerful machine._


### 2. Start a container 

The following command starts a cointainer in detached mode, i.e. it will run as a service until it is explicitly stopped with `docker stop scalbf-wur`.

_Note that the following command limits the number of CPU cores and main memory available to the container. Feel free to use different settings for `--cpuset-cpu` and `-m`._


```
sudo docker run -d --name="scalbf-wur" --cpuset-cpus="0,1" -m "4G" -h "scalbf-wur" -p 33330:22 -p 33331:8083 -v $PWD/data:/opt/data/  scidb-eo:scalbf 
```





### 3. Clean up
To clean up your system, you can remove containers and the image with

1. `sudo docker rm -f scalbf-wur`  and 
2. `sudo docker rmi scidb-eo:scalbf`.

	
	
## Files

| File        | Description           |
| :------------- | :-------------------------------------------------------| 
| install/ | Directory for installation scripts |
| install/install_scidb.sh | Installs SciDB 15.7 from sources |
| install/init_scidb.sh | Initializes SciDB based on provided configuration file |
| install/install_shim.sh | Installs Shim |
| install/install_scidb4geo.sh | Installs the scidb4geo plugin |
| install/install_gdal.sh | Installs GDAL with SciDB driver |
| install/install_R.sh | Installs the latest R version  |
| install/install_r_exec.sh | Installs the r_exec SciDB plugin to run R functions in AFL queries including Rserve |
| install/scidb-15.7.0.9267.tgz| SciDB 15.7 source code |
| conf/ | Directory for configuration files |
| conf/scidb_docker.ini | SciDB configuration file |
| conf/supervisord.conf | Configuration file to manage automatic starts in Docker containers |
| conf/iquery.conf | Default configuration file for iquery |
| conf/shim.conf | Default configuration file for shim |
| data/ | Directory with sample Landsat dataset |
| Dockerfile | Docker image definition file |
| container_startup.sh | Script that starts SciDB, Rserve, and other system services within a container  |
| run.sh | Script that calls container_startup.sh and starts Rscript /opt/run/run.R if available within the container, can be used as container CMD instruction |


## References
[1] Verbesselt, J., Zeileis, A., & Herold, M. (2013). Near real-time disturbance detection using satellite image time series, Remote Sensing of Environment. DOI: 10.1016/j.rse.2012.02.022. 


## License
This Docker image contains source code of SciDB in install/scidb-15.7.0.9267.tgz. SciDB is copyright (C) 2008-2016 SciDB, Inc. and licensed under the AFFERO GNU General Public License as published by the Free Software Foundation. You should have received a copy of the AFFERO GNU General Public License. If not, see <http://www.gnu.org/licenses/agpl-3.0.html>

License of this Docker image can be found in the `LICENSE`file.



## Notes
This Docker image is for demonstration purposes only. Building the image includes both compiling software from sources and installing binaries. Some installations require downloading files which are not provided within this image (e.g. GDAL source code). If these links are not available or URLs become invalid, the build procedure might fail. 



----

## Author

Marius Appel  <marius.appel@uni-muenster.de>
