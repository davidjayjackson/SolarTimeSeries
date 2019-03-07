mydb <- dbConnect(MySQL(),user='root',password='dJj12345',dbname="sidc",
                  host='localhost')

dbListTables(mydb)
dbWriteTable(mydb, "noaa", noaa, row.names = FALSE)
dbSendStatement(mydb, "ALTER TABLE noaa MODIFY COLUMN Ymd date")
# dbSendStatement(mydb, "ALTER TABLE DAILY MODIFY COLUMN Spots int")
dbWriteTable(mydb, "american", american, row.names = FALSE)
dbSendStatement(mydb, "ALTER TABLE american MODIFY COLUMN Ymd date")
dbListTables(mydb)
noaa$Ymd <- as.Date(paste(noaa$Year, noaa$Month, noaa$Day, sep = "-"))
# Calc difference and percent increate/decrease
dbCommit(mydb)
C <- dbGetQuery(mydb,"SELECT * FROM combined WHERE year <=1955")
# Add columns for Diff and Percent
dbSendStatement(mydb, "ALTER TABLE combined ADD COLUMN Difference ")
dbSendStatement(mydb, "UPDATE combined SET Difference =round( aavso - American,2)")
dbSendStatement(mydb, "UPDATE sidc.combined SET Percent = round((Difference/american) *100,2)")
# Multiply American by 10
dbSendStatement(mydb,"UPDATE combined SET timesten = AMERICAN*2")
dbCommit(mydb)
#
# Impute values for Observations and Spots
impute <-mice(DAILY[,10:11],m=3, seed=123)

colnames(solar) <- c("Year","Month","Day", "Fdate","Spots", "Sd","Obs" ,"Defin",
                            "YesNO","Impute","Obs1","Ymd","Impute1","Obs2" )