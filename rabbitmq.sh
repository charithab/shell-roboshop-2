#!/bin/bash

source ./common.sh
app_name=rabbitmq

check_root

echo "Please enter rabbitmq password"
read -s RABBITMQ_PASSWORD

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Creating rabbitmq repo"

dnf install rabbitmq-server -y  &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server   &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server  &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq server"
id roboshop
if [ $? -ne 0 ]
    then
        rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD  &>>$LOG_FILE
        VALIDATE $? "Adding rabbitmq user"
    else
        echo -e "roboshop user is already created.. $Y SKIPPING $N" | tee -a $LOG_FILE
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>$LOG_FILE
VALIDATE $? "Permission set"

print_time