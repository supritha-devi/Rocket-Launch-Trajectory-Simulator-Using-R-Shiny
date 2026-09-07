# ============================================
# global.R
# Shared data: gravity values, locations, coordinates,
# and all calculation/solving functions
# ============================================

library(shiny)

# ---- Gravity values for each planet/body (m/s^2) ----
gravity_values <- list(
  "Mercury" = 3.7, "Venus" = 8.87, "Earth" = 9.8, "Moon" = 1.6,
  "Mars" = 3.71, "Jupiter" = 24.8, "Saturn" = 10.4
)

# ---- Earth: Country -> Launch Site structure ----
earth_sites <- list(
  "United States" = c(
    "Cape Canaveral / Kennedy Space Center (Florida)",
    "Vandenberg Space Force Base (California)",
    "Starbase (Texas)", "Wallops Flight Facility (Virginia)",
    "Mojave Air & Space Port (California)",
    "Pacific Spaceport Complex (Alaska)", "Spaceport America (New Mexico)"
  ),
  "Russia / Kazakhstan" = c(
    "Baikonur Cosmodrome (Kazakhstan)", "Plesetsk Cosmodrome (Russia)",
    "Vostochny Cosmodrome (Russia)", "Kapustin Yar (Russia)"
  ),
  "China" = c(
    "Jiuquan Satellite Launch Center", "Xichang Satellite Launch Center",
    "Taiyuan Satellite Launch Center", "Wenchang Space Launch Site (Hainan)"
  ),
  "India" = c("Satish Dhawan Space Centre, Sriharikota"),
  "Europe" = c(
    "Guiana Space Centre, Kourou (French Guiana)",
    "SaxaVord Spaceport (Scotland)", "Sutherland Spaceport (Scotland)"
  ),
  "Japan" = c("Tanegashima Space Center", "Uchinoura Space Center"),
  "Others" = c(
    "Broglio Space Centre, Malindi (Kenya)",
    "Andoya Rocket Range (Norway)", "SUPARCO facilities (Pakistan)"
  )
)

# ---- Other planets/bodies: flat list of named locations ----
other_locations <- list(
  "Mercury" = c("Caloris Basin", "Discovery Rupes"),
  "Venus"   = c("Venera 13 landing site", "Venera 14 landing site"),
  "Moon"    = c("Sea of Tranquility (Apollo 11)", "Mare Imbrium",
                "Oceanus Procellarum (Apollo 12)", "Shackleton Crater (South Pole)"),
  "Mars"    = c("Jezero Crater (Perseverance)", "Gale Crater (Curiosity)",
                "Elysium Planitia (InSight)", "Meridiani Planum (Opportunity)"),
  "Jupiter" = c("Great Red Spot region", "Equatorial Zone"),
  "Saturn"  = c("Titan - Huygens landing site (Xanadu)", "Equatorial Zone")
)

# ---- Real approximate lat/long for every Earth site (for distance calc) ----
site_coords <- list(
  "Cape Canaveral / Kennedy Space Center (Florida)" = c(28.5721, -80.6480),
  "Vandenberg Space Force Base (California)"        = c(34.7420, -120.5724),
  "Starbase (Texas)"                                = c(25.9970, -97.1554),
  "Wallops Flight Facility (Virginia)"               = c(37.9402, -75.4664),
  "Mojave Air & Space Port (California)"             = c(35.0590, -118.1517),
  "Pacific Spaceport Complex (Alaska)"                = c(57.4353, -152.3378),
  "Spaceport America (New Mexico)"                   = c(32.9903, -106.9750),
  "Baikonur Cosmodrome (Kazakhstan)"                 = c(45.9646, 63.3052),
  "Plesetsk Cosmodrome (Russia)"                     = c(62.9270, 40.5770),
  "Vostochny Cosmodrome (Russia)"                    = c(51.8845, 128.3335),
  "Kapustin Yar (Russia)"                            = c(48.5795, 45.7455),
  "Jiuquan Satellite Launch Center"                  = c(40.9675, 100.2783),
  "Xichang Satellite Launch Center"                  = c(28.2467, 102.0268),
  "Taiyuan Satellite Launch Center"                  = c(38.8489, 111.6087),
  "Wenchang Space Launch Site (Hainan)"               = c(19.6146, 110.9510),
  "Satish Dhawan Space Centre, Sriharikota"          = c(13.7199, 80.2304),
  "Guiana Space Centre, Kourou (French Guiana)"      = c(5.2360, -52.7750),
  "SaxaVord Spaceport (Scotland)"                    = c(60.7500, -0.8000),
  "Sutherland Spaceport (Scotland)"                  = c(58.2000, -4.4200),
  "Tanegashima Space Center"                          = c(30.4008, 130.9714),
  "Uchinoura Space Center"                            = c(31.2514, 131.0790),
  "Broglio Space Centre, Malindi (Kenya)"             = c(-2.9954, 40.1975),
  "Andoya Rocket Range (Norway)"                      = c(69.2944, 16.0284),
  "SUPARCO facilities (Pakistan)"                     = c(25.1930, 66.7580)
)

