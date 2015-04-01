#!/usr/bin/env python
#
# Copyright (C) 2015 The MoKee OpenSource Project
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
import os, sys, codecs

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
    print 'Usage: clearstr [source] [target] [output]'
    print ''
    print 'Compares target XML (strings) with source XML,'
    print 'removes elements that are not in source XML and generates'
    print 'a new XML file based on target XML.'
    print ''
    print 'Example:'
    print 'clearstr res/values/cm_strings.xml res/values-zh-rCN/cm_strings.xml ~/cm_strings.xml'

try:
    if len(sys.argv) == 1:
        usage()
        exit(1)
    elif sys.argv[1] == 'help':
        usage()
        exit(1)

    SRC = os.path.abspath(os.path.expanduser(sys.argv[1]))
    TARGET = os.path.abspath(os.path.expanduser(sys.argv[2]))
    OUT = os.path.abspath(os.path.expanduser(sys.argv[3]))
except IndexError:
    print bcolors.FAIL+'Insufficient parameters!'+bcolors.ENDC
    usage()
    exit(1)

try:
    src = parse(SRC)
    target = parse(TARGET)
except Exception as e:
    print bcolors.FAIL+str(e)+bcolors.ENDC
    exit(1)

def compareXML():
    node_src = []

    for node in src.getElementsByTagName('string'):
        if not str(node.getAttribute('translatable')) == 'false':
            node_src.append(str(node.getAttribute('name')))
    for node in target.getElementsByTagName('string'):
        if node.getAttribute('name') not in node_src:
            target.documentElement.removeChild(node.previousSibling)
            target.documentElement.removeChild(node)

def main():
    compareXML()
    try:
        target.writexml(open(OUT, 'w'),encoding='utf-8')
        with codecs.open(OUT, 'r', encoding='utf-8') as f:
            tmp = f.read()
        out = tmp.replace('-->','-->\n').replace('><!--','>\n<!--')
        with codecs.open(OUT, 'w', encoding='utf-8') as f:
            f.write(out)
    except Exception as e:
        print bcolors.FAIL+str(e)+bcolors.ENDC
        exit(1)
    print bcolors.OKBLUE+'Done!'+bcolors.ENDC

if __name__ == "__main__":
    main()
