#! python 3
# FLACMetadataChange.py - Change the metadata, name, properties, and more for FLAC files

import os
import re
import shutil
import requests
import bs4
import fnmatch
import eyed3
import fnmatch
from mutagen.flac import FLAC
eyed3.log.setLevel("ERROR")

#FLAC metadata changer##
curAlbum = "Bassnectar - Unlimited [2016]"
special = "\\Unlimited [2016] [FLAC]"
musicType = 'Electronic'
os.chdir('C:\\Users\\Music\\Albums\\' + curAlbum + special)
totalTracks = 0
for flac_files in os.listdir('.'):
    if fnmatch.fnmatch(flac_files, '*.flac'):
        totalTracks += 1
print(musicType, totalTracks)
albumSplit = re.compile(r'(.*) - (.*) \[(\d{4})\]')
nameSplitOut = re.compile(r'(\d{2}) - (.*)(\.(?:\w|\d){3,4})')
artistBreak = albumSplit.search(curAlbum)
curArtist = artistBreak.group(1)
foundAlbum = artistBreak.group(2)
theYear = artistBreak.group(3)
for bassFiles in os.listdir('.'):
    onlyFLAC = nameSplitOut.search(bassFiles)
    if onlyFLAC is None:
        continue
    trackNum = onlyFLAC.group(1)
    trackName = onlyFLAC.group(2)
    bassyMusic = FLAC(bassFiles)
    bassyMusic.clear()
    bassyMusic['genre'] = musicType
    bassyMusic['date'] = theYear
    bassyMusic['album'] = foundAlbum
    bassyMusic['albumartist'] = curArtist
    bassyMusic['band'] = curArtist
    bassyMusic['title'] = trackName
    bassyMusic['artist'] = curArtist
    bassyMusic['tracknumber'] = trackNum
    bassyMusic['tracktotal'] = str(totalTracks)
    bassyMusic.save()
    print('Saved ' + bassFiles)