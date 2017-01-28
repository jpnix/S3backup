#!/bin/bash
LOGS=/home/backup/logs
DIRECTORIES_TO_BACKUP=/home/backup/backup_manifest
FILE_DATE=$(date +"%m_%d_%Y")
BUCKET=redacted_bucket_name

echo $(date +"%m %d %Y") >> $LOGS/backup_$FILE_DATE.log

while IFS='' read -r DIRS || [[ -n "$DIRS" ]]; do
    LASTDIR="$(basename $DIRS)"
    FILECOUNT=$((FILECOUNT+1))
    echo "Compressing directory for backup: $DIRS" >> $LOGS/backup_$FILE_DATE.log
    tar -czvf $LASTDIR.$FILE_DATE.tar.gz $DIRS
    echo "Copying $LASTDIR.$FILE_DATE.tar.gz to S3" >> $LOGS/backup_$FILE_DATE.log
    /home/backup/bin/aws s3 cp --sse --storage-class STANDARD_IA $LASTDIR.$FILE_DATE.tar.gz s3://$BUCKET-$HOSTNAME/$FILE_DATE/
    echo "Checking for successful transfer of backup" >> $LOGS/backup_$FILE_DATE.log
    TRANSFER=$(/home/backup/bin/aws s3 ls s3://$BUCKET-$HOSTNAME/$FILE_DATE/ | wc -l)
    if [ "$TRANSFER" -eq "$FILECOUNT" ]; then
      echo "Backup to S3 was successful" >> $LOGS/backup_$FILE_DATE.log
      rm $LASTDIR.$FILE_DATE.tar.gz
      touch /home/backup/backup.nagios
    else
      echo "Problem with S3 backup" >> $LOGS/backup_$FILE_DATE.log
      rm $LASTDIR.$FILE_DATE.tar.gz
      exit
    fi
    echo " " >> $LOGS/backup_$FILE_DATE.log

done < "$DIRECTORIES_TO_BACKUP"
