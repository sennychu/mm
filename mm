#!/usr/bin/env php
<?php
////////////////////////////////////////////////////
// Copyright 2010-2011 Travis Kuhl (travis@kuhl.co)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom
// the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF  CONTRACT, TORT
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////

class mm {

    private $user;
    private $home;
    private $cfg = array();

    public function __construct($args=array()) {
        $this->user = (array_key_exists('SUDO_USER', $_SERVER) ? $_SERVER['SUDO_USER'] : $_SERVER['USER']);
        $this->home = (array_key_exists('HOME', $_SERVER) ? $_SERVER['HOME'] : realpath("~"));
        $this->cfgFile = "{$this->home}/.mm";
        $this->cfg = (file_exists($this->cfgFile) ? parse_ini_file($this->cfgFile, true) : array());

        $cmd = array_shift($args);

        $this->args = $args;

        $launch = array('ssh', 'subl');

        if ($cmd == 'unmount' OR $cmd == 'un') {
            $this->unmount($args[0]);
        }
        else if ($cmd == 'list' OR $cmd == 'ls') {
            $this->ls();
        }
        else if ($cmd == 'remove') {
            $this->remove($args[0]);
        }
        else if ($cmd == 'add') {
            $this->add();
        }
        else if (in_array($cmd, $launch)) {
            $this->launch($cmd);
        }
        else if ($cmd == '-h' OR $cmd == '--help' OR $cmd == 'help') {
            $this->help();
        }
        else if ($cmd OR $cmd == 'mount') {
            $this->mount(($cmd == 'mount' ? $args[0] : $cmd));
        }
        else {
            $this->help();
        }

    }

    public function __destruct() {
        $res = array();
        foreach($this->cfg as $key => $val) {
            if(is_array($val)) {
                $res[] = "[$key]";
                foreach($val as $skey => $sval) $res[] = "$skey = ".(is_numeric($sval) ? $sval : '"'.$sval.'"');
            }
            else $res[] = "$key = ".(is_numeric($val) ? $val : '"'.$val.'"');
        }
        file_put_contents($this->cfgFile, implode("\r\n", $res));
    }


    public function help() {
        $cmds = ' %-10s %s';
        $lines = array(
            'usage: mm <command> [<args>]',
            '',
            'Commands:',
            array($cmds, 'add', 'Add a mount'),
            array($cmds, 'list', 'List mounts'),
            array($cmds, 'mount', 'Mount'),
            array($cmds, 'remove', 'Remove a mount'),
            array($cmds, 'ssh', "Open tab with `ssh` connected to mount settings"),
            array($cmds, 'subl', "Open Submlime Text to local mount folder"),
            array($cmds, 'unmount', 'Unmount'),
            '',
            'Helpful Shortcuts:',
            ' mm mount all',
            ' mm unmount all'
        );
        foreach ($lines as $line) {
            echo (is_array($line) ? call_user_func_array('sprintf', $line) : $line)."\n";
        }
        echo "\n";
        return;
    }

    public function mount($name) {
        if ($name === 'all') {return $this->_all('mount');}
        if (!array_key_exists($name, $this->cfg)) {
            echo "No mount named '$name'. Try `./mm add` first\n"; return;
        }

        // cfg
        $cfg = $this->cfg[$name];

        // local doesn't exist
        if (!file_exists($cfg['local'])) {
            mkdir($cfg['local'], 0777, true);
        }
        if (!file_exists($cfg['local'])) {
            echo "Local folder '{$cfg['local']}' doesn't exist.\n"; return;
        }

        // run the command
        $cmd = "sshfs -p {$cfg['port']} {$cfg['username']}@{$cfg['host']}:{$cfg['dir']} {$cfg['local']}";

        // last cmd
        $this->cfg[$name]['last'] = $cmd;

        // run the cmd
        $resp = exec($cmd);

        // get our pout
        $this->cfg[$name]['pid'] = exec("ps aux | grep '$cmd' | grep -v grep | awk '{ print $2 }' | head -1");

        echo "Mounted!\n";

    }

    public function unmount($name) {
        if ($name === 'all') {return $this->_all('unmount');}
        if (!array_key_exists($name, $this->cfg)) {
            echo "No mount '$name'.\n"; return;
        }

        $cfg = $this->cfg[$name];

        // see if we have a pid
        if (!$cfg['pid']) {
            $cfg['pid'] = exec("ps aux | grep '{$cfg['last']}' | grep -v grep | awk '{ print $2 }' | head -1");
        }

        // no pid
        if (!$cfg['pid']) {
            echo "Unable to find pid for this mount.\n"; return;
        }

        // check if
        exec("ps -p {$cfg['pid']}", $o, $r);

        if ($r === 1) {
            $this->cfg[$name]['pid'] = false;
            echo "Mount '$name' is not running (old pid {$cfg['pid']}).\n"; return;
        }

        // unmount
        exec("umount -f {$cfg['local']}");

        // kill
        posix_kill($cfg['pid'], 9);

        $this->cfg[$name]['pid'] = false;

        echo "Unmounted!\n";

        return;

    }

    public function add() {

        $name = $this->_ask("Name of mount:");
        $cfg = array();

        $cfg['username'] = $this->_ask(" Username:", $this->user);
        $cfg['host'] = $this->_ask(" Host:");
        $cfg['port'] = $this->_ask(" Port:", 22);
        $cfg['dir'] = $this->_ask(" Remote Dir:");
        $cfg['local'] = $this->_ask(" Local Folder:", "./$name");

        if ($cfg['local']{0} == '~') {
            $cfg['local'] = str_replace("~", $this->home, $cfg['local']);
        }

        if (!file_exists($cfg['local'])) {
            mkdir($cfg['local'], 0777, true);
        }

        $cfg['local'] = realpath($cfg['local']);

        // things we need
        $cfg['pid'] = false;
        $cfg['last_cmd'] = false;

        // add to config
        $this->cfg[$name] = $cfg;

        // done
        echo "Mount '$name' added!\n";

    }

    public function remove($name) {
        if (!array_key_exists($name, $this->cfg)) {
            echo "No mount '$name'.\n"; return;
        }
        unset($this->cfg[$name]);
        echo "Removed mount '$name'.\n";
    }

    public function ls() {
        foreach ($this->cfg as $name => $cfg) {
            echo sprintf("%-20s %-50s %d\n", $name, "{$cfg['username']}@{$cfg['host']}:{$cfg['dir']}", $cfg['pid']);
        }
    }

    public function launch($cmd) {
        $name = $this->args[0];
        if (!array_key_exists($name, $this->cfg)) {
            echo "No mount '$name'.\n"; return;
        }
        $cfg = $this->cfg[$name];
        switch($cmd) {
            case 'ssh':
                $run = "ssh -p {$cfg['port']} {$cfg['username']}@{$cfg['host']}";
                exec('osascript -e "tell application \"Terminal\"" -e "tell application \"System Events\" to keystroke \"t\" using {command down}" -e "do script \"'.$run.'\" in front window" -e "end tell" > /dev/null'); break;
            case 'subl':
                exec("/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl {$cfg['local']}"); break;
            default:
                echo "Unknown launch command\n";
        };
    }

    public function _all($func) {
        foreach ($this->cfg as $name => $x) {
            call_user_func(array($this, $func), $name);
        }
    }

    public function _ask($q, $def=false) {
        echo $q . ($def ? " [$def] " : " ");
        $name = trim(fgets(STDIN));
        return ($name ?: $def);
    }

}

array_shift($argv);

new mm($argv);