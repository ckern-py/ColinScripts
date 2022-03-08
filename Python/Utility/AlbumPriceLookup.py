#! python 3
# AlbumPriceLookup.py - Looks up the price of albums that I'm still looking to buy and returns them in a list
# Reads the file for albums, Looks up the prices on each website

import re
import bs4
import requests
import os
#import openpyxl
import time
import random

##places to search
# barnes and noble
# newegg
# target
# walmart
# amazon


##Barnes and Noble##
#album title then artist separated by dashes, but search with + separator and maybe include CD
bnSearchBase = 'https://www.barnesandnoble.com/s/' #This seems to redir when a match is found

##Newegg##
#inseart search in the middle with spaces, or %20, as shown on home computer???
neweggSearchBeg = 'https://www.newegg.com/Product/ProductList.aspx?Submit=ENE&N=100877008&IsNodeId=1&bop=And&ActiveSearchResult=True&SrchInDesc='
#SEARCH%20TERM%20HERE
neweggSearchEnd = '&Page=1&PageSize=36&order=BESTMATCH'
#if nothing found, <span class="result-message-error">We have found 0 items that match "your search".</span>
#class="item container" for first result if found

##Target##
#movies, music & book category. Search terms following separted by +
targetSearchBeg = 'https://www.target.com/s?sortBy=relevance&Nao=0&category=5xsxe&searchTerm='
#[TERM+TERM]
targetSearchEnd = '&facetedValue=5zk8u'

##FYE##
fyeSearchBase = 'https://www.fye.com/search?q='
#[TERM+TERM]
fyeHeader = {'User-Agent':'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36'}
#if only one redir to page

##amazon##
amazonSearch = 'https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Dpopular&field-keywords='
#[TERM+TERM]
amazonHeader = {'User-Agent':'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36'}
#search for first href with CD title in link??

#Mozilla/5.0 (Windows NT 6.3; Win64; x64; rv:65.0) Gecko/20100101 Firefox/65.0
urlHeader = {'User-Agent':'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36'}

## Barns and Noble URL Research ##
with open('C:\\User\\Music\\Albums\\Looking CD.txt', 'r') as stillSearching:
    bnURLResults = open('C:\\User\\Music\\Albums\\CD BN URLs.txt', 'w')
    for albumFound in stillSearching:
        albumFound = albumFound.rstrip()
        noYear = albumFound.split(' [')
        dashPart = noYear[0].partition(' - ')
        artistLast = dashPart[2] + ' ' + dashPart[0]
        searchTerm = artistLast.replace(' ', '+')
        fullBNURL = bnSearchBase + searchTerm + '+cd'
        #print(fullBNURL)
        bnSearchAttempt = requests.get(fullBNURL)
        if bnSearchAttempt.status_code != 200:
            bnURLResults.write(str(albumFound + ' :: ' + 'Code: ' + bnSearchAttempt.status_code + '\n'))
            continue
        if bnSearchAttempt.url != fullBNURL:
            if 'noresults' in bnSearchAttempt.url:
                bnURLResults.write(albumFound + ' :: ALBUM NOT FOUND IN SEARCH\n')
                continue
            urlFirstPart = (bnSearchAttempt.url).partition(';')
            bnURLResults.write(albumFound + ' :: ' + urlFirstPart[0] + '\n')
        else:
            bnURLResults.write(albumFound + ' :: ' + bnSearchAttempt.url + '\n')
        print(albumFound)
bnURLResults.close()

## Barnes and Noble Price Retreiver ##
bAndNPrice = re.compile(r'\$(\d{1,2}\.\d{1,2})')
secondChance = re.compile(r'(?:C|c)urrent price is \$(\d{1,2}\.\d{1,2})')
with open('C:\\User\\Music\\Albums\\CD Barns Noble URLs.txt', 'r') as bnURLsFound:
    bnPriceResults = open('C:\\User\\Music\\Albums\\CD BN Price.txt', 'w')
    for albumURL in bnURLsFound:
        print(albumURL.partition(' :: ')[:1])
        if 'ALBUM NOT FOUND' in albumURL:
            bnPriceResults.write('$00.00' + ' :: ' + albumURL)
            continue
        justURL = albumURL.partition(' :: ')
        bnAlbumRequest = requests.get(justURL[2].rstrip())
        if bnAlbumRequest.status_code != 200:
            print(str(justURL[0] + ' :: Code: ' + str(bnAlbumRequest.status_code) + '\n'))
            continue
        albumSoup = bs4.BeautifulSoup(bnAlbumRequest.text, features="html.parser")
        priceSearch = albumSoup.find(class_='format-price')
        foundPrice = bAndNPrice.search(str(priceSearch))
        if foundPrice == None:
            secondPriceSearch = albumSoup.find(id="adaLabel")
            foundPrice = secondChance.search(str(secondPriceSearch))
        try:
            dispPrice = float(foundPrice.group(1))
        except:
            dispPrice = 0
        bnPriceResults.write('${:05.2f}'.format(dispPrice) + ' :: ' + albumURL)
    bnPriceResults.close()

