################################################################################
# FOR EXPOSURE LINKAGE REPRODUCIBLE EXAMPLE
# RASTER DATA SETTING
################################################################################
#
# CROP Southampton + Portsmouth + Isle of Wight area around 
centr <- c(450000, 096500)

source("reprex_building_functions.R")

set.seed(711492711)

# for one year set start=end equal
year_end <- 2019
year_start <- 2017
seq_years <- c(year_start:year_end)

rasterpaths <- unique(paste0("V:/VolumeQ/AGteam/ST-UK-22/RESULTS/netcdf_maps/pm25_",seq_years,".nc"))

centr <- c(450000, 096500)

buffer_size <- 20000

area <- aoi_square(centr, 27700, buffer_size)

for (i in seq(seq_years)) {
  r <- terra::rast(rasterpaths[i])
  raoi <- terra::crop(r,area)
  
  # Check if "data" directory exists; if not, create it
  if (!dir.exists("data")) dir.create("data")
  
  writeCDF(raoi, paste0("data/pm25_area_",seq_years[i],".nc"))
}

# # visualize the area that is saved above
plot_aoi(centr, crscode = 27700, buffer_size, rasterpaths[1],ndays = 1)


