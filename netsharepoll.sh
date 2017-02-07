#!/usr/bin/env bash

# netsharepoll.sh
# https://github.com/mvarian/netsharepoll
# MIT License

# Configure NETSHARE for your situation
NETSHARE="\\\\WINDOWS-SERVER\SHARE-NAME"
USERNAME="USER"
PASSWORD="PASSWORD"

# Configure the remote files, these files must exist on the network share
REMOTEFILES=('\folder\remotefile1.txt' '\folder\remotefile2.txt' '\folder\remotefile3.txt')

# Set ping interval in seconds
INVERVAL=60

# Set destination log file
LOGPATH="$NETSHARE-netshare_poll.log.csv"

# Used to track execution of this unique script to ensure only one instance is running at a time
PIDFILE="$NETSHARE-netsharepoll.sh.pid"


#================ Code below is not meant to be modified ================#

if [ -f $PIDFILE ] 
then
	echo "[$(date)] : netsharepoll.sh : Script is already running for $NETSHARE"
	exit 1
fi

# Ensure PID file is removed on program exit.
trap "rm -f -- '$PIDFILE'" EXIT

# Create a file with current PID to indicate that process is running.
echo $$ > "$PIDFILE"


# If log file does not yet exist, initialize it with column headers
if [ ! -f $LOGPATH ] 
then
	echo '"Network Share","Remote File","Timestamp","Duration"' > $LOGPATH
fi

# Array counters
ARRAYSIZE=${#REMOTEFILES[*]}
ARRAYINDEX=0

# Infinite loop to record the latency of a ping every INTERVAL until script is aborted
while [ true ] 
do

	RFILE=${REMOTEFILES[$ARRAYINDEX]}

	# Start timer
	STIME=$(date +%s.%N)

	# Execute network share remote file read
	RESULT=`smbclient "$NETSHARE" -U "$USERNAME%$PASSWORD" -c "get \"$RFILE\""`

	# End timer
	ETIME=$(date +%s.%N)
	
	# Wrap-up
	DURATION=`echo - | awk "{print $ETIME - $STIME}"`

	if [[ "$RESULT" == *"NT_STATUS_BAD_NETWORK_NAME"* ]] 
	then
		DURATION="CONNECT FAIL"
	fi

	if [[ "$RESULT" == *"NT_STATUS_OBJECT_NAME_NOT_FOUND"* ]] 
	then
		DURATION="MISSING"
	fi

	if [[ "$RESULT" == *"NT_STATUS"* ]] 
	then
		DURATION="FAIL"
	fi

	if [ -z "$DURATION" ] 
	then
		DURATION="FAIL"
	fi

	if [ -f "$RFILE" ] 
	then
		rm $RFILE
	fi

	# Log results
	NOW=`date +'%F %H:%M:%S'`
	echo "\"$NETSHARE\",\"$RFILE\",\"$NOW\",\"$DURATION\"" >> "$LOGPATH"
	
	# Increment current index
	((ARRAYINDEX=ARRAYINDEX+1))

	# Reset index to 0 if we've made it all the way around to prevent integer overflow on counter
	if [ $((ARRAYINDEX)) -eq $((ARRAYSIZE)) ] 
	then
		ARRAYINDEX=0
	fi

	# Pause until next interval
	sleep "$INVERVAL"

done
