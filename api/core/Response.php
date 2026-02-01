<?php
/**
 * MVC Response helper - JSON output
 */
class Response {
    public static function json($data, $statusCode = 200) {
        http_response_code($statusCode);
        echo json_encode($data);
    }

    public static function success($data = [], $message = null) {
        $payload = array_merge(['status' => 'success'], is_array($data) ? $data : []);
        if ($message !== null) $payload['message'] = $message;
        self::json($payload, 200);
    }

    public static function error($message, $statusCode = 400) {
        self::json(['status' => 'error', 'message' => $message], $statusCode);
    }
}
