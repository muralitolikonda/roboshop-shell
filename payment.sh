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

dnf install python36 gcc python3-devel -y  &>> $LOGFILE
VALIDATE $? "installing python"

id roboshop  &>> $LOGFILE

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else 
    echo -e "roboshop user creation...$Y SKIPPING $N "
fi  


mkdir -p /app   &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip  &>> $LOGFILE
VALIDATE $? "downloading payment"

cd /app   &>> $LOGFILE
VALIDATE $? "moving to app directory"

unzip -o /tmp/payment.zip   &>> $LOGFILE
VALIDATE $? "unzipping the payments"

cd /app   &>> $LOGFILE
VALIDATE $? "moving to app"

pip3.6 install -r requirements.txt  &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/payment.service  /etc/systemd/system/payment.service  &>> $LOGFILE
VALIDATE $? "coping payment.service"

systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable payment   &>> $LOGFILE
VALIDATE $? "enabling payment"

systemctl start payment  &>> $LOGFILE
VALIDATE $? "starting payment"

