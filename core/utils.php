<?php
require_once __DIR__ . "/response.php";

function body_json() {
  $raw = file_get_contents("php://input");
  $data = json_decode($raw, true);
  if ($raw && json_last_error() !== JSON_ERROR_NONE) {
    json(["message" => "Invalid JSON body"], 400);
  }
  return $data ?? [];
}

function require_fields($data, $fields) {
  foreach ($fields as $f) {
    if (!isset($data[$f]) || $data[$f] === "") {
      json(["message" => "Field '$f' is required"], 422);
    }
  }
}

function int_or_zero($v) {
  if ($v === null || $v === "") return 0;
  return (int)$v;
}
