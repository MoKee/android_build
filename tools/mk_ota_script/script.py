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

import sys

j=False

script = sys.argv[1]

print "ui_print(\"Creating symlinks...\");"
f = open(script, "r")
for i in f.readlines():
    if j:
        print i.rstrip()
    elif "symlink" in i:
        print i.rstrip()
        j=True
    if '");' in i:
        j=False 
f.close()

print ""
print "ui_print(\"Setting metadata...\");"
f = open(script, "r")
for i in f.readlines():
    if "set_metadata" in i and not "tmp" in i:
        print i.rstrip()
f.close()
