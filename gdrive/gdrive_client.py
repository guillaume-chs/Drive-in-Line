#!/usr/bin/python

import sys
from sys import platform as _platform
sys.argv = ['']

import os.path
import subprocess

from gdrive.pydrive.auth import GoogleAuth
from gdrive.pydrive.drive import GoogleDrive


file_type = {
    'folder': 'application/vnd.google-apps.folder'
}

class GoogleDriveClient():

    def __init__(self):
        print("Google Drive client, written in Python by G. Chanson")

    def connect(self):
        gauth = GoogleAuth()
        gauth.LocalWebserverAuth()

        self.drive = GoogleDrive(gauth)

    def list_dir_files(self, dir_id='root'):
        query = "'%s' in parents and trashed=false" % dir_id
        files = self.drive.ListFile({'q': query})
        return files.GetList()


    def download_file(self, file_id, file_name=None):
        if file_name is not None:
            if os.path.isfile(file_name):
                print('File already exists at %s' % file_name)
                return file_name

        file = self.drive.CreateFile({'id': file_id})
        if file_name is None:
            file_name = file['title']

        file.GetContentFile(file_name)
        print('Downloaded file %s to %s' % (file['title'], file_name))
        return file_name

    def upload_file(self, filename):
        file = self.drive.CreateFile()
        file.SetContentFile(filename)
        file.Upload()
        print('Uploaded %s' % filename)

    def rename_file(self, file_id, file_name):
        file = self.drive.CreateFile({'id': file_id})
        file['title'] = file_name
        file.Upload()
        print('Uploaded file  %s' % file['title'])

    def open_file(self, file_id):
        file_path = self.download_file(file_id, '/tmp/' + file_id)

        if _platform == "linux" or __platform == "linux2":
            subprocess.call(['xdg-open', file_path])
        elif _platform == "darwin":
            subprocess.call(['open', file_path])       
        elif _platform == "win32":
            subprocess.call(['start', file_path])

gdrive = GoogleDriveClient()
