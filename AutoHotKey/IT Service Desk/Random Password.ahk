#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

UtilColor = f9bd43

^+b::
FocusJump(6, 34, "*Requestor:", "Trebuchet.App.exe") ;uses focusjump to find the users id
CBbeforecompfind := ClipboardAll ;Saves current clipboard before copying username
Clipboard :=
SendInput ^a
Sleep 100
SendInput ^c
Sleep 100 
CherwellUserName := RegexReplace(Clipboard,".*\((.+?)\).*","$1") ;by some magic, assigns only what is found between parenthesis to a variable
		If Clipboard = ;if the clipboard is blank makes the username "User name here"
		{
			NameDisplayString := "User Name Here"
		}Else{ ;if not blank removes all new line and trims the display name to upto the first 15 characters of what was found, useful incase activated in another window or something wrong was copied
			NoTabsString := StrReplace(CherwellUserName, "`n")
			NameDisplayString := SubStr(NoTabsString, 1, 15)
		}
Clipboard := CBbeforecompfind ;puts the clipboard back to before the username was copied 
CBbeforecompfind := ;empties the variable invase the clipboard was large

Random, CapWord, 1, 104
Random, LowWord, 105, 192
Random, SymWord, 193, 201
Random, NumWord, 0, 99 
NumWord := Format("{1:02i}",NumWord)
FileReadLine, OneWord, \\Work\Server\ITSD Scripts\AutoHotKey\Data\Password Options.txt, %CapWord%
FileReadLine, TwoWord, \\Work\Server\ITSD Scripts\AutoHotKey\Data\Password Options.txt, %LowWord%
FileReadLine, SymbolWord, \\Work\Server\ITSD Scripts\AutoHotKey\Data\Password Options.txt, %SymWord%
FinalPassword = %OneWord%|%TwoWord%|%SymbolWord%|%NumWord%
Sort, FinalPassword, Random D| Z
RandomPword := StrReplace(FinalPassword,"|","")
SymBeginning := InStr(RandomPword, SymbolWord, False,1,1)
If (SymBeginning = 1){
	NoSym := SubStr(RandomPword, 2)
	RandomPword = %NoSym%%SymbolWord%
}

WinGetPos , COMX, COMY, COMWidth, COMHeight, A ;Gets coords and size of the current active window 
UcompX := (COMX + Ceil(COMWidth / 2)) -75 ;finds the center adjusting for gui size
UcompY := (COMY + Ceil(COMHeight / 2)) -50 ;finds the center adjusting for gui size
CcompX := (COMX + Ceil(COMWidth / 2)) -70 ;finds the center adjusting for gui size
CcompY := (COMY + Ceil(COMHeight / 2)) -34 ;finds the center adjusting for gui size
Gui, UserPwordChange: Add, Text, x25 y5, Change the Password: `n Plese enter an ID ;Text asking user to input a username
Gui, UserPwordChange: Add, Button, x90 y75 w50 Default gStartChangePWord, Search ;search button, default button
Gui, UserPwordChange: Add, Button, x10 y75 w50 gCancelPWord, Cancel ;gui cancel button
Gui, UserPwordChange: Add, Edit, Limit15 Center R1 x15 y45 w120 vSearchUserName, %NameDisplayString% ;makes space on gui to enter username, autofills with found username
Gui, UserPwordChange: -Border +AlwaysOnTop +ToolWindow ;+ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, UserPwordChange: Color, %UtilColor% ;same color as toobar, color choosen by user
Gui, UserPwordChange: Show, x%UcompX% y%UcompY% W150 H100 ;Centers gui for current active window
Return
	
StartChangePWord:
Gui, UserPwordChange: Submit
Gui, UserPwordChange: Destroy
Gui, UserPword: Add, Text, x25 y5, Change the Password: `n Plese enter a password ;Text asking user to input a username
Gui, UserPword: Add, Button, x90 y75 w50 Default gDOChangePWord, Change ;search button, default button
Gui, UserPword: Add, Button, x10 y75 w50 gCancelPWordchange, Cancel ;gui cancel button
Gui, UserPword: Add, Edit, Limit20 Center R1 x15 y45 w120 vPassChange, %RandomPword% ;makes space on gui to enter username, autofills with found username
Gui, UserPword: -Border +AlwaysOnTop +ToolWindow ;+ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, UserPword: Color, %UtilColor% ;same color as toobar, color choosen by user
Gui, UserPword: Show, x%UcompX% y%UcompY% W150 H100 ;Centers gui for current active window
Return

