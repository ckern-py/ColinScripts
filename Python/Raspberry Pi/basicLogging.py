import os
import datetime

loggingLocation = "/home/RaspberryPi/Documents/Python/Scripts/Logging/"
loggingExt = ".log"

def writeLog(logLocation, logMsg):
    strLogMsg = str(logMsg)
    currDT = datetime.datetime.now().strftime("%Y%m%d %H:%M:%S.%f")
    with open(logLocation, "a+") as logFile:
        logFile.write('\n')
        logFile.write(currDT + "|" + strLogMsg)

def checkMakeFile(checkFileName):
    fileBaseName = os.path.basename(checkFileName)
    fileNoExt = fileBaseName.partition(".")[0]
    logFileName = str(datetime.date.today()) + fileNoExt
    fullPath = loggingLocation + logFileName + loggingExt
    if not os.path.exists(fullPath):
        os.mknod(fullPath)
    return fullPath

def mainLogging(callingFile, msgToLog):
    fullLogLocation = checkMakeFile(callingFile)
    writeLog(fullLogLocation, msgToLog)
    