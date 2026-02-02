<?php
/**
 * Auth Controller - Login, Register, Forgot Password
 */
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt_helper.php';
require_once __DIR__ . '/../core/Response.php';

class AuthController {
    private $db;
    private $user;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->user = new User($this->db);
    }

    public function login() {
        $data = json_decode(file_get_contents("php://input"));
        if (empty($data->email) || empty($data->password)) {
            Response::error("Dados incompletos.", 400);
            return;
        }

        $email = htmlspecialchars(strip_tags($data->email));
        $password = $data->password;

        $query = "SELECT id, name, password, email, avatar_url, weight_lost FROM users WHERE email = ? LIMIT 0,1";
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(1, $email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if (password_verify($password, $row['password'])) {
                $token = JWT_Helper::create(['user_id' => (int) $row['id']]);
                Response::json([
                    "status" => "success",
                    "message" => "Login realizado com sucesso.",
                    "token" => $token,
                    "user" => [
                        "id" => $row['id'],
                        "name" => $row['name'],
                        "email" => $row['email'],
                        "avatar_url" => $row['avatar_url'],
                        "weight_lost" => $row['weight_lost']
                    ]
                ], 200);
            } else {
                Response::error("Senha incorreta!", 401);
            }
        } else {
            Response::error("Email nao encontrado.", 404);
        }
    }

    public function register() {
        $data = json_decode(file_get_contents("php://input"));
        if (empty($data->name) || empty($data->email) || empty($data->password)) {
            Response::error("Preencha todos os campos.", 400);
            return;
        }

        if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
            Response::error("Formato de email invalido.", 400);
            return;
        }

        $this->user->email = $data->email;
        if ($this->user->emailExists()) {
            Response::error("Este email ja esta registado.", 400);
            return;
        }

        $this->user->name = $data->name;
        $this->user->password = password_hash($data->password, PASSWORD_BCRYPT);

        if ($this->user->create()) {
            Response::json([
                "status" => "success",
                "message" => "Conta criada com sucesso."
            ], 201);
        } else {
            Response::error("Nao foi possivel criar a conta.", 503);
        }
    }

    public function forgotPassword() {
        $data = json_decode(file_get_contents("php://input"));
        if (empty($data->email)) {
            Response::error("Por favor insira o email.", 400);
            return;
        }

        $this->user->email = $data->email;
        if ($this->user->emailExists()) {
            Response::json([
                "status" => "success",
                "message" => "Email de recuperacao enviado!"
            ], 200);
        } else {
            Response::error("Este email nao esta registado na nossa base de dados.", 404);
        }
    }
}
