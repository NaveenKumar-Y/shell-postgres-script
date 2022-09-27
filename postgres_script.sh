#!/bin/bash

# install google cloud sdk 
apt install wget -y

wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-403.0.0-linux-x86_64.tar.gz

tar -xzf google-cloud-sdk-403.0.0-linux-x86_64.tar.gz

./google-cloud-sdk/install.sh --usage-reporting false --command-completion true --quiet 


# auth into gcloud account using service account
gcloud auth activate-service-account tachyons-srv-acc@gcp-hum-tachyons.iam.gserviceaccount.com --key-file=./serviceaccount.json

# copy postgres software from gcs bucket to current working directory
gsutil cp gs://postgresql_software/postgresql-14.5.tar.gz ./

# unpack the postgresql package
tar -xzf postgresql-14.5.tar.gz


# install neccessary packages for installation of postgres
apt install build-essential gcc-multilib zlib1g-dev libreadline-dev -y

# variables for postgres user and password
psqlUser="postgres"
psqlPassword="postgres"


# changing to postgres directory 
cd postgresql-14.5

# create a directory to install postgres files and configure to that directory using prefix
mkdir /opt/PostgreSQL-14.5/
./configure --prefix=/opt/PostgreSQL-14.5 --with-pgport=5432


# build and install postgresql using make command
make 
make install

# add postgres user and set password to it
sudo useradd -md /home/postgres/ -p $psqlPassword $psqlUser

echo "created user $psqlUser"

# make a directory which acts as an database cluster and changed owner to postgres user with permissions
mkdir -p /pgdatabase/data
chown -R $psqlUser /pgdatabase/data

# symlink to /usr/bin/psql from /opt
ln -s /opt/PostgreSQL-14.5/bin/psql /usr/bin/psql

# store password of user in a file
echo $psqlPassword > /home/pSql_password.txt

# Read database name and table name from the console.
echo "enter database name:"
read database_name
echo "enter table name:"
read table

# switch to postgres user and intialize database 
# using psql commands create database and a table.
su $psqlUser <<EOF 

# intializing the postgres 
/opt/PostgreSQL-14.5/bin/initdb -D /pgdatabase/data/ -U postgres -A md5 --pwfile=/home/pSql_password.txt

/opt/PostgreSQL-14.5/bin/pg_ctl -D /pgdatabase/data/ -l logfile start

# to see status of the postgres server 
netstat -apn |grep -i 5432

echo "database name is $database_name"
echo "table name is $table"

PGPASSWORD=$psqlPassword psql -U $psqlUser -p 5432 <<EOF2
CREATE DATABASE $database_name;
\c $database_name
create table $table(courseID int,rollno int,coursename varchar(20));
insert into $table values(1004,1,'java'),(1005,2,'sql'),(1005,3,'sql'),(1006,4,'linux'),(1004,5,'java'),(1007,9,'streamsets'),(1008,10,'kafka'),(1007,11,'streamsets');
\d
select * from $table;
EOF2

echo "created database $database_name and table $table in it"

EOF