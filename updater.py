import json
import os
from zipfile import ZipFile
import requests
import sys
from packaging import version


currentVersion = "v1.0"

def update(check: bool):
    try:
        essentialsFiles = ["downloadGen.py", "findSeed.py", "FSG_Macro_slow.ahk", "FSG_Macro.ahk", "updater.py"]
        missingFiles = False
        for essentialFile in essentialsFiles:
            if not os.path.isfile(essentialFile):
                missingFiles = True
        req = requests.get("https://api.github.com/repos/ronkzinho/oldgenoptimizer/releases")
        newestVersion = req.json()
        if version.parse(newestVersion[0]["tag_name"]) > version.parse(currentVersion) or missingFiles == True:
            if check: return print("True")
            r = requests.get("https://github.com/ronkzinho/oldgenoptimizer/releases/latest/download/optimizer.zip")
            with open("optimizer.zip", "wb") as code:
                code.write(r.content)
                unzip("optimizer.zip", essentialsFiles)
        if check:
            return print("False")
    except Exception:
        return print("False")

def unzip(fileName: str, essentialFiles: list):
    with ZipFile(fileName, 'r') as zip_ref:
        zip_ref.extractall(members=essentialFiles)
    
    os.remove(fileName)

if __name__ == "__main__":
    if(len(sys.argv) > 1):
        update(sys.argv[1] == "check")
    else: update(False)