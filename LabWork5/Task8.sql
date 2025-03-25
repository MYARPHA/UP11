INSERT INTO authors (surname, name, country)
VALUES ('1', '1', 'США')
ON DUPLICATE KEY UPDATE
    country = VALUES(country);