# =================================================================================
# Earthquake.R
#
# Fetches recent earthquakes (M≥2.5 over the past 30 days) and displays:
#  1) World map of epicenters (size→mag, color→mag)
#  2) World map of epicenters colored by depth
#  3) Histogram of magnitudes
#  4) Density plot of magnitudes
#  5) Histogram of depths
#  6) Boxplot of depth by magnitude category
#  7) Scatter plot: magnitude vs. depth with smoothing
#  8) Time-series: daily counts
#  9) Heatmap: counts by weekday-hour
# 10) Cumulative quake count over time
# 11) Top 10 “places” by quake count (bar chart)
# 12) Violin plot: magnitude by weekday
# 13) Faceted world map by magnitude category
# 14) Linear regression: magnitude predicted by depth
# =================================================================================

# 0. Install & load packages
pkgs <- c("ggplot2","maps","ggmap","dplyr","lubridate","scales","viridis","tidyr","forcats")
for(p in pkgs) if(!requireNamespace(p,quietly=TRUE)) install.packages(p)
lapply(pkgs, library, character.only=TRUE)

# 1. Fetch & prep data
url <- "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.csv"
quakes <- read.csv(url, stringsAsFactors=FALSE) %>%
  mutate(
    time    = as.POSIXct(time, format="%Y-%m-%dT%H:%M:%S", tz="UTC"),
    date    = as.Date(time),
    hour    = hour(time),
    weekday = wday(time, label=TRUE, abbr=TRUE),
    mag_cat = cut(mag, breaks=c(2.5,4,5,6,Inf),
                  labels=c("2.5–4","4–5","5–6","6+")),
    place_simple = fct_lump(factor(place), n=10)  # top 10 places
  )

world_map <- borders("world", colour="gray50", fill="gray80")

# 2. Map: size & color → magnitude
p1 <- ggplot() + world_map +
  geom_point(data=quakes, aes(longitude, latitude, size=mag, colour=mag), alpha=0.6) +
  scale_size_continuous(name="Magnitude") +
  scale_color_viridis(name="Magnitude", option="plasma") +
  ggtitle("Epicenters: M ≥ 2.5 (Past 30 Days)") + theme_minimal()
print(p1)

# 3. Map: color → depth
p2 <- ggplot() + world_map +
  geom_point(data=quakes, aes(longitude, latitude, colour=depth), alpha=0.6, size=1.5) +
  scale_color_viridis(name="Depth (km)", option="magma") +
  ggtitle("Epicenters Colored by Depth") + theme_minimal()
print(p2)

# 4. Histogram: magnitudes
p3 <- ggplot(quakes, aes(mag)) +
  geom_histogram(binwidth=0.2, fill="steelblue", colour="white") +
  scale_x_continuous(breaks=pretty_breaks()) +
  labs(title="Magnitude Distribution", x="Magnitude", y="Count") +
  theme_minimal()
print(p3)

# 5. Density plot: magnitudes (fixed)
# 5. Density plot of magnitudes (solid fill)
p4 <- ggplot(quakes, aes(x = mag)) +
  geom_density(fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Magnitude Density",
    x     = "Magnitude",
    y     = "Density"
  ) +
  theme_minimal()
print(p4)


# 6. Histogram: depths
p5 <- ggplot(quakes, aes(depth)) +
  geom_histogram(binwidth=10, fill="orchid", colour="white") +
  labs(title="Depth Distribution", x="Depth (km)", y="Count") +
  theme_minimal()
print(p5)

# 7. Boxplot: depth by magnitude category
p6 <- ggplot(quakes, aes(mag_cat, depth, fill=mag_cat)) +
  geom_boxplot() +
  scale_fill_viridis(discrete=TRUE, option="cividis", name="Mag. Cat.") +
  labs(title="Depth by Magnitude Category", x="Magnitude Category", y="Depth (km)") +
  theme_minimal()
print(p6)

# 8. Scatter: magnitude vs. depth
p7 <- ggplot(quakes, aes(depth, mag)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="loess", se=FALSE, colour="darkred") +
  labs(title="Magnitude vs. Depth", x="Depth (km)", y="Magnitude") +
  theme_minimal()
print(p7)

# 9. Time-series: daily counts
daily_counts <- quakes %>% count(date)
p8 <- ggplot(daily_counts, aes(date, n)) +
  geom_line(size=1) + geom_point(size=2) +
  scale_x_date(date_labels="%b %d", date_breaks="5 days") +
  labs(title="Daily Earthquake Counts", x="Date", y="Count") +
  theme_minimal()
print(p8)

# 10. Heatmap: weekday vs. hour
heat_data <- quakes %>%
  count(weekday, hour) %>%
  complete(weekday, hour, fill=list(n=0))
p9 <- ggplot(heat_data, aes(hour, weekday, fill=n)) +
  geom_tile(color="white") +
  scale_fill_viridis(name="Count", option="plasma") +
  labs(title="Quake Counts by Weekday & Hour (UTC)", x="Hour", y="Weekday") +
  theme_minimal()
print(p9)

# 11. Cumulative quake count
cum_data <- quakes %>%
  arrange(time) %>%
  mutate(cum = row_number())
p10 <- ggplot(cum_data, aes(time, cum)) +
  geom_line() +
  labs(title="Cumulative Earthquake Count Over Time", x="Time (UTC)", y="Cumulative Count") +
  theme_minimal()
print(p10)

# 12. Top 10 places by quake count
top_places <- quakes %>% count(place_simple) %>% arrange(desc(n))
p11 <- ggplot(top_places, aes(reorder(place_simple, n), n)) +
  geom_col(fill="darkslateblue") +
  coord_flip() +
  labs(title="Top 10 Reported Locations", x="", y="Count") +
  theme_minimal()
print(p11)

# 13. Violin: magnitude by weekday
p12 <- ggplot(quakes, aes(weekday, mag, fill=weekday)) +
  geom_violin() +
  scale_fill_viridis(discrete=TRUE, option="turbo", name="Weekday") +
  labs(title="Magnitude Distribution by Weekday", x="Weekday", y="Magnitude") +
  theme_minimal()
print(p12)

# 14. Faceted map: by magnitude category
p13 <- ggplot() + world_map +
  geom_point(data=quakes, aes(longitude, latitude), alpha=0.6, size=1) +
  facet_wrap(~ mag_cat) +
  labs(title="Epicenters Faceted by Magnitude Category") +
  theme_minimal()
print(p13)

# 15. Regression: magnitude predicted by depth

# 15a. Fit linear model
model_depth_mag <- lm(mag ~ depth, data = quakes)

# 15b. Print model summary to console
cat("\n===== Linear Regression: mag ~ depth =====\n")
print(summary(model_depth_mag))

# 15c. Plot scatter with regression line
p15 <- ggplot(quakes, aes(x = depth, y = mag)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = TRUE, colour = "blue") +
  labs(
    title = "Linear Regression: Magnitude vs. Depth",
    subtitle = paste0("R² = ",
                      signif(summary(model_depth_mag)$r.squared, 3),
                      ", p-value = ",
                      signif(summary(model_depth_mag)$coefficients[2,4], 3)),
    x = "Depth (km)",
    y = "Magnitude"
  ) +
  theme_minimal()
print(p15)
