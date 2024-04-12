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

dnf module disable mysql -y  &>> $LOGFILE
VALIDATE $? "disabling mysql" 

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "coping mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "enabling mysql"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "setting root user for roboshop"

mysql -uroot -pRoboShop@1 &>> $LOGFILE 
VALIDATE $? "setting root password for roboshop"
