<#
.Synopsis
   Create ServerGroups and Registered Servers in SSMS
.DESCRIPTION
   This script takes the Json file that was produced in Azure_GetSQLSvrDB.ps1 and creates ServerGroups and Registered Servers in SSMS.
.EXAMPLE
  FROM SSMS PS: C:\temp\Create_SQL_Registration.ps1
.INPUTS
   No inputs currently.
.OUTPUTS
   All ServerGroups and Registered Servers appears in SSMS after you do a refresh and are available for use.
.NOTES
   Run from folder location that is above Saved_Servers. It script looks for Saved_Servers so that it can get a reference
   and then creats an Azure_Imports folder under Saved_Servers where all new Groups and Servers are located. 
#>

$ImportFolder = "Azure_Imports"
$TopLevelName = "Saved_Servers"

$AllAzureData = Get-Content C:\temp\AzureSQL_Ordered.json | ConvertFrom-Json

$TopFolderSQL = Get-ChildItem | Where-Object {$_.Name -eq $TopLevelName}
"Moving to $TopLevelName" | Write-Host
Push-Location .\$TopLevelName

$ImportGroup = New-Object -Typename Microsoft.SqlServer.Management.RegisteredServers.ServerGroup -argumentlist ($TopFolderSQL, $ImportFolder)
$ImportGroup.Create()
"Moving to $ImportFolder" | Write-Host
Push-location .\$ImportFolder

ForEach($AzureGroup in $AllAzureData)
{
    "Creating subdirectory $($AzureGroup.Name)" | Write-Host
    $SQLGroup = New-Object -Typename Microsoft.SqlServer.Management.RegisteredServers.ServerGroup -argumentlist ($ImportGroup, $AzureGroup.Name)
    $SQLGroup.Create()
    Push-Location .\$($AzureGroup.Name)

    ForEach($EnvSQL in $AzureGroup.Value)
    {
        $EnvSQL = $EnvSQL -replace '[@{;}]' -replace ' ',"`r`n"
        $EnvTable = ConvertFrom-StringData -StringData $EnvSQL
        $IndSQLServer = New-Object -Typename Microsoft.SqlServer.Management.RegisteredServers.RegisteredServer -argumentlist ($SQLGroup, $EnvTable.Server)
        $IndSQLServer.ServerName = $EnvTable.LongName
        $IndSQLServer.AuthenticationType = 2
        $IndSQLServer.ActiveDirectoryUserId = 'Colin.Kern@email.com'
        $IndSQLServer.ConnectionString = 'data source={0};initial catalog={1};pooling=False;multipleactiveresultsets=False;connect timeout=30;encrypt=True;trustservercertificate=False;packet size=4096;authentication="Active Directory Password";net=dbmssocn' -f $EnvTable.LongName, $EnvTable.Server
        $IndSQLServer.Create()
        "-Server $($EnvTable.Server) created" | Write-Host
    }
    Pop-Location
}

"All Azure objects created" | Write-Host

"Renaming Registered Servers File" | Write-Host
#Known bug where SSMS reads from RegSrvr but the powershell writes changes to RegSrvr16. So we rename RegSrvr16 to RegSrvr so that changes are picked up.
Remove-Item -Path "$($env:APPDATA)\Microsoft\SQL Server Management Studio\RegSrvr.xml"
Rename-Item -Path "$($env:APPDATA)\Microsoft\SQL Server Management Studio\RegSrvr16.xml" -NewName "RegSrvr.xml"

"Script Complete" | Write-Host
