
library(bfastSpatial) # if needed, install with devtools::install_github('loicdtx/bfastSpatial')
data(tura)


set_default_options() 
system.time(bfm.tura.reference <- bfmSpatial(tura, start=c(2009, 1), history = "ROC"))


set_fast_options()
system.time(bfm.tura.new <- bfmSpatial(tura, start=c(2009, 1), history = "ROC"))


plot(bfm.tura.new$breakpoint - bfm.tura.reference$breakpoint)
plot(bfm.tura.new$magnitude - bfm.tura.reference$magnitude)



  

