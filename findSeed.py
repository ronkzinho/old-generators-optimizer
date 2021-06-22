from genericpath import exists
import os
import json
from multiprocessing import Process
from downloadGen import get_gen
import subprocess
import signal
import shutil



def run_seed():
    seed = ""
    while seed == "":
        cmd = f'cd ./generator && ./seed'
        seed = os.popen(cmd).read().strip()
    print(seed)


def start_run():
    with open('settings.json') as filter_json:
        read_json = json.load(filter_json)
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
        processes.append(Process(target=run_seed))
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
