# netsharepoll
A simple shell script to connect to a network share and read a remote file at a specified interval, useful for generating baseline data on the performance of the network share for troubleshooting purposes.



## Features

* Designed to be deployed into a client environment and gather basic performance metrics by reading from one or more network shares.  
* Will connect to a network share at the configured interval, navigate to a directory, and read the contents of a specified file.
* Supports accepting an array of multiple remote file locations which are read in a round robin format on each iteration of the script.
* Data is appended to a log file in csv format with the network share, remote file, timestamp, and duration in ms of the operation.  
* If the remote read fails, "FAIL" will be inserted for the duration value.
* If the remote file does not exist, "MISSING" will be inserted for the duration value.
* If the remote connection cannot be established, "CONNECT FAIL" will be inserted for the duration value.
* Script will make sure that only one instance is running at one time, if it is executed multiple times the subsequent executions will abort.
* For unattended execution, schedule the script to run every minute in cron.  The script will automatically begin on boot, and if it crashes it will resume within 60 seconds.
* To fetch log files remotely, consider scheduled mailx, mutt, or scp to a remote server.  Alternatively, set up a basic samba share and fetch from another machine on the network.
* Currently supports smb only (Windows shares)


## Usage

1. In `netsharepoll.sh`, configure NETSHARE, USERNAME, PASSWORD, REMOTEFILES, and INTERVAL.

2. Run `netsharepoll.sh` in a terminal session, or schedule it to run in cron.

3. `netsharepoll.sh` will continue to run until killed.  Output is written in csv format in LOGPATH and can be opened by any spreadsheet program.

To gather data on a second server simultaneously, make a copy of `netsharepoll.sh`, change the NETSHARE, USERNAME, PASSWORD, and REMOTEFILES variables so they are different, and run as normal.


## Supported Platforms

netsharepoll has only been tested on CentOS 7.  It should also work on any other Redhat-compatible Linux distribution.