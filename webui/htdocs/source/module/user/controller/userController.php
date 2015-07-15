<?php

    class userController {
        
        public function indexAction(){
            
        }
        
        public function loginAction(){
            global $_u;
            $params = getParams('login');
            if(trim($params['secret'])==USER_SECRET){
                $_u->login();
                redirect('monitor');
            }
            
        }
        
        public function logoutAction(){
            global $_u;
            $_u->logout();
            redirect('home');
        }
        
        
    }
?>