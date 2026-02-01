<?php
require_once __DIR__ . '/core/bootstrap.php';
require_once __DIR__ . '/controllers/LibraryController.php';

$controller = new LibraryController();
$controller->index();
