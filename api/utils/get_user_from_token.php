<?php
/**
 * Obtém user_id a partir do header Authorization (Bearer JWT).
 * Retorna o user_id (int) ou null se token ausente/inválido.
 */
include_once __DIR__ . '/jwt_helper.php';

function get_user_id_from_request() {
    $headers = getallheaders();
    $auth = isset($headers['Authorization']) ? $headers['Authorization'] : (isset($headers['authorization']) ? $headers['authorization'] : null);
    if (!$auth || strpos($auth, 'Bearer ') !== 0) {
        return null;
    }
    $token = trim(substr($auth, 7));
    if ($token === '') return null;
    $payload = JWT_Helper::validate($token);
    if (!$payload || !isset($payload['user_id'])) return null;
    return (int) $payload['user_id'];
}
