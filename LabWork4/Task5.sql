SELECT c.login, COUNT(DISTINCT o.id) AS order_count, 
       SUM(co.count) AS total_books
FROM market.orders o
JOIN market.customers c ON o.customers_id = c.id
JOIN market.composition co ON o.id = co.order_id
JOIN market.book b ON co.book_id = b.id
GROUP BY c.login
HAVING SUM(co.count) > 10;