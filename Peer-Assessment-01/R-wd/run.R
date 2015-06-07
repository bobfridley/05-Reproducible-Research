# Cleanup environment data/variables
rm(list=ls())

# Seed for reproductibility
set.seed(351900)

# Set global options for markdown
opts_chunk$set(echo=TRUE)

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

# save current working directory
wdSave <- getwd()
# set working directory
setwd("/Users/bobfridley/Documents/git/05-Reproducible-Research/Peer-Assessment-01/R-wd")

# load required packages
packages <- c("data.table", "reshape2", "dplyr", "lattice", "knitr")
loadp <- sapply(packages, library, character.only=TRUE, quietly=TRUE,
        warn.conflicts=FALSE, logical.return=TRUE, verbose=FALSE)
# verify that all packages loaded, otw stop program
if (!all(loadp)) {
        stop("Unable to load all required packages")
}

# set directory/file paths
baseDirectory <- ".."
dataDirectory <- file.path(baseDirectory, "data")
destZipFilePath <- file.path(dataDirectory, "activity.zip")
destFilePath <- file.path(dataDirectory, "activity.csv")
# save downloaded file info
destDateFileDownloaded <- file.path(dataDirectory, "data-file-downloaded.txt")
# data file url
datafileUrl <- "https://d396qusza40orc.cloudfront.net/repdata/data/activity.zip"

# create data directory is not exists
if (!file.exists(dataDirectory)) {
        dir.create(dataDirectory)
}

# download data file if not exists or if download info file not exists
if (!file.exists(destZipFilePath) || !file.exists(destDateFileDownloaded)) {
        download.file(datafileUrl, destfile=destZipFilePath,
                method="curl", mode="wb")
        dtDownload = format(Sys.time(), "%Y-%b-%d %H:%M:%S")
        cat(dtDownload, file=destDateFileDownloaded)
} else {
        dtDownload <- scan(file=destDateFileDownloaded, what="character",
                sep="\n")
}

# uzip downloaded data file if not exists
if (!file.exists(destFilePath)) {
        unzip(destZipFilePath, exdir=dataDirectory)
}

cat("Data File:", destFilePath, "\r\nFile Size:", file.size(destFilePath),
        "bytes", "\r\nDownloaded From:", URLdecode(datafileUrl),
        "\r\nDownload Date:", dtDownload, "\r\n\r\n")

# Read csv data file
# Verified that csv has a column header row
rawData <- read.csv(destFilePath, colClasses=c("integer", "character",
        "integer"), header=TRUE)

# Display structure of rawData
str(rawData)

# Change data from character string to date type 
rawData$date <- as.Date(rawData$date)
# Intervals are represented by 24 hour time (hhmm)
# Add columns for minutes, hours and elapsed time from Interval
rawData$minute <- rawData$interval %% 100
rawData$hour <- rawData$interval %/% 100
rawData$elapsed <- rawData$hour * 60 + rawData$minute

# Add column for zero-fill interval as factor (hh:mm)
rawData$fInterval <- as.factor(sprintf("%02d:%02d", rawData$hour,
        rawData$minute))

# Display structure of rawData
str(rawData)

# Number of missing values for entire dataset
missAll <- sum(is.na(rawData))
print(missAll)
# Number of missing values for data
missDate <- sum(is.na(rawData$date))
print(missDate)
# Number of missing values for steps
missSteps <- sum(is.na(rawData$steps))
print(missSteps)
# Number of missing values for interval
missInterval <- sum(is.na(rawData$interval))
print(missInterval)

print(head(rawData))

# build table of total number of steps per day
# exclude missing values
dtStepsPerDay <- aggregate(steps ~ date, data=rawData, FUN="sum", na.exclude=TRUE)

# Generate histogram of steps per day
histogram(dtStepsPerDay$steps, breaks=10, main="Total Number of Steps per Day", xlab="Steps per Day")
# rebuild data excluding rows with missing values
#dtActivity <- na.omit(rawData)

# add column 
# Display structure of dtActivity
#str(dtActivity)

#print(summary(dtActivity))
#print(dim(dtActivity))




# restore defaults
setwd(wdSave)
options("scipen"=spSave)