
#! python3
#SpotifyClean.py
#Walk the spotify data folder. Remove folders with mod date greater than 10 and files with mod date greater than 14

import os
import sys
import time

#if an error occurs, it should be displayed using the below function
def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1)
    
def true_folder_size(folder_to_walk):
	total_size = 0
	for found_file in os.listdir(folder_to_walk):
		joined_path = os.path.join(folder_to_walk, found_file)
		file_size = os.path.getsize(joined_path)
		total_size += file_size
	return total_size
    
sys.excepthook = show_exception_and_exit

os.chdir(r'C:\Users\Me\AppData\Local\Spotify\Data')

now_seconds = time.time()
folders_removed = 0
files_removed = 0 
spotify_space = 0
file_space = 0

print('\nChecking Spotify Folders')

for spot_folder in os.listdir(os.getcwd()):
	full_join = os.path.join(os.getcwd(), spot_folder)
	time_diff = (now_seconds - os.path.getmtime(full_join))/86400
	if time_diff > 10:
		location_size = true_folder_size(spot_folder)
		spotify_space += location_size
		os.remove(spot_folder)
		folders_removed += 1
		print('Removed folder:', spot_folder)
	
spotify_space = spotify_space/1048576

print('Removed {0} Spotify folders, saving {1:0.2f} MBs of space'.format(folders_removed, spotify_space))


print('\nNow checking Spotify Files')

for top, folder, files in os.walk(os.getcwd()):
	for ind_file in files:
		file_join = os.path.join(top, ind_file)
		time_diff_f = (time.time() - os.path.getmtime(file_join))/86400
		if time_diff_f > 14:
			file_space += os.path.getsize(file_join)
			os.remove(file_join)
			files_removed += 1

file_space = file_space/1048576

print('Removed {0} Spotify files, saving {1:0.2f} MBs of space'.format(files_removed, file_space))
print('\nRan through everything in {0:0.2f} seconds'.format(time.time()-now_seconds))
input("\nDone: Press Enter to Close")

