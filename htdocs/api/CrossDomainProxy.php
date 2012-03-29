<?php

namespace de\weltraumschaf;

use \HttpRequest as HttpRequest;
use \HttpMessage as HttpMessage;

/**
 * Description of CrossDomainProxy
 *
 * @author Sven Strittmatter <weltraumschaf@googlemail.com>
 * @license http://www.weltraumschaf.de/the-beer-ware-license.txt THE BEER-WARE LICENSE
 */
class CrossDomainProxy {

    private static $headersSpec = array(
        'Accept'          => 'HTTP_ACCEPT',
        'Accept-Encoding' => 'HTTP_ACCEPT_ENCODING',
        'Accept-Language' => 'HTTP_ACCEPT_LANGUAGE',
        'Connection'      => 'HTTP_CONNECTION',
        'User-Agent'      => 'HTTP_USER_AGENT',
    );

    /**
     * @var HttpRequest
     */
    private $request;

    /**
     *
     * @return CrossDomainProxy
     */
    public static function createDefault() {
        if (!class_exists('HttpRequest', false)) {
            throw new \RuntimeException("No class def HttpRequest found! Please install pecl_http.");
        }
        return new static(new HttpRequest());
    }

    public function __construct(HttpRequest $requst) {
        $this->request = $requst;
    }

    private function getRequestHeaders() {
        $headers = array();

        foreach (self::$headersSpec as $name => $key) {
            if (!empty($_SERVER[$key])) {
                $headers[$name] = $_SERVER[$key];
            }
        }

        return $headers;
    }

    private function getRequestMethod() {
        $method = HttpRequest::METH_GET;

        switch (strtolower($_SERVER['REQUEST_METHOD'])) {
            case 'get':     $method = HttpRequest::METH_GET;    break;
            case 'post':    $method = HttpRequest::METH_POST;   break;
            case 'put':     $method = HttpRequest::METH_PUT;    break;
            case 'delete':  $method = HttpRequest::METH_DELETE; break;
        }

        return $method;
    }

    private function sendRequest($uri) {
        $this->request->setUrl($uri);
        $this->request->setMethod($this->getRequestMethod());
        $headers = $this->getRequestHeaders();
        $this->request->setHeaders($headers);
        $body = http_get_request_body();

        if ($this->request->getMethod() === HttpRequest::METH_PUT) {
            $this->request->setPutData($body);
        } else {
            $this->request->setBody($body);
        }

        return $this->request->send();
    }

    private function sendResponse(HttpMessage $response) {
        $versionHeader  = "HTTP/{$response->getHttpVersion()} ";
        $versionHeader .= "{$response->getResponseCode()} {$response->getResponseStatus()}";
        $headers = $response->getHeaders();
        array_unshift($headers, $versionHeader);

        foreach ($headers as $name => $value) {
            header("{$name}: {$value}");
        }

        echo $response->getBody();
    }

    private function sendHeader($name, $value) {
        header("{$name}: {$value}");
    }

    public function start($uri) {
        $response = $this->sendRequest($uri);
        $this->sendResponse($response);
    }
}
