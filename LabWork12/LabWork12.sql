-- 1
USE market;

CREATE VIEW viewdelivers AS
SELECT orders.id, order_date, customers_id, login, surname, name
FROM customers
JOIN orders ON customers.id = orders.customers_id
WHERE YEAR(order_date) = YEAR(NOW());

-- 2
CREATE VIEW viewauthors AS
SELECT book.id, authors.surname, authors.name, book.title, book.price
FROM book
JOIN authors ON book.author_id = authors.id;

-- 3
CREATE VIEW viewlistbooks AS
SELECT authors.surname, authors.name, 
GROUP_CONCAT(book.title SEPARATOR ';') AS book_titles -- GROUP_CONCAT (работет с group by) объединяет значения из нескольких строк в одну строку
FROM authors
JOIN book ON authors.id = book.author_id
GROUP BY authors.id, authors.surname, authors.name; 
    
-- 4

CREATE VIEW ViewCheckTales AS
SELECT *,
CASE
	WHEN title LIKE '%сказки%' THEN 'Да'
	ELSE 'Нет'
	END AS has_tales
FROM viewauthors;

-- 5
CREATE VIEW ViewAuthorsPriceCategory AS
SELECT *,
    CASE
        WHEN price < 1000 THEN 'Дешёвая'
        WHEN price < 5000 THEN 'Средняя'
        ELSE 'Дорогая'
    END AS category
FROM viewauthors;