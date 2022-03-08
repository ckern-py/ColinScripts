#! python3
# UserComputerList.py - Parse throught selected excel files, extracting User IDs and computers
# Then puts the found results in a text file, and places the file on the AHK LAN
# Cherwell file headings must be in the following order to work
# WebAll, top four line like below. 4th line, each comma is new column
#1) DescriptionLabelTextbox, DescriptionTextbox						
#2) Description	Displays a list of users and their computers in a single user domain.						
#3)							
#4) Header_Table0_Name0, Header_Table0_Resource_Domain_OR_Workgr0, Header_Table0_User_Name0, Header_Table0_User_Domain0, Details_Table0_Name0, Details_Table0_Resource_Domain_OR_Workgr0, Details_Table0_User_Name0, Details_Table0_User_Domain0

#CWVDI, top line like below, each comma is new column
#1) Asset Status, Asset Tag, Primary User Full Name, Primary User Employee Id, Charged RU, HostName, Resource ID, Manufacturer, Model, Description, Asset Location, Primary Use, SerialNumber, Charged RU, Department Name, IPAddress, Primary User Rec ID, Department ID

#CWCOM, top line like below, each comma is new column
#1) Asset Status, Asset Tag, Computer Type, Primary User Full Name, Primary User Employee Id, Charged RU, HostName, Resource ID, Manufacturer, Model, Asset Location, Primary Use, Serial Number, IP Address, Department ID, Department Name, MAC Address, Description, Expensed or Capitalized

import os
import re 
import csv
import datetime
import operator
import time
import shutil
import sys
import pyautogui

#if an error occurs, it should be displayed using the below function
def show_exception_and_exit(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    input("Press enter to exit.")
    sys.exit(-1)
    
#function to click the approprite buttons in cherwell, and save the file. For VDI and COM
def export_csv(search_image, name_csv):
		sx, sy, _, _ = pyautogui.locateOnScreen('Searching.png')
		pyautogui.click((sx+5), (sy+5))
		vx, vy, _, _ = pyautogui.locateOnScreen(search_image)
		pyautogui.click(vx, vy)
		time.sleep(1)
		fx, fy, _, _ = pyautogui.locateOnScreen('File.png')
		pyautogui.click(fx, fy)
		gx, gy, _, _ = pyautogui.locateOnScreen('Grid.png')
		pyautogui.click(gx, gy)
		pyautogui.typewrite('C:\\Users\\Me\\My Documents\\AHK\\Research\\' + todayFormatDate + ' Files\\' + todayFormatDate + name_csv)
		pyautogui.press('enter')
		time.sleep(5)
		pyautogui.press('enter')
	
sys.excepthook = show_exception_and_exit

pyautogui.PAUSE = 1
pyautogui.FAILSAFE = True
masterUserDict = {}
todayFormatDate = (datetime.date.today()).strftime('%Y%m%d')

os.makedirs('C:\\Users\\Me\\My Documents\\AHK\\Research\\' + todayFormatDate + ' Files', exist_ok=True)

shutil.move('\\\\Removed\\name\\of\\server\\AutoHotKey\\Data\\Domain_Users.csv', 'C:\\Users\\Me\\My Documents\\AHK\\Research\\' + todayFormatDate + ' Files\\' + todayFormatDate + 'WEBALL.csv') 

os.chdir(r'K:\redir\My Documents\My Pictures\HyperSnap Saves\PyStuff')
input("Press Enter To Get Cherwell Files")

start = time.time()
export_csv('VDIs.png', 'CWVDI.csv')
time.sleep(1.5)
export_csv('COMs.png', 'CWCOM.csv')
time.sleep(1.5)

print('Collected Cherwell computers in {0:0.2f} seconds'.format(time.time() - start))
print('Now starting to parse the Cherwell Files')
os.chdir('C:\\Users\\Me\\My Documents\\AHK\\Research\\' + todayFormatDate + ' Files')

#Regex used to pull the user ID from the cherwell csv files
justUserIDre = re.compile(r'.*\((.*)\)')

#gets all the VDIs from the cherwell report 
with open(todayFormatDate + 'CWVDI.csv', newline='') as cherwellVDI:
	vdiFileReader = csv.reader(cherwellVDI)
	vdiList = list(vdiFileReader)
	for v in range(1, len(vdiList)-1):
		vdiUserID = justUserIDre.search(vdiList[v][2])
		if vdiUserID is None:
			print('CWVDI ' + str(v + 1) + ': ' + vdiList[v][2] + '\n')
			continue
		foundVDIUserID = vdiUserID.group(1)
		if not vdiList[v][5] in masterUserDict:
			masterUserDict[vdiList[v][5]] = foundVDIUserID.lower()
		
#gets all the Computers from the cherwell report
with open(todayFormatDate + 'CWCOM.csv', newline='') as cherwellCOM:
	comFileReader = csv.reader(cherwellCOM)
	comList = list(comFileReader)
	for c in range(1, len(comList)-1):
		comUserID = justUserIDre.search(comList[c][3])
		if comUserID is None:
			print('CWCOM ' + str(c + 1) + ': ' + comList[c][3] + '\n')
			continue
		foundCOMUserID = comUserID.group(1)
		if not comList[c][6] in masterUserDict:
			masterUserDict[comList[c][6]] = foundCOMUserID.lower()
		
#SCCM report, adds all computers and VDIs not found from the Cherwell reports
with open(todayFormatDate + 'WEBALL.csv', newline='') as webAll:
	webFileReader = csv.reader(webAll)
	webList = list(webFileReader)
	for w in range(4, len(webList)-1):
		if not webList[w][4] in masterUserDict:
			masterUserDict[webList[w][4]] = (webList[w][6]).lower()
		
sorted_dict = sorted(masterUserDict.items(), key=operator.itemgetter(1))

with open('Users_and_Computers.txt', 'w') as fileMake:
	for key,value in sorted_dict:
		fileMake.write(value + ',' + key + '\n')
		
print('Finished parsing in {0:0.2f} seconds'.format(time.time() - start))

os.makedirs('\\\\Removed\\name\\of\\server\\AutoHotKey\\Data\\Comp BackUp\\' + todayFormatDate, exist_ok=True)
shutil.move('\\\\Removed\\name\\of\\server\\AutoHotKey\\Data\\Users_and_Computers.txt', '\\\\Removed\\name\\of\\server\\AutoHotKey\\Data\\Comp BackUp\\' + todayFormatDate)
shutil.move('\\\\Removed\\name\\of\\server\\AutoHotKey\\Data\\Users_and_Computers_COPY.txt', '\\\\Removed\\name\\of\\server\\AutoHotKey\\Data\\Comp BackUp\\' + todayFormatDate)
shutil.copy2(os.getcwd() + '\\Users_and_Computers.txt',  '\\\\Removed\\name\\of\\server\\AutoHotKey\\Data')
shutil.copy2(os.getcwd() + '\\Users_and_Computers.txt',  '\\\\Removed\\name\\of\\server\\AutoHotKey\\Data\\Users_and_Computers_COPY.txt')

print('Finished everything in {0:0.2f} seconds'.format(time.time() - start))

input("Press Enter to Close")