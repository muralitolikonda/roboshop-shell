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


mkdir -p /app  &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>> $LOGFILE
VALIDATE $? "downloading the cart" 

cd /app  &>> $LOGFILE
VALIDATE $? "moving to app directory"

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "unzipping the cart file"

cd /app  &>> $LOGFILE
VALIDATE $? "moving to app directory"

npm install &>> $LOGFILE
VALIDATE $? "installing cart server"

cp /home/centos/roboshop-shell/cart.service  /etc/systemd/system/cart.service  &>> $LOGFILE
VALIDATE $? "coping to cart.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "enabling cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "starting cart"
