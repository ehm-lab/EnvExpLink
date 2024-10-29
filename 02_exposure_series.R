################################################################################
# MAIN SCRIPT
################################################################################

# LOAD PACKAGES
library(data.table); library(terra)

################################################################################
# DEFINE THE EXPOSURES AND THE LOCATIONS OF THE (POTENTIAL) DATA

# DEFINE PERIOD AS YEARS
seqyear <- 2017:2019

# EXPOSURE SEQUENCE AND LIST OF PATHS
exp <- "pm25"
pathexp <- list.files("data", full.names = T, pattern=".nc")

# DIGITS FOR THE ROUNDING (EQUAL FOR ALL THE EXPOSURES)
digit <- 1

# OUTPUT PATH
outdir <- "output"

################################################################################
# CREATE THE LOCATION DATA WITH RESIDENTIAL HISTORY 

# LOAD ADDRESS/LOCATION DATA
locdata <- read.csv("data/residhist.csv", 
                    colClasses = c("integer","character","Date","Date","integer","integer"))

# FUNCTION TO DEFINE THE LOCATION SERIES FOR A GIVEN PERIOD
# NB: .bincode IS THE BARE-BONES VERSION OF cut
# - period IS THE FULL PERIOD (E.G., A YEAR)
# - dates ARE THE STARTING DATES A SUBJECT STARTS LIVING AT AN ADDRESS
# - loc IS THE CORRESPONDING ADDRESS ID
# - maxdate  IS THE RIGHT BOUNDARY (USUALLY SET HIGH TO INCLUDE THE WHOLE PERIOD)
floc <- function(period, dates, loc, maxdate=as.Date("2099-12-31")) {
  loc[.bincode(period, c(dates, maxdate), right=F)]
}

################################################################################
# LOOP BY YEAR

# STORE RESULTS
outlist <- list()

for (i in seq(seqyear)) {
  
  # DEFINE THE PERIOD
  period <- seq(as.Date(paste0("01/01/",seqyear[i]),format ="%d/%m/%Y"),
                as.Date(paste0("31/12/", seqyear[i]),format ="%d/%m/%Y"), "day")
  
  subdata <- setDT(locdata)
  subdata$locid <- seq(nrow(subdata))
  
  # EXPAND THE DATA
  data <- subdata[, list(date=period, locid=floc(period, startdate, locid)), by=id]
  
  # LOAD RASTER, EXTRACT, AND CREATE (ROUNDED) SERIES
  rst <- rast(pathexp[i])
  
  matexp <- extract(rst, subdata[,c("easting", "northing")], method='bilinear',
                    ID=FALSE)
  
  matind <- cbind(data$locid, seq(ncol(matexp)))
  
  data[[exp]] <- round(matexp[matind], digit)
  
  outlist <- append(outlist,list(data))
  
}

exp_series <- rbindlist(outlist)

if (!dir.exists("output")) dir.create("output")

write.csv(exp_series,"output/exposure_series.csv",row.names = FALSE)

rm(i, outlist, exp, pathexp, digit, outdir, period, subdata, data, matexp, matind)