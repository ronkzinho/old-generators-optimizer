import requests
import json
import os
from zipfile import ZipFile


def get_gen():
    generators = {
        "fsg-power-village-plusplus": "https://drive.google.com/uc?export=download&id=1nhYhIBKTTA-3UfORsaVveDxdxiFLsZPE",
        "filteredseed": "https://drive.google.com/uc?export=download&id=1f2hA7gXMp-5mhiOo31bB04nL5ANvsXzt",
        "fsg-power-village-minus-minus": "https://drive.google.com/uc?export=download&id=1d__cbrB7y6oecx02f1be_gzW9fRVPWB_"
    }
    with open('settings.json') as filter_json:
        try:
            read_json = json.load(filter_json)
            if not read_json["generator"] in generators:
                return False
            url = generators[read_json["generator"]]
            r = requests.get(url)
            with open(f"gen.zip", "wb") as code:
                code.write(r.content)
                unzip()
            return True
        except Exception as e:
            print(e)
            return False


def unzip():
    with ZipFile("gen.zip", 'r') as zip_ref:
        zip_ref.extractall()
    os.remove("gen.zip")


if __name__ == '__main__':
    get_gen()
