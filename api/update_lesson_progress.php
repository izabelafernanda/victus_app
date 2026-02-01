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
$progress_seconds = isset($data->progress_seconds) ? (int) $data->progress_seconds : 0;
$completed = isset($data->completed) && $data->completed;

if ($lesson_id <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'lesson_id inválido.']);
    exit;
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $completed_at = $completed ? date('Y-m-d H:i:s') : null;

    $stmt = $db->prepare("
        INSERT INTO user_lesson_progress (user_id, lesson_id, progress_seconds, completed_at)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            progress_seconds = VALUES(progress_seconds),
            completed_at = VALUES(completed_at),
            updated_at = CURRENT_TIMESTAMP
    ");
    $stmt->execute([$user_id, $lesson_id, $progress_seconds, $completed_at]);

    echo json_encode([
        'success' => true,
        'progress_seconds' => $progress_seconds,
        'completed' => $completed
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
