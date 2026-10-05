import subprocess
import os
import time

electron_path = r"C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe"
app_dir = r"D:\dsh\harness-shell"
log_file = os.path.join(app_dir, "dsh-test-launch2.log")

def log(msg):
    try:
        with open(log_file, "a", encoding="utf-8") as f:
            timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
            f.write(f"[{timestamp}] {msg}\n")
    except Exception:
        pass

log("Test script starting")

# Test 1: subprocess.Popen with shell=True
log("Test 1: Popen with shell=True")
try:
    proc = subprocess.Popen(
        f'"{electron_path}" "{app_dir}"',
        shell=True,
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
        proc.terminate()
except Exception as ex:
    log(f"ERROR: {ex}")

time.sleep(1)

# Test 2: os.system
log("Test 2: os.system")
try:
    ret = os.system(f'start "" "{electron_path}" "{app_dir}"')
    log(f"os.system returned: {ret}")
    time.sleep(3)
except Exception as ex:
    log(f"ERROR: {ex}")

time.sleep(1)

# Test 3: subprocess.run
log("Test 3: subprocess.run")
try:
    result = subprocess.run(
        [electron_path, app_dir],
        cwd=app_dir,
        capture_output=True,
        text=True,
        timeout=5
    )
    log(f"Return code: {result.returncode}")
    log(f"Stdout: {result.stdout}")
    log(f"Stderr: {result.stderr}")
except Exception as ex:
    log(f"ERROR: {ex}")

log("Test script done")
