<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]);

if ($_SERVER["REQUEST_METHOD"] !== "DELETE") json(["message"=>"Method not allowed"], 405);

$id = (int)($_GET["id"] ?? 0);
if ($id <= 0) json(["message"=>"Invalid id"], 422);

$pdo = db();
$st = $pdo->prepare("DELETE FROM products WHERE id=?");
$st->execute([$id]);

json(["message"=>"Product deleted"]);
