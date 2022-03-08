import subprocess
import basicLogging

def callLog(logMsg):
    basicLogging.mainLogging(__file__, logMsg)
    
def sshConnect():
    callLog("Making SSH connection")
    ssh = subprocess.Popen(["ssh", "root@192.168.1.1", "-p9001"],
                        stdin =subprocess.PIPE,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        universal_newlines=True,
                        bufsize=0)
    callLog("SSH connection made")
    return ssh
 
def sshCommand(sendCommand):
    results = []
    sshConnection = sshConnect()
    callLog("Sending command")
    sshConnection.stdin.write(sendCommand)
    sshConnection.stdin.close()
    callLog("Returning result")
    for line in sshConnection.stdout:
        results.append(line.strip())
    results = '\n'.join(map(str, results))
    return results