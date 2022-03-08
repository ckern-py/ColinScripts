#! python3
# DateChange.py - Used to change the dates on the computer name files located in C:\\Users\\Me\\My Documents\\AHK\\Research
# Will change the files and folders from DDMMYY to YYYYMMDD

import os, shutil, re

os.chdir('C:\\Users\\Me\\My Documents\\AHK\\Research')

findingDigits = re.compile(r'''
	(\d{2})						#date portion of string
	(\d{2})						#month portion of string
	(\d{2})						#year portion of string
	(\s?\w*)					#words after the date
	(\..*)						#file extension
	''', re.VERBOSE)
	
for folderName, subfolders, filenames in os.walk(os.getcwd()):
	print('The current folder is ' + folderName)
	for filename in filenames:
		mo = findingDigits.search(filename)
		if mo == None:
			continue
		monthPart = mo.group(1)
		dayPart = mo.group(2)
		yearPart = mo.group(3)
		fileName = mo.group(4)
		fileExt = mo.group(5)
		
		changedDate = '20' + yearPart + monthPart + dayPart + fileName + fileExt
		
		oldName = os.path.join(folderName, filename)
		newName = os.path.join(folderName, changedDate)
		
		print('Changing: ' + oldName + ' to: ' + newName)
		os.rename(oldName, newName)
	print('')
	
	