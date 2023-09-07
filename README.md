## Callibration data

This Dataset has 426 images of balaena taken during different flights
and dates. -altitudeRaw: the altitude indicated by DJI (zeroed at
takeoff). -imageWidth: picture’s width in pixels (1920 or 3840)
-pixel.length: Balaena’s length in pixels -position: whether Balaena was
in the center of the frame (pos\_c) or closer to the edges (pos\_o)

    summary(dat)

    ##      Date              FlightNo    imageName          timeStamp        
    ##  Length:426         105    : 19   Length:426         Length:426        
    ##  Class :character   203    : 15   Class :character   Class :character  
    ##  Mode  :character   219    : 12   Mode  :character   Mode  :character  
    ##                     222    : 12                                        
    ##                     218    : 11                                        
    ##                     212    : 10                                        
    ##                     (Other):347                                        
    ##   altitudeRaw       imageWidth    pixel.length     position  
    ##  Min.   : 23.60   Min.   :1920   Min.   : 104.4   pos_c:241  
    ##  1st Qu.: 30.80   1st Qu.:1920   1st Qu.: 325.0   pos_o:185  
    ##  Median : 44.40   Median :3840   Median : 678.7              
    ##  Mean   : 56.59   Mean   :3335   Mean   : 683.9              
    ##  3rd Qu.: 69.60   3rd Qu.:3840   3rd Qu.:1050.2              
    ##  Max.   :155.30   Max.   :3840   Max.   :1281.0              
    ## 

## Including Plots

You can also embed plots, for example:

![](Readme_files/figure-markdown_strict/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to
prevent printing of the R code that generated the plot.
