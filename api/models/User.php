<?php
class User {
    private $conn;
    private $table_name = "users";

    public $id;
    public $name;
    public $email;
    public $password;
    public $avatar_url;
    public $weight_lost;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function login() {
        $query = "SELECT id, name, password, avatar_url, weight_lost 
                  FROM " . $this->table_name . " 
                  WHERE email = ? 
                  LIMIT 0,1";

        $stmt = $this->conn->prepare($query);
        
        $this->email = htmlspecialchars(strip_tags($this->email));
        $stmt->bindParam(1, $this->email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (password_verify($this->password, $row['password'])) {
                $this->id = $row['id'];
                $this->name = $row['name'];
                $this->avatar_url = $row['avatar_url'];
                $this->weight_lost = $row['weight_lost'];
                return true;
            }
        }
        return false;
    }
    public function emailExists() {
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

            $this->id = $row['id'];
            $this->name = $row['name'];
            $this->password = $row['password'];
            $this->avatar_url = $row['avatar_url'];
            $this->weight_lost = $row['weight_lost'] ?? 0; 

            return true;
        }

        return false;
    }
}
?>