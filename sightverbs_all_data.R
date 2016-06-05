# This script analyzes raw ratings of verb pairs.  
# - formats the raw output, applies condition labels, and does basic checks at the individual, group, and word level
# - checks correlations across groups and across individuals (starting line 361) 
# - turns ratings ito distance matrices and applies (starting line 548)
#   - hierarchical clustering with plots + bootstrap (line 641/715)
#   - multidimensional scaling (standard and with SMACOF lines 787, 844) 
#   - indivudal differences scaling (IndScal, line 883) 
#   - K medoids to check space in subjective (distance matrix only) frame (line 1055)

## PACKAGES 

if (!require("pracma")) {install.packages("pracma"); require("pracma")}
#if (!require("xlsx")) {install.packages("xlsx"); require("xlsx")}
if (!require("ez")) {install.packages("ez"); require("ez")}
if (!require("psych")) {install.packages("psych"); require("psych")}
if (!require("plotrix")) {install.packages("plotrix"); require("plotrix")}
if (!require("reshape")) {install.packages("reshape"); require("reshape")}
if (!require("reshape2")) {install.packages("reshape2"); require("reshape2")}
if (!require("Hmisc")) {install.packages("Hmisc"); require("Hmisc")}
if (!require("gplots")) {install.packages("gplots"); require("gplots")}
if (!require("SensoMineR")) {install.packages("SensoMineR"); require("SensoMineR")}
if (!require("smacof")) {install.packages("smacof"); require("smacof")}
if (!require("ez")) {install.packages("ez"); require("ez")}
if (!require("ggplot2")) {install.packages("ggplot2"); require("ggplot2")}
if (!require("RColorBrewer")) {install.packages("RColorBrewer"); require("RColorBrewer")}
if (!require("Rcmdr")) {install.packages("Rcmdr"); require("Rcmdr")}

if (!require("cluster")) {install.packages("cluster"); require("cluster")}
if (!require("fpc")) {install.packages("fpc"); require("fpc")}
if (!require("pvclust")) {install.packages("pvclust"); require("pvclust")}
if (!require("mclust")) {install.packages("mclust"); require("mclust")}


library(RColorBrewer)
#library(rgl)
library(Rcmdr)
library('scatterplot3d')
#library('smacof')
library('pracma')
#library("xlsx")
library("ez")
library("psych")
library("plotrix")
library("reshape")
library("reshape2")
library("Hmisc")
library('gplots')
library('SensoMineR')
library('ggplot2')

## GET THE DATA --------------------------------

setwd("~/Dropbox (MIT)//Saxelab/Projects/sight_verbs/SVS_Analysis/Data")
#works if file has empty cells for missing data
#data <- read.xlsx('all_data.xlsx', sheetName = 'data_amod')  #this is very slow
data <- read.csv('all_data.csv',header=TRUE,sep=",")


colors <- brewer.pal(4, "Set1")
display.brewer.pal(4, "Set1")
pal <- colorRampPalette(colors)
display.brewer.all(n=NULL, type="all", select=NULL, exact.n=TRUE)



## ORGANIZE THE DATA --------------------------------

#make a combined verb column
data$Vboth <- paste(data$V1,data$V2,sep='_')

#make a subset-condition column, each row ordered alphabetically 
data$SubCategory <-  sapply(1: length(data$C1),function(x) do.call("paste", as.list(c(sort(c(as.character(data$C1[x]), as.character(data$C2[x]))),sep="_"))))
data$SubCategory <- as.factor(data$SubCategory)                           

#make a subset-condition column, each row ordered alphabetically -- with amodal distinctions
data$SubCategory2 <-  sapply(1: length(data$C1),function(x) do.call("paste", as.list(c(sort(c(as.character(data$S1[x]), as.character(data$S2[x]))),sep="_"))))
data$SubCategory2 <- as.factor(data$SubCategory2)                           

#put the data into long format 
melt.data.frame(data=data,variable_name='subject') -> datamelt
as.character(datamelt$subject) -> datamelt$subject

#add a group variable (based on subject ID)
datamelt$Group <- sub('_..','',datamelt$subject)
datamelt$Group <- as.factor(datamelt$Group)   
as.factor(datamelt$subject) -> datamelt$subject
datamelt <- datamelt[order(datamelt$Vboth),]

## MAKE A SUBJECT LEVEL DATA FRAME  --------------------------------

#get means and std per subject/condition (collapsing across verb pairs)
#with mix vs cog distinction
subjdata <- aggregate(datamelt$value,list(datamelt$subject, datamelt$Group, datamelt$SubCategory2), FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE)))
subjdata$x[,1] -> subjdata$mean
subjdata$x[,2] -> subjdata$sd
subjdata$x <- NULL
names(subjdata) <- c("subject", "Group", "SubCategory2", "mean", "sd")  

#get means and std per subject/condition (collapsing across verb pairs)
subjdata <- aggregate(datamelt$value,list(datamelt$subject, datamelt$Group, datamelt$SubCategory), FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE)))
subjdata$x[,1] -> subjdata$mean
subjdata$x[,2] -> subjdata$sd
subjdata$x <- NULL
names(subjdata) <- c("subject", "Group", "SubCategory", "mean", "sd")

#ANOVA for selected groups and conditions  ## ANALYSIS 1

#UPDATE 'groups' and 'conditions'! 
groups = c("B","S") 
groups = c("B","L") 
groups = c("S","L") 

conditions = c("SightEmission_SightEmission","SoundEmission_SoundEmission", "SightEmission_SoundEmission") 
conditions = c("SightEmission_SightEmission","SoundEmission_SoundEmission", "SoundAgent_SoundAgent", "SightEmission_SoundEmission","SightEmission_SoundAgent","SoundAgent_SoundEmission") 
conditions = c("SoundEmission_SoundEmission", "SoundAgent_SoundAgent","SoundAgent_SoundEmission") 

conditions = c("SightEmission_SightEmission", "SoundAgent_SoundAgent", "SightEmission_SoundAgent")
conditions = c("SoundEmission_SoundEmission", "SoundAgent_SoundAgent", "SoundAgent_SoundEmission")

conditions = c("SightPerception_SightPerception","TouchPerception_TouchPerception", "SightPerception_TouchPerception" ) 
conditions = c("Amodal_Amodal","Amodal_SightPerception", "SightPerception_SightPerception") 
conditions = c("Amodal_Amodal","Amodal_TouchPerception", "TouchPerception_TouchPerception") 

conditions = c("Amodal_SightPerception","Amodal_TouchPerception") 

#conditions = c("SightPerception_SightPerception","Mix_Mix", "Mix_SightPerception") 
#conditions = c("SightPerception_SightPerception","Cog_Cog", "Cog_SightPerception") 

conditions = c("SightEmission_SightEmission","SoundAgent_SoundAgent") 


# get the selected data 
subsetdata <- subjdata[subjdata$SubCategory %in% conditions,]
subsetdata <- subsetdata[subsetdata$Group %in% groups,]
subsetdata <-na.omit(subsetdata)

#anova
ez <- ezANOVA(data=subsetdata,dv=.(mean),wid=.(subject),within=.(SubCategory), between=(Group))
for (x in 1:dim(ez$ANOVA)[1] ) {
  if(x==1){cat(conditions, "\n", sep=", ")}
  cat(ez$ANOVA[x,1],": F(",ez$ANOVA[x,2], "," , ez$ANOVA[x,3], ")=", round(ez$ANOVA[x,4],2), ", p=",round(ez$ANOVA[x,5],2), ", ƞ2=",round(ez$ANOVA[x,7],2), "\n",  sep="")  
}


