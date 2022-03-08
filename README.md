# ColinScripts 
This is a repo containing all the different scripts that I have written over the years.

# Description
This repo is a collection of all the different scripts that I have written. The repo is organized so that each language has its own folder. Inside each language folder I have broken down the scripts into subfolders based on where/how they are used. 

## **Python**
Python was one of the first programming languages that I learned. I still occasionally use python for some home projects, such as on my Raspberry Pi. The Python folder is broken down in to three sub folders, IT Service Desk, Utility, and Raspberry Pi.

<u>[IT Service Desk](https://github.com/ckern-py/ColinScripts/tree/main/Python/IT%20Service%20Desk)</u> - These python scrips are ones I used while I was working on the IT Service Desk. These scripts mainly do one of two things. Make common tasks easier or gather data. They were used in addition to the other scrips that are in this repo. 

<u>[Utility](https://github.com/ckern-py/ColinScripts/tree/main/Python/Utility)</u> - These scripts are all based around functionality and being able to do repetitive tasks quickly and with ease. Most of these are scripts you would use on your personal computer to make tasks easier. 

<u>[Raspberry Pi](https://github.com/ckern-py/ColinScripts/tree/main/Python/Raspberry%20Pi)</u> - These scripts are all ones that I run on my Raspberry Pi. I have cron jobs set up to execute them regularly, and notify me via email is something is not correct 

## **AutoHotKey** 
All my AutoHotKey scripts come from when I was working on the IT Service Desk. AutoHotKey was one of the few approved scripting languages for us to use. So, we made due with what we had. 

<u>[IT Service Desk](https://github.com/ckern-py/ColinScripts/tree/main/AutoHotKey/IT%20Service%20Desk)</u> - The main script here is the ITSDUtil. A friend and I were able to build a toolbar for everyone on the IT Service Desk to use. This toolbar provided most of the information you regularly need, right at your finger tips. Everything from finding solutions to common problems, to unlocking accounts and changing passwords. Making all this information easily available helped to reduce call times and improve productivity across the IT Service Desk.

## **Powershell** 
All of my Powershell scripts here also come from when I was working on the IT Service Desk. Most of the scrips here either interacted with the ITSTUtil.ahk or have a utility use.

<u>[IT Service Desk](https://github.com/ckern-py/ColinScripts/tree/main/Powershell/IT%20Service%20Desk)</u> - Many of the Powershell scripts here interacted with our ITSDUtil toolbar. They allowed the ITSDUtil to seamlessly interact with Active Directory. It allowed the IT Service Desk to check if a given account was valid. If the account was valid then it would provide all the basic information like the current state of the account and when the password was last changed. These scripts also made it easy to change an account password, no matter what domain it was on. Some of these scrips could even be executed on a machine to help solve issues, such as repairing Office or removing keys from Credential Manager.

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
