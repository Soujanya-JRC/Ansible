#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14} #if user is not providing numberof days we take 14 days by default

LOGS_FOLDER="/home/ec2-user/shell-logs"
LOG_FILE=$(echo $0 | awk -f "/" '${print $NF}' | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"



USAGE(){
    echo -e "$R USAGE:: $N sh backup.sh <SOURCE_DIR> <DEST_DIR> <DAYS(optional)>"
    exit 1
}

mkdir -p /home/ec2-user/shell-logs

if [ $# -lt 2 ]
then 
    USAGE
fi

if [ ! -d $SOURCE_DIR ]
then
    echo  -e "$SOURCE_DIR does not exist....please check"
    exit 1
fi

if [ ! -d $DEST_DIR ]
then
    echo  -e "$DEST_DIR does not exist....please check"
    exit 1
fi

FILES=$(find $SOURCE_DIR -name "*.log" -mtime +$DAYS)

if [ -n "$FILES" ] #true if there are files to zip
then    
    echo "Files are: $FILES"
    ZIP_FILE="$DEST_DIR/app-logs-$TIMESTAMP.zip"
    find $SOURCE_DIR -name "*.log" -mtime +$DAYS | zip -@ "$ZIP_FILE"
    if [ -f "$ZIP_FILE" ]
    then
        echo -e "successfully created zipfile for files older than $DAYS"
        while read -r filepath  #here file path is the variable nmae, you can give any name
        do
            echo "deleting file: $filepath" 
            rm -rf $filepath
            echo "deleted file: $filepath"
        done <<< $FILES
    else
        echo -e "$R Error:: $N failed to create zip file"
        exit 1
    fi 

else
    echo  "no files found older than $DAYS "
fi
