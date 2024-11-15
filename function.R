
mdeltaf<- function(data) {
  n<-1 #the first value of the track
  i<-1
  m<- length(data$Tracks[data$Tracks == data$Tracks[1]])
  col = ncol(data)+1#where to put the new column

  
  for (i in 1:nlevels(data$Tracks)) {
    
    if (data$Tracks[m] == data$Tracks[n] | m <= length(data$Tracks)){
      
      track<- data$Tracks[n] # the new track

      f0 <-median(data$Raw[data$Tracks == track], na.rm= TRUE)#here you can change how to select the f0
      
      data[n:m, col]<- (data[n:m, 3]- f0) #substract the median
      data[n:m, col]<- (data[n:m, col]/ f0)
      
      n <- n + length(data$Tracks[data$Tracks == track])
      m<- m + length(data$Tracks[data$Tracks == track])
      
      print("mDelta")
      print(track)
      print(f0)
      
      
    }else{
      
      m<- m-1
      print("error")
      
    }
  }
  colnames(data)[col] <- "mDeltaF"
  return(data)
  }
  

split_list_keepID = function(temp,frames){
  
  #new.names=c(1:length(temp))
  #  
  #  for (i in 1:length(temp)){
  #    new.names[i]= paste0("temp", i)
  #    names(temp)[i]<-new.names[i]
  #  }
  #generate dataframe with all dataframes will be aligned
  frames_table<-0:frames
  frames_table<- as.data.table(frames_table)
  colnames(frames_table)[1]<- "Frame.number"
  
  for (i in 1:length(temp)){
    sub<-as.data.frame(temp[i])#subset dataframe list
    #add Frame number for the whole recording
    #sub<-full_join(frames_table,sub,by= "Frame.number", keep= T)
    #colnames(sub)[1]<-"Frame.number"
    #remove unnecessary column
    #sub <- subset(sub, select = - c(Frame.number.y))  
    #print(str(sub))
    #remove parts of the column names 
    names(sub) = gsub(pattern = ".*.xls.", replacement = "", x = names(sub))
    #sub$Frame.number<- frames_table
    #add number responding to the excel sheet used in chronicel order
    number<-as.character(i)
    colnames(sub)[2:ncol(sub)]<-paste(number, colnames(sub)[2:ncol(sub)], sep = "_")
    #merge tables
    if (i == 1){
      data= merge(frames_table,
                  sub,
                  by="Frame.number", all.x= TRUE)#merge with dataframe with frames
    }else{
      data= merge(data,
                  sub,
                  by="Frame.number", all.x= TRUE)
    }
  }
  return(data)
}
