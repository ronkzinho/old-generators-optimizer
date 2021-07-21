import json
import os
from zipfile import ZipFile
import requests
import sys


currentVersion = 1.8

def update(check: bool):
    try:
        req = requests.get("https://api.github.com/repos/ronkzinho/oldgenoptimizer/releases")
        newestVersion = req.json()
        if float(newestVersion[0]["tag_name"]) > currentVersion:
            if check: return print("True")
            r = requests.get("https://github.com/ronkzinho/oldgenoptimizer/releases/latest/download/optimizer.zip")
            with open("optimizer.zip", "wb") as code:
                code.write(r.content)
                unzip("optimizer.zip")
        if check:
            return print("False")
    except Exception:
        return print("False")

def unzip(fileName: str):
    with ZipFile(fileName, 'r') as zip_ref:
        zip_ref.extractall(members=["downloadGen.py", "findSeed.py", "FSG_Macro_slow.ahk", "FSG_Macro.ahk", "updater.py"])
    
    os.remove(fileName)

if __name__ == "__main__":
    if(len(sys.argv) > 1):
        update(sys.argv[1] == "check")
    else: update(False)