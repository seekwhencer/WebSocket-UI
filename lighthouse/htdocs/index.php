<?php
    session_start();
    
    include_once('source/config.php');
    include_once('source/functions.php');
    include_once('source/actions.php');
    
    include_once('source/lib/Lighthouse.php');
    include_once('source/lib/LighthouseClient.php');
    
    $l = new Lighthouse();    
    $a = new Actions();
    
    $a->process();


?>