<?php
// Configurações CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once 'controllers/LibraryController.php';

$course_id = isset($_GET['course_id']) ? $_GET['course_id'] : null;

try {
    if (!$course_id) {
        echo json_encode([]);
        exit();
    }

    $controller = new LibraryController();
    $data = $controller->getLessonDetail($course_id);
    echo json_encode($data);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["message" => "Erro ao carregar a lição.", "error" => $e->getMessage()]);
}
?>