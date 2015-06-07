# Cleanup environment data/variables
rm(list=ls())

# Seed for reproductibility
set.seed(351900)

# Save default value for displaying scientific notation
spSave <- getOption("scipen")
# Turn off scientific notation for plots
options("scipen"=999)

# Set variables used in markdown
dtSysTime = Sys.time()
dtDate <- format(dtSysTime,"%d-%b-%Y")
dtTime <- format(dtSysTime,"%H:%M:%S")
# Get R version
rVersion <- version$version.string
# Get OS
osPlatform <- version$platform

# Save current working directory
wdSave <- getwd()
setwd("/Users/bobfridley/Documents/git/05-Reproducible-Research/Peer-Assessment-01/R-wd")

# Set directory/file paths
baseDirectory <- ".."
dataDirectory <- file.path(baseDirectory, "data")
destZipFilePath <- file.path(dataDirectory, "activity.zip")
destFilePath <- file.path(dataDirectory, "activity.csv")

# Downloaded file info
destDateFileDownloaded <- file.path(dataDirectory, "data-file-downloaded.txt")

# Data file url
datafileUrl <- "https://d396qusza40orc.cloudfront.net/repdata/data/activity.zip"

# Required R packages for project
packages <- c("data.table", "reshape2", "dplyr", "lattice", "knitr", "cowplot")

# Function to load packages
loadPackages <- function() {
        loadp <- suppressWarnings(sapply(packages, library, character.only=TRUE, quietly=TRUE,
                warn.conflicts=TRUE, logical.return=TRUE, verbose=FALSE))

        # Verify that all packages loaded, else stop program
        if (!all(loadp)) {
                notloaded = which(loadp==FALSE)

                # Display the packages that could not be loaded
                cat("Unable to load the following packages:")
                for(i in notloaded) {
                        cat("\r\n", packages[i])
                }
                
                # Stop execution or program
                stop("Stopping Execution", call.=FALSE)
        }
}

# Function to download csv file
getCSV <- function() {
        # Create data directory is not exists
        if (!file.exists(dataDirectory)) {
                dir.create(dataDirectory)
        }
        
        # Download data file if not exists or if download info file not exists
        if (!file.exists(destZipFilePath) || !file.exists(destDateFileDownloaded)) {
                download.file(datafileUrl, destfile=destZipFilePath,
                        method="curl", mode="wb")
                # Save download time and write to file
                dtDownload = format(Sys.time(), "%Y-%b-%d %H:%M:%S")
                cat(dtDownload, file=destDateFileDownloaded)
        } else {
                # Data file exists.  Get download time from saved file
                dtDownload <- scan(file=destDateFileDownloaded, what="character",
                        sep="\n")
        }
        
        # Uzip downloaded data file if not exists
        if (!file.exists(destFilePath)) {
                unzip(destZipFilePath, exdir=dataDirectory)
        }

        cat("Data File:", destFilePath, "\r\nFile Size:",
                file.size(destFilePath),
                "bytes", "\r\nDownloaded From:", URLdecode(datafileUrl),
                "\r\nDownload Date:", dtDownload, "\r\n\r\n")
}

# Load required packages
loadPackages()

# Set global options for markdown
# depends on knitr package
opts_chunk$set(echo=TRUE)

# Get source data file
getCSV()

# Read csv data file
# Previously verified that csv file has a column header row
rawData <- read.csv(destFilePath, colClasses=c("integer", "character",
        "integer"), header=TRUE)

# Display structure of rawData
str(rawData)

# Change date from character string to date type 
rawData$date <- as.Date(rawData$date)

# Display structure of rawData
str(rawData)

# build table of total number of steps per day
# exclude missing values
dtStepsPerDay <- aggregate(steps ~ date, data=rawData, FUN="sum", na.exclude=TRUE)




# restore defaults
setwd(wdSave)
options("scipen"=spSave)