## Callibration data

This Dataset has 426 images of Balaena taken during different flights
and dates.

-   altitudeRaw: the altitude indicated by DJI (zeroed at takeoff).

-   imageWidth: picture’s width in pixels (1920 or 3840).

-   pixel.length: Balaena’s length in pixels.

-   position: whether Balaena was in the center of the frame (pos\_c) or
    closer to the edges (pos\_o).

<!-- -->

    head(dat)

    ##         Date FlightNo                          imageName timeStamp altitudeRaw
    ## 1 2023-04-08      198 DJI_0005.MP4_00_00_02_vlc00001.png      0:02        50.4
    ## 2 2023-04-08      198 DJI_0005.MP4_00_00_04_vlc00002.png      0:04        49.7
    ## 3 2023-04-08      199 DJI_0006.MP4_00_03_03_vlc00001.png      3:03       119.4
    ## 4 2023-04-08      199 DJI_0006.MP4_00_03_11_vlc00002.png      3:11       120.1
    ## 5 2023-04-08      199 DJI_0006.MP4_00_03_14_vlc00003.png      3:14       120.3
    ## 6 2023-04-08      199 DJI_0006.MP4_00_03_16_vlc00004.png      3:16       119.7
    ##   imageWidth pixel.length position
    ## 1       3840     654.6037    pos_c
    ## 2       3840     672.1734    pos_c
    ## 3       3840     282.6148    pos_o
    ## 4       3840     282.4793    pos_o
    ## 5       3840     283.7345    pos_o
    ## 6       3840     287.1069    pos_o

## Correct initial altitude

The drone altitude is zeroed the moment the rotors start, which means
that the true altitude needs to add the distance from the drone’s launch
point to the water:

<figure>
<img src="Graphical/altitude_diagram.jpeg"
alt="depiction of how the true altitude from the water line is calculated" />
<figcaption aria-hidden="true">depiction of how the true altitude from
the water line is calculated</figcaption>
</figure>

*Note that, in Balaena’s case, the altitude we want is the distance from
the drone to the boat, so we can omit the boat height in the calculation
as follows:*

    #recalculate Balaena's length in m, with new altitude 
    boat.height = 1.03- 0.24# balaena's altitude over the water - toe rail

    launch.chest = 1.4 # Mateo's chest height
    camera.height = 0.045 # cameras distance above the base of the drone's legsfrom legs

    dat$altitude.fix <- dat$altitude + launch.chest + camera.height
    head(dat)

    ##         Date FlightNo                          imageName timeStamp altitudeRaw
    ## 1 2023-04-08      198 DJI_0005.MP4_00_00_02_vlc00001.png      0:02        50.4
    ## 2 2023-04-08      198 DJI_0005.MP4_00_00_04_vlc00002.png      0:04        49.7
    ## 3 2023-04-08      199 DJI_0006.MP4_00_03_03_vlc00001.png      3:03       119.4
    ## 4 2023-04-08      199 DJI_0006.MP4_00_03_11_vlc00002.png      3:11       120.1
    ## 5 2023-04-08      199 DJI_0006.MP4_00_03_14_vlc00003.png      3:14       120.3
    ## 6 2023-04-08      199 DJI_0006.MP4_00_03_16_vlc00004.png      3:16       119.7
    ##   imageWidth pixel.length position altitude.fix
    ## 1       3840     654.6037    pos_c       51.845
    ## 2       3840     672.1734    pos_c       51.145
    ## 3       3840     282.6148    pos_o      120.845
    ## 4       3840     282.4793    pos_o      121.545
    ## 5       3840     283.7345    pos_o      121.745
    ## 6       3840     287.1069    pos_o      121.145

Next, we use the following formula to calculate Balaena’s length
according to the drone’s data: length = (alpha/image.width) \* altitude
\* length.pixels

$$
length = \frac{alpha}{image.width}  \times true.altitude \times pixel.length 
$$

Where *alpha* is the camera’s correction factor, estimated in the lab by
measuring objects of known length and distance. This equation is
reflected in the following function:

    morpho.length.alpha <- function(alpha = 1.2646,image.width, altitude, length.pixels){
      length = (alpha/image.width) * altitude * length.pixels
    }

This results in the following estimated length for Balaena:

    dat$bal.length<- morpho.length.alpha(altitude = dat$altitude.fix,
                                          image.width = dat$imageWidth,
                                          length.pixels = dat$pixel.length)
    summary(dat$bal.length)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   9.457  11.212  11.493  11.458  11.754  12.966

    hist(dat$bal.length, breaks = 20, xlab = "estimated length of Balaena (m)", main = "")
    abline(v = 12.03, col = 2, lwd = 2)

