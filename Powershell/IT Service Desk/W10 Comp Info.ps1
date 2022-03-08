#https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-operatingsystem
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject?view=powershell-5.1

#W10 script to get computer info

#Get-WmiObject -class Win32_OperatingSystem -Computername WWVW10751585 | select Name,PrimaryOwnerName
#parallel commands https://stackoverflow.com/questions/4016451/can-powershell-run-commands-in-parallel

<#VDI Format
OS
Power State
CPUs
Ram
HDD Size
HDD Space
Free Space %
IP address
Powered on Uptime (maybe do last reboot?)
#>


function Gather-Information($ComputerSearching) {
    
    Write-Host "Stats for $ComputerSearching"
    $WindowsOS = (Get-WmiObject -class Win32_OperatingSystem -Computername $ComputerSearching).Caption
    $WindowsBit = (Get-WmiObject -class Win32_OperatingSystem -Computername $ComputerSearching). OSArchitecture
    Write-Output "$WindowsOS - ($WindowsBit)"
    
}

function Gather-Computer-Information($ComputerToGather) {
    
    $WindowsOS = (Get-WmiObject -class Win32_OperatingSystem -Computername $ComputerToGather).Caption
    $WindowsBit = (Get-WmiObject -class Win32_OperatingSystem -Computername $ComputerToGather). OSArchitecture
    $WindowsLastBoot = (Get-WmiObject -class Win32_OperatingSystem -Computername $ComputerToGather).LastBootUpTime
    $ComputerFullName = (Get-WmiObject -class Win32_OperatingSystem -Computername $ComputerToGather).CSName
    $ComputerRAM = (Get-WmiObject -class Win32_PhysicalMemory -Computername $ComputerToGather).Capacity #(...)/1000000000
    $ComputerProcessor = (Get-WmiObject -class Win32_Processor -Computername $ComputerToGather).Name
    $ComputerDriveSize = (Get-WmiObject -class Win32_LogicalDisk -Computername $ComputerToGather).Size
    $ComputerDriveFreeSpace = (Get-WmiObject -class Win32_LogicalDisk -Computername $ComputerToGather).FreeSpace
    $ComputerIPAddress = (Get-WmiObject -class Win32_NetworkAdapterConfiguration -Computername $ComputerToGather).IPAddress
    
    $HDDSize = [math]::Round($ComputerDriveSize/1GB, 2)
	$HDDFreeSpace = [math]::Round($ComputerDriveFreeSpace/1GB, 2)
	$HDDFreePercent = [math]::Round(($HDDFreeSpace/$HDDSize) * 100, 2)
    $TotalRAM = [math]::Round($ComputerRAM/1GB, 2)

    Write-Output "Info for $ComputerFullName"
    Write-Output "OS: $WindowsOS - ($WindowsBit)`n"
    Write-Output "Ram: $TotalRAM GB`n"
    Write-Output "CPU: $ComputerProcessor`n"
    Write-Output "HDD Size: $HDDSize GB`n"
    Write-Output "HDD Free: $HDDFreeSpace GB`n"
    Write-Output "Percent Free: $HDDFreePercent%`n"
    Write-Output "IP Address: $ComputerIPAddress`n"
    Write-Output "Last Boot: $WindowsLastBoot"
}

function Information-Display {
    Write-Output "OS: $WinOSInfo.caption - ($WinOSInfo.OSArchitecture)`n"
    Write-Output "Ram: $ComptuerRam"
    Write-Output "CPU: $ComputerProcessor"
    Write-Output "HDD Size: $ComputerDriveInfo.Size"
    Write-Output "HDD Free: $ComputerDriveInfo.Freespace"
    Write-Output "IP Address: $ComputerIPAddress"
}

$ComputerName = Read-Host "Enter a computer name"
Gather-Computer-Information($ComputerName)
