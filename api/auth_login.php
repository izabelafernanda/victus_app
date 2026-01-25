<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once 'config/database.php';
include_once 'utils/jwt_helper.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->email) && !empty($data->password)) {
    
    $query = "SELECT id, name, email, password FROM users WHERE email = :email LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":email", $data->email);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($data->password == $row['password']) {
            
            $token_payload = [
                "user_id" => $row['id'],
                "email" => $row['email'],
                "name" => $row['name']
            ];
            
            $jwt = JWT_Helper::create($token_payload);

            http_response_code(200);
            echo json_encode([
                "status" => "success",
                "message" => "Login realizado com sucesso.",
                "user" => [
                    "id" => $row['id'],
                    "name" => $row['name'],
                    "email" => $row['email']
                ],
                "token" => $jwt
            ]);
        } else {
            http_response_code(401);
            echo json_encode(["status" => "error", "message" => "Senha incorreta."]);
        }
    } else {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Usuario nao encontrado."]);
    }
} else {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Dados incompletos."]);
}
?>