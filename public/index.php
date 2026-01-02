<?php
require_once __DIR__ . "/../config/cors.php";
require_once __DIR__ . "/../core/response.php";

$uriPath = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);

// kalau akses via http://localhost/snappos_api/public/index.php/api/...
// atau http://localhost/snappos_api/api/...
$base1 = "/snappos_api/public";
$base2 = "/snappos_api";
if (str_starts_with($uriPath, $base1)) $path = substr($uriPath, strlen($base1));
else if (str_starts_with($uriPath, $base2)) $path = substr($uriPath, strlen($base2));
else $path = $uriPath;

if ($path === "") $path = "/";

// HEALTH
if ($path === "/api/health") json(["ok"=>true]);

// AUTH
if ($path === "/api/auth/register") require __DIR__ . "/../modules/auth/register.php";
if ($path === "/api/auth/login") require __DIR__ . "/../modules/auth/login.php";
if ($path === "/api/auth/me") require __DIR__ . "/../modules/auth/me.php";

// PRODUCTS
if ($path === "/api/products" && $_SERVER["REQUEST_METHOD"]==="GET") require __DIR__ . "/../modules/products/index.php";
if ($path === "/api/products" && $_SERVER["REQUEST_METHOD"]==="POST") require __DIR__ . "/../modules/products/store.php";

if (preg_match("#^/api/products/(\d+)$#", $path, $m) && $_SERVER["REQUEST_METHOD"]==="PUT") {
  $_GET["id"] = $m[1];
  require __DIR__ . "/../modules/products/update.php";
}
if (preg_match("#^/api/products/(\d+)$#", $path, $m) && $_SERVER["REQUEST_METHOD"]==="DELETE") {
  $_GET["id"] = $m[1];
  require __DIR__ . "/../modules/products/delete.php";
}

// TRANSACTIONS
if ($path === "/api/checkout") require __DIR__ . "/../modules/transactions/checkout.php";
if ($path === "/api/transactions") require __DIR__ . "/../modules/transactions/history.php";
if (preg_match("#^/api/transactions/(\d+)$#", $path, $m)) {
  $_GET["id"] = $m[1];
  require __DIR__ . "/../modules/transactions/detail.php";
}

json(["message"=>"Not Found", "path"=>$path], 404);
