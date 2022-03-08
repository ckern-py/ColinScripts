
$host.ui.rawui.WindowTitle = "LAN Role Groups"

############################################################################
Function RoleGroupSearch{
    Param([String] $SearchGroup, $FunctionList, [Int] $Depth )
    0..$Depth | %{$Indent += '-'}
    Write-Host "$Indent$SearchGroup"
    $LANGroupsList.Add($SearchGroup)
    try{
        $TwoLevelGroups = (Get-ADGroup $SearchGroup -Properties Members).Members #| ?{[regex]::Match($_, 'CN=(.*)\,OU=Role Groups').Groups[1].Value}
    }catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Host "^Could not find group, might be a user^`n"
    }
    ForEach ($Group in $TwoLevelGroups){
        $JustGroupName = [regex]::Match($Group, 'CN=(.*)\,OU=Role Groups').Groups[1].Value
        if ($JustGroupName -ne ''){
            RoleGroupSearch -SearchGroup $JustGroupName -FunctionList $LANGroupsList
        }
    }
    Return $LANGroupsList
}
#############################################################################
$RoleGroupList = New-Object System.Collections.Generic.List[System.Object] 1000
$LANGroupsList = New-Object System.Collections.Generic.List[System.Object] 1000

$CurrentDirectory = Read-Host 'Please enter a LAN path'
$PathInfo=[System.Uri]$CurrentDirectory
if(-Not ($PathInfo.IsUnc)){
    $CurrentDrive = Split-Path -qualifier $CurrentDirectory
    $LogicalDisk = Get-WmiObject Win32_LogicalDisk -filter "DeviceID = '$CurrentDrive'"
    $CurrentDirectory = Join-Path $LogicalDisk.ProviderName (Split-Path -NoQualifier $CurrentDirectory)
}

Write-Host "Finding Role Groups for UNC location $CurrentDirectory `n"

$AllSecGroups = ((Get-Item $CurrentDirectory).GetAccessControl('Access')).Access

ForEach ($IndividualGroup in $AllSecGroups){
    $RoleGroup = [regex]::Match($IndividualGroup.IdentityReference, 'WORKDOMAIN\\(.*)').Groups[1].Value
    if ($RoleGroup -ne ''){
        $FullList = RoleGroupSearch -SearchGroup $RoleGroup -FunctionList $LANGroupsList -Depth 0
    }
}

$DoUser = Read-Host "`nWould you like to compare the groups to that of a user? (y/N)"
If ($DoUser -ne 'y') {
    Read-Host 'You have chosen not to do a compare. Script will exit when you hit enter'
    Exit
}

$UserID = Read-Host 'Enter a User ID of somone who has similar access'
Write-Host "`n"
foreach ($UserGroup in (Get-ADUser -Identity $UserID -Properties MemberOf).MemberOf){
    $PulledGroup = [regex]::Match($UserGroup, 'CN=(.*?)\,').Groups[1].Value
    $RoleGroupList.Add($PulledGroup)
}

$roleGroupList | ?{$LANgroupsList -contains $_}

Write-Host "`n"
Read-Host 'Script will exit when you hit enter'