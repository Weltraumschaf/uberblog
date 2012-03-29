<?php

namespace de\weltraumschaf;

$baseDir = dirname(dirname(__DIR__));

require_once "{$baseDir}/lib/CrossDomainProxy.php";

$config = json_decode(file_get_contents("{$baseDir}/config/proxy.json"));

$uriPath = !empty($_SERVER['REQUEST_URI'])
         ? $_SERVER['REQUEST_URI']
         : '';

$apiMatch = strpos($uriPath, '/api');

if (false !== $apiMatch) {
    $uriPath = substr($uriPath, $apiMatch + 4);
}

$uri   = "http://{$config->host}:{$config->port}{$uriPath}";

$proxy = CrossDomainProxy::createDefault($_SERVER['HTTP_HOST'], $config->host);
$proxy->start($uri);