## MAKE A GROUP LEVEL DATA FRAME --------------------------------

#get the data per group/condition (collasping across verb pairs, retaining subject-wise error)
groupdata <- aggregate(subjdata$mean,list(subjdata$Group, subjdata$SubCategory), FUN= function(x) c(m=mean(x, na.rm=TRUE), s=std.error(x, na.rm=TRUE)))
groupdata$x[,1] -> groupdata$mean
groupdata$x[,2] -> groupdata$se
groupdata$x <- NULL
names(groupdata) <- c("Group", "SubCategory", "mean", "se")

#write summary statistcs for each group
groupdata$mean -> temp
for (x in 1:dim(groupdata)[1] ) {
  temp[x] <- paste(round(groupdata$mean[x],2), "±", round(groupdata$se[x],2),  sep="")  
}
groupdata$summary <- temp 

## plot group averages of selected group and condition ####

## UPDATE groups and conditions as needed 
groups = c("B","L", "S") 
groups = c("B","S") 

conditions = c("Amodal_Amodal","TouchPerception_TouchPerception","Amodal_TouchPerception") 

#figures 1A,B,C
conditions = c("SightPerception_SightPerception","Amodal_Amodal","Amodal_SightPerception" ) 
conditions = c("SightPerception_SightPerception","TouchPerception_TouchPerception", "SightPerception_TouchPerception" ) 
conditions = c("Amodal_SightPerception","Amodal_TouchPerception") 

#combined figure
conditions = c("SightPerception_SightPerception","TouchPerception_TouchPerception","Amodal_Amodal", "Amodal_SightPerception","Amodal_TouchPerception","SightPerception_TouchPerception") 

#conditions = c("SightPerception_SightPerception","Mix_Mix", "Mix_SightPerception") 
#conditions = c("SightPerception_SightPerception","Cog_Cog", "Cog_SightPerception") 

#figure 2A
conditions = c("SightEmission_SightEmission","SoundEmission_SoundEmission", "SightEmission_SoundEmission") 

conditions = c("SightEmission_SightEmission","SoundEmission_SoundEmission", "SoundAgent_SoundAgent", "SightEmission_SoundEmission","SightEmission_SoundAgent","SoundAgent_SoundEmission") 
conditions = c("SoundEmission_SoundEmission", "SoundAgent_SoundAgent","SoundAgent_SoundEmission") 

#-- plot it !

plotdata = groupdata[groupdata$Group %in% groups, ]
#get data from conditions of interest 
meansD = plotdata[plotdata$SubCategory %in% conditions,]$mean
sesD = plotdata[plotdata$SubCategory %in% conditions,]$se
namesD = plotdata[plotdata$SubCategory %in% conditions,]$SubCategory

meansD <- meansD[order(match(namesD,conditions))]
sesD <- sesD[order(match(namesD,conditions))]
namesD <- namesD[order(match(namesD,conditions))]

namesD = sub(pattern="_",":",namesD)
namesD = sub(pattern="Emission","",namesD);namesD = sub(pattern="Emission","",namesD)
namesD = sub(pattern="Perception","",namesD); namesD = sub(pattern="Perception","",namesD)

mp<-barplot2(meansD, beside = TRUE,horiz=FALSE,
             col = c("red4","red1","royalblue4","royalblue1","grey30","grey60","red4","red1","royalblue4","royalblue1","purple4","purple1"),
             axes = TRUE,
             space = rep(c(1,0),length(conditions)),
             density  = c(-1,-1,-1,-1,-1, -1, 10, 10, 10,10,10,10),
             # names.arg = namesD,
             cex.names = 1.1, 
             ylim = c(0,7),
             #ylab = "PSC",
             cex.lab = 1.2,
             cex.axis = 1,
             las = 1,
             #legend = groups,
             #main = "Pixar in RTPJ", font.main = 2,
             border = "black",
             plot.ci = TRUE, ci.lwd =2, ci.width = .3, ci.l = meansD-sesD/2, ci.u = meansD+sesD/2,
             # grid.inc = 4,
             plot.grid = TRUE)
#axis(1,labels=namesD,at=mp,las=3,cex.axis=1)
abline(v = 9.5,col="black",lty=2,lwd =3)


#for all three groups 
mp<-barplot2(meansD, beside = TRUE,horiz=FALSE,
             col = c("red4","red3", "red1","royalblue4", "royalblue3","royalblue1","seagreen4","seagreen3","seagreen1","grey30","grey50","grey60","grey30","grey50","grey60","grey30","grey50","grey60"),
             axes = TRUE,
             space = rep(c(1,0 ,0),length(conditions)),
             # density  = c(-1,-1,-1,-1,-1, 50, 50,50,50,50),
             # names.arg = namesD,
             cex.names = 1.1, 
             ylim = c(0,7),
             #ylab = "PSC",
             cex.lab = 1.2,
             cex.axis = 1,
             las = 1,
             #legend = groups,
             #main = "Pixar in RTPJ", font.main = 2,
             border = "black",
             plot.ci = TRUE, ci.lwd =2, ci.width = .3, ci.l = meansD-sesD/2, ci.u = meansD+sesD/2,
             # grid.inc = 4,
             plot.grid = TRUE)
axis(1,labels=namesD,at=mp,las=3,cex.axis=1)



#### SINGLE WORDS ##### 

word = "to_feel"
word_amodal1 = datamelt[datamelt$V1==word & datamelt$C2=="Amodal",]
word_amodal2 = datamelt[datamelt$V2==word & datamelt$C1=="Amodal",]
word_amodal = rbind(word_amodal1,word_amodal2)
word_amodal$Cond <- "Amodal"

word_touch1 = datamelt[datamelt$V1==word & datamelt$C2=="TouchPerception",]
word_touch2 = datamelt[datamelt$V2==word & datamelt$C1=="TouchPerception",]
word_touch = rbind(word_touch1,word_touch2)
word_touch$Cond <- "Touch"

word_sight1 = datamelt[datamelt$V1==word & datamelt$C2=="SightPerception",]
word_sight2 = datamelt[datamelt$V2==word & datamelt$C1=="SightPerception",]
word_sight = rbind(word_sight1,word_sight2)
word_sight$Cond <- "Sight"

word_contrast <- rbind(word_sight, word_amodal,word_touch)

#get means and std per subject/condition (collapsing across verb pairs)
worddata <- aggregate(word_contrast$value,list(word_contrast$subject, word_contrast$Group, word_contrast$Cond), FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE)))
worddata$x[,1] -> worddata$mean
worddata$x[,2] -> worddata$sd
worddata$x <- NULL
names(worddata) <- c("subject", "Group", "SubCategory", "mean", "sd")

groupworddata <- aggregate(worddata$mean,list(worddata$Group, worddata$SubCategory), FUN= function(x) c(m=mean(x, na.rm=TRUE), s=std.error(x, na.rm=TRUE)))
groupworddata$x[,1] -> groupworddata$mean
groupworddata$x[,2] -> groupworddata$se
groupworddata$x <- NULL
names(groupworddata) <- c("Group", "SubCategory", "mean", "se")

#write summary statistcs for each group
groupworddata$mean -> temp
for (x in 1:dim(groupworddata)[1] ) {
  temp[x] <- paste(round(groupworddata$mean[x],2), "±", round(groupworddata$se[x],2),  sep="")  
}
groupworddata$summary <- temp 


