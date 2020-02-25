library(maptools)
library(rgdal)

neon_domains <- readOGR("NEONDomains_0/", "NEON_Domains")
#11, 10 are lon, lat
subscales_fia("../data/climate_fia.csv", c(11,10))