mm - SSHFS Mount Manager
====================

Requirements
-----------------
 * PHP >= 5.3.x
 * OSXFuse (https://github.com/osxfuse/osxfuse)
 * SSHFS (https://github.com/osxfuse/sshfs)

Install
-----------------
    curl https://raw.github.com/traviskuhl/mm/master/install | php

or if you've cloned the git repo:

    php install

Useage
-----------------
    ./mm [--help] <command> <args>

 1. run `mm add` to add mount settings
 2. run `mm mount <name>` to mount
 3. run `mm unmount <name>` to unmount

mount settings are stored in `~/.mm`

Commands
----------------
    add - add mount settings
    mount - mount from existing settings
    unmount - unmount a mounted drive
    remove - remove mount settings
    list - list save mount settings

Liscense
----------------
Copyright 2010-2011 Travis Kuhl.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.