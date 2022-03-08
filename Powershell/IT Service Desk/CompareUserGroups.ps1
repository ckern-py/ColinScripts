[CmdletBinding()]
Param ([Parameter(Mandatory=$true)][String] $User1, [Parameter(Mandatory=$false)][String] $User2, [Parameter(Mandatory=$false)][String] $Recursive)

$user2 | Out-File -Filepath C:\AHKLocal\Test.txt

Function RecurseRecurse () {
    Param([string] $DSN, $List)
    $SubGroup = (Get-ADObject $DSN -Properties MemberOf)
    ForEach ($SubDSN in $SubGroup.MemberOf) {
        $List.Add(($SubDSN))
        RecurseRecurse -DSN $SubDSN -List $List
    }
}

Function Get-ADMembershipRecursive( ) { 
    Param([string] $Identity)
    $list = New-Object System.Collections.Generic.List[System.String] 1000
    $BaseLevel = Get-ADOBject (Get-Aduser -Identity $Identity |Select DistinguishedName) -Properties MemberOf
    Foreach ($DSN in $BaseLevel.MemberOf) {
        $List.add($DSN)
        $SubGroup = (Get-ADObject $DSN -Properties MemberOf)
        ForEach ($SubDSN in $SubGroup.MemberOf) {
            $List.Add(($SubDSN))
            RecurseRecurse -DSN $SubDSN -List $list
        }
    }
    $List = $List | Select -Unique
    Return $list
}

#One User List
If ($User2 -eq 'PleaseJustListTheFirstUser') {
    If ($Recursive -eq 'true'){
        $Member1 = Get-ADMembershipRecursive -Identity $user1
    } ElseIF ($Recursive -ne 'true'){
        $Member1 = (Get-ADOBject (Get-Aduser -Identity $User1 | Select DistinguishedName) -Properties MemberOf).MemberOf 
    }
    $member2 = $member1
    (Compare-Object -ReferenceObject ($member1) -DifferenceObject ($member2) -IncludeEqual | Add-Member -MemberType NoteProperty -Name $user2 -Value $Null -PassThru | Add-Member -MemberType NoteProperty -Name $user1 -Value $Null -PassThru | 
    ForEach-Object {
        $_.InputObject -match 'CN=(.*?)\,' | OUt-Null
        if ($_.SideIndicator -eq '=>') {
            $_.$user2 = $Matches[1].Trim()
            $_.$User1 = '-------------'
            $_
        } elseif ($_.SideIndicator -eq '<=')  {
            $_.$user1 = $Matches[1].Trim()
            $_.$User2 = '-------------'
            $_
        }
        Elseif ($_.SideIndicator -eq '==') {
            $_.$User1 = $Matches[1].Trim()
            $_.$User2 = $Matches[1].Trim()
            $_
    } } ) | Sort-Object -Property InputObject| Select $User1| Out-Gridview -title 'Comparision of Users' -wait } 
#Two User Compare
Else {
    If ($Recursive -eq 'true'){
        $Member1 = Get-ADMembershipRecursive -Identity $user1
        $Member2 = Get-ADMembershipRecursive -Identity $user2}
    Else {
        $Member1 = (Get-ADOBject (Get-Aduser -Identity $User1 | Select DistinguishedName) -Properties MemberOf).MemberOf
        $Member2 = (Get-ADOBject (Get-Aduser -Identity $User2 | Select DistinguishedName) -Properties MemberOf).MemberOf}
        (Compare-Object -ReferenceObject ($member1) -DifferenceObject ($member2) -IncludeEqual | Add-Member -MemberType NoteProperty -Name $user2 -Value $Null -PassThru | Add-Member -MemberType NoteProperty -Name $user1 -Value $Null -PassThru | 
        ForEach-Object {
            $_.InputObject -match 'CN=(.*?)\,' | OUt-Null
            if ($_.SideIndicator -eq '=>') {
                $_.$user2 = $Matches[1].Trim()
                $_.$User1 = '-------------'
                $_
            } elseif ($_.SideIndicator -eq '<=')  {
                $_.$user1 = $Matches[1].Trim()
                $_.$User2 = '-------------'
                $_
            }
            Elseif ($_.SideIndicator -eq '==') {
                $_.$User1 = $Matches[1].Trim()
                $_.$User2 = $Matches[1].Trim()
                $_
    } } ) | Sort-Object -Property InputObject| Select $User1, $User2 | Out-Gridview -title 'Comparision of Users' -wait } 