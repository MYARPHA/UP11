<?php
include_once 'connection.php'; // Подключение к файлу с настройками

// Создание класса для работы с базой данных
class Database {
    private $connection;

    public function __construct($host, $user, $password, $database) {
        try {
            $this->connection = new PDO("mysql:host=$host;dbname=$database;charset=utf8", $user, $password);
            $this->connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            die("Ошибка подключения: " . $e->getMessage());
        }
    }

    public function query($sql) {
        return $this->connection->query($sql);
    }

    public function execute($sql, $params = []) {
        $stmt = $this->connection->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public function close() {
        $this->connection = null; // Закрытие соединения
    }
}

// Создание экземпляра класса Database
$db = new Database($host, $user, $password, $database);

// Определение параметра сортировки
$sortBy = isset($_GET["sortBy"]) ? $_GET["sortBy"] : "name"; // по имени
$allowSortColumn = ["name", "price"]; // разрешение на столбцы для сортировки

// Проверка, что столбец допустим
if (!in_array($sortBy, $allowSortColumn)) {
    $sortBy = "name"; // если нет, то значение по умолчанию
}

// Запрос на выборку всех данных из таблицы games
$query = "SELECT idGame, `name`, description, price, category FROM games ORDER BY $sortBy";
$result = $db->query($query);

// Проверка результата
if ($result->rowCount() > 0) {
    // Вывод данных в виде таблицы
    echo "<table border='1'>";
    echo "<tr><th>Название</th><th>Описание</th><th>Цена</th><th>Категория</th><th>Действия</th></tr>";
    
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        echo "<tr>";
        echo "<td>" . htmlspecialchars($row['name']) . "</td>";
        echo "<td>" . htmlspecialchars($row['description']) . "</td>";
        echo "<td>" . number_format($row['price'], 2, ',', ' ') . " руб.</td>";
        echo "<td>" . htmlspecialchars($row['category']) . "</td>"; // Отображение категории
        echo "<td>
                <form action='editTable.php' method='GET' style='display:inline;'>
                    <button name='upd' type='submit' value='" . $row['idGame'] . "'>Редактировать</button>
                </form>
                <form action='editTable.php' method='POST' style='display:inline;'>
                    <button name='del' type='submit' value='" . $row['idGame'] . "'>Удалить</button>
                </form>
              </td>";
        echo "</tr>";
    }
    
    echo "</table>";
} else {
    echo "Нет товаров для отображения.";
}
?>
<form action="showTable.php" method="GET">
    <label>
        <input type="radio" name="sortBy" value="name" <?php echo ($sortBy === 'name' ? 'checked' : ''); ?>> Название
    </label>
    <label>
        <input type="radio" name="sortBy" value="price" <?php echo ($sortBy === 'price' ? 'checked' : ''); ?>> Цена
    </label>
    <button type="submit">Сортировать</button>
</form>
<form action="editTable.php" method="GET">
    <button name='ins' type='submit'>Добавить</button>
</form>

<?php
// Закрытие подключения
$db->close();
?>
