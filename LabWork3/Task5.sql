SELECT title, price,
	CASE
		WHEN price < 100 THEN 'дешевые'
        WHEN price BETWEEN 100 AND 1000 THEN 'средние'
        ELSE 'дорогие'
	END AS price_category
FROM book
ORDER BY price;