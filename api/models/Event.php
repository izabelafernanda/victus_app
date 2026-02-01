<?php
class Event {
    private $conn;
    private $table_name = "events";

    public function __construct($db) {
        $this->conn = $db;
    }

    // Busca os próximos eventos
    public function getUpcoming($limit = 3) {
        $query = "SELECT title, date_label, type FROM " . $this->table_name . " LIMIT :limit";
        
        $stmt = $this->conn->prepare($query);
        
        // Bind do limite (precisa ser inteiro no PDO)
        $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt;
    }
}
?>