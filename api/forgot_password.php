<?php
// api/forgot_password.php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Usa o AuthController que já tem a conexão correta e os caminhos seguros
include_once __DIR__ . '/controllers/AuthController.php';

$data = json_decode(file_get_contents("php://input"));

try {
    $auth = new AuthController();
    
    // A função forgotPassword (que corrigimos no passo anterior)
    // já retorna ["success" => true/false, "message" => "..."]
    // e usa código 200 para não "crashar" o Flutter.
    $response = $auth->forgotPassword($data);
    
    echo json_encode($response);

} catch (Exception $e) {
    http_response_code(200);
    echo json_encode(["success" => false, "message" => "Erro técnico: " . $e->getMessage()]);
}
?>