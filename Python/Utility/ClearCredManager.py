#! python3
# ClearCredManager.py - Clears Credential Manager of certain keys
# This will clear Cred Manager of all keys relating to MicrosoftOffice and msteams

#import of system, win32cred python API wrapper, and regex
import sys
import win32cred
import re

#if an error occurs, it should be displayed using the below function
def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1)
sys.excepthook = show_exception_and_exit

#regex for Teams and Office, anything can follow those words
teams_re = re.compile('msteams.*', re.I)
office_re = re.compile('microsoftoffice.*', re.I)
    
#goes throguh all the creds and if a regex match is found it is deleted and message is displayed on screen
for found_cred in win32cred.CredEnumerate():
	if teams_re.match(found_cred['TargetName']) or office_re.match(found_cred['TargetName']):
		print('Deleting', found_cred['TargetName'])
		win32cred.CredDelete(found_cred['TargetName'], 1, 0)