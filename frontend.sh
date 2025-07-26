#!/bin/bash

source ./common.sh
app_name=frontend

check_root

dnf module disable nginx -y  &>>$LOG_FILE
VALIDATE $? "Disabling Default Nginx"

dnf module enable nginx:1.24 -y  &>>$LOG_FILE
VALIDATE $? "Enabling Nginx:1.24"

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "Installing Nginx:1.24"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx   &>>$LOG_FILE
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "Removing default HTML content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip  &>>$LOG_FILE
VALIDATE $? "Unzipping frontend"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf  &>>$LOG_FILE
VALIDATE $? "creating nginx.conf"

systemctl restart nginx  &>>$LOG_FILE
VALIDATE $? "Restarting nginx"

print_time