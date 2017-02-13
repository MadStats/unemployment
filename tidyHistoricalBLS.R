

yearSeq = c(as.character(90:99), paste("0",0:9,sep=""), 11:15)
length(yearSeq)
for(tick  in 1:25){
  my.url <- paste("http://www.bls.gov/lau/laucnty", yearSeq[tick],".xlsx", sep = "")
  loc.download <- 
    paste(getwd(), "data", paste(yearSeq[tick],".xlsx", sep=""), sep = "/") 
  download.file(my.url, loc.download, mode="wb")
}


dat = as_data_frame(matrix(NA, nrow = 3300*25, ncol = 5))
colnames(dat) = c("year", "fips", "rate", "employed", "name")
spot = 1
for(tick  in 1:25){
  loc.download <- 
    paste(getwd(),"data", paste(yearSeq[tick],".xlsx", sep=""), sep = "/") 
  unemployData = read_excel(loc.download, skip = 5, sheet = 1, na = "setosa", col_names =  F)
  bad = which(rowSums(is.na(unemployData))>4)
  
  unemployData = unemployData %>% mutate(fips = paste(X1,X2,sep = ""))
  dat[spot:(spot+nrow(unemployData)-1),] = unemployData %>% transmute(X4,fips, X9, X7, X3)
  spot = spot+nrow(unemployData) 
}
# head(dat)

dat = dat[rowSums(is.na(dat))==0,]


