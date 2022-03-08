#! python3
# UserNameResearch.py - Used to find the length of all users with a computer
# Reads file from C:\\Users\\Me\\My Documents\\AHK\\Research\\Users_and_Computers.txt

import os, time

start = time.time()
os.chdir('C:\\Users\\Me\\My Documents\\AHK\\Research')
results = open('PythonResults.txt', 'w')
count = 0

with open('C:\\Users\\Me\\My Documents\\AHK\\Research\\Users_and_Computers.txt') as unf:
	for line in unf:
		foundID = line.split(',', maxsplit = 1)
		results.write(str(len(foundID[0])) + '-' + foundID[0] + '\n')
		count += 1
		if (count % 1000 == 0):
			print('Currently at: ' + str(count))
print('Done parsing, now sorting')
results.close()
sortResults = open('SortedPythonResults.txt', 'w')
with open('C:\\Users\\Me\\My Documents\\AHK\\Research\\PythonResults.txt') as parse:
	for line in sorted(parse):
		sortResults.write(line)
sortResults.close()
print('It took {0:0.5f} seconds'.format(time.time() - start))