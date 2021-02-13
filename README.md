# backhome.sh
Script to back up the current user's home directory as a compressed and encrypted archive on another drive.

## Dependencies
- In order to run backhome.sh you need...
	- sudo
	- tar
	- gpg

## Installation/Set-up
- Installation
	1. `git clone https://microwaveable/backhome.sh`
	2. `cd backhome.sh`
	3. Script is found at ./backhome.sh
		- You can move this file to somewhere in your $PATH.
- Set-up
	1. Open backhome.sh with your preferred text editor.
		- `vi backhome.sh`
	2. Set the variables '$UUID', '$MOUNTP', and '$GPGID'
		- $UUID should be set to the name of a file on the backup drive.
			- `UUID=thisisabadexample`
		- $MOUNTP should be set to the backup drive's desired mount point.
			- `MOUNTP=/path/to/mount/point`
		- $GPGID should be set to the id of a public gpg key.
			- `GPGID=someone@email.com`

## Usage
- Run `backhome.sh`. This may take some time. At certain points the program will prompt the user for information.

## Contributing
- You may make pull requests, but I might not see them.
- Copy this script and use it however you'd like.

## About
- This program may be a load of crap, but, in my defense, I didn't go to college.
