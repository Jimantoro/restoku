<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        $stmt = $pdo->query("SELECT * FROM kategori ORDER BY nama_kategori");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($data);
        break;
        
    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        $stmt = $pdo->prepare("INSERT INTO kategori (nama_kategori, icon) VALUES (?, ?)");
        $stmt->execute([$input['nama_kategori'], $input['icon']]);
        echo json_encode(['status' => 'success', 'id' => $pdo->lastInsertId()]);
        break;
}
?>