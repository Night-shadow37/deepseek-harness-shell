# Set AppUserModelID on DeepSeek Harness Start Menu shortcut
# This uses IPropertyStore via SHGetPropertyStoreFromParsingName

$ErrorActionPreference = 'Stop'
$lnkPath = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
$appUserModelId = 'com.deepseek.harness'

Write-Host 'Setting AppUserModelID on shortcut...' -ForegroundColor Cyan

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

[StructLayout(LayoutKind.Sequential, Pack=4)]
public struct PROPERTYKEY {
    public Guid fmtid;
    public int pid;
}

[StructLayout(LayoutKind.Explicit)]
public struct PROPVARIANT {
    [FieldOffset(0)] public ushort vt;
    [FieldOffset(2)] public ushort wReserved1;
    [FieldOffset(4)] public ushort wReserved2;
    [FieldOffset(6)] public ushort wReserved3;
    [FieldOffset(8)] public IntPtr p;
}

[ComImport]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
[Guid("886d8eeb-8cf2-4446-8d02-cdba1dbdcf99")]
public interface IPropertyStore {
    void GetCount(out uint cProps);
    void GetAt(uint iProp, out PROPERTYKEY pkey);
    void GetValue(ref PROPERTYKEY key, out PROPVARIANT pv);
    void SetValue(ref PROPERTYKEY key, ref PROPVARIANT propvar);
    void Commit();
}

public static class NativeMethods {
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    public static extern int SHGetPropertyStoreFromParsingName(
        string pszPath,
        IntPtr pbctx,
        uint flags,
        ref Guid riid,
        [MarshalAs(UnmanagedType.Interface)] out IPropertyStore ppv
    );
}
'@

function Set-ShortcutAppUserModelID {
    param(
        [string]$Path,
        [string]$AppUserModelId
    )
    
    if (-not (Test-Path $Path)) {
        throw "Shortcut not found: $Path"
    }
    
    $guidIPropertyStore = [Guid]"886d8eeb-8cf2-4446-8d02-cdba1dbdcf99"
    $propertyStore = $null
    
    $hr = [NativeMethods]::SHGetPropertyStoreFromParsingName(
        $Path,
        [IntPtr]::Zero,
        2,  # GPS_READWRITE
        [ref]$guidIPropertyStore,
        [ref]$propertyStore
    )
    
    if ($hr -ne 0 -or $propertyStore -eq $null) {
        throw "Failed to get IPropertyStore. HRESULT: 0x$($hr.ToString('X8'))"
    }
    
    $key = New-Object PROPERTYKEY
    $key.fmtid = [Guid]"9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"
    $key.pid = 5  # System.AppUserModel.ID
    
    $variant = New-Object PROPVARIANT
    $variant.vt = 31  # VT_LPWSTR
    $variant.wReserved1 = 0
    $variant.wReserved2 = 0
    $variant.wReserved3 = 0
    $variant.p = [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemUni($AppUserModelId)
    
    try {
        $propertyStore.SetValue([ref]$key, [ref]$variant) | Out-Null
        $propertyStore.Commit() | Out-Null
        Write-Host "[OK] Set AppUserModelID='$AppUserModelId' on $Path" -ForegroundColor Green
    } finally {
        if ($variant.p -ne [IntPtr]::Zero) {
            [System.Runtime.InteropServices.Marshal]::FreeCoTaskMem($variant.p)
        }
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($propertyStore) | Out-Null
    }
}

Set-ShortcutAppUserModelID -Path $lnkPath -AppUserModelId $appUserModelId
Write-Host 'Done.'
