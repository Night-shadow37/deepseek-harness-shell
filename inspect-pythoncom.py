import pythoncom
import win32com.shell.shell

print('pythoncom attributes:')
attrs = [a for a in dir(pythoncom) if not a.startswith('_')]
for a in attrs:
    print(' ', a)
