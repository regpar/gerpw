# gerpw
bash script GnuPG password manager

		gerpw
		Generate, Edit, Read Passwords
		by regpar


A simple script written in bash, making it simple
to use GnuPG as your a password manager. The folder location
and heirarchies of your encrypted password files are 
independent of the script.


Options:

	-f  	define filename			
	-i 		define GnuPG userid
	-u  	define username
	-p  	define password

	-g		generate password
	-n		new entry
	-e		edit entry		
	-r		read entry

	-x		copy <username>
	-c		copy <passcode>

Dependencies:

	Bash		http://www.gnu.org/software/bash/
	GnuPG		https://www.gnupg.org/
	Mktemp		http://www.mktemp.org/
	
	Optional:
	xclip		http://sourceforge.net/projects/xclip/

Basic Syntax:

	$ sh gerpw.sh -f <filename> -i <gpg userid> -g -n -r

		-g	generate password using /dev/urandom
		-n	create a new entry
		-r	read an encrypted entry

-----or-----

	$ sh gerpw.sh -f <filename> -i <gpg userid> -u <username> -p <password> -g -e -r

		-g	generate password using /dev/urandom
		-e	edit an existing entry
		-r	read an encrypted entry
	

Examples:

	$ sh gerpw.sh -f example.com -i testing@email.com -g -n -r
	
		generating password:
		enter password length
		20
		
		Generated Password: hO0rFryXPg2RFtjxvG8p
		
		enter username:
		USERNAME
		
		
		###########[---example.com---]###########

		USERNAME
		hO0rFryXPg2RFtjxvG8p

		###########[---example.com---]###########

----------------

	$ sh gerpw.sh -f example.com -i testing@email.com -g -e -r
		
		generating password:
		enter password length
		20
		
		Generated Password: IMwZSJ7dlzAoPN27GAVk
		
		Current username: USERNAME
		Do you want to change it? (yes/no)
		yes
		
		Enter NEW username:
		NEW_USERNAME

		###########[---example.com---]###########
		
		NEW_USERNAME
		IMwZSJ7dlzAoPN27GAVk
		
		###########[---example.com---]###########

Advanced Examples:

	$ sh gerpw.sh -f example.com -i testing@email.com -u USERNAME22 -p PASSWORD44 -nr

	     	
		###########[---example.com---]###########

		USERNAME22
		PASSWORD44

		###########[---example.com---]###########

----------------

	$ sh gerpw.sh -f example.com -i testing@email.com -u USERNAME -ger

		generating password:
		enter password length
		30

		Generated Password: fBTvpJ0GZm4SSwSxhHcxCtoty7wlLq

		editting gerpw entry: example.com


		###########[---example.com---]###########

		USERNAME
		fBTvpJ0GZm4SSwSxhHcxCtoty7wlLq

		###########[---example.com---]###########


Optional Copy w/ xclip:

	# Copy <username> to clipboard
	$ sh gerpw.sh -f example.com -i testing@email.com -x

	# Copy <password> to clipboard
	$ sh gerpw.sh -f example.com -i testing@email.com -c


User Defined Options:

	[1] default reader to edit entries (example: nano, vim)
	[2] default GnuPG UserID, making the -i <gpg userid> optional
