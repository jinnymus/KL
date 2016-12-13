#!/usr/local/bin/python
import base64
from struct import *
 
password = "Microsoft® Windows® Operating System"  
#bin = pack('s',password.encode("utf-16"))
#print("bin = " + bin)
encoded = base64.b64encode(password)
print(encoded)
decoded = base64.b64decode(encoded)
print(decoded)