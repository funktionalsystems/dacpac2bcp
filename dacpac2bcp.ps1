<#
Load a data DACPAC file into a database, using BCP
(bcp must be available on the PATH)
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="path to .dacpac file")][string]$Filename,
    [Parameter(Mandatory=$true, HelpMessage="database name")][string]$Database,
	[Parameter(Mandatory=$false, HelpMessage="Use Trusted connection (Windows-only Integrated auth) Overrides Username and Password")][bool]$useWindowsAuth = $false,
	#TODO: [Parameter(Mandatory=$false, HelpMessage="Load only this list of tables")][string]$tables = "",
    
	# These defaults are for convenience in an isolated development environment.
	# Don't change them here for production; pass them instead.
	[Parameter(Mandatory=$false, HelpMessage="server name")][string]$Server = "localhost",
    [Parameter(Mandatory=$false, HelpMessage="database username")][string]$Username = "sa",
    [Parameter(Mandatory=$false, HelpMessage="database password")][string]$Password = "Your_password123"
)

#TODO: If bcp is not available on the PATH, try to find it.
#$bcp = 'C:\Program Files\Microsoft SQL Server\110\Tools\Binn\bcp.exe'

$dacpacFile = Get-Item $Filename
if ($dacpacFile.Extension -ne ".dacpac")
{
	echo "Filename must be a .dacpac"
	exit 1;
}

$dacpacDirName = $dacpacFile.BaseName
$dacpacDir = Join-Path $dacpacFile.Directory $dacpacDirName
if (!(Test-Path $dacpacDir))
{
    echo "Need to unzip $Filename to create $dacpacDir"
	mv $Filename "$dacpacDir.zip"
    Expand-Archive -Path $Filename -DestinationPath $dacpacDir
	mv "$dacpacDir.zip" $Filename
}

$dataDir = Join-Path $dacpacDir "Data";
if ( (!(Test-Path $dataDir)) -or ((Get-ChildItem $dataDir | Measure-Object).Count -eq 0) ) {
    echo "ERROR: Data subfolder not found within $dacpacDir"
    echo "Are you sure that the $File file you provided contains table data, and not just schema?"
    exit 1;
}

echo "Deploying $dataDir to $Database on $Server"
$tables = Get-ChildItem -Directory -Path "$dataDir"
foreach ($tablePath in $tables) {
	$table = $(Get-Item $tablePath).BaseName
	# If it's not already, SQL [quote] the tablename:
	$table = $table -replace "^([^\.]*)\.([^\.]*)$","[`$1].[`$2]"
	echo "Loading table $table";
	foreach ($filePath in $(Get-ChildItem -Path "$tablePath")) {
		if ($useWindowsAuth) {
			$bcp_args = "$table", "in", "$filePath", "-S", "$Server", "-d", "$Database", "-T", "-N", "-E", "-e", "$filePath.err"
		} else {
			$bcp_args = "$table", "in", "$filePath", "-S", "$Server", "-d", "$Database", "-U", $Username, "-P", $Password, "-N", "-E", "-e", "$filePath.err"
		}
		$result = & bcp @bcp_args
		#echo "[DEBUG] bcp $bcp_args"
		echo "$result"
		# || break; #If one file failed they all will; on to next table.
	}
	echo "Done loading table $table";
}

#Remove empty (err) files:
Get-ChildItem -File -Recurse -Path "$dataDir" | Where-Object {$_.length -eq 0} | remove-item

echo "Done. (Seeing some errors was expected if the DACPAC contains data for tables that are not in your database. If you see login errors, check the server logs - It might be the specified database is missing or incorrect.)"
