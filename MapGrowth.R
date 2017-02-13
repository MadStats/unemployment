# given a and b, make a map of the growth rate in # of employed:
#  first, with inner join.
# install.packages("tidyverse")

# note: load dplyr last (after anything that loads plyr)
# e.g. try this and read the warning:
# library(tidyverse)
# library(choroplethr)
#   If you forget, then quit R and restart.

library(choroplethr)
library(readxl)
library(tidyverse)

source("tidyHistoricalBLS.R")
dat





a = 1990; b = 2001
first = dat %>% filter(year == a) %>% mutate(employedA = employed)
last = dat %>% filter(year == b) %>% mutate(employedB = employed)
both = inner_join(first,last, by = "fips")

MainTitle = paste("Growth in # employed from", a, "to", b)
both %>% 
  transmute(region = as.numeric(fips), 
            value=round(log(employed.y/employed.x)/(b-a) *100,1)
  ) %>% 
  county_choropleth(title = MainTitle)



# now, repeate the same thing with spread. 
wide = dat %>% 
  transmute(
    fips = fips, 
    year = year, 
    employed  = log(employed)
  ) %>% 
  spread(key = year,value = employed)

wide %>% 
  select(
    region = fips, 
    ea = contains(as.character(a)), 
    eb = contains(as.character(b))
  ) %>% 
  transmute(
    region = as.numeric(region), 
    value = (eb - ea)/(b-a)
  ) %>% 
  county_choropleth(title = MainTitle)


# which do you prefer?  

# with inner join:
system.time({
  a = 1990; b = 2001
  first = dat %>% filter(year == a) %>% mutate(employedA = employed)
  last = dat %>% filter(year == b) %>% mutate(employedB = employed)
  both = inner_join(first,last, by = "fips")
  
  MainTitle = paste("Growth in # employed from", a, "to", b)
  both %>% 
    transmute(region = as.numeric(fips), 
              value=round(log(employed.y/employed.x)/(b-a) *100,1)
    )
})


# with spread: 
system.time({
  wide = dat %>% 
    transmute(
      fips = fips, 
      year = year, 
      employed  = log(employed)
    ) %>% 
    spread(key = year,value = employed)
  
  wide %>% 
    select(
      region = fips, 
      ea = contains(as.character(a)), 
      eb = contains(as.character(b))
    ) %>% 
    transmute(
      region = as.numeric(region), 
      value = (eb - ea)/(b-a)
    )
})

# is that fair?

system.time({
  wide %>% 
    select(
      region = fips, 
      ea = contains(as.character(a)), 
      eb = contains(as.character(b))
    ) %>% 
    transmute(
      region = as.numeric(region), 
      value = (eb - ea)/(b-a)
    )
})


png(file = "plots/GrowthIn90s-Map.png",width = 8, height = 8, units = "in", res =100)
wide %>% 
  select(
    region = fips, 
    ea = contains(as.character(a)), 
    eb = contains(as.character(b))
  ) %>% 
  transmute(
    region = as.numeric(region), 
    value = round((eb - ea)/(b-a)*100,1)
  ) %>% 
  county_choropleth(title = MainTitle)
dev.off()






