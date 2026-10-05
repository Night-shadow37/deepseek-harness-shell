import win32com.shell
import win32com.shell.shell
import pythoncom

print('win32com.shell attributes:')
attrs = [a for a in dir(win32com.shell) if not a.startswith('_')]
for a in attrs:
    print(' ', a)
