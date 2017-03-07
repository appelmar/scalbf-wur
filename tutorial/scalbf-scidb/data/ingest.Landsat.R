library(gdalUtils)

LANDSAT_DIR = "/opt/data/Landsat/"
TARGET_SRS  = "EPSG:4326"

SCIDB_HOST = "https://localhost"
SCIDB_PORT = 8083
SCIDB_USER = "scidb"
SCIDB_PW   = "xxxx.xxxx.xxxx"
TEMPWARPFILE = "test.tif"
SCIDBARRAYNAME = "L7_SW_ETHOPIA"
BBOX = "32.0 1.5 45.0 15.0"

# We don't want to pass this information in every single gdal_translate call und thus set it as environment variables
Sys.setenv(SCIDB4GDAL_HOST=SCIDB_HOST,  SCIDB4GDAL_PORT=SCIDB_PORT, SCIDB4GDAL_USER=SCIDB_USER, SCIDB4GDAL_PASSWD=SCIDB_PW)


image.files = data.frame(path=list.files(LANDSAT_DIR, "*.tif",full.names = T),stringsAsFactors = F)
image.files$name = basename(image.files$path)
image.files$wrs2path = as.integer(substr(image.files$name,4,6))
image.files$wrs2row = as.integer(substr(image.files$name,7,9))
image.files$t = strptime(substr(image.files$name,10,16), format="%Y%j")
image.files = image.files[order(image.files$t),] # order by time


# ingest first image
i = 1

status.started = format(Sys.time())
cat(paste(status.started, ": ", image.files$name[i], " (", i, "/", nrow(image.files), ") ...", sep=""))
res = gdalwarp(image.files$path[i], t_srs = TARGET_SRS,dstfile = TEMPWARPFILE, overwrite = TRUE)
res = gdal_translate(src_dataset = TEMPWARPFILE,
                dst_dataset = paste("SCIDB:array=", SCIDBARRAYNAME, sep=""),
                of = "SciDB", co = list(paste("t=",format(image.files$t[i],"%Y-%m-%d"),sep=""), "dt=P1D",  paste("bbox=",BBOX,sep=""), paste("srs=", TARGET_SRS, sep=""), "type=STS"))
cat(" DONE. (" , round(100* (i) / nrow(image.files),digits=2) , "%)")
cat("\n")
i = i + 1


# ingest other images
while (i <= nrow(image.files)) 
{
  status.started = format(Sys.time())
  cat(paste(status.started, ": ", image.files$name[i], " (", i, "/", nrow(image.files), ") ...", sep=""))
  res = gdalwarp(image.files$path[i], t_srs = TARGET_SRS,dstfile = TEMPWARPFILE, overwrite = TRUE)
  res = gdal_translate(src_dataset = TEMPWARPFILE,dst_dataset = paste("SCIDB:array=", SCIDBARRAYNAME, sep=""), of = "SciDB", co =list("type=ST",paste("t=",format(image.files$t[i],"%Y-%m-%d"),sep=""),  "dt=P1D"))
  cat(" DONE. (" , round(100* (i) / nrow(image.files),digits=2) , "%)")
  cat("\n")
  i = i + 1
}

cat(paste(Sys.time(), ": FINISHED!\n\n", sep=""))
