# project packages

librarian::shelf(terra, raster, sf, mapview, plainview)

# project functions

# make area of interest object
# xy in easting/northing if using crs code 27700 for British National Grid system
# buffer in meters
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
