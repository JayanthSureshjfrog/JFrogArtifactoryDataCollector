# JFrogArtifactoryDataCollector
While dealing with support cases logged to investigate Artifactory performance issues, we would need the baseline information such as CPU, Memory, Disk utilization, thread dumps, etc and other server details to better understand the status of the concerned instance.
During the course of collecting the required details, we end up communicating it multiple times to and fro to gather all the details at once, especially when the customer is not familiar with the Linux tasks to gather the required information.

‘**JFrogArtifactoryDataCollector**’ would ease the information gathering process by capturing all the required baseline information at once and uploads it to the support logs portal. Executing the script against the system multiple times even during the Artifactory crash scenarios, would not do any harm to the system.


**Points to be noted before running the script:**
1. Collecting heap dump (HEAP_DUMP_FLAG) and disk details (DISK_DETAILS_FLAG) are resource consuming, so please opt for it, if its required and the Artifactory server have enough memeory available, There are chances that the Artifactory might crash, if these 2 options are opted when the Artifactory server doesn’t have enough memeory available.
2. When the script starts running in the Artifactory server, a PID file (JFrogArtifactoryDataCollector.pid) will be created in the **/tmp** folder of the Artifactory server. Once the script is successfully completed then the PID file will be deleted. In case if the script is already running then we need to wait for the current script to complete to run it again.
3. When the script is running, if we would like to cancel it or was interrupted in between due to some reasons then the PID file will not be deleted, so in this situations, we need to kill the process of the script , delete PID file and run again.



**Note**: This script does not need any extra library (third party-library) to capture the below data which means the customer can simply run this script in the Artifactory server and script will use the OS default libraries and collect the data.

1. Thread_dump.
2. Heap_dump on request as its resource/space consuming.
3. Java_Heap_Histograms.
4. CPU % utilized by each process.
5. Memory % utilized by each process.
6. Artifactory Server details like Memory,CPU,Disk,File limits and processes running.
7. Disk throughput and latency.
8. Connection to the server Details.
9. List of open port details.
10. Artifactory Readiness and Health check of each microservice.
11. Environment Variables.
