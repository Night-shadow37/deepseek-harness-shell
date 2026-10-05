import pefile
import os

launcher = r'D:\dsh\harness-shell\release\DeepSeek Harness.exe'
original = r'C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe'

print('=== Original electron.exe ===')
pe = pefile.PE(original)
print('Resources:', hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'))
if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
    for res_type in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        print('  Type:', res_type.struct.Id, res_type.struct.name)
pe.close()

print('')
print('=== Launcher EXE ===')
pe = pefile.PE(launcher)
print('Resources:', hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'))
if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
    for res_type in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        print('  Type:', res_type.struct.Id, res_type.struct.name)
        if hasattr(res_type, 'directory'):
            for res_id in res_type.directory.entries:
                try:
                    data = res_id.directory.entries[0].data.struct
                    print('    ID:', res_id.struct.Id, 'Size:', data.Size, 'Offset:', hex(data.OffsetToData))
                except Exception as e:
                    print('    Error reading:', e)
pe.close()

print('')
print('Launcher exists:', os.path.exists(launcher))
print('Launcher size:', os.path.getsize(launcher))
