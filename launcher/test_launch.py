import subprocess
import os
import time

electron_path = r"C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe"
app_dir = r"D:\dsh\harness-shell"
log_file = os.path.join(app_dir, "dsh-test-launch.log")

def log(msg):
    try:
        with open(log_file, "a", encoding="utf-8") as f:
            timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
            f.write(f"[{timestamp}] {msg}\n")
    except Exception:
        pass

log("Test script starting")

try:
    log("Launching electron with subprocess.Popen...")
    proc = subprocess.Popen(
        [electron_path, app_dir],
        cwd=app_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    log(f"PID: {proc.pid}")
    time.sleep(3)
    ret = proc.poll()
    if ret is not None:
        log(f"Exited with code: {ret}")
    else:
        log("Still running")
except Exception as ex:
    log(f"ERROR: {ex}")

log("Test script done")
