import requests
import json
import os
from zipfile import ZipFile


def get_gen():
    generators = {
        "fsg-power-village-plusplus": "https://drive.google.com/uc?export=download&id=1vcJPJhuT11jfJreKElmQL7PdfJIZ3Lv2",
        "filteredseed": "https://drive.google.com/uc?export=download&id=1mpWw28TCCJixqdnx_iFcPq0G5qxuttnj",
        "fsg-power-village-minus-minus": "https://drive.google.com/uc?export=download&id=1hzBE_BkU_3vnAYUW7XniM-NP2DwUu3G4"
    }
    with open('settings.json') as filter_json:
        try:
            read_json = json.load(filter_json)
            if not read_json["generator"] in generators:
                return False
            url = generators[read_json["generator"]]
            r = requests.get(url)
            with open("gen.zip", "wb") as code:
                code.write(r.content)
                unzip()
            return True
        except Exception as e:
            print(e)
            return False


def unzip():
    with ZipFile("gen.zip", 'r') as zip_ref:
        zip_ref.extractall("./generator")
    
    os.remove("gen.zip")


if __name__ == '__main__':
    get_gen()