plotdata = groupworddata[groupworddata$Group %in% groups, ]
#get data from conditions of interest 
meansD = plotdata$mean
sesD = plotdata$se
namesD = plotdata$SubCategory

#meansD <- meansD[order(match(namesD,conditions))]
#sesD <- sesD[order(match(namesD,conditions))]
#namesD <- namesD[order(match(namesD,conditions))]

#namesD = sub(pattern="_",":",namesD)
#namesD = sub(pattern="Emission","",namesD);namesD = sub(pattern="Emission","",namesD)
#namesD = sub(pattern="Perception","",namesD); namesD = sub(pattern="Perception","",namesD)

mp<-barplot2(meansD, beside = TRUE,horiz=FALSE,
            
             col = c("seagreen4","seagreen1","red4","red1","royalblue4","royalblue1"),
             axes = TRUE,
             space = rep(c(1,0),length(meansD)/2),
             # density  = c(-1,-1,-1,-1,-1, 50, 50,50,50,50),
             # names.arg = namesD,
             cex.names = 1.1, 
             ylim = c(0,7),
             #ylab = "PSC",
             cex.lab = 1.2,
             cex.axis = 1,
             las = 1,
             #legend = groups,
             main = sub(pattern = "_",replacement = " ",x = word), font.main = 2,
             border = "black",
             plot.ci = TRUE, ci.lwd =2, ci.width = .3, ci.l = meansD-sesD/2, ci.u = meansD+sesD/2,
             # grid.inc = 4,
             plot.grid = TRUE)
axis(1,labels=namesD,at=mp,las=3,cex.axis=1)


t.test(worddata[worddata$SubCategory=="Sight" & worddata$Group == "B",]$mean, worddata[worddata$SubCategory=="Sight" & worddata$Group == "S",]$mean)
t.test(worddata[worddata$SubCategory=="Amodal" & worddata$Group == "B",]$mean, worddata[worddata$SubCategory=="Amodal" & worddata$Group == "S",]$mean)
t.test(worddata[worddata$SubCategory=="Touch" & worddata$Group == "B",]$mean, worddata[worddata$SubCategory=="Touch" & worddata$Group == "S",]$mean)

t.test(worddata[worddata$SubCategory=="Sight" & worddata$Group == "S",]$mean, worddata[worddata$SubCategory=="Sight" & worddata$Group == "L",]$mean)

#anova
worddata_subset <- worddata[ worddata$Group %in% groups &  (worddata$SubCategory == "Amodal" | worddata$SubCategory == "Touch" | worddata$SubCategory == "Sight") & !is.na(worddata$sd),]
worddata_subset <- worddata[ worddata$Group %in% groups &  (worddata$SubCategory == "Amodal" | worddata$SubCategory == "Touch") & !is.na(worddata$sd),]
worddata_subset <- worddata[ worddata$Group %in% groups &  (worddata$SubCategory == "Touch" | worddata$SubCategory == "Sight") & !is.na(worddata$sd),]

ez <- ezANOVA(data=worddata_subset,dv=.(mean),wid=.(subject),within=.(SubCategory), between=(Group))
for (x in 1:dim(ez$ANOVA)[1] ) {
  if(x==1){cat(word, "\n", sep=", ")}
  cat(ez$ANOVA[x,1],": F(",ez$ANOVA[x,2], "," , ez$ANOVA[x,3], ")=", round(ez$ANOVA[x,4],2), ", p=",round(ez$ANOVA[x,5],2), ", ƞ2=",round(ez$ANOVA[x,7],2), "\n",  sep="")  
}



## MAKE A VERB LEVEL DATA FRAME --------------------------------

#get means and stdev per verb-pair (collapses across participants, split by group)
verbdata <- aggregate(c(datamelt$value), list(datamelt$Vboth, datamelt$Group, datamelt$Category, datamelt$SubCategory2, datamelt$S1, datamelt$S2, datamelt$V1,datamelt$V2 ), FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE),se=std.error(x,na.rm=TRUE)))
verbdata$x[,1] -> verbdata$mean
verbdata$x[,2] -> verbdata$sd
verbdata$x[,3] -> verbdata$se
verbdata$x <- NULL
names(verbdata) <- c("Vboth", "Group", "Category", "SubCategory2", "S1","S2", "V1", "V2", "mean", "sd","se")
verbdata <- verbdata[order(verbdata$Vboth),]

#get means and stdev per verb-pair (collapses across participants, split by group)
verbdata <- aggregate(c(datamelt$value), list(datamelt$Vboth, datamelt$Group, datamelt$Category, datamelt$SubCategory, datamelt$C1, datamelt$C2, datamelt$V1,datamelt$V2 ), FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE),se=std.error(x,na.rm=TRUE)))
verbdata$x[,1] -> verbdata$mean
verbdata$x[,2] -> verbdata$sd
verbdata$x[,3] -> verbdata$se
verbdata$x <- NULL
names(verbdata) <- c("Vboth", "Group", "Category", "SubCategory", "C1","C2", "V1", "V2", "mean", "sd","se")
verbdata <- verbdata[order(verbdata$Vboth),]




# Correlations with Sighted Reference ------------------------------------

rcorr(verbdata[ verbdata$Group =="REF",]$mean, verbdata[ verbdata$Group =="B",]$mean)
rcorr(verbdata[ verbdata$Group =="REF",]$mean, verbdata[ verbdata$Group =="S",]$mean)
rcorr(verbdata[ verbdata$Group =="REF",]$mean, verbdata[ verbdata$Group =="L",]$mean)

plot(verbdata[ verbdata$Group =="REF",]$mean, verbdata[ verbdata$Group =="B",]$mean)
plot(verbdata[ verbdata$Group =="REF",]$mean, verbdata[ verbdata$Group =="S",]$mean)
plot(verbdata[ verbdata$Group =="REF",]$mean, verbdata[ verbdata$Group =="L",]$mean)


conditions = c("SightEmission")
conditions = c("SightPerception")
cS = "red"
cB = "black"

conditions = c("SoundEmission")  #,"SoundAgent")
conditions = c("SoundAgent") 
conditions = c("TouchPerception")
cS = "royalblue1"
cB = "royalblue4"

conditions = c("Amodal")
conditions = c("Cog")
conditions = c("Mix")
conditions = c("Motion")
cS = "seagreen1"  
cB = "seagreen4"

conditions = c("SightPerception","TouchPerception", "Amodal") 
conditions = c("SightEmission","SoundEmission") 
conditions = c("Amodal", "Motion", "SightEmission", "SightPerception", "SoundAgent", "SoundEmission", "TouchPerception")
conditions = c("SightPerception")

verbdata_wide <- reshape(verbdata,v.name = c("mean","sd","se"), idvar = "Vboth", timevar = "Group", direction="wide") 
verbdata_wide$mean.B-verbdata_wide$mean.S -> verbdata_wide$diff
sub("_to_", ", ", sub(pattern = "to_","",verbdata_wide$Vboth)) -> verbdata_wide$verbnames

rdataBR<-rcorr(subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)$mean.B,subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)$mean.REF)
rdataSR<-rcorr(subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)$mean.S,subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)$mean.REF)
rdataSB<-rcorr(subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)$mean.S,subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)$mean.B)

