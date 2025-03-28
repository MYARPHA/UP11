<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Название МОЕГО сайта</title>
    <link rel="stylesheet" href="styles.css"> <!-- Подключение стилей -->
</head>
<body>
<header>
    <h1>Название сайта хихихаха</h1>
    <nav>
        <ul>
            <?php
            include 'connection.php'; // Подключение к БД
            $stmt = $pdo->query("SELECT DISTINCT category FROM games ORDER BY category");
            $currentCategory = isset($_GET['category']) ? $_GET['category'] : '';
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $active = ($currentCategory == $row['category']) ? 'class="active"' : '';
                echo "<li><a href='index.php?category={$row['category']}' $active>{$row['category']}</a></li>";
            }
            
            ?>
        </ul>
    </nav>
</header>
