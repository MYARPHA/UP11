<?php
include_once 'connection.php';
include_once 'showTable.php'; // Подключение к файлу с настройками

// Создание экземпляра класса Database
$db = new Database($host, $user, $password, $database);

// Получение категорий из базы данных
$categoriesQuery = "SELECT idGame, `name` FROM games";
$categoriesResult = $db->query($categoriesQuery);
$categories = $categoriesResult->fetchAll(PDO::FETCH_ASSOC);

// Проверка, если нажата кнопка "Удалить"
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['del'])) {
    $idGame = $_POST['del'];
    // Выполнение SQL-запроса на удаление
    $sql = "DELETE FROM games WHERE idGame = :idGame";
    $db->execute($sql, ['idGame' => $idGame]);
    echo "Товар с ID: $idGame был успешно удален.";
    echo "<br><a href='showTable.php'>Вернуться к списку товаров</a>";
    exit;
}

// Проверка, если нажата кнопка "Добавить"
if (isset($_GET['ins'])) {
    // Отображение формы для добавления нового товара
    echo "<h3>Добавить новый товар</h3>
          <form action='saveTable.php' method='POST'>
              <label>Название: <input type='text' name='name' required></label><br>
              <label>Описание: <textarea name='description' required></textarea></label><br>
              <label>Цена: <input type='number' name='price' step='0.01' required></label><br>
              <label>Категория: 
                  <select name='category' required>";

    // Вывод категорий в выпадающем списке
    foreach ($categories as $category) {
        echo "<option value='" . htmlspecialchars($category['id']) . "'>" . htmlspecialchars($category['name']) . "</option>";
    }

    echo "      </select>
              </label><br>
              <button type='submit'>Сохранить</button>
          </form>";
    exit;
}

// Проверка, если нажата кнопка "Редактировать"
if (isset($_GET['upd'])) {
    $idGame = $_GET['upd'];
    // Запрос на выборку данных товара для редактирования
    $sql = "SELECT * FROM games WHERE idGame = :idGame";
    $stmt = $db->execute($sql, ['idGame' => $idGame]);
    $game = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($game) {
        // Отображение формы для редактирования товара
        echo "<h3>Редактировать товар</h3>
              <form action='saveTable.php' method='POST'>
                  <input type='hidden' name='id' value='" . htmlspecialchars($game['idGame']) . "'>
                  <label>Название: <input type='text' name='name' value='" . htmlspecialchars($game['name']) . "' required></label><br>
                  <label>Описание: <textarea name='description' required>" . htmlspecialchars($game['description']) . "</textarea></label><br>
                  <label>Цена: <input type='number' name='price' value='" . htmlspecialchars($game['price']) . "' step='0.01' required></label><br>
                  <label>Категория: 
                  <select name='category' required>";

        // Вывод категорий в выпадающем списке
        foreach ($categories as $category) {
            $selected = $category['id'] == $game['category'] ? 'selected' : '';
            echo "<option value='" . htmlspecialchars($category['id']) . "' $selected>" . htmlspecialchars($category['name']) . "</option>";
        }

        echo "      </select>
                  </label><br>
                  <button type='submit'>Сохранить</button>
              </form>";
    } else {
        echo "Товар не найден.";
    }
    exit;
}

// Закрытие подключения
$db->close();
?>
