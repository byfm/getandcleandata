setwd("Z:/USER/Axel/Fortbildung/Data Analyst/R/50 Course/030 Getting and Cleaning Data/week 4/20 Programme/Project")
library(reshape2)

filename <- "daten.zip"

## 1. Download the dataset if it does not already exist in the working directory ################################################

## Check if file exits, if not download it

if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename)
}  

## Check if file unziped, if not, unzip

if (!file.exists("UCI HAR Dataset"))  { 
    unzip(filename) 
} else {filename}

## 2. Load the activity and feature info ########################################################################################
# and Take the names from  V2

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## 3. Loads both the training and test datasets, keeping only those columns which reflect a mean or standard deviation ###########
# by matching names

featuresneeded <- grep(".*mean.*|.*std.*", features[,2])
featuresneeded.names <- features[featuresneeded,2]
featuresneeded.names = gsub('-mean', 'Mean', featuresneeded.names)
featuresneeded.names = gsub('-std', 'Std', featuresneeded.names)
featuresneeded.names <- gsub('[-()]', '', featuresneeded.names)

## 4. Loads the activity and subject data for each dataset, and merges those columns with the dataset ###########################
# connect cols @ each set

training <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresneeded]
trainingActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainingSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(trainingSubjects, trainingActivities, training)

testing <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresneeded]
testingActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testingSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testing <- cbind(testingSubjects, testingActivities, testing)

## 5. Merges the two datasets ###################################################################################################
# connect one set rowwise to the other

Daten <- rbind(training, testing)
colnames(Daten) <- c("subject", "activity", featuresneeded.names)

## 6. Converts the `activity` and `subject` columns into factors ################################################################

Daten$activity <- factor(Daten$activity, levels = activityLabels[,1], labels = activityLabels[,2])
Daten$subject <- as.factor(Daten$subject)


## 7. Creates a tidy dataset that consists of the average (mean) value of each variable for each subject and activity pair.
# using melt() to prepare the pairs and dcast() to connect the values

Daten.melted <- melt(Daten, id = c("subject", "activity"))
Daten.mean <- dcast(Daten.melted, subject + activity ~ variable, mean)

write.table(Daten.mean, "tidy.txt", row.names = FALSE, quote = FALSE)