#rdataBR<-rcorr(subset(verbdata_wide,S1 %in% conditions & S2 %in% conditions)$mean.B,subset(verbdata_wide,S1 %in% conditions & S2 %in% conditions)$mean.REF)
#rdataSR<-rcorr(subset(verbdata_wide,S1 %in% conditions & S2 %in% conditions)$mean.S,subset(verbdata_wide,S1 %in% conditions & S2 %in% conditions)$mean.REF)
#rdataSB<-rcorr(subset(verbdata_wide,S1 %in% conditions & S2 %in% conditions)$mean.S,subset(verbdata_wide,S1 %in% conditions & S2 %in% conditions)$mean.B)


rtest <- r.test(n=rdataBR$n[1,2],n2=rdataSR$n[1,2],r12=rdataBR$r[1,2],r13=rdataSR$r[1,2],r23=rdataSB$r[1,2]) 

paste(conditions, ": blind to reference: r(", rdataBR$n[1,2]-2,")=", round(rdataBR$r[1,2],2), ", p<", round(rdataBR$P[1,2],2),  "; sighted to reference: r(", rdataSR$n[1,2]-2,")=", round(rdataSR$r[1,2],2), ", p<", round(rdataSR$P[1,2],2),  "; t(", rdataSR$n[1,1]-2, ")=", round(rtest$t,2), ", p=", round(rtest$p,3), sep="")

#correlation plot with error bars
ggplot(subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)) +
  xlab("Reference Group Ratings") + ylab("Target Group Ratings") + ggtitle(paste(conditions, collapse =", ")) + 
  geom_point(aes(x = mean.REF,y = mean.S, color="Sighted"),size = 3, alpha = .5) + stat_smooth(aes(x=mean.REF,y=mean.S,color=cS),method = "glm",color=cS,fill=cS)  + 
  geom_point(aes(x = mean.REF,y = mean.B, color="Blind"), size = 3, alpha = .5) + stat_smooth(aes(x=mean.REF,y=mean.B),method = "glm",color=cB,fill=cB) +
  #geom_text(data = subset(verbdata_wide, C1 %in% conditions & C2 %in% conditions & (V1=="to_see" | V2=="to_see")), aes(x = mean.REF,y = mean.S,label=Vboth), vjust=0) + 
  geom_errorbar(aes(x=mean.REF, ymin=mean.S-se.S, ymax=mean.S+se.S), color=cS, width=.05,alpha=.5) + 
  geom_errorbar(aes(x=mean.REF, ymin=mean.B-se.B, ymax=mean.B+se.B), color=cB, width=.05,alpha=.5) +
  #geom_text(aes(x = mean.REF,y = mean.S, label=verbnames), size=3) + 
  #geom_text(aes(x = mean.REF,y = mean.B, label=verbnames), size=3) + 
  geom_text(data = subset(verbdata_wide, C1 %in% conditions & C2 %in% conditions & (V1=="to_see" | V2=="to_see")), aes(x = mean.REF,y = mean.S, label=verbnames), color="red", vjust=0) +  
  #geom_point(data = subset(verbdata_wide, C1 %in% conditions & C2 %in% conditions & (V1=="to_see" | V2=="to_see")), aes(x = mean.REF,y = mean.S),color="red", size = 2, alpha =1) +
  geom_text(data = subset(verbdata_wide, C1 %in% conditions & C2 %in% conditions & (V1=="to_see" | V2=="to_see")), aes(x = mean.REF,y = mean.B, label=verbnames), vjust=0, color="black") +  
  #geom_point(data = subset(verbdata_wide, C1 %in% conditions & C2 %in% conditions & (V1=="to_see" | V2=="to_see")), aes(x = mean.REF,y = mean.B),color="black", size = 2, alpha =1) +
  theme_bw() + 
  scale_fill_manual(values = c(cB,cS))+ 
  scale_color_manual(values = c(cB,cS)) + 
  theme(legend.justification=c(1,0), legend.position=c(1,0), legend.title=element_blank()) # Position legend in bottom right


cS = "red"
ggplot(subset(verbdata_wide,C1 %in% conditions & C2 %in% conditions)) + theme_bw() + 
  xlab("Blind") + ylab("Sighted") + ggtitle(paste(conditions, collapse =", ")) + 
  geom_point(aes(x = mean.B,y = mean.S),color=cS,size = 3, alpha = .5) + stat_smooth(aes(x=mean.REF,y=mean.S,color=cS),method = "glm",color=cS,fill=cS)  + 
  geom_errorbar(aes(x=mean.B, ymin=mean.S-se.S, ymax=mean.S+se.S), color=cS, width=.05,alpha=.5) +
  geom_text(aes(x = mean.B,y = mean.S, label=verbnames), size=3)

ggplot(verbdata_wide, aes(diff, diff)) + geom_point() + 
  geom_text(data = subset(verbdata_wide, abs(diff) > 0.4), aes(label=Vboth), vjust=0)

ggplot(verbdata_wide, aes(diff, diff)) + geom_point() + 
  geom_text(data = subset(verbdata_wide, V1=="to_see"), aes(label=Vboth), vjust=0)

ggplot(verbdata_wide, aes(diff, diff)) + geom_point() + 
  geom_text(data = subset(verbdata_wide, V1=="to_touch" | V2=="to_touch"), aes(label=Vboth), vjust=0)



#fun plots 
ggplot(verbdata, aes(x=mean, y=Group,color=Group, subset = (SubCategory %in% c("Amodal_Amodal")))) + geom_point(size = 3)
ggplot(verbdata, aes(x=mean,color=Group, subset = (SubCategory %in% c("Amodal_Amodal")))) + geom_density()
ggplot(verbdata[verbdata$SubCategory=="Amodal_Amodal",], aes(x=mean,color=Group)) + geom_density()
ggplot(verbdata, aes(x=mean,color=Group)) + geom_density()

ggplot(verbdata, aes(x=mean,color=Group)) + geom_histogram() + facet_grid(Group ~ .)
ggplot(verbdata, aes(y=mean,x=SubCategory, fill=Group,alpha=.1)) + geom_dotplot(binaxis="y", stackdir="center", binwidth=0.15) + labs(title="Dot plots") + facet_grid(Group ~ .)



# individual correlation with reference group ----- 
indzs = NA

as.data.frame(matrix(unlist(unique(subjdata$subject)), ncol = 1, byrow = TRUE)) -> subjs
colnames(subjs) <- "subject"
subjdata[subjs$subject,]$Group -> subjs$Group


conditions = c("SoundEmission")  #,"SoundAgent")
conditions = c("SoundAgent") 
conditions = c("Amodal")

allconditions = c("SightEmission","SoundEmission", "SoundAgent",  "SightPerception", "TouchPerception", "Amodal", "Motion")
allconditions = c("SightEmission","SightPerception")
for(c in allconditions){
  conditions = c
  for(s in 1:length(subjs$subject)){v <-rcorr(datamelt[datamelt$subject == subjs$subject[s]  & datamelt$C1 %in% conditions & datamelt$C2 %in% conditions,,]$value, verbdata[verbdata$Group == "REF" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean)
                                    subjs$r_ref[s] <- v$r[2]
                                    subjs$p_ref[s] <- v$P[2]
  }
  
  subjs -> ind_ref_corr
  fisherz(ind_ref_corr$r_ref) -> ind_ref_corr$z_ref
  
  ttestd<-t.test(ind_ref_corr$z_ref[ ind_ref_corr$Group=="S"],ind_ref_corr$z_ref[ ind_ref_corr$Group=="B"]) 
  
  ind_ref_corr_summary <- aggregate(ind_ref_corr$z_ref,list(ind_ref_corr$Group),FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE), se=std.error(x)))
  fisherz2r(ind_ref_corr_summary$x) -> ind_ref_corr_summary_r
  cbind(conditions,levels(ind_ref_corr$Group),round(as.data.frame(ind_ref_corr_summary_r),2)) -> temp
  cbind(conditions,levels(ind_ref_corr$Group),round(as.data.frame(ind_ref_corr_summary$x),2)) -> temp2
  indzs <- rbind(indzs,temp2)
  cat(paste(conditions), paste(temp[,1],": ", temp[,2], "±", temp[,3], "; ", sep=""), paste("t(", round(ttestd$parameter,2), ")=", round(ttestd$statistic,2), ", p=",round(ttestd$p.value,2),sep=""),"\n" )
}
names(indzs)[2] <- "Group"

