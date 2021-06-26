from genericpath import exists
import os
import json
from multiprocessing import Process
from downloadGen import get_gen
import subprocess
import signal
import shutil
import re



def run_seed(generator: str):
    seed = ""
    token = ""
    seed_type = ""
    while seed == "":
        cmd = os.popen("cd generator && ./seed").read().strip()
        cmd = re.sub("[.|,|@|\\n]", " ", cmd)
        listedCmd = cmd.split(" ")
        if "Seed:" in listedCmd:
            if not "Only)" in listedCmd:
                seed_type = listedCmd[listedCmd.index("Seed") - 1]
            seed = listedCmd[listedCmd.index("Seed:") + 1]
            token = listedCmd[listedCmd.index("Token:") + 1]
    if(seed is not "" and token is not ""):
        print(f"Generator: {generator}")
        print(f"Seed: {seed} ")
        print(f"Verification Token: {token} \n")
        if seed_type is not "":
            print(f"Type: {seed_type}")


def start_run():
    with open('settings.json') as filter_json:
        read_json = json.load(filter_json)
        generator = read_json["generator"]
        if not os.path.exists("./generator/seed"):
            if not read_json["generator"]: return print("Invalid generator.")
            if not get_gen(): return print("Invalid generator or something went wrong.")
        else:
            with open("./generator/generator.txt", "r") as file:
                content = file.read()
                if content != read_json["generator"]:
                    shutil.rmtree("./generator/", ignore_errors=True)
                    if not get_gen(): return print("Invalid generator or something went wrong.")
        num_processes = read_json["thread_count"]
    processes = []
    for i in range(num_processes):
        processes.append(Process(target=run_seed, args=(generator,)))
        processes[-1].start()
    i = 0
    while True:
        for j in range(len(processes)):
            if not processes[j].is_alive():
                for k in range(len(processes)):
                    processes[k].kill()
                    p = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
                    out, err = p.communicate()
                    if(err): return                     
                    for line in out.splitlines():
                        if b'seed' in line:
                            pid = int(line.split(None, 1)[0])
                            os.kill(pid, signal.SIGKILL)
                return
        i = (i + 1) % num_processes


if __name__ == '__main__':
    start_run()
