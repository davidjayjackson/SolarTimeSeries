library(data.table)
library(forecast)
library(ggplot2)
library(plotly)
library(xts)
library(lubridate)

rm(list=ls())
#
bremen <- fread('./bremen.csv')
# Import sidc sunspot Data from http://sidc.be
#
# sidc<-fread("http://sidc.be/silso/DATA/SN_d_tot_V2.0.csv",sep = ';')
bremen$Ymd <- as.Date(paste(bremen$Year, bremen$Month, bremen$Day, sep = "-"))
# sidc<-sidc[Ymd>="1853-11-09",]
# Quick Plot: 1978 - May 9, 2019
bremen$Short <- ma(bremen$mgii,order=27)
bremen$Long <- ma(bremen$mgii, order=390)
ggplot(data=bremen,aes(x=Ymd,y=Short)) + geom_line() +geom_line(data=bremen,aes(x=Ymd,y=Long))
a <- ggplot(data=bremen,aes(x=Ymd,y=mgii)) + geom_line()
ggplotly(a)
#
# Lyman Composite Alpha
lyman <- fread("./lyman.csv")
colnames(lyman) <- c("Date","Photons","type")
lyman$Year <- substr(lyman$Date,1,4)
lyman$Day <- substr(lyman$Date,5,7)
lyman$Year <-as.integer(lyman$Year)
lyman$Day <-as.integer(lyman$Day)
lyman$Short <- ma(lyman$Photons,order=27)
lyman$Long <- ma(lyman$Photons, order=390)
ggplot(data=bremen,aes(x=Ymd,y=Short)) + geom_line() +geom_line(data=bremen,aes(x=Ymd,y=Long))
a <- ggplot(data=lyman,aes(x=Year,y=Photons)) + geom_point()
ggplotly(a)
#
tsi <- fread("../db/historical_tsi.csv")
#
radio <- fread("../db/noaa_radio_flux.csv")
radio$Ymd <- as.Date(radio$Ymd)
radio$Year <- year(radio$Ymd)
radio$Month <- month(radio$Ymd)
radio$Short <- ma(radio$flux,order=27)
radio$Long <- ma(radio$flux, order=390)
# SQLite Stuff
db <- dbConnect(SQLite(), dbname="solardata.sqlite3")
dbListTables(db)
dbWriteTable(db,"lyman",lyman, row.names=FALSE,overwrite=TRUE)
dbWriteTable(db,"bremen",bremen, row.names=FALSE,overwrite=TRUE)