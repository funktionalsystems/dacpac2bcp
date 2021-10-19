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
$dacpacDir = $dacpacFile.BaseName
if ($dacpacFile.Extension -ne ".dacpac")
{
	echo "Filename must be a .dacpac"
	exit;
}

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
    exit;
}

echo "Deploying $dataDir to $Database on $Server"
$tables = Get-ChildItem -Directory -Path "$dataDir"

foreach ($t in $tables) {
	$table = $(Get-Item $t).BaseName
	# If it's not already, SQL [quote] the tablename:
	$table = $table -replace "^([^\.]*)\.([^\.]*)$","[`$1].[`$2]"
	echo "Loading table $table";
	foreach ($f in $(Get-ChildItem -Path "$t")){ #-File -Include "*.bcp"
		if ($useWindowsAuth) {
			$bcp_args = "$table", "in", "$f", "-S", "$Server", "-d", "$Database", "-T", "-N"
		} else {
			$bcp_args = "$table", "in", "$f", "-S", "$Server", "-d", "$Database", "-U", $Username, "-P", $Password, "-N"
		}
		& bcp @bcp_args
		#echo "[DEBUG] bcp $bcp_args"
		# || break; #If one file failed they all will; on to next table.
	}
	echo "Done loading table $table";
}

echo "Done. (Seeing some errors was expected if the DACPAC contains data for tables that are not in your database.)"
