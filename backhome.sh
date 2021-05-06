#!/bin/bash
# Script to backup the current user's home directory as a compressed and encrypted archive on another drive.
# Not without its issues.
#
# In order for this script run properly, you need to initialize the variables '$UUID', '$MOUNTP', and '$GPGID'
# Also, you need a private gpg key
# Remember to create a file inside of the back up drive with the same name as variable $UUID
#
# TODO:
#	Support command line arguments
#	Support user friendliness

# This is the UUID of the hard drive the backups will be saved on. There should also a file on the drive w/ this as its name.
UUID=<UUID goes here>
# The mount point of the hard drive.
MOUNTP=<mount point goes here ex:'/mnt/usb'>
# The id of the GPG user.
GPGID=<GPG id goes here.>
# The date. used in the name of the archives being created.
DATE=$(date +%F) 
# Current user's home directory.
SUDO_HOME=$(grep $SUDO_USER /etc/passwd | cut -d ":" -f6)

# Some 'boolean' variables. Toggled in function arguments
BOOL_ENCRYPT=0
BOOL_UMOUNT=0

# Reading command line arguments.
arguments()
{
	for arg in "$@"
	do
		if [ $arg == '-e' ] || [ $arg == '--encrypt' ]
		then
			BOOL_ENCRYPT=1
		fi

		if [ $arg == '-u' ] || [ $arg == '--unmount' ]
		then
			BOOL_UMOUNT=1
		fi

		if [ $arg == "-h" ] || [ $arg == "--help" ]
		then
			echo "Usage:	$( echo $0 | rev | cut -d "/" -f 1 | rev ) [arguments]"
			echo
			echo "Valid arguments:"
			echo "	-e		Encrypt the archive with gpg"
			echo "	-u		Unmount the backup media"
			echo "	-h		print this help message"

			# Find out how to end the process without printing "Terminated"
			kill $$
		fi
	done
	
	initial
}

# Mounting the hard drive.
initial()
{													
	echo "Mounting drive..."
	mount UUID=$UUID $MOUNTP
	# If ID file that is on drive is found then assume the drive is mounted and go on to archive.
	if [ -a $MOUNTP/$UUID ]
	then
		echo "Drive mounted at $MOUNTP"	
		archive										
	else
		echo "Drive not found"
	fi
}

# Make the compressed archive with tar.
archive()
{
	echo "Archiving $SUDO_HOME..."
	tar -zcvf $MOUNTP/$SUDO_USER\_$DATE\_backup.tar.gz $SUDO_HOME
	echo "Archive created at $MOUNTP/$SUDO_USER\_$DATE\_backup.tar.gz"
	encrypt
}

# Encrypt the archive with gpg and shred the unencrypted file.
encrypt()
{
	if [ $BOOL_ENCRYPT -eq 1 ]
	then
		echo "Encrypting archive..."
		cd $MOUNTP
		gpg -r $GPGID -e $MOUNTP/$SUDO_USER\_$DATE\_backup.tar.gz
		echo "Archive encrypted"
		echo "Erasing unencrypted files..."
		shred $MOUNTP/$SUDO_USER\_$DATE\_backup.tar.gz
		rm -f $MOUNTP/$SUDO_USER\_$DATE\_backup.tar.gz
		echo "Files erased"
	fi

	unmount
}

#Unmounting the drive. Still using it's UUID.
unmount()
{
	if [ $BOOL_UMOUNT -eq 1 ]
	then
		echo "Unmounting drive..."
		umount UUID=$UUID
		echo "Drive unmounted"
	fi
}

arguments $@
