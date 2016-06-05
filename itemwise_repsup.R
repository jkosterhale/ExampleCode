
if (!require("ggplot2")) {install.packages("ggplot2"); require("ggplot2")}
if (!require("plotrix")) {install.packages("plotrix"); require("plotrix")}
if (!require("Hmisc")) {install.packages("Hmisc"); require("Hmisc")}
if (!require("ez")) {install.packages("ez"); require("ez")}
if (!require("gplots")) {install.packages("gplots"); require("gplots")}
if (!require("reshape")) {install.packages("reshape"); require("reshape")}
if (!require("RColorBrewer")) {install.packages("RColorBrewer"); require("RColorBrewer")}
if (!require("plyr")) {install.packages("plyr"); require("plyr")}

datatype = "PSC"  #PSC or BETA?
rawdata = 0

for(study_name in c("repsup1","repsup2")){
  
  setwd("/Users/jorie/Dropbox/Repsup 2014/data/")
  ifelse(study_name == "repsup1", data <- read.csv("repsup1_items.csv"), data <- read.csv("repsup2_items.csv"))
  
  
  if(study_name == "repsup1"){
    a <- rep(1:70)
    b <- c(2,1,1,1,2,1,1,2,1,1,
           1,2,1,2,1,2,1,2,2,2,
           2,1,2,1,2,2,2,1,2,1,
           1,1,2,2,2,2,2,1,1,2,
           1,2,2,1,1,2,2,2,1,2,
           2,2,1,2,1,2,1,2,2,2,
           2,2,2,1,1,1,1,2,2,2)
    ## 1 indicates the relevant factivity switch
    table(b)
    c <- cbind(a,b)
    d <- subset(c,b==1)
    e <- rep(2,30)
    d <- cbind(d,e)
    d <- data.frame(d)
    d$e[d$a==38|d$a==64|d$a==67] <- 1 ## 1 indicates a factive baseline as below
    #d$e <- factor(c("factive-baseline","nonfactive-baseline")[d$e])
    
    #Notes
    ## in vign 47: "images" should be "imagines"
    ## in vign 70: "knows" should be "hopes"
    
    ## 1 indicates thinks vs. knows 
    f <- c(2,2,1,1,1,
           1,2,1,1,1,
           2,2,2,2,2,
           2,2,2,2,1,
           2,2,2,2,2,
           2,1,2,1,2)
    d <- cbind(d,f)
    d <- data.frame(d)
    
  }
  
  if(study_name == "repsup2"){
    a <- rep(1:70)
    b <- c(2,1,1,1,2,1,1,1,1,1,1,2,1,2,1,2,1,2,2,2,2,1,2,1,2,2,2,1,2,1,2,1,2,2,2,2,2,1,1,2,1,2,2,1,1,2,2,2,1,2,2,2,1,2,1,2,1,2,2,2,2,2,2,1,1,1,2,2,2,2)
    ## 1 indicates the relevant factivity switch
    table(b)
    c <- cbind(a,b)
    d <- subset(c,b==1)
    e <- rep(2,dim(d)[1])
    d <- cbind(d,e)
    d <- data.frame(d)
    d$e[d$a==38|d$a==64] <- 1 ## 1 indicates a factive baseline as below
    #d$e <- factor(c("factive-baseline","nonfactive-baseline")[d$e])
    
    ## 1 indicates thinks vs. knows 
    f <- c(2,2,1,1,1,1,2,1,1,1,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,1,1,1,1)
    d <- cbind(d,f)
    d <- data.frame(d)
    
    #d$f <- factor(c("thinkVknow","other")[d$f])
  }
  
  colnames(d) <- c("item","change","factive_baseline","thinks_knows")
  
  #prep the data 
  
  data$condition[data$condition == 1] <- "1_same"
  data$condition[data$condition == 2] <- "2_rephrase"
  data$condition[data$condition == 3] <- "3_agent"
  data$condition[data$condition == 4] <- "4_attitude"
  data$condition[data$condition == 5] <- "5_content"
  data$condition[data$condition == 6] <- "6_all"
  data$condition[data$condition == 7] <- "7_new"
  data$condition[data$condition == 8] <- "0_baseline"
  data$condition[data$condition == 9] <- "context"
  
  #label verbs by whether they cross a factive boundary 
  #data$condition[data$condition == "4_attitude"  & data$stories %in% d$item] <- "8_change"
  #data$condition[data$condition == "4_attitude"  & !(data$stories %in% d$item)] <- "9_nochange"
  
  #change:  think vs know;   no change: no factive change at all 
  #data$condition[data$condition == "4_attitude"  & data$stories %in% d$item[ d$thinks_knows ==1]] <- "8_thinkknows"
  #data$condition[data$condition == "4_attitude"  & !(data$stories %in% d$item)] <- "9_nonfact"
  
  #change:  know vs think;  no change: think vs know  
  #data$condition[data$condition == "4_attitude"  & data$stories %in% d$item[ d$factive_baseline==1] ] <- "8_factive_nonfact"
  #data$condition[data$condition == "4_attitude"  & data$stories %in% d$item[ d$factive_baseline==2] ] <- "9_nonfact_fact"
  #data$condition[data$condition == "1_same"  & data$stories %in% d$item[ d$factive_baseline==1]  ] <- "11_fact_fact"
  #data$condition[data$condition == "1_same"  & data$stories %in% d$item[ d$factive_baseline==2] ] <- "12_nonfact_nonfact"
  #data$condition[data$condition == "4_attitude"  & !(data$stories %in% d$item)] <- "10_nofactive_change"
  
  
  
  #know vs think;  think vs know  
 # data$condition[data$condition == "4_attitude"  & data$stories %in% d$item[ d$factive_baseline==1] & data$stories %in% d$item[ d$thinks_knows==1] ] <- "8_knowthink"
#  data$condition[data$condition == "4_attitude"  & data$stories %in% d$item[ d$factive_baseline==2] & data$stories %in% d$item[ d$thinks_knows==1] ] <- "9_thinkknow"
 # data$condition[data$condition == "1_same"  & data$stories %in% d$item[ d$factive_baseline==1] & data$stories %in% d$item[ d$thinks_knows==1] ] <- "11_knowknow"
#  data$condition[data$condition == "1_same"  & data$stories %in% d$item[ d$factive_baseline==2] & data$stories %in% d$item[ d$thinks_knows==1] ] <- "12_thinkthink"
 # data$condition[data$condition == "4_attitude"  & !(data$stories %in% d$item)] <- "10_nofactive_change"
  
 #baseline: change:  know vs think;  no change: think vs know  
  data$condition[data$condition == "0_baseline"  & data$stories %in% d$item[ d$factive_baseline==1] & data$stories %in% d$item[ d$thinks_knows==1] ] <- "8_know"
  data$condition[data$condition == "0_baseline"  & data$stories %in% d$item[ d$factive_baseline==2] & data$stories %in% d$item[ d$thinks_knows==1] ] <- "9_think"
  data$condition[data$condition == "0_baseline"  & !(data$stories %in% d$item)] <- "10_otherverbs"
 
 #baseline: change:  factive vs non-factive
 #data$condition[data$condition == "0_baseline"  & data$stories %in% d$item[ d$factive_baseline==1] ] <- "8_factive"
 #data$condition[data$condition == "0_baseline"  & data$stories %in% d$item[ d$factive_baseline==2] ] <- "9_nonfactive"
 #data$condition[data$condition == "0_baseline"  & !(data$stories %in% d$item)] <- "10_nochange"
 
 
  
  
  #extracted window 
  rangestart<-0
  rangeend<-8   #8 seconds 
  
  #timing info
  lag =  2   #hrf lag in TRs
  start = 0 #any offset from stim start? # segment of interest? -> maybe just 3 trs?
  dur = 2 #how many TRs to average across? 
  
  start=start+lag  #four for lag   #3 for the offset of the background
  end=start+dur-1  #another two TRs for duration of target event 
  
  if(datatype=="PSC"){
    #get the average PSC of the window to analyze
    i0 <- which(colnames(data)==paste("X", gsub("0.",".",rangestart), ".TRs", sep=""))
    iend <- which(colnames(data)==paste("X", rangeend, ".TRs", sep=""))
    i1 <- which(colnames(data)==paste("X", start, ".TRs", sep=""))
    i2 <- which(colnames(data)==paste("X", end, ".TRs", sep=""))
    if(i2-i1>0){data$average <- rowMeans(data[,i1:i2])}
    if(i2-i1==0){data$average <- data[,i1]}
    iavg <- which(colnames(data)=="average")}
  
  #drop the bad people 
  data2 <- data[!(data$subject == 'SAX_rs_10' | data$subject == 'SAX_rs_19' | data$subject == 'SAX_rs_21' | data$subject == 'SAX_rs_22' | data$subject == 'SAX_rs_24' | data$subject == 'SAX_rs_26' |
                    data$subject == 'SAX_rsii_09' | data$subject == 'SAX_rsii_10'| data$subject == 'SAX_rsii_13' |data$subject == 'SAX_rsii_15' | data$subject == 'SAX_rsii_16' |   data$subject == 'SAX_rsii_27'),]  # uncomment for repsup1
  #failed to respond to more than 33%% of items (one per story) and too much movement (SAX_rs_10)
  #<50%:    data$subject == 'SAX_rsii_02' | data$subject == 'SAX_rsii_20' 
  
  ifelse(study_name == "repsup1", data2 -> data_rs1, data2 -> data_rs2)
  
}

