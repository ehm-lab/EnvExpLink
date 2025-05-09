################################################################################
# R code example accompanying:
#
#  Vanoli J, et al. Reconstructing individual-level exposures in cohort analyses 
#    of environmental risks: an example with the UK Biobank. J Expo Sci Environ 
#    Epidemiol. 2024 Jan 8.
#  https://www.nature.com/articles/s41370-023-00635-w
################################################################################

################################################################################
# LINK RESIDENTIAL HISTORY AND ENVIRONMENTAL DATA
################################################################################

# LOAD THE PACKAGE
# install.packages("librarian")
librarian::shelf(data.table, terra)

# DEFINE THE EXPOSURE, PERIOD, AND ENV. DATA SOURCE
seqyear <- 2017:2019
exp <- "pm25"
pathexp <- list.files("data", full.names = T, pattern=".nc")

# DIGITS FOR THE ROUNDING (EQUAL FOR ALL THE EXPOSURES)
digit <- 1

# OUTPUT DIRECTORY
outdir <- "output"

# LOAD ADDRESS/LOCATION DATA
locdata <- read.csv("data/residhist.csv", 
  colClasses = c("character","numeric","Date","Date","integer","integer"))

# FUNCTION TO DEFINE THE LOCATION SERIES FOR A GIVEN PERIOD
# NB: .bincode IS THE BARE-BONES VERSION OF cut
# - period IS THE FULL PERIOD (E.G., A YEAR)
# - dates ARE THE STARTING DATES A SUBJECT STARTS LIVING AT AN ADDRESS
# - loc IS THE CORRESPONDING ADDRESS ID
# - maxdate  IS THE RIGHT BOUNDARY (USUALLY SET HIGH TO INCLUDE THE WHOLE PERIOD)
floc <- function(period, dates, loc, maxdate=as.Date("2099-12-31"))
  loc[.bincode(period, c(dates, maxdate), right=F)]

################################################################################
# LOOP BY YEAR

# STORE RESULTS
explist <- vector("list",length=length(seqyear))

# START THE LOOP BY YEAR
for (i in seq(seqyear)) {
  
  # DEFINE THE PERIOD
  period <- seq(as.Date(paste0("01/01/", seqyear[i]), format ="%d/%m/%Y"),
    as.Date(paste0("31/12/", seqyear[i]), format ="%d/%m/%Y"), "day")
  
  # LOAD DATA
  subdata <- setDT(locdata)

  # EXPAND THE DATA
  data <- subdata[, list(date=period, locid=floc(period, startdate, location)),
    by=id]
  
  # LOAD RASTER, EXTRACT VALUES AT RESIDENCES, AND CREATE (ROUNDED) SERIES
  rst <- rast(pathexp[i])
  matexp <- terra::extract(rst, subdata[,c("easting", "northing")], 
    method='bilinear', ID=FALSE)
  matind <- cbind(data$locid, seq(ncol(matexp)))
  data[[exp]] <- round(matexp[matind], digit)
  explist[i] <- list(data)
}

# APPEND
expseries <- rbindlist(explist)

# CREATE OUTPUT FOLDER IF NEEDED
if (!dir.exists("output")) dir.create("output")

# SAVE AND REMOVE
write.csv(expseries, "output/exposure_series.csv", row.names = FALSE)
rm(i, explist, exp, pathexp, digit, outdir, period, subdata, data, matexp, 
  matind, rst, seqyear, floc, expseries, locdata)
