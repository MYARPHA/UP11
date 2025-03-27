-- Задание 1
-- Создание пользователя userTask1 с привелегиями SHOW DATABASES

CREATE USER 'userTask1'@'localhost';
GRANT SHOW DATABASES ON *.* TO 'userTask1'@'localhost';

-- Задание 2
CREATE USER 'userTask2'@'localhost' IDENTIFIED BY '123'; -- пароль 123
GRANT ALL PRIVILEGES ON *.* TO 'userTask2'@'localhost';


-- Задание 3
CREATE USER 'userTask3'@'localhost' identified by 'qwerty';
GRANT SELECT, INSERT, UPDATE, DELETE ON Market.* TO 'userTask3'@'localhost';

-- Задание 4
CREATE USER 'userTask4'@'localhost';
GRANT SELECT ON Market.book TO 'userTask4'@'localhost';


#Task 5
CREATE USER 'userTask5'@'localhost';
GRANT SELECT(id, title, price), UPDATE(price) ON Market.Book TO 'userTask5'@'localhost';


