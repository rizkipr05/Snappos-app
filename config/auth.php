<?php
require_once __DIR__ . "/response.php";

function make_token() {
  return bin2hex(random_bytes(24));
}

function require_auth() {
  $headers = getallheaders();
  $auth = $headers["Authorization"] ?? $headers["authorization"] ?? "";
  if (!preg_match("/Bearer\s+(.*)$/", $auth, $m)) json(["message"=>"Unauthorized"], 401);
  $token = trim($m[1]);

  // token disimpan di file sementara (MVP)
  $path = __DIR__ . "/../storage_tokens.json";
  if (!file_exists($path)) file_put_contents($path, "{}");
  $map = json_decode(file_get_contents($path), true);

  if (!isset($map[$token])) json(["message"=>"Unauthorized"], 401);
  return $map[$token]; // return user payload
}

function save_token($token, $payload) {
  $path = __DIR__ . "/../storage_tokens.json";
  if (!file_exists($path)) file_put_contents($path, "{}");
  $map = json_decode(file_get_contents($path), true);
  $map[$token] = $payload;
  file_put_contents($path, json_encode($map));
}
