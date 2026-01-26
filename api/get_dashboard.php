<?php
ini_set('display_errors', 0);
error_reporting(0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();

    $has_notifications = true; 
    $has_messages = true;      

    $user_name = "Visitante";
    $query = "SELECT name FROM users WHERE name LIKE '%Cristiana%' LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $user_name = $row['name'];
    } else {
        $query2 = "SELECT name FROM users LIMIT 1";
        $stmt2 = $db->prepare($query2);
        $stmt2->execute();
        if ($stmt2->rowCount() > 0) {
            $row2 = $stmt2->fetch(PDO::FETCH_ASSOC);
            $user_name = $row2['name'];
        }
    }

    $tip_message = "Mantenha o foco!";
    $stmt_tip = $db->prepare("SELECT message FROM daily_tips ORDER BY RAND() LIMIT 1");
    if ($stmt_tip->execute() && $stmt_tip->rowCount() > 0) {
        $row_tip = $stmt_tip->fetch(PDO::FETCH_ASSOC);
        $tip_message = $row_tip['message'];
    }

    $events = [];
    try {
        $query_events = "SELECT title, date_label, type FROM events LIMIT 3";
        $stmt_events = $db->prepare($query_events);
        $stmt_events->execute();
        $events = $stmt_events->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        $events = [];
    }

    $response = [
        "user_name" => $user_name,
        "weight_lost" => 2, 
        "daily_tip" => $tip_message,
        "next_events" => $events,
        "has_notifications" => $has_notifications,
        "has_messages" => $has_messages
    ];

    echo json_encode($response);

} catch (Exception $e) {
    echo json_encode([
        "user_name" => "Erro",
        "weight_lost" => 0,
        "daily_tip" => "Erro de conexão.",
        "next_events" => [],
        "has_notifications" => false,
        "has_messages" => false
    ]);
}
?>