#! python3
# OutlookMB.py - Connects to the SharedMBName@Outlook.com mailbox and retrieves inbox emails
# Usues COM objects to connect to Outlook and the Shared MB

import win32com.client
import time
import win32gui
import win32con
import win32console
import sys
import os

#if an error occurs, it should be displayed using the below function
def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1)
sys.excepthook = show_exception_and_exit

#make window always on top and moves it to bottom right corner of top right monitor
win32console.SetConsoleTitle("MB-SharedMBName")
hwnd = win32gui.GetForegroundWindow()
win32gui.SetWindowPos(hwnd,win32con.HWND_TOPMOST,3171,-346,669,346,0)

#connects with outlook and makes a connection to the shared mailbox
outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
SharedMB = outlook.CreateRecipient("SharedMBName@Outlook.com")
MB_inbox = outlook.GetSharedDefaultFolder(SharedMB, 6)
#6 is for inbox. Link below has more options
#https://docs.microsoft.com/en-us/office/vba/api/outlook.namespace.getshareddefaultfolder

#prints the current date and time, then displays the sender, subject, and send time of each email
#closes once it becomes 5 since im no longer here working 
#sleeps for 5 minutes between each iteration 
while time.localtime().tm_hour is not 17:
	print(time.strftime('%b%d - %I:%M%p',time.localtime()))
	print('Currently there are', MB_inbox.UnreadItemCount, 'unread emails')
	for emails in MB_inbox.Items:
		time_send = (str(emails.SentOn).split('+', 1)[0]).rjust(20)
		email_sender = str(emails.Sender).ljust(40)
		print('>', email_sender, '--', time_send)
		print('>>>>>', emails.Subject[:72])
	print('\n')
	time.sleep(300) 
