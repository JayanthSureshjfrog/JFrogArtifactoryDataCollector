#!/bin/bash
# JFrog hereby grants you a non-exclusive, non-transferable, non-distributable right to use this  code   solely in connection with your use of a JFrog product or service. This  code is provided 'as-is' and without any warranties or conditions, either express or implied including, without limitation, any warranties or conditions of title, non-infringement, merchantability or fitness for a particular cause. Nothing herein shall convey to you any right or title in the code, other than for the limited use right set forth herein. For the purposes hereof "you" shall mean you as an individual as well as the organization on behalf of which you are using the software and the JFrog product or service. 

TIMESTAMP=$(date +%Y%m%d%H%M%S)
pid_file="/tmp/JFrogArtifactoryDataCollector.pid"
PROPERTY_FILE="JFrogArtifactoryDataCollector.properties"

create_pid_file()
{
	echo $$ > $pid_file
	echo -e "\e[1;33mPID file created...\e[0m";
}

delete_pid_file()
{
	rm $pid_file
	echo -e "\e[1;32mPID file deleted.... \e[0m";
}

create_folder()
{
	if [[ -d "$FILE_PATH/Artifactory_details" ]]
	then
        rm -rf  $FILE_PATH/Artifactory_details
	mkdir $FILE_PATH/Artifactory_details && chmod 777 $FILE_PATH/Artifactory_details
	#cp $FILE_PATH/Artifactory_details.tar.gz $FILE_PATH/Artifactory_details-BackupCreatedAt-$TIMESTAMP.tar.gz
	else
	## RHEL 8.x OS need full permission on the folder to create hdump.hprof file
        mkdir $FILE_PATH/Artifactory_details && chmod 777 $FILE_PATH/Artifactory_details
	fi
}

collect_thread_dump()
{
	for ((count=1; count <= $TD_COUNT; count++));
	do $ARTIFACTORY_HOME_PATH/app/third-party/java/bin/jstack -l $(pidof java)  &> "$FILE_PATH/Artifactory_details/artifactory.$(date +%Y%m%d%H%M%S).td"
	echo "Created" $count "ThreadDump";
	sleep "$TD_TIME_INTERVAL"s; 
	done;
}

archive_files()
{
	tar -zcvf $FILE_PATH/Artifactory_details-$TIMESTAMP.tar.gz $FILE_PATH/Artifactory_details/
	sleep 30s;
}

mem-cpu_utilization()
{
	printf "==================== Memory and CPU Percentage per process ===================\n" > $FILE_PATH/Artifactory_details/mem-cpu_utilization.txt
	ps -eo pid,ppid,user,%mem,%cpu,start,time,args --sort=-%mem | head >> $FILE_PATH/Artifactory_details/mem-cpu_utilization.txt
	#ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10 >> $FILE_PATH/Artifactory_details/procress_cpu_utilization.txt
	#ps -eo pcpu,pid,user,args --sort -pid &>> $FILE_PATH/Artifactory_details/procress_cpu_utilization.txt
	#echo "====================Memory Percentage per process ===================" >> $FILE_PATH/Artifactory_details/procress_memory_utilization.txt
	#echo "Process          %MEM" &>> $FILE_PATH/Artifactory_details/procress_memory_utilization.txt
	#ps -eocomm,pmem | egrep -v '(0.0)|(%MEM)'| sort -nrk 2 | head >> $FILE_PATH/Artifactory_details/procress_memory_utilization.txt
	#ps -eo pmem,comm,pid,rss,vsz --sort -rss &>> $FILE_PATH/Artifactory_details/procress_memory_utilization.txt
	#echo "====================List of procress consuming cpu===================" >> $FILE_PATH/Artifactory_details/procress_cpu_utilization.txt
	#echo "Process          %CPU" >> $FILE_PATH/Artifactory_details/procress_cpu_utilization.txt
	#ps -eocomm,pcpu | egrep -v '(0.0)|(%CPU)' | sort -nrk 2 | head >> $FILE_PATH/Artifactory_details/procress_cpu_utilization.txt

}

