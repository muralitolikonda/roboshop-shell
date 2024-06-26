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

mkdir -p /app &>> $LOGFILE
VALIDATE $? "app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE
VALIDATE $? "Downloading the catalogue application"

cd /app 

unzip -o /tmp/catalogue.zip  &>> $LOGFILE
VALIDATE $? "unzipping the catalogue file"

cd /app

npm install  &>> $LOGFILE
VALIDATE $? "Installing catalogue file"

cp /home/centos/roboshop-shell/catalogue.service  /etc/systemd/system/catalogue.service  &>> $LOGFILE
VALIDATE $? "Creating catalogue service"

systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "Reloading the catalogue file"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue  &>> $LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo  /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
VALIDATE $? "copied the mongo repo"

dnf install mongodb-org-shell -y  &>> $LOGFILE
VALIDATE $? "Installing mongo shell"

mongo --host mongodb.murralii.online </app/schema/catalogue.js  &>> $LOGFILE
VALIDATE $? "enabling remote access"







