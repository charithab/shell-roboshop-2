#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo  &>>$LOG_FILE
VALIDATE $? "mongo.repo creating"

dnf install mongodb-mongosh -y  &>>$LOG_FILE
VALIDATE $? "Installing mongosh client"

STATUS=$(mongosh --host mongodb.charitha.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.charitha.site </app/db/master-data.js  &>>$LOG_FILE
    VALIDATE $? "Mongodb Data loading"
else
    echo -e "Data is already loaded.... $Y SKIPPING $N"
fi

print_time
