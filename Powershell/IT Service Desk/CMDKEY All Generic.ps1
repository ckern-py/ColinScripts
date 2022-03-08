<#
Gets all itmes in Credential Manager
if the name contains 'legacygeneric' then its split on the = sign
since found resutls look like this 
Target: LegacyGeneric:target=NameOfCredFound
Then deletes the gereric key
#>

foreach ($Cred in CMDKEY /list) {
    if ($Cred -match "legacygeneric.*") {
        $Name = $Cred.Split('=')[1]
        CMDKEY /delete:$Name 
    }
}