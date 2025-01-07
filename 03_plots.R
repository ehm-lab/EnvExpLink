librarian::shelf(sf, mapgl, terra, dplyr, tidyr, ggplot2, ggh4x, lubridate)

# load residhist object in scirpt 1

# 1. map of all points
reshist <- st_as_sf(residhist, coords=c("easting","northing"), crs=27700) |> 
  st_transform(4326)
reshist$moveord <- c(1,2,3,1,2,1,2,3)

all_points <- maplibre(center=c(-1.26,50.78), zoom=9) |>
  add_circle_layer(
    "reslocs",
    source=reshist,
    circle_radius=9,
    circle_color="white",
    circle_stroke_color=match_expr(
      column="id",
      values=c(1,2,3),
      stops=c("#ff0000","#00ff00","#0000ff"),
      default="#cccccc"
    ),
    circle_stroke_width=3
  ) |>
  add_symbol_layer(
    id="moveord",
    source=reshist,
    text_color="black",
    text_opacity=1,
    text_field=get_column("moveord")
  )

# 2. map for subject 1
id1_locs <- reshist[reshist$id==1,]

subject1 <- maplibre(center=c(-1.26,50.78), zoom=9) |>
  add_circle_layer(
    "reslocs",
    source=id1_locs,
    circle_radius=9,
    circle_color="white",
    circle_stroke_color=match_expr(
      column="moveord",
      values=c(1,2,3),
      stops=c("pink","lightgreen","lightblue"),
      default="#cccccc"
    ),
    circle_stroke_width=3
  ) |>
  add_symbol_layer(
    id="moveord",
    source=id1_locs,
    text_color="black",
    text_opacity=1,
    text_field=get_column("moveord")
  )

# unified extraction for 2017, 2018, 2019
get_ts_data <- function(year, locs) {
  file <- paste0("data/pm25_area_", year, ".nc")
  terra::extract(rast(file), locs) |>
    pivot_longer(cols=-ID) |>
    rename(location=ID, value=value, raw_date=name) |>
    mutate(year=year)
}

id1_extracted <- lapply(2017:2019, get_ts_data, locs=id1_locs) |> bind_rows()

# 3.

# 4. combined ts (2017-01-01 through 2019-12-31)
# unify real dates
dates <- seq(as.Date("2017-01-01"), as.Date("2019-12-31"), by="day")
datens <- seq(1:length(dates)*3)

id1_full <- id1_extracted |>
  arrange(location, year, raw_date) |>
  group_by(location) |>
  mutate(
    date=dates, 
    location_label=paste0("loc. ", location)
  ) |>
  ungroup()

shading2 <- id1_locs |>
  select(xmin=startdate, xmax=enddate, location=moveord) |>
  mutate(
    xmin=c(as.Date("2017-01-01"), xmin[-1]),
    location_label=c("loc. 1","loc. 2","loc. 3")
  )
stripbckgs <- list(element_rect(fill = "pink"),element_rect(fill = "lightgreen"),element_rect(fill = "lightblue"))
# can also plot and save separately to compose in a graphic
locs_subj1_year_series <- ggplot() +
  geom_rect(
    data=shading2,
    aes(xmin=xmin, xmax=xmax, ymin=-Inf, ymax=Inf, group=location_label),
    fill="lightgrey", alpha=0.5, inherit.aes=FALSE
  ) +
  geom_line(
    data=id1_full,
    aes(x=date, y=value),
    inherit.aes=FALSE
  ) +
  facet_wrap2(~location_label, dir="v", strip=strip_themed(background_x=stripbckgs)) +
  theme_bw()


# 5. exposure history
id1_exp <- id1_full %>%
  filter(
    (location_label == "loc. 1" & date <= "2018-04-11") |
      (location_label == "loc. 2" & date > "2018-04-11" & date <= "2019-02-19") |
      (location_label == "loc. 3" & date > "2019-02-19" & date <= "2019-08-24")
  )

subj1_exps <- ggplot() +
  geom_rect(
    data=shading2,
    aes(xmin=xmin, xmax=xmax, ymin=-Inf, ymax=Inf, fill=location_label),
    alpha=0.5
  ) +
  geom_line(
    data=id1_exp,
    aes(x=date, y=value),
    color="black"
  ) +
  scale_fill_manual(values=c(
    "loc. 1"="pink",
    "loc. 2"="lightgreen",
    "loc. 3"="lightblue"
  )) +
  theme_bw()


# ouptuts

all_points

subject1

locs_subj1_year_series

subj1_exps