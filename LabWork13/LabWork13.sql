-- Задание 1
DELIMITER $$
CREATE FUNCTION getPriceByOrder(order_id INT)
RETURNS DECIMAL(10, 2) -- возврат стоимости заказа
BEGIN
    DECLARE total_price DECIMAL(10, 2); -- оператор для объявления перменных в хранимых процедурах и функциях(локальные переменные)
    
    SELECT IFNULL(SUM(book.price), 0) INTO total_price -- если null и ifnull заменит его на 0
    FROM book
    JOIN composition ON book.id = composition.book_id
    WHERE composition.order_id = order_id;
    RETURN total_price;
END$$

DELIMITER;
-- вызов функции для id = 17
SELECT getPriceByOrder(17)


-- Задание 2
DELIMITER $$
CREATE FUNCTION getFullnameByLogin (logins VARCHAR(20))
RETURNS VARCHAR(100)
BEGIN
    DECLARE fullname VARCHAR(100);
    SELECT CONCAT(UPPER(name), ' ', UPPER(surname)) 
    INTO fullname
    FROM customers
    WHERE customers.login = logins;
    RETURN fullname;
END $$
DELIMITER;
SELECT getFullnameByLogin('ivanov');

-- Задание 3
DELIMITER $$
CREATE FUNCTION getBooksByAuthorId(id INT)
RETURNS VARCHAR(200)
BEGIN
    DECLARE books VARCHAR(200);
    SELECT GROUP_CONCAT(book.title SEPARATOR ', ') INTO books
    FROM book
    WHERE book.author_id = id;
    RETURN books;
END
$$DELIMITER;

SELECT getBooksByAuthorId(17);

-- Задание 4
DELIMITER $$
CREATE FUNCTION getAuthorsCountByCountry (country_name VARCHAR(30))
RETURNS INT
BEGIN
    DECLARE authors_count INT;
	SELECT count(country) INTO authors_count FROM authors
    WHERE authors.country = country_name;
    RETURN authors_count;
END
$$DELIMITER;
SELECT  getAuthorsCountByCountry('США')

-- Задание 5
DELIMITER $$
CREATE FUNCTION getIncomeByYear()
RETURNS INT
BEGIN
    DECLARE total_price INT;
	SELECT 
		SUM(book.price * composition.count) INTO total_price -- цена книги * кол-во книг в составе заказа
	FROM composition
	JOIN book ON composition.book_id = book.id
	JOIN orders ON composition.order_id = orders.id
	WHERE year(order_date) = year_number;
    RETURN total_price;
END$$


SELECT getIncomeByYear(2025);