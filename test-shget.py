import win32com.shell.shell as shell_module
import pythoncom

print('Checking for SHGetPropertyStoreFromParsingName...')
print('Has attr:', hasattr(shell_module, 'SHGetPropertyStoreFromParsingName'))

# Try to get it
func = getattr(shell_module, 'SHGetPropertyStoreFromParsingName', None)
print('Function:', func)

# Check if it's in __all__ or similar
print('Module file:', shell_module.__file__)
