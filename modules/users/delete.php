<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]);

if ($_SERVER["REQUEST_METHOD"] !== "DELETE") json(["message"=>"Method not allowed"], 405);

$id = (int)($_GET["id"] ?? 0);
if ($id <= 0) json(["message"=>"Invalid id"], 422);

// Prevent self-deletion
if ($id === (int)$user["id"]) json(["message"=>"Cannot delete yourself"], 403);

$pdo = db();
$st = $pdo->prepare("DELETE FROM users WHERE id=?");
$st->execute([$id]);

json(["message"=>"User deleted"]);
