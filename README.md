# Postgres installation script

## Description:

 script to install postgresqldb by getting the software from the bucket and create a demo db and a table on it


## How to run
- Add serviceaccount JSON file to the directory.
- Download the postgres software in a bucket and give bucket location in the script file and run the script file "postgres_script.sh" with sudo privaliages.
- Postgres server will be installed and started when the script get executed.
- Enter sample database name and table name to be created in the Postgres server.

## Steps used in script file to install postgres:

- Install gcloud sdk in the local machine by downloading latest sdk.
- Unpack the files in the downloaded sdk file.
- Run the "install.sh" file inside the "google-cloud.sdk" directory to install the sdk in the local system. 

```
# install google cloud sdk 

apt install wget -y
wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-403.0.0-linux-x86_64.tar.gz
tar -xzf google-cloud-sdk-403.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh --usage-reporting false --command-completion true --quiet 
```

#### Sample output:



```
https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-403.0.0-linux-x86_64.tar.gz
Resolving dl.google.com (dl.google.com)... 209.85.200.93, 209.85.200.190, 209.85.200.136, ...
Connecting to dl.google.com (dl.google.com)|209.85.200.93|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 161590807 (154M) [application/gzip]
Saving to: ‘google-cloud-sdk-403.0.0-linux-x86_64.tar.gz’

google-cloud-sdk-403.0.0-li 100%[==========================================>] 154.10M   322MB/s    in 0.5s    

2022-09-27 08:56:25 (322 MB/s) - ‘google-cloud-sdk-403.0.0-linux-x86_64.tar.gz’ saved [161590807/161590807]

Welcome to the Google Cloud CLI!
```
- Authenticate into gcloud using service account and copy the postgres software from the bucket to present working directory.
- Unpack the postgresql file.
```
# auth into gcloud account using service account
gcloud auth activate-service-account tachyons-srv-acc@gcp-hum-tachyons.iam.gserviceaccount.com --key-file=./serviceaccount.json

# copy postgres software from gcs bucket to current working directory
gsutil cp gs://postgresql_software/postgresql-14.5.tar.gz ./

# unpack the postgresql package
tar -xzf postgresql-14.5.tar.gz
```

#### Sample output:
```
Activated service account credentials for: [tachyons-srv-acc@gcp-hum-tachyons.iam.gserviceaccount.com]
Copying gs://postgresql_software/postgresql-14.5.tar.gz...
/ [1 files][ 27.6 MiB/ 27.6 MiB]                                                
Operation completed over 1 objects/27.6 MiB.   
```
- Install the required packages for installing postgres.
- Declare variables for username and password for the user.
- By switching to the user, we can use the postgresql.
``` 
apt install build-essential gcc-multilib zlib1g-dev libreadline-dev -y

# variables for postgres user and password
psqlUser="postgres"
psqlPassword="*****"
```
- Create a directory where you want to install postgres files and use prefix option with configure.
``` 
# changing to postgres directory 
cd postgresql-14.5

# create a directory to install postgres files and configure to that directory using prefix
mkdir /opt/PostgreSQL-14.5/
./configure --prefix=/opt/PostgreSQL-14.5 --with-pgport=5432
```
- Build postgreSQL using following make command.
- After build process finishes, now install postgresql using following command.
``` 
make 
make install
```
- Add a user with password.
- Make a directory which acts as a database cluster and change own permissions to postgres user.
```   
sudo useradd -md /home/postgres/ -p $psqlPassword $psqlUser

echo "created user $psqlUser"

mkdir -p /pgdatabase/data
chown -R $psqlUser /pgdatabase/data
```
- Provide a symlink to psql in bin folder from installed directory, so that psql can be accessed from anywhere.
- Store the pSql password in a file, which later used to intialize DB.
``` 
# symlink to /usr/bin/psql from /opt
ln -s /opt/PostgreSQL-14.5/bin/psql /usr/bin/psql

# store password of user in a file
echo $psqlPassword > /home/pSql_password.txt
```
- Read database name and table name from the console.
```
echo "enter database name:"
read database_name
echo "enter table name:"
read table
```
#### Sample output:
```
enter database name:
demo_db
enter table name:
student_course
```

- Switch to postgres user and initialize the database.
- After switching to user HERE document was written to execute all the commands in the user shell.
``` 
su $psqlUser <<EOF 

# intializing the postgres 
/opt/PostgreSQL-14.5/bin/initdb -D /pgdatabase/data/ -U postgres -A md5 --pwfile=/home/pSql_password.txt
```
#### Sample output:
```
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "C.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /pgdatabase/data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Etc/UTC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

Success.
```

- Start the log file to start the server.
``` 
> /opt/PostgreSQL-14.5/bin/pg_ctl -D /pgdatabase/data/ -l logfile start
```
#### Sample output:
```
waiting for server to start.... done
server started
```
- To check status of the postgres server use netstat command.
```  
> netstat -apn |grep -i 5432
```
#### Sample output:
```
tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      17799/postgres      
tcp6       0      0 ::1:5432                :::*                    LISTEN      17799/postgres      
unix  2      [ ACC ]     STREAM     LISTENING     24767    17799/postgres       /tmp/.s.PGSQL.5432
```
- Switch into psql terminal to run the sql queries to create database & a table in it.
- Another HERE document to run series of queries in the psql terminal.
- Create a database and connect to that database using **"\c"** psql command.
``` 
echo "database name is $database_name"
echo "table name is $table"

PGPASSWORD=$psqlPassword psql -U $psqlUser -p 5432 <<EOF2
CREATE DATABASE $database_name;
\c $database_name
```
#### sample output:
```
database name is demo_db
table name is student_course
CREATE DATABASE
You are now connected to database "demo_db" as user "postgres".
```
- Now create a table with data types and insert some data into the table.
- **"\d"** to display all the relations in the database.
```
create table $table(courseID int,rollno int,coursename varchar(20));
insert into $table values(1004,1,'java'),(1005,2,'sql'),(1005,3,'sql'),(1006,4,'linux'),(1004,5,'java'),(1007,9,'streamsets'),(1008,10,'kafka'),(1007,11,'streamsets');
\d
```

#### Sample output:
```
CREATE TABLE
INSERT 0 8
             List of relations
 Schema |      Name      | Type  |  Owner   
--------+----------------+-------+----------
 public | student_course | table | postgres
(1 row)
```
- Fetch the data from the created table and print the data.
```
select * from $table;
EOF2

echo "created database $database_name and table $table in it"
```
#### Final Result:
```
 courseid | rollno | coursename 
----------+--------+------------
     1004 |      1 | java
     1005 |      2 | sql
     1005 |      3 | sql
     1006 |      4 | linux
     1004 |      5 | java
     1007 |      9 | streamsets
     1008 |     10 | kafka
     1007 |     11 | streamsets
(8 rows)

created database demo_db and table student_course in it.
```