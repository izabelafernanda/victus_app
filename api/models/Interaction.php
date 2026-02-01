<?php
class Interaction {
    private $conn;

    public function __construct($db) {
        $this->conn = $db;
    }

    // --- FAVORITOS ---
    public function toggleFavorite($user_id, $lesson_id) {
        // 1. Verifica se já é favorito
        $checkQuery = "SELECT id FROM favorites WHERE user_id = ? AND lesson_id = ?";
        $stmt = $this->conn->prepare($checkQuery);
        $stmt->bindParam(1, $user_id);
        $stmt->bindParam(2, $lesson_id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            // Se já existe, REMOVE (Desfavoritar)
            $query = "DELETE FROM favorites WHERE user_id = ? AND lesson_id = ?";
            $action = "removed";
        } else {
            // Se não existe, ADICIONA (Favoritar)
            $query = "INSERT INTO favorites (user_id, lesson_id) VALUES (?, ?)";
            $action = "added";
        }

        $stmt2 = $this->conn->prepare($query);
        $stmt2->bindParam(1, $user_id);
        $stmt2->bindParam(2, $lesson_id);
        
        if ($stmt2->execute()) {
            return $action; // Retorna se adicionou ou removeu
        }
        return false;
    }

    // --- PROGRESSO (Concluir Aula) ---
    public function updateProgress($user_id, $lesson_id, $is_completed) {
        // 1. Salva o progresso da aula atual
        $query = "INSERT INTO lesson_progress (user_id, lesson_id, is_completed, updated_at) 
                  VALUES (:user_id, :lesson_id, :is_completed, NOW())
                  ON DUPLICATE KEY UPDATE is_completed = :is_completed, updated_at = NOW()";
        
        $stmt = $this->conn->prepare($query);
        $status = $is_completed ? 1 : 0;
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':lesson_id', $lesson_id);
        $stmt->bindParam(':is_completed', $status);

        if ($stmt->execute()) {
            // --- NOVA LÓGICA: DESBLOQUEAR A PRÓXIMA AULA ---
            if ($is_completed) {
                $this->unlockNextLesson($lesson_id);
            }
            return true;
        }
        return false;
    }

    // Função Auxiliar para desbloquear
    private function unlockNextLesson($current_lesson_id) {
        // Acha o ID da próxima aula (assumindo ordem sequencial de IDs)
        $findNext = "SELECT id FROM lessons WHERE id > ? ORDER BY id ASC LIMIT 1";
        $stmtNext = $this->conn->prepare($findNext);
        $stmtNext->bindParam(1, $current_lesson_id);
        $stmtNext->execute();

        if ($row = $stmtNext->fetch(PDO::FETCH_ASSOC)) {
            $next_id = $row['id'];
            // Atualiza a próxima aula para is_locked = 0
            $unlockQuery = "UPDATE lessons SET is_locked = 0 WHERE id = ?";
            $stmtUnlock = $this->conn->prepare($unlockQuery);
            $stmtUnlock->bindParam(1, $next_id);
            $stmtUnlock->execute();
        }
    }
}
?>