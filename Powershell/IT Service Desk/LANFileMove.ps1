
#the parameters taken by the script
param([Alias("dloc")][String]$destinationLocation = '', [PSCredential]$creds) 

Function DisplayOptions () {
    Write-Host "Please select a file to move"
    $foundScripts = @()
    $foundCount = 0
    foreach($LANItem in (Get-ChildItem -Path $moveFromFolder -Name)) {
        $foundCount ++
        $foundScripts += $LANItem
        Write-Host "$foundCount) $LANItem"
    }
    $choice = Read-Host "Script Selection"

    $choiceInt = SelectionCheck
    RangeCheck

    return $choiceInt, $foundScripts
}

Function SelectionCheck () {
    Try{
        $choice = [int]$choice
        return $choice
    }Catch [System.Management.Automation.RuntimeException]{
        Write-Host 'That selection is invalid' -ForegroundColor Red
        $invalidRetry = Read-Host "Would you like to try again? (Y/n)"
        if($invalidRetry -eq "n") {
            Pause
            Exit
        } else {
            DisplayOptions
        }
    }
}

Function RangeCheck () {
    If($choiceInt -gt $foundScripts.Count){
        Write-Host 'Index out of range' -ForegroundColor Red
        $invalidRange = Read-Host "Would you like to try again? (Y/n)"
        if($invalidRange -eq "n") {
            Pause
            Exit
        } else {
            DisplayOptions
        }
    }
}

$moveFromFolder = "\\Work.com\IT\ITSD\Scripts\Data\UserScripts"
$creds = Get-Credential

$selection, $foundItems = DisplayOptions

if ($destinationLocation -eq '') {
    $destinationLocation = Read-Host "`nPlease enter the name of the destination machine."
}
Write-Host "Checking if $destinationLocation is online."

if (Test-Connection -ComputerName $destinationLocation -TimeToLive 5 -Quiet) {
    Write-Host "Successful, moving file over" -ForegroundColor Green
} else { 
    Write-Host "Unable to connect to $destinationLocation" -ForegroundColor Red
    Pause
    Exit
}

$psScript = $foundItems[$selection-1]
$_ = New-PSDrive -Name "LANTransfer" -PSProvider FileSystem -Root "\\$destinationLocation\c`$" -Credential $creds
Copy-Item -Path "$moveFromFolder\$psScript" -Destination "\\$destinationLocation\c`$\temp"  -Force
Remove-PSDrive -Name "LanTransfer" -PSProvider FileSystem -Force
Write-Host "File should have been moved over"
