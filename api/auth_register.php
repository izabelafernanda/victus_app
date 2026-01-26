<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once './config/database.php';
include_once './models/User.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    $data = json_decode(file_get_contents("php://input"));

    if(!empty($data->name) && !empty($data->email) && !empty($data->password)){
        
        if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            echo json_encode(array("status" => "error", "message" => "Formato de email invalido."));
            exit();
        }

        $user->email = $data->email;
        
        if($user->emailExists()){
            http_response_code(400);
            echo json_encode(array("status" => "error", "message" => "Este email ja esta registado."));
        } else {
            $user->name = $data->name;
            $user->password = password_hash($data->password, PASSWORD_BCRYPT);

            if($user->create()){
                http_response_code(201);
                echo json_encode(array("status" => "success", "message" => "Conta criada com sucesso."));
            } else {
                http_response_code(503);
                echo json_encode(array("status" => "error", "message" => "Nao foi possivel criar a conta."));
            }
        }
    } else {
        http_response_code(400);
        echo json_encode(array("status" => "error", "message" => "Preencha todos os campos."));
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array("status" => "error", "message" => "Erro no servidor: " . $e->getMessage()));
}
?>