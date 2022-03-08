#! python3
#CapitalizeFileNames.py - Used to capitalize name of files located in C:\\Users\\Me\\My Documents\\User Things

import os

os.chdir('C:\\Users\\Me\\My Documents\\User Things')

for topFolder, subFolder, files in os.walk('.'):
	print('Now on TopFolder: ' + topFolder)
	for subF in subFolder:
		print('working on SubFolder: ' + subF)
		fileParts = ''
		difParts = subF.split() 
		for partStrings in difParts:
			if partStrings[0].isupper() or partStrings[0].isnumeric():
				pass
			else:
				partStrings = partStrings.capitalize()
			fileParts = fileParts + ' ' + partStrings
		fileParts = fileParts.lstrip()
		workingDir = os.path.abspath('.')
		oldName = os.path.join(workingDir, subF)
		newName = os.path.join(workingDir, fileParts)
		os.rename(oldName, newName)
		print('Changed: %s from: %s' % (newName, oldName))
		print('')
	for foundFiles in files:
		print('Working on ' + foundFiles)
		newParts = ''
		sepParts = foundFiles.split() 
		for parts in sepParts:
			if parts[0].isupper() or parts[0].isnumeric():
				pass
			else:
				parts = parts.capitalize()
			newParts = newParts + ' ' + parts
		newParts = newParts.lstrip()
		oldName = os.path.join(topFolder, foundFiles)
		newName = os.path.join(topFolder, newParts)
		os.rename(oldName, newName)
		print('Changed: %s from: %s' % (newName, oldName))
		print('')
