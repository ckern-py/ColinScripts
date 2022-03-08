#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance

ITSDAgentsName := {abc1234:"Agent1", abc1000:"Agent2", abc9001:"Agent3", abc9876:"Agent4"}
FormatTime, Today, %A_Now%, MMddyyyy

SaveFolder = \\Work\Server\ITSD\AHK\AutoHotKey Leaderboard ; [Designates the overall path for the saved files to be used later.]

IfExist, %SaveFolder%\%A_UserName%-%Today%.ini ; [This scans for the .ini files before launching the GUI and performing an action. It makes the Survey_Count_Text button work.]
{
	IniRead, SurveyCount, %SaveFolder%\%A_UserName%-%Today%.ini, Section 2, key
}
Else
{
	SurveyCount = 0
}
Gui, Name: New, , ITSD Leaderboard; ; [Creates GUI; titles it ITSD Leaderboard.]
Gui, Name: Add, Button, x10 y25 gAddSurvey, Add Survey ; [Creates button label Add Survey with the coordinates 10.]
Gui, Name: Add, Text, x95 y30 w20 vSurvey_Count_Text, %SurveyCount% ; [Creates a button label for the counted survey button clicks.]
Gui, Name: Add, Button, x125 y25 gLeaderboard, Leaderboard ; [Creates button label Leaderboard with the coordinates 125.]
Gui, Name: Add, Button, x178 y00 gExit, X ; [Creates button label X for Exit with the coordinates 178.]
Gui, Name: Add, Button, x155 y00 gMonthlyboard,  M ; [Creates button label M for the Montly Leaderboard with the coordinates 155.]
Gui, +alwaysontop ; [Keeps the Gui on top of all other windows.]
Gui, Name: -caption ; [Removes the border of the Gui. Makes it frameless]
OnMessage(0x0201, "WM_LBUTTONDOWN") ; [This along with the WM_LButtonDown code below makes the Gui moveable by clicking anywhere.]
Gui, Name: show, x800 y400 ; [Determines where on the screen the GUI appears]
Return

WM_LBUTTONDOWN() ; [This along with the line of code above called OnMessage, makes the Gui moveable by clicking anywhere.]
{
   If (A_Gui)
      PostMessage, 0xA1, 2
; 0xA1: WM_NCLBUTTONDOWN, refer to http://msdn.microsoft.com/en-us/library/ms645620%28v=vs.85%29.aspx
; 2: HTCAPTION (in a title bar), refer to http://msdn.microsoft.com/en-us/library/ms645618%28v=vs.85%29.aspx 
}

AddSurvey: ; [Gives the AddSurvey button action.]
	SurveyCount += 1 ; [Tells the Add Survey button to increase by one each click.]
	SurveyCount := Format("{1:02i}",SurveyCount)
	FormatTime, Today, %A_Now%, MMddyyyy
	IniWrite, %SurveyCount%, %SaveFolder%\%A_UserName%-%Today%.ini, section 2, key ; [Creates a .ini file for your username at the L drive; Places the word variable in it.]
	GuiControl Name: ,Survey_Count_Text, %SurveyCount% ; [Master control for the Gui. This makes the Survey_Count_Text update with the Add Survey button. Without it, it will only display the last number from when the Gui was opened.]
	Sleep, 10 ; [This makes the button register clicks every 10 seconds. It prevents double clicking.]
Return

Leaderboard: ; [Gives the Leaderboard button action.]
	UserCount=0
	Loop, %SaveFolder%\*%Today%.ini ; [This loop scans the the .ini folders to gather the userids to display.]
{
	CurrentID := SubStr(A_LoopFileName, 1, -13) ; [This removes the .ini and date on the filename.]
	SurveyName%A_Index% := CurrentID
	IniRead, SurveyCount%CurrentID%, %A_LoopFileFullPath%, Section 2, key
	UserCount +=1
}
	Leaderboard_List =
	Loop, %UserCount% ; [This loop creates the Leaderboard window with the survey counts and userids.]
{
	SurveyNameTemp := SurveyName%A_Index%
	SurveyNameTemp2 := %SurveyNameTemp%	; [This replaces our userids with our names.]
	SurveyCountTemp := SurveyCount%SurveyNameTemp%
	Leaderboard_List = %Leaderboard_List% `n%SurveyNameTemp2% = \%SurveyCountTemp%
}
	Sort, Leaderboard_List, R \ ; [This sorts the Leadboard_List]
	StringReplace, Leaderboard_List, Leaderboard_List, \,,All ; [This replaces the Leaderboard_List to remove the \.]
	MsgBox, %Leaderboard_List%
Return

Monthlyboard: ; [Gives the Monthlyboard button action.]
	ITSDAgentsSTotal := {abc1234:0, abc1000:0, abc9001:0, abc9876:0}
	monthlyCurr := []
	monthlyCurrOne := 
	ArrayCount := 0
	MonthNum := SubStr(Today, 1, 2)
	Loop, Files, %SaveFolder%\*-%MonthNum%*.ini 
	{
		CurUserID := SubStr(A_LoopFileName, 1, -13)
		IniRead, UserSerVal, %A_LoopFileFullPath%, section 2, key
		totalSurvey := ITSDAgentsSTotal[CurUserID]
		totalSurvey += UserSerVal
		ITSDAgentsSTotal[CurUserID] := totalSurvey
		
	}
	for key, val in ITSDAgentsSTotal {
		ArrayCount += 1
		monthlyCurr[ArrayCount] = %val%=%key%
	}
	Sort, monthlyCurr, R
	for item, otherItem in monthlyCurr
		msgbox %item%=%otherItem%
Return

Exit: ; [Makes the Exit button visible and provides action in this sequence.]
	#x::ExitApp ; [Closes the Gui window and the instance of AutoHotKey.]
Return
