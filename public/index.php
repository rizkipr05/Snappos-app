<?php
require_once __DIR__ . "/../config/cors.php";
require_once __DIR__ . "/../core/response.php";

$method  = $_SERVER["REQUEST_METHOD"] ?? "GET";
$uriPath = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH) ?? "/";

// Handle Method Override (e.g. for Multipart PUT sent as POST)
if ($method === "POST" && isset($_POST["_method"])) {
    $method = strtoupper($_POST["_method"]);
}

$base1 = "/snappos_api/public";
$base2 = "/snappos_api";

if (str_starts_with($uriPath, $base1)) $path = substr($uriPath, strlen($base1));
else if (str_starts_with($uriPath, $base2)) $path = substr($uriPath, strlen($base2));
else $path = $uriPath;

if ($path === "") $path = "/";

// FIX: buang /index.php kalau ada
if (str_starts_with($path, "/index.php")) {
  $path = substr($path, strlen("/index.php"));
  if ($path === "") $path = "/";
}

// rapihin trailing slash (biar /api/health/ tetap dianggap /api/health)
if ($path !== "/" && str_ends_with($path, "/")) {
  $path = rtrim($path, "/");
}

/* ===================== ROUTES ===================== */

// HEALTH
if ($method === "GET" && $path === "/api/health") {
  json(["ok" => true]);
  exit;
}

// AUTH
if ($method === "POST" && $path === "/api/auth/register") {
  require __DIR__ . "/../modules/auth/register.php";
  exit;
}
if ($method === "POST" && $path === "/api/auth/login") {
  require __DIR__ . "/../modules/auth/login.php";
  exit;
}
if ($method === "GET" && $path === "/api/auth/me") {
  require __DIR__ . "/../modules/auth/me.php";
  exit;
}

// PRODUCTS
if ($path === "/api/products" && $method === "GET") {
  require __DIR__ . "/../modules/products/index.php";
  exit;
}
if ($path === "/api/products" && $method === "POST") {
  require __DIR__ . "/../modules/products/store.php";
  exit;
}
if (preg_match("#^/api/products/(\d+)$#", $path, $m) && $method === "PUT") {
  $_GET["id"] = $m[1];
  require __DIR__ . "/../modules/products/update.php";
  exit;
}
if (preg_match("#^/api/products/(\d+)$#", $path, $m) && $method === "DELETE") {
  $_GET["id"] = $m[1];
  require __DIR__ . "/../modules/products/delete.php";
  exit;
}

// TRANSACTIONS
if ($path === "/api/checkout" && $method === "POST") {
  require __DIR__ . "/../modules/transactions/checkout.php";
  exit;
}
if ($path === "/api/transactions" && $method === "GET") {
  require __DIR__ . "/../modules/transactions/history.php";
  exit;
}
if (preg_match("#^/api/transactions/(\d+)$#", $path, $m) && $method === "GET") {
  $_GET["id"] = $m[1];
  require __DIR__ . "/../modules/transactions/detail.php";
  exit;
}

json(["marker" => "NEW_ROUTER_IS_RUNNING", "uri" => $_SERVER["REQUEST_URI"]]);
exit;