Server_details()
{

	printf "====================Resource Utilization=================== \n" > $FILE_PATH/Artifactory_details/Server_details.txt
	free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }' >> $FILE_PATH/Artifactory_details/Server_details.txt
	top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}' >> $FILE_PATH/Artifactory_details/Server_details.txt
	printf " \n====================Disk Utilization=================== \n" >> $FILE_PATH/Artifactory_details/Server_details.txt
	df -h >> $FILE_PATH/Artifactory_details/Server_details.txt
	printf " \n====================Server Timezone=================== \n" >> $FILE_PATH/Artifactory_details/Server_details.txt
	date +"%Z" >> $FILE_PATH/Artifactory_details/Server_details.txt
	printf " \n====================OS details=================== \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
	cat /etc/os-release >> $FILE_PATH/Artifactory_details/Server_details.txt;
	printf " \n====================CPU details=================== \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
	lscpu | egrep 'Architecture|Model name|Socket|Thread|NUMA|CPU\(s\)' >> $FILE_PATH/Artifactory_details/Server_details.txt;
	printf " \n====================Swap memeory usage=================== \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
	grep '^Swap' /proc/meminfo >> $FILE_PATH/Artifactory_details/Server_details.txt;
	printf " \n====================Open file details=================== \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
	#ARTIFACTORY_USER=`ps -ef|grep -i "artifactory"|ps -eo user|tail -1`
	printf "Number of open files limit: `ulimit -n` \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
	printf "The hard limit for the given resource: `ulimit -H` \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
        printf "The soft limit for the given resource: `ulimit -S` \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
	printf "User can open `cat /proc/sys/fs/file-max` file per user login session \n" >> $FILE_PATH/Artifactory_details/Server_details.txt;
	printf " \n====================Running Linux processes=================== \n" >> $FILE_PATH/Artifactory_details/Server_details.txt
	top -b -n 1 >> $FILE_PATH/Artifactory_details/Server_details.txt

}

Disk_details()
{

	printf "==================Server throughput disk write speed================= \n" >> $FILE_PATH/Artifactory_details/Disk_details.txt
	dd if=/dev/zero of=/tmp/test1.img bs=1G count=1 oflag=dsync  &>> $FILE_PATH/Artifactory_details/Disk_details.txt
	rm -rf /tmp/test1.img
	# sleep 25s;
	printf "\n==================Server latency=================\n" >> $FILE_PATH/Artifactory_details/Disk_details.txt
	dd if=/dev/zero of=/tmp/test2.img bs=512 count=1000 oflag=dsync  &>> $FILE_PATH/Artifactory_details/Disk_details.txt
	rm -rf /tmp/test2.img
	# sleep 10s;
	
}

Java_Heap_Histograms()
{
	$ARTIFACTORY_HOME_PATH/app/third-party/java/bin/jmap -histo $(pidof java) &> $FILE_PATH/Artifactory_details/Java_Heap_Histograms.file
	sleep 15s;
}

Heap_Dump()
{
	echo "==================Java Dump=================" >> $FILE_PATH/Artifactory_details/Heap_Dump_status.txt
	$ARTIFACTORY_HOME_PATH/app/third-party/java/bin/jmap -dump:live,format=b,file="$FILE_PATH/Artifactory_details/hdump.hprof" $(pidof java) &>> $FILE_PATH/Artifactory_details/Heap_Dump_status.txt
	sleep 25s;
}

