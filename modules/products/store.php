<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/utils.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin", "cashier"]); // admin & cashier

if ($_SERVER["REQUEST_METHOD"] !== "POST") json(["message"=>"Method not allowed"], 405);

// Handle multipart or JSON
$contentType = $_SERVER["CONTENT_TYPE"] ?? "";
if (strpos($contentType, "application/json") !== false) {
    $data = body_json();
} else {
    $data = $_POST;
}

require_fields($data, ["name","price","stock"]);

$sku = trim($data["sku"] ?? "");
$name = trim($data["name"]);
$price = (int)$data["price"];
$stock = (int)$data["stock"];
$imagePath = null;

// Handle Image Upload
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = __DIR__ . "/../../public/uploads/products/";
    if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);
    
    $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
    $filename = uniqid("prod_") . "." . $ext;
    $dest = $uploadDir . $filename;
    
    if (move_uploaded_file($_FILES['image']['tmp_name'], $dest)) {
        $imagePath = "uploads/products/" . $filename;
    }
}

$pdo = db();
$st = $pdo->prepare("INSERT INTO products (sku,name,price,stock,image) VALUES (?,?,?,?,?)");
$st->execute([$sku ?: null, $name, $price, $stock, $imagePath]);

json(["message"=>"Product created", "id"=>$pdo->lastInsertId()], 201);