<figure>
<img src="Readme_files/figure-markdown_strict/estimate-1.png"
alt="Histogram of Balaena’s length estimated using the DJI Mini Drone. The red line shows Balaena’s True length" />
<figcaption aria-hidden="true">Histogram of Balaena’s length estimated
using the DJI Mini Drone. The red line shows Balaena’s True
length</figcaption>
</figure>

This means there is an under-estimate of Balaena’s length of mean =
0.57m, and s.d. = 0.45

    dat$error <- dat$bal.length-12.03
    mean(dat$error)

    ## [1] -0.5721738

    sd(dat$error)

    ## [1] 0.4805297

## Questions

-   Am I doing something wrong? (in the formula?)

-   If not, where should the correction factor go - is it a constant
    that I add to the total, or is it specifically for the altitude?

## Altitude experiment:

I suspect that the majority of the error comes from bad altitude
estimates. So I used our knowledge of Balaena’s true length, assumed all
other measurements were adequate, and calculated **true altitude**, and
found that the good altitudes are further away from the measured
altitudes at higher altitudes. For this, I used the formula:

$$
true.altitude = \frac{true.length}{pixel.length}  \times \frac{image.width}{alpha}
$$

    true.altitude <- function(true.length, pixel.length, image.width, alpha){
      t.a = (true.length/pixel.length) * (image.width/alpha)
    }

    dat$true.altitude <- true.altitude(true.length = 12.03, 
                                       pixel.length = dat$pixel.length, 
                                       image.width = dat$imageWidth, 
                                       alpha = 1.2646)

Next, I estimated the altitude error as:

    dat$altitude.err <- dat$true.altitude - dat$altitude.fix
    dat$altitude.err.p <- dat$altitude.err/dat$true.altitude

Which results in the following error distribution:

    hist(dat$altitude.err, breaks = 30, xlab = "altitude error (m)", 
         main = "")
    text(x = 20, y = 80, paste("mean error = ",signif(mean(dat$altitude.err), digits =3)))

    text(x = 20, y = 60, paste("s.d. = ",signif(sd(dat$altitude.err), digits =3)))

![](Readme_files/figure-markdown_strict/unnamed-chunk-8-1.png)

How does this look across altitudes?

    ggplot(dat, aes(x = true.altitude, y = altitude.err))+
      geom_point(alpha = 0.5)+
      theme(legend.position = "none")+ 
      geom_smooth(method = "lm")

    ## `geom_smooth()` using formula = 'y ~ x'

![](Readme_files/figure-markdown_strict/unnamed-chunk-9-1.png)

How does **percent** error compare to altitude?

    ggplot(dat, aes(x = true.altitude, y = altitude.err.p))+
      geom_point(alpha = 0.5)+
      theme(legend.position = "none")+ 
      geom_smooth(method = "lm")

    ## `geom_smooth()` using formula = 'y ~ x'

![](Readme_files/figure-markdown_strict/unnamed-chunk-10-1.png)

Which looks like error is proportional, more than an added constant

    mean(dat$altitude.err.p)

    ## [1] 0.04756224

    quantile(dat$altitude.err.p, probs = c(0.05, 0.95))

    ##           5%          95% 
    ## -0.007102842  0.114652934

So if I add this percent altitude to my correction:

    dat$altitude.corr <-dat$altitude.fix*(1+mean(dat$altitude.err.p))


    dat$bal.length.c<- morpho.length.alpha(altitude =dat$altitude.corr,
                                          image.width = dat$imageWidth,
                                          length.pixels = dat$pixel.length)
    quantile(dat$bal.length.c, probs = c(0.05, 0.5, 0.95))

    ##       5%      50%      95% 
    ## 11.15730 12.03968 12.69169

    hist(dat$bal.length.c, breaks = 30, main = "", xlab = "estimated length")
    abline(v = 12.03, col = 2, lwd = 2)

![](Readme_files/figure-markdown_strict/unnamed-chunk-13-1.png)

Look at error pre & post correction:

    dat$length.error.c <- dat$bal.length.c - 12.03 # corrected error raw
    dat$length.error.c.p <- (dat$length.error.c/dat$bal.length.c)*100

    dat$length.error.p <- (dat$error/dat$bal.length)*100

    e <- c(dat$length.error.c.p,dat$length.error.p)
    d <- data.frame(perc.error = e, error.type = rep(c("corrected", "uncorrected"), each = length(dat$bal.length)))

    ggplot(d, aes(x = error.type, y = perc.error, color = error.type))+
      geom_boxplot()+
        scale_y_continuous(limits=c(-60,60), breaks = seq(-60,60,10))+
      labs(y = "corrected % error", x = "error type")+
      theme(legend.position = "null")+
      geom_hline(yintercept = 0)+
      geom_hline(yintercept = -5, linetype = "dashed")+
      geom_hline(yintercept = 5, linetype = "dashed")

<img src="Readme_files/figure-markdown_strict/fig3-1.png" style="display: block; margin: auto;" />

This looks pretty reasonable!
