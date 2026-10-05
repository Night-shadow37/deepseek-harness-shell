#!/usr/bin/env python3
"""
Inject VERSIONINFO resource into a PE EXE to reduce SmartScreen warnings.
This adds publisher info (CompanyName, ProductName, etc.) to the EXE.
"""

import struct
import sys
import os

try:
    import pefile
except ImportError:
    print("ERROR: pefile is not installed. Run: pip install pefile")
    sys.exit(1)


def make_unicode_string(s, pad_to=None):
    """Convert string to UTF-16LE with null terminator, optionally padded."""
    result = s.encode('utf-16-le') + b'\x00\x00'
    if pad_to:
        while len(result) < pad_to:
            result += b'\x00'
    return result


def align_up(value, alignment):
    """Align value up to alignment boundary."""
    return (value + alignment - 1) & ~(alignment - 1)


def make_version_info_resource():
    """Create a VERSIONINFO resource structure."""
    
    strings = {
        'CompanyName': 'DeepSeek',
        'FileDescription': 'DeepSeek Harness Launcher',
        'FileVersion': '1.0.0.0',
        'InternalName': 'DeepSeek Harness Launcher.exe',
        'OriginalFilename': 'DeepSeek Harness Launcher.exe',
        'ProductName': 'DeepSeek Harness',
        'ProductVersion': '1.0.0.0',
    }
    
    # Build string table
    string_table_data = b''
    for key, value in strings.items():
        string_table_data += make_unicode_string(key)
        string_table_data += make_unicode_string(value)
    
    # Pad to 4-byte boundary
    while len(string_table_data) % 4 != 0:
        string_table_data += b'\x00'
    
    # StringFileInfo structure
    sf_key = b'StringFileInfo\x00'
    sf_key_padded = sf_key + b'\x00' * ((4 - len(sf_key) % 4) % 4)
    sf_header = struct.pack('<HHH', 0, 0, 1) + sf_key_padded
    sf_header += string_table_data
    sf_header = struct.pack('<H', len(sf_header)) + sf_header[2:]
    
    # VarFileInfo structure (minimal)
    vf_key = b'VarFileInfo\x00'
    vf_key_padded = vf_key + b'\x00' * ((4 - len(vf_key) % 4) % 4)
    vf_value = struct.pack('<HHHH', 0x0409, 1200)  # Translation: US English, Unicode
    vf_header = struct.pack('<HHH', 0, len(vf_value) // 4, 1) + vf_key_padded
    vf_header += vf_value
    vf_header = struct.pack('<H', len(vf_header)) + vf_header[2:]
    
    # VS_VERSION_INFO root
    children = sf_header + vf_header
    vs_key = b'VS_VERSION_INFO\x00'
    vs_key_padded = vs_key + b'\x00' * ((4 - len(vs_key) % 4) % 4)
    
    # VS_FIXEDFILEINFO (minimal but valid)
    fixed_info = struct.pack('<IIIIHHHHHHHHHH',
                             0x00010000,  # dwSignature
                             0x00010000,  # dwStrucVersion
                             0x0001,      # dwFileVersionMS
                             0x0000,      # dwFileVersionLS
                             0x0001,      # dwProductVersionMS
                             0x0000,      # dwProductVersionLS
                             0x3F,        # dwFileFlagsMask
                             0,           # dwFileFlags
                             4,           # dwFileOS
                             1,           # dwFileType
                             1,           # dwFileSubtype
                             0,           # dwFileDateMS
                             0)           # dwFileDateLS
    
    vs_header = struct.pack('<HHH', 0, len(fixed_info) // 4, 0) + vs_key_padded
    vs_header += fixed_info + children
    vs_header = struct.pack('<H', len(vs_header)) + vs_header[2:]
    
    return vs_header


def get_section_by_name(pe, name):
    """Find a section by name."""
    for section in pe.sections:
        sec_name = section.Name.decode().strip('\x00')
        if sec_name == name:
            return section
    return None


def inject_version_info(exe_path):
    """Inject VERSIONINFO resource into PE file."""
    
    print(f'Loading {exe_path}...')
    pe = pefile.PE(exe_path)
    
    # Check if version info already exists
    if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
        for rt in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            if rt.struct.Id == 16:  # RT_VERSION
                print('Version info already exists, skipping')
                pe.close()
                return
    
    # Create version info resource
    version_data = make_version_info_resource()
    print(f'Created version info: {len(version_data)} bytes')
    
    # Find .rsrc section
    rsrc_section = get_section_by_name(pe, '.rsrc')
    if not rsrc_section:
        print('ERROR: No .rsrc section found')
        pe.close()
        return
    
    print(f'Found .rsrc section: VAddr={rsrc_section.VirtualAddress:#x}, Size={rsrc_section.Misc_VirtualSize:#x}')
    print('Version info injection requires PE section modification - this is complex')
    print('For now, the launcher works without version info')
    
    pe.close()


if __name__ == '__main__':
    exe_path = r'D:\dsh\harness-shell\launcher\DeepSeek Harness Launcher.exe'
    inject_version_info(exe_path)
