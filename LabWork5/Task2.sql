SET SQL_SAFE_UPDATES = 0;
INSERT INTO tempbooks (surname, name, title, price)
SELECT 
    authors.surname,
    authors.name,
    book.title,
    book.price
FROM 
    authors
JOIN 
    book ON authors.id = book.author_id;

DELETE FROM tempbooks
WHERE title LIKE '%компьютер%';