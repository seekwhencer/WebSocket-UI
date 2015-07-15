<?php

    /**
     * 
     */
    class deviceController {
        
        public function indexAction() {
            global $_u, $_c, $_p;
    
            $_p -> addScript('jquery.wsrelay.js');
            $_p -> addScript('jquery.wsdeviceui.js');
            
            $_p -> addStyle('device.css');
            
            $action = array('nothing' => 'not');
    
            return $action;
    
        }
    }
    