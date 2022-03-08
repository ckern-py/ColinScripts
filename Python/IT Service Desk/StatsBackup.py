#! python3
# StatsBackup.py - Used to create weekly backup folders for the AHK state files located in \\Removed\name\of\server\ITSDUtil Stats
# Will parse the files and copy them to the corresponding folder with date format YYYYMMDD

import os
import re
import shutil
import datetime
import time
import sys

#if an error occurs, it should be displayed using the below function
def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1) 
sys.excepthook = show_exception_and_exit

movedUserFiles = 0

os.chdir(r'\\Removed\name\of\server\ITSDUtil Stats')

nameAndDate = re.compile(r'''
	(\w+\d+-{1})			    #user name with hyphen(-)
	(\d{8})						#date for week stat
	(\.ini)						#file extension, all .ini files
	''', re.VERBOSE)

try:
	with open('.\\Backup\\LastRunTime.txt') as ranDate:
		runTime = ranDate.read()
	print('Only doing files modified after ' + str(datetime.datetime.fromtimestamp(float(runTime))))
except (OSError, FileNotFoundError) as e:
	runTime = 151260
	print('File not found, or didn\'t open. Doing all files \nAlso error:' + str(e))
runTime = float(runTime)

with open('.\\Backup\\LastRunTime.txt', 'w+') as lastRan:
	lastRan.write(str(time.time()))

print('Going through files')
for statFiles in os.listdir('.'):
	if os.path.getmtime(statFiles) > runTime:
		mo = nameAndDate.search(statFiles)
		if mo is None:
			continue
		userName = mo.group(1)
		dateOnFile = mo.group(2)
		if os.path.isdir('.\\Backup\\' + dateOnFile + ' Backup Files'):
			pass
		else:
			print('Creating ' + dateOnFile + ' Folder')
			os.makedirs('.\\Backup\\' + dateOnFile + ' Backup Files')
		shutil.copy2('.\\' + statFiles ,'.\\Backup\\' + dateOnFile + ' Backup Files')
		print('Moving: ' + statFiles)
		movedUserFiles += 1


print('Done Running')

print('Moved ' + str(movedUserFiles) + ' user files')

input("Press Enter to Close")