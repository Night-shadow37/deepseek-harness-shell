import pefile
import struct

# Test reading electron.exe
exe_path = r'C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe'
pe = pefile.PE(exe_path)

print('Machine:', hex(pe.FILE_HEADER.Machine))
print('NumberOfSections:', pe.FILE_HEADER.NumberOfSections)
print('Characteristics:', hex(pe.FILE_HEADER.Characteristics))
print('EntryPoint:', hex(pe.OPTIONAL_HEADER.AddressOfEntryPoint))
print('ImageBase:', hex(pe.OPTIONAL_HEADER.ImageBase))
print('SectionAlignment:', pe.OPTIONAL_HEADER.SectionAlignment)
print('FileAlignment:', pe.OPTIONAL_HEADER.FileAlignment)

if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
    print('Resources:')
    for res_type in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        print('  Type:', res_type.struct.Id, res_type.struct.name)
else:
    print('No resources')

pe.close()
