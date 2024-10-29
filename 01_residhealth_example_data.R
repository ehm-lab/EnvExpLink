################################################################################
# FOR EXPOSURE LINKAGE REPRODUCIBLE EXAMPLE
# RESID + HEALTH DATA SETTING
################################################################################

library(data.table)
library(terra)

# COHORT INFO
cohortinfo <- data.frame(
  id = 1:3,
  enroldate = as.Date(c("03/02/2017", "06/04/2018",
                        "25/01/2017"),format ="%d/%m/%Y"),
  endfpdate = as.Date(c("03/10/2018", "16/12/2019",
                        "17/09/2019"),format ="%d/%m/%Y")
)

# RESIDENTIAL HISTORY
residhist <- data.frame(
  id=c(1,1,1,
       2,2,
       3,3,3),
  location=c("Loc_1","Loc_13","Loc_20",
          "Loc_22","Loc_5",
          "Loc_16","Loc_25","Loc_69"),
  startdate=as.Date(c("09/04/2015","12/04/2018","20/02/2019",
                      "30/01/2017","26/06/2018",
                      "27/10/2017","29/01/2018","30/04/2019"),format ="%d/%m/%Y"),
  enddate=as.Date(c("11/04/2018","19/02/2019","24/08/2019",
                    "25/06/2018","11/09/2018",
                    "28/02/2018","29/04/2019","13/05/2021"),format ="%d/%m/%Y"),
  easting=c(440880,432526,457847,
            432711,466497,
            467947,455179,449773),
  northing=c(114243,094510,092484,
             087311,101544,
             110476, 101645, 105656)
)

# OUTCOMES
outcomes<-data.frame(
  id = c(1,2,2,2,3),
  icd = c("E11", "J45","J45","J41","I20"),
  date = as.Date(c("10/09/2017", "01/07/2018",
                   "16/10/2018","03/11/2019",
                   "27/04/2019"),format ="%d/%m/%Y")
)

# Check if "data" directory exists; if not, create it
if (!dir.exists("data")) dir.create("data")

# Write CSV files
write.csv(cohortinfo, "data/cohortinfo.csv", row.names = FALSE)
write.csv(residhist, "data/residhist.csv", row.names = FALSE)
write.csv(outcomes, "data/outhosp.csv", row.names = FALSE)

