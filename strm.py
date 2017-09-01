import os
import sys
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from pushbullet import Pushbullet

folderID = str(sys.argv[1])
encryptedFile = str(sys.argv[2])
strmPath = str(sys.argv[3])
videoName = str(sys.argv[4])
textFile = str(sys.argv[5])
originalName = str(sys.argv[6])
fileSize = str(sys.argv[7])
strmDestination = str(sys.argv[8])
listDestination = str(sys.argv[9])

gauth = GoogleAuth()
gauth.CommandLineAuth()
drive = GoogleDrive(gauth)

pb = Pushbullet("Your API Key")

if folderID != "Sport":

  files = drive.ListFile({'q': "'"+folderID+"' in parents and title = '"+encryptedFile+"'"}).GetList()

  for file in files:

    fileID = str(file['id'])
    strm = open(strmPath + "/" + videoName + ".strm", "w+")
    strm.write("plugin://plugin.video.gdrive/?mode=video&encfs=True&title=" + videoName + "&filename=" + fileID)
    strm.close()
    list = open(textFile, "a+")
    list.write("vn: " + videoName + "\non: " + originalName + "\nfn: " +  encryptedFile + "\nid: " + fileID + "\nfs: " + fileSize + "\n\n")
    list.close()

  os.system("rclone copy '"+strmPath+"'/'"+videoName+"'.strm '"+strmDestination+"'")
  os.system("rclone copy '"+textFile+"' '"+listDestination+"'")

chrome = pb.devices[1]
chrome.push_note(videoName, "")
