<?php
include_once __DIR__ . '/../config/database.php';
include_once __DIR__ . '/../models/Interaction.php';

class InteractionController {
    private $db;
    private $interaction;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->interaction = new Interaction($this->db);
    }

    public function favorite($data) {
        if (!isset($data->user_id) || !isset($data->lesson_id)) {
            http_response_code(400);
            return ["message" => "Dados incompletos (user_id, lesson_id)."];
        }

        $result = $this->interaction->toggleFavorite($data->user_id, $data->lesson_id);

        if ($result) {
            return ["status" => "success", "action" => $result, "message" => "Favoritos atualizados."];
        } else {
            http_response_code(500);
            return ["message" => "Erro ao atualizar favoritos."];
        }
    }

    public function progress($data) {
        if (!isset($data->user_id) || !isset($data->lesson_id) || !isset($data->is_completed)) {
            http_response_code(400);
            return ["message" => "Dados incompletos."];
        }

        $result = $this->interaction->updateProgress($data->user_id, $data->lesson_id, $data->is_completed);

        if ($result) {
            return ["status" => "success", "message" => "Progresso salvo."];
        } else {
            http_response_code(500);
            return ["message" => "Erro ao salvar progresso."];
        }
    }
}
?>