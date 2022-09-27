# Postgres installation script

## Description:

 script to install postgresqldb by getting the software from the bucket and create a demo db and a table on it
<br> </br>

## How to run
- Add serviceaccount JSON file to the directory and run the script file "postgres_script.sh" with sudo privaliages.

## Steps used in script file:

- Install 

```
# install google cloud sdk 
apt install wget -y

wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-403.0.0-linux-x86_64.tar.gz

tar -xzf google-cloud-sdk-403.0.0-linux-x86_64.tar.gz

./google-cloud-sdk/install.sh --usage-reporting false --command-completion true --quiet 
```

### Sample output:

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



```
Activated service account credentials for: [tachyons-srv-acc@gcp-hum-tachyons.iam.gserviceaccount.com]
Copying gs://postgresql_software/postgresql-14.5.tar.gz...
/ [1 files][ 27.6 MiB/ 27.6 MiB]                                                
Operation completed over 1 objects/27.6 MiB.   
```


```
enter database name:
demo_db
enter table name:
student_course
```



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
#### logfile start
```
waiting for server to start.... done
server started

```

```
tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      17799/postgres      
tcp6       0      0 ::1:5432                :::*                    LISTEN      17799/postgres      
unix  2      [ ACC ]     STREAM     LISTENING     24767    17799/postgres       /tmp/.s.PGSQL.5432
```

![](images/database_table_output.png)  
```

```