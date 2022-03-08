<#
.Synopsis
   Short description
   PS script is used to unlock a Work account
.DESCRIPTION
   Long description
   When given a Work account and a domain, the script will unlock the account and then go through all the Domain Controllers on the domain and unlock it on each one
.EXAMPLE
   .\PSAcctUnlock.ps1 -AccountName abc1234 -SearchDomain Work.com 
.EXAMPLE
   .\PSAcctUnlock.ps1 -AccountName [WorkID] -SearchDomain [DOMAIN(Work.com, WorkDev.com, or WorkDemo.com)]
.INPUTS
   Only takes Work ID and Domain as input
.OUTPUTS
   Returns when the initial unlock has been completed. It also says all the domain controllers that it goes through and the completion status for each
.NOTES
   General notes
   This script is mainly to be used with the ITSDUtil Toolbar. This toolbar is exclusive to the IT Service Desk. This will only unlock accounts, nothing else.
.COMPONENT
   The component this cmdlet belongs to
   I dont know what this means but based off nothing but this link https://docs.microsoft.com/en-us/powershell/developer/cmdlet/cmdlet-overview
   I would say Input processing method.
.ROLE
   The role this cmdlet belongs to
   Also dont know what this means. But this PowerShell script plays a role in the AHK ITSDUtil Toolbar, the All In One ceneter more specifically.
   When you hit the unlock button this is the script that is ran and it unlocks the account and returns the information to the user via another script display.
.FUNCTIONALITY
   The functionality that best describes this cmdlet
   This provides the ITSD with a quick way to unlock a users account. This is much faster than doing it by hand, which was done before.
#>


param([string]$AccountName, [string]$SearchDomain, [PSCredential]$credential) #the parameters taken by the script

Remove-Item -Path C:\temp\UnlockStatus.txt #delted the file and then recreates it

Try {
    if ($SearchDomain -eq "WorkDemo.com") {
        Unlock-ADAccount -Identity $AccountName -Server $SearchDomain #tries to do an ititial unlock on the given account. After this is done the user can usually get back in
    } else {
        Unlock-ADAccount -Credential $credential -Identity $AccountName -Server $SearchDomain
    }
} Catch {
    "Unsuccessful`r`nDone" | Out-File -Filepath C:\temp\UnlockStatus.txt #if the unlock fails it is written to file, and the script exits
    Exit
}

$DomTrim = $SearchDomain.Substring(0,$SearchDomain.Length-4) #trims the $SearchDomain to remove ".com". New var used to get all domain controllers
$DCList = Get-ADComputer -credential $credential -Filter * -SearchBase "ou=Domain Controllers,dc=$DomTrim,dc=com" -Server $SearchDomain #gets a list of all domain controllers in the given domain
$DCList.Count | Out-File -Filepath C:\temp\UnlockStatus.txt #writes count to file so another script can caclulate % done
'Ititial' | Out-File -Append -Filepath C:\temp\UnlockStatus.txt 
Foreach ($targetDC in $DCList.Name) { #goes through all found domain controllers and unlocks the account on that one. Also prints the completion status of each to file
    Try {
        if ($SearchDomain -eq "WorkDemo.com") {
	        Unlock-ADAccount -Identity $AccountName -Server $targetDC -ErrorAction SilentlyContinue
        } else {
            Unlock-ADAccount -Credential $credential -Identity $AccountName -Server $targetDC -ErrorAction SilentlyContinue
        }
		$completedmsg = $targetDC + ' Completed'
		$completedmsg | Out-File -Append -Filepath C:\temp\UnlockStatus.txt
	} Catch {
		$errormsg = $targetDC + ' Error'
		$errormsg | Out-File -Append -Filepath C:\temp\UnlockStatus.txt  
	}
	If ($targetDC -eq $DCList.Name[-1]) {
		"Done" | Out-File -Append -Filepath C:\temp\UnlockStatus.txt
	}
}
