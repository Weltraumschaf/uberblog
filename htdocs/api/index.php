<?php

namespace de\weltraumschaf;

require_once __DIR__ . '/CrossDomainProxy.php';

$configFile = dirname(dirname(__DIR__)) . '/config/proxy.json';
$config = json_decode(file_get_contents($configFile));

$uriPath = !empty($_SERVER['REQUEST_URI'])
         ? $_SERVER['REQUEST_URI']
         : '';

$apiMatch = strpos($uriPath, '/api');

if (false !== $apiMatch) {
    $uriPath = substr($uriPath, $apiMatch + 4);
}

$uri   = "http://{$config->host}:{$config->port}{$uriPath}";

$proxy = CrossDomainProxy::createDefault();
$proxy->start($uri);
