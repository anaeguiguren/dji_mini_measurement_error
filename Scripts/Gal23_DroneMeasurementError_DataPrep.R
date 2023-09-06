#Gal23_DroneMeasurementError data prep:
# Morphometric analyses:
source("Functions/getMorphoMetrix.R")
library(dplyr)

library("plotly")
library(ggplot2)
library(lubridate)

#a <- getMorphoMetrix(ROOTfolderpath = "/Users/anacristinaeguigurenburneo/Documents/Galapagos2023_Drone_Snapshots/Balaena_Callibrations/")
#write.csv(a, "/Users/anacristinaeguigurenburneo/Documents/Galapagos_Fieldwork_2020s/Measurement_Error_Outputs/Balaena_Raw_Measures.csv")

#a$imageName <- basename(a$imagePath)
#get d

# 1. import and clean data ----
# morphometrix measurements:
m <- read.csv("Raw_Data/Balaena_Raw_Measures.csv", header = T)

#snapshot metadata
s  <- read.csv("Raw_Data/Snapshot_Metadata_2023.csv", header = T)
s$imageName <- s$FileName


a <- left_join(m, s, by ="imageName")

#make a column that contains date and video name
a$videoDate <-paste(a$videoFile, a$Date, sep = "_")

# merge data with flight number:
f <- read.csv("Raw_Data/Drone_Flights_Summary_2023.csv", header = T)

f$videoFileBase <- basename(f$videoFile)

f$Date <- gsub(" .*", "", f$LocalTime)

library(lubridate)
f$Month <- as.character(month(ymd(010101) + months(as.numeric(substr(f$Date, 7,7))-1),label=TRUE,abbr=TRUE))
f$DateWord <- paste(substr(f$Date, 9,10), f$Month, "23", sep = "-")

f$videoDate <- paste(f$videoFileBase, f$DateWord, sep = "_")

#join:
dat <- left_join(a, f, by = "videoDate")

#cleanup

dat$notes <-tolower(dat$notes)
dat$notes <-trimws(dat$notes)
dat <- dat[-which(dat$notes==""),]
dat$pos <- factor(dat$notes)
dat$balaenaAngled <- factor(dat$balaenaAngled)
dat$FlightNo <- factor(dat$FlightNo)

# 2. clean up
dat <- dat %>% select(
  imageName, timeStamp, altitude, length ,pixelDimension.old = pixelDimension, ImageWidth ,
  balaenaAngled, pos, FlightNo, Date = Date.y
)

rm(a);rm(f);rm(m);rm(s)

