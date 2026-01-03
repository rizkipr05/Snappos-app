<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();

if ($_SERVER["REQUEST_METHOD"] !== "GET") json(["message"=>"Method not allowed"], 405);

$id = $_GET["id"] ?? 0;

$pdo = db();

try {
  // 1. Get Transaction
  // 1. Get Transaction
  $st = $pdo->prepare("
    SELECT t.id, t.total, t.paid, t.change_money, t.created_at, t.customer_name, u.name AS cashier_name
    FROM transactions t
    JOIN users u ON u.id = t.user_id
    WHERE t.id = ?
    LIMIT 1
  ");
  $st->execute([$id]);
  $trx = $st->fetch();

  if (!$trx) json(["message" => "Transaction not found"], 404);

  // 2. Get Items (JOIN with products to get name)
  $stItems = $pdo->prepare("
    SELECT ti.id, p.name AS product_name, ti.price, ti.qty, ti.subtotal
    FROM transaction_items ti
    JOIN products p ON p.id = ti.product_id
    WHERE ti.transaction_id = ?
  ");
  $stItems->execute([$id]);
  $items = $stItems->fetchAll();

  // Combine
  $trx["items"] = $items;

  json([
    "data" => $trx
  ]);

} catch (Exception $e) {
  json(["message" => "Server Error: " . $e->getMessage()], 500);
}
