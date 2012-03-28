<?php
$uri    = 'http://localhost:4567';
$uri    .= !empty($_SERVER['REQUEST_URI'])
        ? str_replace('/~sxs/uberblog/api', '', $_SERVER['REQUEST_URI'])
        : '/';
$method = HttpRequest::METH_GET;

switch (strtolower($_SERVER['REQUEST_METHOD'])) {
    case 'get':     $method = HttpRequest::METH_GET;    break;
    case 'post':    $method = HttpRequest::METH_POST;   break;
    case 'put':     $method = HttpRequest::METH_PUT;    break;
    case 'delete':  $method = HttpRequest::METH_DELETE; break;
}

$request = new HttpRequest($uri, $method);
$headersSpec = array(
    'Accept'          => 'HTTP_ACCEPT',
    'Accept-Encoding' => 'HTTP_ACCEPT_ENCODING',
    'Accept-Language' => 'HTTP_ACCEPT_LANGUAGE',
    'Connection'      => 'HTTP_CONNECTION',
    'User-Agent'      => 'HTTP_USER_AGENT',
);
$headers = array();

foreach ($headersSpec as $name => $key) {
    if (!empty($_SERVER[$key])) {
        $headers[$name] = $_SERVER[$key];
    }
}

$request->setHeaders($headers);
$response = $request->send();

header("HTTP/{$response->getHttpVersion()} {$response->getResponseCode()} {$response->getResponseStatus()}");

foreach ($response->getHeaders() as $name => $value) {
    header("{$name}: {$value}");
}

echo $response->getBody();