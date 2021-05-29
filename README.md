# backhome.sh
Script to back up the current user's home directory as a compressed and/or encrypted archive.

## Dependencies
- In order to run backhome.sh you need...
	- tar
	- gpg

## Installation/Set-up
- Installation
	1. `$ git clone https://github.com/microwaveable/backhome.sh`
	2. `$ cd backhome.sh`
	3. Script is found at ./backhome.sh
		- You can move this file to somewhere in your $PATH.
- Set-up
	1. Open backhome.sh with your preferred text editor.
		- `$ vi backhome.sh`
	2. Set the variable '$GPGID' to the id of a public gpg key.
		- `GPGID=someone@email.com`

## Usage
- Run `$ backhome.sh --help` for some information about valid arguments.
- Run `$ backhome.sh --output ~ --encrypt` to make an encrypted archive in your home directory. This may take some time. At certain points gpg may prompt the user for information.

## Contributing
- You may make pull requests, but I might not see them.
- Copy this script and use it however you'd like.

## About
- This program may be a load of crap, but, in my defense, I didn't go to college.
