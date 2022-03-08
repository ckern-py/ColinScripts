<#
Gets all itmes in Credential Manager
if the name contains msteams or microsoftoffice then its split on the = sign
since found resutls look like this 
Target: LegacyGeneric:target=NameOfCredFound
Then deletes the Teams/Office key
#>

foreach ($Cred in CMDKEY /list) {
    if ($Cred -match "msteams.*" -or $Cred -match "microsoftoffice.*") {
        $Name = $Cred.Split('=')[1]
        Write-Host $name
        CMDKEY /delete:$Name
    }
}