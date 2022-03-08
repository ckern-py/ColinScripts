#Requires -Module ActiveDirectory
#This can be turned on by going to Programs and Features > Turn Windows features on or off.
#Browse to Remote Server Administration Tools > Role Administration Tools > AD DS and AD LDS Tools
#Place a checkmark in Active Directory Module for Windows PowerShell and click OK.

#Also need to enable scripts in PowerShell.
#Open PowerShell by clicking Start > type "PowerShell" in the search.
#At prompt, type: Set-ExecutionPolicy remotesigned
#This should still block PowerShell scripts from the Internet. "Unrestricted" would completely unblock, but is not needed here.

#To run this script, right click on the file and choose Run with PowerShell.

#Enables the Active Directory module if installed. Otherwise, errors out.

$host.ui.rawui.WindowTitle = "Account Lookup: Now with a timer!" #name the window

Try
{
  Import-Module ActiveDirectory -ErrorAction Stop
}
Catch
{
  Write-Host "[ERROR]`t ActiveDirectory Module couldn't be loaded. Script will stop!"
  Exit 1
}

#Function to determine if a button is hit in time
Function TimedPrompt($prompt,$secondsToWait){   
    Write-Host -NoNewline $prompt
    $secondsCounter = 0
    $subCounter = 0
    #While no keys are hit and time is less than given param, counts the time 
    #Seems to take about 1.3 times longer than $secondsToWait, with a -m 50
    While ( (!$host.ui.rawui.KeyAvailable) -and ($count -lt $secondsToWait) ){
        start-sleep -m 50
        $subCounter = $subCounter + 50
        if($subCounter -ge 1000)
        {
            $secondsCounter++
            $subCounter = 0
            #Write-Host -NoNewline "."
        }       
        If ($secondsCounter -ge $secondsToWait) { 
            #if no key is hit and time is reached returns false
            return $false;
        }
    }
    #If a key is hit returns true
    return $true;
}


