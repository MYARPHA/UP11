SELECT a.surname, a.name
FROM market.authors a
WHERE a.id NOT IN (
	SELECT DISTINCT b.author_id
    FROM market.book b
    WHERE b.title LIKE '%linux%' OR b.title LIKE '%windows%');