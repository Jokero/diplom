<?php

    $base = 'Maps';
    $host = 'localhost';
    $user = 'root';
    $pass = '1';

    mysql_connect($host, $user, $pass) or die('Connection error.');
    mysql_select_db($base);

    mysql_query("SET NAMES 'utf8'");

?>