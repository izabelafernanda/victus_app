<?php
// 1. Cabeçalhos (Permite o Flutter conectar)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8"); // <--- Garante que é JSON

// Se for apenas verificação de CORS, para aqui
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 2. Inclui arquivos de conexão
include_once 'config/database.php';
include_once 'models/User.php';

// 3. Conecta ao Banco
$database = new Database();
$db = $database->getConnection();
$user = new User($db);

// 4. Pega os dados enviados pelo Flutter
$data = json_decode(file_get_contents("php://input"));

// Verifica se veio email e senha
if(!empty($data->email) && !empty($data->password)) {
    
    $user->email = $data->email;
    $email_exists = $user->emailExists();

    if($email_exists && password_verify($data->password, $user->password)) {
        // --- SUCESSO ---
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Login realizado com sucesso.",
            "data" => [
                "id" => $user->id,
                "name" => $user->name,
                "email" => $user->email,
                "avatar_url" => $user->avatar_url,
                "weight_lost" => 0 // <--- ADICIONE ESTA LINHA (com vírgula antes)
            ]
        ]);
    } else {
        // --- ERRO DE SENHA OU EMAIL ---
        http_response_code(401);
        echo json_encode([
            "status" => "error", 
            "message" => "Credenciais inválidas."
        ]);
    }
} else {
    // --- DADOS INCOMPLETOS ---
    http_response_code(400);
    echo json_encode([
        "status" => "error", 
        "message" => "Dados incompletos."
    ]);
}
?>