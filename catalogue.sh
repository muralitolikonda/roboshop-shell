#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at:$TIMESTAMP" &>> $LOGFILE

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e  "$2 ... $R FAILED $N "
    else
        echo -e  "$2 ... $G SUCCESS $N "
    fi
}

if [ $ID -ne 0 ]
then
    echo -e " $R ERROR $N:: Please run the script with the root user $N"
    exit 1
else 
    echo "You are root user"
fi


dnf module disable nodejs -y  &>> $LOGFILE
VALIDATE $? "disabling nodejs default version"

dnf module enable nodejs:18 -y  &>> $LOGFILE
VALIDATE $? "enabling nodejs:18 version"

dnf install nodejs -y  &>> $LOGFILE
VALIDATE $? "installing nodejs:18 version"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else 
    echo -e "roboshop user creation...$Y SKIPPING $N "
fi

mkdir /app
VALIDATE $? "app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading the catalogue application"

cd /app 

unzip /tmp/catalogue.zip
VALIDATE $? "unzipping the catalogue file"

cd /app

npm install 
VALIDATE $? "Installing catalogue file"

cp /home/centos/roboshop-shell /etc/systemd/system/catalogue.service
VALIDATE $? "Creating catalogue service"

mongo --host mongodb.murralii.online </app/schema/catalogue.js






