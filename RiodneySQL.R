library(data.table)
library(ggplot2)
library(forecast)
library(RMySQL)
dblibrary(RSQLite)

rm(list=ls())
#

# Import Daily sunspot Data from http://sidc.be
# And create Data Table
DAILY<-fread("http://sidc.be/silso/DATA/SN_d_tot_V2.0.csv",sep = ';')
# ADD column names
colnames(DAILY) <- c("Year","Month","Day", "Fdate","Spots", "Sd","Obs" ,"Defin"  )
# Create Year - Month - Day field
DAILY$Ymd <- as.Date(paste(DAILY$Year, DAILY$Month, DAILY$Day, sep = "-"))
#
###### MySQL & RMySQL
mydb <- dbConnect(MySQL(),user='root',password='dJj12345',dbname="sidc",
host='localhost')
#
dbListTables(mydb)
# Drop Tables
dbRemoveTable(mydb,"daily")
dbListTables(mydb)

dbWriteTable(mydb, "DAILY", DAILY, row.names = FALSE)
dbSendStatement(mydb, "ALTER TABLE DAILY MODIFY COLUMN Ymd date")
dbSendStatement(mydb, "ALTER TABLE DAILY MODIFY COLUMN Spots int")
# Read data back into data.frame
ROD <- dbGetQuery(mydb, "SELECT * FROM daily
                  WHERE Year >=2000")
ROD$Ymd <- as.Date(ROD$Ymd)
dbDisconnect(mydb)
# Create Plot of DAily Sunspots numbers.
plot(ROD$Ymd,ROD$Spots,type="l",
     main="Yearly Sunspot Counts: 2000 - 2018",
     xlab="Years",ylab="Sunspot Counts")


# SQLite: stuff
# 
db <- dbConnect(SQLite(), dbname="Rhowe.sqlite3")
# # SQLite: stuff
# 
dbListTables(db)
# # Creat table and Insert data.frame(overwrites existing table)
# Convert Ymd field to Character for import into sqlite
DAILY$Ymd <- as.character(DAILY$Ymd)
dbWriteTable(db, "DAILY", DAILY,overwrite=TRUE)
HOWE <- dbGetQuery(db, "SELECT * FROM daily
                  WHERE Year >=2018")

#
dbDisconnect(db)
#
# Plot for daily counts for 2018
#
plot(HOWE$Fdate,HOWE$Spots, type="l",
     main="Daily Sunspot Count for 2018",
     xlab="Number of Month/Year",ylab="Sunspot Counts")
