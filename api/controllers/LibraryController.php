<?php
/**
 * Library Controller - Course/library items
 */
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

class LibraryController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function index() {
        $query = "SELECT id, title, description, image_url, progress FROM library_items";
        $stmt = $this->db->prepare($query);
        $stmt->execute();
        $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
        Response::json($items);
    }
}
