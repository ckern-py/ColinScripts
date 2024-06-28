<#
.Synopsis
   Get all Azure SQL Servers and Databases and group them.
.DESCRIPTION
   This script gets all Azure SQL Servers and Databases on those servers. Then attempts to group similar ones together. 
   Results are output to a file in json format.
.EXAMPLE
  IN AZURE: .\Azure_GetSQLSvrDB.ps1
.INPUTS
   No inputs currently.
.OUTPUTS
   All SQL Servers and Databases found will be output to a json file in the same directory named AzureSQL_Ordered.json.
.NOTES
   Script is looking for Databases on the servers that are not named master.
   If more than one Database is on a Server then the script does not handle it well, this will need to be changed. 
#>

"Starting Script" | Write-Host
$AzEnvList = @("NonProd", "Prod")
$AllSQLList = @()
$SQLOrganized = @{}
$RegexPattern = "ResG-PreFix-(\w+\d+)-(.*?)-?(sql|db)?$"

foreach($AzEnv in $AzEnvList)
{
    "Starting $AzEnv" | Write-Host
    $CurrEnvList = az sql server list --query "[].{LongName:fullyQualifiedDomainName, Name:name, Group:resourceGroup, Server:''}" --subscription $AzEnv | ConvertFrom-Json
    foreach($SQLServer in $CurrEnvList)
    {
      $SQLServer.Server = (az sql db list -g $SQLServer.Group -s $SQLServer.Name --subscription $AzEnv | ConvertFrom-Json | Where-Object {$_.Name -ne 'master'}).name
    }
    $AllSQLList += , $CurrEnvList
}

"All SQL info gathered" | Write-Host
"Starting to organize the data" | Write-Host

foreach($SQLOption in $AllSQLList)
{
    $SQLGroup = ($SQLOption.Group | Select-String -Pattern $RegexPattern).Matches.Groups[2].Value
    if( $SQLOrganized.ContainsKey($SQLGroup))
    {
        $CurrList = @($SQLOrganized[$SQLGroup])
        $CurrList += ,$SQLOption
        $SQLOrganized.$SQLGroup = $CurrList
    }
    else
    {
        $NewList = @($SQLOption)
        $SQLOrganized.$SQLGroup = $NewList
    }
}

"Data organized" | Write-Host

$SQLOrganized.GetEnumerator() | Sort-Object -Property Key | ConvertTo-Json | Out-File -FilePath .\AzureSQL_Ordered.json
"Output sent to file" | Write-Host
