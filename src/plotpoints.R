library(ggmap)
library(ggplot2)

test <- read.csv('../data/response_fia.csv')
OSBS <- x_fia[x_fia$statecd == 12 & x_fia$countycd==107,]
TALL <- x_fia[x_fia$statecd == 1 & x_fia$countycd %in% c(7,65, 105, 125),]
MLBS <- x_fia[x_fia$statecd == 51 & x_fia$countycd ==71,]

usa <- map_data("county")
OSBS_out <- usa[usa$subregion == "putnam" & usa$region == "florida",]
TALL_out <- usa[usa$subregion %in% c('bibb', 'hale', 'perry', 'tuscaloosa') & usa$region == "alabama", ]
MLBS_out <- usa[usa$subregion == "giles" & usa$region == "virginia",]

OSBS$lat2 <- OSBS$lat
TALL$lat2 <- TALL$lat
MLBS$lat2 <- MLBS$lat

OSBS$lat <- NULL
TALL$lat <- NULL
MLBS$lat <- NULL

ggplot() + 
  geom_polygon(data = OSBS_out, aes(x=long, y = lat, group = group), fill = NA, color = "red") + 
  geom_point(data = OSBS, aes(x=lon,y=lat2), size = 1, shape = 1) +
  coord_fixed(1.3)

ggplot() + 
  geom_polygon(data = TALL_out, aes(x=long, y = lat, group = group), fill = NA, color = "red") + 
  geom_point(data = TALL, aes(x=lon,y=lat2), size = 1, shape = 1) +
  coord_fixed(1.3)

ggplot() + 
  geom_polygon(data = MLBS_out, aes(x=long, y = lat, group = group), fill = NA, color = "red") + 
  geom_point(data = MLBS, aes(x=lon,y=lat2), size = 1, shape = 1) +
  coord_fixed(1.3)

