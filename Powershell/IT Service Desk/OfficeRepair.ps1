
$ComputerName = Read-Host "Please enter a comptuer name"
Write-Output "Connecting to $ComputerName and bringing up O365 Repair"
PSEXEC \\$ComputerName -s cmd /c "C:\program files\Microsoft Office 15\ClientX64\OfficeClickToRun.exe" scenario=Repair platform=x86 culture=en-us forceappshutdown=True RepairType=QuickRepair DisplayLevel=True
Read-Host "Office repair process has completed"