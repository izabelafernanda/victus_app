<?php
include_once __DIR__ . '/../config/database.php';
include_once __DIR__ . '/../models/Course.php';

class LibraryController {
    private $db;
    private $courseModel;

    public function __construct() {
        if (!class_exists('Database')) {
            throw new Exception("Erro Crítico: Classe Database não encontrada.");
        }
        $database = new Database();
        $this->db = $database->getConnection();
        $this->courseModel = new Course($this->db);
    }

    // Lista de Cursos (Biblioteca)
    // Lista de Cursos (Biblioteca) com Cálculo de Progresso
    public function getContent() {
        $stmt = $this->courseModel->getAll();
        
        $courses = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Garante que são números
            $total = intval($row['total_lessons']);
            $completed = intval($row['completed_lessons']);
            
            // Lógica da Percentagem (Evita divisão por zero)
            $percentage = 0;
            if ($total > 0) {
                $percentage = round(($completed / $total) * 100);
            }

            // Adiciona o campo 'progress' ao JSON (Ex: 80)
            $row['progress'] = $percentage;
            
            // Adiciona à lista final
            $courses[] = $row;
        }

        return $courses;
    }

    // Lista de Lições de um Curso
    public function getCourseLessons($course_id) {
        if (!$course_id) return [];
        
        $stmt = $this->courseModel->getLessonsByCourse($course_id);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Lição Individual (Primeira/Preview)
    public function getLessonDetail($course_id) {
        if (!$course_id) return [];

        $stmt = $this->courseModel->getFirstLesson($course_id);
        $lesson = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $lesson ? $lesson : []; // Retorna array vazio se não achar
    }
}
?>