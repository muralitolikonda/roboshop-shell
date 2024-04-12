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


dnf install nginx -y  &>> $LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx  &>> $LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx  &>> $LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*  &>> $LOGFILE
VALIDATE $? "removing the default folder"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip  &>> $LOGFILE
VALIDATE $? "downloading the zip file"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving to nginx folder"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping the web file"

cp /home/centos/roboshop-shell/roboshop.conf   /etc/nginx/default.d/roboshop.conf  &>> $LOGFILE
VALIDATE $? "coping the roboshop.conf"

systemctl restart nginx   &>> $LOGFILE
VALIDATE $? "restarting nginx"