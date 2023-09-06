# Set working directory---
setwd("/Users/anacristinaeguigurenburneo/Documents/DJI_Mini2_Measurement_Error/")


source("Scripts/Gal23_DroneMeasurementError_DataPrep.R")


# 1. Extract pixel length given the measurements used in morphometrix----

# make a function:
px.length <- function(l.m, p.d, f.l = 4.25531, a.m){
  (l.m/p.d)*(f.l/a.m)
  
}

#calculate pixel length:
dat$pixel.length <- px.length(l.m=dat$length, 
                              p.d = dat$pixelDimension.old, 
                              a.m = dat$altitude)




# fix pixel dimensions:
dat$pixelDimension<-NA

dat$pixelDimension <- 6.3/dat$ImageWidth


#2. Re-estimate length ----

morpho.length.alpha <- function(alpha = 1.2646,image.width, altitude, length.pixels){
  length = (alpha/image.width) * altitude * length.pixels
}

#recalculate Balaena's length in m, with new altitude 
boat.height = 1.03# balaena's altitude over the water

launch.chest = 1.4 - 0.24 # Mateo's chest height
camera.height = 0.045 # cameras distance from legs

dat$altitude.fix <- dat$altitude + launch.chest + camera.height




dat$length.fix <- morpho.length.alpha(altitude = dat$altitude.fix,
                                      image.width = dat$ImageWidth,
                                      length.pixels = dat$pixel.length)


hist(dat$length.fix, breaks = 200)
mean(dat$length.fix)
sd(dat$length.fix)


# 3. Describe and model measurement error -----
balaena.length <- 12.03



dat$length.error <- (dat$length.fix -  balaena.length)

d <- data.frame(length = balaena.length,
                length.error = dat$length.error, 
                length.error.abs = abs(dat$length.error),
                altitude = dat$altitude.fix, 
                angle = dat$balaenaAngled, 
                position = dat$pos, 
                flightNo = dat$FlightNo, 
                date = dat$Date)


# ~~~ a. overall error ----
#total
quantile(d$length.error, probs= c(0.05, 0.5, 0.95))
mean(d$length.error) 
sd(d$length.error)


# absolute

quantile(d$length.error.abs, probs= c(0.05, 0.5, 0.95))
mean(d$length.error.abs) 
sd(d$length.error.abs)


# ~~~ b. error as a function of altitude ----
#total error

ggplot(data = d,aes(x = altitude, y = length.error))+
  geom_point(alpha = 0.5, col = "darkcyan")+
  geom_smooth(method = "lm", color = "black")+
  xlab("altitude (m)") + ylab("total error (m)")+
  theme_classic()

m.tot <- (lm(length.error~altitude, data=d))
summary(m.tot)
confint(m.tot, 'altitude',level = 0.90)

# absolute error

ggplot(data = d,aes(x = altitude, y = length.error.abs))+
  geom_point(alpha = 0.5, col = "darkcyan")+
  geom_smooth(method = "lm", color = "black")+
  xlab("altitude (m)") + ylab("total error (m)")+
  theme_classic()

m.abs <- (lm(length.error.abs~altitude, data=d))
summary(m.abs)
confint(m.abs, 'altitude',level = 0.90)

# ~~~c. error as a function of the position of the boat on the frame ----
m.pos.tot <- (lm(length.error~position, data=d))
summary(m.pos.tot)
confint(m.pos.tot, 'positionpos_o',level = 0.90)


m.pos.abs <- (lm(length.error.abs~position, data=d))
summary(m.pos.abs)
confint(m.pos.abs, 'positionpos_o',level = 0.90)

# ~~~~d. hierarchical approach by flight ----
library(nlme)

# total error:
m.int <- gls(length.error~ 1, data = d, method = "ML")
summary(m.int) #588.87
intervals(m.int, level = 0.9)


# model random intercept :
m.rand <- lme(length.error ~ 1, data = d, method = "ML",
              random = ~1|flightNo)
summary(m.rand) #522.48
intervals(m.rand, level = 0.9)

# add altitude:
m.rand.alt <- lme(length.error ~ altitude, data = d, method = "ML",
              random = ~1|flightNo)
anova(m.rand, m.rand.alt)# does not help!
summary(m.rand.alt)
intervals(m.rand.alt, level = 0.9)


# boat position:
m.rand.pos <- lme(length.error ~ position , data = d, method = "ML",
                  random = ~1|flightNo)
anova(m.rand, m.rand.pos)
intervals(m.rand.pos, level = 0.9)



