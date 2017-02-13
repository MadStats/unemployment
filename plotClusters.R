# Let's make groups/clusters of counties. 
# Essential question:  What should make counties similar?
#    - similar employment numbers over all years.
#    - similar direction of employment numbers over all years.
# I think the second is more interesting...
#   So, we need to make a vector of directions!  
#   I think growth rate captures this...  P e^(rt)  remember that?  
#  If employment is 1000 in year 1 and the growth rate is .05, what is in year 2?
#    1000* exp(.05*1)
#  If employment is 1000 in year 1 and 1500 in year 2, what is r? 
#  1500 = 1000*exp(r*1) -->   log(1500/1000) = log(1500) - log(1000)


library(choroplethr)
library(readxl)
library(tidyverse)

# source("tidyHistoricalBLS.R")
dat


wide = dat %>% 
  transmute(
    fips = fips, 
    name = name,
    year = year, 
    employed  = employed
  ) %>% 
  spread(key = year,value = employed) 


rates = apply(wide[,-(1:2)], 1, function(x) return(diff(log(x)))) %>% t
missing = rowSums(is.na(rates))
cbind(wide[,1:2], missing) %>% as_tibble() %>% filter(missing>0)
w = wide[missing==0,]
r = rates[missing==0,]

quartz( )
K=  3
km = kmeans(r,K, nstart = 10)
table(km$cluster)

kmd = as_tibble(list(region = as.numeric(w$fips) , value = as.factor(km$cluster)))
# 
choro = CountyChoropleth$new(kmd)
choro$set_num_colors(K)
# To choose a palette, go to http://colorbrewer2.org
# palette="Pastel2"
choro$ggplot_scale = scale_fill_brewer(name="", palette="Paired", drop=FALSE)
png(file = "plots/Cluster-Map.png",width = 8, height = 8 , units = "in", res =100)
choro$render()
dev.off()

#  What do each of the clusters look like? 
cent = as_tibble(km$centers)
cent$cluster = as.character(1:K)
png(file = "plots/Cluster-Centers.png",width = 8, height = 6, units = "in", res =100)
cent %>% gather(key = year, rate, -cluster) %>% 
  mutate(year = as.numeric(year)) %>% 
ggplot(aes(x = year, y = rate, color =cluster)) + 
  geom_line() + facet_wrap(~cluster, nrow = 1)+scale_colour_brewer(palette="Paired")
dev.off()

# sample 10 counties from each cluster.  
#  plot those lines, wrapping by cluster.
r = as_tibble(r)
r$fips = w$fips; r$name = w$name; r$cluster = as.character(km$cluster)

# install.packages("sampling")
# library(sampling)
TheseFips = strata(w, stratanames="cluster", rep(20,K), method = "srswor")$ID_unit 

png(file = "plots/Cluster-SubsetRates.png",width = 8, height = 6, units = "in", res =100)
r %>% 
  filter(fips %in% w$fips[TheseFips]) %>%  
  gather(key = year, employed, -fips, -name, -cluster) %>% 
  mutate(year = as.numeric(year)) %>% 
  ggplot(aes(x = year, y = employed, group = name,color =cluster)) + 
  geom_line() + facet_wrap(~cluster, nrow = 1)+
  scale_colour_brewer(palette="Paired")
dev.off()


w$cluster = as.character(km$cluster)
png(file = "plots/Cluster-SubsetActuals.png",width = 8, height = 6, units = "in", res =100)
w %>% 
  filter(fips %in% w$fips[TheseFips]) %>%  
  gather(key = year, employed, -fips, -name, -cluster) %>% 
  mutate(year = as.numeric(year)) %>% 
  ggplot(aes(x = year, y = log(employed), group = name,color =cluster)) + 
  geom_line() + facet_wrap(~cluster, nrow = 1)+
  scale_colour_brewer(palette="Paired")
dev.off()


