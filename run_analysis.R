You should create one R script called run_analysis.R that does the following.


https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# step: download data and reading


namefile <- "data"
namefile

if (!file.exists(namefile)) {
	dir.create(namefile)
}


fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/datatraining.zip", method = "curl")
list.files("./data")

dateDownloaded <- date()
dateDownloaded 

unzip(zipfile="./data/datatraining.zip",exdir="./data")


data_path <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(data_path, recursive=TRUE)
files

# Reading files with data to analyze

dataActivityTest  <- read.table(file.path(data_path, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(data_path, "train", "Y_train.txt"),header = FALSE)

dataSubjectTrain <- read.table(file.path(data_path, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(data_path, "test" , "subject_test.txt"),header = FALSE)

dataFeaturesTest  <- read.table(file.path(data_path, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(data_path, "train", "X_train.txt"),header = FALSE)


# Step: Merges the training and the test sets to create one data set.


# Concatenate data tables

dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(data_path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)


# Step: Extracts only the measurements on the mean and standard deviation for each measurement.

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

str(Data)

activityLabels <- read.table(file.path(data_path, "activity_labels.txt"),header = FALSE)

head(Data$activity,30)

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))


names(Data)



# Step: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "finaltidydata.txt",row.name=FALSE)


#Codebook

library(knitr)
knit2html("codebook.Rmd");
