<?php
ini_set('display_errors', 0);
error_reporting(0);

require_once __DIR__ . '/core/bootstrap.php';
require_once __DIR__ . '/controllers/DashboardController.php';

$controller = new DashboardController();
$controller->index();
