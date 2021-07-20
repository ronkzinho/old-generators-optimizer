import requests
import json
import os
from zipfile import ZipFile


def get_gen():
    with open('settings.json') as filter_json:
        try:
            read_json = json.load(filter_json)
            generators = requests.get("https://oldgenoptimizer.tk/api/generators").json()
            if not read_json["generator"] in generators:
                return False
            url = generators[read_json["generator"]]
            r = requests.get(url)
            with open("gen.zip", "wb") as code:
                code.write(r.content)
                unzip()
            return True
        except Exception as e:
            return False


def unzip():
    with ZipFile("gen.zip", 'r') as zip_ref:
        zip_ref.extractall("./generator")
    
    os.remove("gen.zip")


if __name__ == '__main__':
    get_gen()
