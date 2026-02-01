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
$lesson_id = isset($data->lesson_id) ? (int) $data->lesson_id : 0;
if ($lesson_id <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'lesson_id inválido.']);
    exit;
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $stmt = $db->prepare("SELECT id FROM user_favorites WHERE user_id = ? AND lesson_id = ?");
    $stmt->execute([$user_id, $lesson_id]);
    $exists = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($exists) {
        $stmt = $db->prepare("DELETE FROM user_favorites WHERE user_id = ? AND lesson_id = ?");
        $stmt->execute([$user_id, $lesson_id]);
        echo json_encode(['success' => true, 'is_favorited' => false]);
    } else {
        $stmt = $db->prepare("INSERT INTO user_favorites (user_id, lesson_id) VALUES (?, ?)");
        $stmt->execute([$user_id, $lesson_id]);
        echo json_encode(['success' => true, 'is_favorited' => true]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
