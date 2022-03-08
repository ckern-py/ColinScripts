$host.UI.RawUI.WindowTitle = "Seek and Destroy"

$AnotherOne = $True

While($AnotherOne -ne $False){
    $ComputerName = Read-Host "Enter a computer name"
    $ProgramToKill = Read-Host "Enter the program to kill"
    Write-Host "Killing $ProgramToKill on $ComputerName"
    Taskkill /s $ComputerName /f /im $ProgramToKill /t
    $AnotherOne = Read-Host "Another program? (Y/n)"
    if($AnotherOne -eq "n"){
        $AnotherOne = $False
    }
        
}