import json
import os
from zipfile import ZipFile
import requests
import sys
from packaging import version


currentVersion = "v1.3.8-beta"

def update(check: bool, force: bool):
    try:
        with open("settings.json", "r+") as settings_raw:
            settings_json = json.load(settings_raw)
            essentialsFiles = ["downloadGen.py", "findSeed.py", "FSG_Macro_slow.ahk", "FSG_Macro.ahk", "updater.py", "JSON.ahk"]
            missingFiles = False
            for essentialFile in essentialsFiles:
                if not os.path.isfile(essentialFile):
                    missingFiles = True
            req = requests.get("https://api.github.com/repos/ronkzinho/oldgenoptimizer/releases")
            newestVersion = req.json()
            if ((newestVersion[0]["prerelease"] and version.parse(filter(lambda version: not version["prerelease"], newestVersion)[0]["tag_name"]) > version.parse(currentVersion)) or (version.parse(newestVersion[0]["tag_name"]) > version.parse(currentVersion) and newestVersion[0]["prerelease"] and settings_json["tests"] == True) or missingFiles == True or force == True):
                if check: return print("True")
                r = requests.get("https://github.com/ronkzinho/oldgenoptimizer/releases/latest/download/optimizer.zip")
                with open("optimizer.zip", "wb") as code:
                    code.write(r.content)
                    newProperties = unzip("optimizer.zip", settings_json)
                    with open("settings.json", "w") as w:
                        w.write(json.dumps(newProperties, indent=4))
            if check:
                return print("False")
    except Exception:
        return print("False")

def unzip(fileName: str, settings_json: dict):
    newProperties = settings_json.copy()
    with ZipFile(fileName, 'r') as zip_ref:
        for member in zip_ref.namelist():
            if member == "settings.json":
                content = zip_ref.open(member)
                newsettings_json = json.loads(content.read())
                for property in newsettings_json:
                    if not property in settings_json:
                        newProperties.update({ f"{property}": newsettings_json[property] })

                for oldProperty in settings_json:
                    if not oldProperty in newsettings_json:
                        del newProperties[oldProperty]
            break

        zip_ref.extractall()
    
    os.remove(fileName)
    return newProperties

if __name__ == "__main__":
    if(len(sys.argv) > 1):
        if "force" in sys.argv:
            if "check" in sys.argv:
                update(True, True)
            else:
                update(False, True)
        else:
            update(sys.argv[1] == "check", False)
    else: update(False, False)