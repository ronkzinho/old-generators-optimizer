from typing import Any
import requests
import json
import os
import sys
from zipfile import ZipFile

baseGeneratorPath = "./generator"
mandatoryGeneratorFiles = ["/seed", "/csprng.c", "/libs/"]

def get_gen(download: bool, forceDownload):
    with open('settings.json') as filter_json:
        try:
            read_json = json.load(filter_json)
            generators = requests.get("https://oldgenoptimizer.tk/generators.json").json()
            gen = next((item for item in generators["generators"] if item["name"] == read_json["generator"]), None)
            if not gen:
                print("Generator not in list.")
                return False
            if any(map(lambda file: not os.path.isfile(f'{baseGeneratorPath}{file}') if not file.endswith('/') else not os.path.isdir(f'{baseGeneratorPath}{file}'), mandatoryGeneratorFiles)) and download or forceDownload:
                r = requests.get(gen["url"])
                with open("gen.zip", "wb") as code:
                    code.write(r.content)
                    unzip()
                print("done")
            return check_gen(gen, read_json)
        except Exception as e:
            print(e)
            return False


def unzip():
    with ZipFile("gen.zip", 'r') as zip_ref:
        zip_ref.extractall(baseGeneratorPath)
    
    os.remove("gen.zip")
    os.popen(f"chmod +x {baseGeneratorPath}{mandatoryGeneratorFiles[0]}")

def check_gen(gen, read_json):
    if any(map(lambda file: not os.path.isfile(f'{baseGeneratorPath}{file}') if not file.endswith('/') else not os.path.isdir(f'{baseGeneratorPath}{file}'), mandatoryGeneratorFiles)):
        print("Missing mendatory generator files.")
        return False
    if gen["sha256sum"] != os.popen("sha256sum ./generator/csprng.c").read().strip().split(" ")[0] and not gen["verifiable"]:
        print("Invalid csprng.c sha256sum.")
        return False
    if not gen["verifiable"] and read_json["warnOnUnverifiable"]:
        print("Runs with this generator won't be able to get verified.")
    return True

if __name__ == '__main__':
    get_gen("download" in sys.argv, "forceDownload" in sys.argv)
