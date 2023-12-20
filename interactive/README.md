# How to run JFrogArtifactoryDataCollector
**Interactive way of running the script**
``` ./JFrogArtifactoryDataCollector.sh ```

Provide inputs to the script as show below:

```
./JFrogArtifactoryDataCollector.sh
###########################This script will not consider any default values, so please pass the values explicitly ###########################
PID file created...
Please enter the Artifactory Home path (The path till var and app folder, Ex: /opt/jfrog/artifactory):/opt/jfrog/artifactory
Please enter the target path to save the files (Ex: /tmp):/tmp
Please enter the DB port (Ex: 5432 for postgres or leave blank for derby DB):
Please enter the ticket number to upload the collected data to supportlogs.jfrog.com (leave blank to ignore the upload):1100
Would you like to capture the Heap Dump? It would consume extra resource and space (size of the max. heap size) - y/n : y
Would you like to capture the Disk throughput and latency? It would consume extra Server Memory - y/n : y
How many thread dumps would you like to take - (5 or 10): 10
Please specify the time interval between each thread dump - (5 or 10) in seconds: 10
```

**Run with command line arguments**

```./JFrogArtifactoryDataCollector.sh <<< $'<ARTIFACTORY_HOME_PATH>\n<FILE_PATH>\n<DB_PORT>\n<TICKET_NUMBER>\n<HEAP_DUMP_FLAG>\n<TD_COUNT>\n<TD_TIME_INTERVAL>\n' ```

**Example:**
``` ./JFrogArtifactoryDataCollector.sh <<< $'/opt/jfrog/artifactory\n/tmp\n0\n0\nn\n2\n2\n' ```


|         Parameter         |           Description             | 
|---------------------------|-----------------------------------|
| `ARTIFACTORY_HOME_PATH`        | Artifactory home path (EX:/opt/jfrog/artifactiry ) |
| `FILE_PATH`               | Folder path to store the extracted data (EX: /tmp) |
| `DB_PORT`     | DB port number used to connect to Artifactory DB server, can pass 0 for derby DB |
| `TICKET_NUMBER`     | Ticket number to upload the extracted data       |
| `HEAP_DUMP_FLAG`             | Flag to collect Heap Dump, vaules are y/n (yes/no) |
| `DISK_DETAILS_FLAG`             | Flag to collect Disk details, vaules are y/n (yes/no) |
| `TD_COUNT`         | Number of Thread dumps to be collected |
| `TD_TIME_INTERVAL`         | Time interval between Thread dumps |

**Run with configuration file**

``` <folder-name>/JFrogArtifactoryDataCollector.sh < <folder-name>/arguments.conf >> <folder-name>/output-$(date +\%F-\%R).log & ```

Using the above command we can configure the script in crontab to run the script on the required time.

**Example:** ``` */30 * * * * nohup <folder-name>/JFrogArtifactoryDataCollector.sh < <folder-name>/arguments.conf >> <folder-name>/output-$(date +\%F-\%R).log 2>&1 ```

Content of **arguments.conf** file

```
ARTIFACTORY_HOME_PATH 
FILE_PATH
DB_PORT
TICKET_NUMBER
HEAP_DUMP_FLAG
DISK_DETAILS_FLAG
TD_COUNT
TD_TIME_INTERVAL
```
**Example-1:** In this example, we are running the script where the Artifactory DB is default derby and do not want to uplaod the data to JFrog Support logs portal.so that the extarcted data will be in the FILE_PATH.
```
/opt/jfrog/artifactory 
/tmp
0
0
n
n
5
10
```

**Example-2:** In this example, we are running the script where the Artifactory DB is postgres and the ticket number is 123456. So that once the script is successfully completed then we are uploading the extracted data to JFrog Support logs portal, even a copy of the extracted data will be in FILE_PATH.
```
/opt/jfrog/artifactory 
/tmp
5432
123456
y
y
5
10
```

Similar to Artifactory, Below are the lists of supported/tested operating systems and the versions.

|      Product       |       Debian      |      Centos*       |        RHEL        |      Ubuntu        |    Amazon Linux    |
|--------------------|-------------------|--------------------|--------------------|--------------------|--------------------|
|    Artifactory     |      10.x,11.x    |       7.x          |     7.x,8.x,9.x    | 18.04, 20.04, 22.04|Amazon Linux 2023, Amazon Linux 2

**The script can also be triggered in the Artifactory Docker container and also the Artifactory container inside the pod in Kubernates cluster!**
