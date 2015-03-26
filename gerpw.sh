#!/bin/bash/env bash

## User Defined Defaults--------------------------

### GnuPG UserID
gerpuser=email@email

### Default Editor
EDITOR="${vi:-nano}"

##------------------------------------------------


usage () {
        cat <<_
Usage: gerp-bash.sh -f <filename> -i <gpg userid> <Parameters>
        where <Parameters> can be any of 
        -g      generate password
        -e      edit a password
	-n	enter a new password
        -r      read an encrypted password
	
	-u	<username>
	-p	<password>

	-cu	copy <username>
	-cp	copy <password>
	
#USE  [ $ unset HISTFILE ]  prior to using gerpw to prevent bash history from saving & close terminal window when done.
_
	
}

while getopts "i:f::u::p:genrcx" opt; do
 case $opt in
 
     f) gerp=$OPTARG;;
     i) gerpuser=$OPTARG;;
     u) tagname=$OPTARG; usercounter=1;;			
     p) tagpass=$OPTARG; passcounter=1;;

     g) genecounter=1;;
     n) newcounter=1;;
     e) editcounter=1;;
     r) readcounter=1;;
     x) xclip=user;;
     c) xclip=pass;;
     
     h) usage; exit;;
     ?) usage; exit;;
    esac
done

## mutually exclusive
if [ "$newcounter" = "1" ] && [ "$editcounter" = "1" ]; then
    echo
    echo "-n & -e are mutually exclusive options. Ending Program."
    echo
    exit
elif [ "$genecounter" = "1" ] && [ "$passcounter" = "1" ]; then
    echo
    echo "-p & -g are mutually exclusive options. Ending Program."
    echo
    exit
fi

function on_exit {
    rm -rf "$gerptemp" "$gerptemp2"
}

## -g --generate tag

if [ "$genecounter" = "1" ]; then
echo "generating password:"
    echo "enter password length"
    read pwlength
    genpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $pwlength | head -n 1);
    echo
    echo "Generated Password: $genpw"
    echo				
fi

## -n --new_entry tag

if [ "$newcounter" = "1" ]; then
    gerptemp="$(mktemp)"
    trap on_exit EXIT
    if [ "$usercounter" = "1" ]; then
	username=$tagname
	
    else	
	echo "enter username:"
	read "username"
	echo

    fi;

{    
    if [ "$genecounter" = "1" ]; then
	(echo "$username" && echo "$genpw") > "$gerptemp"
	gpg -o $gerp -r $gerpuser --encrypt $gerptemp &> /dev/null

    else

	    if [ "$passcounter" = "1" ]; then
		inputpw=$tagpass
		(echo "$username" && echo "$inputpw") > "$gerptemp"
		gpg -o $gerp -r $gerpuser --encrypt $gerptemp &> /dev/null

	    else
		echo "enter password:"
		read inputpw
		(echo "$username" && echo "$inputpw") > "$gerptemp"
		gpg -o $gerp -r $gerpuser --encrypt $gerptemp &> /dev/null

	    fi
    fi
}
fi

## -e --edit_entry tag

if [ "$editcounter" = "1" ]; then
     echo "editting garp-bash entry: $GERP"
     gerptemp="$(mktemp)"
     trap on_exit EXIT
     gpg -o $gerptemp --batch --yes  --decrypt $gerp &> /dev/null
     
     if [ "$genecounter" = "1" ]; then
	 echo
	 username="$(sed -n '1p' $gerptemp)"

	 {
	     if [ "$usercounter" = "1" ]; then
		(echo "$tagname" && echo "$genpw") > $gerptemp
		gpg -o $gerp -r $gerpuser --batch --yes  --encrypt $gerptemp &> /dev/null

	     else
		 echo "Current username: $username"
		 echo "Do you want to change it? (yes/no)"
		 read uduncounter

		 {
		     if [ "$uduncounter" = "yes" ] || [ "$uduncounter" = "y" ]; then
		         echo
			 echo "Enter NEW username:"
			 read inputun
			 (echo "$inputun" && echo "$genpw") >| "$gerptemp"
			 gpg -o $gerp -r $gerpuser --batch --yes --encrypt $gerptemp &> /dev/null

		     elif [ "$uduncounter" = "no" ] || [ "$uduncounter" = "n" ]; then
			 (echo "$username" && echo "$genpw") >| $gerptemp
			 gpg -o $gerp -r $gerpuser --batch --yes --encrypt $gerptemp &> /dev/null

		     else
			 echo
			 echo "Invalid Option. Ending Program"
			exit
			 
		     fi
		 }
	     fi
	 }


     else
	 {
	     if [ "$usercounter" = "1" ]; then
		 {
		     if [ "$passcounter" = "1" ]; then
			 (echo "$tagname" && echo "$tagpass") >| $gerptemp
			 gpg -o $gerp -r $gerpuser --batch --yes --encrypt $gerptemp &> /dev/null
			
		     else
			 uneditpw="$(sed -n '2p' $gerptemp)"
			 (echo "$tagname" && echo "$uneditpw") >| $gerptemp
			 gpg -o $gerp -r $gerpuser --batch --yes --encrypt $gerptemp &> /dev/null

		     fi;
		 }

	     elif [ "$passcounter" = "1" ]; then
		username="$(sed -n '1p' $gerptemp)"
		(echo "$username" && echo "$tagpass") >| $gerptemp
		gpg -o $gerp-r $gerpuser --batch --yes --encrypt $gerptemp &> /dev/null

	     else
		 $EDITOR $gerptemp
		 gpg -o $gerp -r $gerpuser --batch --yes --encrypt $gerptemp &> /dev/null
	     fi;
	 }
     fi
fi

## -r --read_entry tag

if [ "$readcounter" = "1" ]; then
    gerptemp2="$(mktemp)"
    trap on_exit EXIT
    echo
    echo "###########[---$gerp---]###########"
    echo
    gpg --decrypt --batch --yes -o $gerptemp2 $gerp &> /dev/null
    cat $gerptemp2
    echo
    echo "###########[---$gerp---]###########"
    echo

    if [ "$xclip" = "pass" ]; then
	echo "$(sed -n '2p' $gerptemp2)" | xclip &> /dev/null
    elif [ "$xclip" = "USER" ]; then
	echo "$(sed -n '1p' $gerptemp2)" | xclip &> /dev/null
    fi
exit

else
    gerptemp2="$(mktemp)"
    trap on_exit EXIT
    if [ "$xclip" = "pass" ]; then
	gpg --decrypt --batch --yes -o $gerptemp2 $gerp &> /dev/null
	echo "$(sed -n '2p' $gerptemp2)" | xclip &> /dev/null
	
    elif [ "$xclip" = "user" ]; then
	gpg --decrypt --batch --yes -o $gerptemp2 $gerp &> /dev/null
	echo "$(sed -n '1p' $gerptemp2)" | xclip &> /dev/null
    fi
	exit
fi

