import subprocess
import sys
import os
import time
import traceback

ELECTRON_PATH = r"C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe"
APP_DIR = r"D:\dsh\harness-shell"
LOG_FILE = os.path.join(APP_DIR, "dsh-launcher.log")

def log(msg):
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
            f.write(f"[{timestamp}] {msg}\n")
    except Exception:
        pass

def main():
    try:
        log("Launcher starting")
        log(f"Electron path: {ELECTRON_PATH}")
        log(f"App dir: {APP_DIR}")

        electron_path = ELECTRON_PATH
        if not os.path.exists(electron_path):
            log("ERROR: Electron not found at: " + electron_path)
            alt_path = os.path.join(os.path.dirname(APP_DIR), ".dsh", "dsh-orb", "electron-runtime", "electron.exe")
            log(f"Trying alternative path: {alt_path}")
            if os.path.exists(alt_path):
                electron_path = alt_path
                log("Using alternative electron path")
            else:
                log("ERROR: Electron not found at alternative path either")
                time.sleep(3)
                sys.exit(1)

        log("Launching electron via subprocess.Popen without shell...")
        proc = subprocess.Popen(
            [electron_path, APP_DIR],
            cwd=APP_DIR
        )
        log(f"PID: {proc.pid}")
        
        # Wait and check
        for i in range(10):
            time.sleep(1)
            ret = proc.poll()
            if ret is not None:
                log(f"Electron exited with code: {ret}")
                break
            else:
                log(f"Electron still running after {i+1} seconds")
        
        log("Launcher exiting")
        sys.exit(0)
    except Exception as ex:
        log("ERROR: " + str(ex))
        log(traceback.format_exc())
        time.sleep(3)
        sys.exit(1)

if __name__ == "__main__":
    main()