DOChangePWord:
	Gui, UserPword: Submit
	Gui, UserPword: Destroy	
	If FileExist ("C:\temp\PWordSetStatus.txt")
		FileDelete, C:\temp\PWordSetStatus.txt
	PasswordAllDCcript =
		(
			New-Item -Path C:\temp\ -Name "PWordSetStatus.txt" -ItemType "file" -force
			$DCList = Get-ADComputer -Filter * -SearchBase �ou=Domain Controllers,dc=Work,dc=com�
			$DCList.Count | Out-File -Append -filepath C:\temp\PWordSetStatus.txt 
			Foreach ($targetDC in $DCList.Name)
			{
			Try
			{
				Set-ADAccountPassword -Identity %SearchUserName% -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "%PassChange%" -Force) -ErrorAction SilentlyContinue
				$completedmsg = $targetDC + ' Completed'
				$completedmsg | Out-File -Append -filepath C:\temp\PWordSetStatus.txt
			}
			Catch
			{
				$errormsg = $targetDC + ' Error'
				$errormsg | Out-File -Append -filepath C:\temp\PWordSetStatus.txt  
			}
			If ($targetDC -eq $DCList.Name[-1]){
				$EndingPWDmsg = 'Done'
				$EndingPWDmsg | Out-File -Append -filepath C:\temp\PWordSetStatus.txt
			}
			}
 		)
	Try {
			Run PowerShell.exe -Noninteractive -NoLogo -Command &{%PasswordAllDCcript%},,Hide  
		} Catch{ 
			MsgBox, 16,Powershell Failure, Something went wrong `nPowershell Pchange did not run, 5
		}
	Progress, b w300, In Progress, Changing Password
	NewFileContent := ""
	PWtotalDC := ""
	While ! FileExist( "C:\temp\PWordSetStatus.txt" )
  	Sleep 20	
  While PWtotalDC = ""
  	FileReadLine, PWtotalDC, C:\temp\PWordSetStatus.txt, 1

  While ! Instr(NewFileContent,"Done"){
  	Sleep 250
  	fileread newFileContent, C:\temp\PWordSetStatus.txt
  	DCcomplete := 0
  	DCerror := 0
  	Loop, Read, C:\temp\PWordSetStatus.txt 
  	{
  		 Loop, Parse, A_LoopReadLine, `n 
  		 {
  		 		If Instr(A_LoopReadLine,"Complete"){
  		 			DCcomplete ++
  		 		} Else If Instr(A_LoopReadLine,"Error") {
  		 			DCerror ++
  		 		}
   		 }
  	}
  	DCsoFar := DCcomplete + DCerror
  	AmountDone := (DCsoFar/PWtotalDC)*100
  	Progress, %AmountDone%, Successful: %DCcomplete% -- Failed: %DCerror% -- Done: %DCsoFar%/%PWtotalDC%
  	
  }
  Progress,,,Done! Password has been Changed
	Sleep 5000
	Progress, OFF
Return

CancelPWordchange:
CancelPWord: ;Destroys the gui if user hits cancel
UserPwordChangeGuiEscape: ;Destroys the gui if user hits esc
UserPwordGuiEscape:
	Gui, UserPwordChange: Destroy
	Gui, UserPword: Destroy
	Exit
Return

FocusJump(XDiffTemp, YDiffTemp, TextLabelTemp, AppTemp)
{
	DetectHiddenText, On
	ControlGetPos, SorX, SorY, Width, Height, %TextLabelTemp%, ahk_exe %AppTemp%
	SorX += XDiffTemp		;Add the difference between the label's x position and the desired field's x position
	SorY += YDiffTemp		;Add the difference between the label's y position and the desired field's y position
	
	WinGet, List, ControlList, A
	Loop, Parse, List, `n
	{
		ControlGetPos, DestX, DestY, DestW, DestdH, %A_LoopField%, A
		If (DestX = SorX && DestY = SorY)
		{
			ControlFocus, %A_LoopField%, ahk_exe %AppTemp%
		}
		
	}
	Return
}