<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]);

if ($_SERVER["REQUEST_METHOD"] !== "GET") json(["message"=>"Method not allowed"], 405);

$pdo = db();
$st = $pdo->prepare("SELECT id, name, email, role, created_at FROM users ORDER BY name ASC");
$st->execute();
json(["data"=>$st->fetchAll()]);
