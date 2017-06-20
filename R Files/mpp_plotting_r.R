library(RPostgreSQL)
library(ggplot2)
library(dplyr)
library(magrittr)

# Connects to the cluster
conn <- dbConnect(PostgreSQL(), dbname="postgres", host="localhost", user="postgres", password="")

dbSendQuery(conn, "SET search_path TO template;")


# Histogram
sql <- "
SELECT *
  FROM histogram_values
 ORDER BY bin_loc;
"
r_hist_df <- dbGetQuery(conn, sql)

png('R_histogram.png', width = 720, height = 504, units = 'px')

plot_bin_width <- r_hist_df$bin_loc %>% diff() %>% mean(na.rm=TRUE)
# Since all bin widths are the same, we can define them by the distance
# between the first two points
plot_bin_width <- r_hist_df$bin_loc[2] - r_hist_df$bin_loc[1]

ggplot(r_hist_df, aes(bin_loc, weight = bin_height)) +
  geom_histogram(binwidth = plot_bin_width, col = 'black', fill = 'dodgerblue2') +
  labs(title = 'ggplot Histogram (R)', x = 'x-axis', y = 'Frequency') +
  theme(plot.title = element_text(size = 26, hjust = 0.5),
        axis.title.x = element_text(size = 22),
        axis.title.y = element_text(size = 22),
        axis.text.x = element_text(size = 14), 
        axis.text.y = element_text(size = 14)
       )

dev.off()


# Scatter plot
sql <- "
SELECT *
  FROM scatter_plot_values
 ORDER BY scat_bin_x, scat_bin_y;
"
r_scat_df <- dbGetQuery(conn, sql)

png('R_scatter_plot.png', width = 720, height = 504, units = 'px')

ggplot(r_scat_df, aes(scat_bin_x, scat_bin_y, alpha = freq)) +
  geom_point(col = 'dodgerblue2') +
  labs(title = 'ggplot Scatter Plot (R)', x = 'x variable', y = 'y variable') +
  theme(plot.title = element_text(size = 26, hjust = 0.5),
        axis.title.x = element_text(size = 22),
        axis.title.y = element_text(size = 22),
        axis.text.x = element_text(size = 14), 
        axis.text.y = element_text(size = 14),
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 16)
       )

dev.off()


  