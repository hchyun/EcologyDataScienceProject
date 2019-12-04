library(ggmap)
library(ggplot2)

test <- read.csv('../data/response_fia.csv')
testc <- read.csv('../data/climate_fia.csv')

usa <- map_data("usa")

colnames(DO1)[5] <- 'lat2'
s <- y_fia[y_fia$spcd == 12,]

t <- join(s, DO1, type='inner', by=c("statecd","unitcd","countycd","plot"))
colnames(t)
testc$lat2 <- testc$lat
testc$lat <- NULL
temporal_fia2$lat2 <- temporal_fia2$lat
temporal_fia2$lat <- NULL
ggplot() + 
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), fill = NA, color = "red") + 
  geom_point(data = t, aes(x=lon,y=lat2), size = 1, shape = 1) +
  coord_fixed(1.3)

