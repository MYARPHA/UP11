-- Задание 1
DROP TRIGGER IF EXISTS after_delete_customers;
DELIMITER $$
CREATE TRIGGER after_delete_customers
AFTER DELETE ON customers
FOR EACH ROW
BEGIN
    INSERT INTO deleted_customers(id, login, surname, name, address, phone, deletion_date)
    VALUES (id, OLD.login, OLD.surname, OLD.name, OLD.address, OLD.phone, NOW());
END $$
SHOW TRIGGERS;

-- Задание 2
-- book
DELIMITER $$
CREATE TRIGGER after_insert_books
AFTER INSERT ON book
FOR EACH ROW
BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('book', 'INSERT', NOW(), USER());
END $$

DELIMITER $$
CREATE TRIGGER after_update_books
AFTER UPDATE ON book
FOR EACH ROW
BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('book', 'UPDATE', NOW(), USER());
END $$

DELIMITER $$
CREATE TRIGGER after_delete_books
AFTER DELETE ON book
FOR EACH ROW
BEGIN
   INSERT INTO Logs (table_name, operation, user_name)
    VALUES ('book', 'DELETE', CURRENT_USER());
END $$


-- orders
DELIMITER $$
CREATE TRIGGER after_insert_orders
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('orders', 'INSERT', NOW(), USER());
END $$

DELIMITER $$
CREATE TRIGGER after_update_orders
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('orders', 'UPDATE', NOW(), USER());
END $$

DELIMITER $$
CREATE TRIGGER after_delete_orders
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
   INSERT INTO Logs (table_name, operation, user_name)
    VALUES ('orders', 'DELETE', CURRENT_USER());
END $$
DELIMITER ;


-- Задание 3
DROP TRIGGER IF EXISTS after_delete_orders;

DELIMITER $$
CREATE TRIGGER after_delete_orders
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    DELETE FROM customers
    WHERE id = OLD.customers_id
    AND NOT EXISTS (
        SELECT 1 FROM orders WHERE customers_id = OLD.customers_id
    );
     INSERT INTO logs(table_name, operation, user_name)
	VALUES ('orders', 'DELETE', CURRENT_USER());
END $$

--
DELIMITER $$
-- Задание 4
CREATE TRIGGER after_insert_composition
AFTER INSERT ON composition
FOR EACH ROW
BEGIN
    SET @orderCost = (
        SELECT SUM(composition.count * book.price) 
        FROM composition
        JOIN book ON composition.book_id = book.id
        WHERE composition.order_id = NEW.order_id
    );
END $$
DELIMITER ;
SELECT @orderCost;


