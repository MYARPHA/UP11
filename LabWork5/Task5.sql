UPDATE book
        JOIN
    authors ON book.author_id = authors.id 
SET 
    book.price = book.price + 100
WHERE
    authors.country = 'Англия';