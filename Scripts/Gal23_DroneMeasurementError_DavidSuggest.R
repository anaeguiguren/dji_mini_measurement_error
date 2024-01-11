#Re callibrate with new information:
library(circular)

#estimate focal length (mm)

diag.35mm <- sqrt(36^2 + 24^2)
diag.mini <- sqrt(6.2^2 + 4.65^2)
crop.factor.mini = diag.35mm/diag.mini

diag.phantom <- sqrt(13.2^2 +8.8^2)

crop.factor.phantom <- diag.35mm/diag.phantom


length.morphometrix <-function(px.dimension = 0.00155,
                        altitude, 
                        pixel.length){
  #' @description all constant parameters are set to the DJI mini specs as a default
  #' @param px.dimension the size of pixels in centimeters - default value is set for 4K video
  #' @param altitude the drone's height over the water in meters
  #' @param pixel.length the object's length in pixels
  
  GSD <- (px.dimension * altitude)/focal.length
  length.m <- GSD * pixel.length
  return(length.m)
}


pixel.dimension <- function(image.width, sensor.width){
  sensor.width/image.width
}

# try with desk measurements:
# Desk trial:
true.length.a = 30.48
distance.a = 355.9175
image.width = 3840
pixel.length.a = 260

length.morphometrix(altitude = 355.9175, pixel.length = 260)


morpho.length.alpha <- function(alpha = 1.2646, image.width, altitude, length.pixels){
  length = (alpha/image.width) * altitude * length.pixels
}


true.length.c = 217.17
distance.c = 799.1475
image.width = 1920
pixel.length.c = 415.75

morphometrix(altitude = 799.1475, pixel.length = 415.75, image.width = 1920)

