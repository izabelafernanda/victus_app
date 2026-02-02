<?php
/**
 * Profile Controller - User profile update
 */
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/get_user_from_token.php';
require_once __DIR__ . '/../core/Response.php';

class ProfileController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function updateProfile() {
        $userId = get_user_id_from_request();
        if ($userId === null) {
            Response::json(['success' => false, 'message' => 'Não autorizado. Faça login.'], 401);
            return;
        }

        $data = json_decode(file_get_contents("php://input"));
        $name = isset($data->name) ? trim($data->name) : '';
        if ($name === '') {
            Response::json(['success' => false, 'message' => 'Nome não pode estar vazio.'], 400);
            return;
        }

        $name = htmlspecialchars(strip_tags($name));
        if (strlen($name) > 100) {
            $name = substr($name, 0, 100);
        }

        try {
            $stmt = $this->db->prepare("UPDATE users SET name = ? WHERE id = ?");
            $stmt->execute([$name, $userId]);
            Response::json(['success' => true, 'name' => $name]);
        } catch (Exception $e) {
            Response::json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function updateAvatar() {
        $userId = get_user_id_from_request();
        if ($userId === null) {
            Response::json(['success' => false, 'message' => 'Não autorizado. Faça login.'], 401);
            return;
        }

        if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
            Response::json(['success' => false, 'message' => 'Nenhuma imagem enviada ou erro no upload.'], 400);
            return;
        }

        $file = $_FILES['avatar'];
        $allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
        if (!in_array($mime, $allowed)) {
            Response::json(['success' => false, 'message' => 'Formato de imagem não permitido.'], 400);
            return;
        }

        $ext = match($mime) {
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/gif' => 'gif',
            'image/webp' => 'webp',
            default => 'jpg',
        };
        $uploadDir = dirname(__DIR__, 2) . '/uploads/avatars';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        $filename = 'user_' . $userId . '.' . $ext;
        $path = $uploadDir . '/' . $filename;
        if (!move_uploaded_file($file['tmp_name'], $path)) {
            Response::json(['success' => false, 'message' => 'Erro ao guardar a imagem.'], 500);
            return;
        }

        $baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http')
            . '://' . ($_SERVER['HTTP_HOST'] ?? 'localhost')
            . dirname(dirname($_SERVER['SCRIPT_NAME'] ?? ''));
        $avatarUrl = rtrim($baseUrl, '/') . '/uploads/avatars/' . $filename;

        try {
            $stmt = $this->db->prepare("UPDATE users SET avatar_url = ? WHERE id = ?");
            $stmt->execute([$avatarUrl, $userId]);
            Response::json(['success' => true, 'avatar_url' => $avatarUrl]);
        } catch (Exception $e) {
            Response::json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
