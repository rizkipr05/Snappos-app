<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/utils.php";
require_once __DIR__ . "/../../core/auth.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") json(["message"=>"Method not allowed"], 405);

$data = body_json();
require_fields($data, ["email","password"]);

$email = strtolower(trim($data["email"]));
$password = $data["password"];

$pdo = db();
$st = $pdo->prepare("SELECT id,name,email,password_hash,role FROM users WHERE email=? LIMIT 1");
$st->execute([$email]);
$user = $st->fetch();
if (!$user) json(["message"=>"Invalid credentials"], 401);

if (!password_verify($password, $user["password_hash"])) json(["message"=>"Invalid credentials"], 401);

$token = make_token();
$payload = [
  "id" => (int)$user["id"],
  "name" => $user["name"],
  "email" => $user["email"],
  "role" => $user["role"]
];
save_token($token, $payload);

json(["message"=>"Login success", "token"=>$token, "user"=>$payload]);
