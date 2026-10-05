import win32crypt
import win32api
import win32con
import ctypes
from ctypes import wintypes
import struct

# Constants
CERT_STORE_PROV_SYSTEM = 10
CERT_SYSTEM_STORE_CURRENT_USER = 0x00010000
CERT_STORE_OPEN_EXISTING_FLAG = 0x00004000
CERT_STORE_ADD_USE_EXISTING = 2
X509_ASN_ENCODING = 0x00000001
PKCS_7_ASN_ENCODING = 0x00010000

# Load certutil functions
crypt32 = ctypes.WinDLL('crypt32.dll', use_last_error=True)
kernel32 = ctypes.WinDLL('kernel32.dll', use_last_error=True)

# Define structures
class CRYPT_DATA_BLOB(ctypes.Structure):
    _fields_ = [
        ('cbData', wintypes.DWORD),
        ('pbData', ctypes.POINTER(ctypes.c_byte))
    ]

def read_cert_file(path):
    with open(path, 'rb') as f:
        data = f.read()
    return data

def add_cert_to_store(cert_data, store_name, location):
    # Convert Python bytes to a ctypes buffer
    buf = ctypes.create_string_buffer(cert_data)
    blob = CRYPT_DATA_BLOB()
    blob.cbData = len(cert_data)
    blob.pbData = ctypes.cast(buf, ctypes.POINTER(ctypes.c_byte))
    
    # Open the system store
    hStore = wintypes.HANDLE()
    result = crypt32.CertOpenStore(
        "System",
        X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,
        0,
        CERT_STORE_PROV_SYSTEM | CERT_SYSTEM_STORE_CURRENT_USER | CERT_STORE_OPEN_EXISTING_FLAG,
        store_name
    )
    
    if not result:
        error = ctypes.get_last_error()
        print(f"Failed to open store. Error: {error}")
        return False
    
    try:
        # Add the certificate
        cert_context = crypt32.CertAddSerializedStoreElement(
            result,
            0,  # dwFlags
            CERT_STORE_ADD_USE_EXISTING,
            buf,
            len(cert_data),
            0  # pvReserved
        )
        
        if not cert_context:
            error = ctypes.get_last_error()
            print(f"Failed to add certificate. Error: {error}")
            return False
        
        print("Certificate added successfully!")
        return True
    finally:
        crypt32.CertCloseStore(result, 0)

def main():
    cert_path = r'D:\dsh\harness-shell\release\dsh-cert.cer'
    cert_data = read_cert_file(cert_path)
    print(f"Read {len(cert_data)} bytes from {cert_path}")
    
    # Try adding to Root store
    if add_cert_to_store(cert_data, "Root", "CurrentUser"):
        print("Added to CurrentUser\Root")
    else:
        print("Failed to add to CurrentUser\Root")
    
    # Also try LocalMachine\Root
    if add_cert_to_store(cert_data, "Root", "LocalMachine"):
        print("Added to LocalMachine\Root")
    else:
        print("Failed to add to LocalMachine\Root")

if __name__ == "__main__":
    main()
