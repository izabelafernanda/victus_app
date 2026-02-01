<?php
class DailyTip {
    private $conn;
    private $table_name = "daily_tips";

    public function __construct($db) {
        $this->conn = $db;
    }

    // Busca uma dica aleatória
    public function getRandom() {
        $query = "SELECT message FROM " . $this->table_name . " ORDER BY RAND() LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            return $row['message'];
        }
        
        return "Mantenha o foco!"; // Fallback padrão
    }
}
?>