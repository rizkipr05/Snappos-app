<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/utils.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]);

// Allow POST for multipart/form-data support (method spoofing or direct POST)
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST["_method"]) && strtoupper($_POST["_method"]) === "PUT") {
    // It's a PUT spoofed as POST
} elseif ($_SERVER["REQUEST_METHOD"] !== "PUT" && $_SERVER["REQUEST_METHOD"] !== "POST") {
    json(["message"=>"Method not allowed"], 405);
}

// Handle multipart or JSON
$contentType = $_SERVER["CONTENT_TYPE"] ?? "";
if (strpos($contentType, "application/json") !== false) {
    $data = body_json();
} else {
    $data = $_POST;
}

$id = (int)($_GET["id"] ?? 0);
if ($id <= 0) json(["message"=>"Invalid id"], 422);

$name = isset($data["name"]) ? trim($data["name"]) : null;
$sku = isset($data["sku"]) ? trim($data["sku"]) : null;
$price = isset($data["price"]) ? (int)$data["price"] : null;
$stock = isset($data["stock"]) ? (int)$data["stock"] : null;

// Handle Image Upload
$imagePath = null;
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
$st = $pdo->prepare("SELECT id FROM products WHERE id=? LIMIT 1");
$st->execute([$id]);
if (!$st->fetch()) json(["message"=>"Product not found"], 404);

$fields = [];
$params = [];
if ($sku !== null) { $fields[]="sku=?"; $params[]=$sku; }
if ($name !== null) { $fields[]="name=?"; $params[]=$name; }
if ($price !== null) { $fields[]="price=?"; $params[]=$price; }
if ($stock !== null) { $fields[]="stock=?"; $params[]=$stock; }
if ($imagePath !== null) { $fields[]="image=?"; $params[]=$imagePath; }

if (!$fields) json(["message"=>"No fields to update"], 422);

$params[] = $id;
$sql = "UPDATE products SET ".implode(",", $fields)." WHERE id=?";
$st = $pdo->prepare($sql);
$st->execute($params);

json(["message"=>"Product updated"]);
