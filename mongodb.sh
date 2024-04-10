#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE() {
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ...$R FAILED $N"
        exit 1
    else
        echo -e "$2 ...$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Error:: $N Please run the script with the root user $N"
    exit 1
else
    echo "you are root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied Mongodb repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing MongoDb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabling MongoDb"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting MongoDb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "remote access to MongoDb"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "restarting MongoDb"
