#Clear and set Directory
rm(list = setdiff(ls(), lsf.str()))
#load required packages
library(tidyverse)
library(readxl)
library(xlsx)
library(data.table)
library(reshape2)
library(ggplot2)
library(RColorBrewer) 
library(viridis)
library(mirt)

#plotting of data
library(ggbeeswarm)
library(skimr)
library(janitor)
library(ggridges)
library(hrbrthemes)
library(datasets)

#k-means clustering
library(cluster)    # clustering algorithms
library(factoextra) # clustering algorithms & visualization
library(gridExtra)
library(ggpubr)#for arranging plots

#set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))#always the order where the script is
getwd()
fps<- 25 #check the right fps #0.1/0.8333
frames<-2001

#-----------First step----------------------------------------------------------------------------------------------
#Load excel files with single neuronal tracks and merge tracks into one and then merge the excel files
files <- list.files(pattern = ".xls" )#generates a list with alö files which contain the defined pattern


temp<- lapply(files, function(x) read_excel(x, 
                                            guess_max=frames, #Maximum number of data rows to use for guessing column types.
                                            sheet = 1))#loads the excel files as a list, sheet defines which sheet in your excel file you want to load
data<-split_list_keepID(temp, frames)#makes the list to a dataframe
str(data)

#save data in the working directory
#save file
write.csv(data, file = paste(files[1],"_raw.csv"), row.names = FALSE)

#------------Second step------------------------------
head(data)
str(data)

data[is.na(data)]<- 0 #replace NA with 0
head(data)
#Transforming with multiple track files
#transform to matrix
mat<-as.matrix(data)

#remove rownames and Frame
mat2<-mat[,-1]
head(mat)

#matrix to table
data2<-reshape2::melt(mat2)
head(data2)
str(data2)
#clean the track names
#split variable so maintain id of table/file
data2$Groupe <- sub("*_linked.tracks.*","", data2$Var2)
data2$Var2 <- sub(".*linked.","", data2$Var2)

data2$Groupe<-as.factor(data2$Groupe)
#split variable so maintain id of table/file
head(data2)
str(data2)

#rename the colums
colnames(data2)[1] <- "Frames"
colnames(data2)[2] <- "Tracks"
colnames(data2)[3] <- "Raw"
data2$Tracks<-as.factor(data2$Tracks)
head(data2)


#---------------third normalization-----------------------------------------------------------------------
#show data
head(data2)

#Calculating the deltaF/F0 the change of fluorescence
#F0 is the median of the fluorescence (F) distribution
#substract F0 from the fluorescence
data2[data2 == 0]<-NA
hist(data2$Raw, na.rm= TRUE)


#load functions manually before continuing
#take f0 from the mean value of a non-active head (fiji, here: 48)
data3<-mdeltaf(data2)#measured  and mean 66
#data1<-all_mdeltaf(data1, delta = 0)
#data1<-all_qdeltaf(data1, delta = 0)
#data1<-all_mdeltaf(data1, delta = 0)
head(data3)
str(data3$Groupe)
#data2<-finale
#plot the recalculated data
hist(data3$mDeltaF, na.rm= TRUE)

#replace NAs with value 0
data3[is.na(data3)]<- 0 #replace NA values with 0
str(data3)
head(data3)

#calculate the time
data3[ncol(data3)+1]<-data3[1]
#fps<- 0.1111 #check the right fps
data3[ncol(data3)]<-(1:data3[nrow(data3), 1]/ fps)
colnames(data3)[ncol(data3)] <- "Time"
head(data3)
str(data3)

#Save the file in the working directory
#?write.csv
write.csv(data3, file = "H66-3_mDelta_RAW.csv",row.names = FALSE)


#all negative values to 0
data3<- data3 %>% 
  mutate(mDeltaF = if_else(mDeltaF < 0, 0, mDeltaF))

#smoothen data
#smooth data
smooth = ksmooth(time(data3$Time), data3$mDeltaF, kernel = 'normal', bandwidth= 5) #bandwith defines how strong
data3$DeltaSmooth = smooth$y

