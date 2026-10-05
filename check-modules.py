try:
    import win32com
    print('pywin32 version:', win32com.__version__)
except ImportError:
    print('pywin32: not found')

try:
    import comtypes
    print('comtypes version:', comtypes.__version__)
except ImportError:
    print('comtypes: not found')
