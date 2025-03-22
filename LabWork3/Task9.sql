SELECT author_id, title, COUNT(*) AS book_count
FROM book
GROUP BY author_id, title