import ctypes
from ctypes import wintypes
import time
import subprocess

class GUID(ctypes.Structure):
    _fields_ = [
        ("Data1", wintypes.DWORD),
        ("Data2", wintypes.WORD),
        ("Data3", wintypes.WORD),
        ("Data4", ctypes.c_ubyte * 8)
    ]
    
    def __init__(self, guid_str):
        guid_str = guid_str.strip('{}')
        parts = guid_str.split('-')
        self.Data1 = int(parts[0], 16)
        self.Data2 = int(parts[1], 16)
        self.Data3 = int(parts[2], 16)
        data4 = parts[3] + parts[4]
        self.Data4 = (ctypes.c_ubyte * 8).from_buffer_copy(
            bytes.fromhex(data4)
        )

class PROPERTYKEY(ctypes.Structure):
    _fields_ = [
        ("fmtid", GUID),
        ("pid", wintypes.DWORD)
    ]

class PROPVARIANT(ctypes.Structure):
    _fields_ = [
        ("vt", wintypes.WORD),
        ("wReserved1", wintypes.WORD),
        ("wReserved2", wintypes.WORD),
        ("wReserved3", wintypes.WORD),
        ("p", wintypes.LPWSTR),
        ("ulVal", wintypes.ULONG),
    ]
    
VT_LPWSTR = 31

ole32 = ctypes.OleDLL('ole32.dll')
ole32.CoInitialize(None)
shell32 = ctypes.WinDLL('shell32.dll')

SHGetPropertyStoreFromParsingName = shell32.SHGetPropertyStoreFromParsingName
SHGetPropertyStoreFromParsingName.argtypes = [
    wintypes.LPCWSTR,
    ctypes.c_void_p,
    wintypes.DWORD,
    ctypes.POINTER(GUID),
    ctypes.POINTER(ctypes.c_void_p)
]
SHGetPropertyStoreFromParsingName.restype = ctypes.HRESULT

lnk_path = r'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
app_id = 'com.deepseek.harness'

guid_ipropertystore = GUID('{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}')
property_store_ptr = ctypes.c_void_p()

hr = SHGetPropertyStoreFromParsingName(
    lnk_path,
    None,
    1,  # GPS_HANDLERPROPERTIESONLY (read-only)
    ctypes.byref(guid_ipropertystore),
    ctypes.byref(property_store_ptr)
)

if hr != 0:
    print(f'Failed to get IPropertyStore. HRESULT: 0x{hr:08X}')
    exit(1)

vtable_ptr = ctypes.c_void_p.from_address(property_store_ptr.value).value

GetValue_ptr = ctypes.c_void_p.from_address(vtable_ptr + 5 * ctypes.sizeof(ctypes.c_void_p)).value
GetValue_func = ctypes.WINFUNCTYPE(
    ctypes.HRESULT,
    ctypes.c_void_p,
    ctypes.POINTER(PROPERTYKEY),
    ctypes.POINTER(PROPVARIANT)
)(GetValue_ptr)

key = PROPERTYKEY()
key.fmtid = GUID('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}')
key.pid = 5

value = PROPVARIANT()
value.vt = 0
value.p = None

hr = GetValue_func(property_store_ptr, ctypes.byref(key), ctypes.byref(value))
print(f'GetValue HRESULT: 0x{hr:08X}')

if hr == 0:
    if value.vt == VT_LPWSTR and value.p:
        app_id_read = ctypes.c_wchar_p(value.p).value
        print(f'AppUserModelID: {app_id_read}')
        if app_id_read == app_id:
            print('SUCCESS: AppUserModelID matches expected value!')
        else:
            print(f'ERROR: Expected {app_id}, got {app_id_read}')
    else:
        print(f'Property not found or wrong type: vt={value.vt}')
else:
    print('GetValue failed')

ole32.CoUninitialize()
