<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// CORREÇÃO: Caminho direto, sem sair da pasta
include_once __DIR__ . '/controllers/DashboardController.php';

try {
    $controller = new DashboardController();
    $data = $controller->getDashboardData();

    http_response_code(200);
    echo json_encode($data);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["message" => "Erro: " . $e->getMessage()]);
}
?>