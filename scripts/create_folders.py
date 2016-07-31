"""
This script will be used to create my standard folder structures
"""
import sys
from subprocess import call

DATA_ANALYTICS = ['raw_data', 'out_data', 'scripts', 'viz', 'stg_data', 'docs']
WEB_SITE = ['scripts', 'templates', 'js', 'db', 'docs']
OS_APPLICATION = ['scripts', 'bin', 'db', 'docs']

def create_folders(str_folders, str_location):
    """
    Creates the folders in the OS
    """
    for folder in str_folders:
        call(['mkdir', str_location + '/' + folder])
    call(['git', 'init'])

def main_process():
    """
    Main Function
    """
    curr_location = '.'
    if len(sys.argv):
        curr_location = sys.argv[1]

    print('Please select the application type you are creating:\r\n' + \
            '1) Data Analytics Project\r\n' + \
            '2) Web Site Project\r\n' + \
            '3) Desktop Application\r\n')
    opt_selected = input('-> ')

    if opt_selected == '1':
        create_folders(DATA_ANALYTICS, curr_location)
    elif opt_selected == '2':
        create_folders(WEB_SITE, curr_location)
    else:
        create_folders(OS_APPLICATION, curr_location)

main_process()
