<?php include 'header.php'; ?>

<main>
    <?php
    $id = $_GET['id'];
    $stmt = $pdo->prepare("SELECT * FROM games WHERE idGame = :id");
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    $game = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($game) {
        // Отображение логотипа
        if ($game['logo']) {
            echo "<img src='{$game['logo']}' alt='{$game['name']}' style='float:left; margin-right: 20px; max-width: 200px;'>";
        }
        
        echo "<h2>{$game['name']}</h2>";
        echo "<p>{$game['description']}</p>";
        echo "<p>Цена: " . number_format($game['price'], 2, ',', ' ') . " руб.</p>";
        
        // Проверка, добавлен ли товар в корзину
        $cartStmt = $pdo->prepare("SELECT * FROM Cart WHERE game_id = :game_id");
        $cartStmt->bindParam(':game_id', $id);
        $cartStmt->execute();
        $inCart = $cartStmt->rowCount() > 0;

       // Отображение кнопки "Добавить в корзину" или "Уже в корзине"
       if ($inCart) {
        echo "<p style='color: green;'>Игра уже в корзине!</p>";
    } else {
        echo "<form action='add_to_cart.php' method='POST'>";
        echo "<input type='hidden' name='game_id' value='{$game['idGame']}'>";
        echo "<button type='submit'>Добавить в корзину</button>";
        echo "</form>";
    }
} else {
    echo "<p>Игра не найдена.</p>";
}
?>
</main>

<?php include 'footer.php'; ?>
