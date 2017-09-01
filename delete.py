import os
import sys
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

fileID = str(sys.argv[1])

gauth = GoogleAuth()
gauth.CommandLineAuth()
drive = GoogleDrive(gauth)

file = drive.CreateFile({'id': ""+fileID+""})
file.Delete()
