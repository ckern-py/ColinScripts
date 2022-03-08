import smtplib
import basicLogging

from email.message import EmailMessage
from email.headerregistry import Address

def checkListJoin(listMsg):
    if isinstance(listMsg, list):
        joinedMsg = '.\n'.join(map(str, listMsg))
    else:
        joinedMsg = listMsg
    return f'{joinedMsg}.'

def callLog(logMsg):
    basicLogging.mainLogging(__file__, logMsg)

def custEmailMessage(emailMsg):
    callLog("Sending email")
    callLog(emailMsg)
        
    msg = EmailMessage()
    msg['From'] = Address("Raspberry Pi", "My.Raspberry.Pi", "gmail.com")
    msg['To'] = Address("My Name", "PersonalEmail", "gmail.com")
    msg['Subject'] = 'Automated Email'
    
    joinedMsg = checkListJoin(emailMsg)
    msg.set_content(joinedMsg)    

    username = 'My.Raspberry.Pi@gmail.com'
    password = 'SuperSecretPassword123!'

    server = smtplib.SMTP('smtp.gmail.com:587')
    server.starttls()
    server.login(username, password)
    server.send_message(msg)
    server.quit()
    
    callLog("Email sent")