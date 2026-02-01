<?php
// CORREÇÃO: Sai de 'controllers' (..) e entra em 'config'
include_once __DIR__ . '/../config/database.php';

class DashboardController {
    private $conn;

    public function __construct() {
        // Tenta conectar, se falhar, o erro será capturado no dashboard.php
        if (class_exists('Database')) {
            $database = new Database();
            $this->conn = $database->getConnection();
        } else {
             throw new Exception("Classe Database não encontrada. Verifica o ficheiro config/database.php");
        }
    }

    public function getDashboardData() {
        $response = [
            "daily_tip" => null,
            "weight_lost" => 0.0,
            "events" => []
        ];

        if (!$this->conn) return $response;

        try {
            // 1. Dica do Dia
            $query = "SELECT title, message, background_color FROM daily_tips ORDER BY id DESC LIMIT 1";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $response["daily_tip"] = $row;
            }

            // 2. Peso
            $query = "SELECT weight_lost FROM users WHERE id = 1";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $response["weight_lost"] = (float)$row['weight_lost'];
            }

            // 3. Eventos
            $query = "SELECT title, type, date_label FROM events LIMIT 3";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $events = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $response["events"] = $events ? $events : [];

        } catch (Exception $e) {
            // Ignora erro SQL para não quebrar a app
        }

        return $response;
    }
}
?>