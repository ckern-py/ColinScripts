#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

;Im making a change to test out GitHub
;Next im going to remove this change

;Variable pointing directly to data folder to make it easy to change to dev if needed for testing.
DataDir := "\\Work\Server\ITSD Scripts\AutoHotkey\Data\"
;Variables for HTML that needs to be replaced to fill out template. If the email template ever changes, these may also need to be updated.
DescriptionTemp := "{<span style='color:#953735'>copy/paste from Subject of Portal Announcement</span>}"
InitTimeTemp := "{<span style='color:#953735'>Format:<span style='mso-spacerun:yes'>  </span>mm/dd<span style='mso-spacerun:yes'>  </span>hh/mm a.m. -<span style='mso-spacerun:yes'>  </span>Include the date as well as the start and end time. If it is still occurring, use “ongoing” for the end time (ex: 08/04 09:30 a.m – Ongoing)</span>}"
IncNumberTemp := "{<span style='color:#953735'>Cherwell Incident number</span>}"
LongDescTemp := "{<span style='color:#953735'>Paste the comment section from the Portal Announcement.<span style='mso-spacerun:yes'>  </span>It should Include a description of the incident, including start/stop times, and business impact in general terms – avoid technical jargon and acronyms. For the initial communication, there may not be much info here</span>}"
UpdTimeFrameTemp := "{<span style='color:#953735'>Provide a timeframe for the next update.<span style='mso-spacerun:yes'>  </span>See note above to get the timing</span><span style='color:#1F497D;mso-themecolor:dark2'>.</span>}"
Priority2Flag := "color:#00B0F0'>Priority 2 Incident</span>"
Priority1Flag := "color:red'>Priority 1 Incident</span>"
PriorityLvlTemp := "color:#00B0F0'>Priority 2 Incident</span>"

;The following sets up the initial timeframe range to within 56 minutes to 86 minutes from when this application is launched or cleared.
;If the time is between 0 and 5 minutes after the hour, it adds an hour and changes the minutes to 0. If it is between 4 and 34 minutes after the hour, it adds and hour and changes the minutes to 30.
;If the time is after 35 minutes after the hour, it adds 2 hours and changes the minutes to 0.
MyTimeTf := A_Now
FormatTime, MyMinTf, %MyTimeTf%, mm
If (MyMinTf = 0 || MyMinTf < 5)
{
	EnvAdd, MyTimeTf, 1, Hours
	EnvAdd, MyTimeTf, -%MyMinTf%, Minutes
}
Else If (MyMinTf > 4 && MyMinTf < 35)
{
	EnvAdd, MyTimeTf, 1, Hours
	EnvAdd, MyTimeTf, -%MyMinTf%, Minutes
	EnvAdd, MyTimeTf, 30, Minutes
}
Else If (MyMinTf > 34 && MyMinTf < 60)
{
	EnvAdd, MyTimeTf, 2, Hours
	EnvAdd, MyTimeTf, -%MyMinTf%, Minutes
}

