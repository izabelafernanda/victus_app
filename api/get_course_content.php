<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

$course_id = isset($_GET['course_id']) ? $_GET['course_id'] : 1;

$query = "SELECT id, title, description, video_url, duration_minutes, is_locked, is_completed 
          FROM lessons 
          WHERE library_item_id = ? 
          ORDER BY id ASC";

$stmt = $db->prepare($query);
$stmt->bindParam(1, $course_id);
$stmt->execute();

$lessons = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($lessons);
?>