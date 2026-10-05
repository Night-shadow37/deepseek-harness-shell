import win32com.shell
import win32com.shell.shell
import pythoncom
import os

lnk_path = r'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
app_id = 'com.deepseek.harness'

print('Using pywin32 to set AppUserModelID...')

# Initialize COM
pythoncom.CoInitialize()

# Get property store
# GPS_READWRITE = 0x2
IID_IPropertyStore = pythoncom.IID('{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}')
property_store = win32com.shell.SHGetPropertyStoreFromParsingName(lnk_path, None, 0x2, IID_IPropertyStore)

if property_store is None:
    print('Failed to get property store')
    exit(1)

print('Got property store')

# Define property key for System.AppUserModel.ID
# {9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}, 5
FMTID_AppUserModelID = pythoncom.IID('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}')
PID_AppUserModelID = 5

# Set the value
# PROPVARIANT for VT_LPWSTR = 31
# In pywin32, we can use PyPROPVARIANT
from win32com.shell import PROPVARIANT

pv = PROPVARIANT()
pv.vt = 31  # VT_LPWSTR
pv.value = app_id

property_store.SetValue(FMTID_AppUserModelID, PID_AppUserModelID, pv)
hr = property_store.Commit()

if hr == 0:
    print('Successfully set AppUserModelID!')
else:
    print(f'Commit failed with HRESULT: 0x{hr:08X}')

pythoncom.CoUninitialize()
