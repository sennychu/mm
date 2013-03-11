mm - SSHFS Mount Manager
====================

Requirements
-----------------
 * PHP >= 5.3.x
 * [OSXFuse](https://github.com/osxfuse/osxfuse)
 * [SSHFS](https://github.com/osxfuse/sshfs)

Notes
------------------
 * I've only tested on OSX 10.8.2. No idea if it will work anywhere else
 * Yes it's written in PHP.

Install
-----------------
 1. [download](https://github.com/downloads/osxfuse/osxfuse/OSXFUSE-2.5.4.dmg) & install [OSXFuse](https://github.com/osxfuse/osxfuse)
 2. [download](https://github.com/downloads/osxfuse/sshfs/SSHFS-2.4.1.pkg) & install [SSHFS](https://github.com/osxfuse/sshfs)
 3. `curl https://raw.github.com/traviskuhl/mm/master/install | sudo php`



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
    list - list save mount settings
    mount - mount from existing settings
    remove - remove mount settings
    ssh - launch a new Terminal tab and ssh to mount
    subl - launch Submlime Text in mount local folder
    unmount - unmount a mounted drive

Helpful Shortcuts
-------------------
    `mm mount all` - mount all settings
    `mm unmount all` - unmount all settings


Liscense
----------------
Copyright 2013 Travis Kuhl (travis@kuhl.co)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.