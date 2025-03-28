<?php
include_once 'connection.php'; // Подключение к файлу с настройками

// Создание класса для работы с базой данных
class Database {
    private $connection;

    public function __construct($host, $user, $password, $database) {
        try {
            $this->connection = new PDO("mysql:host=$host;dbname=$database;charset=utf8", $user, $password);
            // Установка режима обработки ошибок
            $this->connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
        }
    }

    public function query($sql) {
        return $this->connection->query($sql);
    }

    public function close() {
        $this->connection = null; // Закрытие соединения
    }
}

// Создание экземпляра класса Database
$db = new Database($host, $user, $password, $database);

// Параметры пагинации
$N = 3; // Количество отображаемых товаров
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1; // устаовлены ли параметер page в URL если да то преобразует в целое число, если нет то параметер по умолчаню
$offset = ($page - 1) * $N; // вычитаем 1 из номера страницы и получаем кол-во полных страниц (2-1=1) - перед ней была полная страница *N - общее кол-во товаров которыое нужно прокрутить
//$offset = (2 - 1) * 3 = 1 * 3 = 3 (page=2, N=3)


// Фильтрация
$filters = [];
if (isset($_GET['price']) && $_GET['price'] !== '') {
    $price = (float)$_GET['price'];
    $filters[] = "price <= $price";
}
if (isset($_GET['name']) && $_GET['name'] !== '') {
    $name = htmlspecialchars($_GET['name']);
    $filters[] = "name LIKE '%$name%'";
}
if (isset($_GET['description']) && $_GET['description'] !== '') {
    $description = htmlspecialchars($_GET['description']);
    $filters[] = "description LIKE '%$description%'";
}

$filterString = !empty($filters) ? 'WHERE ' . implode(' AND ', $filters) : ''; // не является ли массив пустым, функция implode объединяет элементы массива $filters в одну строку, 
                                                                                                // используя ' AND ' в качестве разделителя и : ''; - если массив пустой 

// Запрос на выборку количества товаров
$countQuery = "SELECT COUNT(*) FROM games $filterString";
$totalItems = $db->query($countQuery)->fetchColumn();
$totalPages = ceil($totalItems / $N);

// Запрос на выборку товаров с учетом пагинации и фильтрации
$query = "SELECT `name`, description, price FROM games $filterString LIMIT $offset, $N";
$result = $db->query($query);

// Проверка результата
if ($result->rowCount() > 0) {
    // Вывод данных в виде параграфов
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        echo "<h2>" . htmlspecialchars($row['name']) . "</h2>";
        echo "<p>" . htmlspecialchars($row['description']) . "</p>";
        echo "<p>Цена: " . number_format($row['price'], 2, ',', ' ') . " руб.</p>";
    }
} else {
    echo "Нет товаров для отображения.";
}

// Отображение номеров страниц
for ($i = 1; $i <= $totalPages; $i++) {
    echo "<a href='showList.php?page=$i'>" . $i . "</a> ";
}
// Форма фильтрации
?>
<form action="showList.php" method="GET">
    <input type="number" name="price" placeholder="Максимальная цена" value="<?php echo isset($_GET['price']) ? htmlspecialchars($_GET['price']) : ''; ?>">
    <input type="text" name="name" placeholder="Название" value="<?php echo isset($_GET['name']) ? htmlspecialchars($_GET['name']) : ''; ?>">
    <input type="text" name="description" placeholder="Описание" value="<?php echo isset($_GET['description']) ? htmlspecialchars($_GET['description']) : ''; ?>">
    <button type="submit" name="filter" value="yes">Фильтровать</button>
    <button type="submit" name="filter" value="no">Очистить</button>
</form>

<?php
// Закрытие подключения
$db->close();
?>
