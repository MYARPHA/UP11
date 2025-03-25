SET SQL_SAFE_UPDATES = 0;
UPDATE tempbooks
SET 
    price = CASE 
        WHEN surname = 'Пушкин' THEN price * 2
        WHEN surname = 'Иванов' THEN price - 50
        ELSE price
    END;