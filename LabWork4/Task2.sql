SELECT a.surname, a.name, COUNT(b.id) AS book_count
FROM market.authors a
LEFT JOIN book b ON a.id = b.author_id
GROUP BY a.id;