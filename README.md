# S3backup

Shell script that utilizes AWSCLI to read a manifest file of directories a user would want to back up to an AWS S3 Bucket.
The script compresses the entire directory into tar.gz format and has error checking of file transfer to the S3 Bucket.
It also touches a nagios file that could be used with a plugin such as check_file_age to monitor if it was run for example as a nightly cron job. 

