-- Задание 1
DROP TRIGGER IF EXISTS before_delete_customers;
DELIMITER $$
CREATE TRIGGER before_delete_customers
BEFORE DELETE ON customers
FOR EACH ROW
BEGIN
    DELETE FROM composition WHERE order_id IN (SELECT id FROM orders WHERE customers_id = OLD.id);
    
    DELETE FROM orders WHERE customers_id = OLD.id;
    
    INSERT INTO logs (table_name, operation, operation_time, user_name)
    VALUES ('customers', 'BEFORE', NOW(), USER());
END $$
DELETE FROM customers WHERE id = 21;
SELECT * FROM orders;
SELECT * FROM composition;
SELECT * FROM customers;

-- Задание 2
DELIMITER $$
CREATE TRIGGER before_insert_books
BEFORE INSERT ON book
FOR EACH ROW
BEGIN
    IF NEW.price > 5000 THEN
        SET NEW.price = 5000;
    END IF;
END $$

DELIMITER ;

INSERT INTO book (author_id, title, genre, price, weight, year_publication, pages)
VALUES (17, 'оч дорогая книг', 'другое', 6000, 1.5, 2023, 350);

SELECT * FROM book WHERE title = 'оч дорогая книг';

-- Задание 3
DELIMITER $$
CREATE TRIGGER before_insert_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_date IS NULL THEN
        SET NEW.order_date = NOW();
    END IF;
END $$
DELIMITER ;

-- Задание 4
DELIMITER $

CREATE TRIGGER before_insert_composition
BEFORE INSERT ON composition
FOR EACH ROW
BEGIN
    -- Уменьшаем количество экземпляров книги
    UPDATE book
    SET count = count - composition.count  -- Предполагается, что в таблице composition есть поле quantity
    WHERE id = NEW.book_id;

    -- Проверяем, чтобы количество не стало отрицательным
    IF (SELECT count FROM book WHERE id = composition.book_id) < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Недостаточно экземпляров книги для заказа';
    END IF;
END $

DELIMITER ;


INSERT INTO book (author_id, title, genre, price, weight, year_publication, pages, count)
VALUES 
    (17, 'Книга 1', 'другое', 500, 1.2, 2020, 350, 10),
    (17, 'Книга 2', 'другое', 300, 1.0, 2021, 250, 5); 

SELECT * FROM book;

INSERT INTO orders (customers_id, order_date)
VALUES 
    (7, '2025-03-01'),
    (7, '2025-03-02');

INSERT INTO composition (order_id, book_id, count)
VALUES 
    (22, 16, 4),
    (23, 16, 6); 

SELECT * FROM book;
SELECT * FROM orders;
SELECT * FROM composition;



