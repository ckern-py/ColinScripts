#! python3
# UtilArchive.py - Creates a copy of all current items in the AutoHotKey folder and places them in the Archive folder
# Only needs to be ran when update is pushed out

import os
import shutil
import sys
import datetime
import fnmatch
import time

def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1) 
sys.excepthook = show_exception_and_exit

today_formatted = (datetime.date.today()).strftime('%Y%m%d')
os.chdir(r'C:\Users\Me\Documents\ITSD Scripts\AutoHotKey')
archive_location = os.getcwd() + '\Archive'

start_time = time.time()


#Shell gave Thumbs.db copy error. Do someting about it, skip?
print('Moving Data to Archive')
try:
	shutil.copytree(os.getcwd() + '\\Data', archive_location + '\\Prod\\' + today_formatted + '\\Data')
except:
	print('Skipping someting, due to error')
	

print('Moving Editor to Archive')
try:
	shutil.copytree(os.getcwd() + '\\Editor', archive_location + '\\Prod\\' + today_formatted + '\\Editor')
except:
	print('Skipping someting, due to error')


print('Moving Prod files to Archive')
for prod_main in os.listdir(os.getcwd()):
	if fnmatch.fnmatch(prod_main, '*.*'):
		shutil.copy2(os.path.abspath(prod_main), archive_location + '\\Prod\\' + today_formatted + '\\' + prod_main)
		

print('Moving Demo files to Archive')		
try:
	shutil.copytree(os.getcwd() + '\\Demo', archive_location + '\\Demo\\' + today_formatted)
except:
	print('Skipping someting, due to error')
	

print('Moving Dev files to Archive')
try:
	shutil.copytree(os.getcwd() + '\\Dev', archive_location + '\\Dev\\' + today_formatted)
except:
	print('Skipping someting, due to error')
	
	
print('Finished running backup in {0:0.2f} seconds'.format(time.time() - start_time))
input("Done: Press Enter to Close")