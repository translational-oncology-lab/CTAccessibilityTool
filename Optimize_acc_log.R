Optimize_acc_log<-function(pop,count,stud,gcount,ns,rate)
{
  # functions to compute accessibility for all the grid points in selected country
  
  # pop: pulation density
  # count: selected country
  # stud: studies for all the countries
  # gcount: country in format for map_data, see maps::map() for more details
  # ns: number of studies to add
  
  library(tidyverse)
  library(maps)
  library(ggplot2)
  
  source('distance.R')
  source('index.R')
  
  git<-map_data("world", region = gcount)
  
  Count<-as.data.frame(subset(pop, name_long==count))
  Count<-Count[,c(5,7,8)]
  Studies_base_C<-subset(stud, country==count)
  Studies_base_C<-as.data.frame(subset(Studies_base_C, year==2019))
  
  lats_i<-seq(min(Count$lat),max(Count$lat), by=1)
  long_i<-seq(min(Count$lon),max(Count$lon), by=1)
  
  # define the new locations to try: they are the grid points
  New_points<-subset(Count)[,c(2,3)]
  New_points$country<-rep(count,nrow(New_points))
  New_points$RealAddress<-paste("point_",seq(1,nrow(New_points)),sep="")
  New_points$year<-rep(2019,nrow(New_points))
  New_points$nstudies<-rep(ns,nrow(New_points))
  New_points<-as.data.frame(New_points[,colnames(Studies_base_C)])
  
  if (nrow(Studies_base_C)>0)
  {
    kno<-which(New_points$RealAddress==Studies_base_C$RealAddress[nrow(Studies_base_C)])
    if (length(kno)>0)
      New_points<-New_points[-kno,]
  }
  
  national_index<-numeric()
  
  #define max for NI and save the local accessibilities
  max_ni<-0
  max_cind<-rep(0,nrow(New_points))
  
  #3. compute index for all the cases
  for (i in seq(1,nrow(New_points)))
  {
    print(i)
    
    it_new<-Count
    stf<-rbind(Studies_base_C,New_points[i,])
    
    #compute distance for the points
    closest<-data.frame()
    for(j in seq(1,nrow(it_new)))
    {
      dis<-distance(it_new[j,c(2,3)], subset(stf)[,c("RealAddress","lon","lat")])
      closest<-rbind(closest,cbind(dis[1],dis[2]))
    }
    colnames(closest)<-c("Address","Km")
    
    it_new<-cbind(it_new,closest)
    
    ## add number of trials
    nstud<-numeric()
    for (ii in seq(1,nrow(it_new)))
    {
      el<-as.character(it_new$Address[ii])
      k<-which(as.character(stf$RealAddress)==el)
      nstud<-c(nstud,stf$nstudies[k])
    }
    it_new<-cbind(it_new, "nstudies"=nstud)
    
    ## compute index
    cind<-numeric()
    for (ii in seq(1,nrow(it_new)))
    {
      cind_k<-(index(it_new$density_2015[ii],
                    as.numeric(as.character(it_new$Km[ii])),
                    it_new$nstudies[ii])*it_new$density_2015[ii])/log(it_new$density_2015[ii]*rate)
      cind<-c(cind,cind_k)
    }
    
    ni<-(sum(cind*log(it_new$density_2015*rate)))/sum(log(it_new$density_2015*rate))
    national_index<-c(national_index,ni)
    
    if (ni>max_ni)
    {
      max_ni<-ni
      max_cind<-cind
    }
    
  }
  
  reuslts<-cbind(New_points,"NI_1"=national_index)
  
  return(list(reuslts,max_ni,max_cind))
}