Connection_Details()
{
	printf "==================Summary of connections in the server=================\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	netstat -a | grep -e tcp | awk '{print $1,$6}' | sort | uniq -c >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n==================Connections per process=================\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "==================Connections of java=====================\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof java) >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n Total java connections is `netstat -ntlpea | grep $(pidof java) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	printf "\n==================Connections of JFrog-Router===============\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof jf-router) >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n Total JFrog-Router connections is `netstat -ntlpea | grep $(pidof jf-router) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
   	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n==================Connections of JFrog-Metadata===============\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof jf-metadata) >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n Total JFrog-Metadata connections is `netstat -ntlpea | grep $(pidof jf-metadata) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n==================Connections of JFrog-Event==================\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof jf-event) >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n Total JFrog-Event connections is `netstat -ntlpea | grep $(pidof jf-event) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n==================Connections of JFrog-Frontend================\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof node) >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n Total JFrog-Frontend connections is `netstat -ntlpea | grep $(pidof node) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n==================Connections of JFrog-Observability=============\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof jf-observability) >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n Total JFrog-Observability connections is `netstat -ntlpea | grep $(pidof jf-observability) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n==================Connections of JFrog-Connect===================\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof jf-connect) >> $FILE_PATH/Artifactory_details/Connections_Info.txt	
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n Total JFrog-Connect connections is `netstat -ntlpea | grep $(pidof jf-connect) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
  	printf "\n==================Connections of JFrog-Integration=================\n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | head -2 >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	netstat -ntlpea | grep $(pidof jf-integration) >> $FILE_PATH/Artifactory_details/Connections_Info.txt
 	printf "=======================================================" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
	printf "\n Total JFrog-Integration connections is `netstat -ntlpea | grep $(pidof jf-integration) | wc -l`" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
   	printf "\n======================================================= \n" >> $FILE_PATH/Artifactory_details/Connections_Info.txt
    
	# printf "==================HTTP connections on 8081 port=================\n" >> $FILE_PATH/Artifactory_details/Threads_Info.txt
	# for ((count=1; count <= 10; count++));
	# do printf " \n $(date)  HTTP Connections : $(netstat -latuen | grep 8081 | wc -l) \n "  >> $FILE_PATH/Artifactory_details/Threads_Info.txt
	# done;
	# printf "\n==================HTTP connections on 8040 port=================\n" >> $FILE_PATH/Artifactory_details/Threads_Info.txt
	# for ((count=1; count <= 10; count++));
	# do printf " \n $(date)  HTTP Connections : $(netstat -latuen | grep 8040 | wc -l) \n "  >> $FILE_PATH/Artifactory_details/Threads_Info.txt
	# done;
}

Database_Connections()
{
	printf "==================Active DB connections while runnig the script=================\n" >> $FILE_PATH/Artifactory_details/DB_connections.txt
 	netstat -latuen | head -2 >> $FILE_PATH/Artifactory_details/DB_connections.txt
 	netstat -latuen | grep $DB_PORT | grep -v '127.0.0.1' >> $FILE_PATH/Artifactory_details/DB_connections.txt
 	printf "==================Active DB connections count with 5 seconds time interval=================\n" >> $FILE_PATH/Artifactory_details/DB_connections.txt
	for ((count=1; count <= 10; count++));
	do printf "$(date)  DB Connections : $(netstat -latuen | grep $DB_PORT | grep -v '127.0.0.1' | wc -l) \n "  &>> $FILE_PATH/Artifactory_details/DB_connections.txt
 	sleep 5s;
	done;
}

Listen_Ports()
{
	printf "==================LISTEN Ports=================\n" >> $FILE_PATH/Artifactory_details/open_ports.txt
	printf " \n $(netstat -tulpn | head -2) " >> $FILE_PATH/Artifactory_details/open_ports.txt
	printf " \n $(netstat -tulpn | grep LISTEN) \n " >> $FILE_PATH/Artifactory_details/open_ports.txt
}


HealthCheck()
{
	printf "==================Artifactory HealthCheck=================\n" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "$(date) \n" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "Microservice    Status" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf " \n Artifactory   $(curl -s -o /dev/null -w '%{http_code}' localhost:8081/artifactory/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Router         $(curl -s -o /dev/null -w '%{http_code}' localhost:8082/router/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Access         $(curl -s -o /dev/null -w '%{http_code}' localhost:8040/access/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Metadata       $(curl -s -o /dev/null -w '%{http_code}' localhost:8086/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Frontend       $(curl -s -o /dev/null -w '%{http_code}' localhost:8070/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Event          $(curl -s -o /dev/null -w '%{http_code}' localhost:8061/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Observability  $(curl -s -o /dev/null -w '%{http_code}' localhost:8036/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Integration    $(curl -s -o /dev/null -w '%{http_code}' localhost:8071/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n JFconnect      $(curl -s -o /dev/null -w '%{http_code}' localhost:8030/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n MissionControl $(curl -s -o /dev/null -w '%{http_code}' localhost:8091/mc/api/v1/system/readiness)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	printf "\n Router HealthCheck: \n $(curl -s  http://localhost:8082/router/api/v1/system/health)" >> $FILE_PATH/Artifactory_details/artifactory-healthcheck.log;
	sleep 15s;
}

upload_data()
{
	
	#cp $FILE_PATH/Artifactory_details.tar.gz $FILE_PATH/Artifactory_details-$(date +%Y%m%d%H%M%S).tar.gz
	#else
	curl -i -T $FILE_PATH/Artifactory_details-$TIMESTAMP.tar.gz "https://supportlogs.jfrog.com/logs/$TICKET_NUMBER/" &>> $FILE_PATH/Artifactory_details/upload_data.log;
	sleep 30s;
	#fi
}

Check_Before_Run()
{
    if [[ -f ${pid_file} ]]; then
    echo -en "\e[1;31mLooks like JFrogArtifactoryDataCollector script is running or the previous run was not succesful, please wait for the script to complete or kill the process of the script or delete /tmp/JFrogArtifactoryDataCollector.pid file and run again \e[0m \n" 
	exit 1
    fi
}

###################################
# Main body of script starts here #
###################################
Check_Before_Run
echo -e "\e[1;33mBelow are the values that are passed in the prorpeties file for this script\e[0m";
function getProperty  { grep "${1}" ${PROPERTY_FILE} | cut -d'=' -f2 
}
ARTIFACTORY_HOME_PATH=$(getProperty 'artifactory_home_path')
echo -e "\e[1;32mArtifactory Home Path value is\e[0m $ARTIFACTORY_HOME_PATH"
if [ ! -d $ARTIFACTORY_HOME_PATH ]; then 
echo -en "\e[1;31m $ARTIFACTORY_HOME_PATH path does not exist\e[0m"
exit 1 
fi
FILE_PATH=$(getProperty 'file_path')
echo -e "\e[1;32mFile Path value is\e[0m $FILE_PATH"
if [ ! -d $FILE_PATH ]; then 
echo -en "\e[1;31m $FILE_PATH path does not exist\e[0m"
exit 1 
fi
DB_PORT=$(getProperty 'db_port')
echo -e "\e[1;32mDB Port value is\e[0m $DB_PORT"
TICKET_NUMBER=$(getProperty 'ticket_number')
echo -e "\e[1;32mTicket Number value is\e[0m $TICKET_NUMBER"
HEAP_DUMP_FLAG=$(getProperty 'heap_dump_flag')
echo -e "\e[1;32mHeap Dump Flag value is\e[0m $HEAP_DUMP_FLAG"
DISK_DETAILS_FLAG=$(getProperty 'disk_details_flag')
echo -e "\e[1;32mDisk Details Flag value is\e[0m $DISK_DETAILS_FLAG"
TD_COUNT=$(getProperty 'td_count')
echo -e "\e[1;32mThread Dump Count value is\e[0m $TD_COUNT"
if [ -z $TD_COUNT ] || [ $TD_COUNT -lt 0 ];then
echo -en "\e[1;31m Invalid or NULL value, please pass the value greater then zero \e[0m" 
exit 1
fi
TD_TIME_INTERVAL=$(getProperty 'td_time_interval')
echo -e "\e[1;32mThread Dump Time Interval value is\e[0m $TD_TIME_INTERVAL"
if [ -z $TD_TIME_INTERVAL ] || [ $TD_TIME_INTERVAL -lt 0 ];then
echo -en "\e[1;31m Invalid or NULL value, please pass the value greater then zero \e[0m" 
exit 1
fi
echo -en "\e[1;33mScript started at $(date)\e[0m \n"
create_pid_file
echo -e "\e[1;33mStarted Creating the required folder for saving the files\e[0m";
create_folder
echo -e "\e[1;32mFinished Creating the required folder for saving the files\e[0m";
echo -e "\e[1;33mStarted Gathering the Artifactory server details\e[0m";
Server_details
echo -e "\e[1;32mCompleted Gathering the Artifactory server details\e[0m";
if [[ $DISK_DETAILS_FLAG = "y" ]];then
	echo -e "\e[1;33mStarted Gathering the Artifactory disk details\e[0m";
	Disk_details
	echo -e "\e[1;32mCompleted Gathering the Artifactory disk details\e[0m";
fi
echo -e "\e[1;33mStarted collected the thread dump...\e[0m";
collect_thread_dump
echo -e "\e[1;32mCompleted collecting the thread dump...\e[0m";
echo -e "\e[1;33mStarted Gathering the data of Running Processes in the Artifactory server\e[0m";
mem-cpu_utilization
echo -e "\e[1;32mCompleted Gathering the data of Running Processes in the Artifactory server\e[0m";
echo -e "\e[1;33mStarted Gathering Java Heap Histograms in the Artifactory server\e[0m";
Java_Heap_Histograms
echo -e "\e[1;32mCompleted Gathering Java Heap Histograms in the Artifactory server\e[0m";
if [[ $HEAP_DUMP_FLAG = "y" ]];then
	echo -e "\e[1;33mStarted Gathering Heap Dump in the Artifactory server\e[0m";
	Heap_Dump
	echo -e "\e[1;32mCompleted Gathering Heap Dump in the Artifactory server\e[0m";
fi
echo -e "\e[1;33mStarted Gathering the Connections in the Artifactory server\e[0m";
Connection_Details
echo -e "\e[1;32mCompleted Gathering Threads Connections in the Artifactory server\e[0m";
if [[ $DB_PORT -gt 0 ]];then
	echo -e "\e[1;33mStarted Gathering Database Connections in the Artifactory server\e[0m";
	Database_Connections
	echo -e "\e[1;32mCompleted Gathering Database Connections in the Artifactory server\e[0m";
fi
echo -e "\e[1;33mStarted Gathering HealthCheck of the Artifactory\e[0m";
HealthCheck
echo -e "\e[1;32mCompleted Gathering HealthCheck of the Artifactory\e[0m";
echo -e "\e[1;33mStarted Gathering Open Ports in the Artifactory server\e[0m";
Listen_Ports
echo -e "\e[1;32mCompleted Gathering Open Ports in the Artifactory server\e[0m";
echo -e "\e[1;33mStarted archiving all the files...\e[0m" ;
archive_files
echo -e "\e[1;32mCompleted archiving all the files...\e[0m";
if [[ $TICKET_NUMBER -gt 0 ]];then
STATUS=$(curl -s -o /dev/null -w "%{http_code}" 'https://supportlogs.jfrog.com/artifactory/api/system/ping')
	if [[ $STATUS == 200 ]]; then
	echo -e "\e[1;33mUploading the collected data to supportlogs.jfrog.com\e[0m" ;
	upload_data
	echo -e "\e[1;32mFinished uploading the collected data to supportlogs.jfrog.com\e[0m";
    else
    echo -e "\e[1;33munable to connect to supportlogs.jfrog.com, so the upload failed,but the archive is in $FILE_PATH path\e[0m";
	fi
fi
delete_pid_file
echo -en "\e[1;33mScript completed at $(date) \e[0m \n"
