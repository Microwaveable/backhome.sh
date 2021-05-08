#!/bin/bash
# Script to backup the current user's home directory as a compressed and encrypted archive.
# Not without its issues.
#
# In order for this script run properly, you need to initialize the variable '$GPGID'
# Also, you need a private gpg key
#
# TODO:
#	Support command line arguments
#	Support user friendliness

# The id of the GPG user.
GPGID=<gpg is goes here>
# The date. used in the name of the archives being created.
DATE=$(date +%F) 
# Current user's home directory.
SUDO_HOME=$(grep $SUDO_USER /etc/passwd | cut -d ":" -f6)

# A 'boolean' variables. Toggled in function arguments()
BOOL_ENCRYPT=0

# Reading command line arguments.
arguments()
{
	if [[ $@ != *-o* ]]
	then
		echo "Error: No output directory provided!"
		kill $$
	fi

	for arg in "$@"
	do
		if [ $arg == '-e' ] || [ $arg == '--encrypt' ]
		then
			BOOL_ENCRYPT=1
		fi

		# Argument to specify where to create archive.
		if [ $arg == '-o' ] #|| [ $arg == '--output' ]
		then
			OUTPUT=$( echo $@ | sed 's/^[^-o]*-o//' | awk '{print $1}' )
			
			if [[ $OUTPUT == */ ]]
			then
				OUTPUT=$( echo $OUTPUT | sed 's/.$//' )
			fi
		fi

		if [ $arg == "-h" ] || [ $arg == "--help" ]
		then
			echo "Usage:	$( echo $0 | rev | cut -d "/" -f 1 | rev ) [arguments]"
			echo
			echo "Valid arguments:"
			echo "	-o [directory]		Path to where the archive will be created"
			echo "	-e			Encrypt the archive with gpg"
			echo "	-h			print this help message"

			# Find out how to end the process without printing "Terminated"
			kill $$
		fi
	done
	
	archive
}

# Make the compressed archive with tar.
archive()
{
	echo "Archiving $SUDO_HOME..."
	tar -zcvf $OUTPUT/$SUDO_USER\_$DATE\_backup.tar.gz $SUDO_HOME
	echo "Archive created at $OUTPUT/$SUDO_USER\_$DATE\_backup.tar.gz"
	encrypt
}

# Encrypt the archive with gpg and shred the unencrypted file.
encrypt()
{
	if [ $BOOL_ENCRYPT -eq 1 ]
	then
		echo "Encrypting archive..."
		cd $OUTPUT
		gpg -r $GPGID -e $OUTPUT/$SUDO_USER\_$DATE\_backup.tar.gz
		echo "Archive encrypted"
		echo "Erasing unencrypted files..."
		shred $OUTPUT/$SUDO_USER\_$DATE\_backup.tar.gz
		rm -f $OUTPUT/$SUDO_USER\_$DATE\_backup.tar.gz
		echo "Files erased"
	fi
}

arguments $@
