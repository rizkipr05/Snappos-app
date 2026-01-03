<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth(); // semua role boleh lihat

$pdo = db();
$rows = $pdo->query("
    SELECT 
        id,
        sku,
        name,
        price,
        stock,
        image,
        created_at
    FROM products
    ORDER BY id DESC
")->fetchAll(PDO::FETCH_ASSOC);

json(["data" => $rows]);
