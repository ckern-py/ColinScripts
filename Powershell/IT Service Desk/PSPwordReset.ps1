<#
.Synopsis
   Short description
   PS script is used to change the password for a Work account
.DESCRIPTION
   Long description
   When given a Work account, a domain, a new password, and the option to force a password change the next time the user logs in.
   The script will change the password for a given account and then go through all the Domain Controllers on the domain and change it on each one too
   At the end it will set ChangePasswordAtLogon to True if seleced
.EXAMPLE
   .\PSPwordReset.ps1 -AccountName [WorkID] -NewPassword [PASSWORDSTRING] -SearchDomain [DOMAIN(Work.com, WorkDev.com, or WorkDemo.com)] -F [FORCECHANGE(0 or 1)]
.INPUTS
   Only takes Work ID, a Domain, a new password, and the option to force a password change the next time the user logs in
.OUTPUTS
   Returns when the initial password change has been completed. It also says all the domain controllers that it goes through and the completion status for each
.NOTES
   General notes
   This script is mainly to be used with the ITSDUtil Toolbar. This toolbar is exclusive to the IT Service Desk. This will only change password for accounts, nothing else.
.COMPONENT
   The component this cmdlet belongs to
   I dont know what this means but based off nothing but this link https://docs.microsoft.com/en-us/powershell/developer/cmdlet/cmdlet-overview
   I would say Input processing method???? Im not really sure.
.ROLE
   The role this cmdlet belongs to
   When you hit the pwd reset button this is the  script that is ran and it changes the password for an account and returns the information to the user via another script display.
.FUNCTIONALITY
   The functionality that best describes this cmdlet
   This provides the ITSD with a quick way to change a users password.  Another program provides a random password, so that its never the same
#>


param([string]$AccountName, [string]$NewPassword, [string]$SearchDomain, [string]$F, [PSCredential]$credential) #the parameters taken by the script, F is force password change at next login	

Remove-Item -Path C:\temp\PWordSetStatus.txt #delted the file and then recreates it

Try {
    #tries to do an ititial password rest on the given account. After this is done the user can usually use the new password
    if ($SearchDomain -eq "WorkDemo.com") {
        Set-ADAccountPassword -Identity $AccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$NewPassword" -Force) -Server $SearchDomain 
    } else {
        Set-ADAccountPassword -Credential $credential -Identity $AccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$NewPassword" -Force) -Server $SearchDomain
    }
} Catch {
    "Unsuccessful`r`nDone" | Out-File -Filepath C:\temp\PWordSetStatus.txt #if the password reset fails it is written to file, and the script exits
    Exit
}

$DomTrim = $SearchDomain.Substring(0,$SearchDomain.Length-4) #trims the $SearchDomain to remove ".com". New var used to get all domain controllers
$DCList = Get-ADComputer -Credential $credential -Filter * -SearchBase "ou=Domain Controllers,dc=$DomTrim,dc=com" -server $SearchDomain #gets a list of all domain controllers in the given domain
$DCList.Count | Out-File -Filepath C:\temp\PWordSetStatus.txt #writes count to file so AHK can caclulate % done
'Ititial' | Out-File -Append -Filepath C:\temp\PWordSetStatus.txt
Foreach ($targetDC in $DCList.Name) { #goes through all found domain controllers and sets the password on each one. Also prints the completion status of each to file
    Try {
        if ($SearchDomain -eq "WorkDemo.com") {
	        Set-ADAccountPassword -Identity $AccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$NewPassword" -Force) -Server $targetDC -ErrorAction SilentlyContinue
        } else {
            Set-ADAccountPassword -Credential $credential -Identity $AccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$NewPassword" -Force) -Server $targetDC -ErrorAction SilentlyContinue
        }
		$completedmsg = $targetDC + ' Complete'
		$completedmsg | Out-File -Append -Filepath C:\temp\PWordSetStatus.txt
	} Catch {
	    $errormsg = $targetDC + ' Error' #+ $error[0]
		$errormsg | Out-File -Append -Filepath C:\temp\PWordSetStatus.txt  
	}
	If ($targetDC -eq $DCList.Name[-1]){
		'Done' | Out-File -Append -Filepath C:\temp\PWordSetStatus.txt
	}
}

#if F is set to 1 then ChangePasswordAtLogon is set to True, and the user should be prompted once they log in
If ($F -eq '1') { 
   Set-ADUser -Credential $credential -Identity $AccountName -ChangePasswordAtLogon $True -Server "Work.com"
}
