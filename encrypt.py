import os
import re
import sys
import encryption

saltFile = str(sys.argv[1])
password = str(sys.argv[2])
encryptFolder = str(sys.argv[3])
file = str(sys.argv[4])
uploadFolder = str(sys.argv[5])

encrypt = encryption.encryption(saltFile, password)

encFile = encrypt.encryptString(file)
encrypt.encryptFile(str(encryptFolder) + "/" + str(file), str(uploadFolder) + "/" + str(encFile))
print str(encFile)
