<?php
// Configurações de Cabeçalho e Erros
ini_set('display_errors', 0);
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Incluir apenas o Controller
include_once 'controllers/DashboardController.php';

try {
    // Instancia o Controller
    $controller = new DashboardController();
    
    // Pede os dados
    $data = $controller->getData();

    // Retorna o JSON
    http_response_code(200);
    echo json_encode($data);

} catch (Exception $e) {
    // Tratamento de Erro Global
    http_response_code(500);
    echo json_encode([
        "user_name" => "Erro",
        "weight_lost" => 0,
        "daily_tip" => "Erro ao carregar dados.",
        "next_events" => [],
        "has_notifications" => false,
        "has_messages" => false,
        "error_debug" => $e->getMessage() // Opcional: remover em produção
    ]);
}
?>