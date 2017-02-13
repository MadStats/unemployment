# plot time series of employment numbers for Dane County


library(readxl)
library(tidyverse)

# source("tidyHistoricalBLS.R")
dat

DaneFips = "55025"

dat$year = as.numeric(dat$year)
dat %>% filter(fips==DaneFips) %>%  ggplot(aes(x = year, y = employed, color = name)) + geom_line()


MkeFips = "55079"
theseFips = c(DaneFips, MkeFips)
dat %>% 
  filter(fips %in% theseFips) %>%  
  ggplot(aes(x = year, y = employed, color = name)) + 
  geom_line() 


# sample m counties.  plot their time series.
m  = 20
sampleFips = dat$fips %>% unique %>% sample(m)
quartz()
dat %>% 
  filter(fips %in% sampleFips) %>%  
  ggplot(aes(x = year, y = employed, color = name)) + 
  geom_line() 

# hard to see variation!  How to improve? 

png(file = "plots/Time-Subset.png",width = 3.5, height = 6, units = "in", res =100)
dat %>% 
  filter(fips %in% sampleFips) %>%  
  ggplot(aes(x = log(year), y = log(employed), color = name)) + 
  geom_line() 
dev.off()
# adjust aspect ratio to make plot tall and thin.


# can we center and scale?
# Easier to do with the wide data...

wide = dat %>% 
  transmute(
    fips = fips, 
    year = year, 
    employed  = log(employed),
    name = name
  ) %>% 
  spread(key = year,value = employed) 

wt = t(scale(t(wide[,-(1:2)])))
wt = as_tibble(wt)
wt$fips = wide$fips
wt$name = wide$name
colnames(wt)


m  = 10
sampleFips = dat$fips %>% unique %>% sample(m)

wt %>% 
  filter(fips %in% sampleFips) %>%  
  gather(key = year, employed, -fips, -name) %>% 
  mutate(year = as.numeric(year)) %>% 
  ggplot(aes(x = year, y = employed, color = name)) + 
  geom_line() 
# I don't think this helps!
# Let's find some groups of counties...

