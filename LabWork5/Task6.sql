SET SQL_SAFE_UPDATES = 0;
DELETE FROM customers
WHERE id NOT IN (
    SELECT customers_id
    FROM orders
);