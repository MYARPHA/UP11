SELECT a.surname,country, a.name, book.title AS book_title, book.price
FROM authors a
INNER JOIN book ON a.id = book.author_id
WHERE country = 'Англия'