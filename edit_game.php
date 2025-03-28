<?php
include 'connection.php';

// Получение ID игры из URL
$game_id = $_GET['id'];

// Получение информации об игре из базы данных
$stmt = $pdo->prepare("SELECT * FROM games WHERE idGame = :id");
$stmt->bindParam(':id', $game_id);
$stmt->execute();
$game = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$game) {
    echo "Игра не найдена.";
    exit();
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Редактировать игру</title>
</head>
<body>
    <h1>Редактировать игру: <?php echo htmlspecialchars($game['name']); ?></h1>

    <form action="upload.php" method="POST" enctype="multipart/form-data">
        <input type="hidden" name="game_id" value="<?php echo $game_id; ?>">
        
        <label for="logo">Загрузить логотип:</label>
        <input type="file" name="logo" id="logo" accept="image/*" required>
        
        <label for="photos">Загрузить иллюстрации:</label>
        <input type="file" name="photos[]" id="photos" accept="image/*" multiple>
        
        <button type="submit">Загрузить</button>
    </form>
</body>
</html>