rbind.fill(data_rs1,data_rs2) -> data2

#select the ROI 
allrois = c('RTPJ') #,'LTPJ','RSTS','PC','DMPFC','MMPFC','VMPFC','LeftIFG','LeftMidAntTemp')

#dev.off()
#layout(matrix(1:8,ncol=2))
#par(mar = c(3.1, 4.5,2.1, 2.1))

plotdata <- NA 
# a loop that prints stats to a text file and generates beta graphs 
#for (roiname in allrois){
roiname = 'RTPJ'
dataroi <- data2[grepl(roiname,data2$roi),]


#subjectmeans <- aggregate(list(average = subset$average), by=list(subject = subset$subject, Condition=subset$mod, mod_main=subset$mod_main, direct=subset$direct), mean, na.rm=TRUE)
#ezANOVA(data=subjectmeans,dv=.(average),wid=.(subject),within=.(direct,mod_main))

# bar plot  ----------------------------------------------------------

#pick your data (INTERACTIVE)
datasubset <- data2[grepl(roiname,data2$roi),]


#itemwise
means <- data.frame(tapply( datasubset$average, list( datasubset$stories2, datasubset$condition), mean,na.rm=TRUE))
m <- colMeans(means,na.rm=T)
se <- apply(means,2,std.error, na.rm=T)

