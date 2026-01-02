<?php
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

if ($_SERVER["REQUEST_METHOD"] !== "GET") json(["message"=>"Method not allowed"], 405);
$user = require_auth();
json(["user" => $user]);
