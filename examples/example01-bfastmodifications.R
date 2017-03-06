#library(devtools)
#install_github("appelmar/strucchange")
#install_github("appelmar/bfast")

library(bfast)
NDVIa <- as.ts(zoo(som$NDVI.a, som$Time))
f <- function() bfastmonitor(NDVIa, start = c(2010, 13), history = "ROC") 

set_default_options()
x = f() 
system.time(replicate(100, f()))

set_fast_options()
y = f()
system.time(replicate(100, f()))

par(mfrow = c(1,2))
plot(x) ; plot(y)
