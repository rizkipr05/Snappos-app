<?php
require_once __DIR__ . "/../../config/db.php";
require_once __DIR__ . "/../../core/response.php";
require_once __DIR__ . "/../../core/auth.php";

$user = require_auth();
require_role($user, ["admin"]); // Only admin can view reports

$pdo = db();

$startDate = $_GET['start_date'] ?? date('Y-m-01');
$endDate = $_GET['end_date'] ?? date('Y-m-d');

// Format dates to ensure they include time for full day coverage
$start = "$startDate 00:00:00";
$end = "$endDate 23:59:59";

// Summary Query
$sqlSummary = "
    SELECT 
        COUNT(id) as total_transactions,
        COALESCE(SUM(total), 0) as total_revenue
    FROM transactions
    WHERE created_at BETWEEN ? AND ?
";

$stmt = $pdo->prepare($sqlSummary);
$stmt->execute([$start, $end]);
$summary = $stmt->fetch(PDO::FETCH_ASSOC);

// Daily Sales Query (Graph Data)
$sqlDaily = "
    SELECT 
        DATE(created_at) as date,
        COUNT(id) as count,
        SUM(total) as revenue
    FROM transactions
    WHERE created_at BETWEEN ? AND ?
    GROUP BY DATE(created_at)
    ORDER BY date ASC
";

$stmtDaily = $pdo->prepare($sqlDaily);
$stmtDaily->execute([$start, $end]);
$daily = $stmtDaily->fetchAll(PDO::FETCH_ASSOC);

json([
    "summary" => $summary,
    "daily" => $daily,
    "period" => [
        "start" => $startDate,
        "end" => $endDate
    ]
]);
