<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

$query = "SELECT id, title, description, image_url, progress FROM library_items";
$stmt = $db->prepare($query);
$stmt->execute();

$items = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($items);
?>