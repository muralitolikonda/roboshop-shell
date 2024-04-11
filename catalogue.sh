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

yum install git -y &>> $LOGFILE

if [ $? -ne 0 ]
then 
    echo -e " $N Insatalling ...$N "
    exit 1
else 
    echo -e "Installing ...$Y SKIPPING $N"
fi


VALIDATE $? "Installing git" 

yum install mysql -y &>> $LOGFILE

if [ $? -ne 0 ]
then 
    echo -e " $N Insatalling ...$N "
    exit 1
else 
    echo -e "Installing ...$Y SKIPPING $N"
fi


VALIDATE $? "Installing mysql" 