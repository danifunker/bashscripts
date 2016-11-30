#!/bin/bash
#Display usage statement if no arguments are passed
test $# -lt 1  && echo "usage: $0 <myPFXKeyToExtract.pfx> [<PFXPassword>]" && exit 1
#Check the file actually exists, exit if it doesn't
! test -f $1  && echo "$1 is not a file, please specify a file" && exit 2
#Prompt for a password if not specified on the command line
if ! test $# -gt 1; 
	then read -se -p "Please enter the password:"
else
	REPLY=$2
fi
echo -e "\n"
#Expecting to create 3 files, but will delete one of them.
#Will use a variable success for each openssl command that runs sucessfully
success=0
#Get the private key file in PEM format
openssl pkcs12 -in $1 -nocerts -out $1_key.pem -nodes -passin pass:$REPLY
test $? -eq 0 && success=$(($success + 1))
#Get the certificate in PEM format
openssl pkcs12 -in $1 -nokeys -out $1_cert.pem -passin pass:$REPLY
test $? -eq 0 && success=$(($success + 1))
#Convert the private key to RSA format
openssl rsa -in $1_key.pem -out $1_key.key -passin pass:$REPLY
test $? -eq 0 && success=$(($success + 1))
#Cleanup if successful and return status message
if test $success -eq 3; then 
	rm $1_key.pem
	echo "Exported the PKCS12 certificate successfully. Search for $1_key.key and $1_cert.pem in this folder"
else
	echo "$success files were written. Check to ensure the file is actually PKCS12 and the password is correct."
fi
