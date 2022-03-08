#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$SaveLocation = "C:\temp\WebexToolInstall.msi"
$WebexURL = "https://webex.com/client/WBXclient-39.2.5-8/webexapp.msi"

Invoke-WebRequest -URI "https://webex.com" -OutFile "C:\temp\DownloadWebex.txt" -DisableKeepAlive
Invoke-WebRequest -URI $WebexURL -OutFile $SaveLocation
Remove-Item -Path "C:\temp\DownloadWebex.txt"

Write-Host 'Closing Office and IE' -ForegroundColor Green
Start-Sleep -Seconds 2
Stop-Process -Name iexplore -ErrorAction Ignore -Force -PassThru
Stop-Process -Name OUTLOOK -ErrorAction Ignore -Force -PassThru
Stop-Process -Name WINWORD -ErrorAction Ignore -Force -PassThru
Stop-Process -Name EXCEL -ErrorAction Ignore -Force -PassThru
Stop-Process -Name POWERPNT -ErrorAction Ignore -Force -PassThru
Stop-Process -Name MSPUB -ErrorAction Ignore -Force -PassThru
Stop-Process -Name ONENOTE -ErrorAction Ignore -Force -PassThru

Start-Process $SaveLocation

Read-Host "Download complete. Starting install."
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\temp\WebexToolInstall.msi /passive'