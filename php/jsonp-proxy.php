<?php
    // Don't know on the fly how to request data from another URL in PHP, but it's easy to find out
    $base64_url = $_GET['url'];
    $url = base64_decode($base64_url);
    
    $base64_payload = $_GET['payload'];
    $payload = base64_decode($base64_payload);
    
    $c = curl_init($url + "?" + $payload);
    curl_setopt($c, CURLOPT_RETURNTRANSFER, true);
    //curl_setopt(... other options you want...)
    
    $response = curl_exec($c);
    
    if (curl_error($c))
    	die(curl_error($c));
    
    // Get the status code
    $status = curl_getinfo($c, CURLINFO_HTTP_CODE);
    curl_close($c);
    //$response = file_get_contents("http://www.douban.com/j/app/radio/channels");
    echo $_GET['callback'] . '(' . $response . ')';
?>