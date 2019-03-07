library(forecast)
library(data.table)
#
YEARLY<-fread("http://sidc.be/silso/DATA/SN_y_tot_V2.0.csv",sep = ';')
colnames(YEARLY) <- c("Ymd","Spots","V3","V4","V5")
spots <- subset(DAILY,Year >=2000)
spots <- ts(spots,start=min(spots$Year,end=max(spots$Year)))