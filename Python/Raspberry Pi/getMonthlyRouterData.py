import sshRouter
import basicLogging
import basicSendEmail
import datetime
import azureData

nvramGet = "nvram get "
traff = "traff-"
allTraffMonthly = "/home/RaspberryPi/Documents/TrafficData/TrafficMonthly.txt"

def callLog(logMsg):
    basicLogging.mainLogging(__file__, logMsg)
    
def writeToFile(incomingData):
    newFile = f"/home/RaspberryPi/Documents/TrafficData/{lastMonthTraff}.txt"
    fileShareLoc = f"/mnt/location/on/ssd/TrafficData/{lastMonthTraff}.txt"
    with open(newFile, 'w') as nf:
        nf.write(lastMonthTraff + "\n" + incomingData)
    with open(fileShareLoc, 'w') as fsl:
        fsl.write(lastMonthTraff + "\n" + incomingData)
    with open(allTraffMonthly, 'a') as tm:
        tm.write(f'{lastMonthTraff}={incomingData}\n\n')

def totalFromData(wholeDataTraff):
    splitList = wholeDataTraff.split(' ')
    totalIn, totalOut = splitList[-1].split(':')
    totalIn = totalIn.strip('[]')
    totalOut = totalOut.strip('[]')
    return totalIn, totalOut

def highLowDataDays(allDataTraffic):
    tempHigh = 0
    tempLow = 99999999
    highestDay = ''
    lowestDay = ''
    for index, data in enumerate(allDataTraffic.split(), start=1):
        try:
            currInt = int(data.split(':')[0])
        except:
            pass
        if currInt > tempHigh:
            tempHigh = currInt
            highestDay = f'{index} - {tempHigh}'
        if currInt < tempLow:
            tempLow = currInt
            lowestDay = f'{index} - {tempLow}'
    return highestDay, lowestDay
    
    
callLog("Starting")

today = datetime.date.today()
if today.month == 1:
    lastMonth = today.replace(month=12, year=today.year -1).strftime("%m-%Y")
    monthFull = today.replace(month=12, year=today.year -1).strftime("%B")
else:
    lastMonth = today.replace(month=today.month-1).strftime("%m-%Y")
    monthFull = today.replace(month=today.month-1).strftime("%B")
    
lastMonthTraff = traff + lastMonth
lastMonthTraffCommand = nvramGet + lastMonthTraff
    
callLog("Sending SSH command")    
monthlyTraffic = sshRouter.sshCommand(lastMonthTraffCommand)
callLog("SSH results returned")

emailList = [f'Traffic data for last month, {monthFull} {today.year}']

callLog("Writing to file")
writeToFile(monthlyTraffic)
callLog("File written")

callLog('Sending to Azure')
azureData.sendToAzure(monthlyTraffic)
callLog('Sent to Azure')

emailList.append("Summary of data")
dataIn, dataOut = totalFromData(monthlyTraffic)
emailList.append(f'Total Data In: {dataIn} Mb ({dataIn[:-3]}.{dataIn[-3:]} GB)')
emailList.append(f'Total Data Out: {dataOut} Mb ({dataOut[:-3]}.{dataOut[-3:]} GB)')

highest, lowest = highLowDataDays(monthlyTraffic)
emailList.append(f'Highest Day: {monthFull} {highest} Mb')
emailList.append(f'Lowest Day: {monthFull} {lowest} Mb')

emailList.append('Additional details available in the folder')

callLog("Sending email")
basicSendEmail.custEmailMessage(emailList)
callLog("Email sent")