#raw 
if(rawdata==1){
  means <- data.frame(tapply( datasubset$average, list(datasubset$condition), mean,na.rm=TRUE))
  se <- data.frame(tapply( datasubset$average, list(datasubset$condition), std.error,na.rm=TRUE))
  m <- rowMeans(means,na.rm=T)
  se <- rowMeans(se,na.rm=T)}


m<-m[c(1,9,10,2 )]
se<-se[c(1,9,10,2)]


m<-m[c(3,4,11,12)]
se<-se[c(3,4,11,12)]



#names(m) <- c("same","know-think","think-know","nochange")
#names(m) <- c("same","factive-nonfact","nonfact_factive")

mybarcol <- "gray20"
color_pal <- brewer.pal(7, 'Set1')
#png(paste("figures/",study_name,"_",roiname,"_",datatype,'.png',sep=""))
barplot2(m, beside = TRUE,
         col = color_pal,
         # legend = names(m), 
         ylim = c(-1, 1),
         #ylab = "Percent Signal Change",
         col.sub = mybarcol,
         cex.names = .85, plot.ci = TRUE, ci.l = m+se/2, ci.u = m-se/2,
         plot.grid = TRUE)
if(datatype=="BETA"){title(paste(roiname, ": ", datatype))}
if(datatype=="PSC"){title(paste(roiname, ": ", datatype, " - time window (TRs):", start, " - " ,end))}
#dev.off()


# time course plot  (only works for PSC)----------------------------------------------------------
#get differences from mean for plotting within subject standard error  (we probably want to do this for the bar plots too..)

j0 <- which(colnames(itemmeans)==paste("X", gsub("0.",".",rangestart), ".TRs", sep=""))
jend <- which(colnames(itemmeans)==paste("X", rangeend, ".TRs", sep=""))
jav = which(colnames(itemmeans)=="average")


#by item 
itemmeans <- aggregate(dataroi[c(i0:iend,iavg)], by=list(items = dataroi$stories2, condition=dataroi$condition), mean, na.rm=TRUE)
graphmeans <- aggregate(itemmeans[j0:jend], by=list(condition=itemmeans$condition), mean, na.rm=TRUE)
graphste <- aggregate(itemmeans[j0:jend], by=list(condition=itemmeans$condition), std.error, na.rm=TRUE)


