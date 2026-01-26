<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
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

    $data = json_decode(file_get_contents("php://input"));

    if(!empty($data->email) && !empty($data->password)){
        
        $email_recebido = htmlspecialchars(strip_tags($data->email));
        $senha_recebida = $data->password;

        $query = "SELECT id, name, password, email, avatar_url, weight_lost FROM users WHERE email = ? LIMIT 0,1";
        $stmt = $db->prepare($query);
        $stmt->bindParam(1, $email_recebido);
        $stmt->execute();

        if($stmt->rowCount() > 0){
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $hash_no_banco = $row['password'];

            if(password_verify($senha_recebida, $hash_no_banco)){
                $token = bin2hex(random_bytes(16));
                http_response_code(200);
                echo json_encode(array(
                    "status" => "success",
                    "message" => "Login realizado com sucesso.",
                    "token" => $token,
                    "user" => array(
                        "id" => $row['id'],
                        "name" => $row['name'],
                        "email" => $row['email'],
                        "avatar_url" => $row['avatar_url'],
                        "weight_lost" => $row['weight_lost']
                    )
                ));
            } else {
                http_response_code(401);
                echo json_encode(array(
                    "status" => "error",
                    "message" => "Senha incorreta! Recebi: '$senha_recebida'."
                ));
            }
        } else {
            http_response_code(404);
            echo json_encode(array(
                "status" => "error",
                "message" => "Email nao encontrado: '$email_recebido'"
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array("status" => "error", "message" => "Dados incompletos."));
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array("status" => "error", "message" => "Erro interno no servidor: " . $e->getMessage()));
}
?>