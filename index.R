index<-function(p,d,n)
{
  ### function for index computation
  #p: population density on the grid point
  #d: distance from the closest research center (km)
  #n: number of studies of the research center
  #e: number of enrolled patients of the research center
  
  ind<-(n)/(sqrt(d)*p)
  
  return(ind)
}
