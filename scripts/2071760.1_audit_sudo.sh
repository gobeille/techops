#!nsh
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
	
# Collect the path to put reports from parameters passed in.
REPORT_DESTINATION_PATH=$1

echo "REPORT_DESTINATION_PATH = $REPORT_DESTINATION_PATH" 
echo "SUDO_BINARIES = $SUDO_BINARIES"

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

echo "SUDO_REPORT = $SUDO_REPORT"
echo "SUDOERS_REPORT = $SUDOERS_REPORT"
touch $SUDO_REPORT $SUDOERS_REPORT

# Capture to variables
#   current OS
#   current OS version

OS=`uname -s`
OS_VERSION=`uname -r`

echo "OS = $OS"
echo "OS_VERSION = $OS_VERSION"

# For each possible sudo bin location, capture which exist
# The 2> /dev/null discards errors such as when a file does not exist.

AVAILABLE_SUDO_BINARIES=`ls $POSSIBLE_SUDO_BINARIES 2> /dev/null`

echo "AVAILABLE_SUDO_BINARIES = $AVAILABLE_SUDO_BINARIES"

#Using the above, capture the existing sudo versions

for SUDO_PATH in $AVAILABLE_SUDO_BINARIES; do
	SUDO_VERSION=`$SUDO_PATH -V | head -1 | awk '{print $NF}'`
	echo "SUDO_VERSION = $SUDO_VERSION"
done

#Populate the host report with contents

#For each possible sudoers file locations capture into the sudoers report:
#            each line from sudoers prefaced with host name and file location while filtering out blank lines and comments

# This is a normal, successful exit. Use exit 1 for failures so they show up clearly in the job status with a red icon.
exit 0