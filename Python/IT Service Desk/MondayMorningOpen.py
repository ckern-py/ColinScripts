#!python3
# MondayMorningOpen.py.py - Used to open all the programs that use for my job
# Will open each program, and place it in the given location

import win32gui
import win32process
import subprocess
import time
import sys

#if an error occurs, it should be displayed using the below function
def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1)
sys.excepthook = show_exception_and_exit

#finds the hwnd for each window given the pid. Found online
def get_hwnds_for_pid (pid):
  def callback (hwnd, hwnds):
    if win32gui.IsWindowVisible (hwnd) and win32gui.IsWindowEnabled (hwnd):
      _, found_pid = win32process.GetWindowThreadProcessId (hwnd)
      if found_pid == pid:
        hwnds.append (hwnd)
    return True
    
  hwnds = []
  win32gui.EnumWindows (callback, hwnds)
  return hwnds

#opens each program and moves it to the coordinate provided. Sleeps so windows have enough time to spawn.
def open_and_append(popen_args, shell_bool, program_name, x=None, y=None, w=None, h=None, cflags=0):
	current_program = subprocess.Popen(popen_args, shell = shell_bool, creationflags=cflags)
	print('Opened ' + program_name)
	time.sleep (9)
	for hwnd in get_hwnds_for_pid (current_program.pid):
		print(str(hwnd) + " => " + str(win32gui.GetWindowText(hwnd)))
		if None not in (x, y, w, h):
			try:
				win32gui.MoveWindow(hwnd, x, y, w, h, 1)
				print('Moving and resizing {0}, {1}, {2}, {3}, {4}'.format(program_name, x, y, w, h))
			except:
				print('Cant move ', win32gui.GetWindowText(hwnd))
	time.sleep(1)

#########################################################################

#open 2 links in Firefox to call dashboard
open_and_append(["C:\\Program Files\\Mozilla Firefox\\firefox.exe", "https://calldashboard.website/takecalls", "https://calldashboard.website/dashboard", "-new-window"], False, 'FF calls', 0, -1080, 960, 391)

#Outlook
open_and_append('C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE', False, 'Outlook', 2880, -1080, 960, 1080)

#notepad
open_and_append('C:\\Windows\\System32\\notepad.exe', False, 'Notepad', 2394, -1070, 960, 714)

#personal Dev AHK Toolbar
open_and_append('\\\\Removed\\name\\of\\server\\AutoHotKey\\Dev\\Toolbar_ColinVer.ahk', True, 'AHK Dev')

#taskmanger
open_and_append('C:\\Windows\\System32\\taskmgr.exe', False, 'TaskManager', 0, -732, 414, 459)

#lockout status.exe
open_and_append('C:\\Users\\Me\\Desktop\\lockoutstatus.exe', False, 'Lockout.exe', 0, -358, 1016, 358)

#Cisco Jabber
open_and_append('C:\\Program Files (x86)\\Cisco Systems\\Cisco Jabber\\CiscoJabber.exe', False, 'Jabber', 304, 135, 359, 601)

#HyperSnap
open_and_append('C:\\Program Files (x86)\\HyperSnap 7\\HprSnap7.exe', False, 'HyperSnap', 1920, -700, 903, 700)

#UltraEdit
open_and_append('C:\\Program Files\\IDM Computer Solutions\\UltraEdit\\uedit64.exe', False, 'UltraEdit', 0, 0, 1920, 1040)

#Cherwell
open_and_append(['C:\\Program Files (x86)\\Cherwell Software\\Cherwell Service Management\\Trebuchet.App.exe', '/c', '[Common]Prod'], False, 'Cherwell', 0, 0, 1920, 1040)

#VIP
open_and_append('C:\\Program Files (x86)\\Symantec\\VIP Access Client\\VIPUIManager.exe', False, 'VIP', 1714, 831, 205, 208)

#cmd to open file explorer location
open_and_append(['C:\\Windows\\System32\\cmd.exe', '/K cd /d C:\\Users\\me\\My Documents\\Python\\MyScripts'], True, 'Terminal', 1920, -334, 669, 334, subprocess.DETACHED_PROCESS)

#Configuration Manager Remote Control
open_and_append('\\\\Removed\\name\\of\\server\\RemoteControl\\CmRcViewer.exe', False, 'Remote Control', 2222, 112, 1155, 630)

#Word
open_and_append('C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\WINWORD.EXE', False, 'Word', 2064, -873, 1287, 765)

#AHK Date
open_and_append('C:\\Users\\Me\\My Documents\\AHK\\Date.ahk', True, 'AHK Date')

#look up PS script
open_and_append(['C:\\LSA Programs\\Unlock_Accounts.lnk'], True, 'Unlock', 414, -681, 669, 346, subprocess.DETACHED_PROCESS)

#VDI PS script
open_and_append(['powershell', '\\\\Removed\\name\\of\\server\\GetVMInfo\\GetVMInfo.ps1'], True, 'PS VDI', 205, -458, 669, 334, subprocess.DETACHED_PROCESS)

#contractions AHK
open_and_append('C:\\Users\\Me\\My Documents\\AHK\\Contractions.ahk', True, 'AHK Contractions')

#ADUC
open_and_append('C:\\Users\\Me\\Desktop\\Customer Queries for ADUC.msc', True, 'ADUC', 1920, -1080, 904, 452)

#IE
open_and_append(['C:\\Program Files\\Internet Explorer\\iexplore.exe', 'https://SPNsiteURL.com/_layouts/15/start.aspx'], False, 'IE', 1920, 0, 1920, 1018)

#Python 3.7 shell
open_and_append('C:\\Users\\Me\\AppData\\Local\\Programs\\Python\\Python37\\Lib\\idlelib\\idle.pyw', True, 'Python 3.7.0 Shell', 1251, 0, 669, 662)

#MS Teams
open_and_append(['C:\\Users\\Me\\AppData\\Local\\Microsoft\\Teams\\Update.exe', '--processStart', 'Teams.exe'], False, 'Teams', 1920, -1080, 960, 1080)

#File explorer folder
open_and_append(['C:\\Windows\\explorer.exe', 'C:\\Elevated Programs'], False, 'Elevated Folder')

#Spotify client application
open_and_append('C:\\Users\\Me\\AppData\\Roaming\\Spotify\\Spotify.exe', False, 'Spotify App', 1920, 0, 690, 1080)

input("Press Enter to Close")