Function Unlocker
{
    param([String]$FindUser)
    [System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)
    #Search for the username and set the UserAcct variable to it, including the challenge question and answer and lockout information.

    #Tries searching for inputted username. If successful gets properties and display info on screen. If it fails, says failed and asks for username again
    Try{
    $Script:UserAcct = Get-ADUser -server "workserver.com" -Identity $UserName -Properties * | Select cn, workAppAssociatedOrganizations, ou, workchallengephrase, workhelpdeskresponse, workReadPrivacyStmt, workAgentID, workAppEmployeeSolutions, oblogintrycount, oblockouttime, enabled
    } Catch {
    Write-Host 'User was not found in Active Directory' -ForegroundColor Red
    Continue
    }
        
    #Show the current values for the found account

        Write-Host '----------------------------------------------------------------------------'        
        Write-Host 'User: ' -NoNewline
        Write-Host $UserAcct.cn -foreground Green
        Write-Host 'Contract: ' -NoNewline
        Write-Host $UserAcct.workAppAssociatedOrganizations -ForegroundColor Green
        Write-Host 'Employer: ' -NoNewline
        Write-Host $UserAcct.ou -ForegroundColor Green
        Write-Host ' '
            If ($UserAcct.enabled -eq $False){
                #Can check is enabled status is set to false (Maybe $False) instead, probably easier, and could catch more codes??
                Write-Host 'Account Status: ' -NoNewline
                Write-Host 'Account is Disabled' -ForegroundColor Red
                Write-Host ' '
            }
        Write-Host 'Benefits Access (If blank, user has not registered for Benefits): ' 
        Write-Host $UserAcct.workAppEmployeesolutions -ForegroundColor Magenta       
        Write-Host ' '
        Write-Host 'If either of the following fields return ''Not Present'' see help article 13578:' -ForegroundColor Yellow
            If ($UserAcct.workAppEmployeesolutions -ne $null -and $UserAcct.workReadPrivacyStmt -eq $null){
                Write-Host 'workReadPrivacySTMT (Benefits Terms): ' -NoNewline
                Write-Host 'Not Present' -ForegroundColor Red
            }Else{
                Write-Host 'workReadPrivacySTMT (Benefits Terms): ' -NoNewline
                Write-Host $UserAcct.workReadPrivacyStmt -ForegroundColor Cyan       
            }
            If ($UserAcct.workAppEmployeesolutions -ne $null -and $UserAcct.workAgentID -eq $null){
                Write-Host 'workAgentID: ' -NoNewline
                Write-Host 'Not Present' -ForegroundColor Red
            }Else{
                Write-Host 'workAgentID: ' -NoNewline
                Write-Host $UserAcct.workAgentID -ForegroundColor Cyan      
            }     
        Write-Host ' '
        Write-Host 'Challenge Question: ' -NoNewline
        Write-Host $UserAcct.workchallengephrase -ForegroundColor Green
        Write-Host 'Challenge Response: ' -NoNewline
        Write-Host $UserAcct.workhelpdeskresponse -ForegroundColor Green
        Write-Host ' '
            If($UserAcct.oblogintrycount -ne $null -or $UserAcct.oblockouttime -ne $null){
                Write-Host 'Login Attempts: ' -NoNewline
                Write-Host $UserAcct.oblogintrycount -ForegroundColor Red
                Write-Host 'Locked Out Status: ' -NoNewline
                Write-Host $UserAcct.oblockouttime -ForegroundColor Red
                Write-Host ' '
        }
        #Goes to TimedPrompt to determine if a user hits a key, ~10 minute time out 
        $val = TimedPrompt "Available options are:`r`nS)earch another username (Scroll up to view history)`r`nN)ew User (Clears history)`r`nC)opy to clipboard`r`nU)nlock`r`nSelction:" 460
        #If no key is hit in time, host is cleared and prompted for username. Else reads key entered and continues 
        if ($val -eq $false){
            Clear-Host
            Write-Host 'Time limit reached. For security reasons the screen has been cleared' -ForegroundColor Red
            Continue
        }Else{
        #Reads the user input and continues based off the selection
        $CnclChoice = Read-Host 
            #If e is selected then no changes are made, console goes to top and asks for username again
            If ($CnclChoice -eq "s") {
                [System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)
                Write-Host 'No changes have been made.'
                #Start-Sleep -seconds 2
            }
            #If h is selected then the console is cleared via clear-host
            ElseIf ($CnclChoice -eq "n"){
                Clear-Host 
            } 
            #Sends info to the clipboard for the user. Name, username, employeer, and contract number
            ElseIf ($CnclChoice -eq "c"){
                $UserInfo = "User: " + $UserAcct.cn + "`r`n"
	            $UserInfo = $UserInfo + "Employer: " + $UserAcct.ou
                #sets clipboard to the gathered info, then reloads the function
	            Set-Clipboard -Value $UserInfo
                Write-Host 'Info has been sent to the clipboard'
                Start-Sleep -seconds 2
                Unlocker -UserAcct $UserName
            }
            #If u is selected unlocks the searched account
            ElseIf ($CnclChoice -eq "u") { 
                #gets a new instance of the username, because it wouldnt work otherwise. It kept throwing errors                     
                $UnlockName = Get-ADUser -server "workserver.com" -Identity $UserName 
                #Prepare to clear these two attributes for the selected user. 
                $UnlockName.oblogintrycount = $null
                $UnlockName.oblockouttime = $null
                #Apply the changes.
                Set-ADUser -Instance $UnlockName 
                Write-Host 'The users account has been unlocked.'
                Start-Sleep -seconds 2
                Unlocker -UserAcct $UserName
            }
            #If the choice is not one of the above, tells you and reloads the function
            Else {
                Write-Host 'That choice appears to be invalid'
                Start-Sleep -seconds 2
                Unlocker -UserAcct $UserName
            }
     }
}

While ($True) {    
    #Prompt for username to be typed in. Then goes to function and runs it with typed username 
    #Loops until told to exit
    $UserName = Read-Host 'Username' 
    If ($UserName -eq "clear"){
        Clear-Host 
    }
    Elseif ($UserName -eq "exit"){
        Exit
    }
    Else
    {
        Unlocker -FindUser $UserName
    }
}
