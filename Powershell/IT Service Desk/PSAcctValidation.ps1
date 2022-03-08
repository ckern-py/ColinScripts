<#
.Synopsis
   Short description
   PS script is used to get Work account state
.DESCRIPTION
   Long description
   When given a Work account and a domain, the script will get the accounts current state. It first makes sure that
   the account is valid. Then it checks to see if its disabled. If its enabled it gets the password age and checks if its locked out
   If it is locked out then it runs the account unlocker script?
.EXAMPLE
   .\PSAcctValidation.ps1 -AccountName abc1234 -SearchDomain Work.com 
.EXAMPLE
   .\PSAcctValidation.ps1 -AccountName [WorkID] -SearchDomain [DOMAIN(Work.com, WorkDemo.com, or WorkDev.com)]
.INPUTS
   Only takes Work ID and Domain as input
.OUTPUTS
   Returns the following information for a given account. Returns Present/Absent depending if its a valid account or not.
   Next returns if the account is currently disabled or not (disabled/enabled). If it is enabled the password age is returned, if found. Finally checks
   to see if the account is currently locked. If it is then the PSAcctUnlock script is called to unlock it.
.NOTES
   General notes
   This script is mainly to be used with the AHK ITSDUtil Toolbar. This toolbar is exclusive to the IT Service Desk.
.COMPONENT
   The component this cmdlet belongs to
   I dont know what this means but based off nothing but this link https://docs.microsoft.com/en-us/powershell/developer/cmdlet/cmdlet-overview
   I would say Parameter set
.ROLE
   The role this cmdlet belongs to
   Also dont know what this means. But this PowerShell script plays a  role in the AHK ITSDUtil Toolbar
   When you hit go/search this is the first script that is ran and returns all the information to AHK, and its then displayed.
.FUNCTIONALITY
   The functionality that best describes this cmdlet
   This provides the ITSD with a quick look at a users account. Based off what is found, the correct course of action can be taken
#>

param([string]$AccountName, [string]$SearchDomain, [PSCredential]$credential) #the parameters taken by the script

$UNLServer = @{"Work.com" = "ServerNameHere";"WorkDemo.com" = "ServerNameHere1";"WorkDev.com" = "ServerNameHere2"} #Hash table of the "Top Level" sever for each domain.
# Checks against it to see if a user is locked out. This is ususally the first one to show locked when an account is locked out

Remove-Item -Path C:\AHKLocal\AccountStatUnl.txt #deleted the file and then recreates it, mainly to help AHK

$LSAUser = $credential.username
$LSAPass = $credential.GetNetworkCredential().password

#used dsquery because its faster than Get-ADUser and doesnt have to load the ActiveDirectory module
If (dsquery user -o samid -samid $AccountName -d $SearchDomain) {
    'Present' | Out-File -Filepath C:\AHKLocal\AccountStatUnl.txt #if dsquery finds the account it returns present and continues
	    If (dsquery user -samid $AccountName -d $SearchDomain -disabled -u $LSAUser -p $LSAPass) {	#check is account is currenlty disabled. If so stops, else continues
		    "Disabled" | Out-File -Append -Filepath C:\AHKLocal\AccountStatUnl.txt
		}Else{
			'Enabled' | Out-File -Append -Filepath C:\AHKLocal\AccountStatUnl.txt
            $PdateLtime = Get-ADUser -Credential $credential -Identity $AccountName -Server $UNLServer.$SearchDomain -Properties * | Select PasswordLastSet, LockoutTime #if account is enabled get these attributtes (PasswordLastSet, LockoutTime) for the next step
            Try {
                $PwordAge = New-TimeSpan -Start ($PdateLtime.PasswordLastSet) -End (Get-Date) #tries to get the time difference between when the password was last set and now
                $PwordAge.ToString('dd\d\:hh\h\:mm\m') | Out-File -Append -Filepath C:\AHKLocal\AccountStatUnl.txt #formats the time string and appends it to the file
            } Catch [System.Management.Automation.ParameterBindingException] {
            "00d:00h:00m"| Out-File -Append -Filepath C:\AHKLocal\AccountStatUnl.txt #if the time can not be mathed out it defaults to 0. Mainly happens with WorkDemo.com and WorkDev.com            
            }
			If ($PdateLtime.LockoutTime -ge 1) { #if the lockout time that was retrieved above is greater than one, then account is locked and unlocker script is ran.
			    "Locked`r`nMoving" | Out-File -Append -Filepath C:\AHKLocal\AccountStatUnl.txt #Did not do 0 because that means the password was reset but user hasnt logged in, I think
                .\PSAcctUnlock.ps1 -AccountName $AccountName -SearchDomain $SearchDomain -Credential $credential
			}Else{
				"Unlocked" | Out-File -Append -Filepath C:\AHKLocal\AccountStatUnl.txt   #if account is unlocked then continues like normal                 
			}
		}					
} Else {
    "Absent" | Out-File -Filepath C:\AHKLocal\AccountStatUnl.txt #if dsquery does not find the account Absent is returned
}

"Done" | Out-File -Append -Filepath C:\AHKLocal\AccountStatUnl.txt #used to let AHK know the script is done running