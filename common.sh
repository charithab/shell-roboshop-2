#!/bin/bash

USERID=$(id -u)
R='\e[31m'
G='\e[32m'
Y='\e[33m'
N='\e[0m'
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" | tee -a $LOG_FILE

check_root() {
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Error: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1
    else
        echo "You are running with root access"
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is...$G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is...$R FAILURE $N" | tee -a $LOG_FILE
    fi
}

print_time() {
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script execution completed successfully, $N Time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
}

app_setup() {
    id roboshop
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating Roboshop system user"
    else
        echo -e "Roboshop user is already created ... $Y SKIPPING $N"
    fi

    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "Creating App Directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    rm -rf /app/*
    VALIDATE $? "Removing App content"

    cd /app  
    unzip /tmp/$app_name.zip  &>>$LOG_FILE
    VALIDATE $? "Unzipping $app_name"
}

systemd_setup() {
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service  &>>$LOG_FILE
    VALIDATE $? "Creating $app_name service"

    systemctl daemon-reload
    systemctl enable $app_name  &>>$LOG_FILE
    systemctl start $app_name  &>>$LOG_FILE
    VALIDATE $? "Starting $app_name service"
}

nodejs_setup() {
    dnf module disable nodejs -y  &>>$LOG_FILE
    VALIDATE $? "Disabling Default nodeJs"

    dnf module enable nodejs:20 -y  &>>$LOG_FILE
    VALIDATE $? "Enabling nodeJs:20"

    dnf install nodejs -y  &>>$LOG_FILE
    VALIDATE $? "Installing nodeJs:20"

    npm install  &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

maven_setup() {
    dnf install maven -y  &>>LOG_FILE
    VALIDATE $? "Installing maven and Java"

    mvn clean package &>>LOG_FILE
    VALIDATE $? "Packaging"

    mv target/shipping-1.0.jar shipping.jar  &>>LOG_FILE
    VALIDATE $? "Renaming and moving the Jar file"
}

python_setup() {
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing pip"
}