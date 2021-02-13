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
#	Fix issues with calling sudo many times
#	Support user friendliness

# This is the UUID of the hard drive the backups will be saved on. There should also a file on the drive w/ this as its name.
UUID=<UUID goes here>
# The mount point of the hard drive.
MOUNTP=<mount point goes here ex:'/mnt/usb'>
# The id of the GPG user.
GPGID=<GPG id goes here.>
# The date. used in the name of the archives being created.
DATE=$(date +%F) 
# Current user's $HOME. Use w/ sudo as to not use root's $HOME.
SUDO_HOME=$(grep $SUDO_USER /etc/passwd | cut -d ":" -f6)

# Some 'boolean' variables. Toggled in function arguments
BOOL_ENCRYPT=0
BOOL_UMOUNT=0

# Reading command line arguments.
arguments()
{
	for arg in "$@"
	do
		if [ $arg == '-e' ]
		then
			BOOL_ENCRYPT=1
		fi

		if [ $arg == '-u' ]
		then
			BOOL_UMOUNT=1
		fi
	done
	
	echo "Arguments are $@"
	echo "BOOL_ENCRYPT is $BOOL_ENCRYPT"

	inital
}

# Mounting the hard drive.
inital()
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
	# This prompt only exist because sudo may time out if the user is away. This all depends on how sudo is configured.
	#echo "Would you like to encrypt the archive?(y/n)"
	#read PROMPT1

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
	#elif [ $PROMPT1 = 'n' ]
	#then
	#	echo "The archive will not be encrypted"
	#else
	#	echo "Please type 'y' or 'n'"
	#	sleep 0.3s
	#	encrypt
	fi

	unmount
}

#Unmounting the drive. Still using it's UUID.
unmount()
{
	#echo "Would you like to unmount the backup drive?(y/n)"
	#read PROMPT2

	if [ $BOOL_UMOUNT -eq 1 ]
	then
		echo "Unmounting drive..."
		umount UUID=$UUID
		echo "Drive unmounted"
	#elif [ $PROMPT2 = 'n' ]
	#then
	#	echo "The drive will remain mounted at $MOUNTP"
	#else
	#	echo "Please type 'y' or 'n'"
	#	sleep 0.3s
	#	unmount
	fi
}

arguments $@
