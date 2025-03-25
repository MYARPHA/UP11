-- Процедуры это наборы операторов которые хранятся в базе данных и могут быть выполнены по запросу

-- Задание 1 
DELIMITER $$
CREATE PROCEDURE add_Customer(
    IN p_login VARCHAR(50),
    IN p_name VARCHAR(50),
    IN p_surname VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_phone VARCHAR(20)
)
BEGIN
    INSERT INTO customers (login, name, surname, address, phone)
    VALUES (p_login, p_name, p_surname, p_address, p_phone);

    SELECT LAST_INSERT_ID() AS customer_id; -- LAST_INSERT_ID() послелний автоинк.ID
END$$
DELIMITER;
CALL add_Customer('GooDLike', 'Артёмочка', 'мой кисик', 'Цигломень', '+22914881377');

-- Задание 2
DELIMITER $$
CREATE PROCEDURE getPartOfTitle(IN search_term VARCHAR(255))
BEGIN
    SELECT title 
    FROM book 
    WHERE title LIKE CONCAT('%', search_term, '%');
END$$
DELIMITER;

CALL getPartOfTitle('Война');

-- Задание 3
DELIMITER $$
CREATE PROCEDURE addNewAuthor(
    IN p_surname VARCHAR(255),
    IN p_name VARCHAR(255),
    IN p_country VARCHAR(255),
    OUT p_author_id INT -- OUT для передачи значения из процедуры обратно в вызывающий код(выходной параметер)
)
BEGIN
    INSERT INTO authors (surname, name, country)
    VALUES (p_surname, p_name, p_country);
    SET p_author_id = LAST_INSERT_ID();
END $$
DELIMITER;
CALL addNewAuthor('Бебебе', 'Бубубу', 'Россия', @new_author_id);
SELECT @new_author_id;
DROP PROCEDURE IF EXISTS addNewAuthor;

-- Задание 4
SET SQL_SAFE_UPDATES = 0;
DELIMITER $
CREATE PROCEDURE updateBooksPrice(IN p_percentage DECIMAL(5, 2))
BEGIN
    UPDATE book
    SET price = price + (price * (p_percentage / 100));
END $
DELIMITER;

CALL updateBooksPrice(5);
SELECT * FROM book;

-- Задание 5
DELIMITER $$
CREATE PROCEDURE deleteAuthorsWithoutBooks()
BEGIN
    DELETE FROM authors
    WHERE authors.id NOT IN (SELECT DISTINCT author_id FROM book);
	SELECT id, name, surname, country
    FROM authors;
END $$
DELIMITER ;

CALL deleteAuthorsWithoutBooks();

