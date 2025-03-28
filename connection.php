<?php
$host = '127.0.0.1'; // Хост базы данных
$db = 'market'; // Имя базы данных
$user = 'root'; // Имя пользователя
$pass = 'root'; // Пароль

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo "Ошибка подключения: " . $e->getMessage();
}
?>
