<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Headers: Authorization, X-Requested-With");

include_once __DIR__ . '/config/database.php';
include_once __DIR__ . '/utils/get_user_from_token.php';

$database = new Database();
$db = $database->getConnection();

$course_id = isset($_GET['course_id']) ? (int) $_GET['course_id'] : 1;
$user_id = get_user_id_from_request();

$query = "SELECT id, title, description, video_url, duration_minutes, is_locked, is_completed 
          FROM lessons 
          WHERE library_item_id = ? 
          ORDER BY id ASC";
$stmt = $db->prepare($query);
$stmt->bindParam(1, $course_id);
$stmt->execute();
$lessons = $stmt->fetchAll(PDO::FETCH_ASSOC);

if ($user_id !== null && count($lessons) > 0) {
    $lesson_ids = array_column($lessons, 'id');
    $placeholders = implode(',', array_fill(0, count($lesson_ids), '?'));
    $fav_query = "SELECT lesson_id FROM user_favorites WHERE user_id = ? AND lesson_id IN ($placeholders)";
    $fav_stmt = $db->prepare($fav_query);
    $fav_stmt->execute(array_merge([$user_id], $lesson_ids));
    $favorited_ids = array_column($fav_stmt->fetchAll(PDO::FETCH_ASSOC), 'lesson_id');

    $prog_query = "SELECT lesson_id, progress_seconds, completed_at FROM user_lesson_progress WHERE user_id = ? AND lesson_id IN ($placeholders)";
    $prog_stmt = $db->prepare($prog_query);
    $prog_stmt->execute(array_merge([$user_id], $lesson_ids));
    $progress_by_lesson = [];
    while ($row = $prog_stmt->fetch(PDO::FETCH_ASSOC)) {
        $progress_by_lesson[$row['lesson_id']] = [
            'progress_seconds' => (int) $row['progress_seconds'],
            'is_completed' => $row['completed_at'] !== null ? 1 : 0
        ];
    }

    foreach ($lessons as &$lesson) {
        $lid = (int) $lesson['id'];
        $lesson['is_favorited'] = in_array($lid, $favorited_ids) ? 1 : 0;
        $lesson['progress_seconds'] = isset($progress_by_lesson[$lid]) ? $progress_by_lesson[$lid]['progress_seconds'] : 0;
        if (isset($progress_by_lesson[$lid])) {
            $lesson['is_completed'] = $progress_by_lesson[$lid]['is_completed'];
        }
    }
    unset($lesson);
}

echo json_encode($lessons);
?>