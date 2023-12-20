# Run JFrogArtifactoryDataCollector in a non-interactive way

Please place both JFrogArtifactoryDataCollector.sh and JFrogArtifactoryDataCollector.properties file in the same location and add the required parameters in the properties file 
and run the script.

*Command*
``` ./JFrogArtifactoryDataCollector.sh ```

Below are the sample paramters to the script:

```
## THIS IS A PROPERTIES FILE FOR JFrogArtifactoryDataCollector
## Please enter the Artifactory Home path (The path till var and app folder, Ex: /opt/jfrog/artifactory)
artifactory_home_path=/opt/jfrog/artifactory
## Please enter the target path to save the files (Ex: /tmp)
file_path=/tmp
## Please enter the DB port (Ex: 5432 for postgres or leave blank for derby DB)
db_port=0
##Please enter the ticket number to upload the collected data to supportlogs.jfrog.com (leave blank to ignore the upload)
ticket_number=0
## If you would like to capture the Heap Dump? It would consume extra resource and space (size of the max. heap size) - y/n
heap_dump_flag=n
## If you would you like to capture the Disk throughput and latency? It would consume extra Server Memory - y/n
disk_details_flag=n
## How many thread dumps would you like to take - (5 or 10)
td_count=5
## Please specify the time interval between each thread dump - (5 or 10) in seconds
td_time_interval=10
```

Similar to Artifactory, Below are the lists of supported/tested operating systems and the versions.

|      Product       |       Debian      |      Centos*       |        RHEL        |      Ubuntu        |    Amazon Linux    |
|--------------------|-------------------|--------------------|--------------------|--------------------|--------------------|
|    Artifactory     |      10.x,11.x    |       7.x          |     7.x,8.x,9.x    | 18.04, 20.04, 22.04|Amazon Linux 2023, Amazon Linux 2

**The script can also be triggered in the Artifactory Docker container and also the Artifactory container inside the pod in Kubernates cluster!**
