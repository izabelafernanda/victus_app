<?php
include_once __DIR__ . '/../config/database.php';
include_once __DIR__ . '/../models/User.php';
include_once __DIR__ . '/../utils/jwt_helper.php'; // O teu gerador de tokens

class AuthController {
    private $db;
    private $user;

    public function __construct() {
        if (!class_exists('Database')) {
            throw new Exception("Erro: Classe Database não encontrada.");
        }
        $database = new Database();
        $this->db = $database->getConnection();
        $this->user = new User($this->db);
    }

    // Lógica de Login
    // Em controllers/AuthController.php

    // Em api/controllers/AuthController.php

    public function login($data) {
        if (!isset($data->email) || !isset($data->password)) {
            http_response_code(200);
            return ["success" => false, "message" => "Dados incompletos."];
        }

        $this->user->email = $data->email;
        $emailExists = $this->user->emailExists();

        if ($emailExists && password_verify($data->password, $this->user->password)) {
            
            $jwt = "token_simulado_" . time(); 

            // SUCESSO
            http_response_code(200);
            return [
                "success" => true,
                "message" => "Login realizado com sucesso.",
                "token" => $jwt,
                "user" => [
                    "id" => $this->user->id,
                    "name" => $this->user->name,
                    // --- ADICIONEI ESTES CAMPOS QUE FALTAVAM ---
                    "email" => $this->user->email,
                    "avatar_url" => $this->user->avatar_url,
                    "weight_lost" => $this->user->weight_lost
                ]
            ];
        } else {
            // ERRO 
            http_response_code(200); 
            return [
                "success" => false, 
                "message" => "Email ou senha incorretos."
            ];
        }
    }
    // Lógica de Registo
    // Em controllers/AuthController.php

    // Em controllers/AuthController.php

public function register($data) {
    // 1. Validar inputs
    if (!isset($data->name) || !isset($data->email) || !isset($data->password)) {
        return ["success" => false, "message" => "Por favor preenche todos os campos."];
    }

    $name = htmlspecialchars(strip_tags($data->name));
    $email = htmlspecialchars(strip_tags($data->email));
    $password = htmlspecialchars(strip_tags($data->password));

    try {
        // 2. VERIFICAÇÃO: O email já existe?
        // CORREÇÃO: Usar $this->db em vez de $this->conn
        $checkQuery = "SELECT id FROM users WHERE email = :email";
        $checkStmt = $this->db->prepare($checkQuery); 
        $checkStmt->bindParam(':email', $email);
        $checkStmt->execute();

        if ($checkStmt->rowCount() > 0) {
            return ["success" => false, "message" => "Este email já está registado. Tenta fazer login."];
        }

        // 3. Criar utilizador
        $query = "INSERT INTO users (name, email, password, created_at) VALUES (:name, :email, :password, NOW())";
        
        // CORREÇÃO: Usar $this->db em vez de $this->conn
        $stmt = $this->db->prepare($query); 

        $passwordHash = password_hash($password, PASSWORD_DEFAULT);

        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password', $passwordHash);

        if ($stmt->execute()) {
            return ["success" => true, "message" => "Conta criada com sucesso!"];
        } else {
            return ["success" => false, "message" => "Erro ao guardar no banco de dados."];
        }

    } catch (PDOException $e) {
        if ($e->getCode() == 23000) { 
            return ["success" => false, "message" => "Este email já está a ser utilizado."];
        }
        return ["success" => false, "message" => "Erro técnico: " . $e->getMessage()];
    }
}

    // Lógica de Recuperação de Senha (ADICIONADO AQUI)
    // Em controllers/AuthController.php

    public function forgotPassword($data) {
        if (!isset($data->email)) {
            // Mantemos 200 para o Flutter ler o JSON, mas indicamos false
            http_response_code(200); 
            return ["success" => false, "message" => "Por favor, insere o email."];
        }

        $this->user->email = $data->email;
        
        if ($this->user->emailExists()) {
            $code = rand(1000, 9999);
            
            // SUCESSO
            http_response_code(200);
            return [
                "success" => true, // Mudado de "status" => "success" para booleano
                "message" => "Email de recuperação enviado! (Código: $code)"
            ];
        } else {
            // ERRO (Email não encontrado)
            // IMPORTANTE: Mudamos de 404 para 200.
            // Assim o Flutter recebe a resposta sem "explodir" um erro.
            http_response_code(200); 
            return [
                "success" => false, 
                "message" => "Este email não está registado."
            ];
        }
    }
}
?>