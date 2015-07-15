<?php

class Actions {

    public $action = false;
    public $mode = false;

    public function __construct() {
        global $l;

        $actions = get_class_methods(get_class($this));

        $url = getUriPages();
        $url = array_reverse($url);
        $a = trim($url[count($url) - 1]);

        // set action or redirect
        if (empty($a)) {
            $action = "indexAction";
        } else {
            $action = $a . 'Action';

            if (in_array($action, $actions)) {
                $this -> action = $action;
            } else {
                redirect('');
            }
        }

        //

    }

    /**
     *
     */
    public function process() {
        global $a;
        if ($this -> action == false)
            return;

        return call_user_method($this -> action, $this);
    }

    /**
     *
     */
    public function indexAction() {

    }

    public function getipAction() {
        global $l;
        
        $url = getUriPages();
        $url = array_reverse($url);
        $p = trim($url[count($url) - 2]);

        if (!empty($p)) {
            $params = explode('=', $p);
            
            if (count($params) == 2){
                echo $remote_ip = $l -> request($params[0], $params[1]);
            }
        }
    }
    
    public function tabsAction(){
        global $l;
        $tables = $l->getTables();
        
        echo partial('tabs', array('tabs'=>$tables));
    }
    
    public function getrelayipAction(){
        global $l;
        
        $url = getUriPages();
        $url = array_reverse($url);
        $name = trim($url[count($url) - 2]);
               
        $table = $l->getTable('relay',$name);
        
        echo $table->ip;
    }

}
?>