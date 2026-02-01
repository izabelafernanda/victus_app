<?php
/**
 * Lesson Controller - Course content, lessons, progress, favorites
 */
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/get_user_from_token.php';
require_once __DIR__ . '/../core/Response.php';

class LessonController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function getCourseContent() {
        $userId = get_user_id_from_request();
        $courseId = isset($_GET['course_id']) ? (int) $_GET['course_id'] : 1;

        $query = "SELECT id, title, description, video_url, duration_minutes, is_locked, is_completed 
                  FROM lessons 
                  WHERE library_item_id = ? 
                  ORDER BY id ASC";
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(1, $courseId);
        $stmt->execute();
        $lessons = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($userId !== null && count($lessons) > 0) {
            $lessonIds = array_column($lessons, 'id');
            $placeholders = implode(',', array_fill(0, count($lessonIds), '?'));
            $favQuery = "SELECT lesson_id FROM user_favorites WHERE user_id = ? AND lesson_id IN ($placeholders)";
            $favStmt = $this->db->prepare($favQuery);
            $favStmt->execute(array_merge([$userId], $lessonIds));
            $favoritedIds = array_column($favStmt->fetchAll(PDO::FETCH_ASSOC), 'lesson_id');

            $progQuery = "SELECT lesson_id, progress_seconds, completed_at FROM user_lesson_progress WHERE user_id = ? AND lesson_id IN ($placeholders)";
            $progStmt = $this->db->prepare($progQuery);
            $progStmt->execute(array_merge([$userId], $lessonIds));
            $progressByLesson = [];
            while ($row = $progStmt->fetch(PDO::FETCH_ASSOC)) {
                $progressByLesson[$row['lesson_id']] = [
                    'progress_seconds' => (int) $row['progress_seconds'],
                    'is_completed' => $row['completed_at'] !== null ? 1 : 0
                ];
            }

            foreach ($lessons as &$lesson) {
                $lid = (int) $lesson['id'];
                $lesson['is_favorited'] = in_array($lid, $favoritedIds) ? 1 : 0;
                $lesson['progress_seconds'] = isset($progressByLesson[$lid]) ? $progressByLesson[$lid]['progress_seconds'] : 0;
                if (isset($progressByLesson[$lid])) {
                    $lesson['is_completed'] = $progressByLesson[$lid]['is_completed'];
                }
            }
            unset($lesson);
        }

        Response::json($lessons);
    }

    public function getLesson() {
        $courseId = isset($_GET['course_id']) ? $_GET['course_id'] : null;
        if ($courseId === null) {
            Response::json([]);
            return;
        }

        $query = "SELECT title, description, video_url, duration_minutes FROM lessons WHERE library_item_id = ? LIMIT 1";
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(1, $courseId);
        $stmt->execute();
        $lesson = $stmt->fetch(PDO::FETCH_ASSOC);
        Response::json($lesson ? $lesson : []);
    }

    public function toggleFavorite() {
        $userId = get_user_id_from_request();
        if ($userId === null) {
            Response::json(['success' => false, 'message' => 'Não autorizado. Faça login.'], 401);
            return;
        }

        $data = json_decode(file_get_contents("php://input"));
        $lessonId = isset($data->lesson_id) ? (int) $data->lesson_id : 0;
        if ($lessonId <= 0) {
            Response::json(['success' => false, 'message' => 'lesson_id inválido.'], 400);
            return;
        }

        try {
            $stmt = $this->db->prepare("SELECT id FROM user_favorites WHERE user_id = ? AND lesson_id = ?");
            $stmt->execute([$userId, $lessonId]);
            $exists = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($exists) {
                $stmt = $this->db->prepare("DELETE FROM user_favorites WHERE user_id = ? AND lesson_id = ?");
                $stmt->execute([$userId, $lessonId]);
                Response::json(['success' => true, 'is_favorited' => false]);
            } else {
                $stmt = $this->db->prepare("INSERT INTO user_favorites (user_id, lesson_id) VALUES (?, ?)");
                $stmt->execute([$userId, $lessonId]);
                Response::json(['success' => true, 'is_favorited' => true]);
            }
        } catch (Exception $e) {
            Response::json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function updateProgress() {
        $userId = get_user_id_from_request();
        if ($userId === null) {
            Response::json(['success' => false, 'message' => 'Não autorizado. Faça login.'], 401);
            return;
        }

        $data = json_decode(file_get_contents("php://input"));
        $lessonId = isset($data->lesson_id) ? (int) $data->lesson_id : 0;
        $progressSeconds = isset($data->progress_seconds) ? (int) $data->progress_seconds : 0;
        $completed = isset($data->completed) && $data->completed;

        if ($lessonId <= 0) {
            Response::json(['success' => false, 'message' => 'lesson_id inválido.'], 400);
            return;
        }

        try {
            $completedAt = $completed ? date('Y-m-d H:i:s') : null;
            $stmt = $this->db->prepare("
                INSERT INTO user_lesson_progress (user_id, lesson_id, progress_seconds, completed_at)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    progress_seconds = VALUES(progress_seconds),
                    completed_at = VALUES(completed_at),
                    updated_at = CURRENT_TIMESTAMP
            ");
            $stmt->execute([$userId, $lessonId, $progressSeconds, $completedAt]);

            Response::json([
                'success' => true,
                'progress_seconds' => $progressSeconds,
                'completed' => $completed
            ]);
        } catch (Exception $e) {
            Response::json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