#visualize
ggplot(data= data3, aes(x = Time, y = mDeltaF)) +
  geom_line(size=0.5, alpha= .5)+
  geom_line(aes(x = Time, y = DeltaSmooth), size=0.5, alpha= .5, color = "red", linewidth = 2)+
  geom_point(size=0.5,alpha= .5)+
  #stat_summary(fun.data = "mean_se", size =1)+
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black", size = 3),
        axis.ticks.length=unit(.25, "cm"),
        axis.ticks = element_line(size = 2),
        axis.text.x = element_text(size = 24, angle = 45, hjust = 1), 
        axis.title.x =element_text(size = 24),
        axis.text.y = element_text(size = 24), 
        axis.title.y =element_text(size = 24),
        legend.position="none"
  )+
  ylab("mDeltaF/F")+
  xlab("Time (sec)")+
  facet_grid(~Tracks)



###first plotting before continue
#heat map of tracks
ggplot(data= data3, aes(Frames, Tracks, fill= mDeltaF))+
  geom_tile()+
  ylab("Neurons")+
  xlab("Frames")+
  scale_fill_viridis(discrete=FALSE)+
  #scale_x_continuous( breaks= seq(0,2641,10))+
  theme(axis.title.x = element_text(face="bold", colour="#990000", size=20), axis.text.x  = element_text(angle=45, vjust=0.5, size=14))+
  theme(axis.title.y = element_text(face="bold", colour="#990000", size=20),  
        axis.text.y  = element_text(vjust=0.5, size=5)
        #axis.text.y = element_blank()
  )+
  theme(axis.text = element_blank())

#save file
write.csv(data3, file = "H66-3_finale_file.csv", row.names = F)

######################################final step clustering################################################
#cluster analysis, finding groups and ensembles
#load data
#first as rownames
data2<-acast(data3, Frames~Tracks, value.var="DeltaSmooth") #Transform into matrix
head(data2)


mydata <- na.omit(data2) # listwise deletion of missing

head(mydata)

#switch column with rows
mydata<-t(mydata)
head(mydata)
distance <- get_dist(mydata,
                     method = "pearson",
                     stand = FALSE  #standardize variables
)

#plotting the correlation distance matrix
distance<- na.omit(distance)
pear1<-fviz_dist(distance,
                 order = TRUE, 
                 gradient = list(low = "#FDE725FF", mid = "#238A8DFF", high = "#440154FF"),
                 lab_size = 7)
pear1
#pear2<-fviz_dist(distance,
#                 order = TRUE, 
#                 gradient = list(low = "#FDE725FF", mid = "#238A8DFF", high = "#440154FF"),
#                 lab_size = 9)

#arrange plots into one
#ggarrange(pear2, pear1, 
#          labels = c("A", "B", "C"),
#          ncol = 1, nrow = 2)


#k-mean clustering
k2 <- kmeans(mydata, centers = 2, nstart = 25)
str(k2)

#extract k-mean cluster ids
ids<-as.data.frame(k2$cluster)
head(ids)

which(apply(mydata, 2, var)==0)
mydata<-mydata[ , which(apply(mydata, 2, var) != 0)]

fviz_cluster(k2, data = mydata,
             ellipse.type = "convex", #"convex"
             ggtheme = theme(panel.grid.major = element_blank(), 
                             panel.grid.minor = element_blank(),
                             panel.background = element_blank(),
                             axis.line = element_line(colour = "black", size = 1),
                             panel.border = element_rect(linetype = "solid", size = 1, fill = NA)
             )
)

#getAnywhere("fviz_cluster")

k3 <- kmeans(mydata, centers = 3, nstart = 25)
k4 <- kmeans(mydata, centers = 4, nstart = 25)
k5 <- kmeans(mydata, centers = 5, nstart = 25)

# plots to compare
p1 <- fviz_cluster(k2, geom = "point", data = mydata) + ggtitle("k = 2")
p2 <- fviz_cluster(k3, geom = "point",  data = mydata) + ggtitle("k = 3")
p3 <- fviz_cluster(k4, geom = "point",  data = mydata) + ggtitle("k = 4")
p4 <- fviz_cluster(k5, geom = "point",  data = mydata) + ggtitle("k = 5")

library(gridExtra)
grid.arrange(p1, p2,p3, p4, nrow = 2)


#dtermine the optimal cluster number
set.seed(123)

fviz_nbclust(mydata, kmeans, method = "wss")
fviz_nbclust(mydata, kmeans, method = "silhouette")


# compute gap statistic
set.seed(123)
gap_stat <- clusGap(mydata, FUN = kmeans, nstart = 25,
                    K.max = 3, B = 50)
# Print the result
print(gap_stat, method = "firstmax")
fviz_gap_stat(gap_stat)

