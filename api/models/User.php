<?php
class User {
    private $conn;
    private $table_name = "users";

    // 1. ADICIONAR AS PROPRIEDADES QUE FALTAVAM
    public $id;
    public $name;
    public $email;
    public $password;
    public $created_at;
    public $avatar_url;  // <--- Faltava ou não estava a ser preenchido
    public $weight_lost; // <--- Faltava ou não estava a ser preenchido

    public function __construct($db) {
        $this->conn = $db;
    }

    // Criar conta
    public function create() {
        $query = "INSERT INTO " . $this->table_name . "
                SET
                    name = :name,
                    email = :email,
                    password = :password,
                    created_at = :created_at";

        $stmt = $this->conn->prepare($query);

        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->password = htmlspecialchars(strip_tags($this->password));
        $this->created_at = date('Y-m-d H:i:s');

        $stmt->bindParam(':name', $this->name);
        $stmt->bindParam(':email', $this->email);
        $stmt->bindParam(':password', $this->password);
        $stmt->bindParam(':created_at', $this->created_at);

        if($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Verificar se email existe (E CARREGAR DADOS)
    public function emailExists() {
        // 2. ATUALIZAR A QUERY PARA TRAZER OS NOVOS CAMPOS
        $query = "SELECT id, name, password, avatar_url, weight_lost
                FROM " . $this->table_name . "
                WHERE email = ?
                LIMIT 0,1";

        $stmt = $this->conn->prepare($query);
        $this->email = htmlspecialchars(strip_tags($this->email));
        $stmt->bindParam(1, $this->email);
        $stmt->execute();

        if($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // 3. PREENCHER AS PROPRIEDADES DO OBJETO
            $this->id = $row['id'];
            $this->name = $row['name'];
            $this->password = $row['password'];
            $this->avatar_url = $row['avatar_url']; // Agora já existe
            $this->weight_lost = $row['weight_lost']; // Agora já existe
            
            return true;
        }
        return false;
    }
}
?>