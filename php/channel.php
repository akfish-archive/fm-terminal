<?php
    // Don't know on the fly how to request data from another URL in PHP, but it's easy to find out
    $response = request_url("http://www.douban.com/j/app/radio/channels");
    echo $_GET['callback'] . '(' . $response . ')';
?>