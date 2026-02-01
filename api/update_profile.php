<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once __DIR__ . '/config/database.php';
include_once __DIR__ . '/utils/get_user_from_token.php';

$user_id = get_user_id_from_request();
if ($user_id === null) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Não autorizado. Faça login.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));
$name = isset($data->name) ? trim($data->name) : '';
if ($name === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Nome não pode estar vazio.']);
    exit;
}

$name = htmlspecialchars(strip_tags($name));
if (strlen($name) > 100) {
    $name = substr($name, 0, 100);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    $stmt = $db->prepare("UPDATE users SET name = ? WHERE id = ?");
    $stmt->execute([$name, $user_id]);

    echo json_encode([
        'success' => true,
        'name' => $name,
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
