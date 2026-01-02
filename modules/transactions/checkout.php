<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/utils.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth(); // admin/cashier boleh

if ($_SERVER["REQUEST_METHOD"] !== "POST") json(["message"=>"Method not allowed"], 405);

$data = body_json();
require_fields($data, ["items","paid"]);

$items = $data["items"];
$paid = (int)$data["paid"];
if (!is_array($items) || count($items) === 0) json(["message"=>"Items required"], 422);

$pdo = db();
$pdo->beginTransaction();

try {
  // hitung total + cek stok
  $total = 0;
  $normalized = [];

  foreach ($items as $it) {
    $pid = (int)($it["product_id"] ?? 0);
    $qty = (int)($it["qty"] ?? 0);
    if ($pid <= 0 || $qty <= 0) json(["message"=>"Invalid item"], 422);

    $st = $pdo->prepare("SELECT id,name,price,stock FROM products WHERE id=? FOR UPDATE");
    $st->execute([$pid]);
    $p = $st->fetch();
    if (!$p) json(["message"=>"Product not found: $pid"], 404);
    if ((int)$p["stock"] < $qty) json(["message"=>"Stock not enough for ".$p["name"]], 422);

    $price = (int)$p["price"];
    $subtotal = $price * $qty;
    $total += $subtotal;

    $normalized[] = [
      "product_id"=>$pid,
      "qty"=>$qty,
      "price"=>$price,
      "subtotal"=>$subtotal
    ];
  }

  if ($paid < $total) json(["message"=>"Paid is less than total", "total"=>$total], 422);
  $change = $paid - $total;

  // insert transaksi
  $st = $pdo->prepare("INSERT INTO transactions (user_id,total,paid,change_money) VALUES (?,?,?,?)");
  $st->execute([(int)$user["id"], $total, $paid, $change]);
  $trxId = (int)$pdo->lastInsertId();

  // items + update stock
  $sti = $pdo->prepare("INSERT INTO transaction_items (transaction_id,product_id,qty,price,subtotal) VALUES (?,?,?,?,?)");
  $stu = $pdo->prepare("UPDATE products SET stock = stock - ? WHERE id=?");

  foreach ($normalized as $it) {
    $sti->execute([$trxId, $it["product_id"], $it["qty"], $it["price"], $it["subtotal"]]);
    $stu->execute([$it["qty"], $it["product_id"]]);
  }

  $pdo->commit();
  json(["message"=>"Checkout success", "transaction_id"=>$trxId, "total"=>$total, "paid"=>$paid, "change"=>$change], 201);

} catch (Exception $e) {
  $pdo->rollBack();
  json(["message"=>"Server error", "error"=>$e->getMessage()], 500);
}
