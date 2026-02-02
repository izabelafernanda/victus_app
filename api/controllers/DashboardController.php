<?php
/**
 * Dashboard Controller - Home dashboard data
 */
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

class DashboardController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function index() {
        try {
            $userName = "Visitante";
            $query = "SELECT name FROM users WHERE name LIKE '%Cristiana%' LIMIT 1";
            $stmt = $this->db->prepare($query);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $userName = $row['name'];
            } else {
                $query2 = "SELECT name FROM users LIMIT 1";
                $stmt2 = $this->db->prepare($query2);
                $stmt2->execute();
                if ($stmt2->rowCount() > 0) {
                    $row2 = $stmt2->fetch(PDO::FETCH_ASSOC);
                    $userName = $row2['name'];
                }
            }

            $tipMessage = "Mantenha o foco!";
            $stmtTip = $this->db->prepare("SELECT message FROM daily_tips ORDER BY RAND() LIMIT 1");
            if ($stmtTip->execute() && $stmtTip->rowCount() > 0) {
                $rowTip = $stmtTip->fetch(PDO::FETCH_ASSOC);
                $tipMessage = $rowTip['message'];
            }

            $events = [];
            try {
                $queryEvents = "SELECT title, date_label, type FROM events LIMIT 3";
                $stmtEvents = $this->db->prepare($queryEvents);
                $stmtEvents->execute();
                $events = $stmtEvents->fetchAll(PDO::FETCH_ASSOC);
            } catch (Exception $e) {
                $events = [];
            }

            Response::json([
                "user_name" => $userName,
                "weight_lost" => 2,
                "daily_tip" => $tipMessage,
                "next_events" => $events,
                "has_notifications" => true,
                "has_messages" => true
            ]);
        } catch (Exception $e) {
            Response::json([
                "user_name" => "Erro",
                "weight_lost" => 0,
                "daily_tip" => "Erro de conexao.",
                "next_events" => [],
                "has_notifications" => false,
                "has_messages" => false
            ], 500);
        }
    }
}