ttestd<-t.test(touchtemp$z_ref[ touchtemp$Group=="B"],sighttemp$z_ref[ sighttemp$Group=="B"]) 
touch_summary <- aggregate(touchtemp$z_ref,list(touchtemp$Group),FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE), se=std.error(x)))
sight_summary <- aggregate(sighttemp$z_ref,list(sighttemp$Group),FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE), se=std.error(x)))



#correlation with leave one out from own group
allconditions = c("SightEmission","SoundEmission", "SoundAgent",  "SightPerception", "TouchPerception", "Amodal", "Motion")
allconditions = c("SightEmission","SightPerception")


for(c in allconditions){
  conditions = c
  for(s in 1:length(subjs$subject)){
    if(subjs$subject[s] != "REF_01"){
      gdata = datamelt[datamelt$subject != subjs$subject[s] & datamelt$Group == subjs$Group[s],]
      
      group_one_out <- aggregate(c(gdata$value), list(gdata$Vboth, gdata$Group, gdata$Category, gdata$SubCategory, gdata$C1, gdata$C2, gdata$V1,gdata$V2 ), FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE)))
      group_one_out$x[,1] -> group_one_out$mean
      group_one_out$x[,2] -> group_one_out$sd
      group_one_out$x <- NULL
      names(group_one_out) <- c("Vboth", "Group", "Category", "SubCategory", "C1","C2", "V1", "V2", "mean", "sd")
      group_one_out <- group_one_out[order(group_one_out$Vboth),]
      
      v <-rcorr(datamelt[datamelt$subject == subjs$subject[s]  & datamelt$C1 %in% conditions & datamelt$C2 %in% conditions,,]$value, group_one_out[group_one_out$C1 %in% conditions & group_one_out$C2 %in% conditions,]$mean)
      subjs$r_loo[s] <- v$r[2]
      subjs$p_loo[s] <- v$P[2]
    }}
  
  subjs -> ind_group_corr
  fisherz(ind_group_corr$r_loo) -> ind_group_corr$z_loo
  
  ttestd<-t.test(ind_group_corr$z_loo[ ind_group_corr$Group=="S"],ind_group_corr$z_loo[ ind_group_corr$Group=="B"]) 
  
  ind_group_corr_summary <- aggregate(ind_group_corr$z_loo,list(ind_group_corr$Group),FUN= function(x) c(m=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE), se=std.error(x)))
  fisherz2r(ind_group_corr_summary$x) -> ind_group_corr_summary_r
  cbind(levels(ind_group_corr$Group),round(as.data.frame(ind_group_corr_summary_r),2)) -> temp
  
  cat(paste(conditions), paste(temp[,1],": ", temp[,2], "±", temp[,3], "; ", sep=""), paste("t(", round(ttestd$parameter,2), ")=", round(ttestd$statistic,2), ", p=",round(ttestd$p.value,2),sep=""),"\n" )
}

# skip  ------- 
# rcorr(verbdata[verbdata$Group == "B" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean,verbdata[verbdata$Group == "REF" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean)
# rcorr(verbdata[verbdata$Group == "S" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean,verbdata[verbdata$Group == "REF" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean)
# rcorr(verbdata[verbdata$Group == "L" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean,verbdata[verbdata$Group == "REF" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean)
# 
# plot(verbdata[verbdata$Group == "B" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean,verbdata[verbdata$Group == "REF" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean)
# plot(verbdata[verbdata$Group == "S" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean,verbdata[verbdata$Group == "REF" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean)
# plot(verbdata[verbdata$Group == "L" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean,verbdata[verbdata$Group == "REF" & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,]$mean)


## SINGLE SUBJECT DISTANCE MATRICES -----------------------

allconditions = list(c("SightPerception","TouchPerception", "Amodal"), c("SightEmission","SoundEmission"), c("SightEmission"), c("SightPerception"),c("SoundEmission","SoundAgent"),c("SightEmission", "SoundEmission","SoundAgent"))

# single participant distance matrices 
#conditions = c("SightPerception","TouchPerception", "Amodal") 
#conditions = c("SightEmission","SoundEmission") 
#conditions = c("SightEmission")
#conditions = c("SightPerception")
#conditions2 = c("SoundEmission","SoundAgent")

for(c in 1:length(allconditions)){
  conditions = allconditions[[c]] 
  #initialize if we don't already have it 
  if(!exists("subj.dis.square")){subj.dis.square <- list()}
  
  for(subj in levels(datamelt$subject)){#make similiarity matrix 
    ssdata <- (datamelt[ datamelt$subject == subj & datamelt$C1 %in% conditions & datamelt$C2 %in% conditions,])
    ssdata[ order(ssdata$V1,ssdata$V2),] -> ssdata 
    squareform(ssdata$value) -> squaredata.sim
    diag(squaredata.sim) <- 7
    
    #get the list of verbs and their categories
    ssdata[!duplicated(ssdata$V1),c(1,6)] -> t1
    ssdata[!ssdata$V2 %in% ssdata$V1,][1,c(2,7)] -> t2
    names(t2) <- names(t1)
    vnames <- rbind( t1,t2)
    as.factor(vnames$V1) -> vnames$V1
    sub('to_','',vnames$V1) -> vnames$V1
    #sub('to_','',unique(c(as.character(ssdata$V1),as.character(ssdata$V2)))) -> vnames$verbs
    
    #name similarity matrix
    vnames$V1 -> rownames(squaredata.sim)
    vnames$V1 -> colnames(squaredata.sim)
    
    #make dissimarity matrix 
    7 - squaredata.sim -> squaredata.dis
    
    subj.dis.square[[paste(conditions,sep="",collapse="_")]][[subj]] <- squaredata.dis
  }
  subj.dis.square[[paste(conditions,sep="",collapse="_")]]$verbs <- vnames
}


## GROUP LEVEL DISTANCE MATRICES -----------------------


groups = c("B","S","REF","L")

