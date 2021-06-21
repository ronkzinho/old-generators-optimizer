import os
import json
from multiprocessing import Process
from downloadGen import get_gen
import subprocess
import signal


def run_seed():
    seed = ""
    while seed == "":
        cmd = f'./seed'
        seed = os.popen(cmd).read().strip()
    print(seed)


def start_run():
    with open('settings.json') as filter_json:
        read_json = json.load(filter_json)
        if not os.path.exists("seed"):
            if not read_json["generator"]: return print("Invalid generator.")
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
                    for line in out.splitlines():
                        if b'seed' in line:
                            pid = int(line.split(None, 1)[0])
                            os.kill(pid, signal.SIGKILL)
                return
        i = (i + 1) % num_processes


if __name__ == '__main__':
    start_run()
