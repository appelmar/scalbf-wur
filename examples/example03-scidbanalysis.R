
#library(devtools)
#install_github("Paradigm4/SciDBR")
#install_github("flahn/scidbst")



library(scidb)
library(scidbst)
scidbconnect(host      = Sys.getenv("scidb.host"),
             username  = Sys.getenv("scidb.username"),
             password  = Sys.getenv("scidb.password"),
             port      = Sys.getenv("scidb.port"),
             auth_type = "digest",
             protocol  = "https")


# what do we have in the database?
scidbst.ls(extent = T)



# save a proxy object to the Ethiopia array in l7
l7 = scidbst("L7_SW_ETHOPIA")
l7

# subset a small region
l7.subset = crop(l7,  extent(37.42, 37.48, 9.78, 9.81))

# repartition the data
l7.subset.repart = repart(l7.subset, chunk=c(32,32,4177))


# compute NDVI and omit invalid values
l7.subset.repart.ndvi = filter(project(transform(l7.subset.repart, ndvi="double(band1) / 10000"), "ndvi"), "ndvi >= -1 and ndvi <=1")

# make dimension values available as attributes
l7.subset.bfast.in = transform(l7.subset.repart.ndvi, dimx = "double(x)", dimy = "double(y)", dimt="double(t)")




# generate a random name to store the array
array.name1 = paste("wur_", paste(sample(letters,replace = T, size = 12), collapse=""), sep="")
array.name1


# the following command runs the operations above and stores the result as a new array
# takes a few minutes
scidbsteval(l7.subset.bfast.in, name = array.name1)





# compute a few summary statistics
l7.subset.bfast.in = scidbst(array.name1)
l7.subset.repart.ndvi.stats = aggregate(l7.subset.bfast.in, FUN="max(ndvi), min(ndvi), avg(ndvi), count(*)")

# download the summary data, the proxy slot returns the scidb object
l7.subset.repart.ndvi.stats@proxy[]







# generate a random name to store the output array
array.name2 = paste("wur_bfastmonitor_", paste(sample(letters,replace = T, size = 12), collapse=""), sep="")
array.name2





# more difficult part: running bfastmonitor


afl.query.R = paste("store(unpack(r_exec(", array.name1, ",'output_attrs=5','expr=
                require(xts)
                require(bfast)
                require(plyr)
                set_fast_options()
                ndvi.df = data.frame(ndvi=ndvi,dimy=dimy,dimx=dimx,dimt=dimt)
                f <- function(x) {
                return(
                  tryCatch({
                    ndvi.ts = bfastts(x$ndvi,as.Date(\"2003-07-21\") + x$dimt,\"irregular\")
                    bfast.result = bfastmonitor(ndvi.ts, start = c(2010, 1), order=1,history=\"ROC\")
                    return(c(nt=length(x$dimt), breakpoint = bfast.result$breakpoint,  magnitude = bfast.result$magnitude ))
                  }, error=function(e) {
                    return (c(nt=0,breakpoint=NA,magnitude=NA))
                  }))}
                  ndvi.change = ddply(ndvi.df, c(\"dimy\",\"dimx\"), f)
                  list(dimy = as.double(ndvi.change$dimy), dimx = as.double(ndvi.change$dimx), nt = as.double(ndvi.change$nt), brk = as.double(ndvi.change$breakpoint), magn = as.double(ndvi.change$magnitude) )'),i), 
                ", array.name2 ,")", sep="")


iquery(afl.query.R) # this runs the query above and takes a few minutes

# the result has no spatial / temporal reference any longer, thus we work with
# scidb instead of scidbst for now and set the spatial reference later


# postprocess the result to form a two-dimensional spatially referenced array
l7.subset.bfast.out = scidb(array.name2)
l7.subset.bfast.out


# change names and data types of attribute
l7.subset.bfast.out = scidb::project(transform(l7.subset.bfast.out, y="int64(expr_value_0)", x="int64(expr_value_1)", n = "int16(expr_value_2)", breakdate = "expr_value_3", magnitude="expr_value_4"), c("y","x","n","breakdate","magnitude"))
head(l7.subset.bfast.out)


# redimension the array such that y and x become dimensions whereas i will be dropped
l7.subset.bfast.out.redim = redimension(l7.subset.bfast.out,dim = c("y","x"))



# for simplicity, we trim empty cells around the actual data

# check the actual array extent of the input array
array_extent = aggregate(l7.subset.bfast.in, FUN="min(dimx),max(dimx),min(dimy),max(dimy),min(dimt),max(dimt)")@proxy[]
array_extent
l7.subset.bfast.out.redim.trimmed = subarray(l7.subset.bfast.out.redim,limits = c(4689,7597, 4800, 7819))


# generate a random name to store the output array
array.name3 = paste("wur_bfastmonitor_map_", paste(sample(letters,replace = T, size = 12), collapse=""), sep="")
array.name3

scidbeval(l7.subset.bfast.out.redim.trimmed, name=array.name3)



# now, derive spatial reference of result array 
srs.reference.array = subarray(l7.subset.bfast.in,limits = c(7597,4689,0, 7819, 4800, 0))
setSRS(scidb(array.name3), srs(srs.reference.array), affine(srs.reference.array))




# now that we have a spatial reference, we can use scidbst again and
# explore the results
result = scidbst(array.name3)
result

x = as(result, "RasterBrick")
plot(x$n)
plot(x$breakdate)
plot(x$magnitude)



#library(mapview)
#mapView(x$breakdate)



# clean up
scidbrm(array.name1, force=TRUE)
scidbrm(array.name2, force=TRUE)
scidbrm(array.name3, force=TRUE)


# clean up everything
#wur_arrays =  scidbls()
#wur_arrays = wur_arrays[grep("wur_", wur_arrays)]
#scidbrm(wur_arrays, force=T)

