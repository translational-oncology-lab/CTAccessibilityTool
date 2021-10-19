index_simulation_log<-function(gp,rc,case)
{
  #function to compute index for simulated configurations
  
  library(ggplot2)
  library(gridExtra)
  library(reshape2)
  library(RColorBrewer)
  
  source('index.R')
  
  ##### some function useful in the following ######
  #1. distance
  distance_sim<-function(A,B)
  {
    minim<-10^20
    elmin<-"a"
    for (i in seq(1,nrow(B)))
    {
      el<-B$Point_name[i]
      
      mat<-matrix(c(as.numeric(A[,c(1,2)]),as.numeric(B[i,c(2,3)])),nrow=2,ncol=2,byrow=TRUE)
      
      k<-dist(mat) # distances between the rows of a data matrix.
      if (is.finite(k)==TRUE & k<minim)
      {
        minim<-k
        elmin<-as.character(el)
      }
    }
    return(c("Research_point"=elmin,"Distance"=minim))
  }
  
  #2. compute the indexes
  index_my<-function(data)
  {
    cind1<-numeric()
    for (i in seq(1,nrow(data)))
    {
      #add the log of the population to have the complete index
      cind1<-c(cind1,index(log(data$Population[i]),as.numeric(as.character(data$Distance[i])),data$Studies[i]))
    }
    ni_1<-(sum(cind1*log(data$Population)))/sum(log(data$Population))
    
    ind<-data.frame("index_1"=cind1)
    ni<-ni_1
    return(list(ind,ni))
  }
  
  ######### compute everything
  #1. find the closest research point
  myc<-FALSE #I need this variable to compute the cases for different number of studies
  
  gp_new<-data.frame()
  closest<-data.frame()
  for(i in seq(1,nrow(gp)))
  {
    dis<-distance_sim(gp[i,c(3,4)], rc[,c(2,3,4)])
    closest<-rbind(closest,cbind(dis[1],dis[2]))
  }
  colnames(closest)<-c("Research_point","Distance")
  gp_new<-cbind(gp,closest)
  
  gp_rc<-merge(gp_new,rc,by.x="Research_point",by.y="Point_name")
  
  #2. add the number of studies
  nstud<-seq(5,50, by=5)
  
  #separate cases to check the importance of n studies
  nc<-unique(rc$Point_name)
  print(nc)
  
  if (length(nc)==1)
  {
    cases<-list(nc[1])
    if (nc=="A")
      names<-c("A") else
        names<-c("E")
  }
  
  if (length(nc)==2)
  {
    if ("E" %in% nc)
    {
      k<-which(nc=="E")
      cases<-list(nc[1],nc[k],nc)
      names<-c("A","E",paste(nc[1],nc[2],sep=""))
    } else
    {
      cases<-list(nc[1],nc)
      names<-c("A",paste(nc[1],nc[2],sep=""))
    }
  }
  
  if (length(nc)==3)
  {
    if (!(FALSE %in% (nc==c("A","B","E"))))
    {
      myc<-TRUE
      cases<-list(nc[1],nc[2],nc[3],nc[c(1,2)],c(as.character(nc[c(1,2)]),"Double"),c(as.character(nc[c(2,1)]),"Double"),
                  nc[c(1,3)], c(as.character(nc[c(1,3)]),"Double"),c(as.character(nc[c(3,1)]),"Double"),
                  nc[c(2,3)],c(as.character(nc[c(2,3)]),"Double"),c(as.character(nc[c(3,2)]),"Double"), nc)
      names<-c("A","B","E",paste(nc[1],nc[2],sep=""),paste("2",nc[1],nc[2],sep=""),paste(nc[1],"2",nc[2],sep=""),
               paste(nc[1],nc[3],sep=""),paste("2",nc[1],nc[3],sep=""),paste(nc[1],"2",nc[3],sep=""),
               paste(nc[2],nc[3],sep=""),paste("2",nc[2],nc[3],sep=""),paste(nc[2],"2",nc[3],sep=""),
               paste(nc[1],nc[2],nc[3],sep=""))
      linet<-c(1,1,1,1,2,3,1,2,3,1,2,3,1)
    } else
    {
      if ("E" %in% nc)
      {
        k<-which(nc=="E")
        cases<-list(nc[1],nc[k],nc[c(1,2)], nc[c(1,3)], nc)
        names<-c("A","E",paste(nc[1],nc[2],sep=""),paste(nc[1],nc[3],sep=""),
                 paste(nc[1],nc[2],nc[3],sep=""))
      } else
      {
        cases<-list(nc[1],nc[c(1,2)],nc[c(1,3)],nc[c(2,3)],nc)
        names<-c("A",paste(nc[1],nc[2],sep=""),paste(nc[1],nc[3],sep=""),paste(nc[2],nc[3],sep=""),
                 paste(nc[1],nc[2],nc[3],sep=""))
      }
    }
  }
  
  if(length(nc)==4)
  {
    if ("E" %in% nc)
    {
      k<-which(nc=="E")
      cases<-list(nc[1],nc[2],nc[3],nc[4],nc[c(1,2)],nc[c(1,3)],nc[c(1,4)],nc[c(2,3)],nc[c(2,4)],nc[c(3,4)],
                  nc[c(1,2,3)],nc[c(1,2,4)],nc[c(1,3,4)],nc[c(2,3,4)],nc)
      names<-c("A","B","C","E",paste(nc[1],nc[2],sep=""),paste(nc[1],nc[3],sep=""),paste(nc[1],nc[4],sep=""),
               paste(nc[2],nc[3],sep=""),paste(nc[2],nc[4],sep=""),paste(nc[3],nc[4],sep=""),
               paste(nc[1],nc[2],nc[3],sep=""),paste(nc[1],nc[2],nc[4],sep=""),paste(nc[1],nc[3],nc[4],sep=""),paste(nc[2],nc[3],nc[4],sep=""),
               paste(nc[1],nc[2],nc[3],nc[4],sep=""))
    } else {
      cases<-list(nc[1],nc[c(1,2)],nc[c(1,3)],nc[c(1,4)],nc[c(1,2,3)],nc)
      names<-c("A",paste(nc[1],nc[2],sep=""),paste(nc[1],nc[3],sep=""),paste(nc[1],nc[4],sep=""),
               paste(nc[1],nc[2],nc[3],sep=""),paste(nc[1],nc[2],nc[3],nc[4],sep=""))
    }
  }
  
  if(length(nc)==5)
  {
    cases<-list(nc[1],nc[5],nc[c(1,2)],nc[c(1,3)],nc[c(1,4)],nc[c(1,5)],
                nc[c(1,2,3)],nc[c(1,2,5)],nc[c(1,3,5)],nc[c(1,4,5)],
                nc[c(1,2,3,4)],nc[c(1,2,3,5)],nc)
    names<-c("A","E",paste(nc[1],nc[2],sep=""),paste(nc[1],nc[3],sep=""),paste(nc[1],nc[4],sep=""),
             paste(nc[1],nc[5],sep=""),paste(nc[1],nc[2],nc[3],sep=""),paste(nc[1],nc[2],nc[5],sep=""),
             paste(nc[1],nc[3],nc[5],sep=""),paste(nc[1],nc[4],nc[5],sep=""),
             paste(nc[1],nc[2],nc[3],nc[4],sep=""),paste(nc[1],nc[2],nc[3],nc[5],sep=""),
             paste(nc[1],nc[2],nc[3],nc[4],nc[5],sep=""))
  }
  
  print(names)
  #compute the indexes for the cases
  nindex1<-data.frame("Nstud"=nstud)
  
  ind_grid<-data.frame()
  for (i in seq(1,length(cases)))
  {
    print(cases[[i]])
    
    gp_rc_s<-gp_rc
    k<-which(gp_rc_s$Research_point %in% cases[[i]])
    
    ni1<-numeric()
    
    for (j in nstud)
    {
      gp_rc_s$Studies[k]<-j
      if ("Double" %in% cases[[i]])
      {
        kc1<-which(gp_rc_s$Research_point==cases[[i]][1])
        kc2<-which(gp_rc_s$Research_point==cases[[i]][1])
        gp_rc_s$Studies[kc1]<-2*j
        gp_rc_s$Studies[kc2]<-j
      }
      #compute index
      ind_gp<-index_my(gp_rc_s)
      
      ni1<-c(ni1,ind_gp[[2]][1])
    }
    nindex1<-cbind(nindex1,ni1)
  }
  colnames(nindex1)[-1]<-names
  
  ####plots
  # 1. grid that is used
  p1<-ggplot(gp,aes(x,y, shape=Label))+
    geom_point(aes(col=as.factor(Population)),size=5)+
    scale_color_manual(values = c("200"="mediumblue","100" = "dodgerblue", "50" = "skyblue"))+
    geom_point(data=rc, aes(x,y),size=7)+
    geom_text(data=rc, aes(label=Point_name),color="white")+
    ggtitle(paste("Configuration:",case,sep=" "))
  p1
  
  #2. plot of cases
    nindex1_2<-melt(nindex1,id.vars="Nstud",measure.name=colnames(nindex1)[-1])
    nindex1_2$Index<-rep("index_1",nrow(nindex1_2))

  
  nindex1_2$Index<-rep("Accessibility",nrow(nindex1_2))

  fin_1<-nindex1_2
  plots<-p1
  
  final_1<-nindex1_2[,c(1,2,3)]
  colnames(final_1)<-c("Nstud","Case","Accessibility")
  
  return(list(final_1,plots))
}