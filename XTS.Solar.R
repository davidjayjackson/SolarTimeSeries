library(data.table)
library(forecast)
library(mice)
library(VIM)
# library(RMySQL)
# library(RSQLite)
library(ggplot2)
library(sqldf)

rm(list=ls())
#

# Import sidc sunspot Data from http://sidc.be
#
sidc<-fread("http://sidc.be/silso/DATA/SN_d_tot_V2.0.csv",sep = ';')
colnames(sidc) <- c("Year","Month","Day", "Fdate","Spots", "Sd","Obs" ,"Defin"  )
sidc$Ymd <- as.Date(paste(sidc$Year, sidc$Month, sidc$Day, sep = "-"))
sidc<-sidc[Year>=1945,]
sidc$Vote <- ifelse(sidc$Spots == 0, 
                      0, 1)
summary(sidc$Ymd)
mtd <- sqldf("Select Day,avg(Spots) as ct from sidc where Spots >=1 group by Day")
ggplot(data=mtd,aes(Day,ct,size=ct)) + geom_smooth() +geom_point() + ggtitle("Sunspot Summary by Day")
# sidc$Ymd <-ymd(sidc$Ymd)
# impute <- mice(sidc[,10:11],m=10,seed=123)
# data <-complete(impute,7)
# D <-sidc
# data <- as.data.table(data)
# solar <- cbind(D,data)
# solar[,.(Year,Ymd,Vote,Obs1,)]
#
# Quick plot to check previous 13 months data,
feb <- sidc[Ymd >="2018-01-01"]
ggplot(data=feb,aes(Ymd,Spots)) + geom_line() +geom_smooth() +ggtitle("13 Month Sunspot Count ")
#
# XTS Weekly series
isn.xts <- xts(x = sidc$Spots, order.by = sidc$Ymd)
str(isn.xts)
isn.weekly<- apply.weekly(isn.xts, sum)
XTSWEEKLY <- as.data.table(isn.weekly)
colnames(XTSWEEKLY) <- c("Ymd","Spots")
#
# XTS series for monthly
#
isn.xts <- xts(x = sidc$Spots, order.by = sidc$Ymd)
str(isn.xts)
isn.monthly<- apply.monthly(isn.xts, sum)
XTSMONTHLY <- as.data.table(isn.monthly)
colnames(XTSMONTHLY) <- c("Ymd","Spots")
#
#
#Import Yearly Data from http://sidc.be
#
YEARLY<-fread("http://sidc.be/silso/DATA/SN_y_tot_V2.0.csv",sep = ';')
colnames(YEARLY) <- c("Ymd","Spots","V3","V4","V5")

# Hemasphere
HEMP<-fread("http://sidc.be/silso/DATA/SN_m_hem_V2.0.csv",sep = ';')
colnames(HEMP) <- c("Year","Month","FDate", "Mean",
                    "North", "South","V7" ,"V8","V9","V10","V11","V12","V13"   )
hem <- HEMP[Year >="2018",]
ggplot(data=hem,aes(FDate,North)) + geom_line() +geom_smooth() +ggtitle("13 Month North SunSpots Activity")
#

#
# Use XTS to calculate Yearly sunspot counts
isn.xts <- xts(x = sidc$Spots, order.by = sidc$Ymd)
str(isn.xts)
isn.yearly<- apply.yearly(isn.xts, sum)
XTSYEARLY <- as.data.table(isn.yearly)
colnames(XTSYEARLY) <- c("Ymd","Spots")

# XTSYEARLY$Twentyfive <- as.data.table(ma(XTSYEARLY$Spots,order=25))
# XTSYEARLY$Fifty <- as.data.table(ma(XTSYEARLY$Spots,order=50))
# XTSYEARLY$SEVENTYFIVE<- as.data.table(ma(XTSYEARLY$Spots,order=75))
# XTSYEARLY$CENTURY <- as.data.table(ma(XTSYEARLY$Spots,order=100))
# XTSYEARLY$WA <- (XTSYEARLY$Spots + XTSYEARLY$Twentyfive + 
#                    XTSYEARLY$Fifty + XTSYEARLY$SEVENTYFIVE + XTSYEARLY$CENTURY )/5
# # sidc$WA2 <- (sidc$Spots + sidc$ma30 + sidc$ma90 + sidc$ma120)/mean(sidc$Spots)
# Create


# XTSYEARLY$Year <- as.character(XTSYEARLY$Year)
# #  
# XTSYEARLY$Twentyfive <- as.numeric(XTSYEARLY$Twentyfive)
# XTSYEARLY$Fifty<- as.numeric(XTSYEARLY$Fifty)
# XTSYEARLY$Century <- as.numeric(XTSYEARLY$Century)
# XTSYEARLY$Year <- as.numeric(XTSYEARLY$Year)
#
#
##
###### MySQL & RMySQL
mydb <- dbConnect(MySQL(),user='root',password='dJj12345',dbname="sidc",
host='localhost')
#
dbListTables(mydb)
# Drop Tables
dbRemoveTable(mydb,"sidc")
dbRemoveTable(mydb,"xtsmonthly")
dbRemoveTable(mydb,"xtsweekly")
dbRemoveTable(mydb,"xtsyearly")
dbRemoveTable(mydb,"hemp")

#
dbListTables(mydb)
dbWriteTable(mydb, "sidc", sidc, row.names = FALSE)
dbSendStatement(mydb, "ALTER TABLE sidc MODIFY COLUMN Ymd date")
dbSendStatement(mydb, "ALTER TABLE sidc MODIFY COLUMN Spots int")
#
dbWriteTable(mydb, "XTSWEEKLY", XTSWEEKLY, row.names = FALSE)
dbSendStatement(mydb, "ALTER TABLE XTSWEEKLY MODIFY COLUMN Ymd date")
dbSendStatement(mydb, "ALTER TABLE XTSWEEKLY MODIFY COLUMN Spots int")
#
dbWriteTable(mydb, "XTSMONTHLY", XTSMONTHLY, row.names = FALSE)
dbSendStatement(mydb, "ALTER TABLE XTSMONTHLY MODIFY COLUMN Ymd date")
dbSendStatement(mydb, "ALTER TABLE XTSMONTHLY MODIFY COLUMN Spots INT")
#
dbWriteTable(mydb, "XTSYEARLY", XTSYEARLY, row.names = FALSE)
dbListTables(mydb)
dbSendStatement(mydb, "ALTER TABLE XTSYEARLY MODIFY COLUMN Ymd date")
dbSendStatement(mydb, "ALTER TABLE XTSYEARLY MODIFY COLUMN Spots int")
dbWriteTable(mydb, "HEMP", HEMP, row.names = FALSE)
dbWriteTable(mydb, "solar", solar, row.names = FALSE)
dbDisconnect(mydb)

dbSendStatement(mydb, "UPDATE combined SET AMERICAN10 = AMERICAN*1.5")

dbCommit(mydb)