#raw
if(rawdata==1){
  graphmeans <- aggregate(dataroi[c(i0:iend,iavg)], by=list(condition=dataroi$condition), mean, na.rm=TRUE)
  graphste <- aggregate(dataroi[c(i0:iend,iavg)], by=list(condition=dataroi$condition), std.error, na.rm=TRUE)
  graphmeans <- graphmeans[,-ncol(graphmeans)]
  graphste <- graphste[,-ncol(graphmeans)]}

#format for ggplot
rownames(graphmeans) <- (paste(graphmeans$condition, sep="_"))
rownames(graphste) <- (paste(graphste$condition, sep="_"))

plotmeans<-as.data.frame(t(graphmeans[,2:dim(graphmeans)[2]]))
plotmeans$timing <- rangestart:rangeend
plotmeans<-melt.data.frame(plotmeans,measure.vars=names(plotmeans[1:(length(plotmeans)-1)]), variable_name="condition") 

plotste<-as.data.frame(t(graphste[,2:dim(graphste)[2]]))
plotste$timing <- rownames(plotste)
plotste<-melt.data.frame(plotste,measure.vars=names(plotste[1:(length(plotste)-1)]), variable_name="condition") 

plotmeans$ste <- plotste$value

#pick which data you want to plot (INTERACTIVE)
# main conditions without baseline
#plotsubset <- plotmeans[ grepl('1_same', plotmeans$condition) | grepl('2_rephrase', plotmeans$condition) | grepl('3_agent', plotmeans$condition) | grepl('4_attitude', plotmeans$condition) | grepl('9_', plotmeans$condition) | grepl('5_content', plotmeans$condition) | grepl('6_all', plotmeans$condition) | grepl('8_', plotmeans$condition) ,]
#plotsubset$ste <- plotste[grepl('same-gmean', plotste$condition) | grepl('rephrase-gmean', plotste$condition) | grepl('agent-gmean', plotste$condition) | grepl('attitude-gmean', plotste$condition) |  grepl('nonfactive-gmean', plotste$condition) | grepl('content-gmean', plotste$condition) | grepl('all-gmean', plotste$condition) | grepl('yesfactive-gmean', plotste$condition)  ,]$value  

#plotsubset <- plotmeans[ grepl('1_same', plotmeans$condition) | grepl('2_rephrase', plotmeans$condition) | grepl('3_agent', plotmeans$condition) | grepl('9_', plotmeans$condition) | grepl('5_content', plotmeans$condition) | grepl('6_all', plotmeans$condition) | grepl('8_', plotmeans$condition) ,]
#plotsubset$ste <- plotste[grepl('same-gmean', plotste$condition) | grepl('rephrase-gmean', plotste$condition) | grepl('agent-gmean', plotste$condition) |  grepl('nonfactive-gmean', plotste$condition) | grepl('content-gmean', plotste$condition) | grepl('all-gmean', plotste$condition) | grepl('yesfactive-gmean', plotste$condition)  ,]$value  

#plotsubset <- plotmeans[ grepl('9_', plotmeans$condition) | grepl('8_', plotmeans$condition) ,]
#plotsubset$ste <- plotste[grepl('nonfactive-gmean', plotste$condition) | grepl('yesfactive-gmean', plotste$condition)  ,]$value  

# plotsubset <- plotmeans[ grepl('1_same', plotmeans$condition) | grepl('2_rephrase', plotmeans$condition) |  grepl('3_agent', plotmeans$condition) | grepl('9_', plotmeans$condition) | grepl('8_', plotmeans$condition) ,]

plotsubset <- plotmeans[ grepl('1_same', plotmeans$condition) | grepl('9_', plotmeans$condition) | grepl('8_', plotmeans$condition) ,]

plotsubset <- plotmeans[ grepl('1_same', plotmeans$condition) | grepl('10_', plotmeans$condition) | grepl('9_', plotmeans$condition) | grepl('8_', plotmeans$condition) ,]

plotsubset <- plotmeans[ grepl('1_same', plotmeans$condition) | grepl('10_', plotmeans$condition) | grepl('9_', plotmeans$condition) | grepl('8_', plotmeans$condition) | grepl('11_', plotmeans$condition) | grepl('12_', plotmeans$condition) ,]

