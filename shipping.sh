#!/bin/bash

source ./common.sh
app_name=shipping

check_root
echo "Please enter root password to setup"
read -s SHIPPING_PASSWORD

app_setup
maven_setup
systemd_setup

dnf install mysql -y  &>>LOG_FILE
VALIDATE $? "Installing mysql"

mysql -h mysql.daws84s.site -u root -p$SHIPPING_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.charitha.site -uroot -p$SHIPPING_PASSWORD < /app/db/schema.sql &>>LOG_FILE
    mysql -h mysql.charitha.site -uroot -p$SHIPPING_PASSWORD < /app/db/app-user.sql  &>>LOG_FILE
    mysql -h mysql.charitha.site -uroot -p$SHIPPING_PASSWORD < /app/db/master-data.sql &>>LOG_FILE
    VALIDATE $? "Data is loading into db"
else
    echo -e "Data is already loaded into MYSQL... $Y SKIPPING $N"
fi

systemctl restart shipping &>>LOG_FILE
VALIDATE $? "Restart shipping"

print_time
