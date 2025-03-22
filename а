SELECT market.customers.login, 
       COUNT(market.orders.id) AS order_count, 
       SUM(market.composition.count) AS total_books, 
       SUM(market.book.price * market.composition.count) AS total_spent
FROM market.orders
JOIN market.customers ON market.orders.customers_id = market.customers.id
JOIN market.composition ON market.orders.id = market.composition.order_id
JOIN market.book ON market.composition.book_id = market.book.id
GROUP BY market.customers.login;