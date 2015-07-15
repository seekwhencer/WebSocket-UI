<?php

class monitorController {

	public function indexAction() {
		global $_u, $_c, $_p;

		$_p -> addScript('jquery.wsrelay.js');
		$_p -> addScript('jquery.wsrelayui.js');
        
        $_p -> addStyle('monitor.css');
        
		$action = array('nothing' => 'not');

		return $action;

	}

	public function getrelayipAction() {
		global $_u, $_c, $_p;
		
		$relay_name = filter($_c -> getUriParams(1));
		$lighthouse_url = LIGHTHOUSE_HOST.'/getrelayip/'.$relay_name;
		
		echo $relay_host = trim(implode(file($lighthouse_url)));

	}

}
