<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Content-Disposition");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once __DIR__ . '/utils/get_user_from_token.php';

$user_id = get_user_id_from_request();
if ($user_id === null) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Não autorizado. Faça login.']);
    exit;
}

if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Nenhuma imagem enviada ou erro no upload.']);
    exit;
}

$file = $_FILES['avatar'];
$allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);
if (!in_array($mime, $allowed)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Formato de imagem não permitido.']);
    exit;
}

$ext = match($mime) {
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/gif' => 'gif',
    'image/webp' => 'webp',
    default => 'jpg',
};
$upload_dir = dirname(__DIR__) . '/uploads/avatars';
if (!is_dir($upload_dir)) {
    mkdir($upload_dir, 0755, true);
}
$filename = 'user_' . $user_id . '.' . $ext;
$path = $upload_dir . '/' . $filename;
if (!move_uploaded_file($file['tmp_name'], $path)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Erro ao guardar a imagem.']);
    exit;
}

$base_url = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http')
    . '://' . ($_SERVER['HTTP_HOST'] ?? 'localhost')
    . dirname(dirname($_SERVER['SCRIPT_NAME'] ?? ''));
$avatar_url = rtrim($base_url, '/') . '/uploads/avatars/' . $filename;

try {
    include_once __DIR__ . '/config/database.php';
    $database = new Database();
    $db = $database->getConnection();
    $stmt = $db->prepare("UPDATE users SET avatar_url = ? WHERE id = ?");
    $stmt->execute([$avatar_url, $user_id]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    exit;
}

echo json_encode([
    'success' => true,
    'avatar_url' => $avatar_url,
]);
