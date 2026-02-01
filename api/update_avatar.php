<?php
require_once __DIR__ . '/core/bootstrap.php';
require_once __DIR__ . '/controllers/ProfileController.php';

$controller = new ProfileController();
$controller->updateAvatar();