## Newegg URL Retriever ##
with open('C:\\User\\Music\\Albums\\Looking CD.txt', 'r') as neweggSearch:
    neweggURLResults = open('C:\\User\\Music\\Albums\\CD Newegg URLs.txt', 'w')
    for albumLooking in neweggSearch:
        searchNoLineReturn = albumLooking.rstrip()
        albumNoYear = searchNoLineReturn.split(' [')
        albumNoDash = albumNoYear[0].replace(' -', '')
        searchURLInsert = albumNoDash.replace(' ', '%20')
        #print(searchURLInsert)
        fullNeweggURL = neweggSearchBeg + searchURLInsert + neweggSearchEnd
        #print(fullBNURL)
        neweggSearchAttempt = requests.get(fullNeweggURL)
        if neweggSearchAttempt.status_code != 200:
            neweggURLResults.write(str(searchNoLineReturn + ' :: ' + 'Code: ' + neweggSearchAttempt.status_code + '\n'))
            continue
        neweggSearchText = bs4.BeautifulSoup(neweggSearchAttempt.text, features="html.parser")
        try:
            foundURL = neweggSearchText.find(class_="item-img")['href']
        except TypeError:
            isItNotFound = neweggSearchText.find(class_="result-message-error")
            if '0 items' in str(isItNotFound):
                foundURL = 'ALBUM NOT FOUND IN SEARCH'
            else:
                foundURL = 'PROBABLY CALLED A BOT ' + fullNeweggURL
        neweggURLResults.write(searchNoLineReturn + ' :: ' + foundURL + '\n')
        neweggSleep = random.randrange(5, 10)
        print(searchNoLineReturn + ' - ' + str(neweggSleep))
        time.sleep(neweggSleep)
neweggURLResults.close()

## Newegg Price Retreiver ##
with open('C:\\User\\Music\\Albums\\CD Newegg URLs.txt', 'r') as neweggURLsFound:
    neweggPriceResults = open('C:\\User\\Music\\Albums\\CD Newegg Price.txt', 'w')
    for albumURL in neweggURLsFound:
        print(albumURL.partition(' :: ')[:1])
        if 'ALBUM NOT FOUND' in albumURL:
            neweggPriceResults.write('$00.00' + ' :: ' + albumURL)
            continue
        justURL = albumURL.partition(' :: ')
        neweggAlbumRequest = requests.get(justURL[2].rstrip(), headers = urlHeader)
        if neweggAlbumRequest.status_code != 200:
            print(justURL[0], ':: Code: ', neweggAlbumRequest.status_code)
            continue
        albumSoup = bs4.BeautifulSoup(neweggAlbumRequest.text, features="html.parser")
        neweggPriceSearch = float(albumSoup.find(itemprop='price')['content'])
        neweggPriceResults.write('${:05.2f}'.format(neweggPriceSearch) + ' :: ' + albumURL)
        time.sleep(random.randrange(5, 10))
    neweggPriceResults.close()

## FYE URL getter ##
with open('C:\\User\\Music\\Albums\\Looking CD.txt', 'r') as stillSearching:
    fyeURLResults = open('C:\\User\\Music\\Albums\\CD FYE URLs.txt', 'w')
    for albumFound in stillSearching:
        albumFound = albumFound.rstrip()
        noYear = albumFound.split(' [')
        dashPart = noYear[0].replace(' - ', ' ', 1)
        searchTerm = dashPart.replace(' ', '+')
        fullFYEURL = fyeSearchBase + searchTerm
        #print(fullFYEURL)
        fyeSearchAttempt = requests.get(fullFYEURL, headers = fyeHeader)
        if fyeSearchAttempt.status_code != 200:
            fyeURLResults.write(str(albumFound + ' :: ' + 'Code: ' + fyeSearchAttempt.status_code + ' :: ' + fyeSearchAttempt.url +'\n'))
            continue
        fyeURLResults.write(albumFound + ' :: ' + fyeSearchAttempt.url + '\n')
        print(albumFound)
