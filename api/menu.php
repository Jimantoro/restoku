<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['id'])) {
            $stmt = $pdo->prepare("SELECT m.*, k.nama_kategori FROM menu m 
                                   LEFT JOIN kategori k ON m.id_kategori = k.id_kategori 
                                   WHERE m.id_menu = ?");
            $stmt->execute([$_GET['id']]);
            $data = $stmt->fetch(PDO::FETCH_ASSOC);
        } else {
            $stmt = $pdo->query("SELECT m.*, k.nama_kategori FROM menu m 
                                LEFT JOIN kategori k ON m.id_kategori = k.id_kategori 
                                WHERE m.status = 'tersedia' 
                                ORDER BY m.nama_menu");
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }
        echo json_encode($data);
        break;
        
    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        $stmt = $pdo->prepare("INSERT INTO menu (nama_menu, harga, deskripsi, id_kategori, stok) 
                              VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$input['nama_menu'], $input['harga'], $input['deskripsi'], 
                       $input['id_kategori'], $input['stok']]);
        echo json_encode(['status' => 'success', 'id' => $pdo->lastInsertId()]);
        break;
        
    case 'PUT':
        $input = json_decode(file_get_contents('php://input'), true);
        $stmt = $pdo->prepare("UPDATE menu SET nama_menu=?, harga=?, deskripsi=?, 
                              id_kategori=?, stok=?, status=? WHERE id_menu=?");
        $stmt->execute([$input['nama_menu'], $input['harga'], $input['deskripsi'], 
                       $input['id_kategori'], $input['stok'], $input['status'], $input['id_menu']]);
        echo json_encode(['status' => 'success']);
        break;
}
?>