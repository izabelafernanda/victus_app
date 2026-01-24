<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

$course_id = isset($_GET['course_id']) ? $_GET['course_id'] : die();

$query = "SELECT title, description, video_url, duration_minutes FROM lessons WHERE library_item_id = ? LIMIT 1";
$stmt = $db->prepare($query);
$stmt->bindParam(1, $course_id);
$stmt->execute();

$lesson = $stmt->fetch(PDO::FETCH_ASSOC);

echo json_encode($lesson ? $lesson : []); 
?>