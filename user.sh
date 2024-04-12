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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling default nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs:18"

dnf install nodejs -y  &>> $LOGFILE
VALIDATE $? "installing nodejs"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else 
    echo -e "roboshop user creation...$Y SKIPPING $N "
fi

mkdir -p /app

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "downloading the zip file"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unzipping the zip file"


cd /app 

npm install  &>> $LOGFILE
VALIDATE $? "intalling user"

cp /home/centos/roboshop-shell/user.service  etc/systemd/system/user.service  &>> $LOGFILE
VALIDATE $? "coping user.service"

systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable user &>> $LOGFILE
VALIDATE $? "enabling user"

systemctl start user  &>> $LOGFILE
VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo  /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
VALIDATE $? "coping mongo repo"

dnf install mongodb-org-shell -y   &>> $LOGFILE
VALIDATE $? "installing mongodb shell"

mongo --host mongodb.murralii.online /app/schema/user.js &>> $LOGFILE
VALIDATE $? "giving remote access to mongodb"





