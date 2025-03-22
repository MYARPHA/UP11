SELECT
	b.id AS book_id,
    b.title AS book_title,
    '5%' AS discount,
    b.price * 0.95 AS price_with_discount
FROM book AS b;