# Use the official R base image
FROM r-base:4.3.2

# Install system dependencies for maps/ggmap
RUN apt-get update && apt-get install -y \
    libssl-dev libcurl4-openssl-dev libxml2-dev

# Install R packages in one layer
RUN R -e "install.packages(c('ggplot2','maps','ggmap','dplyr','lubridate','scales','viridis','tidyr','forcats','rmarkdown'), repos='https://cloud.r-project.org/')"

# Copy project into container
WORKDIR /home/rstudio/earthquake
COPY . .

# Default command: render report
CMD ["Rscript", "-e", "rmarkdown::render('earthquake_report.Rmd', output_file='report.html')"]
