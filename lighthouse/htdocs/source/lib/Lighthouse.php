<?php

class Lighthouse {

    var $wan_ip;

    var $accepted_nodes = array(
        'relay' => array('main'),
        'device' => array('orb'),
        'webui' => array(
            'desktop',
            'mobile',
            'smartphone',
            'pipboy'
    ));
    var $tables_folder = "tables";
    var $log_file = 'logs/lighthouse_connections.json';
    var $log_time = 3600; // in seconds :) 3600 = Hour, 21600 = 6 Hours, 43200 = 12 Hours, 86400 = One Day
    var $log_every_ping = false;

    public function __construct() {
        $this -> wan_ip = $_SERVER['SERVER_ADDR'];
    }

    public function request($mode, $name) {
        $keys = array_keys($this -> accepted_nodes);
        if (in_array($mode, $keys)) {
            if (in_array($name, $this -> accepted_nodes[$mode])) {
                $this -> logRequest($_SERVER['REMOTE_ADDR'], $mode, $name);
            }
        }

        return $_SERVER['REMOTE_ADDR'];
    }

    public function logRequest($ip, $mode, $name) {
        $log = array('ip' => $ip, 'mode' => $mode, 'name' => $name, 'time' => time());

        $write = json_encode($log);
        
        if($this->log_every_ping)
            file_put_contents($this -> log_file, $write . "\n", FILE_APPEND | LOCK_EX);
    
        file_put_contents($this -> tables_folder . "/" . $mode . "-" . $name . ".json", $write);

        //$this->cutLog();
    }

    public function cutLog() {

    }

    public function getTables() {
        
        $dir = utf8_decode($this -> tables_folder . "/");

        $files = array();
        $dirs = array();
        foreach (new DirectoryIterator(($dir)) as $fileInfo) {
            if ($fileInfo -> getExtension() == 'json') {
                $name = utf8_encode($fileInfo -> getFilename());
                $item = array(
                    'name'      => str_replace('.json', '', $name),
                    'filename'  => $name,
                );

                if ($fileInfo -> isFile()) {
                    $files[] = $item;
                }
            }
        }
        
        $data = array();
        
        foreach($files as $f){
           $data[] = json_decode(implode(file($this->tables_folder."/".$f['filename'])));
        }

        return $data;

    }
    
    public function getTable($mode, $name){
        $filename = $this->tables_folder."/".$mode."-".$name.".json";
        
        if(!file_exists($filename))
            return false;
        
        return json_decode(implode(file($filename)));
    }

}
?>