SELECT
	country,
    COUNT(*) AS author_count
FROM authors
GROUP BY country
HAVING COUNT(*) > 1;