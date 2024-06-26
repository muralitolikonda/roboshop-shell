#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

exec &> $LOGFILE

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

dnf module disable nodejs -y


dnf module enable nodejs:18 -y


dnf install nodejs -y


id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else 
    echo -e "roboshop user creation...$Y SKIPPING $N "
fi

mkdir -p /app


curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip


cd /app 


unzip -o /tmp/cart.zip

cd /app 

npm install 

cp /home/centos/roboshop-shell/cart.service  /etc/systemd/system/cart.service

systemctl daemon-reload

systemctl enable cart 

systemctl start cart




