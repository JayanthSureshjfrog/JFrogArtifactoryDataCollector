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

Similar to Artifactory, Below are the lists of supported/tested operating systems and the versions.

|      Product       |       Debian      |      Centos*       |        RHEL        |      Ubuntu        |    Amazon Linux    |
|--------------------|-------------------|--------------------|--------------------|--------------------|--------------------|
|    Artifactory     |      10.x,11.x    |       7.x          |     7.x,8.x,9.x    | 18.04, 20.04, 22.04|Amazon Linux 2023, Amazon Linux 2

**The script can also be triggered in the Artifactory Docker container and also the Artifactory container inside the pod in Kubernates cluster!**
