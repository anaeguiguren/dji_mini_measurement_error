#Read In Measurements from Morphometrix


getMorphoMetrix  <- function(ROOTfolderpath){
  require(dbplyr); require(dplyr)
#' @title compMorphometrix
#' @description compile the csv outputs from Morphometrix folder 
#' @param ROOTfolderpath 	a character vector of full path names to the folder where the csv outputs are located  


  #remove / from ROOTFfolderpath
  if (substring(ROOTfolderpath, nchar(ROOTfolderpath), nchar(ROOTfolderpath)) == 
     "/") {
   ROOTfolderpath = substring(ROOTfolderpath, 1, nchar(ROOTfolderpath) - 
                               1)
  }

  #folder not found
  if(isFALSE(dir.exists(ROOTfolderpath)))
    stop(paste(ROOTfolderpath, "doesn't exist", sep = ""))

  #get list of files
   tmp.files <- list.files(path = ROOTfolderpath, pattern = "*.csv", 
                        full.names = TRUE, recursive = TRUE)
   
   #make empty data table to populate
   #empty flightlog
   morpho.output <- data.frame(imagePath = character(), 
                               videoFile = character(),
                               timeStamp = numeric(),
                               altitude = numeric(),
                               pixelDimension = numeric(),
                               object = character(),
                               length = numeric(),
                               notes = character()
                               )
   
   # go through all files
   for (i in seq_along(tmp.files)){
     
     #prints progress bar
     cat(paste("\r", round(100 * (i/length(tmp.files)), 1), 
               "% processing, file", i, ":", (tmp.files[i])))
     
     #read in each file
     
     a <- t(read.csv(tmp.files[i], header = F))
     tmp.table <- data.frame(imagePath = a[2,2], 
                             videoFile =  paste(gsub('\\..*', "",basename(a[2,2])), ".MP4", sep = ""),
                             timeStamp = gsub("_",":",substr(basename(a[2,2]), 17, 21)),
                             altitude = as.numeric(a[2,4]),
                             pixelDimension = a[2,5],
                             length = as.numeric(a[2,9]),
                             notes = a[2,6]
     )
   
     morpho.output <- rbind(morpho.output, tmp.table)

   }
   return(morpho.output)
   
}
