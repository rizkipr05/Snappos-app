<?php
require_once __DIR__ . "/response.php";

function make_token() {
  return bin2hex(random_bytes(24));
}

function token_store_path() {
  return __DIR__ . "/../storage_tokens.json";
}

function save_token($token, $payload) {
  $path = token_store_path();
  if (!file_exists($path)) file_put_contents($path, "{}");
  $map = json_decode(file_get_contents($path), true);
  if (!is_array($map)) $map = [];
  $map[$token] = $payload;
  file_put_contents($path, json_encode($map));
}

function require_auth() {
  $headers = getallheaders();
  $auth = $headers["Authorization"] ?? $headers["authorization"] ?? "";
  if (!preg_match("/Bearer\s+(.*)$/", $auth, $m)) json(["message"=>"Unauthorized"], 401);
  $token = trim($m[1]);

  $path = token_store_path();
  if (!file_exists($path)) file_put_contents($path, "{}");
  $map = json_decode(file_get_contents($path), true);
  if (!is_array($map) || !isset($map[$token])) json(["message"=>"Unauthorized"], 401);

  return $map[$token]; // {id,name,email,role}
}

function require_role($payload, $roles) {
  if (!in_array($payload["role"] ?? "", $roles, true)) {
    json(["message" => "Forbidden"], 403);
  }
}
