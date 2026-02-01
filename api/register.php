<?php
// api/register.php

// 1. CORS Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// --- CORREÇÃO AQUI ---
// Antes estava: include_once '../controllers/AuthController.php';
// Como a pasta controllers está JUNTOS do register.php, usamos assim:
include_once __DIR__ . '/controllers/AuthController.php'; 

$data = json_decode(file_get_contents("php://input"));

try {
    $auth = new AuthController();
    $response = $auth->register($data);
    
    http_response_code(200); 
    echo json_encode($response);

} catch (Exception $e) {
    http_response_code(200);
    echo json_encode(["success" => false, "message" => "Server error: " . $e->getMessage()]);
}
?>