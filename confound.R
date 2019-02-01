# this is a test

files <- list.files(path=getwd(), pattern="*.tsv")

nsubj <- length(files)/4

all.confound <- data.frame()

for(file in files){
  temp <- read.table(file, header = T, na.strings = 'n/a')
  temp[is.na(temp)] <- 0
  temp <- temp$FramewiseDisplacement
  temp2 <- as.data.frame(temp)
  colnames(temp2) <- 'FramewiseDisplacement'
  subjID <- rep(substr(file, nchar(file)-42,nchar(file)-(42-7)), nrow(temp2))
  runID <-  rep(substr(file, nchar(file)-(42-18),nchar(file)-(42-23)), nrow(temp2))
  temp2$subjID <- subjID
  temp2$runID <- runID
  temp2 <- temp2[,c(2,3,1)]
  all.confound <- rbind(all.confound, temp2)
}

subj_list <- levels(as.factor(all.confound$subjID))

threshold <- seq(from = 0.2, to = 1, by = 0.1)

for (t in 1:length(threshold)){
  table.threshold <- data.frame()

  for (sub in 1:length(levels(as.factor(all.confound$subjID)))){
    temp_subj <- subset(subset(all.confound, subjID==subj_list[sub]))
    for (run in 1:length(levels(as.factor(all.confound$runID)))){
      temp_run <- subset(subset(temp_subj, runID==levels(as.factor(all.confound$runID))[run]))
      temp_run$above_threshold <- ifelse(temp_run$FramewiseDisplacement > threshold[t], 1, 0)
      table.threshold[sub,1] <- subj_list[sub]
      table.threshold[sub,run+1] <- sum(temp_run$above_threshold)/nrow(temp_run)
    }
  }

  table.threshold.2 <- table.threshold
  table.threshold[6:9] <- ifelse(table.threshold[2:5] > .1, 1, 0)
  table.threshold$drop <- ifelse(rowSums(table.threshold[6:9], dims = 1) > 0, 1, 0)

  print(paste('At', threshold[t], 'mm threshold you discard n.', sum(table.threshold$drop), 'subj'))

  # drop.list <- table.threshold[which(table.threshold$drop==1),1]
  # for (i in 1:length(drop.list)){
  # print(drop.list[i])
}


all.confound.drop <- subset(all.confound, !(subjID %in% drop.list))

ggplot(all.confound.drop, aes(runID, FramewiseDisplacement, fill=runID))+
  geom_boxplot(show.legend = F)+
  # geom_jitter(aes(col=subjID), show.legend = F)+
  theme_classic()




# plot <- list()
# subj_list <- levels(as.factor(all.confound$subjID))
#
# library(ggplot2)
#
# for (sub in 1:length(levels(as.factor(all.confound$subjID)))){
#   sub_temp <- subset(all.confound,subjID==subj_list[sub])
#   plot[[sub]] <- ggplot(sub_temp, aes(subjID, FramewiseDisplacement, fill=runID))+
#     geom_boxplot()+
#     theme_bw()
#   ggsave(plot = plot[[sub]], file = paste(subj_list[sub],".jpg",sep=""))
# }
#
# ggplot(all.confound.drop, aes(runID, FramewiseDisplacement, fill=runID))+
#   # geom_boxplot(show.legend = F)+
#   geom_jitter(aes(col=subjID), show.legend = F)+
#   theme_classic()
