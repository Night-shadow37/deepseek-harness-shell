import ctypes
from ctypes import wintypes
import struct

# Define GUID structure
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

# Define PROPERTYKEY
class PROPERTYKEY(ctypes.Structure):
    _fields_ = [
        ("fmtid", GUID),
        ("pid", wintypes.DWORD)
    ]

# Define PROPVARIANT for VT_LPWSTR
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

# IPropertyStore interface
class IPropertyStore(ctypes.c_void_p):
    _methods_ = [
        ("QueryInterface",
         ctypes.WINFUNCTYPE(ctypes.HRESULT, ctypes.POINTER(GUID), ctypes.POINTER(ctypes.c_void_p))),
        ("AddRef",
         ctypes.WINFUNCTYPE(ctypes.c_ulong)),
        ("Release",
         ctypes.WINFUNCTYPE(ctypes.c_ulong)),
        ("GetCount",
         ctypes.WINFUNCTYPE(ctypes.HRESULT, ctypes.POINTER(ctypes.c_uint))),
        ("GetAt",
         ctypes.WINFUNCTYPE(ctypes.HRESULT, ctypes.c_uint, ctypes.POINTER(PROPERTYKEY))),
        ("GetValue",
         ctypes.WINFUNCTYPE(ctypes.HRESULT, ctypes.POINTER(PROPERTYKEY), ctypes.POINTER(PROPVARIANT))),
        ("SetValue",
         ctypes.WINFUNCTYPE(ctypes.HRESULT, ctypes.POINTER(PROPERTYKEY), ctypes.POINTER(PROPVARIANT))),
        ("Commit",
         ctypes.WINFUNCTYPE(ctypes.HRESULT)),
    ]
    
    def SetValue(self, key, value):
        return self._methods_[6](self, ctypes.byref(key), ctypes.byref(value))
    
    def Commit(self):
        return self._methods_[7](self)

# Shell32 functions
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
    2,  # GPS_READWRITE
    ctypes.byref(guid_ipropertystore),
    ctypes.byref(property_store_ptr)
)

if hr != 0:
    print(f'Failed to get IPropertyStore. HRESULT: 0x{hr:08X}')
    exit(1)

if not property_store_ptr:
    print('Property store pointer is null')
    exit(1)

print(f'Got property store: {property_store_ptr}')

# Create IPropertyStore wrapper
property_store = IPropertyStore.__new__(IPropertyStore)
property_store.value = property_store_ptr.value

# Set AppUserModelID
key = PROPERTYKEY()
key.fmtid = GUID('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}')
key.pid = 5

value = PROPVARIANT()
value.vt = VT_LPWSTR
value.wReserved1 = 0
value.wReserved2 = 0
value.wReserved3 = 0
value.p = app_id
value.ulVal = 0

hr = property_store.SetValue(ctypes.byref(key), ctypes.byref(value))
print(f'SetValue HRESULT: 0x{hr:08X}')

if hr == 0:
    hr = property_store.Commit()
    print(f'Commit HRESULT: 0x{hr:08X}')
    if hr == 0:
        print('Successfully set AppUserModelID!')
    else:
        print('Commit failed')
else:
    print('SetValue failed')
