<?php

			$this->route = array(
						
						'home' 							=> array(
																'label'			=>'Home',
																'slug'			=>'home',
																'module'		=>'main',
																'controller'	=>'main',
																'action'		=>'index',
																'view'			=>'home',
																'is_login'		=>'both',
																'navi'			=>'header',
																'navi_icon'		=>'home'
																
												    ),
                                                    
						'login'								=> array(
																'label'			=>'Login',
																'slug'			=>'login',
																'module'		=>'user',
																'controller'	=>'user',
																'action'		=>'login',
																'is_login'		=>false,
																'navi'			=>'header',
																'navi_icon'		=>'sign-in',
													),
						'logout'							=> array(
																'label'			=>'Logout',
																'slug'			=>'logout',
																'module'		=>'user',
																'controller'	=>'user',
																'action'		=>'logout',
																'is_login'		=>true,
																'navi'			=>'header',
																'navi_icon'		=>'sign-out',
													),
													
                         'monitor'                          => array(
                                                                'label'         =>'Monitor',
                                                                'slug'          =>'monitor',
                                                                'module'        =>'monitor',
                                                                'controller'    =>'monitor',
                                                                'action'        =>'index',
                                                                'is_login'      =>true,
                                                                'navi'          =>'header',
                                                                'navi_icon'     =>'heartbeat',
                                                    ),
                         'monitor/getrelayip'                          => array(
                                                                'label'         =>'Get Relay IP',
                                                                'slug'          =>'monitor/getrelayip',
                                                                'module'        =>'monitor',
                                                                'controller'    =>'monitor',
                                                                'action'        =>'getrelayip',
                                                                'is_login'      =>true,
                                                                'is_xhr'	 	=>true
                                                    ),
                        
                         'device'                          => array(
                                                                'label'         =>'Device',
                                                                'slug'          =>'device',
                                                                'module'        =>'device',
                                                                'controller'    =>'device',
                                                                'action'        =>'index',
                                                                'is_login'      =>true,
                                                                'navi'          =>'header',
                                                                'navi_icon'     =>'arrows',
                                                    ),
                         					
				);
?>