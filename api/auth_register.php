<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->name) && !empty($data->email) && !empty($data->password)) {
    
    $checkQuery = "SELECT id FROM users WHERE email = :email";
    $stmt = $db->prepare($checkQuery);
    $stmt->bindParam(":email", $data->email);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        http_response_code(400); 
        echo json_encode(["status" => "error", "message" => "Este email ja esta registado."]);
    } else {
        $query = "INSERT INTO users (name, email, password, created_at) VALUES (:name, :email, :password, NOW())";
        $stmt = $db->prepare($query);

        $stmt->bindParam(":name", $data->name);
        $stmt->bindParam(":email", $data->email);
        $stmt->bindParam(":password", $data->password); 

        if ($stmt->execute()) {
            http_response_code(201); 
            echo json_encode(["status" => "success", "message" => "Conta criada com sucesso."]);
        } else {
            http_response_code(503);
            echo json_encode(["status" => "error", "message" => "Erro ao criar conta."]);
        }
    }
} else {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Dados incompletos."]);
}
?>