for(c in 1:length(allconditions)){
  conditions = allconditions[[c]] 
  #initialize if we don't already have it 
  if(!exists("dis.square")){dis.square <- list()}
  if(!exists("var.square")){var.square <- list()}
  
  for (group in groups){ #make similiarity matrix 
    ssdata <- (verbdata[verbdata$Group %in% group & verbdata$C1 %in% conditions & verbdata$C2 %in% conditions,])
    ssdata[ order(ssdata$V1,ssdata$V2),] -> ssdata 
    squareform(ssdata$mean) -> squaredata.sim
    squareform(ssdata$sd) -> squaredata.var
    diag(squaredata.sim) <- 7
    diag(squaredata.var) <- 0
    
    #get the list of verbs and their categories
    ssdata[!duplicated(ssdata$V1),c(5,7)] -> t1
    ssdata[!ssdata$V2 %in% ssdata$V1,][1,c(6,8)] -> t2
    names(t2) <- names(t1)
    vnames <- rbind( t1,t2)
    as.factor(vnames$V1) -> vnames$V1
    sub('to_','',vnames$V1) -> vnames$V1
    #sub('to_','',unique(c(as.character(ssdata$V1),as.character(ssdata$V2)))) -> vnames$verbs
    
    #name similarity matrix
    vnames$V1 -> rownames(squaredata.sim)
    vnames$V1 -> colnames(squaredata.sim)
    vnames$V1 -> rownames(squaredata.var)
    vnames$V1 -> colnames(squaredata.var)
    
    #make dissimarity matrix 
    7 - squaredata.sim -> squaredata.dis
    
    dis.square[[paste(conditions,sep="",collapse="_")]][[group]] <- squaredata.dis
    var.square[[paste(conditions,sep="",collapse="_")]][[group]] <- squaredata.var
  }
  
  dis.square[[paste(conditions,sep="",collapse="_")]]$verbs <- vnames 
  var.square[[paste(conditions,sep="",collapse="_")]]$verbs <- vnames 
}



## DENDROGRAMS -------------------------


#pick your group and conditions 
group = c("B")
group = c("S")

conditions = c("SightPerception","TouchPerception", "Amodal") 
conditions = c("SightEmission","SoundEmission") 
conditions = c("SightEmission","SoundEmission") 
conditions = c("SightEmission")
conditions = c("SightPerception")
conditions = c("SoundEmission","SoundAgent")
conditions = c("SightEmission","SoundEmission","SoundAgent")

#conditions = "SightPerception_TouchPerception_Amodal"
#conditions = "SightEmission_SoundEmission"
#conditions = "SightEmission"
#conditions = "SightEmission_SoundEmission_SoundAgent"

paste(conditions, sep="_",collapse = "_") -> c 

#reload the verbs for the distance matrix 
vnames <- dis.square[[c]]$verbs

#get colors   
##add colors for the conditions  red=seeing, blue = non-seeing, black = amodal  
if (length(conditions) == 3){color = c("black","blue","red")}   # three way
if (length(conditions) == 2){color = c("blue","red")}   # three way
if (length(conditions) == 1){color = c("red")}   # three way
#color = c("red","blue","blue")   # two way
#label conditions as a color
for (l in 1:length(unique(vnames$C1))){
  for (i in 1:length(vnames$C1)){
    if(vnames$C1[i] == unique(vnames$C1)[l]){
      vnames$color[i]=color[l]}}}

vnames -> dis.square[[c]]$verbs

#indivudual subject (not in paper)
hclust(as.dist(subj.dis.square[[c]][[subj]]),method='ward') -> hc  #hc.blind #hc.sighted

#whole group  (Not in paper)
hclust(as.dist(dis.square[[c]][[group]]),method='ward') -> hc  #hc.blind #hc.sighted

### colored, with option to rotate labels, and height isn't all the way down  
col.vec = vnames$color  #make the colors 
label.vec = vnames$V1  #make the labels 

ht.vec<-rep(NA,nrow(vnames))
for(i in 1:nrow(vnames))
{
  loc<-which(hc$merge==-i)
  row.loc<-loc%%(nrow(vnames)-1)
  ht.vec[i]<-hc$height[row.loc] 
}
hang<- ht.vec
ht.vec2<-ht.vec-hang-.4
plclust(hc,labels=rep("                 ",nrow(vnames)),hang=-10, ann=FALSE)  ##turning off the labels
text(seq(1,nrow(vnames)),ht.vec2[hc$order],labels=label.vec[hc$order],col=col.vec[hc$order],srt=45,adj=c(1,1),cex=.95)

title(paste(group,conditions))
#cbind(hc.sighted$merge,  hc.blind$merge)


# Model Based Clustering -- not so good for distance matrices 
library(mclust)
fit <- Mclust(as.matrix(dis.square[[c]][[group]]),G = 1:15)
m.best <- dim(fit$z)[2]
#plot(fit) # plot results 
#summary(fit) # display the best model



# Ward Hierarchical Clustering with Bootstrapped p values
# Compute the eigenvalues
x <- cmdscale(dis.square[[c]][[group]],1,eig=T)

# Plot the eigenvalues and choose the correct number of dimensions (eigenvalues close to 0)
plot(x$eig, 
     type="h", lwd=5, las=1, 
     xlab="Number of dimensions", 
     ylab="Eigenvalues")

# Recover the coordinates that give the same distance matrix with the correct number of dimensions    
x <- cmdscale(dis.square[[c]][[group]],32)
fit <- pvclust(t(x), method.hclust='ward.D', method.dist="euclidean")
plot(fit,cex = .7, cex.pv = .5, col.pv = c("red",rgb(0, 0, 0, 0),rgb(0, 0, 0, 0)), print.num=F, print.pv =T ) # dendogram with p values

plot(fit,col=vnames$color, cex = .7, cex.pv = .5, col.pv = c("green",rgb(0, 0, 0, 0),rgb(0, 0, 0, 0)), print.num=F, print.pv=T) # dendogram with p values
# add rectangles around groups highly supported by the data

plot(fit, print.pv=TRUE, print.num=TRUE)
## S3 method for class 'pvclust'
text(fit, col=c(2,3,8), print.num=TRUE, float=0.01, cex=NULL, font=NULL)
pvrect(fit, alpha=.95,)



### colored, with option to rotate labels, and height isn't all the way down  
col.vec = vnames$color  #make the colors 
label.vec = vnames$V1  #make the labels 

ht.vec<-rep(NA,nrow(vnames))
for(i in 1:nrow(vnames))
{
  loc<-which(fit$hclust$merge==-i)
  row.loc<-loc%%(nrow(vnames)-1)
  ht.vec[i]<-fit$hclust$height[row.loc] 
}
hang<- ht.vec
ht.vec2<-ht.vec-hang-.4
plot(fit$hclust,labels=rep("                 ",nrow(vnames)),hang=-10, ann=FALSE)  ##turning off the labels
text(seq(1,nrow(vnames)),ht.vec2[fit$hclust$order],labels=label.vec[fit$hclust$order],col=col.vec[fit$hclust$order],srt=90,adj=c(1,.5),cex=.95)
title(paste(group,conditions))
pvrect(fit, alpha=.90,)
#text(fit, col=c("black",rgb(0, 0, 0, 0),rgb(0, 0, 0, 0)), print.num=F, print.pv=F, cex=.6, font=NULL)






#### Heat Maps ########################################################################################

#distance 
data.matrix(dis.square[[c]][[group]]) -> squaredata.disM
diag(squaredata.disM) <- NA
col = vnames$color[hc$order]
p <- heatmap.2(squaredata.disM[ hc$order, hc$order],trace = 'none', dendrogram='none',ColSideColors=col,Rowv=FALSE, Colv=FALSE, cexCol = 1.1, cexRow=1.1,col=colorRampPalette(c("darkred","red3","yellow"))(24))

#in order of category  
sort.int(as.character(vnames$C1),index.return = T) -> x 
data.matrix(dis.square[[c]][["B"]]) -> squaredata.disM
diag(squaredata.disM) <- NA
p <- heatmap.2(squaredata.disM[x$ix,x$ix],trace = 'none', dendrogram='none',ColSideColors=vnames$color[x$ix],Rowv=FALSE, Colv=FALSE, cexCol = 1.1, cexRow=1.1,col=colorRampPalette(c("darkred","red3","yellow"))(24))


