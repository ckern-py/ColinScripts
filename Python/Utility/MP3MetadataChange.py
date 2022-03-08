#! python 3
# MP3MetadataChange.py - Change the metadata, name, properties, and more for  mp3 files

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

#Mp3 metadata changer##
artistAlbumYear = 'Mac Miller - Faces [2014]'
justAlbum = '\\Faces [2014] [Mp3]'
musicType = 'Hip Hop'
os.chdir('C:\\Users\\Music\\Albums\\' + artistAlbumYear + justAlbum)
print(os.getcwd())
albumSplit = re.compile(r'(.*) - (.*) \[(\d{4})\]')
nameSplitOut = re.compile(r'(\d{2}) - (.*)(\.(?:\w|\d){3,4})')
artistBreak = albumSplit.search(artistAlbumYear)
curArtist = artistBreak.group(1)
foundAlbum = artistBreak.group(2)
theYear = artistBreak.group(3)
print(musicType + ", " + theYear)
for macFiles in os.listdir('.'):
    onlyMP3 = nameSplitOut.search(macFiles)
    if onlyMP3 is None:
        continue
    trackNum = onlyMP3.group(1)
    trackName = onlyMP3.group(2)
    macAttack = eyed3.load(macFiles)
    macAttack.tag.track_num = int(trackNum)
    macAttack.tag.album = foundAlbum
    macAttack.tag.album_artist = curArtist
    macAttack.tag.artist = curArtist
    macAttack.tag.title = trackName
    macAttack.tag.release_date = theYear
    macAttack.tag.original_release_date = theYear
    macAttack.tag.genre = musicType
    macAttack.tag.comments.set('')
    macAttack.tag.comments.remove 
    macAttack.tag.save(macFiles, version=(2,3,0))
    print('Saved ' + macFiles)