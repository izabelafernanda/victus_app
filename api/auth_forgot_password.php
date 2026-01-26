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

$database = new Database();
$db = $database->getConnection();
$user = new User($db);

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->email)){
    $user->email = $data->email;

    if($user->emailExists()){
        http_response_code(200);
        echo json_encode(array("status" => "success", "message" => "Email de recuperacao enviado!"));
    } else {
        http_response_code(404);
        echo json_encode(array("status" => "error", "message" => "Este email nao esta registado na nossa base de dados."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("status" => "error", "message" => "Por favor insira o email."));
}
?>