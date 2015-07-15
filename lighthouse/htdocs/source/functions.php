<?

function debug($array = false, $echo = false) {
    if ($array == false)
        return false;

    if ($echo == false) {
        echo '<pre>' . print_r($array, true) . '</pre>';
    } else {
        return '<pre>' . print_r($array, true) . '</pre>';
    }

}

function partial($page, $action, $path = false) {

    if (!$page)
        return;

    if ($path == false) {
        $file = './source/layout/' . $page . '.phtml';
    } else {
        $file = $path . $page . '.phtml';
    }

    $key = md5($file);

    if (file_exists($file)) {
        if (!$partialcache[$key]) {
            $source = implode(file($file));
            $partialcache[$key] = $source;
        }

        ob_start();
        eval("?>" . $partialcache[$key] . "<?");
        $c = ob_get_contents();
        ob_end_clean();
        return $c;
    }
}

function redirect($newLocation) {
    $host = $_SERVER["HTTP_HOST"];
    $dir = rtrim(dirname($_SERVER["PHP_SELF"]), '/\\');
    header("Location: http://$host$dir/$newLocation");
    exit ;
}

function getUriPages($filename = false, $as_sring = false) {

    if ($filename == false)
        $filename = 'index.php';
    $filter = 'abcdefghijklmnopqrstuvwxyz0123456789@./+-_=ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    $base = str_replace($filename, '', urldecode($_SERVER['PHP_SELF']));

    if ($base != '/') {
        $uri = str_replace($base, '', urldecode($_SERVER['REQUEST_URI']));
    } else {
        $uri = substr(urldecode($_SERVER['REQUEST_URI']), 1, strlen(urldecode($_SERVER['REQUEST_URI'])));
    }

    $ux = explode('?', $uri);
    if (count($ux > 1))
        $uri = $ux[0];

    for ($u = 0; $u < strlen($uri); $u++) {
        for ($f = 0; $f < strlen($filter); $f++) {
            if ($uri{$u} == $filter{$f}) {
                $ub .= $uri{$u};
            }
        }
    }

    if ($ub{strlen($ub) - 1} == '/')
        $ub = substr($ub, 0, -1);
    return explode('/', $ub);
}

function dump($arr) {
    return '<pre>' . print_r($arr, true) . '</pre>';
}

function filter($v) {
    $v = stripslashes($v);

    $v = preg_replace('#(<.*?>).*?(</.*?>)#', '$1$2$3', $v);
    $v = filter_var($v, FILTER_SANITIZE_STRIPPED);
    $v = trim($v);
    //$v = str_replace(array('"',"'",';',':','\\','<','>'),'',$v);
    //$v = str_replace(array('"',"'",';',':','\\','<','>'),'',$v);
    return $v;
}

function filterNum($s) {
    $filter = '0123456789';
    $new = '';
    for ($u = 0; $u < strlen($s); $u++) {
        for ($f = 0; $f < strlen($filter); $f++) {
            if ($s{$u} == $filter{$f}) {
                $new .= $s{$u};
            }
        }
    }
    return $new;
}

function filterFloat($s, $round = false, $floatval = true) {

    if ($round == false)
        $round = 2;

    $filter = '0123456789,.';
    $new = '';
    for ($u = 0; $u < strlen($s); $u++) {
        for ($f = 0; $f < strlen($filter); $f++) {
            if ($s{$u} == $filter{$f}) {
                $new .= $s{$u};
            }
        }
    }

    if ($floatval == false)
        return $new;

    $new = str_replace('.', '', $new);
    $new = str_replace(',', '.', $new);

    $new = round(floatval($new), $round);

    return $new;
}

function getParams($key = false) {
    $params = array_merge($_GET, $_POST);
    if ($key == false) {
        return $params;
    } else {
        return $params[$key];
    }
}

function ksortBy($arr, $bykey) {
    $newArr = array();
    if ($arr) {
        foreach ($arr as $i) {
            if (!is_int(substr($i[$bykey], 0, 1))) {
                $newArr[$i[$bykey]] = $i;
            } else {
                $newArr['ks' . $i[$bykey]] = $i;
            }
        }

        ksort($newArr);

        return $newArr;
    }
}

function generateHash($length = false) {
    if ($length == false)
        $length = 4;

    $s = 'ABCDFGHJKLMNPRSTVXYZabcdefghijklmnopqrstufwxyz123456789';
    $r = '';
    for ($i = 0; $i < $length; $i++) {
        $r .= $s{rand(0, (strlen($s) - 1))};
    }
    return $r;
}



function XML2Array(SimpleXMLElement $parent) {
    $array = array();

    foreach ($parent as $name => $element) {
        ($node = &$array[$name]) && (1 === count($node) ? $node = array($node) : 1) && $node = &$node[];

        $node = $element -> count() ? XML2Array($element) : trim($element);
    }

    return $array;
}
?>