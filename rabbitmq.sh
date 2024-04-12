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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> $LOGFILE
VALIDATE $? "Installing rabbitmq repo"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> $LOGFILE
VALIDATE $? "Installing rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server  &>> $LOGFILE
VALIDATE $? "enabling rabbitmq server"

systemctl start rabbitmq-server  &>> $LOGFILE
VALIDATE $? "starting rabbitmq server"



rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "creating user and password for the rabbitmq server"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "setting permissions for user in server"


