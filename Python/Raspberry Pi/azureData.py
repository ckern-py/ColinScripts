import calendar
import json
import datetime
import basicLogging
import basicSendEmail
import requests

class DataObject:
    def __init__ (self, calDay, calWeekday, dataIn, dataOut):
        self.calDay = calDay
        self.calWeekday = calWeekday
        self.dataIn = dataIn
        self.dataOut = dataOut

class DataTotal:
    def __init__ (self, calMonth, calYear, totalDataIn, totalDataOut):
        self.calMonth = calMonth
        self.calYear = calYear
        self.totalDataIn = totalDataIn
        self.totalDataOut = totalDataOut
        
def callLog(logMsg):
    basicLogging.mainLogging(__file__, logMsg)
    
def getLastMonth():
    callLog('Start getLastMonth')
    today = datetime.date.today()
    if today.month == 1:
        lastMonth = today.replace(month = 12, year = today.year - 1)
    else:
        lastMonth = today.replace(month = today.month - 1)
    callLog('End getLastMonth')
    return lastMonth

def getDaysInMonth(dtLastMonth):
    callLog('Start getDaysInMonth')
    monthDays2 = calendar.Calendar().itermonthdays2(dtLastMonth.year, dtLastMonth.month)
    onlyMonthDays = filter(lambda x : x[0] != 0, monthDays2)
    callLog('End getDaysInMonth')
    return onlyMonthDays

def getDataTotal(lastIndex, lastMonthDate):
    callLog('Start getDataTotal')
    totalIn, totalOut = lastIndex.strip('[]').split(':')
    objDataTotal = DataTotal(lastMonthDate.month, lastMonthDate.year, int(totalIn), int(totalOut))
    callLog('End getDataTotal')
    return objDataTotal

def getDataObject(daysInMonth, splitTraffic):
    callLog('Start getDataObject')
    dataInfoList = []
    for index, days in enumerate(daysInMonth):
        dataIn, dataOut = splitTraffic[index].split(':')
        objDataObject = DataObject(days[0], days[1], int(dataIn), int(dataOut))
        dataInfoList.append(objDataObject)
    callLog('End getDataObject')
    return dataInfoList

def buildJson(stringTraff):
    callLog('Start buildJson')
    finalDataDict = {'DataInfo':'', 'MonthTotal':'', 'RequestingSystem':'MyRaspberryPi'}
    lMonthDate = getLastMonth()
    monthDays = getDaysInMonth(lMonthDate)
    splitTraff = stringTraff.split()
    dataTotalObj = getDataTotal(splitTraff[-1], lMonthDate)
    dataObjectObj = getDataObject(monthDays, splitTraff)
    finalDataDict.update(DataInfo = dataObjectObj)
    finalDataDict.update(MonthTotal = dataTotalObj)
    jsonString = json.dumps(finalDataDict, default = lambda d : d.__dict__)
    callLog('End buildJson')
    return jsonString

def sendToAzure(stringLMTraff):
    callLog('Start sendToAzure')
    jsonLoad = buildJson(stringLMTraff)
    
    url = 'https://myURL/MonthlyDataUsage'
    headers = {'Content-Type' : 'application/json'}
    response = requests.post(url, data=jsonLoad, headers=headers)
    
    if response.status_code != 200:
        response2 = requests.post(url, data=jsonLoad, headers=headers)
        
        if response2.status_code != 200:
            emailList = ['Failed to send monthly data to Azure after two tries']
            emailList.append(f'Status code: {response.status_code} & {response2.status_code}')
            callLog('Send to Azure Failed')
        else:
            emailList = ['Successfully sent monthly data to Azure on second try']
            callLog('Send to Azure Succeeded')
    else:
        emailList = ['Successfully sent monthly data to Azure']
        callLog('Send to Azure Succeeded')
        
    basicSendEmail.custEmailMessage(emailList)
    callLog('End sendToAzure')