plotsubset <- plotmeans[  grepl('10_', plotmeans$condition) | grepl('9_', plotmeans$condition) | grepl('8_', plotmeans$condition) | grepl('11_', plotmeans$condition) | grepl('12_', plotmeans$condition) ,]

plotsubset <- plotmeans[ grepl('9_', plotmeans$condition) | grepl('8_', plotmeans$condition) | grepl('11_', plotmeans$condition) | grepl('12_', plotmeans$condition)  ,]

#plot it 
color_pal <- brewer.pal(9, 'Set1')
color_pal <- c("red","darkblue","darkred","blue")
color_pal <- c("green4","green1","darkgreen","blue")
#png(paste(study_name,roiname,'timecourse.png',sep="_")) # Change filename!
ggplot(data=plotsubset, aes(x=timing, y=value, ymin=value-ste, ymax=value+ste, group=condition, colour=condition, fill=condition ))+ 
  geom_line(lwd=2) + 
  #geom_errorbar(alpha=.6) +
  geom_ribbon(aes(linetype=NA), alpha=.2) +
  xlab("TR") + 
  ylab("PSC") + 
  theme_bw() + 
  ggtitle(paste(roiname)) + 
  theme(plot.title = element_text(face="bold"))+ 
  #geom_vline(xintercept = start-.2) + 
  #geom_vline(xintercept = end+.2) + 
  scale_fill_manual(values=color_pal) + 
  scale_colour_manual(values=color_pal)


# ggsave(filename = paste("figures/", study_name, "_", roiname,"_timecourse.pdf", sep=""), width = 10, height = 5, units = c("in"))




t.test(dataroi$average[grepl("8_",dataroi$condition)],dataroi$average[grepl("9_",dataroi$condition)],paired = F,alternative = "less")
ttest2 <- t.test(itemmeans$average[grepl("8_",itemmeans$condition)],itemmeans$average[grepl("9_",itemmeans$condition)],paired = F,alternative = "less")

ttest2 <- t.test(itemmeans$average[grepl("8_",itemmeans$condition)],itemmeans$average[grepl("10_",itemmeans$condition)],paired = F,alternative = "less")
ttest2 <- t.test(itemmeans$average[grepl("9_",itemmeans$condition)],itemmeans$average[grepl("10_",itemmeans$condition)],paired = F,alternative = "greater")

c2 = "9_thinkknow"; c1="8_knowthink"
c2 = "9_nonfact_fact"; c1="8_factive_nonfact"
c1 = "9_thinkknow"; c2="10_nochange"
c1 = "8_knowthink"; c2="10_nochange"

cat(ifelse(ttest2$p.value<.05,"*"," "), paste(sep="","(", c1, ": ", round(mean(means[,paste("X", c1, sep="")],na.rm=T),2), "±", round(std.error(means[,paste("X", c1, sep="")]),2),"; ", c2, ": ", round(mean(means[,paste("X", c2, sep="")],na.rm=T),2), "±", round(std.error(means[,paste("X", c2, sep="")]),2)));cat(paste('; t(',round(ttest2$parameter,2),')=',   round(ttest2$statistic,1),sep="",", p=",round(ttest2$p.value,2),")"),"\n","\n")





subset <- itemmeans[ grepl('10', itemmeans$condition) | grepl('9_', itemmeans$condition) | grepl('8_', itemmeans$condition) ,]
subset <- itemmeans[  grepl('9_', itemmeans$condition) | grepl('8_', itemmeans$condition) ,]
subset <- itemmeans[  grepl('9_', itemmeans$condition) | grepl('10_', itemmeans$condition) ,]

subset <- itemmeans[  grepl('8_', itemmeans$condition) | grepl('10_', itemmeans$condition) ,]

ez<-ezANOVA(data=subset,dv=.(average),wid=.(items),between = .(condition))
for (x in 1:dim(ez$ANOVA)[1] ) {
  cat(ez$ANOVA[x,6], " ", ez$ANOVA[x,1],":", "F(",ez$ANOVA[x,2], "," , ez$ANOVA[x,3], ")=", round(ez$ANOVA[x,4],2), ", p=",round(ez$ANOVA[x,5],2), ", ƞ2=",round(ez$ANOVA[x,7],2), "\n",  sep="")  
}
cat("\n"); cat("\n"); 