#variance 
data.matrix(var.square[[c]][[group]]) -> squaredata.varM
diag(squaredata.varM) <- NA
col = vnames$color[hc$order]
pvar <- heatmap.2(squaredata.varM[ hc$order, hc$order],trace = 'none', dendrogram='none',ColSideColors=col,Rowv=FALSE, Colv=FALSE, cexCol = 1.1, cexRow=1.1,col=colorRampPalette(c("darkred","red3","yellow"))(24))


#### MDS ########################################################################################

#pick your group and conditions 
group = c("B")
group = c("S")
group = c("REF")

conditions = c("SightPerception","TouchPerception", "Amodal") 
conditions = c("SightEmission","SoundEmission") 
conditions = c("SightEmission","SoundEmission") 
conditions = c("SightEmission")
conditions = c("SightPerception")
conditions = c("SoundEmission","SoundAgent")
conditions = c("SightEmission","SoundEmission","SoundAgent")

#conditions = "SightPerception_TouchPerception_Amodal"
#conditions = "SightEmission_SoundEmission"
#conditions = "SightEmission"
#conditions = "SightEmission_SoundEmission_SoundAgent"

paste(conditions, sep="_",collapse = "_") -> c 

#reload the verbs for the distance matrix 
vnames <- dis.square[[c]]$verbs

#get colors   
##add colors for the conditions  red=seeing, blue = non-seeing, black = amodal  
if (length(conditions) == 3){color = c("black","blue","red")}   # three way
if (length(conditions) == 2){color = c("blue","red")}   # three way
if (length(conditions) == 1){color = c("red")}   # three way
#color = c("red","blue","blue")   # two way
#label conditions as a color
for (l in 1:length(unique(vnames$C1))){
  for (i in 1:length(vnames$C1)){
    if(vnames$C1[i] == unique(vnames$C1)[l]){
      vnames$color[i]=color[l]}}}

vnames -> dis.square[[c]]$verbs

## check basic MDS 

MDS.space <- cmdscale(as.dist(dis.square[[c]][[group]]), k, eig=TRUE)

#graph
x <- MDS.space$points[,1]
y <- MDS.space$points[,2]
plot(x, y, type="n", xlab="", ylab="", main=paste(group,c))
text(x, y, rownames(MDS.space$points), cex=1, col=vnames$color)

#graph elbow GOF 
gof = NA
for(x in 1:k){gof[x] = sum(MDS.space$eig[x])/sum(abs(MDS.space$eig))}
plot(gof,type='o')
title(conditions, k)

sum(MDS.space$eig[1])/sum(MDS.space$eig[MDS.space$eig>0])  #GOF 2

##SMACOF version 
# uses majorization algorithm. The objective function to be minimized is known as stress and functions which majorize stress are elaborated.

group = "S"
group = "B"

MDSsma.space.metric  <- smacofSym(as.dist(dis.square[[c]][[group]]), 2,type="ratio")


#graph metric 
x2 <- -MDSsma.space.metric$conf[,1]
y2 <- -MDSsma.space.metric$conf[,2]
plot(x2, y2, type="n", xlab="", ylab="", main=paste("metric", group,conditions), asp=1)
text(x2, y2, rownames(MDSsma.space.metric$conf), cex=1, col=vnames$color)

#graph "scree" gof elbow metric 
result<-vector("list",k)
for (i in 1:k){
  result[[i]]<- smacofSym(as.dist(dis.square[[c]][[group]]), i, type="ratio")
}
stress<- sapply(result, function(x) x$stress)
plot(1:k,stress[1:k],type='o', main=paste("metric", group,conditions))

#check groups against each other (note save MDSsma.space.nonmetric by group name) 
rcorr(MDSsma.space.nonmetricR$conf[,d],MDSsma.space.nonmetricS$conf[,d])
rcorr(MDSsma.space.nonmetricB$conf[,d],MDSsma.space.nonmetricS$conf[,d])


#other plots
plot(MDSsma.space.metric,plot.type = "Shepard")
plot(MDSsma.space.metric, plot.type = "resplot")
points(MDSsma.space.metric$obsdiss, MDSsma.space.metric$confdiss, col="red")
plot(MDSsma.space.metric, plot.type = "bubbleplot")


## INDSCAL for all participants  ------------------------------------------------------

#get rid of the participants with missing data ### BETTER WAY IS TO SET THE WEIGHT MATRIX TO 0!!  

group = "S"
group = "B"

temp <- subj.dis.square[[c]][sapply(subj.dis.square[[c]],function(x) !any(is.na(x)))]
#temp <- subj.dis.square[[c]]

temp<-temp[grepl(group[1],names(temp))]
#temp<-temp[grepl("S",names(temp)) | grepl("B",names(temp))]

temp <- lapply(temp,function(x) as.dist(x))

#because otherwise it was droppping folks... 
temp2 <- temp[c(1:length(temp))]
# 
IDS.space.nonmetric <- smacofIndDiff(temp2,constraint="indscal",ndim=10) #,metric=FALSE)
IDS.space <- IDS.space.nonmetric


#graph
dim1<-1; dim2<-2; dim3<-3
x1 <- IDS.space$gspace[,dim1]; y1 <- IDS.space$gspace[,dim2]; z1 <- IDS.space$gspace[,dim3]

#2d

subjcol=rainbow(length(IDS.space$conf),v =1, alpha=1)

colfunc <- colorRampPalette(c("red", "white")); reds <- colfunc(20)
colfunc <- colorRampPalette(c("blue", "white")); blues <- colfunc(20)
colfunc <- colorRampPalette(c("black", "white")); blacks <- colfunc(35)

vnames$color2 <- NA 
vnames[vnames$color == "red",]$color2 <- reds[1:length(vnames[vnames$color == "red",]$color)]
vnames[vnames$color == "blue",]$color2 <- blues[1:length(vnames[vnames$color == "blue",]$color)]
vnames[vnames$color == "black",]$color2 <- blacks[1:length(vnames[vnames$color == "black",]$color)]

ifelse(group=="S",1,-1) -> flip
plot(flip*x1, y1, type="n", xlab="", ylab="", main=paste("IDSscal", group,c), ylim = c(-.6,1), xlim = c(-1,.6))
for(s in 1:length(IDS.space$conf)){
  x <- flip*IDS.space$conf[[s]][,dim1]
  y <- IDS.space$conf[[s]][,dim2]
  
  if(grepl("S",names(temp2)[s])){
    #points(x, y,pch=19, col=rgb(.8,.8,.8,1),cex=.8)}  
    #points(x, y,pch=19, col=rainbow(59,v =1, alpha=.4),cex=.8)}
    points(x, y,pch=19, col=vnames$color2,cex=.8)}
    #points(x, y,pch=19, col=subjcol[s],cex=.8)}
  
  if(grepl("B",names(temp2)[s])){
    #points(x, y,pch=19, col=rgb(.5,.5,.5,1),cex=.8)}  
    #points(x, y,pch=19, col=rainbow(59,v=1, alpha=.2),cex=.8)}
    points(x, y,pch=19, col=vnames$color2,cex=.8)}
    #points(x, y,pch=19, col=subjcol[s],cex=.8)}
}

