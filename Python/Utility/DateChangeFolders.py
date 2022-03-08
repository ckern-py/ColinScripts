#! python3
# DateChange.py - Used to change the dates on the computer name files located in 'C:\\Users\\Me\\My Documents\\AHK\\Research'
# Will change the files and folders from DDMMYY to YYYYMMDD

import os, shutil, re

os.chdir('C:\\Users\\Me\\My Documents\\AHK\\Research')

findingDigits = re.compile(r'''
	(\d{2})						#date portion of string
	(\d{2})						#month portion of string
	(\d{2})						#year portion of string
	(\s?\w*)					#words after the date
	''', re.VERBOSE)
	
for datesFound in os.listdir('.'):
	mo = findingDigits.search(datesFound)
	if mo == None:
		continue
	
	monthPart = mo.group(1)
	dayPart = mo.group(2)
	yearPart = mo.group(3)
	fileName = mo.group(4)
	
	changedDate = '20' + yearPart + monthPart + dayPart + fileName
	
	absWorkingDir = os.path.abspath('.')
	oldName = os.path.join(absWorkingDir, datesFound)
	newName = os.path.join(absWorkingDir, changedDate)
	
	print('Renameing "%s" to "%s" ' % (oldName, newName))
	print('')
	shutil.move(oldName, newName)
	