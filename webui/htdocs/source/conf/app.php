<?php

	return array(
	
		'debug'					=>	false,
		'lighthouse_host'		=> 'http://192.168.2.102:8080/relay',
		
		'page_base'				=> 	'http://'.$_SERVER['HTTP_HOST'].''.str_replace('index.php','',$_SERVER['PHP_SELF']),
		'page_name'				=>	'Websocket UI', 
		'page_claim'			=>	'Damn!',
		'page_domain'			=>	$_SERVER['HTTP_HOST'],
		'page_date'				=>	'',
		
		'layout'				=>	'relay',
		
		'frontend_url'			=>	'http://'.$_SERVER['HTTP_HOST'],
		
		// Cache Einstellung in Sekunden
		'cache_db'				=>	'0', // generelle Cache-Dauer
		'cache_html'			=>	'0',
		'cache_geo'				=>	60 * 60 * 24,
		
		'path_temp'				=>	'data/temp',
		'path_image'			=>	'data/images',
		'path_files'			=>	'data/files',
		'path_import'			=>	'data/import',
		'path_mp3'				=>	'data/mp3',
		
		
		// E-Mail Server Einstellung
		'mail'					=>	'XXX@domain.tld',
		'mail_smtp_server'		=>	'smtp.mailhoster.tld',
		'mail_smtp_send_from'	=>	'XXX@domain.tld',
		'mail_smtp_domain'		=>	'domain.tld',
		'mail_smtp_username'	=>	'XXX@domain.tld',
		'mail_smtp_password'	=>	'XXX',
		'mail_smtp_server_port'	=>	'465',
		
		'page_main_navi'		=>	'home,monitor,device,login,logout',
		
		'user_secret'           =>  'change!me'

	);
