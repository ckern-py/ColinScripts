#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

;FoundChars := []
StartTime = %A_Now%

Loop, Read, C:\temp\AHK\Research\All Users and Computers.txt 
{
	NameCompSplit:= StrSplit(A_LoopReadLine, ",")
	UserNameL := StrLen(NameCompSplit.1)
	UserFull := NameCompSplit.1
	FileAppend, %UserNameL%-%UserFull%`n, C:\temp\AHK\Research\UsernameResults.txt
}
	
FileRead, Contents, C:\temp\AHK\Research\UsernameResults.txt
if not ErrorLevel  ; Successfully loaded.
{
    Sort, Contents
    FileAppend, %Contents%, C:\temp\AHK\Research\UsernameResultsSorted.txt
    Contents =  ; Free the memory.
}

EndTime = %A_Now%
EnvSub, EndTime, %StartTime%, S
MsgBox It took this long, %EndTime%