points(flip*x1, y1,pch=5, col="black",cex=.9);points(flip*x1, y1,pch=5, col="black",cex=.9);points(flip*x1, y1,pch=5, col="black",cex=.9);points(flip*x1, y1,pch=5, col="black",cex=.9);
points(flip*x1, y1,pch=18, col=vnames$color2,cex=.8);points(flip*x1, y1,pch=18, col=vnames$color2,cex=.8);points(flip*x1, y1,pch=18, col=vnames$color2,cex=.8);points(flip*x1, y1,pch=18, col=vnames$color2,cex=.8);
#text(x1,y1, names(x1), cex=.7, col=("black"),adj=-.5)

vnames2<-vnames[with(vnames, order(C1, V1)), ]

legend("bottomright",legend = vnames2$V1, fill=vnames2$color2,cex = .39)

if(group=="S")
  {IDS.space -> IDS.space.sighted}
if(group=="B")
  {IDS.space -> IDS.space.blind}

t.test(IDS.space.blind$sps,IDS.space.sighted$sps)

# differences in stress between groups?
IDSstress<-list()
IDSstress$sighted <- IDS.space$sps[grepl("S", names(IDS.space$sps))]
IDSstress$blind <- IDS.space$sps[grepl("B", names(IDS.space$sps))]
t.test(IDSstress$blind,IDSstress$sighted)

t.test(IDS.space.blind$sps,IDS.space$sps)


#get the average weight for each dimension
IDSweights <- sapply(IDS.space$cweights,diag)
barplot(rowMeans(IDSweights))

#other plots 
plot(IDS.space,plot.type = "Shepard")
plot(IDS.space, plot.type = "resplot")

plot(IDS.space,plot.type = "confplot")
plot(IDS.space, plot.type = "bubbleplot")

#get the stress per person
sorted <- sort(IDS.space$sps, decreasing = TRUE)
sortedcol <- ifelse(grepl("S",names(sorted)),"red","darkred")
barplot(sort(IDS.space$sps, decreasing = TRUE), main = paste("Stress",group,c), cex.names = 1,las=2, col=sortedcol,ylim=c(0,.6)) 

#get the stress per item 
plot(IDS.space, plot.type = "stressplot", main = "Stress per Item",cex=1,label.conf.rows = list(label = TRUE, pos = 3, col = 3, las=3))

sorted <- sort(IDS.space$spp, decreasing = TRUE)
sortedcol <- ifelse(grepl(vnames$V1==names(sorted)),vname$color,"darkred")
barplot(sort(IDS.space$spp, decreasing = TRUE), main = paste("Stress",group,c), cex.names = .8,las=2, col=sortedcol) #,ylim=c(0,.6)) 

x <- sort.int(IDS.space$spp,index.return = T)
plot( x$x, type = "h")
text(x$x+3, names(x$x),srt=90, col = vnames$color[x$ix] )

## Silly 3D Plots 

#3D
s3d<-scatterplot3d(x1,y1,z1, main="3D Scatterplot",type="p",angle=30,pch=" ", zlim = c(-1,1), xlim = c(-2,2), ylim = c(-2,2), scale.y=1,box=FALSE)
for(s in 1:length(IDS.space$conf)){  
  x <- IDS.space$conf[[s]][,dim1]
  y <- IDS.space$conf[[s]][,dim2]
  z <- IDS.space$conf[[s]][,dim3] 
  
  if(grepl("S",names(IDS.space$conf[s]))){
    # points(x, y,pch=19, col=rgb(1,0,0,.6),cex=1.5)}  
    #points(s3d$xyz.convert(x,y,z),pch=19, col=rgb(1,0,0,.6),cex=1.5, type="h")
    #s3d$points3d(x,y,z,pch=20, col=rainbow(15,.6),cex=1.5, type="h")
    s3d$points3d(x,y,z,pch=20, col=rgb(1,0,0,.6),cex=1.5, type="p")  
  }
  
  if(grepl("B",names(IDS.space$conf[s]))){
    #points(x, y,pch=19, col=rgb(.5,0,0,.6),cex=1.5)}  
    #points(s3d$xyz.convert(x,y,z),pch=19, col=rgb(.5,0,0,.6),cex=1.5, type = "h")
    #s3d$points3d(x,y,z,pch=20, col=rainbow(15,.6),cex=1.5, type="h")
    s3d$points3d(x,y,z,pch=20, col=rgb(.5,0,0,.6),cex=1.5, type="p")  }
}
#text(s3d$xyz.convert(x1,y1,z1),labels=names(x1),col=rainbow(15))
s3d$points3d(x1,y1,z1,pch=" ", col=rgb(0,0,0,1),cex=1.5, type="h",lwd=2)  
text(s3d$xyz.convert(x1,y1,z1),labels=names(x1),col="black",pos=3)

#3d 2 
plot3d(x1, y1, z1, size=1, type="s", lighting=TRUE, shade=0, col="black",box=FALSE)
for(s in 1:length(IDS.space$conf)){  
  x <- IDS.space$conf[[s]][,dim1]
  y <- IDS.space$conf[[s]][,dim2]
  z <- IDS.space$conf[[s]][,dim3] 
  
  if(grepl("S",names(IDS.space$conf[s]))){
    #plot3d(x, y, z, col=rainbow(15,.6), size=1, type="s",add=TRUE)  
    plot3d(x, y, z, col=rgb(1,0,0,.6), size=1, type="s",add=TRUE)  
  }
  
  if(grepl("B",names(IDS.space$conf[s]))){
    #plot3d(x, y, z, col=rainbow(15,.6), size=1, type="s",add=TRUE)
    plot3d(x, y, z, col=rgb(.1,0,0,.6), size=1, type="s",add=TRUE)  
  }
}
#text(s3d$xyz.convert(x1,y1,z1),labels=names(x1),col=rainbow(15))
text3d(x1,y1,z1,text=names(x1))
scatter3d(x1, y1, z1,surface=TRUE,type="h")



## Other Reduction Approaches (check against Ward Hierarchical) 

# Determine number of clusters
wssB <- (nrow(dis.square[[c]][["B"]])-1)*sum(apply(dis.square[[c]][[group]],2,var))
for (i in 1:10) wssB[i] <- sum(kmeans(dis.square[[c]][["B"]], centers=i)$withinss)

wssS <- (nrow(dis.square[[c]][["S"]])-1)*sum(apply(dis.square[[c]][[group]],2,var))
for (i in 1:10) wssS[i] <- sum(kmeans(dis.square[[c]][["S"]], centers=i)$withinss)

plot(1:10, wssB, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares", col = "darkred")
lines(1:10, wssS, type = "b", col = "red")
legend("topright",c("Blind","Sighted"), fill = c("darkred","red"))

#K medoids -- use when there aren't "objective" parameters for the dimensions space (e.g. when there is only a distance matrix)
library(fpc)
library(MASS)

group = "S"
c

pamk.best <- pamk(dis.square[[c]][[group]], diss=T, usepam = T)
cat("number of clusters estimated by optimum average silhouette width:", pamk.best$nc, "\n")
pamk.data <- pam(as.dist(dis.square[[c]][[group]]), pamk.best$nc, diss=T)

pamk.mds <- cmdscale(dis.square[[c]][[group]],pamk.best$nc)
eqscplot(pamk.mds,col=pamk.data$clustering, pch=pamk.data$clustering)

summary(pamk.data)
plot(pamk.data,color="red",cex.names =.8,nmax.lab=100)

barplot(pamk.data$silinfo$widths[,3],horiz = T,las=2,cex.name=.8)


