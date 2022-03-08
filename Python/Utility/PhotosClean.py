#! python3
# PhotosClean.py - Removes old HyperSnap saves
# Goes through Pictures>HyperSnap Saves and removes photos that are over a certain age

#import os, system, and time 
import os
import sys
import time
import fnmatch

#if an error occurs, it should be displayed using the below function
def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1)
    
sys.excepthook = show_exception_and_exit

#change working directory to HyperSnap Saves and get current time in seconds from epoch
os.chdir(r'C:\Users\Me\My Pictures\HyperSnap Saves')
now_seconds = time.time()
photos_removed = 0

#go through all the files in the current working directory and get the creation date in seconds from epoch
#subtract photo_creation from now and divide seconds by 86400 since thats how many are in a day
#if the creation date is more than 6 days ago it is removed and a message is printed on screen
for photos in os.listdir(os.getcwd()):
	if fnmatch.fnmatch(photos, '*.png'):
		photo_creation = os.path.getctime(photos)
		photo_age = (now_seconds - photo_creation)/86400
		if photo_age > 6:
			os.remove(photos)
			photos_removed += 1
			print('Removed:', photos)
	    	
print('Finished removing {0} photos in {1:0.2f} seconds'.format(photos_removed, time.time() - now_seconds))

input("Press Enter to Close")