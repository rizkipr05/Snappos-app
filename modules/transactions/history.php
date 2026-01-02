<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();

if ($_SERVER["REQUEST_METHOD"] !== "GET") json(["message"=>"Method not allowed"], 405);

$pdo = db();
$st = $pdo->prepare("
  SELECT t.id, t.total, t.paid, t.change_money, t.created_at, u.name AS cashier_name
  FROM transactions t
  JOIN users u ON u.id = t.user_id
  ORDER BY t.id DESC
  LIMIT 100
");
$st->execute();
json(["data"=>$st->fetchAll()]);
