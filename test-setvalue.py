import pythoncom
import win32com.shell.shell
import win32com.shell

pythoncom.CoInitialize()

lnk_path = r'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
app_id = 'com.deepseek.harness'

# Get IPropertyStore
IID_IPropertyStore = pythoncom.MakeIID('{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}')
property_store = win32com.shell.shell.SHGetPropertyStoreFromParsingName(lnk_path, None, 0x2, IID_IPropertyStore)

print('Property store type:', type(property_store))
print('Property store methods:', [m for m in dir(property_store) if not m.startswith('_')])

# Define property key
FMTID_AppUserModelID = pythoncom.MakeIID('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}')
PID_AppUserModelID = 5

# Try SetValue with different argument types
try:
    # Try with tuple key
    hr = property_store.SetValue((FMTID_AppUserModelID, PID_AppUserModelID), app_id)
    print('SetValue (string) HRESULT:', hex(hr))
except Exception as e:
    print('SetValue (string) failed:', e)

try:
    # Try with PROPVARIANT
    pv = win32com.shell.PROPVARIANT()
    pv.vt = pythoncom.VT_LPWSTR
    pv.value = app_id
    hr = property_store.SetValue((FMTID_AppUserModelID, PID_AppUserModelID), pv)
    print('SetValue (PROPVARIANT) HRESULT:', hex(hr))
except Exception as e:
    print('SetValue (PROPVARIANT) failed:', e)

# Try Commit
try:
    hr = property_store.Commit()
    print('Commit HRESULT:', hex(hr))
except Exception as e:
    print('Commit failed:', e)

pythoncom.CoUninitialize()
