#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance
ITSDVersion := "June 13, 2019" ;Made up relase date for all the new changes, probably wont happen at the said date

ITSDAgents := {abc1234:"Agent1", abc1000:"Agent2", abc9001:"Agent3", abc9876:"Agent4"}
ScriptUserID := ITSDAgents[A_Username]
RealUser := false
Random, NewNewSeed
Random, ,%NewNewSeed%
		
SetTimer, CheckTime, 300000	;How often, in milliseconds, to check if the file has updated - 300000 for 5 mins

ProdMainDir := "\\Work\Server\ITSD Scripts\AutoHotKey"
StatsFolder := "\\Work\Server\IT Service Desk\Teamwork\ITSDUtil Stats"
MessagesDir := "\\Work\Server\ITSD Scripts\AutoHotkey\Data\Messages\"

If !FileExist("C:\AHKLocal\") ;if the file directory does not exist then it is created and the PS1 files are pulled in
{
	FileCreateDir, C:\AHKLocal\
	Try 
	{
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctValidation.ps1, C:\AHKLocal 
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSPwordReset.ps1, C:\AHKLocal
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctUnlock.ps1, C:\AHKLocal
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctFindMD.ps1, C:\AHKLocal
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSReturnCreds.ps1, C:\AHKLocal
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSRemoteAccess.ps1, C:\AHKLocal
	}
	Catch
		Msgbox Unable to pull in the needed PowerShell files 
}
Else ;checks to make sure all the PS1 files are up to date by doing a comparison. If they are outdated pulls in newest ones
{
	FileGetTime, AcctValLAN, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctValidation.ps1, M
	FileGetTime, PwordResLAN, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSPwordReset.ps1, M
	FileGetTime, AcctUnlLAN, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctUnlock.ps1, M
	FileGetTime, CmdCmmLAN, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctFindMD.ps1, M
	FileGetTime, GetCredsLAN, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSReturnCreds.ps1, M
	FileGetTime, GetRemALAN, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSRemoteAccess.ps1, M
	FileGetTime, AcctValLocal, C:\AHKLocal\PSAcctValidation.ps1, M
	FileGetTime, PwordResLocal, C:\AHKLocal\PSPwordReset.ps1, M
	FileGetTime, AcctUnlLocal, C:\AHKLocal\PSAcctUnlock.ps1, M
	FileGetTime, CmdCmmLocal,  C:\AHKLocal\PSAcctFindMD.ps1, M
	FileGetTime, GetCredsLocal,  C:\AHKLocal\PSReturnCreds.ps1, M
	FileGetTime, GetRemALocal,  C:\AHKLocal\PSRemoteAccess.ps1, M
	If (AcctValLAN > AcctValLocal)
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctValidation.ps1, C:\AHKLocal, 1
	If (PwordResLAN > PwordResLocal)
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSPwordReset.ps1, C:\AHKLocal, 1
	If (AcctUnlLAN > AcctUnlLocal)
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctUnlock.ps1, C:\AHKLocal, 1
	If (CmdCmmLAN > CmdCmmLocal)
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSAcctFindMD.ps1, C:\AHKLocal, 1
	If (GetCredsLAN > GetCredsLocal)
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSReturnCreds.ps1, C:\AHKLocal, 1
	If (GetRemALAN > GetRemALocal)
		FileCopy, \\Work\Server\ITSD Scripts\AutoHotKey\Data\PSRemoteAccess.ps1, C:\AHKLocal, 1
}

;Sets a default for the following variables, in case they are not read from the file, it will load the default
AllDefaultCoords := {CurrentMarqCoordinatesX:0, CurrentMarqCoordinatesY:0, MarqueeFullSize:true, CurrentContCoordinatesX:0, CurrentContCoordinatesY:258, MagicContextColor:"50ff1b", MagicContextFontColor:"Black", MagicMarqueeColor:"b2f3f4", MagicMarqueeFontColor:"Black", AIOColorChoice:"1db4d4", AIOFontColorChoice:"Black", AIOPositionX:0, AIOPositionY:0, CurrentCoordinatesX:0, CurrentCoordinatesY:0, UtilAlwaysOnTop:true, UtilMarqAlwaysOnTop:true, MagicContextShow:true, UtilColorChoice:"1db4d4", SecondClipBoard:"SecondaryPaste", AIOAlwayOnTop:true, UtilFontColor:"Black"}
;Reads the file, splits the lines at the equals sign. If the first part of the split is in the AllDefaultCoords array then the value is updated to what is found
Loop, Read, C:\AHKLocal\ToolBarSettings.txt
{
	CoordsSplit:= StrSplit(A_LoopReadLine, "=")
	If AllDefaultCoords.HasKey(CoordsSplit.1) 
	{
		If ! (CoordsSplit.2 = "")
			AllDefaultCoords[CoordsSplit.1] := CoordsSplit.2 
	}
}	
FileDelete, C:\AHKLocal\ToolBarSettings.txt ;Deletes this file so that it can be re-written
For key, value in AllDefaultCoords ;for all the values in AllDefaultCoords, they are written to file
	FileAppend, %key%=%value%`n, C:\AHKLocal\ToolBarSettings.txt

Loop, Read, C:\AHKLocal\ToolBarSettings.txt ;Reads the file that was just written and created the variables
{ 
	CreationSplit := StrSplit(A_LoopReadLine, "=")
	VarCreated := CreationSplit.1
	%VarCreated% := CreationSplit.2
}	

;Set the initial state for the Magic Button so that it only clears the Context Window.
MagicButton = ClearMagCont

ITSDUtilAdmin := FolderWriteAccess("\\Work\Server\ITSD Scripts") ;Checks to see if the user has write access to the AutoHotkey folder. ITSDUtilAdmin = 1/true = yes, 0/false = no.

StatType := "HotString" ;This makes the default stat "HotString." If the user uses MCM or Toolbar, it will change to those and then revert back to default of HotString.

Gosub, UpdateMessages

WaitEnter := false ; Sets up the default for hot strings to not require an extra Enter.

CurrentMarq := 1
CurrentMessage := MWMessage1
CurrentTitle := MWMTitle1
CurrentDate := MWMDate1
StringTrimRight, CurrentTitle, CurrentTitle, 4
PlayMarquee := true
FileGetTime, ModNewMsg, %A_ScriptDir%\Data\NewMsgTrigger.txt, M

SetTimer, UpdateMessages, 5000
SetTimer, NextMarquee, 10000
SetTimer, NewMsgAlert, 500

;------------------------------------------------------------------------

CrLf = `r`n
WinDockFile := "C:\temp\WinPos.txt"

MCMHeading := ["Passwords", "Support", "Quick Reference", "Access Requests", "Installations"]
MCMLoopTimes := MCMHeading.MaxIndex() ;The number of objects in array MCMHeading
	
YYY := 6 ;Starting position of the Y coordinate when making the tool bar drop downs
Loop %MCMLoopTimes%
{
	Values := MCMHeading[A_Index] ;The heading of each dropdown, selected from the array
	Gui, MClickMenu: Add, DropDownList, x10 y%YYY% w140  vListMCM%A_Index% gOnSelectMCM10, %Values%|| ;Builds the dropdown options and the list under each heading
	MPlace := A_Index
	Loop, %A_ScriptDir%\Data\DropDownList\%Values%\*.* ;Loops through the files and gets the names of them all
	{ 
		DropName := SubStr(A_LoopFileName, 1, -4) ;Gets the name from the file and removes .txt
		GuiControl, MClickMenu:,ListMCM%MPlace%, %DropName% ;Puts the trimmed name in the toolbar as an option
	}	
	YYY += 27 ;increases Y for next dropdown
}	
		
Gui MClickMenu: Add, Button, x155 y60, X
Gui MClickMenu: Add, Picture, x155 y114 gUnchecker, %A_ScriptDir%\Data\UncheckSrchOpt.jpg
Gui MClickMenu: +AlwaysOnTop -Caption -Border

;The following lines set up the gui and the dropdown boxes with all of their selections below. If changing, need to also change wording on OnSelect section below.
BarNames := ["External", "Password Issues", "Windows", "Outlook", "VPN and VIP", "Mobile Email", "VMware", "OneDrive", "Web Conference", "Security", "MFP", "ADUC and LAN", "Hardware", "Current"]
BarLoopTimes := BarNames.MaxIndex() ;The number of objects in array BarNames
	
XX := 27 ;Starting position of the X coordinate when making the tool bar drop downs
YY := 12 ;Starting position of the Y coordinate when making the tool bar drop downs
Loop %BarLoopTimes%
{
	Value := BarNames[A_Index] ;The heading of each dropdown, selected from the array
	Gui, ITSDToolbar: Add, DropDownList, x%XX% y%YY% w120  vList%A_Index% gOnSelect10, %Value%|| ;Builds the dropdown options and the list under each heading
	PPlace := A_Index
	Loop, %A_ScriptDir%\Data\DropDownList\%Value%\*.* ;Loops through the files and gets the names of them all
	{
		DDName := SubStr(A_LoopFileName, 1, -4) ;Gets the name from the file and removes .txt
		GuiControl, ITSDToolbar:,List%PPlace%, %DDName% ;Puts the trimmed name in the toolbar as an option
	}
	XX += 121 ;increases X for next dropdown
	If (A_Index = Ceil(BarLoopTimes/2)) ;After getting half way through the total BarNames resets X and changes Y to next level
	{
		XX := 27
		YY := 35
	}	
}

EandFWB := Ceil(BarLoopTimes/2)*121+28 ;Where to place the FixWins and Exit buttons, auto place after last dropdowns
Gui, ITSDToolbar: Add, Button, x5 y11 w20, ?
Gui, ITSDToolbar: Add, Button, x5 y34 w20, O
Gui, ITSDToolbar: Add, Button, x%EandFWB% y34 w49, FixWins
Gui, ITSDToolbar: Add, Button, x%EandFWB% y11 w49, Exit

;This, along with the WM_LBUTTONDOWN() function below allows the user to move the gui by clicking anywhere (except the buttons or drop down lists).
OnMessage(0x0201, "WM_LBUTTONDOWN")

FileGetTime, ModTime, %A_ScriptFullPath%, M	;when the script first launches, check the last modified date (to compare against when timer above goes off)
FileGetTime, ModTimeMaster, %A_ScriptDir%\Data\UpdateTrigger.txt, M ;this will check last modified date of the updatetrigger file, which is updated when the editor changes are saved

Gui, MagWinMarq: Font, c%MagicMarqueeFontColor% s9 underline, Verdana
Gui, MagWinMarq: Add, Text, x13 y4 w200 h18 vMagMsgTtl gMarqSize, %CurrentTitle%
Gui, MagWinMarq: Font, c%MagicMarqueeFontColor% s9 norm, Verdana
Gui, MagWinMarq: Add, Edit, ReadOnly x1 y23 w222 h200 vMagMsgTxt -VScroll, %CurrentMessage%
Gui, MagWinMarq: Add, Text, x4 y223 vLastModifiedTxt, Last modified: 
Gui, MagWinMarq: Add, Text, x100 y223 w120 vMagMsgDt, %CurrentDate%
Gui, MagWinMarq: Font, 000000 s8, Verdana
Gui, MagWinMarq: Add, Button, Default x47 y243 vPauseM gPauseMarquee, Pause
Gui, MagWinMarq: Add, Button, x23 y243 vNextM gNextMarquee, >
Gui, MagWinMarq: Add, Button, x3 y243 vPrevM gPrevMarquee, <
If (ITSDUtilAdmin = true) ;If the user has write access to the ITSD Scripts folder.
{
	Gui, MagWinMarq: Add, Button, x105 y243 vAddM gAddMarquee, Add
	Gui, MagWinMarq: Add, Button, x139 y243 vEditM gEditMarquee, Edit
	Gui, MagWinMarq: Add, Button, x172 y243 vDelM gDelMarquee, Delete
}
Gui, MagWinMarq: Color, %MagicMarqueeColor%
If (UtilMarqAlwaysOnTop = true)
	Gui, MagWinMarq: +AlwaysOnTop -Border
Else
	Gui, MagWinMarq: -Border
If (MarqueeFullSize = true)
	Gui, MagWinMarq: Show, x%CurrentMarqCoordinatesX% y%CurrentMarqCoordinatesY% h270 w226 NA, ITSDMarquee
Else 
	Gui, MagWinMarq: Show, x%CurrentMarqCoordinatesX% y%CurrentMarqCoordinatesY% h18 w226 NA, ITSDMarquee

Gui, MagWinCont: Font, c%MagicContextFontColor% s9, Verdana
Gui, MagWinCont: Add, Edit, x2 y1 w250 h200 +Left +ReadOnly vMagContTxt -VScroll
Gui, MagWinCont: Color, %MagicContextColor%
Gui, MagWinCont: +AlwaysOnTop -Border
	
If (MagicContextShow = true)
	Gui, MagWinCont: Show, x%CurrentContCoordinatesX% y%CurrentContCoordinatesY% w253 NA, ContextTips
Else
{
	Gui, MagWinCont: Add, Button, x194 w55 gDismiss, Dismiss
	Gui, MagWinCont: Show, x%CurrentContCoordinatesX% y%CurrentContCoordinatesY% w253 NA, ContextTips
	Gui, MagWinCont: Hide
}

;The following creates an opposite color of the AIOCenter used for getting attention with ContextTips. Briefly flashes to this color. Called with OppColor.
;Also creates lighter shades of the AIO center and the Util Toolbar for menu popups
GuiColor := AIOColorChoice
	
OppR := (255 - hex2r(GuiColor) != 0 && 255 - hex2r(GuiColor) != 255) ? 254 - hex2r(GuiColor) : 255 - hex2r(GuiColor)
OppG := (255 - hex2g(GuiColor) != 0 && 255 - hex2g(GuiColor) != 255) ? 254 - hex2g(GuiColor) : 255 - hex2g(GuiColor)
OppB := (255 - hex2b(GuiColor) != 0 && 255 - hex2b(GuiColor) != 255) ? 254 - hex2b(GuiColor) : 255 - hex2b(GuiColor)
OppColor := RGBtoHex(OppR "," OppG "," OppB)
	
UpShdR := (75 + hex2r(GuiColor))
UpShdG := (75 + hex2g(GuiColor))
UpShdB := (75 + hex2b(GuiColor))
UpShdColor := RGBtoHex(UpShdR "," UpShdG "," UpShdB)
	
If (AIOAlwayOnTop = true)
	Gui, AIOCenter: +AlwaysOnTop -Border ;make gui always on top and have no border
Else
	Gui, AIOCenter: -Border
Gui, AIOCenter: Margin, 5 ;sets outside margins of 5, if not specified
Gui, AIOCenter: Font, c%AIOFontColorChoice%
Gui, AIOCenter: Add, Text, Center,Welcome To The All In One User Center`nEnter A User ID: ;text welcoming user to the AIOcenter
Gui, AIOCenter: Font, Black
Gui, AIOCenter: Add, Edit, Limit20 Center R1 x40 y35 w120 vAccountToGetInfo, UserNameHere ;field to enter username
Gui, AIOCenter: Font, c%AIOFontColorChoice%
Gui, AIOCenter: Add, Button, Default Center x165 y35 w30 H21 gSearchID, Go ;go button, searches based off inputted username
Gui, AIOCenter: Add, Button, Center x5 y24 w30 H21 gWorkDemo, M 
Gui, AIOCenter: Add, Button, Center x5 y45 w30 H21 gWorkDev, D 
Gui, AIOCenter: Add, Text, Center x40 y60 w120 vOtherDomain, Domain: Work ;displays the search domain, defual is Work
Gui, AIOCenter: Add, Text, x5 y73 w190 h2 0x4 ;0x1000 ;0x4 for black line F ;dividing line
Gui, AIOCenter: Add, Text, Left x5 y78 w125 vPersonComputers,User Computers`: ;below is found comptuer 
Gui, AIOCenter: Font, Black
Gui, AIOCenter: Add, ListBox, x5 y95 vComputerSelection R5 gUserComputerSelection,Found|Computers|Appear|Here ;120w 69H or 116W 65H??? ;all the found computers for the searched user
Gui, AIOCenter: Font, c%AIOFontColorChoice%
Gui, AIOCenter: Add, Text, Right x125 y78 w70 vAgeOfPassword, Pword Age
Gui, AIOCenter: Add, Button, Center x130 y95 w65 H21 gUnlockAccount,Unlock ;runs an unlocker script for the selected accoutn
Gui, AIOCenter: Add, Button, Center x130 y143 w65 H21 gResetPassword ,Pwd Reset ;resets the password for the selected accoutn 
Gui, AIOCenter: Add, Picture, x130 y119 w65 h-1 vAccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOStatus.png ;account status display. unlcoked, locked, etc
Gui, AIOCenter: Add, Text, Right x75 y172 w120 vRandomGenPword, ;place for showing password when its chaned, only shows for a limited time 
Gui, AIOCenter: Add, Button, Center x5 y213 w60 h21 gCopyComp, Copy ;copy the name of the selected computer to the clipboard
Gui, AIOCenter: Add, Button, Center x70 y213 w60 h21 gPasteComp, Paste ;pastes the name fo hte selected computer into the cherwell window where the username was pulled from 
Gui, AIOCenter: Add, Button, Center x135 y213 w60 h21 gCompFileExplorer, Win Exp ;open windows explorer and goes to the C: drive of the selected comptuer
Gui, AIOCenter: Add, Text, Center x5 y241 w190 vUpdateInfo, Status Bar Information ;information on what is happening, usually changes when hitting buttons
Gui, AIOCenter: Add, StatusBar, Center w200 H21 vProgressBarPercent, Progress Bar Info ;progress bar with % done, changes when doing unlock or Pwd Reset
Gui, AioCenter: Font, underline bold s11
Gui, AIOCenter: Add, Text, Left x5 y190 w195 vContextTipLink gContextTipClick ;ContextTips Changed when the user types certain words. Clicking opens a gui with information.
Gui, AIOCenter: Color, %AIOColorChoice% ;the selected color for the AIOCenter
Gui, AIOCenter: Show, NA x%AIOPositionX% y%AIOPositionY% W200 H283, AIOCenter ;displays the gui at this size

;----------------------------------------------------------------------

Gui MClickMenu: Color, %UtilColorChoice%

;Names the toolbar and loads certain attributes based off the location that it is opened from

If InStr(A_ScriptDir, "Dev") 
{
	NameIdentify := "ITSDUtil Dev" ((InStr(A_ScriptName, "Colin")) ? " Colin" : "")
	If (UtilAlwaysOnTop = true)
		Gui, ITSDToolbar: +AlwaysOnTop +border
	Else
		Gui, ITSDToolbar: +border
}
Else If InStr(A_ScriptDir, "Demo") 
{
	NameIdentify := "ITSDUtil DEMO" ((InStr(A_ScriptName, "Colin")) ? " Colin" : "")
	If (UtilAlwaysOnTop = true)
		Gui, ITSDToolbar: +AlwaysOnTop +border
	Else
		Gui, ITSDToolbar: +border
}
Else  
{
	NameIdentify := "ITSDUtil"
	If (UtilAlwaysOnTop = true)
		Gui, ITSDToolbar: +AlwaysOnTop -caption +border
	Else
		Gui, ITSDToolbar: -caption +border
}
;padding of 10 around whole outside of UtilOptions
Gui, UtilOptions: Font, bold
Gui, UtilOptions: Add, Text, x10 y10, ITSDUtil version`:
Gui, UtilOptions: Font, norm
Gui, UtilOptions: Add, Text, x10 y24, %ITSDVersion%
If (ITSDUtilAdmin = true)
{
	Gui, UtilOptions: Add, Button, x336 y10 gLaunchEditor, Launch Editor
	Gui, UtilOptions: Font, bold
	Gui, UtilOptions: Add, Text, x227 y15, < KCS team only >
	Gui, UtilOptions: Font, norm
	Gui, UtilOptions: Add, Button, x144 y10 gLaunchEmailThing, Major Incident
}
;Gui, UtilOptions: Font, norm
;Gui, UtilOptions: Add, Text, x120 y33, Colors (without #):
Gui, UtilOptions: Add, Text, x10 y59 w70, Toolbar:
Gui, UtilOptions: Add, Edit, x85 y55 w60 center vUtilColorChoice, %UtilColorChoice%
Gui, UtilOptions: Add, Text, x157 y59, Font Color:
Gui, UtilOptions: Add, Edit, x213 y55	w60 center vUtilFontColor, %UtilFontColor%
Gui, UtilOptions: Add, Text, x10 y84 w70, Notifications:
Gui, UtilOptions: Add, Edit, x85 y80 w60 center vMagicMarqueeColor, %MagicMarqueeColor%
Gui, UtilOptions: Add, Text, x157 y84, Font Color:
Gui, UtilOptions: Add, Edit, x213 y80	w60 center vMagicMarqueeFontColor, %MagicMarqueeFontColor%
Gui, UtilOptions: Add, Text, x10 y109 w70, ContextTips:
Gui, UtilOptions: Add, Edit, x85 y105 w60 center vMagicContextColor, %MagicContextColor%
Gui, UtilOptions: Add, Text, x157 y109, Font Color:
Gui, UtilOptions: Add, Edit, x213 y105 w60 center vMagicContextFontColor, %MagicContextFontColor%
Gui, UtilOptions: Add, Text, x10 y134 w70, AIOCenter:
Gui, UtilOptions: Add, Edit, x85 y130 w60 center vAIOColorChoice, %AIOColorChoice%
Gui, UtilOptions: Add, Text, x157 y134, Font Color:
Gui, UtilOptions: Add, Edit, x213 y130 w60 center vAIOFontColorChoice, %AIOFontColorChoice%
Gui, UtilOptions: Add, Text, x10 y160 w404 center, Use color codes for windows colors and color words (eg. "blue") for font colors.
Gui, UtilOptions: Add, Text, x10 y175 w404 center, For color codes, use the drop down at the top from the site:
Gui, UtilOptions: Font, underline
Gui, UtilOptions: Add, Text, x10 y190 w404 center cBlue gColorHex, http://www.color-hex.com/
Gui, UtilOptions: Font, norm
If (UtilAlwaysOnTop = true)
	Gui, UtilOptions: Add, Checkbox, x285 y59 Checked vUtilAlwaysOnTop, Always On Top?
Else
	Gui, UtilOptions: Add, Checkbox, x285 y59 vUtilAlwaysOnTop, Always On Top?
If (UtilMarqAlwaysOnTop = true)
	Gui, UtilOptions: Add, Checkbox, x285 y84 Checked vUtilMarqAlwaysOnTop, Always On Top?
Else
	Gui, UtilOptions: Add, Checkbox, x285 y84 vUtilMarqAlwaysOnTop, Always On Top?
If (MagicContextShow = true)
	Gui, UtilOptions: Add, Checkbox, x285 y109 Checked vMagicContextShow, Always Show?
Else
	Gui, UtilOptions: Add, Checkbox, x285 y109 vMagicContextShow, Always Show?
If (AIOAlwayOnTop = true)
	Gui, UtilOptions: Add, Checkbox, x285 y134 Checked vAIOAlwayOnTop, Always On Top?
Else
	Gui, UtilOptions: Add, Checkbox, x285 y134 vAIOAlwayOnTop, Always On Top?
Gui, UtilOptions: Add, Button, x10 y212 W45 Default vUtilOptionsOKAY, OK
Gui, UtilOptions: Add, Button, x69 y212 W45, Cancel ;x45
Gui, UtilOptions: Add, Button, x310 y212 gSaveWin, Save Win Positions
Gui, UtilOptions: -caption +border +AlwaysOnTop
Gui, ITSDToolbar: Font, c%UtilFontColor%
Gui, ITSDToolbar: Color, %UtilColorChoice%
Gui, ITSDToolbar: show, NA x%CurrentCoordinatesX% y%CurrentCoordinatesY%, %NameIdentify%	;Make the gui appear. Creates it using the settings above that start with "Gui."

Run, PowerShell.exe -NoProfile -NoLogo -NoExit -Command $cr = .\PSReturnCreds.ps1, C:\AHKLocal\, Hide, PSOutVar
SetKeyDelay, 5, 0
	
Return

LaunchEmailThing:
	Run C:\Program Files\AutoHotkey\AutoHotkey.exe "%A_ScriptDir%\NotificationEmailer.ahk"
	Gui, UtilOptions: Hide
Return

LaunchEditor:
	FileGetAttrib, EditorInUse, %A_ScriptDir%\Editor\EditLocker.txt
	IfInString, EditorInUse, R
	{
		Gui, UtilOptions: Hide
		IniRead, LockedByUser, %A_ScriptDir%\Editor\Editor.ini, LockedUnder, LockedByUser
		MsgBox,, Locked by %LockedByUser%, The Editor is in use by %LockedByUser% right now. It will become available again when that user saves or abandons their current changes.
		Return
	}
	Else
	{
		FileSetAttrib, +R, %A_ScriptDir%\Editor\EditLocker.txt
		IniWrite, %A_UserName%, %A_ScriptDir%\Editor\Editor.ini, LockedUnder, LockedByUser
		Run, C:\Program Files\AutoHotkey\AutoHotkey.exe "%A_ScriptDir%\ITSDUtil Editor.ahk"
		Gosub, SaveCoords
		ExitApp
	}
Return

;Accurate way to jump to fields within an application. Jumps from adjacent text label to field. Does not work for destination fields that begin with HwndWrapper.
FocusJump(XDiffTemp, YDiffTemp, TextLabelTemp, AppTemp)
{
	DetectHiddenText, On
	ControlGetPos, SorX, SorY, Width, Height, %TextLabelTemp%, %AppTemp%
	SorX += XDiffTemp		;Add the difference between the label's x position and the desired field's x position
	SorY += YDiffTemp		;Add the difference between the label's y position and the desired field's y position
	WinGet, List, ControlList, A
	Loop, Parse, List, `n
	{
		ControlGetPos, DestX, DestY, DestW, DestdH, %A_LoopField%, A
		If (DestX = SorX && DestY = SorY)
			ControlFocus, %A_LoopField%, %AppTemp%
	}
	Return
}


ClickJump(XDiffTemp, YDiffTemp, TextLabelTemp, AppTemp)
{
	DetectHiddenText, On
	ControlGetPos, SorX, SorY, Width, Height, %TextLabelTemp%, %AppTemp%
	SorX += XDiffTemp		;Add the difference between the label's x position and the desired field's x position
	SorY += YDiffTemp		;Add the difference between the label's y position and the desired field's y position
	WinGet, List, ControlList, A
	Loop, Parse, List, `n
	{
		ControlGetPos, DestX, DestY, DestW, DestdH, %A_LoopField%, A
		If (DestX = SorX && DestY = SorY)
			ControlClick, %A_LoopField%, %AppTemp%
	}
	Return
}

BetSend(SendWhat)
{
	Control, EditPaste, %SendWhat%, %A_LoopField%, ahk_exe %AppTemp%
}

ClassificationFill(ClassifySearch)
{
	Clipboard :=  ""
	Sleep 200
	SendInput ^a ;Selects everything
	Sleep 100
	SendInput ^c ;Copies what it selects
	Sleep 100
	If (Clipboard = "") ;If you press the hot keys when no words are present it will paste what is on the clipboard
	{
		Clipboard := ClassifySearch
		Sleep 100
		SendInput ^v ;Pastes what it just parsed
		Sleep 200
		SendInput {enter} ;Hits enter to bring up the classify options screen
	}
	Else
		Sleep 100
		Send {Shift Down}{Tab}{Shift Up}
	Return
}

CheckTime:
	IfExist, %A_ScriptFullPath%
	{
		FileGetTime, ModTime2, %A_ScriptFullPath%, M
		If (ModTime2 != ModTime)
		{
			Gosub, SaveCoords	
			Sleep, 1000
			Reload
		}
	}
	Else
	{
		MsgBox, 0, Error, ITSDUtil has lost connection to the LAN. Please re-launch.
		ExitApp
	}
;--------------------------------
	IfExist, %A_ScriptDir%\Data\UpdateTrigger.txt
	{
		FileGetTime, ModTimeMaster2, %A_ScriptDir%\Data\UpdateTrigger.txt, M
		If (ModTimeMaster2 != ModTimeMaster)
		{
			Gosub, SaveCoords	
			Sleep, 1000
			Reload
		}
	}
	Else
	{
		MsgBox, 0, Error, ITSDUtil has lost connection to the LAN and has stopped updating. Please re-launch.
		SetTimer, CheckTime, OFF
	}
Return


SaveCoords:
	Process, Close, %PSOutVar%
	Gui ITSDToolbar: +LastFound ;Using this method with +LastFound so that it will work even if opened from another directory (since The named of the window is dependent on the folder the script is run from).
	;Gets the current coordinates for the GUI windows
	WinGetPos, CurrentCoordinatesX, CurrentCoordinatesY
	WinGetPos, AIOPositionX, AIOPositionY, ,, AIOCenter
	WinGetPos, CurrentMarqCoordinatesX, CurrentMarqCoordinatesY, ,, ITSDMarquee
	If WinExist("ContextTips")
		WinGetPos, CurrentContCoordinatesX, CurrentContCoordinatesY, ,, ContextTips
	;Reads file, if key is found in array then updates the value
	Loop, Read, C:\AHKLocal\ToolBarSettings.txt
	{
		CloseSplit := StrSplit(A_LoopReadLine, "=")
		CloseKey := CloseSplit.1
		If AllDefaultCoords.HasKey(CloseSplit.1)
			AllDefaultCoords[CloseSplit.1] := %CloseKey%
	}	
	;Deletes the files and then re-writes it with a FOR loop, to reflect the updated values 
	FileDelete, C:\AHKLocal\ToolBarSettings.txt
	For key, value in AllDefaultCoords
		FileAppend, %key%=%value%`n, C:\AHKLocal\ToolBarSettings.txt
Return

FolderWriteAccess( Folder ) {
	If InStr( FileExist(Folder), "D" ) 
	{
  	FileAppend,,%Folder%\fa.tmp
  	rval := ! ErrorLevel
  	FileDelete,,%Folder%\fa.tmp
  	Return rval 
	}
	Return - 1  
}
Return

JumpDescFill:
	FocusJump(3, 24, "*Short Description:", "Cherwell Service Management")
	TempClip := ClipboardAll
	SendInput ^a
	DescTextLineSplit := StrSplit(DescText, "`n")
	Clipboard := DescTextLineSplit.1
	Sleep, 100
	SendInput ^v
	Sleep, 100
	SendInput {TAB}
  Sleep 100
  Clipboard := DescText
	Sleep, 100
	SendInput ^v
	Sleep 100
	SendInput {enter}
	Sleep, 100
	SendInput {TAB}
	ClassificationFill(ClassText)
	Clipboard := TempClip
Return

AutoPaster:
	If (ResolutionText != "")
	{
		SecondClipBoard := ResolutionText
		ResolutionText := ""
	}
	SetTitleMatchMode, 2
	WinGet, CWNum, count, Cherwell Service Management 
	If CWNum > 1
	{
		WinWaitActive, Cherwell Service Management , , 5
		If ErrorLevel
			Return
		Else
		{
			CoordMode, Pixel, Window
			ImageSearch, , , 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, %A_ScriptDir%\Data\ImgSrchSrce\CheckedBox.png
			If(ErrorLevel == 0)
				Gosub, Unchecker
			FocusJump(3, 20, "Search for:" ,"Cherwell Service Management")
			Sleep 100
			SendInput %SearchText%
			Sleep, 100
			SendInput {enter}
			Gosub, StatGrabber1
			StatTemp := StatType ;Saves the current stat type
			StatType := "HotString" ;Reverts back to HotString type after saving stat
			If (WaitEnter = true) ;If the user used a toolbar or middleclick menu option instead of a hot string
			{
				KeyWait, Enter, D T3 ;Wait for the "Enter" key to be pressed, but only operate if within T seconds.
				WaitEnter := false
				If ErrorLevel									
					Return
			}
			Gosub, StatGrabber2
			Gosub, JumpDescFill
		}
	}
	Else If CWNum < 1
		Return
	Else If CWNum = 1
	{
		CoordMode, Pixel, Window
		WinActivate, Cherwell Service Management 
		ImageSearch, , , 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, %A_ScriptDir%\Data\ImgSrchSrce\CheckedBox.png
		If(ErrorLevel == 0)
			Gosub, Unchecker
		SendInput ^+k
		Sleep, 500
		SendInput ^a
		Sleep, 500
		SendInput %SearchText%
		Sleep, 200
		SendInput {enter}
		Gosub, StatGrabber1
		StatTemp := StatType ;Saves the current stat type
		StatType := "HotString" ;Reverts back to HotString type after saving stat
		If (WaitEnter = true) ;If the user used a toolbar or middleclick menu option instead of a hot string
		{
			KeyWait, Enter, D T3 ;Wait for the "Enter" key to be pressed, but only operate if within T seconds.
			WaitEnter := false
			If ErrorLevel
				Return
		}
		Gosub, StatGrabber2
		Gosub, JumpDescFill
	}
Return

;Subroutine that creates a stat with a header of StatType and a value for DescText.
;It uses the currently logged in user's username and the week date as the file name that it outputs to.
;The output folder is defined by StatsFolder near the top of this script.
;If the stat already exists for the user and week combination, then it increments it.
StatGrabber1:
	WeekOf = % WeekPrevSun()
	IfExist, %StatsFolder%\%A_UserName%-%WeekOf%.ini
	{
		IniRead, StatTemp, %StatsFolder%\%A_UserName%-%WeekOf%.ini, %StatType%, %DescText%
		If !StatTemp
			StatTemp := 0
		StatTemp += 1
	}
	Else
		StatTemp := 1
	IniWrite, %StatTemp%, %StatsFolder%\%A_UserName%-%WeekOf%.ini, %StatType%, %DescText%
Return

;The same as StatGrabber1 but corrects the StatType for certain situations that can't set the StatType variable for some reason.
StatGrabber2:
	WeekOf := WeekPrevSun()
	If (StatType != "AIOSearch")
		StatType := StatTemp ;Corrects the type back to the saved value unless it's already AIOSearch
	IfExist, %StatsFolder%\%A_UserName%-%WeekOf%.ini
	{
		IniRead, StatTemp2, %StatsFolder%\%A_UserName%-%WeekOf%.ini, %StatType%Fill, %DescText%
		If !StatTemp2
			StatTemp2 := 0
		StatTemp2 += 1
	}
	Else
		StatTemp2 := 1
	IniWrite, %StatTemp2%, %StatsFolder%\%A_UserName%-%WeekOf%.ini, %StatType%Fill, %DescText%
	StatType := "HotString"
Return

WeekPrevSun()
{
	d += 1-A_WDay, Days
	FormatTime, d, %d%, yyyyMMdd
	Return d
}

; This, along with the OnMessage section above allows the user to move the Guis by clicking anywhere (except for controls)
; Commented out... This also will cause one click to select all text in any Edit control labeled with HWNDhedit1 in options.
WM_LBUTTONDOWN(Parm1,Parm2,Parm3,Parm4)
{
	global
;  static Focus
	If (A_Gui)
		PostMessage, 0xA1, 2

		 
; 0xA1: WM_NCLBUTTONDOWN, refer to http://msdn.microsoft.com/en-us/library/ms645620%28v=vs.85%29.aspx
; 2: HTCAPTION (in a title bar), refer to http://msdn.microsoft.com/en-us/library/ms645618%28v=vs.85%29.aspx 
}

^+c:: ;When user press control, shift and c, copy selected text to a variable, preserving the current clipboard.
	SaveClipB := ClipboardAll
	Sleep, 100
	SendInput ^c
	Sleep, 100
	SecondClipBoard := Clipboard
	Sleep, 100
	Clipboard := SaveClipB
Return

^+v:: ;Control, shift and v pastes the secondary clipboard.
	SaveClipB := Clipboard
	Sleep, 100
	Clipboard := SecondClipBoard
	Sleep, 100
	SendInput ^v
	Sleep, 100
	Clipboard := SaveClipB
Return

;Magic Button to activate the Context Window commands
LControl & LWin::
	Gosub, %MagicButton%
Return

ITSDToolbarButton?:
	Run, "\\Work\Server\ITSD Scripts\AutoHotKey\Hotkeys Guide.pdf"
Return

ITSDToolbarButtonO:
	Gui, UtilOptions: Show, H245 W424, Util Options
	ControlFocus, UtilOptionsOKAY, UtilOptions
Return

ColorHex:
	Run http://www.color-hex.com/
Return

UtilOptionsButtonOK:
	Gui, UtilOptions: Submit
	Gosub, SaveCoords
	Sleep, 1000
	Reload
Return

UtilOptionsGuiEscape:
UtilOptionsButtonCancel:
	Gui, UtilOptions: Hide
Return

;Below is for Dev locations, when launding from Dev
#Include %A_ScriptDir%\Data\DropDownList\External\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Password Issues\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Windows\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Outlook\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\VPN and VIP\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Mobile Email\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\VMware\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\OneDrive\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Internet Explorer\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Web Conference\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Security\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\MFP\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\ADUC and LAN\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Hardware\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Current\Master\Master.txt
;For the Cherwell middle click menu:
#Include %A_ScriptDir%\Data\DropDownList\Passwords\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Support\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Quick Reference\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Access Requests\Master\Master.txt
#Include %A_ScriptDir%\Data\DropDownList\Installations\Master\Master.txt
;For the ContextTips popups
#Include %A_ScriptDir%\Data\ContextTips\Master\master.txt

NoteBox:
	If IncludeMB = 1
	{
		CurrentContextMessage = %MBText%
		Gosub, ContextWindowFiller
	}
	If IncludeTTip = 1
		TrayTip, ITSDUtil Notice, %MBText%, 20, 17
Return

OnSelectMCM10:
	StatType := "MiddleClick"
	GuiControlGet, MCMSelected, Focusv ;Gets the variable for the selected item
	Gui, MClickMenu: Submit
	If %MCMSelected% not in Passwords,Support,Quick Reference,Access Requests,Installations ;Checks to make sure the selection is not a header, if so it does nothing 
	{
		MCMnumber := RegExReplace(MCMSelected, "[^0-9]") ;Gets the number of which drop down you opened, to be used later
		GuiControl, Choose, ListMCM%MCMnumber%, 1	;Resets the dropdown back to the heading. only change the "List1" part to match which dropdown (not item)
		MCMSelectedName := ListMCM%MCMnumber% ;Gets the name of the option you selected
		MCMHeadingDD := MCMHeading[MCMNumber] ;Gets the name of which drop down your selection is under
		MCMListCombined := MCMHeadingDD MCMSelectedName
		CleanList := RegexReplace(MCMListCombined," ","")
		Gosub, %CleanList%
	}
Return

OnSelect10:
	StatType := "Toolbar"
	Gui, ITSDToolbar: Submit, nohide
	GuiControlGet, GetSelected, FocusV ;Gets the variable for the selected item
	If %GetSelected% not in External,Password Issues,Windows,Outlook,VPN and VIP,Mobile Email,VMware,OneDrive,Web Conference,Security,MFP,ADUC and LAN,Hardware,Current ;Checks to make sure the selection is not a header, if so it does nothing 
	{
		Lnumber := RegExReplace(GetSelected, "[^0-9]") ;Gets the number of which drop down you opened, to be used later
		GuiControl, Choose, List%Lnumber%, 1	;Resets the dropdown back to the heading. only change the "List1" part to match which dropdown (not item)
		DDSelectName := List%Lnumber% ;Gets the name of the option you selected
		DDLHeading := BarNames[LNumber] ;Gets the name of which drop down your selection is under
		ListCombined := DDLHeading DDSelectName
		CleanList := RegexReplace(ListCombined," ","")
		Gosub, %CleanList%
	}
Return

ITSDToolbarButtonExit:
ITSDToolbarGuiClose:
	Gosub, SaveCoords	
ExitApp

TicketFiller:
	ControlGetFocus, DescFieldName, Cherwell Service Management
	Gosub, KCSQuickSearch
	ControlFocus, %DescFieldName%, Cherwell Service Management
	SendInput %DescText%
	Sleep, 1000
	SendInput {TAB}
	Sleep, 500
	SendInput %DescText%
	Sleep, 1000
	SendInput {enter}
	Sleep, 100
	SendInput {TAB}
	Sleep, 500
	SendInput %ClassText%
	Sleep, 500
	SendInput {enter} ;will bring up the list of classifications
Return

;Click button in middle click menu or press ctrl shift P to uncheck Cherwell's search options and leave just Search Service Desk KCS.
Unchecker:
	SetControlDelay -1
	ControlClick, Search Open Incidents, Cherwell Service Management 
	ControlClick, Search Known Errors, Cherwell Service Management 
	ControlClick, Search All KCS Articles, Cherwell Service Management 
	ControlClick, Search ROC KCS Articles, Cherwell Service Management 
	WinActivate, UtilMClickMenu ;The controlclicks happen so fast, Windows doesn't recognize that the middle click menu was ever active and AHK closes it as if it never became active.
Return

;Press Windows Key, Shift 0 (zero above the letter P on the keyboard) to find missing gui.
#+0::
	SetTitleMatchMode, 2
	WinMove, ITSDUtil,, 0, 0
	WinMove, ITSDMarquee,, 0, 50
	WinMove, ContextTips,, 0, 100
Return

CoordGetControl(xCoord, yCoord, _hWin) ; _hWin should be the ID of the active window
{
	CtrlArray := Object() 
	WinGet, ControlList, ControlList, ahk_id %_hWin%
	Loop, Parse, ControlList, `n
	{
		Control := A_LoopField
		ControlGetPos, left, top, right, bottom, %Control%, ahk_id %_hWin%
      right += left, bottom += top
		If (xCoord >= left && xCoord <= right && yCoord >= top && yCoord <= bottom)
			MatchList .= Control "|"
	}
	StringTrimRight, MatchList, MatchList, 1
	Loop, Parse, MatchList, |
	{
		ControlGetPos,,, w, h, %A_LoopField%, ahk_id %_hWin%
		Area := w * h
		CtrlArray[Area] := A_LoopField
	}
	For Area, Ctrl in CtrlArray
	{
		Control := Ctrl
		If (A_Index = 1)
			Break
	}
	Return Control
}

;various ways to hide the middle click menu
MClickMenuButtonX:
MClickMenuGuiClose:
MClickMenuGuiEscape:
	Gui MClickMenu: Hide
Return

KCSBlueGuiButtonOK:
	Gui KCSBlueGui: Submit
	SendInput See linked KCS article %KCSNumBlue%
	SendInput ^+{Left}
	SendInput {Ctrl Down}d{Ctrl Up}
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput bold
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	Sleep, 100
	SendInput {Tab}{Tab}{Tab}
	Sleep, 100
	SendInput {PgUp}
	Sleep, 300
	SendInput b
	Sleep, 100
	SendInput {Enter}
	Sleep, 100
	SendInput {Right}
	SendInput .
	SendInput ^{Left}
	SendInput {Ctrl Down}d{Ctrl Up}
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	Sleep, 100
	SendInput {Tab}{Tab}{Tab}
	Sleep, 100
	SendInput {PgUp}
	Sleep, 100
	SendInput {Enter}
	SendInput {Right}
	SendInput {Enter}
	Gui KCSBlueGui: Destroy
Return

KCSBlueGuiButtonCancel:
	Gui KCSBlueGui: Destroy
Return

MarqSize:
	If (MarqueeFullSize = true)
	{
		Gui, MagWinMarq: Show, h18
		MarqueeFullSize := false
	}
	Else
	{
		Gui, MagWinMarq: Show, h270
		MarqueeFullSize := true
	}
Return

UpdateMessages:
	TotalMarq = 0
	FileList := ""
	Loop, Files, %MessagesDir%\*.txt
	{
		FileList = %FileList%%A_LoopFileTimeModified%`t%A_LoopFileName%`n
	}
	Sort, FileList, R
	Loop, Parse, FileList, `n
	{
		If (A_LoopField = "")
			Continue
		StringSplit, FileItem, A_LoopField, %A_Tab%
		FileRead, MWMessage%A_Index%, %MessagesDir%\%FileItem2%
		MWMessagePath%A_Index% = %MessagesDir%\%FileItem2%
		MWMTitle%A_Index% = %FileItem2%
		TotalMarq := TotalMarq+1
		FormatTime, ModDateTime, %FileItem1%, M/d/yy h:mmtt
		MWMDate%A_Index% := ModDateTime
	}
Return

AddMarquee:
	EditSwitch := false
	Gui, AddMarqWin: Destroy
	Gui, AddMarqWin: Add, Text,, Title:
	Gui, AddMarqWin: Add, Edit, Limit30 w200 vAddTitleEdit gMagCharCheck
	Gui, AddMarqWin: Add, Text,, Message:
	Gui, AddMarqWin: Add, Edit, Limit350 w300 h130 vAddMsgEdit
	Gui, AddMarqWin: Add, Button, Default gAddSaveB, Save
	Gui, AddMarqWin: Add, Button, gAddCancel, Cancel
	Gui AddMarqWin: +AlwaysOnTop
	Gui, AddMarqWin: Show,, Create a new marquee message:
Return

EditMarquee:
	SetTimer, NextMarquee, Off
	EditSwitch := true ;Currently editing a message
	Gui, AddMarqWin: Destroy
	Gui, AddMarqWin: Add, Text,, Title:
	Gui, AddMarqWin: Add, Edit, Limit30 w200 vAddTitleEdit gMagCharCheck, %CurrentTitle%
	Gui, AddMarqWin: Add, Text,, Message:
	Gui, AddMarqWin: Add, Edit, Limit350 w300 h130 vAddMsgEdit, %CurrentMessage%
	Gui, AddMarqWin: Add, Button, Default gAddSaveB, Save
	Gui, AddMarqWin: Add, Button, gAddCancel, Cancel
	Gui AddMarqWin: +AlwaysOnTop
	Gui, AddMarqWin: Show,, Create a new marquee message:
Return

MagCharCheck:
	Gui +LastFound
	Gui, Submit, NoHide
	If AddTitleEdit Contains /,\,:,*,?,",<,>,|,& ;"
	{
		SendInput, {BackSpace}
		Goto, MagCharCheck
	}
Return

AddSaveB:
	If (EditSwitch = true) ;currently editing a message (as opposed to creating a new one)
	{
		CurrentPath := MWMessagePath%CurrentMarq%
		FileDelete, %CurrentPath%
	}
	Gui, AddMarqWin: Submit
	FileDelete, %MessagesDir%\%AddTitleEdit%.txt
	FileAppend, %AddMsgEdit%, %MessagesDir%\%AddTitleEdit%.txt
	Gui, AddMarqWin: Destroy
	SetTimer, NextMarquee, % ((PlayMarquee = true) ? "On" : "Off")
	FileAppend, Updated %A_Now% `n, %A_ScriptDir%\Data\NewMsgTrigger.txt
Return

AddCancel:
	EditSwitch := false
	SetTimer, NextMarquee, % ((PlayMarquee = true) ? "On" : "Off")
	Gui, AddMarqWin: Destroy
Return

DelMarquee:
	SetTimer, NextMarquee, Off
	If (TotalMarq = 1)
	{
		MsgBox, 4096, Error, Cannot delete last message! Please create a new message before deleting this one.
		Return
	}
	MsgBox, 262148, Permanently Delete, Are you sure you want to delete this message?
	IfMsgBox Yes
	{
		CurrentPath := MWMessagePath%CurrentMarq%
		FileDelete, %CurrentPath%
		GuiControl MagWinMarq: , MagMsgTxt, Deleted ;Display the word "Deleted" on the window
	}
	Sleep, 2000
	Gosub, NextMarqueeNow
Return

NextMarquee:
	If (TotalMarq >1)
	{
		SetTimer, NextMarquee, % ((PlayMarquee = true) ? "On" : "Off")
		CurrentMarq := CurrentMarq + 1
		If (CurrentMarq > TotalMarq)
		{
			CurrentMessage := MWMessage1
			CurrentTitle := MWMTitle1
			CurrentMarq := 1
			CurrentDate := MWMDate1
		}
		Else
		{
			CurrentMessage := MWMessage%CurrentMarq%
			CurrentTitle := MWMTitle%CurrentMarq%
			CurrentDate := MWMDate%CurrentMarq%
		}
 		GuiControl MagWinMarq: ,MagMsgTxt, %CurrentMessage%
 		GuiControl MagWinMarq: ,MagMsgDt, %CurrentDate%
 		StringTrimRight, CurrentTitle, CurrentTitle, 4
 		GuiControl MagWinMarq: ,MagMsgTtl, %CurrentTitle%
	}
Else If (TotalMarq = 1)
	{
		CurrentMessage := MWMessage1
		CurrentTitle := MWMTitle1
		CurrentMarq := 1
		CurrentDate := MWMDate1
		GuiControl MagWinMarq: ,MagMsgTxt, %CurrentMessage%
 		GuiControl MagWinMarq: ,MagMsgDt, %CurrentDate%
 		StringTrimRight, CurrentTitle, CurrentTitle, 4
 		GuiControl MagWinMarq: ,MagMsgTtl, %CurrentTitle%
	}
Return

NextMarqueeNow:
	SetTimer, NextMarquee, % ((PlayMarquee = true) ? "On" : "Off")
	CurrentMarq := CurrentMarq + 1
	If (CurrentMarq > TotalMarq)
	{
		CurrentMessage := MWMessage1
		CurrentTitle := MWMTitle1
		CurrentMarq := 1
		CurrentDate := MWMDate1
	}
	Else
	{
		CurrentMessage := MWMessage%CurrentMarq%
		CurrentTitle := MWMTitle%CurrentMarq%
		CurrentDate := MWMDate%CurrentMarq%
	}
 	GuiControl MagWinMarq: ,MagMsgTxt, %CurrentMessage%
 	GuiControl MagWinMarq: ,MagMsgDt, %CurrentDate%
 	StringTrimRight, CurrentTitle, CurrentTitle, 4
 	GuiControl MagWinMarq: ,MagMsgTtl, %CurrentTitle%
Return

PrevMarquee:
	SetTimer, NextMarquee, % ((PlayMarquee = true) ? "On" : "Off")
	CurrentMarq := CurrentMarq - 1
	If (CurrentMarq < 1)
	{
		CurrentMessage := MWMessage%TotalMarq%
		CurrentTitle := MWMTitle%TotalMarq%
		CurrentMarq := TotalMarq
		CurrentDate := MWMDate%TotalMarq%
	}
	Else
	{
		CurrentMessage := MWMessage%CurrentMarq%
		CurrentTitle := MWMTitle%CurrentMarq%
		CurrentDate := MWMDate%CurrentMarq%
	}
  GuiControl MagWinMarq: ,MagMsgTxt, %CurrentMessage%
  GuiControl MagWinMarq: ,MagMstDt, %CurrentDate%
  StringTrimRight, CurrentTitle, CurrentTitle, 4
  GuiControl MagWinMarq: ,MagMsgTtl, %CurrentTitle%
Return

PauseMarquee:
	If (PlayMarquee = true)
	{
		PlayMarquee := false
		SetTimer, NextMarquee, Off
		GuiControl MagWinMarq: ,PauseM, Play
	}
	Else
	{
		PlayMarquee := true
		SetTimer, NextMarquee, On
		GuiControl MagWinMarq: ,PauseM, Pause
	}
Return

NewMsgAlert:
	IfWinActive, ITSDMarquee
	{
		If (MarqNeedAttn = true)
		{
			MarqNeedAttn := false
			Gui, MagWinMarq: Color, %MagicMarqueeColor%
			Gui, MagWinMarq: Font, c%MagicMarqueeFontColor% s9 underline, Verdana
			GuiControl MagWinMarq: Font, MagMsgTtl
			Gui, MagWinMarq: Font, c%MagicMarqueeFontColor% s9 norm, Verdana
			GuiControl MagWinMarq: Font, MagMsgTxt
			Gui, MagWinMarq: Font, c%MagicMarqueeFontColor% s9 norm, Verdana
			GuiControl MagWinMarq: Font, MagMsgDt
			GuiControl MagWinMarq: Font, LastModifiedTxt
			SetTimer, NextMarquee, % ((PlayMarquee = true) ? "On" : "Off")
			If (UtilMarqAlwaysOnTop = false)
				Gui, MagWinMarq: -AlwaysOnTop
		}
	}
	IfExist, %A_ScriptDir%\Data\NewMsgTrigger.txt
	{
		FileGetTime, ModNewMsg2, %A_ScriptDir%\Data\NewMsgTrigger.txt, M
		If (ModNewMsg2 != ModNewMsg)
		{
			FileGetTime, ModNewMsg, %A_ScriptDir%\Data\NewMsgTrigger.txt, M
			Gosub, UpdateMessages
			Gui, MagWinMarq: Color, f9ff00
			Gui, MagWinMarq: Flash
			Gui, MagWinMarq: Show, h270 NA
			CurrentMessage = %MWMessage1%
			CurrentDate := MWMDate1
			CurrentTitle := MWMTitle1
			CurrentMarq := 1
			GuiControl MagWinMarq: ,MagMsgTxt, %CurrentMessage%
			GuiControl MagWinMarq: ,MagMsgDt, %CurrentDate%
 			StringTrimRight, CurrentTitle, CurrentTitle, 4
 			GuiControl MagWinMarq: ,MagMsgTtl, %CurrentTitle%
			MarqueeFullSize := true
			SetTimer, NextMarquee, Off
			Gui, MagWinMarq: +AlwaysOnTop
			Gui, MagWinMarq: Font, cBlack s9 underline, Verdana
			GuiControl MagWinMarq: Font, MagMsgTtl
			Gui, MagWinMarq: Font, cBlack s9 norm, Verdana
			GuiControl MagWinMarq: Font, MagMsgTxt
			Gui, MagWinMarq: Font, cBlack s9 norm, Verdana
			GuiControl MagWinMarq: Font, MagMsgDt
			GuiControl MagWinMarq: Font, LastModifiedTxt
			MarqNeedAttn := true
		}
	}
	Else
	{
		MsgBox, 0, Error, ITSDUtil has lost connection to the LAN and has stopped updating. Please re-launch.
		SetTimer, CheckTime, OFF
	}
Return
;----------------------------------------------------------------------


ContextTipClick:
	Gui, MagWinCont: Show, NA, ContextTips ;Changes the word/link that shows in the AIOCenter. The word should say what the current magic button is related to and what info you will get upon clicking.
	GuiControl, MagWinCont: , MagContTxt, %CurrentContextMessage% ;Changes the information in the ContextTips window on click.
Return

ContextWindowFiller:
	TwoWeeksAgo := ""
	HSContextTitle := MagicButton ;Grabbing the label for the context title from the magic button
	MBCheck := SubStr(HSContextTitle, 1, 3) ;Check to see if HSContextTitle starts with the letters MB	
	If (MBCheck == "MB1")
	{
		Replace := ["MB1Passwords","MB1Support","MB1QuickReference","MB1AccessRequests","MB1Installations"] ;create an array of phrases that we want to erase from the title
		For Index, Element in Replace ;for each of the items in the array above do the following
			HSContextTitle := StrReplace(HSContextTitle, Element) ;Replace any of the items from the array above with blank
	}			
	Else
		HSContextTitle := StrReplace(MagicButton,"MB") ;If HSContextTitle starts with MB, replace MB with blank
	OldCTTitle := ContextTipTitle ;Save current context tip link name as the old name before giving a new name
	;Borrowing the stattype to tell which source the command came from so that the proper context tip link name will display since they all use different variables.
	If (StatType == "HotString")
		ContextTipTitle := HSContextTitle
	Else If (StatType == "MiddleClick")
		ContextTipTitle := MCMSelectedName
	Else If (StatType == "Toolbar")
		ContextTipTitle := DDSelectName
	FileGetTime, ContextTipModDate, %A_ScriptDir%\Data\ContextTips\%ContextTipTitle%.txt, M
	TwoWeeksAgo += -14, Days
	NewFlag := (ContextTipModDate > TwoWeeksAgo) ? "*New* " : ""
	FormatTime, ContextTipModDate, %ContextTipModDate%, M-d-yy
	GuiControl, AIOCenter: , ContextTipLink,  %NewFlag%%ContextTipTitle% (%ContextTipModDate%)
	If (OldCTTitle != ContextTipTitle) ;If you type "outlook" (for example) and then type it again, it will only flash the first time.
	{
		Gui AIOCenter: Color, c%OppColor% ;OppColor is set up elsewhere and is the opposite of the color chosen for the AIOCenter.
		SetTimer, FlashBack, -2000 ;After 2 seconds, revert the color oc the AIOCenter back to the user's choice.
	}
Return

FlashBack:
	Gui AIOCenter: Color, %AIOColorChoice%
Return

Dismiss: ;Button to Keep or Dismiss the ContextTips window. Button changes from Keep to Dismiss and back on clicking.
	WinGetPos, CurrentContX, CurrentContY, ,, ContextTips
	Gui, MagWinCont: Hide
Return

ClearMagCont:
	TrayTip, ITSDUtil Notice, There is no ContextTip action available yet because no keyword has been typed in., 20, 17
Return

;----------------------------------------------------------------------

~MButton::
	CoordMode, Mouse, Screen
	MouseGetPos, MseX, MseY, MClickID, MClickControl
	MouseGetPos,,, WinUMID
	WinGetTitle, MClickTitle, ahk_id %MClickID%
	WinActivate, ahk_id %MClickID%
	MCMNeedle := "Cherwell Service Management "
	If InStr(MClickTitle, MCMNeedle)
	{
		MseX := MseX-165
		MseY := MseY-70
		Gui MClickMenu: Show, NA x%MseX% y%MseY%, UtilMClickMenu
		WinWaitActive, UtilMClickMenu, , 3
		If ErrorLevel
	  	Gui MClickMenu: Hide
	}
	Sleep 100
Return

;The following only activates if Cherwell has focus. Shortcuts will still work in other applications.
#IfWinActive ahk_exe Trebuchet.App.exe

;---------------------------------------------------------------------------

^+x:: ;when control, shift and x are pressed together, do the following:
	FocusJump(6, 34, "*Requestor:", "Cherwell Service Management") ;uses focusjump to find the users id
	SendInput ^a
	SendInput ^c
	Sleep 100
	CherwellUserName := RegexReplace(Clipboard,".*\((.+?)\).*","$1") ;assigns only what is found between parenthesis to a variable
	Clipboard := CherwellUserName ;copies that variable to the clipboard
Return

::escep::
::escpe::
	FoundPandE := [] ;Creats a blank array for user later
	WinGet, OutlputVARR, controlList, A ;Gets all ControlLists on the active winow
	Loop, Parse, OutlputVARR, `n ;Parses throught all ConrolLists
	{
		ControlGetText, Haystack, %A_LoopField%, A
		EmailPosFound := RegExMatch(Haystack,"i)[a-z0-9_-]*\.?[a-z0-9_-]+@[a-z0-9_-]+\.+[a-z]{2,4}") ;Looks at current ControlList to see if it fits email criteria, and returns starting position if found
		PhonePosFound := RegExMatch(Haystack,"i)^[0-9]{3}\.[0-9]{4}$") ;Looks at current ControlList to see if it fits phone criteria, and returns starting position if found
		ControlGetPos, EaPX, EaPY, EaPW, EaPH, %A_LoopField%, A ;Gets the coordinates of the current control
		If (PhonePosFound = 1 && EaPY < 450) ;If a phone number is found at the first postion and above the 450 Y coord then it gets the phone number and adds it to the array
		{
			ControlGetText, PhoneNumber, %A_LoopField%, A
			FoundPandE.Push("Phone: "PhoneNumber)
		}
		If (EmailPosFound = 1 && EaPY < 450) ;If an email number is found at the first postion and above the 450 Y coord then it gets the email and adds it to the array
		{
			ControlGetText, UserEmail, %A_LoopField%, A
			UserEmail := Trim(UserEmail)
			FoundPandE.Push("Email: "UserEmail)
		}
	}	
	If (FoundPandE.MaxIndex() > 2) ;If more than 2 elements in the array it will only print the 3rd and 4th, if 4th is blank then the line is empty
	{
		SendInput % FoundPandE[3]
		SendInput {Return}
		SendInput % FoundPandE[4]
		SendInput {Return} 
	}
	Else ;If only 2 elements then it prints the first 2
	{
		SendInput % FoundPandE[1]
		SendInput {Return}
		SendInput % FoundPandE[2]
		SendInput {Return}
	}
Return

^+u::
	Gosub, ^+j
	Gosub, SearchID
Return
 
^+j:: ;hot key to grab the username from cherwell and put it into the gui
	CBbeforecompfind := ClipboardAll
	Gosub, ^+x
	If (Clipboard = "") ;if the clipboard is blank makes the username "User name here"
		NameDisplayString := "Enter Name"
	Else ;if not blank removes all new line and trims the display name to upto the first 20 characters of what was found, useful incase activated in another window or something wrong was copied
	{
		NoTabsString := StrReplace(CherwellUserName, "`n")
		NameDisplayString := SubStr(NoTabsString, 1, 20)
	}
	Clipboard := CBbeforecompfind ;puts the clipboard back to before the username was copied 
	CBbeforecompfind := ;empties the variable invase the clipboard was large
	WinGet, ControlShiftV, ID, A ;gets the id of the cherwell window so it can paste back into it later
	WinActivate, AIOCenter ;activates the AIOcenter, so you can hit enter after the username is inputted
	Sleep 150
	GuiControl, AIOCenter:, AccountToGetInfo, %NameDisplayString% ;inputs the username it pulled from cherwell into the window
	ControlFocus, Edit1, AIOCenter ;makes the username field the one with focus
Return 

^+q:: 
	FocusJump(3, 24, "*Short Description:", "Cherwell Service Management")
	Preminifillout := ClipboardAll ;Makes current clipboard var Preminifillout
	Sleep 333
	Clipboard :=  ""
	Sleep 200
	SendInput ^a ;Selects everything
	Sleep 100
	SendInput ^c ;Copies what it selects
	Sleep 333
	If (Clipboard = "") ;If you press the hot keys when no words are present it will paste what is on the clipboard
	{
		Clipboard := Preminifillout
		Sleep 333
		SendInput ^v
		Sleep 100
		SendInput ^a 
		Sleep 100
		SendInput ^c
	}
	Sleep 200
	SendInput {TAB} ;Tabs to description
	Sleep 200
	SendInput ^v ;Pastes what it copied from above
	Sleep 200
	SendInput {enter} ;Hits return incase you already had some info there
	Sleep 200
	SendInput {TAB} ;Tabs to classify field
	Loop, Parse, Clipboard, - ;Parses through what is currently on the clip board stopping at, and not including, the dash(-), and then sends the first part to the clipboard
	{
		Classification := A_LoopField
		Sleep 200
		Break
	}
	ClassificationFill(Classification)
	Clipboard := Preminifillout ;Puts what you had on the clipboard before it started back on to the clipboard
	Sleep 333
	Preminifillout := "" ;Free the memory in case the clipboard was very large
	Classification := "" ;Free the memory in case the variable was very large
Return

^+p::
	ControlGetFocus, DescFieldName, Cherwell Service Management
	SetControlDelay -1
	ControlClick, Search Open Incidents, Cherwell Service Management 
	ControlClick, Search Known Errors, Cherwell Service Management 
	ControlClick, Search All KCS Articles, Cherwell Service Management 
	ControlClick, Search ROC KCS Articles, Cherwell Service Management 
	WinActivate, UtilMClickMenu ;The controlclicks happen so fast, Windows doesn't recognize that the middle click menu was ever active and AHK closes it as if it never became active.
	Sleep, 100
	ControlFocus, %DescFieldName%, Cherwell Service Management
Return

KCSQuickSearch:
	CoordMode, Pixel, Window
	ImageSearch, , , 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, %A_ScriptDir%\Data\ImgSrchSrce\CheckedBox.png
	If(ErrorLevel == 0)
		Gosub, Unchecker
	SendInput ^+k
	Sleep, 500
	SendInput ^a
	Sleep, 500
	SendInput %SearchText%
	Sleep, 200
	SendInput {enter}
Return

^Enter::
	ControlClick, Next: Close this Record, Cherwell Service Management 
Return

^+1::
	SendInput {Ctrl Down}d{Ctrl Up}
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput bold
	SendInput {Tab}
	Sleep, 100
	SendInput 12
	SendInput {Enter}
	Sleep, 100
	SendInput ITSD Section:
	SendInput {Enter}
	Sleep, 100
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
	Sleep, 100
	SendInput {Enter}{Enter}{Enter}
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput bold
	SendInput {Tab}
	Sleep, 100
	SendInput 12
	SendInput {Enter}
	Sleep 100
	SendInput Non-ITSD Section:
	SendInput {Enter}
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
	Sleep, 200
	SendInput NA
Return

^+2::
	SendInput ^d
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
Return
	
^+3::
	Gui KCSBlueGui: Add, Text,, Enter KCS Number:
	Gui KCSBlueGui: Add, Edit, vKCSNumBlue
	Gui KCSBlueGui: Add, Button, Default, OK
	Gui KCSBlueGui: Add, Button, , Cancel
	Gui KCSBlueGui: Show,, Link KCS
Return

#Include %A_ScriptDir%\Data\Includes\Phrases\Resolution.txt
#Include %A_ScriptDir%\Data\Includes\Phrases\Escalating.txt

::kcst::
	SendInput KCS Management
	SendInput {Enter}
Return

::itsdt::
	SendInput IT Service Desk
	SendInput {Enter}
Return

^+!m::
	ClickJump(3, 54, "Owned By:", "Cherwell Service Management")
	WinWaitActive, Prompt, , 1
	If ErrorLevel
		Return
	SendInput KCS Management
	SendInput	{Enter}
	Sleep, 500
	ClickJump(3, 30, "Owned By:", "Cherwell Service Management")
	WinWaitActive, Prompt, , 1
	If ErrorLevel
		Return
	UserNameConvert := %A_UserName%	
	SendInput %UserNameConvert%
	SendInput {Enter}
Return

#IfWinActive

SearchID:
	SearchingDomain := "Work.com"
	Gosub, SuperSearch
Return
		
WorkDev:
	SearchingDomain := "WorkDev.com"
	Gosub, SuperSearch
Return

WorkDemo:
	SearchingDomain := "WorkDemo.com"
	Gosub, SuperSearch
Return

SuperSearch:
	Gui, AIOCenter: Submit, NoHide ;gets submitted user ID from gui
	If (AccountToGetInfo = "")
		Return 
	StatType := "AIOSearch" ;Names the header that will appear the stats output for when a user is searched
	DescText := "Searched User" ;Names the value that will appear the stats output for when a user is searched
	Gosub, StatGrabber2 ;Runs the subroutine that increases the count of number of searched users
	GuiControl, AIOCenter:Text, OtherDomain, Domain: %SearchingDomain% ;displays domain as Work
	GuiControl, AIOCenter:, UpdateInfo, Status Bar Information ;resets the status bar information, incase other buttons were hit
	GuiControl, AIOCenter:, ProgressBarPercent, Progress Bar Info ; resets the progress bar information, incase other buttons were hit
	GuiControl, AIOCenter:, AgeOfPassword, Loading...
	GuiControl, AIOCenter:, RandomGenPword, ;Makes the dipslayed password blank
	GuiControl, AIOCenter:, PersonComputers, For %AccountToGetInfo%`:
	GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOWorking.png ;sets status pic as working, stays until PS script is ran, then it changes
	RealUser := true ;defaults real user to true, changes of false
	NotFoundJump := true ;defaults found computers to true, if none found it changes 
	FoundMachines := [] ; blank array to store all found machine for user
	Count := 0 ;count of found user manchines, starts at 0
	If (SearchingDomain = "Work.com")
	{
		Loop, Read, \\Work\Server\ITSD Scripts\AutoHotKey\Data\Z All Combined Users and Computers.txt ;loops text file of all machines looking for username that was inputted
		{
			Loop, Parse, A_LoopReadLine, `n
			{
				UserComputer := InStr(A_LoopReadLine, AccountToGetInfo, CaseSensitive := false, StartingPos := 1, Occurrence := 1)
				If (UserComputer = 1) ;if username is found parses string to only incude computer, incrases computer count
				{
					Loop, Parse, A_LoopReadLine, `,
					{
						If (A_Index = 2)
						{
							Count++
							FoundMachines.Push(A_LoopField)
						}	
					}	
				}
			}
		}
		StringOptions := ;blank string useed to display all the users computer in the gui
		TotalComputersFound := FoundMachines.MaxIndex() ;counts how many machines were found for the user
		If (Count = 0) ;if no machines were found a message box appears saying so
		{
			StringOptions := "No||Computers|Found|For|User" ;if not computers found makes the computer box dispaly that 
			NotFoundJump := false ;sets this to false, used later so can remote, copy, etc unfound computers 
		}
		Loop %TotalComputersFound%
		{
			If (A_Index = 1) ;makes first one the defaul option
				StringOptions := StringOptions . FoundMachines[A_Index] . "||"
			Else If (A_Index != TotalComputersFound)
				StringOptions := StringOptions . FoundMachines[A_Index] . "|"
			Else If (A_Index = TotalComputersFound)
				StringOptions := StringOptions . FoundMachines[A_Index]
		}	
	} 
	Else 
	{
		NotFoundJump := false
		StringOptions := "Not||Searching|Computers|On|"SearchingDomain
	}
	GuiControl, AIOCenter:, ComputerSelection, |%StringOptions% ;displays the found comptuers
	GuiControl, AIOCenter:Focus, ComputerSelection ;makes the top comptuer the default selection
	If (NotFoundJump = false) ;if not comptuer found jump back up to username field 
		ControlFocus, Edit1, AIOCenter
	If (SearchingDomain != "Work.com")
		Gosub, SpecialDomainLookUp ;if the domain is not Work goes to sub routine to find if multiple accounts 
	Else 
		Gosub, LookingForSomethingMore ;if Work continues like normal, searching only on the one account 
Return	

SpecialDomainLookUp:
	MultipleUsers := true
	DetectHiddenWindows, On
	TotalFoundUsers := "" ;creates blank var for the total found users 
	FindMDScript := ".\PSAcctFindMD.ps1 -AccountName " AccountToGetInfo " -SearchDomain " SearchingDomain " -credential $cr" ;PS command to see if multiple users 
	FindMDScript := Format("{:Ls}", FindMDScript) ;converts string to lower case so shift is not needed in PS. Probably reduces chance of error??
	ControlSendRaw, ,%FindMDScript%, ahk_pid %PSOutVar% ;sends command to PS window and hits enter
	ControlSend,,{Enter}, ahk_pid %PSOutVar%
	Sleep 100
	FileGetTime, CMDDSQRModifyTime, C:\AHKLocal\CMDDSQR.txt, M
	EnvSub, CMDDSQRModifyTime, %A_Now%, Seconds
	DetectHiddenWindows, Off
	While !(3 > Abs(CMDDSQRModifyTime) > 0) 
	{
		Sleep 50
		FileGetTime, CMDDSQRModifyTime, C:\AHKLocal\CMDDSQR.txt, M
		EnvSub, CMDDSQRModifyTime, %A_Now%, Seconds
	}
	While ! Instr(TotalFoundUsers,"Done") ;while not done, keep reading file until Done is read
	{
		FileRead, TotalFoundUsers, C:\AHKLocal\CMDDSQR.txt
		If Instr(TotalFoundUsers,"NoneFound") ;if account not found returns absent and changes dispaly info to reflect that
		{
			GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIONotFound2.png
			GuiControl, AIOCenter:, UpdateInfo, The Account Was Not Found
			GuiControl, AIOCenter:, AgeOfPassword, Invalid
			RealUser := false 
			MultipleUsers := false
			Break
		}
		Else If Instr(TotalFoundUsers,"OnlyContinue") ;if only one account is found, reads found name and auto runs on it, else prompts for selection 
		{
			FileReadLine, AccountToGetInfo, C:\AHKLocal\CMDDSQR.txt, 1 ;reads name printed on line 1. Reads name incase you search on UserID and the only found account is UserID-Test01
			GuiControl, AIOCenter:, AccountToGetInfo, %AccountToGetInfo%
			GuiControl, AIOCenter:, PersonComputers, For %AccountToGetInfo%`:
			Gosub, SomethingMoreAfterCtrlSend
			MultipleUsers := false
			Break
		}
		Sleep 50 
	}
	If (MultipleUsers = true) 
	{
		AllFoundCMDU := [] ;creats blank array for found user IDs
		Loop, Read, C:\AHKLocal\CMDDSQR.txt ;loops text file of all found userIDs and creats array
		{
			Loop, Parse, A_LoopReadLine, `n
			{
				FoundCMDUser := InStr(A_LoopReadLine, AccountToGetInfo, CaseSensitive := false, StartingPos := 1, Occurrence := 1) ;reads file and gets username similar to what was searched
				If (FoundCMDUser = 2) ;if username is found starting at the second position, then trims and adds to array
				{
					UserPush := SubStr(A_LoopReadLine, 2, -1) ;if username is found parses string to remove quotes, and addes to array
					AllFoundCMDU.Push(UserPush) ;adds trimmed username to array 
				}
			}
		}
		CMDUserShow := ""
		AllFoundCMDUCount := AllFoundCMDU.MaxIndex() ;gets the total user names found 
		Loop %AllFoundCMDUCount%
		{
			If (A_Index = 1) ;makes first one the defaul option
				CMDUserShow := CMDUserShow . AllFoundCMDU[A_Index] . "||"
			Else If (A_Index != AllFoundCMDUCount)
				CMDUserShow := CMDUserShow . AllFoundCMDU[A_Index] . "|"
			Else If (A_Index = AllFoundCMDUCount)
				CMDUserShow := CMDUserShow . AllFoundCMDU[A_Index]
		}
		WinGetPos, CMDX, CDMY, CMDWidth, CMDHeight, AIOCenter ;finds position of AIO on screen
		CMDcompX := (CMDX + Ceil(CMDWidth / 2)) -75 ;finds the center adjusting for gui size
		CMDcompY := (CDMY + Ceil(CMDHeight / 2)) -55 ;finds the center adjusting for gui size	
		Gui, CMMDChoose: Font, c%AIOFontColorChoice%
		Gui, CMMDChoose: Add, Text, Center x10 y5 w130, Multiple Accounts Found:`nPlease Select One ;Text asking user to input a username
		Gui, CMMDChoose: Add, Button, x90 y85 w50 Default gCMMDSelect, Select ;change button, default button
		Gui, CMMDChoose: Add, Button, x10 y85 w50 gCancelCMMD, Cancel ;gui cancel button
		Gui, CMMDChoose: Font, cBlack
		Gui, CMMDChoose: Add, ListBox, R3 x10 y37 w130 vCMMDUserID gCMMDUserSelect, %CMDUserShow%
		Gui, CMMDChoose: -Border +AlwaysOnTop +ToolWindow ;+ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, CMMDChoose: Color, %UpShdColor% ;%PwordColor% same color as toobar, color choosen by user
		Gui, CMMDChoose: Show, x%CMDcompX% y%CMDcompY% W150 H110 ;Centers gui for current active window
	}
Return

CMMDUserSelect:
	If A_GuiControlEvent <> DoubleClick ;if event is not a double click then do nothing
		Return
	Gosub, CMMDSelect ;go sub to run on selected user ID
Return

CMMDSelect:	;gets selected user ID and updates display info
	Gui, CMMDChoose: Submit 
	Gui, CMMDChoose: Destroy
	GuiControl, AIOCenter:, AccountToGetInfo, %CMMDUserID%
	GuiControl, AIOCenter:, PersonComputers, For %CMMDUserID%`:
	AccountToGetInfo := CMMDUserID
	Gosub, LookingForSomethingMore
Return

LookingForSomethingMore: 
	DetectHiddenWindows, On
	ValidAccountScript := ".\PSAcctValidation.ps1 -AccountName " AccountToGetInfo " -SearchDomain " SearchingDomain " -credential $cr"
	ValidAccountScript := Format("{:Ls}", ValidAccountScript) ;converts string to lower case so shift is not needed in PS. 
	ControlSendRaw, ,%ValidAccountScript%, ahk_pid %PSOutVar% ;sends PS command to window and hits enter to run it
	ControlSend,,{Enter}, ahk_pid %PSOutVar%
	DetectHiddenWindows, Off
	Gosub, SomethingMoreAfterCtrlSend
Return 
	
SomethingMoreAfterCtrlSend: 
	ValidLockStatus := ""
	FileGetTime, AccountStatUnlModifyTime, C:\AHKLocal\AccountStatUnl.txt, M
	EnvSub, AccountStatUnlModifyTime, %A_Now%, seconds 
	While !(3 > Abs(AccountStatUnlModifyTime) > 0)
	{ 
		Sleep 50
		FileGetTime, AccountStatUnlModifyTime, C:\AHKLocal\AccountStatUnl.txt, M
		EnvSub, AccountStatUnlModifyTime, %A_Now%, seconds
	}
	PwordDisplayed := false
	PasswordAge :=
	While ! Instr(ValidLockStatus,"Done") ;While done is not present, keeps reading file
	{
		FileRead, ValidLockStatus, C:\AHKLocal\AccountStatUnl.txt
		If Instr(ValidLockStatus,"Absent") ;if account not found returns absent and changes dispaly info to reflect that
		{
			GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIONotFound2.png
			GuiControl, AIOCenter:, UpdateInfo, The Account Was Not Found
			GuiControl, AIOCenter:, AgeOfPassword, Invalid
			RealUser := false
			Break
		}
		Else If Instr(ValidLockStatus,"Disabled") ;if account is disabled returns disabled and changes dispaly info to reflect that
		{
			GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIODisabled.png
			GuiControl, AIOCenter:, UpdateInfo, This Account Is Currently Disabled
			GuiControl, AIOCenter:, AgeOfPassword, Disabled
			RealUser := false
			Break
		}
		If (PwordDisplayed = false)
			FileReadLine, PasswordAge, C:\AHKLocal\AccountStatUnl.txt, 3 ;reads line 3 to get current password age 
			If (PasswordAge != "" && PwordDisplayed = false) 
			{
				GuiControl, AIOCenter:, AgeOfPassword, %PasswordAge% ;displays age of password
				PwordDisplayed := true
			} 
		If Instr(ValidLockStatus,"Unlocked") ;if account is unlocked returns unlcoked and changes dispaly info to reflect that
		{ 
			GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOUnlocked.png
			Break
		}
		Else If Instr(ValidLockStatus,"Moving") ;if account locked returns locked and changes dispaly info to reflect that, also runs the unlocker PS script 
		{ 
			GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOLocked.png
			GuiControl, AIOCenter:, UpdateInfo, Working on Unlocking The Account
			Gosub, UnlockAfterCtrlSend 
			Break
		}
		Sleep 50
	}
Return

CancelCMMD:
CMMDChooseGuiEscape: ;if the mulitple accounts gui window is closed, display changed to reflect that
	Gui, CMMDChoose: Destroy
	GuiControl, AIOCenter: Text, UpdateInfo, Account Lookup Canceled	
	GuiControl, AIOCenter:, AgeOfPassword, Canceled
	GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOStatus.png
Return 

UserComputerSelection:
	If (RealUser = false || NotFoundJump = false) ;if not real user or no computers found do nothing
		Return
	Else 
	{
		If A_GuiControlEvent <> DoubleClick ;if event is not a double click then do nothing
			Return
		Gosub, RemoteControlGo ;gosub on remoting into selected user computer 
	}	
Return 

UnlockAccount: 
	If (RealUser = false) ;if the username is not valid then do nothing, dont unlock the account 
		Return
	Else 
	{
		GuiControl, AIOCenter:Text, UpdateInfo, Working On Unlocking Account ;changes status to show its working on unlocking
		GuiControl, AIOCenter:, ProgressBarPercent, Working On It... ;changes status to show its working on unlocking
		DetectHiddenWindows, On
		;Try and catch for sending control send??? 
		UnlockAllDCScript := ".\PSAcctUnlock.ps1 -AccountName " AccountToGetInfo " -SearchDomain " SearchingDomain " -credential $cr"
		UnlockAllDCScript := Format("{:Ls}", UnlockAllDCScript) ;converts string to lower case so shift is not needed in PS.
		ControlSendRaw, ,%UnlockAllDCScript%, ahk_pid %PSOutVar%
		ControlSend,,{Enter}, ahk_pid %PSOutVar%
		DetectHiddenWindows, Off
		Gosub, UnlockAfterCtrlSend
	}
Return
		
UnlockAfterCtrlSend:
	FileGetTime, UnlockStatusModifyTime, C:\AHKLocal\UnlockStatus.txt, M
	EnvSub, UnlockStatusModifyTime, %A_Now%, seconds 
	While !(3 > Abs(UnlockStatusModifyTime) > 0)
	{ 
		Sleep 50
		FileGetTime, UnlockStatusModifyTime, C:\AHKLocal\UnlockStatus.txt, M
		EnvSub, UnlockStatusModifyTime, %A_Now%, seconds 
	}
	UnltotalDC := "" ;makes new blank var
	AccountUnlockStatus := "" ;makes new blank var
	InitialUnlDone := false
	PreviousAmountDone := 0
	While ! Instr(AccountUnlockStatus,"Done")
	{
		FileRead, AccountUnlockStatus, C:\AHKLocal\UnlockStatus.txt
		If Instr(AccountUnlockStatus, "Unsuccessful") ;if cant do initial unlock message is displayed and its stopped  
		{
			GuiControl, AIOCenter:Text, UpdateInfo, Unlock Failed, Try Again
			GuiControl, AIOCenter:,ProgressBarPercent, Error Could Not Unlock
			Break
		}
		If (AccountUnlockStatus != "" && InitialUnlDone = false)
		{
  		GuiControl, AIOCenter: Text, UpdateInfo, Account Unlocked`, Now Replicating ;Performing Double Check
  		InitialUnlDone := true
  	}
  	DCUnlockcomplete := 0
  	DCUnlockerror := 0
  	FileReadLine, UnltotalDC, C:\AHKLocal\UnlockStatus.txt, 1 
  	Loop, Read, C:\AHKLocal\UnlockStatus.txt 
  	{
  		Loop, Parse, A_LoopReadLine, `n 
  			{
  				If Instr(A_LoopReadLine,"Complete")
  					DCUnlockcomplete ++
  				Else If Instr(A_LoopReadLine,"Error") 
  					DCUnlockerror ++
  			}
  	}
  	UnlDCsoFar := DCUnlockcomplete + DCUnlockerror
  	AmountDone := (UnlDCsoFar/UnltotalDC)*100
  	AmountDone := Format("{1:.2f}",AmountDone)
  	If (AmountDone > PreviousAmountDone)
  	{
  		GuiControl, AIOCenter:,ProgressBarPercent, %AmountDone%`% Done - Completed:%DCUnlockcomplete% - Errors:%DCUnlockerror%
  		PreviousAmountDone := AmountDone
  	}
  	Sleep 50
  }
  If (DCUnlockcomplete = UnltotalDC)
  {
		GuiControl, AIOCenter:Text, UpdateInfo, Account Was Successfully Unlocked ;when complete updates to reflect that 
		GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOUnlocked.png
	}
	Else If (DCUnlockerror > DCUnlockcomplete)
	{
		GuiControl, AIOCenter:Text, UpdateInfo, Account Unlock Most Likely Failed
		GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOLocked.png
	}
	Else ;If (PwdDCcomplete <> PWtotalDC AND PwdDCcomplete > PwdDCerror)
	{ 
		GuiControl, AIOCenter:Text, UpdateInfo, Account Unlock Was Mostly Successful
		GuiControl, AIOCenter:, AccountStatusPic, \\Work\Server\ITSD Scripts\AutoHotKey\Data\AIOUnlocked.png
	}
Return 

ResetPassword: ;Make a spot to show the password, can also be changed here. Also make checkbox to force change at next log in
	If (RealUser = false)
		Return
	Else
	{
		WinGetPos , COMX, COMY, COMWidth, COMHeight, AIOCenter ;Gets coords and size of the current active window 
		UcompX := (COMX + Ceil(COMWidth / 2)) -75 ;finds the center adjusting for gui size
		UcompY := (COMY + Ceil(COMHeight / 2)) -55 ;finds the center adjusting for gui size	
		GuiControl, AIOCenter:Text, UpdateInfo, Working On Changing Password
		Gosub, GeneratePassword
		Gui, UserPword: Font, c%AIOFontColorChoice%
		Gui, UserPword: Add, Text, Center x10 y5 w130, Change the Password:`nPlease enter a password ;Text asking user to input a username
		Gui, UserPword: Add, Button, x90 y85 w50 Default gDoChangePWord, Change ;change button, default button
		Gui, UserPword: Add, Button, x10 y85 w50 gCancelPWordchange, Cancel ;gui cancel button
		Gui, UserPword: Add, Checkbox, vForceResetCheckBox Checked1 x10 y65, Force password change?
		Gui, UserPword: Font, cBlack
		Gui, UserPword: Add, Edit, Limit20 Center R1 x10 y37 w130 vPassChange, %FinalPassword% ;makes space on gui to enter password, autofills with randomly generated password 
		Gui, UserPword: -Border +AlwaysOnTop +ToolWindow ;+ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, UserPword: Color, %UpShdColor% ;%PwordColor% same color as toobar, color choosen by user
		Gui, UserPword: Show, x%UcompX% y%UcompY% W150 H110 ;Centers gui for current active window
		If (!InStr(AccountToGetInfo, "-lsa") && (SearchingDomain = "Work.com"))
		{
			GuiControl,UserPword: Enable, ForceResetCheckBox ;Re-enables the box in case the user recently searched an LSA account
			GuiControl,UserPword:, ForceResetCheckBox, 1
		}
		Else
		{
			GuiControl,UserPword: Disable, ForceResetCheckBox ;Disabled the choice to check the force password reset checkbox
			GuiControl,UserPword:, ForceResetCheckBox, 0
		}
	}
Return

GeneratePassword:
		Random, CapWord, 1, 106 ;selects a random number, between lines 1 and 104
		Random, SymWord, 107, 112 ;selects a random number, between lines 107 and 115
		Random, NumWord, 0, 99 ;selects a random number, between lines 1 and 99
		NumWord := Format("{1:02i}",NumWord) ;if number is single ditits adds a preceiding zero
		FileReadLine, OneWord, \\Work\Server\ITSD Scripts\AutoHotKey\Data\Password Options.txt, %CapWord% ;gets the number generated before and goes to that line in the file, pulling that word;	FileReadLine, TwoWord, \\Work\Server\ITSD Scripts\AutoHotKey\Data\Password Options.txt, %LowWord% ;gets the number generated before and goes to that line in the file, pulling that word
		FileReadLine, SymbolWord, \\Work\Server\ITSD Scripts\AutoHotKey\Data\Password Options.txt, %SymWord% ;gets the number generated before and goes to that line in the file, pulling that word
		FinalPassword := OneWord NumWord SymbolWord ;puts all the words and numbers into one string with pipe delimiter
Return

^+Space::
	SetTimer, ClearPWord, -600000 ;Clear the displayed password after this many miliseconds. Note that there is a delay before the timer starts. Seems to pause while working on other tasks.
	Gosub, GeneratePassword
	Clipboard := FinalPassword
	GuiControl, AIOCenter:Text, RandomGenPword, %FinalPassword%
	GuiControl, AIOCenter:Text, UpdateInfo, Copied Random Password To Clipboard
	SetTimer, AIOUpdateInfoRevert, -45000	
Return

;Clear the displayed password after a set amount of time.
ClearPWord:
	vClear := ;Create a blank variable
	GuiControl, AIOCenter:Text, RandomGenPword, %vClear% ;Assign the text of the text control called RandomGenPword to null variable, vClear
Return

DoChangePWord:
	Gui, UserPword: Submit, NoHide ;gets password from the gui and doesn't close the gui
	SetTimer, ClearPWord, -600000 ;Clear the displayed password after this many miliseconds. Note that there is a delay before the timer starts. Seems to pause while working on other tasks.
	If (StrLen(PassChange) < 8) ;Send a message box if the submitted password is less than 8 characters
	{
		MsgBox The password must be at least 8 characters long.
		Return
	}
	Gui, UserPword: Destroy ;destroys the gui, its no longer needed 
	GuiControl, AIOCenter:Text, RandomGenPword, %PassChange% ;displays the password on the AIOcenter, only there for a limited time 
	DetectHiddenWindows, On
	ChangePasswordStart := ".\PSPwordReset.ps1 -AccountName " AccountToGetInfo " -NewPassword " ;first part of PS command, will be converted to lowercase
	ChangePasswordEnd := " -SearchDomain " SearchingDomain " -F " ForceResetCheckBox " -credential $cr" ;last part of PS command, will be converted to lowercase
	ChangePasswordScript := Format("{1:Ls} {2:s} {3:Ls}", ChangePasswordStart, PassChange, ChangePasswordEnd) ;converts string to lower case so shift is not needed, but keeps password the same. 
	ControlSendRaw, ,%ChangePasswordScript%, ahk_pid %PSOutVar%
	ControlSend,,{Enter}, ahk_pid %PSOutVar%
	DetectHiddenWindows, Off 
	
	FileGetTime, PWordSetStatusModifyTime, C:\AHKLocal\PWordSetStatus.txt, M
	EnvSub, PWordSetStatusModifyTime, %A_Now%, seconds 
	While !(3 > Abs(PWordSetStatusModifyTime) > 0)
	{ 
		Sleep 50
		FileGetTime, PWordSetStatusModifyTime, C:\AHKLocal\PWordSetStatus.txt, M
		EnvSub, PWordSetStatusModifyTime, %A_Now%, seconds 
	}
	PWFileContents := "" ;creates blank variable for getting file contect
	PWtotalDC := "" ;blank variable for total DCs found	
	InitialPwordSet := false
	PwordPrevAmount := 0
	While ! Instr(PWFileContents, "Done")
	{
		FileRead, PWFileContents, C:\AHKLocal\PWordSetStatus.txt
		If Instr(PWFileContents,"Unsuccessful") ;if cant do initial password reset, message is displayed and its stopped  
		{
			GuiControl, AIOCenter:Text, UpdateInfo, Password Reset Failed`, Try Again
			GuiControl, AIOCenter:,ProgressBarPercent, Error Could Not Reset Password
			Break
		}
		If (PWFileContents != "" && ItitialPwordSet = false)
		{
			GuiControl, AIOCenter:Text, UpdateInfo, Password Changed`, Now Replicating ;Performing Double Check
			ItitialPwordSet := true
		}
		FileReadLine, PWtotalDC, C:\AHKLocal\PWordSetStatus.txt , 1
  	PwdDCcomplete := 0 ;resets each loop so it doesnt go over the totalDC
  	PwdDCerror := 0 ;resets each loop so it doesnt go over the totalDC
  	Loop, Read, C:\AHKLocal\PWordSetStatus.txt ;reads file and parses each line for complete or error, if found adds one
  	{
  		Loop, Parse, A_LoopReadLine, `n 
  		{
  			If Instr(A_LoopReadLine,"Complete")
  				PwdDCcomplete ++
  			Else If Instr(A_LoopReadLine,"Error") 
  				PwdDCerror ++
   	 	}
  		PwdDCsoFar := PwdDCcomplete + PwdDCerror ;gets total complete/errors so far
  		PWAmountDone := (PwdDCsoFar/PWtotalDC)*100 ;makes the total a percentage 
  		PWAmountDone := Format("{1:.2f}",PWAmountDone) ;formats to 2 digits and 2 decimal places 
  		If (PWAmountDone > PwordPrevAmount)
  		{
  			GuiControl, AIOCenter:,ProgressBarPercent, %PWAmountDone%`% Done - Successful:%PwdDCcomplete% - Errors:%PwdDCerror% ;displays the total progress so far 
  			PwordPrevAmount := PWAmountDone
  		}
 	 	}
 	 	Sleep 50
  } 
  If (PwdDCcomplete = PWtotalDC)
  {
		GuiControl, AIOCenter:Text, UpdateInfo, Password Was Successfully Updated ;when complete updates to reflect that
		GuiControl, AIOCenter:, AgeOfPassword, 00d:00h:00m  
	}
	Else If (PwdDCerror > PwdDCcomplete)
		GuiControl, AIOCenter:Text, UpdateInfo, Password Update Most Likely Failed
	Else ;If (PwdDCcomplete <> PWtotalDC AND PwdDCcomplete > PwdDCerror){
	{ 
		GuiControl, AIOCenter:Text, UpdateInfo, Password Update Mostly Successful
		GuiControl, AIOCenter:, AgeOfPassword, 00d:00h:00m
	}
Return 

CopyComp: ;copies the selected comptuer to the clipboard 
	If (RealUser = false || NotFoundJump = false) ;if username is invalid or no computers found then does nothing, else copies computer to clipboard
		Return
	Else 
	{
		Gui, AIOCenter: Submit, NoHide
		Clipboard := ComputerSelection
		GuiControl, AIOCenter:Text, UpdateInfo, Computer Was Copied To Clipboard
		SetTimer, AIOUpdateInfoRevert, -45000 ;keeps update info display visable for 45 seconds, then reverts to default   
	}
Return

PasteComp: ;pastes the computer name into the cherwell where the last username was pulled from 
	If (RealUser = false || NotFoundJump = false) ;if username is invalid or no computers found then does nothing, else pastes the computer name into cherwell description 
		Return
	Else 
	{
		Gui, AIOCenter: Submit, NoHide
		GuiControl, AIOCenter:Text, UpdateInfo, Pasting Computer Name Into Cherwell
		SetTimer, AIOUpdateInfoRevert, -45000 ;keeps update info display visable for 45 seconds, then reverts to default 
		WinActivate, ahk_id %ControlShiftV%
		FocusJump(3, 24, "*Short Description:", "Cherwell Service Management")
		SendInput {Tab}
		Sleep 200
		SendInput {Ctrl Down}{End}{Ctrl Up}
		Sleep 200
		SendInput {Return}{Return}
		Sleep 100
		PrePasteComputer := ClipboardAll
		Clipboard = Computer`: %ComputerSelection%
		Sleep 100
		SendInput ^v
		Sleep 100
		Clipboard := PrePasteComputer
		PrePasteComputer := ""
	}
Return

CompFileExplorer: ;open the C: drive of the slected computer in windows explorer 
	If (RealUser = false || NotFoundJump = false) ;if username is invalid or no computers found then does nothing, else tries to open file explorer. Error message if it fails 
		Return
	Else 
	{
		Gui, AIOCenter: Submit, NoHide
		GuiControl, AIOCenter:Text, UpdateInfo, Opening C: Drive In File Explorer
		SetTimer, AIOUpdateInfoRevert, -45000 ;keeps update info display visable for 45 seconds, then reverts to default 
		Try 
			Run,\\%ComputerSelection%\c$
		Catch
			MsgBox, 16,Can Not Connect, Could not connect to the computer %ComputerSelection% `nIt may be offline, or something went wrong
	}
Return

CompareSimple:
		WinGetPos , COMX, COMY, COMWidth, COMHeight, AIOCenter ;Gets coords and size of the current active window 
		UcompX := (COMX + Ceil(COMWidth / 2)) -75 ;finds the center adjusting for gui size
		UcompY := (COMY + Ceil(COMHeight / 2)) -55 ;finds the center adjusting for gui size	
		GuiControl, AIOCenter:Text, UpdateInfo, Working On Comparing Users
		Gui, AIOCenter: Submit, NoHide

		Gui, UserCompare: Font, c%AIOFontColorChoice%
		Gui, UserCompare: Add, Text, Center x10 y5 w130, Compare Users: ;Text asking user to input a username
		Gui, UserCompare: Add, Button, x90 y120 w50 Default gDoCompareUsers, Compare ;change button, default button
		Gui, UserCompare: Add, Button, x10 y120 w50 gCancelCompareUsers, Cancel ;gui cancel button
		Gui, UserCompare: Add, Checkbox, vRecursiveCheckBox x10 y100, Do a recursive search?
		Gui, UserCompare: Add, Text, Center x10 y21 w130, First UserID:		
		Gui, UserCompare: Add, Text, Center x10 y60 w130, Second UserID:
		Gui, UserCompare: Font, cBlack
		Gui, UserCompare: Add, Edit, Center R1 x10 y35 w130 vCompareFirstUser, %AccountToGetInfo%
		Gui, UserCompare: Add, Edit, Center R1 x10 y74 w130 vCompareSecondUser
		Gui, UserCompare: -Border +AlwaysOnTop +ToolWindow ;+ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, UserCompare: Color, %UpShdColor% ;%PwordColor% same color as toobar, color choosen by user
		Gui, UserCompare: Show, x%UcompX% y%UcompY% W150 H150 ;Centers gui for current active window
		GuiControl, UserCompare: Focus, CompareFirstUser
		SendInput	^a
;		}
Return

DoCompareUsers:
	FileDelete, C:\AHKLocal\AccountValidTest*.txt
	Gui, UserCompare: Submit
	If (CompareSecondUser = "")
		CompareSecondUser := "PleaseJustListTheFirstUser"
	If (RecursiveCheckBox = false)
		Run, powershell.exe -Command "& '%A_ScriptDir%\Data\CompareUsersGroups.ps1' -user1 %CompareFirstUser% -user2 %CompareSecondUser% -recursive false",,Hide
	Else
		Run, powershell.exe -Command "& '%A_ScriptDir%\Data\CompareUsersGroups.ps1' -user1 %CompareFirstUser% -user2 %CompareSecondUser% -recursive true",,Hide
	If (CompareSecondUser != "PleaseJustListTheFirstUser")
	{
		Run, powershell.exe -Command "& '%A_ScriptDir%\Data\CheckIfUserError.ps1' -user1 %CompareFirstUser%",,Hide
		RunWait, powershell.exe -Command "& '%A_ScriptDir%\Data\CheckIfUserError.ps1' -user1 %CompareSecondUser%",,Hide
	}
	Else
		RunWait, powershell.exe -Command "& '%A_ScriptDir%\Data\CheckIfUserError.ps1' -user1 %CompareFirstUser%",,Hide
	FileRead, AccountIsValid1, C:\AHKLocal\AccountValidTest%CompareFirstUser%.txt
	FileRead, AccountIsValid2, C:\AHKLocal\AccountValidTest%CompareSecondUser%.txt
	AccountCheckCombined := AccountIsValid1 A_Space AccountIsValid2
	If Instr(AccountCheckCombined,"valid")
	{
		MsgBox %AccountCheckCombined%
		Gui, UserCompare: Show
		Return
	}
	Gui, UserCompare: Destroy	
	GuiControl, AIOCenter:Text, UpdateInfo, Generating Table, Please Wait
	WinGet, WinListInitial, List, Comparision of Users
	SetTimer, CheckComparisonWin, 500
Return

CheckComparisonWin:
	WinGet, WinList, list, Comparision of Users
	If (WinList > WinListInitial)
	{
		SetTimer, CheckComparisonWin, Delete
		GuiControl, AIOCenter:Text, UpdateInfo, User Comparison Completed	
	}
Return

CancelCompareUsers:
UserCompareGuiEscape:
	GuiControl, AIOCenter:Text, UpdateInfo, User Compare Canceled
	Gui, UserCompare: Destroy
Return

CancelPWordchange:
UserPwordChangeGuiEscape: ;hitting esc or cancel will close the gui and NOT do the password change 
	Gui, UserPword: Destroy
	GuiControl, AIOCenter:Text, UpdateInfo, Password Change Canceled 
Return 

AIOUpdateInfoRevert: ;when 45 seconds is up reverts display to info below 
	GuiControl, AIOCenter:Text, UpdateInfo, Status Bar Information
Return 

#IfWinActive, AIOCenter ;if the gui AIOCenter is active then the folling keys will work

NumpadEnter::
Enter:: ;hitting enter remotes into the selected machine
	ControlGetFocus, HittingKeys, AIOCenter
	If (HittingKeys = "ListBox1") ;if not in the list box then sends enter key, else does the following 
	{ 
		If (RealUser = false || NotFoundJump = false) ;if username is invalid or no computers found then does nothing, else remotes into the selected computer 
			Return
		Else 
			Gosub, RemoteControlGo
	}
	Else
		SendInput {Enter}
Return

RemoteControlGo: ;when select to remote in. Gets the computer, adds a stat, and then rums it in Configuration Manager Remote Control
	Gui, AIOCenter: Submit, NoHide
	StatType := "AIOSearch" ;Names the header that will appear the stats output for when a user's computer is remoted in to.
	DescText := "Remote In" ;Names the value that will appear the stats output for when a user's computer is remoted in to.
	Gosub, StatGrabber2 ;Starts the subroutine that increases the value of number of computers remoted in to.
	DetectHiddenWindows, On
	RemoteComptuer := ".\psremoteaccess.ps1 -com " ComputerSelection " -cred $cr"
	ControlSendRaw,,  %RemoteComptuer%, ahk_pid %PSOutVar%
	ControlSend,, {Enter}, ahk_pid %PSOutVar%
	DetectHiddenWindows, Off
	GuiControl, AIOCenter:Text, UpdateInfo, Remoting Into Selected Computer
	SetTimer, AIOUpdateInfoRevert, -45000 ;keeps update info display visable for 45 seconds, then reverts to default 
Return 
	
^c:: ;control c, or control shift c, will copy the selected comptuer to the clipboard
^+c::
	ControlGetFocus, HittingKeys, AIOCenter
	If (HittingKeys = "Edit1") ;if in the edit box then sends control c, else does the following 
		SendInput ^c
	Else
		Gosub, CopyComp
Return
	
^a:: ;control a, or control shift a, will copy all the users comptuers to the clipboard 
^+a:: 
	ControlGetFocus, HittingKeys, AIOCenter
	If (HittingKeys = "Edit1") ;if in the edit box then sends control a, else does the following
	{ 
		SendInput ^a
	}
	Else
	{		
		If (RealUser = false || NotFoundJump = false) ;if username is invalid or no computers found then does nothing, else will copy all computers to the clipboard
			Return
		Else 
		{
			CompFullList := StrReplace(StringOptions,"||","`n") ;rermoves pipes from the var before sending to the clipboard
			CompFullList := StrReplace(CompFullList,"|","`n")
			Clipboard := CompFullList
			GuiControl, AIOCenter:Text, UpdateInfo, All Computers Were Copied To Clipboard
			SetTimer, AIOUpdateInfoRevert, -45000 ;keeps update info display visable for 45 seconds, then reverts to default 
		}
	}
Return		
	
^x:: ;control x, or control shift x will open file explorer to the users C: drive
^+x:: 
	ControlGetFocus, HittingKeys, AIOCenter
	If (HittingKeys = "Edit1") ;if in the edit box then sends control x, else does the following
		SendInput ^x
	Else
		Gosub, CompFileExplorer
Return
	
^v:: ;control v, or ;control shift v, will paste the selected computer name in the cherwell description. It finds the short description and then tabs to the description 
^+v:: 
	ControlGetFocus, HittingKeys, AIOCenter
	If (HittingKeys = "Edit1") ;if in the edit box then sends control v, else does the following
		SendInput ^v
	Else
		Gosub, PasteComp
Return 

^m:: ;control v, or ;control shift v, will paste the selected computer name in the cherwell description. It finds the short description and then tabs to the description 
^+m:: 
	GoSub, CompareSimple
Return 

;---------------------------------------------------------------------------------------------------

#IfWinActive ahk_exe bomgar-rep.exe

^+a::
	If (A_Hour > 11)
		SendInput Good afternoon{!} Thank you for contacting the IT Service Desk.
	Else
		SendInput Good morning{!} Thank you for contacting the IT Service Desk.
	Sleep, 100
	SendInput {Enter}
	Sleep, 100
	SendInput My name is %ScriptUserID%. How can I help you?
	Sleep, 100
	SendInput {Enter}
Return

^+z::
	SendInput Thank you for using the IT Service Desk chat support{!}
	Sleep, 100
	SendInput {Enter}
	Sleep, 100
	SendInput Please click on the "X" when you are ready to end the chat session.
	Sleep, 100
	SendInput {Enter}
Return

::belse::
	SendInput Is there anything else I can assist you with?
	SendInput {Enter}
Return

::btick::
	SendInput Do you want the ticket number?
	SendInput {Enter}
Return

::bcon::
	SendInput Do you want to be contacted by phone, e-mail, Teams, or another way?
	SendInput {Enter}
Return

::bmind::
	SendInput Do you mind if I remote in?
	SendInput {Enter}
Return

::omp::
::bomp::
	SendInput One moment please.
	SendInput {Enter}
Return

::ompr::
::bompr::
	SendInput One moment please while I research that.
	SendInput {Enter}
Return


#IfWinActive ITSDMarquee
Left::
	Gosub, NextMarquee
Return

Right::
	Gosub, PrevMarquee
Return

Delete::
NumpadDot::
NumpadDel::
	If (ITSDUtilAdmin = true)
		Gosub, DelMarquee
Return

NumpadAdd::
+::
	If (ITSDUtilAdmin = true)
		Gosub, AddMarquee
Return
;------------------------------------------------------------------

#IfWinActive ahk_class ConsoleWindowClass

^v::
	SendInput {Raw}%Clipboard%
Return

#IfWinActive Knowledge search - KCS Articles

^+1::
	SendInput ^d
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput bold
	SendInput {Tab}
	Sleep, 100
	SendInput 12
	SendInput {Enter}
	Sleep, 100
	SendInput ITSD Section:
	SendInput {Enter}
	Sleep, 100
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
	Sleep, 100
	SendInput {Enter}{Enter}{Enter}
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput bold
	SendInput {Tab}
	Sleep, 100
	SendInput 12
	SendInput {Enter}
	Sleep 100
	SendInput Non-ITSD Section:
	SendInput {Enter}
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
	Sleep, 200
	SendInput NA
Return

^+2::
	SendInput ^d
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
Return
	
^+3::
	Gui KCSBlueGui: Add, Text,, Enter KCS Number:
	Gui KCSBlueGui: Add, Edit, vKCSNumBlue
	Gui KCSBlueGui: Add, Button, Default, OK
	Gui KCSBlueGui: Add, Button, , Cancel
	Gui KCSBlueGui: Show,, Link KCS
Return

#IfWinActive Quick-view

^+1::
	SendInput ^d
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput bold
	SendInput {Tab}
	Sleep, 100
	SendInput 12
	SendInput {Enter}
	Sleep, 100
	SendInput ITSD Section:
	SendInput {Enter}
	Sleep, 100
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
	Sleep, 100
	SendInput {Enter}{Enter}{Enter}
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput bold
	SendInput {Tab}
	Sleep, 100
	SendInput 12
	SendInput {Enter}
	Sleep 100
	SendInput Non-ITSD Section:
	SendInput {Enter}
	SendInput ^d
	Sleep, 300
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
	Sleep, 200
	SendInput NA
Return

^+2::
	SendInput ^d
	Sleep, 150
	SendInput verdana
	SendInput {Tab}
	Sleep, 100
	SendInput regular
	SendInput {Tab}
	Sleep, 100
	SendInput 10
	SendInput {Enter}
Return
	
^+3::
	Gui KCSBlueGui: Add, Text,, Enter KCS Number:
	Gui KCSBlueGui: Add, Edit, vKCSNumBlue
	Gui KCSBlueGui: Add, Button, Default, OK
	Gui KCSBlueGui: Add, Button, , Cancel
	Gui KCSBlueGui: Show,, Link KCS
Return

#IfWinActive

; The following comes from DockWin v0.4 - Save and Restore window positions when docking/undocking
ITSDToolbarButtonFixWins:
  WinGetActiveTitle, SavedActiveWindow
  ParmVals:="Title x y height width maximized path"
  SectionToFind:= SectionHeader()
  SectionFound:= 0
 	FixWinProg = 5
 	Progress, b w300, Fixing windows
 	Progress, %FixWinProg%
  Loop, Read, %WinDockFile%
  {
    If !SectionFound
    {
      ;Read through file until correct section found
      If (A_LoopReadLine<>SectionToFind) 
				Continue
    }	  
		;Exit if another section reached
		If ( SectionFound and SubStr(A_LoopReadLine,1,8)="SECTION:")
			Break
		SectionFound:=1
		Win_Title:="", Win_x:=0, Win_y:=0, Win_width:=0, Win_height:=0, Win_maximized:=0
		Loop, Parse, A_LoopReadLine, CSV 
		{
			EqualPos:=InStr(A_LoopField,"=")
			Var:=SubStr(A_LoopField,1,EqualPos-1)
			Val:=SubStr(A_LoopField,EqualPos+1)
			IfInString, ParmVals, %Var%
			{
				;Remove any surrounding double quotes (")
				If (SubStr(Val,1,1)=Chr(34)) 
				{
					StringMid, Val, Val, 2, StrLen(Val)-2
				}
				Win_%Var%:=Val  
			}
		}
		FixWinProg+=3
		Progress, %FixWinProg%
		If ( (Win_maximized = 1) and WinExist(Win_Title) )
		{	
			WinRestore
			WinActivate
			WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
			WinMaximize, A
		} 
		Else If ((Win_maximized = -1) and (StrLen(Win_Title) > 0) and WinExist(Win_Title) )		; Value of -1 means Window is minimised
		{	
			WinRestore
			WinActivate
			WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
			WinMinimize, A
		} 
		Else If ( (StrLen(Win_Title) > 0) and WinExist(Win_Title) )
		{	
			WinRestore
			WinActivate
			WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
		}
  }
  If !SectionFound
  {
    msgbox,,Dock Windows, Section does not exist in %WinDockFile% `nLooking for: %SectionToFind%`n`nTo save a new section, Click on the "O" button and then click "Save Win Positions"
  }
  ;Restore window that was active at beginning of script
  WinActivate, %SavedActiveWindow%
  Progress, 99
  Sleep, 100
  Progress, Off
Return


SaveWin:
	Gui, UtilOptions: Hide
	MsgBox, 4,Dock Windows, Save current window positions and delete previous positions? `nDon't touch the mouse or keyboard until completion, please.
	IfMsgBox, NO, Return
	SaveWinProg = 1
	Progress, b w300, Deleting previous settings, Saving Window Positions
	Progress, %SaveWinProg%
	FileDelete C:\temp\winpos.txt
	Sleep, 500
	WinGetActiveTitle, SavedActiveWindow
	file := FileOpen(WinDockFile, "a")
	If !IsObject(file)
	{
		MsgBox, Can't open "%WinDockFile%" for writing.
		Return
	}
	line:= SectionHeader() . CrLf
	file.Write(line)
  ; Loop through all windows on the entire system
	WinGet, id, list,,, Program Manager
	Loop, %id%
	{
		SaveWinProg+=1.5
		Progress, %SaveWinProg%, Discovering windows
		this_id := id%A_Index%
		WinGetTitle, this_title, ahk_id %this_id%
		WinGet, win_maximized, minmax, %this_title%
		WinActivate, ahk_id %this_id%
		WinGetPos, x, y, Width, Height, A ;Wintitle
		WinGetClass, this_class, ahk_id %this_id%
		If ( (StrLen(this_title)>0) and (this_title<>"Start") )
		{
			line=Title="%this_title%"`,x=%x%`,y=%y%`,width=%width%`,height=%height%`,maximized=%win_maximized%,path=""`r`n
			file.Write(line)
		}
		If(win_maximized = -1)		;Re-minimize any windows that were minimised before we started.
		{
			WinMinimize, A
		}
  	Sleep, 150
  }
  file.write(CrLf)  ;Add blank line after section
  file.Close()
	SaveWinProg = 100
	Progress, %SaveWinProg%
	Sleep, 200
	Progress, Off
  ;Restore active window
  WinActivate, %SavedActiveWindow%
  MsgBox,, Dock Windows, Saved!
Return


;Create standardized section header for later retrieval
SectionHeader()
{
	SysGet, MonitorCount, MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	line=SECTION: Monitors=%MonitorCount%,MonitorPrimary=%MonitorPrimary%
  WinGetPos, x, y, Width, Height, Program Manager
	line:= line . "; Desktop size:" . x . "," . y . "," . width . "," . height
	Return %line%
}

;-----------------------------

;The following are needed for making the opposite color for the attention grabbing color flash for the AIOCenter when a new ContextTip appears.
Hex2RGB( CR ) {
  NumPut( "0x" SubStr(CR,-5), (V:="000000") )
  Return NumGet(V,2,"UChar") "," NumGet(V,1,"UChar") "," NumGet(V,0,"UChar")
}

Hex2R(Hex){
  NumPut( "0x" SubStr(Hex,-5), (V:="000000") )
	Return NumGet(V,2,"UChar")
}

Hex2G(Hex){
  NumPut( "0x" SubStr(Hex,-5), (V:="000000") )
	Return NumGet(V,1,"UChar")
}

Hex2B(Hex){
  NumPut( "0x" SubStr(Hex,-5), (V:="000000") )
	Return NumGet(V,0,"UChar")
}

rgbToHex(s, d = "") {
  StringSplit, s, s, % d = "" ? "," : d
  SetFormat, Integer, % (f := A_FormatInteger) = "D" ? "H" : f
  h := s1 + 0 . s2 + 0 . s3 + 0
	SetFormat, Integer, %f%
  Return, RegExReplace(RegExReplace(h, "0x(.)(?=$|0x)", "0$1"), "0x")
}
