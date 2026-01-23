<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

// Pega o ID do usuário (se não mandar, assume que é o ID 1 - Cristiana)
$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : 1;

$response = [];

// 1. Pegar Dados do Usuário (Nome e Peso Perdido)
$query_user = "SELECT name, weight_lost FROM users WHERE id = ? LIMIT 1";
$stmt_user = $db->prepare($query_user);
$stmt_user->bindParam(1, $user_id);
$stmt_user->execute();
$user_data = $stmt_user->fetch(PDO::FETCH_ASSOC);

// Garante que o peso venha como número (float), mesmo se for nulo
if($user_data) {
    $response['user'] = [
        "name" => $user_data['name'],
        "weight_lost" => floatval($user_data['weight_lost'])
    ];
}

// 2. Pegar Banners
$query_banners = "SELECT id, title, subtitle, image_url FROM banners";
$stmt_banners = $db->prepare($query_banners);
$stmt_banners->execute();
$response['banners'] = $stmt_banners->fetchAll(PDO::FETCH_ASSOC);

// 3. Pegar Lembrete do Dia (Último inserido)
$query_tip = "SELECT title, message FROM daily_tips ORDER BY id DESC LIMIT 1";
$stmt_tip = $db->prepare($query_tip);
$stmt_tip->execute();
$response['reminder'] = $stmt_tip->fetch(PDO::FETCH_ASSOC);

// 4. Pegar Próximos 3 Eventos (Já formatando a data para dia/mês ex: 23/05)
$query_events = "SELECT id, title, DATE_FORMAT(event_date, '%d/%m') as date_formatted FROM events WHERE event_date >= CURDATE() ORDER BY event_date ASC LIMIT 3";
$stmt_events = $db->prepare($query_events);
$stmt_events->execute();
$response['events'] = $stmt_events->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($response);
?>