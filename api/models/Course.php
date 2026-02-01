<?php
class Course {
    private $conn;
    private $table_name = "courses"; // ATUALIZADO: Agora usa a tabela 'courses'
    private $table_lessons = "lessons";

    public function __construct($db) {
        $this->conn = $db;
    }

    // 1. Busca todos os cursos (Para a tela Biblioteca)
    public function getAll() {
        $user_id = 1; // Fixo para teste

        // Esta Query conta o Total de Aulas VS Aulas Completas
        $query = "SELECT 
                    c.id, 
                    c.title, 
                    c.description, 
                    c.image_url, 
                    c.category, -- Adicionei categoria caso precises no futuro
                    
                    -- CONTA O TOTAL DE LIÇÕES DO CURSO
                    -- Alterado de library_item_id para course_id
                    (SELECT COUNT(*) FROM lessons WHERE course_id = c.id) as total_lessons,

                    -- CONTA AS LIÇÕES QUE O UTILIZADOR JÁ VIU
                    (SELECT COUNT(*) 
                     FROM lessons l
                     JOIN lesson_progress lp ON l.id = lp.lesson_id
                     WHERE l.course_id = c.id -- Alterado para course_id
                     AND lp.user_id = :uid 
                     AND lp.is_completed = 1) as completed_lessons

                  FROM " . $this->table_name . " c
                  WHERE c.is_active = 1 -- Só mostra cursos ativos
                  ORDER BY c.id ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $user_id);
        $stmt->execute();
        return $stmt;
    }

    // 2. Busca todas as lições de um curso
    public function getLessonsByCourse($course_id) {
        $user_id = 1; // ID fixo para teste

        $query = "SELECT 
                    l.id, 
                    l.title, 
                    l.description, 
                    l.video_url, 
                    l.duration_minutes,
                    
                    -- Mantivemos a lógica dinâmica (0 por defeito)
                    0 as is_locked, 
                    
                    -- Progresso real vindo da tabela lesson_progress
                    COALESCE(lp.is_completed, 0) as is_completed,
                    
                    -- Favoritos reais
                    CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END as is_favorited

                  FROM " . $this->table_lessons . " l
                  LEFT JOIN lesson_progress lp ON l.id = lp.lesson_id AND lp.user_id = :uid
                  LEFT JOIN favorites f ON l.id = f.lesson_id AND f.user_id = :uid2
                  
                  -- ATUALIZADO: library_item_id mudou para course_id
                  WHERE l.course_id = :cid
                  
                  GROUP BY l.id
                  ORDER BY l.lesson_order ASC"; // Ordenar pela ordem da aula, não pelo ID
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $user_id);
        $stmt->bindParam(':uid2', $user_id);
        $stmt->bindParam(':cid', $course_id);
        $stmt->execute();
        return $stmt;
    }

    // 3. Busca a primeira lição (Para preview)
    public function getFirstLesson($course_id) {
        $query = "SELECT title, description, video_url, duration_minutes 
                  FROM " . $this->table_lessons . " 
                  WHERE course_id = ? -- ATUALIZADO
                  ORDER BY lesson_order ASC
                  LIMIT 1";
                  
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $course_id);
        $stmt->execute();
        return $stmt;
    }
}
?>