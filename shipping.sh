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

dnf install maven -y  &>> $LOGFILE

id roboshop  &>> $LOGFILE

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else 
    echo -e "roboshop user creation...$Y SKIPPING $N "
fi


mkdir -p /app  &>> $LOGFILE
VALIDATE $? ""

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip  &>> $LOGFILE


cd /app  &>> $LOGFILE
VALIDATE $? "creating app directory"

unzip -o /tmp/shipping.zip  &>> $LOGFILE
VALIDATE $? "downloading zip file"

cd /app  &>> $LOGFILE
VALIDATE $? "moving to app directory"

mvn clean package   &>> $LOGFILE
VALIDATE $? "downloading clean package"

mv target/shipping-1.0.jar shipping.jar  &>> $LOGFILE
VALIDATE $? "renaming to jar file"

cp /home/centos/roboshop-shell/shipping.service  /etc/systemd/system/shipping.service  &>> $LOGFILE
VALIDATE $? "coping shipping service"

systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "enabling shipping"

systemctl start shipping  &>> $LOGFILE
VALIDATE $? "starting shipping"

dnf install mysql -y   &>> $LOGFILE
VALIDATE $? "installing mysql"

mysql -h mysql.murralii.online -uroot -pRoboShop@1  /app/schema/shipping.sql  &>> $LOGFILE
VALIDATE $? "creating user and password"

systemctl restart shipping  &>> $LOGFILE
VALIDATE $? "restarting shipping"