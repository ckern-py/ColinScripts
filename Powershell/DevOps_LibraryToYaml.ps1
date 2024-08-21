$org = 'https://dev.azure.com/YourCompanyName'
$proj = 'Project_Name_In_DevOps'

#Put the whole name of the variable group that you want to pull value from
$varGroup="VarGroupName-NonProd"

$pat = "Generate a PAT in DevOps and Put the value here in this string"
#example: $pat = "liaskhdgoawtyg90823qatygfhowefgyh903827rtf80o3wa4gv"

Write-Output $pat | az devops login --organization=$org

"variables:" | Out-File -FilePath C:\Temp\$varGroup.yml

$allGroupVars = az pipelines variable-group list --group-name=$vargroup --org=$org --project=$proj --query "[].variables" | ConvertFrom-Json
$allGroupVars | Get-Member -MemberType NoteProperty | ForEach-Object {Write-Output "    $($_.Name): ""$($allGroupVars.($_.Name).value)"""} | Out-File -FilePath C:\Temp\$varGroup.yml -Append
