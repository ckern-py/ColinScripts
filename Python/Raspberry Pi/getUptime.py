# File is executed 15 minutes after a reboot to see if it was successful.

import datetime
import basicSendEmail
import basicLogging

def getThisUptime():
    with open('/proc/uptime', 'r') as f:
        uptimeSeconds = float(f.readline().split()[0])
    return uptimeSeconds

def callLog(logMsg):
    basicLogging.mainLogging(__file__, logMsg)

currUpTime = getThisUptime()

if currUpTime > 900:
    rebootStatus = "Reboot failed"
    curUpMsg = "Current uptime is " + str(datetime.timedelta(seconds=currUpTime))
else:
    rebootStatus = "Reboot seccessful"
    curUpMsg = "The reboot took " + str(datetime.timedelta(seconds=(900-currUpTime)))

callLog(rebootStatus)

callLog(curUpMsg)

emailList = [rebootStatus, curUpMsg]

callLog("Sending email")
basicSendEmail.custEmailMessage(emailList)
callLog("Email sent")