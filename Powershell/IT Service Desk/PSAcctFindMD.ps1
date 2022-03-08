<#
.Synopsis
   Short description
   PS script is used to find all account for a user on WorkDemo or WorkDev
.DESCRIPTION
   Long description
   When given a Work account and a domain, the script will find all accounts that start with that user ID. 
   .\PSAcctFindMD.ps1 -AccountName WorkID -SearchDomain WorkDemo.com 
   The above will return the following WorkID, WorkID-test01, WorkID-test02, and WorkID-test03
.EXAMPLE
   .\PSAcctFindMD.ps1 -AccountName WorkID -SearchDomain WorkDemo.com 
   The above will return the following WorkID, WorkID-test01, WorkID-test02, and WorkID-test03 
.EXAMPLE
   .\PSAcctFindMD.ps1 -AccountName [WorkID] -SearchDomain [DOMAIN(WorkDemo.com or WorkDev.com)]
.INPUTS
   Only takes Work ID and Domain as input
.OUTPUTS
   Returns all accounts found for the inputted user ID on the selected domain
.NOTES
   General notes
   This script is mainly to be used with the ITSDUtil Toolbar. This toolbar is exclusive to the IT Service Desk. This will find all accounts, and another script will display them,
   If only one account is found then it goes to the PSAcctValidation.ps1 scrit and gets all that information.
.COMPONENT
   The component this cmdlet belongs to
   I dont know what this means but based off nothing but this link https://docs.microsoft.com/en-us/powershell/developer/cmdlet/cmdlet-overview
   I would say Input processing method???? Im not really sure.
.ROLE
   The role this cmdlet belongs to
   When you hit the M or D button in another script this is the scritp that is ran and it searches for all accounts and returns the information
.FUNCTIONALITY
   The functionality that best describes this cmdlet
   This provides the ITSD with a quick way to look up all accounts for one user in in the WorkDemo or WorkDev domain.
#>


param([string]$AccountName, [string]$SearchDomain, [PSCredential]$credential) #the parameters taken by the script

Remove-Item -Path C:\temp\CMDDSQR.txt #delted the file and then recreates it

$AllFound = dsquery user -o samid -samid $AccountName* -d $SearchDomain #does a dsquery with the given params, finding all the samid's
If ($AllFound.count -gt 0) { #as long as at least one account is found, it runs throug the below code
    If ($AllFound.count -eq 1){ #if only one account is found PSAcctValidation.ps1 is ran on it
        $AllFound.Substring(1,$AllFound.Length-2) | Out-File -Filepath C:\temp\CMDDSQR.txt -append #if only one found trims quotes for AHK to pick up
        "OnlyContinue" | Out-File -Filepath C:\temp\CMDDSQR.txt -append #lets another script know we are moving to another PS file
        .\PSAcctValidation.ps1 -AccountName $AllFound.Substring(1,$AllFound.Length-2) -SearchDomain $SearchDomain -Credential $credential #Sends the info to the other PS file
    } Else {
        $AllFound | Out-File -Filepath C:\temp\CMDDSQR.txt -append #puts all found account, for user to read
    }
 } Else { #if no accounts found writes that to file and is done
  "NoneFound" | Out-File -Filepath C:\temp\CMDDSQR.txt
 }
 'Done' | Out-File -Filepath C:\temp\CMDDSQR.txt -append