#install.packages(&quot;rvest&quot;)
library(rvest)
 
#URL of the HTML webpage we want to scrape
url=&quot;http://www.fia.com/events/formula-1-world-championship/season-2015/qualifying-classification&quot;
 
fiaTableGrabber=function(url,num){
  #Grab the page
  hh=html(url)
  #Parse HTML
  cc=html_nodes(hh, xpath = &quot;//table&quot;)[[num]] %&gt;% html_table(fill=TRUE)
  #TO DO - extract table name
   
  #Set the column names
  colnames(cc) = cc[1, ]
  #Drop all NA column
  cc=Filter(function(x)!all(is.na(x)), cc[-1,])
  #Fill blanks with NA
  cc=apply(cc, 2, function(x) gsub(&quot;^$|^ $&quot;, NA, x))
  #would the dataframe cast handle the NA?
  as.data.frame(cc)
}
 
#Usage:
#NUM:
## Qualifying:
### 1 CLASSIFICATION 
### 2 BEST SECTOR TIMES
### 3 SPEED TRAP 
### 4 MAXIMUM SPEEDS
##Race:
### 1 CLASSIFICATION
### 2 FASTEST LAPS
### 3 BEST SECTOR TIMES
### 4 SPEED TRAP
### 5 MAXIMUM SPEEDS
### 6 PIT STOPS
xx=fiaTableGrabber(url,NUM)

#1Q
fiaQualiClassTidy=function(xx){
  for (q in c('Q1','Q2','Q3')){
    cn=paste(q,'time',sep='')
    xx[cn]=apply(xx[q],1,timeInS)
  }
   
  xx=dplyr:::rename(xx, Q1_laps=LAPS)
  xx=dplyr:::rename(xx, Q2_laps=LAPS.1)
  xx=dplyr:::rename(xx, Q3_laps=LAPS.2)
  xx
}
 
#2Q, 3R 
fiaSectorTidy=function(xx){
  colnames(xx)=c('pos',
                's1_driver','s1_nattime',
                's2_driver','s2_nattime',
                's3_driver','s3_nattime')
  for (s in c('s1','s2','s3')) {
    sn=paste(s,'_time',sep='')
    sm=paste(s,'_nattime',sep='')
    xx[sn]=apply(xx[sm],1,timeInS)
  }
   
  xx[-1,]
}
 
#3Q, 4R
fiaTrapTidy=function(xx){
  xx
}
 
# 4Q, 5R
fiaSpeedTidy=function(xx){
  colnames(xx)=c('pos',
                'inter1_driver','inter1_speed',
                'inter2_driver','inter2_speed',
                'inter3_driver','inter3_speed')
   
  xx[-1,]
}
 
# 2R
fiaRaceFastlapTidy=function(xx){
  xx['time']=apply(xx['LAP TIME'],1,timeInS)
  xx
}
 
# 6R
fiaPitsSummary=function(xx){
  r=which(xx['NO']=='RACE - PIT STOP - DETAIL')
  xx['tot_time']=apply(xx['TOTAL TIME'],1,timeInS)
  Filter(function(x)!all(is.na(x)), xx[1:r-1,])
}
 
#6R
fiaPitsDetail=function(xx){
  colnames(xx)=c('NO','DRIVER','LAP','TIME','STOP','NAT DURATION','TOTAL TIME')
  xx['tot_time']=apply(xx['TOTAL TIME'],1,timeInS)
  xx['duration']=apply(xx['NAT DURATION'],1,timeInS)
  r=which(xx['NO']=='RACE - PIT STOP - DETAIL')
  xx=xx[r+2:nrow(xx),]
  #Remove blank row - http://stackoverflow.com/a/6437778/454773
  xx[rowSums(is.na(xx)) != ncol(xx),]
}
