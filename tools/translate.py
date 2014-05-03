#!/usr/bin/env python
#
# Copyright (C) 2014 The MoKee OpenSource Project
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

from xml.dom.minidom import parse, Document, Node
import os, sys

reload(sys)
sys.setdefaultencoding('utf-8')

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

def usage():
    print ''
    print 'Usage: translate [language] [file name] [1]'
    print ''
    print 'Compares target XML (strings) with main XML in res/values'
    print 'and points out missing translations. If parameter 1 is given,'
    print 'generates new file'
    print ''
    print 'Note: Must be in res folder, output file will be in home directory'

try:
    if len(sys.argv) == 1:
        usage()
        exit(1)
    if len(sys.argv) == 4:
        if sys.argv[3] != "1":
            print bcolors.FAIL+'Invalid parameters!'+bcolors.ENDC
            usage()
            exit(1)
        else:
            GENFILE = True
    elif len(sys.argv) == 3:
        GENFILE = False
    elif sys.argv[1] == 'help':
        usage()
        exit(1)

    FILE1 = os.path.abspath(os.path.join('values/',sys.argv[2]))
    FILE2 = os.path.abspath(os.path.join('values-'+sys.argv[1],sys.argv[2]))
except IndexError:
    print bcolors.FAIL+'Insufficient parameters!'+bcolors.ENDC
    usage()
    exit(1)

if not os.path.isfile(FILE1):
    print bcolors.FAIL+FILE1+' does not exist!'+bcolors.ENDC
    exit(1)

file1 = parse(FILE1)
doc = Document()
NODE_NIL = []
NODE_LIST1 = []

if os.path.isfile(FILE2):
    NOFILE=False
    file2 = parse(FILE2)
    NODE_LIST2 = []
else:
    NOFILE=True

def compareXML():
    for node in file1.getElementsByTagName('string'):
        if not str(node.getAttribute('translatable')) == 'false':
            NODE_LIST1.append(str(node.getAttribute('name')))
    for node in file2.getElementsByTagName('string'):
        if not str(node.getAttribute('translatable')) == 'false':
            NODE_LIST2.append(str(node.getAttribute('name')))

    for i in NODE_LIST1:
        if i not in NODE_LIST2:
            NODE_NIL.append(i)

def noCompare():
    for node in file1.getElementsByTagName('string'):
        if not str(node.getAttribute('translatable')) == 'false':
            NODE_LIST1.append(str(node.getAttribute('name')))

    NODE_NIL.append(NODE_LIST1)

def genNode(parent, target):
    for i in parent.childNodes:
        if i.nodeType == Node.TEXT_NODE:
            nodeText = doc.createTextNode(i.nodeValue)
            target.appendChild(nodeText)
        else:
            newNode = doc.createElement(i.nodeName)
            j=i.attributes
            count=0
            while count < j.length:
                k=j.item(count)
                newNode.setAttribute(k.name, k.value)
                count+=1
            genNode(i, newNode)
            target.appendChild(newNode)

def genNew():
    if len(NODE_NIL) == 0:
        return

    if not os.path.exists('values-'+sys.argv[1]):
        os.makedirs('values-'+sys.argv[1])
    docPath = os.path.join('values-'+sys.argv[1], sys.argv[2])
    commentText = '\n\
    Copyright (C) 2014 The MoKee OpenSource Project\n\n\
    Licensed under the Apache License, Version 2.0 (the \"License\");\n\
    you may not use this file except in compliance with the License.\n\
    You may obtain a copy of the License at\n\n\
          http://www.apache.org/licenses/LICENSE-2.0\n\n\
    Unless required by applicable law or agreed to in writing, software\n\
    distributed under the License is distributed on an \"AS IS\" BASIS,\n\
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n\
    See the License for the specific language governing permissions and\n\
    limitations under the License.\n'

    comment = doc.createComment(commentText)
    doc.appendChild(comment)
    root = doc.createElement('resources')
    root.setAttribute('xmlns:xliff', 'urn:oasis:names:tc:xliff:document:1.2')
    doc.appendChild(root)
    if not NOFILE:
        values = file2.getElementsByTagName('string')

    for node in NODE_LIST1:
        tempChild = doc.createElement('string')
        tempChild.setAttribute('name', node)
        root.appendChild(tempChild)

        if NOFILE or (node in NODE_NIL):
            nodeText = doc.createTextNode('')
            tempChild.appendChild(nodeText)
        else:
            for i in values:
                if str(i.getAttribute('name')) == node:
                    parent = values[values.index(i)]
                    break

            genNode(parent, tempChild)

    doc.writexml(open(docPath, 'w'),
                 addindent='  ',
                 newl='\n',
                 encoding="UTF-8")

    doc.unlink()

    print ''
    print bcolors.HEADER+'New file created at:'+bcolors.ENDC
    print bcolors.OKGREEN+docPath+bcolors.ENDC

def diffPrint():
    print ''
    if NOFILE:
        print bcolors.OKBLUE+'No translations done before!'+bcolors.ENDC
    elif NODE_NIL == []:
        print bcolors.OKBLUE+'All translations done!'+bcolors.ENDC
    else:
        print bcolors.OKBLUE+'Strings without translation:'+bcolors.ENDC
        for i in NODE_NIL:
            print bcolors.OKGREEN+i+bcolors.ENDC

def main():
    if NOFILE:
        noCompare()
    else:
        compareXML()

    diffPrint()
    if GENFILE:
        genNew()

if __name__ == "__main__":
    main()
