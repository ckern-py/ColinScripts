#Quickly close all programs on Friday afternoon.

Read-Host "Press Enter to close your windows"

(Get-Process | ? { $_.mainwindowtitle -ne "" -and $_.processname -ne "powershell" })| Stop-Process

Stop-Process -Name explorer -Force
Start-Process explorer
Stop-Process -Name powershell

Write-Host "Nearly everything should be closed"
Read-Host "Press Enter to shut down the comptuer"

Stop-Computer -Force