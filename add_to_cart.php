<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $game_id = $_POST['game_id'];

    // Добавление игры в корзину
    $stmt = $pdo->prepare("INSERT INTO Cart (game_id) VALUES (:game_id)");
    $stmt->bindParam(':game_id', $game_id);
    if ($stmt->execute()) {
        header("Location: info.php?id=$game_id"); // Перенаправление обратно на страницу игры
        exit();
    } else {
        echo "Ошибка при добавлении в корзину.";
    }
} else {
    echo "Неверный запрос.";
}
?>
