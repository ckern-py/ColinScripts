import basicLogging
import basicSendEmail
import requests
import json
import time

def callLog(logMsg):
    basicLogging.mainLogging(__file__, logMsg)
    
requestingDict = {'RequestingSystem':'MyRaspberryPi'}
urlCheckHealth = 'https://myURL/CheckHealth'
urlCheckHealthDB = 'https://myYRL/CheckHealthDB'
headers = {'Content-Type':'application/json'}    

callLog('Start azureCheckHealth')
jsonBody = json.dumps(requestingDict, default = lambda d:d.__dict__)

callLog('Call CheckHealth')
response = requests.post(urlCheckHealth, data=jsonBody, headers=headers)
callLog(f'Returned Status code: {response.status_code}')
if response.status_code != 200:
    emailList = ['CheckHealth failed for Azure API']
    emailList.append(f'Status code: {response.status_code}')
    callLog('Azure CheckHealth Failed')

time.sleep(10)

callLog('Call CheckHealthDB')
response = requests.post(urlCheckHealthDB, data=jsonBody, headers=headers)
callLog(f'Returned Status code: {response.status_code}')
if response.status_code != 200:
    emailList = ['CheckHealthDB failed for Azure API']
    emailList.append(f'Status code: {response.status_code}')
    callLog('Azure CheckHealthDB Failed')
    
if 'emailList' in locals():
    basicSendEmail.custEmailMessage(emailList)
    
callLog('End azureCheckHealth')