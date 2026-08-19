<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['id'])) {
            // Get transaksi detail
            $stmt = $pdo->prepare("SELECT t.*, m.nomor_meja FROM transaksi t 
                                  LEFT JOIN meja m ON t.id_meja = m.id_meja 
                                  WHERE t.id_transaksi = ?");
            $stmt->execute([$_GET['id']]);
            $transaksi = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Get detail items
            $stmt = $pdo->prepare("SELECT d.*, menu.nama_menu FROM detail_transaksi d 
                                  JOIN menu ON d.id_menu = menu.id_menu 
                                  WHERE d.id_transaksi = ?");
            $stmt->execute([$_GET['id']]);
            $transaksi['items'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode($transaksi);
        } else {
            $stmt = $pdo->query("SELECT t.*, m.nomor_meja FROM transaksi t 
                                LEFT JOIN meja m ON t.id_meja = m.id_meja 
                                WHERE t.status = 'pending' 
                                ORDER BY t.tanggal DESC");
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($data);
        }
        break;
        
    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        
        try {
            $pdo->beginTransaction();
            
            // Generate nomor transaksi
            $nomor = 'INV-' . date('Ymd') . '-' . rand(1000, 9999);
            
            // Insert transaksi
            $stmt = $pdo->prepare("INSERT INTO transaksi (nomor_transaksi, id_meja, total, pajak, diskon, grand_total, metode_pembayaran) 
                                  VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$nomor, $input['id_meja'], $input['total'], $input['pajak'], 
                           $input['diskon'], $input['grand_total'], $input['metode_pembayaran']]);
            $id_transaksi = $pdo->lastInsertId();
            
            // Insert detail transaksi
            foreach ($input['items'] as $item) {
                $stmt = $pdo->prepare("INSERT INTO detail_transaksi (id_transaksi, id_menu, jumlah, harga_satuan, subtotal, catatan) 
                                      VALUES (?, ?, ?, ?, ?, ?)");
                $stmt->execute([$id_transaksi, $item['id_menu'], $item['jumlah'], 
                               $item['harga_satuan'], $item['subtotal'], $item['catatan']]);
                
                // Kurangi stok
                $stmt = $pdo->prepare("UPDATE menu SET stok = stok - ? WHERE id_menu = ?");
                $stmt->execute([$item['jumlah'], $item['id_menu']]);
            }
            
            // Update status meja
            $stmt = $pdo->prepare("UPDATE meja SET status = 'terisi' WHERE id_meja = ?");
            $stmt->execute([$input['id_meja']]);
            
            $pdo->commit();
            echo json_encode(['status' => 'success', 'id' => $id_transaksi, 'nomor' => $nomor]);
            
        } catch(Exception $e) {
            $pdo->rollBack();
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;
        
    case 'PUT':
        $input = json_decode(file_get_contents('php://input'), true);
        if (isset($input['action']) && $input['action'] == 'pay') {
            $stmt = $pdo->prepare("UPDATE transaksi SET status = 'paid' WHERE id_transaksi = ?");
            $stmt->execute([$input['id_transaksi']]);
            
            // Update meja menjadi kosong
            $stmt = $pdo->prepare("UPDATE meja SET status = 'kosong' 
                                  WHERE id_meja = (SELECT id_meja FROM transaksi WHERE id_transaksi = ?)");
            $stmt->execute([$input['id_transaksi']]);
            
            echo json_encode(['status' => 'success']);
        }
        break;
}
?>