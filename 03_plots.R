################################################################################
# R code example accompanying:
#
#  Vanoli J, et al. Reconstructing individual-level exposures in cohort analyses 
#    of environmental risks: an example with the UK Biobank. J Expo Sci Environ 
#    Epidemiol. 2024 Jan 8.
#  https://www.nature.com/articles/s41370-023-00635-w
################################################################################

################################################################################
# PLOT TO VISUALISE PARTICIPANT MOVES AND EXPOSURE SERIES
################################################################################

# LOAD PACKAGES
# install.packages("librarian")
librarian::shelf(
  sf , mapgl, terra, dplyr, tidyr, ggplot2, ggh4x, lubridate
)

# LOAD ADDRESS/LOCATION DATA MAKE INTO SPATIAL FEATURES
reshist <- read.csv("data/residhist.csv", 
  colClasses = c("character","character","Date","Date","integer","integer")) |>
  st_as_sf(coords=c("easting","northing"), crs=27700) |> 
  st_transform(4326)

# MAP ID RESIDENCES
all_points <- maplibre(center=c(-1.26,50.78), zoom=9) |>
  add_circle_layer(
    "reslocs",
    source=reshist,
    circle_radius=9,
    circle_color="white",
    circle_stroke_color=match_expr(
      column="id",
      values=c("a","b","c"),
      stops=c("#ff0000","#00ff00","#0000ff"),
      default="#cccccc"
    ),
    circle_stroke_width=2
  ) |>
  add_symbol_layer(
    id="idloc",
    source=reshist,
    text_color="black",
    text_opacity=1,
    text_size = 12,
    text_field=get_column("idloc")
  )

# MAP AND EXPOSURE SERIES FOR ID "a" 
ida_locs <- reshist[reshist$id=="a",]
locs_a <- maplibre(center=c(-1.26,50.78), zoom=9) |>
  add_circle_layer(
    "reslocs",
    source=ida_locs,
    circle_radius=9,
    circle_color="white",
    circle_stroke_color=match_expr(
      column="idloc",
      values=c("a1","a2","a3"),
      # stops=c("pink","lightgreen","lightblue"),
      stops=c("#FFA500","#8000FF","#00D7D7"),
      default="#cccccc"
    ),
    circle_stroke_width=2
  ) |>
  add_symbol_layer(
    id="idloc",
    source=ida_locs,
    text_color="black",
    text_opacity=1,
    text_size = 12,
    text_field=get_column("idloc")
  )

# EXTRACT VALUES AT ALL LOCATIONS 
get_PM_data <- function(year, locs) {
  file <- paste0("data/pm25_area_", year, ".nc")
  r <- rast(file)
  # match projections
  if (!st_crs(locs)==st_crs(r)) {locs<-st_transform(locs,st_crs(r))}
  xtr <- terra::extract(r, locs)
  ts <- xtr |> 
    pivot_longer(cols=-ID) |>
    rename(location=ID, value=value) |>
    mutate(year=year)
}
ida_extracted <- lapply(2017:2019, get_PM_data, locs=ida_locs) |>  bind_rows()

# OBJECTS FOR PLOTS AND PLOT THEMING 
dates <- seq(as.Date("2017-01-01"), as.Date("2019-12-31"), by="day")

# PM SERIES AT ALL ID A LOCATIONS
ida_full <- ida_extracted |>
  group_by(location) |>
  mutate(
    date=dates, 
    location_label=paste0("Loc. ", location)
  ) |>
  ungroup()

# shading and facet labels
residence_periods <- ida_locs |>
  select(xmin=startdate, xmax=enddate, location) |>
  mutate(
    xmin=c(as.Date("2017-01-01"), xmin[-1]),
    location_label=paste0("Loc. ", location)
  )
strip_custom <- strip_themed(
  background_x = list(element_rect(fill = "#FFA500"),
    element_rect(fill = "#8000FF"),
    element_rect(fill = "#00D7D7")),
  text_x = element_text(size = 12, face = "bold", color = "black")
)

locs_a_ts <- ggplot() +
  geom_rect(
    data=residence_periods,
    aes(xmin=xmin, xmax=xmax, ymin=-Inf, ymax=Inf, group=location_label),
    fill="lightgrey", alpha=0.5, inherit.aes=FALSE
  ) +
  geom_line(
    data=ida_full,
    aes(x=date, y=value),
    inherit.aes=FALSE
  ) +
  facet_wrap2(~location_label, dir="v", strip=strip_custom) +
  theme_bw() +
  labs(
    x = "Date",
    y = expression(PM[2.5]  (~ mu*g/m^3))
  )

# ID A PM EXPOSURE SERIES
ida_exp <- ida_full %>%
  filter(
    (location_label == "Loc. 1" & date <= "2018-04-11") |
      (location_label == "Loc. 2" & date > "2018-04-11" & date <= "2019-02-19") |
      (location_label == "Loc. 3" & date > "2019-02-19" & date <= "2019-08-24")
  )

a_exps <- ggplot() +
  geom_rect(
    data=residence_periods,
    aes(xmin=xmin, xmax=xmax, ymin=-Inf, ymax=Inf, fill=location_label),
    alpha=0.5
  ) +
  geom_line(
    data=ida_exp,
    aes(x=date, y=value),
    color="black"
  ) +
  scale_fill_manual(values=c(
    "Loc. 1"="#FFA500",
    "Loc. 2"="#8000FF",
    "Loc. 3"="#00D7D7"
  )) +
  theme_bw() +
  labs(
    x = "Date",
    y = expression(PM[2.5]  (~ mu*g/m^3))
  )

# OUTPUTS

# MAP OF ID LOCATIONS (opens in viewer)
all_points

# MAP OF LOCATIONS FOR ID A (opens in viewer)
locs_a

# FULL PM SERIES AT ALL ID A RESIDENCES
locs_a_ts

# COMBINED ID A EXPOSURE SERIES
a_exps
