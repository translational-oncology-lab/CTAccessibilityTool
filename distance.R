distance<-function(x0,y)
{
  #function to compute geographical distance between two points
  # x0: long and lat of the city/node
  # y: dataset with research centres
  
  library("geosphere")
  
  minim<-10^20 # fix a high minimum
  elmin<-"a" #give a fake address
  for (el in unique(as.character(y$RealAddress)))
  {
    #print(el)
    who<-which(as.character(y$RealAddress)==as.character(el))[1]

    k<-distm(x0, y[who,c(2,3)], function(x,y) distHaversine(x,y))[1,1]
    
    # if the couple exists, substitute the minimum distance and the address
    if (is.finite(k)==TRUE & k<minim)
    {
      minim<-k
      elmin<-as.character(el)
    }
  }
  if (minim==0) #if they are in the same place, set the minimum to 1,000m
    minim<-1000
  
  # convert in Km and return the minimum distance and the place giving it
  return(c("Address"=elmin,"Km"=(minim/1000)))
}