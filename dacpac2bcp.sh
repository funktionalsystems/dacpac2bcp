#!/bin/bash
USAGE='Usage: dacpac2bcp.sh -d DATABASE -S SERVER [-T or -U USERNAME -P PASSWORD] ( -d is required. The others have defaults.)'
DIR='Must be called from within root of unzipped dacpac folder. (Run "unzip blah.dacpac" then "cd blah")'

# These defaults are for convenience in an isolated development environment.
# Don't change them here for production; pass them in.
SERVER="localhost"
USERNAME="sa"
PASSWORD="Your_password123"

while [ $# -gt 0 ]; do
	case "$1" in
		-S)
			SERVER="$2"
			shift
			;;
		-d)
			DATABASE="$2"
			shift
			;;
		-T) #Trusted connection (Integrated/Windows auth) Overrides -U and -P
			AUTH="-T"
			#no arg, no shift
			;;
		-U)
			USERNAME="$2"
			shift
			;;
		-P)
			PASSWORD="$2"
			shift
			;;
		--*)
			echo "Illegal option $1"
			echo "$USAGE"
			echo "$DIR"
			exit 1
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

if [ -z "$AUTH" ]; then
	AUTH="-U \"$USERNAME\" -P \"$PASSWORD\""
fi

if [ -z "$DATABASE" ]; then
	echo ERROR: Must specify database name.
	echo "$USAGE"
	echo "$DIR"
	exit 1
fi

r=`pwd`
if [ "${r%/}" != "Data" ]; then
	if [ -d "./Data" ]; then
		cd ./Data
	else
		echo "ERROR: $DIR"
		exit 1
	fi
fi

echo Deploying to "$DATABASE" on "$SERVER"
#set -x #Command echo on, for debugging

for d in */ ; do
	cd "$d";
	echo "Loading table ${d%/}";
	for f in *.BCP; do
		tablename="${d%/}"; #Get table name from subfolder name.
		bcp "${tablename}" in "$f" -S "$SERVER" -d "$DATABASE" $AUTH -N || break; #If one file failed they all will; on to next table.
	done;
	cd ..;
done

#set +x #Command echo back off

cd .. #Back out of Data dir to root

echo "Done. (Seeing some errors was expected if the DACPAC contains data for tables that are not in your database.)"