summary(m.rand.pos)
anova(m.rand, m.rand.pos)

m.rand.pos.alt <- lme(length.error ~ position +altitude , data = d, method = "ML",
                  random = ~1|flightNo)



ggplot(d, aes(x = position, y = length.error))+
  geom_boxplot()+
  scale_fill_viridis(discrete = TRUE, alpha=0.6)+
  geom_jitter(color = "black", size = 1, alpha = 0.6)+
  theme_classic()






# absolute error:-----


m.int.abs <- gls(length.error.abs~ 1, data = d, method = "ML")
summary(m.int.abs) 
intervals(m.int.abs, level = 0.9)


# model random intercept :
m.rand.abs <- lme(length.error.abs ~ 1, data = d, method = "ML",
              random = ~1|flightNo)
summary(m.rand.abs) 
intervals(m.rand.abs, level = 0.9)
anova(m.int.abs, m.rand.abs)

# add altitude:
m.rand.alt.abs <- lme(length.error.abs ~ altitude, data = d, method = "ML",
                  random = ~1|flightNo)
anova(m.rand.abs, m.rand.alt.abs)# does not help!
summary(m.rand.alt.abs)
intervals(m.rand.alt.abs, level = 0.9)


# boat position:
m.rand.pos.abs <- lme(length.error.abs ~ position, data = d, method = "ML",
                  random = ~1|flightNo)
anova(m.rand.abs, m.rand.pos.abs)# does not help!
intervals(m.rand.pos, level = 0.9)

summary(m.rand.pos)
anova(m.rand, m.rand.pos)


ggplot(d, aes(x = position, y = length.error))+
  geom_boxplot()+
  scale_fill_viridis(discrete = TRUE, alpha=0.6)+
  geom_jitter(color = "black", size = 1, alpha = 0.6)+
  theme_classic()
 

# graphical representation:
library(viridis)
ggplot(d, aes(x = flightNo, y = length.error.abs, fill = date))+
  geom_boxplot()+
  scale_fill_viridis(discrete = TRUE, alpha=0.6)+
  geom_jitter(color = "black", size = 0.4, alpha = 0.6)
  theme(axis.text.x=element_text(angle = 90, size = 5))


ggplot(d, aes(x = flightNo, y = length.error, fill = date))+
    geom_boxplot()+
    scale_fill_viridis(discrete = TRUE, alpha=0.6)+
    geom_jitter(color = "black", size = 0.4, alpha = 0.6)
    theme(axis.text.x=element_text(angle = 90, size = 5))

    
ggplot(d, aes(x = flightNo, y = altitude, fill = date))+
      geom_boxplot()+
      scale_fill_viridis(discrete = TRUE, alpha=0.6)+
      geom_jitter(color = "black", size = 0.4, alpha = 0.6)+
    theme(axis.text.x=element_text(angle = 90, size = 5))
    


#~~~~e. last rabbit hole: ----
#does range of altitude within flight correlate with
# range of error?----

# Is the range of error in each flight related to the range of altitudes?
flight.sum<-d %>% group_by(flightNo) %>%
  summarise(min_altitude = min(altitude),
            max_altitude = max(altitude), 
            min_error = min(length.error), max_error = max(length.error),
            min_abs_error = min(length.error.abs), max_abs_error = max(length.error.abs))



flight.sum$altitude_range = flight.sum$max_altitude - flight.sum$min_altitude
flight.sum$error_range = flight.sum$max_error - flight.sum$min_error
flight.sum$abs_error_range = flight.sum$max_abs_error - flight.sum$min_abs_error


# total error:
ggplot(data = flight.sum,aes(x = altitude_range, y = error_range))+
  geom_point(alpha = 0.5, col = "darkcyan")+
  geom_smooth(method = "lm", color = "black")+
  xlab("altitude range") + ylab("error range")+
  theme_classic()

m.err.rang <- (lm(error_range~altitude_range, data=flight.sum))
summary(m.err.rang)
confint(m.err.rang, 'altitude_range',level = 0.90)


# absolute error:
ggplot(data = flight.sum,aes(x = altitude_range, y = abs_error_range))+
  geom_point(alpha = 0.5, col = "darkcyan")+
  geom_smooth(method = "lm", color = "black")+
  xlab("altitude range") + ylab("absolute error range")+
  theme_classic()

m.abs.err.rang <- (lm(abs_error_range~altitude_range, data=flight.sum))
summary(m.abs.err.rang)
confint(m.abs.err.rang, 'altitude_range',level = 0.90)
#yes! ok 
