compute_index<-function(Country, pop_dens, stud,who)
{
  #Country: the country we are interested in
  #pop_dens: data frame with already computed the nation for each point and denstity data from nasa
  #stud: info on research places with number of studies
  #who we want for output: "Index" to return only the national index, 
  #                        "Other" to return also the local index for all the grid points

  source('distance.R')
  source('index.R')
  
  #put together all the info from data density and clinical_trials
  #mantain only the grid points of the selected country
  country_dens<-as.data.frame(subset(pop_dens, name_long==Country))
  
  pop_years<-c(2005,2010,2015)
  tot_years<-seq(2005,2019,by=1)
  #combine populaion data with studies: pop of 2000 is related to studies in 2000,2001,2002, 2003,2004 etc
  combo<-cbind(rep(pop_years,each=5),tot_years)
  
  #associate the closest research centre to each grid point, according to the matrix of years
  for (nr in seq(1,nrow(combo)))
  {
    print(nr)

    yp<-combo[nr,1]
    ys<-combo[nr,2]
    k<-which(pop_years==yp)+1
    
    cdy<-country_dens[,c(k,7,8)] #density for the selected year, lon e lat
    
    closest<-data.frame()
    for(j in seq(1,nrow(cdy)))
    {
      dis<-distance(cdy[j,c(2,3)], subset(stud, (year==ys & country==Country))[,c("RealAddress","lon","lat")])
      closest<-rbind(closest,cbind(dis[1],dis[2]))
    }
    colnames(closest)<-paste(c("Address","Km"),ys,sep="_")
    country_dens<-cbind(country_dens,closest) #else
  }
  
  #add number of studies for each research centre
  #define in which columns there are the values
  colk<-seq(5,19)*2
  y<-0
  for (j in colk)
  {
    y<-y+1
    print(tot_years[y])
    
    st<-subset(stud, (year==tot_years[y] & country==Country))
    print(nrow(st))
    
    if (nrow(st)>0)
    {
      nstud<-numeric()
      for (i in seq(1,nrow(country_dens)))
      {
        print(i)
        el<-as.character(country_dens[i,j])
        
        k<-which(as.character(st$RealAddress)==el)[1]
        #print(k)
        nstud<-c(nstud,st$nstudies[k])
      }
    } else
     {
      nstud<-rep(0,nrow(country_dens))
     }
    country_dens<-cbind(country_dens, nstud)
  }
  colnames(country_dens)[seq(40,54)]<-paste("nstudies",tot_years,sep="_")
  
  #compute index for each year and the national index
  national_index<-numeric()
  
  for (el in seq(1,nrow(combo)))
  {
    yp<-combo[el,1]
    ys<-combo[el,2]
    n1<-paste("density",yp,sep="_")
    n2<-paste("Km",ys,sep="_")
    n3<-paste("nstudies",ys,sep="_")

    st<-country_dens[,c(n1,n2,n3)]
    
    st[,n2]<-as.numeric(as.character(st[,n2]))
    
    cind<-numeric()
    for (i in seq(1,nrow(st)))
    {
      cind<-c(cind,index(country_dens[i,n1],as.numeric(as.character(country_dens[i,n2])),country_dens[i,n3]))#,country_dens[i,n4]))
      #print(cind)
    }
    
    ni<-(sum(cind*country_dens[,n1]))/sum(country_dens[,n1])
    national_index<-c(national_index,ni)
    
    country_dens<-cbind(country_dens, cind)
  }
  colnames(country_dens)[seq(55,69)]<-paste("index",tot_years,sep="_")
  
  if (who=="Index")
    return(list("NI"=national_index))
  else
    return(list("data"=country_dens,"national_index"=national_index))
}