;Set up the gui interface (buttons and text fields.
Gui, Add, Text, x10 y10, Incident Priority
Gui, Add, DropDownList, gSubmitRad vPrioritySelection w72 x10 y25, P1|P2|P3||

Gui, Font, bold
Gui, Add, Text, Center x90 y31 w200, Ticket Notification Center
Gui, Font, norm

Gui, Add, Text, x10 y54, Incident #
Gui, Add, Edit, Number w166 x10 y69 vIncNum

Gui, Add, Text, x10 y98, Title
Gui, Add, Edit, gCharCheck vIncTitle w166 x10 y113

Gui, Add, Text, x10 y142, Description
Gui, Add, Edit, vIncDesc w166 x10 y157 h65

Gui, Add, Text, x10 y230, Special ITSD Instructions (optional)
Gui, Add, Edit, vIncSpecITSD w166 x10 y245 h65

Gui, Add, Text, x195 y318, Initial Time
Gui, Add, DateTime, vIncInitTime w166 x195 y333, MM/dd hh:mm tt
	
Gui, Add, Text, x10 y318, Next Update Timeframe
Gui, Add, DateTime, vIncUpdTf Choose%MyTimeTf% w166 x10 y333, MM/dd hh:mm tt
	
Gui, Add, Text, Center vTeamsROCChatStrike w350 x10 y362, Type ~roc in Teams to post to ROC chat
Gui, Add, Text, Center vTeamsITSDChatStrike w350 x10 y378, Type ~itsd in Teams to post to ITSD chat

Gui, Add, Button, gCreateEmail vCreateEmailBtn Disabled w166 x195 y69, Create Email
Gui, Add, Button, gCreateMarq vMarqueeNotif w166 x195 y112, Create New Marquee Notification
Gui, Add, Button, gCopyChrTitle vCherwellTitleBtn w166 x195 y156, Cherwell Title
Gui, Add, Button, gCopyChrDesc vCherwellDescBtn w166 x195 y200, Cherwell Description
Gui, Add, Button, gCopyBmgrTitle vBomgarTitleBtn w166 x195 y244, Bomgar Title
Gui, Add, Button, gCopyBmgrDesc vBomgarDescBtn w166 x195 y288, Bombgar Description

Gui, Add, Text, x309 y10, Reset GUI
Gui, Add, Button, gClearAll w72 x288 y25, Clear All

Gui, Show, Center w370 h395, Ticket Notification Center
Return

;The copy subroutines below copy the various information to the clipboard to be pasted into Cherwell and Bomgar.

CopyChrTitle:
	Gui, Submit, NoHide
	Clipboard := "Attention:  " IncTitle
	Gui, Font, strike
	GuiControl, Font, CherwellTitleBtn
Return

CopyBmgrTitle:
	Gui, Submit, NoHide
	Clipboard := IncTitle
	Gui, Font, strike
	GuiControl, Font, BomgarTitleBtn
Return

CopyChrDesc:
	Gui, Submit, NoHide
	Clipboard := IncDesc " IT Support is working to resolve the issue through incident " IncNum "."
	Gui, Font, strike
	GuiControl, Font, CherwellDescBtn 
Return

CopyBmgrDesc:
	Gui, Submit, NoHide
	Clipboard := "ATTENTION:  " IncTitle " - " IncDesc " IT Support is working to resolve the issue through incident " IncNum "."
	Gui, Font, strike
	GuiControl, Font, BomgarDescBtn
Return

;When the priority is changed between 1, 2 and 3 check if it is 3 and disable the Create Email button if it is, since we don't send emails for P3.
SubmitRad:
	Gui, Submit, NoHide
	If (PrioritySelection = "P3")
		GuiControl, Disable, CreateEmailBtn
	Else
		GuiControl, Enable, CreateEmailBtn
Return

;Clear all fields and set the initial time to now and the initial expected update timeframe to between 56 and 86 minutes from now by default.
ClearAll:
	MyTimeTf := A_Now
	FormatTime, MyMinTf, %MyTimeTf%, mm
	If (MyMinTf = 0 || MyMinTf < 5)
	{
		EnvAdd, MyTimeTf, 1, Hours
		EnvAdd, MyTimeTf, -%MyMinTf%, Minutes
	}
	Else If (MyMinTf > 4 && MyMinTf < 35)
	{
		EnvAdd, MyTimeTf, 1, Hours
		EnvAdd, MyTimeTf, -%MyMinTf%, Minutes
		EnvAdd, MyTimeTf, 30, Minutes
	}
	Else If (MyMinTf > 34 && MyMinTf < 60)
	{
		EnvAdd, MyTimeTf, 2, Hours
		EnvAdd, MyTimeTf, -%MyMinTf%, Minutes
	}
	NullVar :=
	GuiControl,, IncUpdTf, %MyTimeTf%
	GuiControl,, IncNum, %NullVar%
	GuiControl,, IncTitle, %NullVar%
	GuiControl,, IncDesc, %NullVar%
	GuiControl,, IncSpecITSD, %NullVar%
	GuiControl,, IncInitTime, %A_Now%
	GuiControl,, IncUpdTf, %MyTimeTf%
	GuiControl, Choose, PrioritySelection, 3
	Gui, Font, norm
	GuiControl, Font, CreateEmailBtn
	GuiControl, Font, TeamsROCChatStrike
	GuiControl, Font, TeamsITSDChatStrike
	GuiControl, Font, MarqueeNotif
	GuiControl, Font, CherwellTitleBtn
	GuiControl, Font, BomgarTitleBtn
	GuiControl, Font, CherwellDescBtn
	GuiControl, Font, BomgarDescBtn
	Gosub, SubmitRad
Return

;Using the hmtl template saved as plain text in \data\notificationsemailer\templatehtml.txt, changes out text to fill out the template based on how fields are filled out in gui.
CreateEmail:
	;Submit NoHide so that the gui window does not close when the Create Email button is clicked.
	
	Gui, Submit, NoHide
	
	;Format the time so that the default PM (or AM) is replaced with the required format, "p.m." and add "– Ongoing" afterward.
	FormatTime, MyPAMInit, %IncInitTime%, tt
	If (MyPAMInit = "PM")
		MyPAMInitFixed := "p.m. – Ongoing"
	Else
		MyPAMInitFixed := "a.m. – Ongoing"
	FormatTime, MyPAM, MyTime, tt
	If (MyPAM = "PM")
		MyPAMFixed := "p.m."
	Else
		MyPAMFixed := "a.m."
	
	;Same as above but for the expected next update time instead.
	FormatTime, MyPAMTf, %IncUpdTf%, tt
	If (MyPAMTf = "PM")
		MyPAMTfFixed := "p.m."
	Else
		MyPAMTfFixed := "a.m."
	
	;Reads the plain text html email template and sets it to the variable MsgTemplate, so that parts can be replaced.
	FileRead, MsgTemplate, %A_ScriptDir%\Data\NotificationEmailer\TemplateHTML.txt
	;Remove all returns and new lines from the template so that replacements will work correctly.
	RNL := "`r`n"
	MsgTemplate := StrReplace(MsgTemplate, RNL, " ")
	Outlook := ComObjActive("Outlook.Application")
	email := Outlook.Application.CreateItem(0)
	email.BCC := "ITIncidentNotification@work.com"
	email.SentOnBehalfOfName := "ITUpdate-Operations@work.com"
	email.BodyFormat := 2
		
	FormatTime, IncInitTimeFormat, %IncInitTime%, MM/dd h:mm
	IncInitTimeFormat := IncInitTimeFormat " " MyPAMInitFixed
		
	FormatTime, IncUpdTfFormat, %IncUpdTf%, h:mm
	IncUpdTfFormat := IncUpdTfFormat " " MyPAMTfFixed	
		
	;The following lines replace each part of the template, continuously updating the variable MsgTemplateReplaced
	MsgTemplateReplaced := StrReplace(MsgTemplate, DescriptionTemp, IncTitle)
	MsgTemplateReplaced := StrReplace(MsgTemplateReplaced, InitTimeTemp, IncInitTimeFormat)
	MsgTemplateReplaced := StrReplace(MsgTemplateReplaced, IncNumberTemp, IncNum)
	MsgTemplateReplaced := StrReplace(MsgTemplateReplaced, LongDescTemp, IncDesc)
	MsgTemplateReplaced := StrReplace(MsgTemplateReplaced, UpdTimeFrameTemp, IncUpdTfFormat)	
	If (PrioritySelection = "P2")
		MsgTemplateReplaced := StrReplace(MsgTemplateReplaced, PriorityLvlTemp, Priority2Flag)	
	Else
		MsgTemplateReplaced := StrReplace(MsgTemplateReplaced, PriorityLvlTemp, Priority1Flag)
	email.HTMLBody := MsgTemplateReplaced
	email.Subject := "IT Service Update " IncNum " : " IncTitle " - #1"
	email.Display()
	Gui, Font, strike
	GuiControl, Font, CreateEmailBtn
Return

;Since the marquee updates are files, the following characters are not allowed. These characters are deletd.
CharCheck:
	Gui, Submit, NoHide
	If IncTitle Contains /,\,:,*,?,",<,>,|,& ;"
	{
		SendInput, {BackSpace}
		MsgBox, Please do not use any of the following characters: / \ : * ? " < > | & `;
		;" ignore this line. It is here because the unmatched quote mark was causing issues in UltraEdit. Thanks UltraEdit.
		Goto, CharCheck
	}
Return

;Create a file in the data\messages folder where the title of the file is the heading/title for the message and the contents of the file is the message description.
;It also updates the NewMsgTrigger which causes the marquee to change color and expand and display the latest message.
CreateMarq:
	Gui, Submit, NoHide
	MarqMessage = %IncDesc% `n`r `n`rPlease link any related calls to Incident %IncNum% `n`r `n`r%IncSpecITSD%
	FileDelete, %DataDir%\Messages\%IncTitle%.txt
	FileAppend, %MarqMessage%, %DataDir%\Messages\%IncTitle%.txt
	Sleep 1000
	FileAppend, Updated %A_Now% `n, %DataDir%\NewMsgTrigger.txt
	Gui, Font, strike
	GuiControl, Font, MarqueeNotif
Return

;If the window is closed, close the script completely.
GuiClose:
Gui, Destroy
ExitApp

;If Microsoft Teams is the window with focus, then the following hotkeys/hotstrings become available.
#IfWinActive ahk_exe Teams.exe

;Typing tilde followed by "roc" in Teams causes it to fill in the incident info. 
::~roc::
	Gui, Submit, NoHide
	ChatThis := PrioritySelection " Master Incident *" IncNum "* has been escalated for " IncTitle " - " IncDesc
	SendInput, %ChatThis%
	Gui, Font, strike
	GuiControl, Font, TeamsROCChatStrike
Return

;Typing tilde followed by "itsd" in Teams causes it to fill in the incident info. 
::~itsd::
	Gui, Submit, NoHide
	ChatThis := PrioritySelection " Master Incident *" IncNum "* has been escalated for " IncTitle " - " IncDesc
	SendInput, %ChatThis%
	Gui, Font, strike
	GuiControl, Font, TeamsITSDChatStrike
Return

;Ending for the IfWinActive section.
#IfWinActive