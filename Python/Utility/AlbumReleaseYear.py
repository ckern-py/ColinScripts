#! python 3
# AlbumReleaseYear.py - Go through music I have and find the year each album was released

import os
import re
import shutil
import requests
import bs4

###Google search for year album was released###
searchReleaseDate = re.compile(r'(R|r)elease(d)? (on )?(\w*) (\d{1,2},) (\d{4})')
folderCut = re.compile(r'(.*?)(\s?\(|\[.*?)(.*)')
for Folders in os.listdir('.'):
    folderTrim = folderCut.search(Folders)
    if folderTrim == None:
        searchName = Folders
    else:
        searchName = folderTrim.group(1)
    print('Getting ' + str(searchName))
    googleSearch = requests.get('https://www.google.com/search?q=' + searchName.replace(' ', '+') + '+release+date')
    if googleSearch.status_code != 200:
        print(googleSearch.status_code + ' for ' + searchName)
        continue
    searchSoup = bs4.BeautifulSoup(googleSearch.text, features="html.parser")
    foundRelease = searchSoup.find(string=re.compile('(R|r)elease(d)? (on )?(\w*) (\d{1,2},) (\d{4})'))
    theYearWas = searchReleaseDate.search(str(foundRelease))
    if theYearWas == None:
        print('Release year not found')
        continue
    foundYear = theYearWas.group(6)
    print('Released: ' + foundYear)
    nameWithYear = searchName + ' [' + foundYear + ']'
    absWorkingDir = os.path.abspath('.')
    oldName = os.path.join(absWorkingDir, Folders)
    changedName = os.path.join(absWorkingDir, nameWithYear)
    print('Renaming "%s" to "%s"...' % (oldName, changedName))
    shutil.move(oldName, changedName) 