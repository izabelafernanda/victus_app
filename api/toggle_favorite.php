<?php
// --- CABEÇALHOS CORS (Crucial para Web) ---
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS"); // Adicionado OPTIONS
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// --- TRATAMENTO DO PRE-FLIGHT (O Navegador pergunta antes de enviar) ---
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once 'controllers/InteractionController.php';

// Recebe o JSON
$data = json_decode(file_get_contents("php://input"));

$controller = new InteractionController();
echo json_encode($controller->favorite($data));
?>