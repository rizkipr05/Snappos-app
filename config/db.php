<?php
function db() {
  $host = "localhost";
  $user = "root";
  $pass = "";
  $name = "snappos";

  $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
  ]);
  return $pdo;
}
