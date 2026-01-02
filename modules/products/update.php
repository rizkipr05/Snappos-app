<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/utils.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]);

if ($_SERVER["REQUEST_METHOD"] !== "PUT") json(["message"=>"Method not allowed"], 405);

$id = (int)($_GET["id"] ?? 0);
if ($id <= 0) json(["message"=>"Invalid id"], 422);

$data = body_json();
$name = isset($data["name"]) ? trim($data["name"]) : null;
$sku = isset($data["sku"]) ? trim($data["sku"]) : null;
$price = isset($data["price"]) ? (int)$data["price"] : null;
$stock = isset($data["stock"]) ? (int)$data["stock"] : null;

$pdo = db();
$st = $pdo->prepare("SELECT id FROM products WHERE id=? LIMIT 1");
$st->execute([$id]);
if (!$st->fetch()) json(["message"=>"Product not found"], 404);

$fields = [];
$params = [];
if ($sku !== null) { $fields[]="sku=?"; $params[]=$sku; }
if ($name !== null) { $fields[]="name=?"; $params[]=$name; }
if ($price !== null) { $fields[]="price=?"; $params[]=$price; }
if ($stock !== null) { $fields[]="stock=?"; $params[]=$stock; }

if (!$fields) json(["message"=>"No fields to update"], 422);

$params[] = $id;
$sql = "UPDATE products SET ".implode(",", $fields)." WHERE id=?";
$st = $pdo->prepare($sql);
$st->execute($params);

json(["message"=>"Product updated"]);
