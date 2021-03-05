#!/bin/bash
USAGE="Usage: $0 srcfile.dacpac destfile.dacpac databaseName deployScript.sql"

if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
	>&2 echo ERROR: Must specify src, dest, database name, and output file.
	>&2 echo "$USAGE"
	exit 1
fi

sqlpackage \
	/Action:Script \
	/SourceFile:"$1" /TargetFile:"$2" /TargetDatabaseName:"$3" /DeployScriptPath:"$4" \
	/Profile:"/opt/sqlpackage/Database.publish.xml" \
	/p:DropObjectsNotInSource=False
