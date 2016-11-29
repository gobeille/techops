#!nsh -x
#########################################################################################################################
# Audit Sudo
#
# Scott Gobeille - November 2016
#
# This job collects host OS and OS Version 
# 
# 
#
# Parameters
#
#	REPORT_DESTINATION_PATH 
#		The NSH path, including host, where reports will go.
#		Default : //alprut01-m/usr/local/app/techops/auth_files
#	  
#########################################################################################################################




echo "REPORT_DESTINATION_PATH = $REPORT_DESTINATION_PATH" 

# These two reports will contain this data:

#            host/sudo report to contain 
#                        OS
#                        OS version
#                        active sudo binaries
#                        sudo versions
#                        active sudoers paths

#            sudoers report to contain
#                        sudoers path
#                        each line from sudoers omitting comments and blank lines

# The name of the host for each report will be in the name of the report as defined below.

DATE_STAMP=`date +%Y%m%d`
HOST_INFO_REPORT=$REPORT_DESTINATION_PATH/$NSH_RUNCMD_HOST.host_info.$DATE_STAMP


echo "HOST_INFO_REPORT = $HOST_INFO_REPORT"

# Delete any previous version of the report created today. This is to ensure each report is fresh with no duplicates
rm $SUDO_REPORT $SUDOERS_REPORT $HOST_INFO_REPORT
touch $SUDO_REPORT $SUDOERS_REPORT $HOST_INFO_REPORT


write_host_info_report ()
{
	# Capture to variables
	#   current OS
	#   current OS version
	
	OS=`uname -s`
	OS_VERSION=`uname -r`
	
	echo "OS = $OS"
	echo "OS_VERSION = $OS_VERSION"
	
	echo "${OS}${FD}${OS_VERSION}" > $HOST_INFO_REPORT

}

write_host_info_report
# This is a normal, successful exit. Use exit 1 for failures so they show up clearly in the job status with a red icon.
exit 0
