<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/utils.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]);

if ($_SERVER["REQUEST_METHOD"] !== "POST") json(["message"=>"Method not allowed"], 405);

$data = body_json();
require_fields($data, ["name","email","password"]);

$name = trim($data["name"]);
$email = strtolower(trim($data["email"]));
$password = $data["password"];
$role = $data["role"] ?? "cashier";
if (!in_array($role, ["admin","cashier"], true)) $role = "cashier";

$pdo = db();

// Check if email exists
$st = $pdo->prepare("SELECT id FROM users WHERE email=? LIMIT 1");
$st->execute([$email]);
if ($st->fetch()) json(["message"=>"Email already registered"], 409);

$hash = password_hash($password, PASSWORD_BCRYPT);
$st = $pdo->prepare("INSERT INTO users (name,email,password_hash,role) VALUES (?,?,?,?)");
$st->execute([$name,$email,$hash,$role]);

json(["message"=>"User created", "id"=>$pdo->lastInsertId()], 201);
