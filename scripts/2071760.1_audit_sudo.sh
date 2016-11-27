#!nsh -x
#########################################################################################################################
# Audit Sudo
#
# Scott Gobeille - November 2016
#
# This job collects sudo configurations, locations, versions and some host values -- OS version, etc -- into reports.
# It is the first part of two scripts. The second will compile host-specific reports into single master reports.
# 
#
# Parameters
#
#	REPORT_DESTINATION_PATH 
#		The NSH path, including host, where reports will go.
#		Default : //alprut01-m/usr/local/app/techops/auth_files
#	
#########################################################################################################################

# This assumes several possible locations for the sudo executable, /usr/local/bin for the 3rd party version and /bin for the native version
# available in Solaris 11 and Linux as well as other likely paths.
POSSIBLE_SUDO_BINARIES="/bin/sudo /usr/bin/sudo /usr/local/bin/sudo"

# Similar to the above, this assumes a couple of possible locations for the sudo configuration file sudoers, /usr/local/etc/sudoers
# for the 3rd party version and /etc/sudoers for the native version available in Solaris 11 and Linux.
POSSIBLE_SUDOERS_FILES="/etc/sudoers /usr/local/etc/sudoers"
	
# Collect the path to put reports from parameters passed in.
REPORT_DESTINATION_PATH=$1

# Define a field delimiter, a character to separate all fields in reports produced here.
FD=$2

echo "POSSIBLE_SUDO_BINARIES = $POSSIBLE_SUDO_BINARIES"
echo "POSSIBLE_SUDOERS_FILES = $POSSIBLE_SUDOERS_FILES"
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
SUDO_REPORT=$REPORT_DESTINATION_PATH/$NSH_RUNCMD_HOST.sudo.$DATE_STAMP
SUDOERS_REPORT=$REPORT_DESTINATION_PATH/$NSH_RUNCMD_HOST.sudoers.$DATE_STAMP
HOST_INFO_REPORT=$REPORT_DESTINATION_PATH/$NSH_RUNCMD_HOST.host_info.$DATE_STAMP

echo "SUDO_REPORT = $SUDO_REPORT"
echo "SUDOERS_REPORT = $SUDOERS_REPORT"
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

write_sudo_report ()
{
	# For each possible sudo bin location, capture which exist
	# The 2> /dev/null discards errors such as when a file does not exist.
	#
	# Maybe a find command, which ignores links and requires an executable binary, would be better here?
	#
	
	AVAILABLE_SUDO_BINARIES=`ls $POSSIBLE_SUDO_BINARIES 2> /dev/null`
	
	echo "AVAILABLE_SUDO_BINARIES = $AVAILABLE_SUDO_BINARIES"
	
	#Using the above, capture the existing sudo versions
	
	for SUDO_PATH in $AVAILABLE_SUDO_BINARIES; do
		SUDO_VERSION=`nexec -e $SUDO_PATH -V | head -1 | awk '{print $NF}'`
		echo "${SUDO_PATH}${FD}${SUDO_VERSION}" >> $SUDO_REPORT
	done

}

write_sudoers_report ()
{
	#For each possible sudoers file locations capture into the sudoers report:
	#            each line from sudoers prefaced with host name and file location while filtering out blank lines and comments
	AVAILABLE_SUDOERS_FILES=`ls $POSSIBLE_SUDOERS_FILES 2> /dev/null`
	
	echo "AVAILABLE_SUDOERS_FILES = $AVAILABLE_SUDOERS_FILES"
	
	for SUDOERS_PATH in $AVAILABLE_SUDOERS_FILES; do
		
		# Sed commands are separated by ";".
		# Here, we sometimes use a : instead of the usual / so sed doesn't get confused when working with paths.
		
		# In this compound command, we:
		#	Remove blank lines = /^$/d
		#	Remove comment lines, ones that begin with a hash = /^#.*$/d
		#	Prepend the sudoers path and a field delimiter 
		#		= s/^/${SUDOERS_PATH}${FD}/g
		
		sed "/^$/d ; /^#.*$/d ; s:^:${SUDOERS_PATH}${FD}:g" $SUDOERS_PATH >> $SUDOERS_REPORT
		
	done
	
}

write_host_info_report
write_sudo_report
write_sudoers_report

# This is a normal, successful exit. Use exit 1 for failures so they show up clearly in the job status with a red icon.
exit 0