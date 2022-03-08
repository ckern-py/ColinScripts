function Test-Cred{
         
    [CmdletBinding()]
    [OutputType([String])]   
    Param (
        [Parameter( Mandatory = $false, ValueFromPipeLine = $true, ValueFromPipelineByPropertyName = $true)] 
        [Alias( 'PSCredential')] 
        [ValidateNotNull()] 
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] 
        $Credentials
    )

    $Domain = $null
    $Root = $null
    $ElevatedUserName = $null
    $Password = $null
      
    If($Credentials -eq $null){   
        Try{
            $Credentials = $host.ui.PromptForCredential("AHK Credentials", "Enter your elevated user name and password.", "Work\$env:username-elevated", "")
        }Catch{
            $ErrorMsg = $_.Exception.Message
            Write-Host "Failed to validate credentials, script will exit:" -ForegroundColor Yellow
            Write-Warning $ErrorMsg
            Pause
            Exit
        }
       
    }
      
    # Checking module
    Try{
        # Split username and password
        $ElevatedUserName = $credentials.username
        $Password = $credentials.GetNetworkCredential().password
  
        # Get Domain
        $Root = "LDAP://" + ([ADSI]'').distinguishedName
        $Domain = New-Object System.DirectoryServices.DirectoryEntry($Root, $ElevatedUserName, $Password)
    }Catch{
        $_.Exception.Message
        Continue
    }
  
    If(!$Domain){
        Write-Warning "Something went wrong, the script will exit"
        Pause
        Exit
    }Else{
        If($Domain.name -ne $null){
            Write-Host "Authenticated" -ForegroundColor Green
            Return $Credentials, $true
        }Else{
            Write-Host "Not authenticated, Please try again" -ForegroundColor Red
            Return $null, $false
        }
    }
}

$CredAttempt = 0
Do{
    $CredAttempt ++ 
    $Credentials, $Successful = Test-Cred
}Until(($Successful -eq $true) -or ($CredAttempt -gt 4))

If($CredAttempt -gt 4){
    Write-Host "You are probably locked out, the script will exit" -ForegroundColor Yellow
    Exit
}

Return $Credentials
