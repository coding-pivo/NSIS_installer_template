import win32com.client as win32
import win32serviceutil as win32service
import win32api
import os
import platform
import sys
import logging
import shutil
import argparse
import subprocess
import time

try:
    import _winreg as winreg
except ImportError:
    import winreg

# Setup logging in general
log = logging.getLogger('Test')
log.setLevel(logging.DEBUG)
fh = logging.FileHandler('test.log')
fh.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
log.addHandler(fh)


def main():
    cmdParser = argparse.ArgumentParser(description='Test script')
    cmdParser.add_argument('greet', choices=['Hello', 'Hallo'], action='store')
    cmdParser.add_argument('title', choices=['Mr','Herr'], action='store')
    cmdParser.add_argument('name', choices=['Doe','Mustermann'], action='store')
    cmdArgs = cmdParser.parse_args()

    # Set starting point in log file
    log.info('Script was called with following parameters: {}'.format(str(sys.argv)))
    log.info('Start script...')
    
    print('{} {} {}'.format(cmdArgs.greet, cmdArgs.title, cmdArgs.name))
    
    log.info('Finished script...')

if __name__ == '__main__':
    main()
