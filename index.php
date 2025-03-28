<?php include 'header.php'; ?>

<main>
    <h2>Список игр</h2>
    <?php
    $category = isset($_GET['category']) ? $_GET['category'] : '';
    $query = "SELECT * FROM games";
    if ($category) {
        $query .= " WHERE category = :category";
    }
    $query .= " ORDER BY name";
    
    $stmt = $pdo->prepare($query);
    if ($category) {
        $stmt->bindParam(':category', $category);
    }
    $stmt->execute();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "<h3>{$row['name']}</h3>";
        echo "<p>{$row['description']}</p>";
        echo "<a href='info.php?id={$row['idGame']}'>Подробнее</a>";
    }
    ?>
</main>

<?php include 'footer.php'; ?>
