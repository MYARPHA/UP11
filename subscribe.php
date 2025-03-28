<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];

    // Проверка на корректность email
    if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
        // Подготовка запроса для вставки email в таблицу Subscribers
        $stmt = $pdo->prepare("INSERT INTO Subscribers (email) VALUES (:email)");
        $stmt->bindParam(':email', $email);

        try {
            // Выполнение запроса
            $stmt->execute();
            echo "Вы успешно подписались на новости!";
        } catch (PDOException $e) {
            // Обработка ошибок, например, если email уже существует
            if ($e->getCode() == 23000) { // Код ошибки для уникального ограничения
                echo "Этот адрес электронной почты уже подписан на новости.";
            } else {
                echo "Ошибка при подписке: " . $e->getMessage();
            }
        }
    } else {
        echo "Некорректный адрес электронной почты.";
    }
} else {
    echo "Неверный запрос.";
}
?>
