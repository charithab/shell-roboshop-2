#!/bin/bash

source ./common.sh
app_name=mysql
check_root

echo "Please enter mysql password"
read -s MYSQL_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing Mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling Mysql service"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Starting Mysql server" 

mysql_secure_installation --set-root-pass $MYSQL_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting Root Password"

print_time