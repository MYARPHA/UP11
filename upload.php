<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $game_id = $_POST['game_id'];

    // Обработка логотипа
    if (isset($_FILES['logo']) && $_FILES['logo']['error'] == 0) {
        $logoPath = 'uploads/logos/' . basename($_FILES['logo']['name']);
        if (move_uploaded_file($_FILES['logo']['tmp_name'], $logoPath)) {
            // Обновление логотипа в таблице games
            $stmt = $pdo->prepare("UPDATE games SET logo = :logo WHERE idGame = :id");
            $stmt->bindParam(':logo', $logoPath);
            $stmt->bindParam(':id', $game_id);
            $stmt->execute();
        } else {
            echo "Ошибка при загрузке логотипа.";
        }
    }

    // Обработка иллюстраций
    if (isset($_FILES['photos'])) {
        foreach ($_FILES['photos']['tmp_name'] as $key => $tmp_name) {
            if ($_FILES['photos']['error'][$key] == 0) {
                $photoPath = 'uploads/photos/' . basename($_FILES['photos']['name'][$key]);
                if (move_uploaded_file($tmp_name, $photoPath)) {
                    // Сохранение пути к иллюстрации в таблице Photos
                    $stmt = $pdo->prepare("INSERT INTO Photos (game_id, photo_path) VALUES (:game_id, :photo_path)");
                    $stmt->bindParam(':game_id', $game_id);
                    $stmt->bindParam(':photo_path', $photoPath);
                    $stmt->execute();
                } else {
                    echo "Ошибка при загрузке иллюстрации.";
                }
            }
        }
    }

    // Перенаправление обратно на страницу игры или на страницу успеха
    header("Location: info.php?id=$game_id");
    exit();
}
?>
