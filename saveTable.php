<?php
include_once 'showTable.php'; // Подключение к файлу с классом Database

// Создание экземпляра класса Database
$db = new Database($host, $user, $password, $database);

// Проверка, если данные для добавления нового товара
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['name'])) {
    // Получение данных из формы
    $name = $_POST['name'];
    $description = $_POST['description'];
    $price = $_POST['price'];
    $category = $_POST['category']; // Получаем значение категории

    // Проверка, если это добавление нового товара
    if (!isset($_POST['id'])) {
        // SQL-запрос на добавление нового товара
        $sql = "INSERT INTO games (`name`, description, price, category) VALUES (:`name`, :description, :price, :category)";
        $db->execute($sql, [
            'name' => $name,
            'description' => $description,
            'price' => $price,
            'category' => $category // Передаем значение категории
        ]);
        echo "Товар '$name' был успешно добавлен.";
    } else {
        // Если это обновление существующего товара
        $idGame = $_POST['id'];

        // SQL-запрос на обновление товара
        $sql = "UPDATE games SET `name` = :`name`, description = :description, price = :price, category = :category WHERE idGame = :idGame";
        $db->execute($sql, [
            'idGame' => $idGame,
            'name' => $name,
            'description' => $description,
            'price' => $price,
            'category' => $category // Передаем значение категории
        ]);
        echo "Товар с ID: $idGame был успешно обновлен.";
    }
    echo "<br><a href='showTable.php'>Вернуться к списку товаров</a>";
    exit;
}

// Закрытие подключения
$db->close();
?>
