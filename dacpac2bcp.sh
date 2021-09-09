#!/bin/bash
USAGE='Usage: dacpac2bcp.sh -f <path to .dacpac file> -d DATABASE -S SERVER [-T or -U USERNAME -P PASSWORD] ( -d and -f are required. The others have defaults.)'

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
		-f)
			DACPACFILE="$2"
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
		--tables)
			TABLES="$2"
			shift
			;;
		--*)
			echo "Illegal option $1"
			echo "$USAGE"
			exit 1
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

if [ -z "$AUTH" ]; then
	AUTH="-U $USERNAME -P $PASSWORD"
fi

if [ -z "$DATABASE" ]; then
	echo ERROR: Must specify database name.
	echo "$USAGE"
	exit 1
fi

if [ -z "$DACPACFILE" ]; then
	echo ERROR: Must specify DACPAC file path.
	echo "$USAGE"
	exit 1
fi

dacpacDir="${DACPACFILE%.dacpac}"

if [ ! -d "$dacpacDir" ]; then
    echo "Need to unzip $DACPACFILE to create $dacpacDir"
    unzip -d "$dacpacDir" "$DACPACFILE"
fi

if [ ! -d "$dacpacDir/Data" ]; then
    echo "ERROR: Data subfolder not found within $dacpacDir"
    echo "Are you sure that the $DACPACFILE file you provided contains table data, and not just schema?"
    exit 1
fi

cd "$dacpacDir/Data"
echo Deploying to "$DATABASE" on "$SERVER"
#set -x #Command echo on, for debugging

load_table() {
	d="$1"
	cd "$d";
	echo "Loading table ${d%/}";
	for f in *.BCP; do
		tablename="${d%/}"; # Get table name from subfolder name. This needs to be done inside the loop.
		# If it's not already, SQL [quote] the tablename:
		[[ "${tablename}" =~ "\[" ]] || tablename="[${tablename/\./\]\.\[}]"
		bcp "${tablename}" in "$f" -S "$SERVER" -d "$DATABASE" $AUTH -N || break; #If one file failed they all will; on to next table.
	done;
	echo "Done loading table ${d%/}";
	cd ..;
}

# Load all tables by default:
if [ -z "$TABLES" ]; then
	for d in */ ; do
		load_table "$d"
	done
else # If a list of tables has been provided, do only those:
	for d in $TABLES ; do
		load_table "$d"
	done
fi

#set +x #Command echo back off
cd .. #Back out of Data dir to root
echo "Done. (Seeing some errors was expected if the DACPAC contains data for tables that are not in your database.)"
