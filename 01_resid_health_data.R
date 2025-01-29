################################################################################
# R code example accompanying:
#
#  Vanoli J, et al. Reconstructing individual-level exposures in cohort analyses 
#    of environmental risks: an example with the UK Biobank. J Expo Sci Environ 
#    Epidemiol. 2024 Jan 8.
#  https://www.nature.com/articles/s41370-023-00635-w
################################################################################

################################################################################
# PREPARE RESIDENTIAL HISTORY AND COHORT INFO DATA
################################################################################

# COHORT INFO
cohortinfo <- data.frame(
  id = c("a","b","c"),
  enroldate = as.Date(c("03/02/2017", "06/04/2018", "25/01/2017"),
    format ="%d/%m/%Y"),
  endfpdate = as.Date(c("03/10/2018", "16/12/2019", "17/09/2019"),
    format ="%d/%m/%Y")
)

# RESIDENTIAL HISTORY
residhist <- data.frame(
  id=rep(letters[1:3], c(3,2,3)),
  location=c(1:8),
  startdate=as.Date(
    c("09/04/2015","12/04/2018","20/02/2019",
    "30/01/2017","26/06/2018",
    "27/10/2017","29/01/2018","30/04/2019"),
    format ="%d/%m/%Y"),
  enddate=as.Date(
    c("11/04/2018","19/02/2019","24/08/2019",
      "25/06/2018","11/09/2018",
      "28/02/2018","29/04/2019","13/05/2021"),
    format ="%d/%m/%Y"),
  easting=c(440880,432526,457847,
    432711,466497,
    467947,455179,449773),
  northing=c(114243,094510,092484,
    087311,101544,
    110476,101645,105656)
)
residhist$idloc <- paste0(residhist$id, c(1:3,1:2,1:3))

# SAVE AND REMOVE
write.csv(cohortinfo, "data/cohortinfo.csv", row.names = FALSE)
write.csv(residhist, "data/residhist.csv", row.names = FALSE)
rm(cohortinfo, residhist)
