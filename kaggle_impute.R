## Importing packages
library(tidyverse)
library(forecast)
library(data.table)
library(mice)
library(VIM)
#
rm(list=ls())
#
# Import daily sunspot data from http://sidc.be
s <-fread("http://sidc.be/silso/DATA/SN_d_tot_V2.0.csv")
colnames(s) <- c("Year","Month","Day", "Fdate","Spots", "Sd","Obs" ,"Defin"  )
s1 <-subset(s,Year >=1945)
# Create YYYY-MM-DD field
s1$Ymd <- as.Date(paste(s1$Year, s1$Month, s1$Day, sep = "-"))
# Deleted values for Spots and Sd for years between 1955 & 1060
s1$Spots1 <- ifelse(s1$Year >=1955 & s1$Year <=1960,NA,s1$Spots)
s1$Sd1 <- ifelse(s1$Year >=1955 & s1$Year <=1960,NA,s1$Sd)
s1$Defin1 <- ifelse(s1$Year >=1955 & s1$Year <=1960,NA,s1$Defin)
# Names: 'Year' 'Month' 'Day' 'Fdate' 'Spots' 'Sd' 'Obs' 'Defin' 'Ymd' 'Spots1' 'Sd1'
solar <-s1
# solar <- solar[,.(Ymd,Year,Defin,Spots,Sd,Defin1,Spots1,Sd1)]
solar <- solar[,.(Ymd,Year,Spots)]
tail(solar)
# Impute missing numbers for Defin,Spots and SD for period between 1849 and 2019
impute <- mice(solar[,6:8],m=3,seed=123)
impute$imp$Spots1
data <-complete(impute,3)
solar3 <- cbind(solar2,data)