fyeURLResults.close()

## FYE Price Retreiver ##
fyePrice = re.compile(r'\$(\d{1,2}\.\d{2})')
with open('C:\\User\\Music\\Albums\\CD FYE URLs.txt', 'r') as fyeURLsFound:
    fyePriceResults = open('C:\\User\\Music\\Albums\\CD FYE Price.txt', 'w')
    for albumFYEURL in fyeURLsFound:
        print(albumFYEURL.partition(' :: ')[:1])
        if 'ALBUM NOT FOUND' in albumFYEURL:
            fyePriceResults.write('$00.00' + ' :: ' + albumFYEURL)
            continue
        justTheURL = albumFYEURL.partition(' :: ')
        fyeAlbumRequest = requests.get(justTheURL[2].rstrip(), headers = urlHeader)
        if fyeAlbumRequest.status_code != 200:
            print(justTheURL[0] + ' :: ' + 'Code: ' + str(fyeAlbumRequest.status_code) + '\n')
            continue
        fyeAlbumSoup = bs4.BeautifulSoup(fyeAlbumRequest.text, features="html.parser")
        fyePriceSearch = fyeAlbumSoup.find(class_="c-product-details__price")
        theBFYFoundPrice = fyePrice.search(str(fyePriceSearch))
        displayPrice = float(theBFYFoundPrice.group(1))
        fyePriceResults.write('${:05.2f}'.format(displayPrice) + ' :: ' + albumFYEURL)
    fyePriceResults.close()


## Amazon URL getter ##
zeroResRe = re.compile(r'href=\"(.*?)\"')
with open('C:\\User\\Music\\Albums\\Looking CD.txt', 'r') as amGettingAlbums:
    amazonURLs = open('C:\\User\\Music\\Albums\\CD Amazon URLs.txt', 'w')
    for amAlbum in amGettingAlbums:
        albumStrip = amAlbum.rstrip()
        noYear = albumStrip.split(' [')
        noDashPart = noYear[0].replace(' - ', ' ', 1)
        allPlus = noDashPart.replace(' ', '+')
        print(allPlus)
        amazonFullURL = amazonSearch + allPlus + '+cd'
        amazonFind = requests.get(amazonFullURL, headers = amazonHeader)
        if amazonFind.status_code != 200:
            fyeURLResults.write(str(amAlbum + ' :: ' + 'Code: ' + amazonFind.status_code + ' :: ' + amazonFind.url +'\n'))
            continue
        amazonText = bs4.BeautifulSoup(amazonFind.text)
        firstSearch = amazonText.find(id="result_0")
        theURL = zeroResRe.search(str(firstSearch))
        if theURL == None:
            amazonURLs.write(albumStrip + ' :: ' + 'NOT FOUND ' + amazonFullURL + '\n')
            continue
        retURL = theURL.group(1)
        bestPart = retURL.split('?')
        amazonURLs.write(albumStrip + ' :: ' + bestPart[0] + '\n')
    amazonURLs.close()

## Amazon Price Retreiver ##
with open('C:\\User\\Music\\Albums\\CD Amazon URLs.txt', 'r') as amazonURLsFound:
    amazonPriceResults = open('C:\\User\\Music\\Albums\\CD Amazon Price.txt', 'w')
    for albumAmazonURL in amazonURLsFound:
        print(albumAmazonURL.partition(' :: ')[:1])
        if 'ALBUM NOT FOUND' in albumAmazonURL:
            amazonPriceResults.write('$00.00' + ' :: ' + albumAmazonURL)
            continue
        justTheURL = albumAmazonURL.partition(' :: ')
        amazonAlbumRequest = requests.get(justTheURL[2].rstrip(), headers = urlHeader)
        if amazonAlbumRequest.status_code != 200:
            print(justTheURL[0] + ' :: Code: ' + str(amazonAlbumRequest.status_code) + '\n')
            amazonPriceResults.write("$00.00 :: " + albumAmazonURL)
            continue
        amazonAlbumSoup = bs4.BeautifulSoup(amazonAlbumRequest.text)
        try:
            amazonPriceSearch = amazonAlbumSoup.find(class_="a-size-base a-color-price a-color-price").text
        except AttributeError:
            amazonPriceResults.write("$00.00 :: " + albumAmazonURL)
            continue
        priceStrip = amazonPriceSearch.strip()
        amazonPriceResults.write(priceStrip + " :: " + albumAmazonURL)
    amazonPriceResults.close()
