import subprocess
import os
import time

electron_path = r"C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe"
app_dir = r"D:\dsh\harness-shell"
log_file = os.path.join(app_dir, "dsh-test-launch3.log")

def log(msg):
    try:
        with open(log_file, "a", encoding="utf-8") as f:
            timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
            f.write(f"[{timestamp}] {msg}\n")
    except Exception:
        pass

log("Test script starting")

# Test: Popen without shell=True, no pipes
log("Test: Popen without pipes")
try:
    proc = subprocess.Popen(
        [electron_path, app_dir],
        cwd=app_dir
    )
    log(f"PID: {proc.pid}")
    time.sleep(5)
    ret = proc.poll()
    if ret is not None:
        log(f"Exited with code: {ret}")
    else:
        log("Still running after 5 seconds")
except Exception as ex:
    log(f"ERROR: {ex}")

log("Test script done")
