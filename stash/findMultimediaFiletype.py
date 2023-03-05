#!/bin/python

##
## Override the internal filetype command.
##
## Originally written: 2017-08-01
## See: https://gist.github.com/renoirb/89b9fce3ab41dc08002a806e926d9282#file-index-sh
## Time Spent: ~
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##

# UNFINISHED
#
# @TODO Move as /usr/bin/filetype or adjust findMultimediaFiles.sh
#
# It also might require a mime python module.
#
# TODO: find which pip module install was successful.

import sys
fileName = sys.argv[1]

# os.path.exists(media.encode('utf-8')

import os
stat = os.stat(fileName)
fileSize = stat.st_size

import hashlib

class FileHasher(object):
    '''
    Hash file contents
    '''
    def __init__(self, path, alg='sha1'):
        self.path = path
        if alg == 'sha1':
            self.hasher = hashlib.md5()
        elif alg == 'md5':
            self.hasher = hashlib.sha1()
        else:
            raise ValueError('Unsupported Hashing algorithm')
        with open(path, 'rb') as File:
            while True:
                data = File.read(0x100000)
                if not data:
                    break
                self.hasher.update(data)

    def __str__(self):
        return '{0}'.format(self.hasher.hexdigest())


fileHash = FileHasher(fileName, 'sha1')

## e.g.
#print stat
#posix.stat_result(st_mode=33279, st_ino=12602, st_dev=16657, st_nlink=1, st_uid=1024, st_gid=100, st_size=4109788, st_atime=1440119440, st_mtime=1287784330, st_ctime=1400614047)

from mimetypes import MimeTypes
mime = MimeTypes()
fileType = mime.guess_type(fileName)

print '"{}","{}","{}","{}"'.format(fileName, fileType[0], fileSize, fileHash)
