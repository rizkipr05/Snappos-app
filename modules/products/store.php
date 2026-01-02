<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/utils.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]); // cuma admin

if ($_SERVER["REQUEST_METHOD"] !== "POST") json(["message"=>"Method not allowed"], 405);

$data = body_json();
require_fields($data, ["name","price","stock"]);

$sku = trim($data["sku"] ?? "");
$name = trim($data["name"]);
$price = (int)$data["price"];
$stock = (int)$data["stock"];

$pdo = db();
$st = $pdo->prepare("INSERT INTO products (sku,name,price,stock) VALUES (?,?,?,?)");
$st->execute([$sku ?: null, $name, $price, $stock]);

json(["message"=>"Product created", "id"=>$pdo->lastInsertId()], 201);