all_earth_site_names <- unname(unlist(earth_sites))

# ---- Real-world great-circle distance between two lat/long points (meters) ----
haversine_distance <- function(lat1, lon1, lat2, lon2) {
  R_earth <- 6371000
  to_rad <- function(x) x * pi / 180
  dlat <- to_rad(lat2 - lat1)
  dlon <- to_rad(lon2 - lon1)
  a <- sin(dlat / 2)^2 + cos(to_rad(lat1)) * cos(to_rad(lat2)) * sin(dlon / 2)^2
  c_val <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R_earth * c_val
}

# ---- Core physics calculation (Mode 1: speed + angle known) ----
calculate_trajectory <- function(v0, angle_deg, g) {
  angle_rad <- angle_deg * pi / 180
  vx <- v0 * cos(angle_rad)
  vy <- v0 * sin(angle_rad)
  
  time_to_peak <- vy / g
  total_time   <- 2 * time_to_peak
  max_height   <- (vy^2) / (2 * g)
  range_val    <- vx * total_time
  
  t <- seq(0, total_time, length.out = 200)
  x <- vx * t
  y <- vy * t - 0.5 * g * t^2
  
  list(vx = vx, vy = vy, time_to_peak = time_to_peak, total_time = total_time,
       max_height = max_height, range_val = range_val,
       path_x = x, path_y = y, v0 = v0, angle_deg = angle_deg, g = g)
}

# ---- Reverse solve (Mode 2: destination known) ----
# Given target range R and angle, solve required speed
solve_speed_given_angle <- function(R, angle_deg, g) {
  angle_rad <- angle_deg * pi / 180
  denom <- sin(2 * angle_rad)
  if (denom <= 0) return(NA)
  sqrt(R * g / denom)
}

# Given target range R and speed, solve required angle (degrees)
solve_angle_given_speed <- function(R, v0, g) {
  val <- R * g / (v0^2)
  if (val > 1) return(NA)  # speed too low to ever reach that range
  (0.5 * asin(val)) * 180 / pi
}

# ---- Compass direction options for Mode 1 (Earth only) ----
compass_choices <- c(
  "North" = 0, "Northeast" = 45, "East (common real-world choice)" = 90,
  "Southeast" = 135, "South" = 180, "Southwest" = 225,
  "West" = 270, "Northwest" = 315
)

# ---- Given a start point, a compass bearing, and a distance,
#      find the landing point's real lat/long ----
destination_point <- function(lat1, lon1, bearing_deg, distance_m) {
  R_earth <- 6371000
  lat1_r <- lat1 * pi / 180
  lon1_r <- lon1 * pi / 180
  bearing_r <- bearing_deg * pi / 180
  d_r <- distance_m / R_earth
  
  lat2_r <- asin(sin(lat1_r) * cos(d_r) + cos(lat1_r) * sin(d_r) * cos(bearing_r))
  lon2_r <- lon1_r + atan2(sin(bearing_r) * sin(d_r) * cos(lat1_r),
                           cos(d_r) - sin(lat1_r) * sin(lat2_r))
  
  list(lat = lat2_r * 180 / pi, lon = ((lon2_r * 180 / pi + 540) %% 360) - 180)
}

# ---- Find the nearest real named city to a lat/long point ----
# Uses the offline 'maps' package city database (no internet needed).
# Returns NULL if the 'maps' package isn't installed.
nearest_city <- function(lat, lon) {
  if (!requireNamespace("maps", quietly = TRUE)) return(NULL)
  
  world.cities <- NULL
  data("world.cities", package = "maps", envir = environment())
  cities <- world.cities[world.cities$pop > 20000, ]
  
  d <- haversine_distance(lat, lon, cities$lat, cities$long)
  idx <- which.min(d)
  
  list(name = cities$name[idx], country = cities$country.etc[idx],
       distance_km = d[idx] / 1000)
}
