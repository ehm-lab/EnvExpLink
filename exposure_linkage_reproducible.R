################################################################################
# FOR EXPOSURE LINKAGE REPRODUCIBLE EXAMPLE
################################################################################

librarian::shelf(terra, raster, sf, mapview, plainview)

# SET-UP

set.seed(711492711)

# for one year set start=end equal
year_end <- 2019
year_start <- 2017
seq_years <- c(year_start:year_end)

rasterpaths <- unique(paste0("V:/VolumeQ/AGteam/ST-UK-22/RESULTS/netcdf_maps/pm25_",seq_years,".nc"))

city_list <- list(Southhampton=c(442110, 113640), Newcastle=c(424861,564428), 
                  Grantchester=c(543024,255730), Nottingham = c(457119,340206),
                  Bloomsbury=c(530049,181879), Liverpool=c(335052,390728), 
                  Solihull = c(415228,279440), Glasgow=c(260107,665646))

#####
# FUNCTIONS

# make area of interest object
aoi_square <- function(xy, crscode=27700, buffer_size) {
  
  # create point - add appropriate CRS - set to class sf
  point <- st_point(x=xy) %>% st_sfc(crs=crscode) %>% st_sf(geometry=.)
  
  # create square buffer as polygon
  square_buffer <- st_buffer(point, dist = buffer_size, endCapStyle = "SQUARE")
  
}

# crop and select a few days for plotting
crop_to_aoi <- function(rpath, aoi, ndays) {
  
  r <- rast(rpath, lyrs=runif(ndays,1,365*length(rpath)))

  raoi <- terra::crop(r, aoi)

}

plot_aoi <- function(xy, crscode, buffer_size, rpath, ndays) {
  
  # create square around city point
  aoi <- aoi_square(xy,crscode, buffer_size)
  
  raoi <- crop_to_aoi(rpath, aoi, ndays)
  
  # plot random day(s) on leaflet
  if (nlyr(raoi)==1) {rr<-raster(raoi)} else {rr<-stack(raoi)}
  
  mapview(rr, alpha=0.5)
  
}

#####
# RASTER DIM to SAVED SIZE TESTS (DATA FOLDER)

r <- rast(rasterpaths)

# length of side in kms
sizes <- seq(10, 50, 10)

for (size in sizes) {
  
  buf_siz <- (size/2) * 1000
  
  aoi <- aoi_square(xy=city_list$Bloomsbury, buffer_size = buf_siz)

  raoi <- terra::crop(r, aoi)

  writeCDF(raoi, 
           filename = paste0("data/test_years_size_",length(seq_years),"_",size,".nc"),
           overwrite = TRUE)
  
}

#####
# PLOT SOME CITIES TO CHOOSE AREA

names(city_list)

# make list of html plots
cities_mapviews <- lapply(
  city_list, function(x){
    # uses large buffer size to get a view of the surroundings
    plot_aoi(xy = x, ndays = 2, buffer_size = 30000, crscode = 27700, rpath = rasterpaths)
    })

# view by calling e.g
# cities_mapviews$Grantchester

# save mapviews
lapply(seq(cities_mapviews), function(x){mapshot(cities_mapviews[[x]], url=paste0("mapviews/",names(cities_mapviews)[x],".html"))})


# #####
# # GENERATE RANDOM POINTS IN AN AREA
# 
# npts = 100
# 
# # different sampling schemes
# random_points <- st_sample(aoi, size = npts, type = "random") %>% st_sf(geometry = .)
# hex_points <- st_sample(aoi, size = npts, type = "hexagonal") %>% st_sf(geometry = .)
# reg_points <- st_sample(aoi, size = npts, type = "regular") %>% st_sf(geometry = .)
# 
# plot(st_geometry(aoi), col = 'lightblue')
# plot(st_geometry(reg_points), add = TRUE, col = 'blue', pch = 10)
# plot(st_geometry(random_points), add = TRUE, col = 'red', pch = 10)
# plot(st_geometry(hex_points), add = TRUE, col = 'green', pch = 10)

#####
# GENERATE SEQ OF UP TO um POINTS IN AREA FOR EACH OF n IDS

# number of study units/participants
n <- 10

# upper limit of moves
um <- 6

# define area
aoi <- aoi_square(xy=city_list$Grantchester, buffer_size = 15000)

adrss <- lapply(1:n, function(x){
  
  # sample between 1 and um points within area
  samp <- st_sample(aoi, size = round(runif(1,1,um)))
  
  # re-structure spatial data 
  df_coords <- as.data.frame(st_coordinates(samp))
  
  # add same ID to each sequence of moves
  df_coords$ID <- x
  
  return(df_coords)
  
})

ids_adrss <- data.table::rbindlist(adrss)

#####
# ADD DATES TO EACH MOVE - ORDER BY ID, DATE, SAVE 

# generate a sequence of dates
start_date <- as.Date(paste0(year_start,"-01-01"))
end_date <- as.Date(paste0(year_end,"-12-31"))
date_seq <- seq.Date(start_date, end_date, by="day")

# add dates to ids_adrss
ids_adrss$date <- sample(date_seq, nrow(ids_adrss), replace = TRUE)

# arrange the data by ID and Date
ids_adrss <- ids_adrss[order(ids_adrss$ID, ids_adrss$date)]

# display the data
print(ids_adrss)

# save the dataframe to a CSV file
saveRDS(ids_adrss, "data/ids_adrss_with_dates.RDS")

# (?) ->

#####
# EXPAND IDS_ADRSS TO DAILY SERIES

#####
# EXTRACT EXPOSURE FROM RASTER

#####
# REDUCE TO EXPOSURE SERIES OF INTEREST

