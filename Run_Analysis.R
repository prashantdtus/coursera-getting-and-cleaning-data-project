library(plyr)
# download file to local data folder 

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

#Unzip file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

path_rp <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rp, recursive=TRUE)
files

#Read the Activity files

dataActivityTest  <- read.table(file.path(path_rp, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rp, "train", "Y_train.txt"),header = FALSE)

#Read the Subject files

dataSubjectTrain <- read.table(file.path(path_rp, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rp, "test" , "subject_test.txt"),header = FALSE)

#Read Fearures files

dataFeaturesTest  <- read.table(file.path(path_rp, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rp, "train", "X_train.txt"),header = FALSE)


#Concatenate the data tables by rows

dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#set names to variables

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rp, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#Merge columns to get the data frame Data for all data

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#Subset Name of Features by measurements on the mean and standard deviation

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#Subset the data frame Data by seleted names of Features

selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#Read descriptive activity names from "activity_labels.txt"

activityLabels <- read.table(file.path(path_rp, "activity_labels.txt"),header = FALSE)

#facorize Variable activity in the data frame Data using descriptive activity names

Data$activity <- factor(Data$activity, 
                                levels = activityLabels[, 1], labels = activityLabels[, 2])

Data$subject <- as.factor(Data$subject)

##Appropriately label the data set with descriptive variable names

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#Create a second, independent tidy set with the average of each
#          variable for each activity and each subject


Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)


