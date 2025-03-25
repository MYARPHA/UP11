-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema market
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema market
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `market` DEFAULT CHARACTER SET utf8 ;
USE `market` ;

-- -----------------------------------------------------
-- Table `market`.`authors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`authors` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `surname` VARCHAR(50) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `country` VARCHAR(30) NOT NULL DEFAULT 'Россия',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_author_surname` (`surname` ASC) INVISIBLE,
  UNIQUE INDEX `idx_author_name` (`name` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 37
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`book` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `author_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(50) NOT NULL,
  `genre` ENUM('проза', 'поэзия', 'другое') NOT NULL DEFAULT 'проза',
  `price` DECIMAL(6,2) UNSIGNED NOT NULL,
  `weight` DECIMAL(4,3) UNSIGNED NOT NULL,
  `year_publication` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `pages` SMALLINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_author_id_idx` (`author_id` ASC) VISIBLE,
  CONSTRAINT `fk_author_id`
    FOREIGN KEY (`author_id`)
    REFERENCES `market`.`authors` (`id`)
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 32
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`booksinfo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`booksinfo` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `surname` VARCHAR(50) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `title` VARCHAR(50) NOT NULL,
  `price` DECIMAL(6,2) NULL DEFAULT '0.00',
  `year_publication` YEAR NULL DEFAULT NULL,
  `arrival_date` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `UQ_BooksInfo_Title` (`title` ASC) VISIBLE,
  UNIQUE INDEX `UQ_BooksInfo_Name` (`name` ASC) VISIBLE,
  UNIQUE INDEX `UQ_BooksInfo_Surname` (`surname` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`customers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `login` VARCHAR(20) NOT NULL,
  `surname` VARCHAR(50) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(15) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_customers_login` (`login` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 10
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`orders` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customers_id` INT UNSIGNED NOT NULL,
  `order_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `customers_id_idx` (`customers_id` ASC) VISIBLE,
  CONSTRAINT `fk_orders_customers`
    FOREIGN KEY (`customers_id`)
    REFERENCES `market`.`customers` (`id`)
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 21
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`composition`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`composition` (
  `order_id` INT UNSIGNED NOT NULL,
  `book_id` INT UNSIGNED NOT NULL,
  `count` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`order_id`, `book_id`),
  INDEX `fk_book_id_idx` (`book_id` ASC) VISIBLE,
  CONSTRAINT `fk_book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `market`.`book` (`id`),
  CONSTRAINT `fk_order_id`
    FOREIGN KEY (`order_id`)
    REFERENCES `market`.`orders` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`games`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`games` (
  `idGame` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(500) NULL DEFAULT NULL,
  `category` VARCHAR(50) NOT NULL,
  `price` DECIMAL(18,2) NOT NULL,
  PRIMARY KEY (`idGame`),
  FULLTEXT INDEX `idx_description` (`description`) VISIBLE,
  FULLTEXT INDEX `idx_name_description` (`name`, `description`) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 12
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`myeventtable`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`myeventtable` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `eventTime` DATETIME NOT NULL,
  `eventName` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 448
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`tempbooks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`tempbooks` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `surname` VARCHAR(50) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `title` VARCHAR(50) NOT NULL,
  `price` DECIMAL(6,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 90
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `market`.`video_games`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`video_games` (
  `Title` VARCHAR(200) NULL DEFAULT NULL,
  `MaxPlayers` TINYINT NULL DEFAULT NULL,
  `Genres` VARCHAR(100) NULL DEFAULT NULL,
  `Release Console` VARCHAR(100) NULL DEFAULT NULL,
  `ReleaseYear` SMALLINT NULL DEFAULT NULL,
  FULLTEXT INDEX `idx_genre` (`Genres`) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `market` ;

-- -----------------------------------------------------
-- Placeholder table for view `market`.`viewauthors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`viewauthors` (`id` INT, `surname` INT, `name` INT, `title` INT, `price` INT);

-- -----------------------------------------------------
-- Placeholder table for view `market`.`viewauthorspricecategory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`viewauthorspricecategory` (`id` INT, `surname` INT, `name` INT, `title` INT, `price` INT, `category` INT);

-- -----------------------------------------------------
-- Placeholder table for view `market`.`viewchecktales`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`viewchecktales` (`id` INT, `surname` INT, `name` INT, `title` INT, `price` INT, `has_tales` INT);

-- -----------------------------------------------------
-- Placeholder table for view `market`.`viewdelivers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`viewdelivers` (`id` INT, `order_date` INT, `customers_id` INT, `login` INT, `surname` INT, `name` INT);

-- -----------------------------------------------------
-- Placeholder table for view `market`.`viewlistbooks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`viewlistbooks` (`surname` INT, `name` INT, `book_titles` INT);

-- -----------------------------------------------------
-- procedure addNewAuthor
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `addNewAuthor`(
    IN p_surname VARCHAR(255),
    IN p_name VARCHAR(255),
    IN p_country VARCHAR(255),
    OUT p_author_id INT -- OUT для передачи значения из процедуры обратно в вызывающий код(выходной параметер)
)
BEGIN
    INSERT INTO authors (surname, name, country)
    VALUES (p_surname, p_name, p_country);
    SET p_author_id = LAST_INSERT_ID();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_Customer
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `add_Customer`(
    IN p_login VARCHAR(50),
    IN p_name VARCHAR(50),
    IN p_surname VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_phone VARCHAR(20)
)
BEGIN
    INSERT INTO customers (login, name, surname, address, phone)
    VALUES (p_login, p_name, p_surname, p_address, p_phone);

    SELECT LAST_INSERT_ID() AS customer_id; -- LAST_INSERT_ID() послелний автоинк.ID
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_Сustomer
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `add_Сustomer`(
    IN p_login VARCHAR(50),
    IN p_name VARCHAR(50),
    IN p_surname VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_phone VARCHAR(20)
)
BEGIN
    INSERT INTO customers (login, name, surname, address, phone)
    VALUES (p_login, p_name, p_surname, p_address, p_phone);

    SELECT LAST_INSERT_ID() AS customer_id; -- LAST_INSERT_ID() послелний автоинк.ID
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteAuthorsWithoutBooks
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `deleteAuthorsWithoutBooks`()
BEGIN
    DELETE FROM authors
    WHERE authors.id NOT IN (SELECT DISTINCT author_id FROM book);
	SELECT id, name, surname, country
    FROM authors;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getAuthorsCountByCountry
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getAuthorsCountByCountry`(country_name VARCHAR(30)) RETURNS int
BEGIN
    DECLARE authors_count INT;
	SELECT count(country) INTO authors_count FROM authors
    WHERE authors.country = country_name;
    RETURN authors_count;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getBooksByAuthorId
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getBooksByAuthorId`(id INT) RETURNS varchar(200) CHARSET utf8
BEGIN
    DECLARE books VARCHAR(200);
    SELECT GROUP_CONCAT(book.title SEPARATOR ', ') INTO books
    FROM book
    WHERE book.author_id = id;
    RETURN books;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getFullnameByLogin
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getFullnameByLogin`(logins VARCHAR(20)) RETURNS varchar(100) CHARSET utf8
BEGIN
    DECLARE fullname VARCHAR(100);
    
    SELECT CONCAT(UPPER(name), ' ', UPPER(surname)) 
    INTO fullname
    FROM customers
    WHERE customers.login = logins;
    
    RETURN fullname;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getIncomeByYear
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getIncomeByYear`(year_number INT) RETURNS int
BEGIN
    DECLARE total_price INT;
	SELECT 
		SUM(book.price * composition.count) INTO total_price -- цена книги * кол-во книг в составе заказа
	FROM composition
	JOIN book ON composition.book_id = book.id
	JOIN orders ON composition.order_id = orders.id
	WHERE year(order_date) = year_number;
    RETURN total_price;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getPartOfTitle
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `getPartOfTitle`(IN search_term VARCHAR(255))
BEGIN
    SELECT title 
    FROM book 
    WHERE title LIKE CONCAT('%', search_term, '%');
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getPriceByOrder
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getPriceByOrder`(order_id INT) RETURNS decimal(10,2)
BEGIN
    DECLARE total_price DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(book.price), 0) INTO total_price
    FROM book
    JOIN composition ON book.id = composition.book_id
    WHERE composition.order_id = order_id;
    RETURN total_price;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure updateBooksPrice
-- -----------------------------------------------------

DELIMITER $$
USE `market`$$
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `updateBooksPrice`(IN p_percentage DECIMAL(5, 2))
BEGIN
    UPDATE book
    SET price = price + (price * (p_percentage / 100));
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `market`.`viewauthors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `market`.`viewauthors`;
USE `market`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `market`.`viewauthors` AS select `market`.`book`.`id` AS `id`,`market`.`authors`.`surname` AS `surname`,`market`.`authors`.`name` AS `name`,`market`.`book`.`title` AS `title`,`market`.`book`.`price` AS `price` from (`market`.`book` join `market`.`authors` on((`market`.`book`.`author_id` = `market`.`authors`.`id`)));

-- -----------------------------------------------------
-- View `market`.`viewauthorspricecategory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `market`.`viewauthorspricecategory`;
USE `market`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `market`.`viewauthorspricecategory` AS select `viewauthors`.`id` AS `id`,`viewauthors`.`surname` AS `surname`,`viewauthors`.`name` AS `name`,`viewauthors`.`title` AS `title`,`viewauthors`.`price` AS `price`,(case when (`viewauthors`.`price` < 1000) then 'Дешёвая' when (`viewauthors`.`price` between 1000 and 5000) then 'Средняя' else 'Дорогая' end) AS `category` from `market`.`viewauthors`;

-- -----------------------------------------------------
-- View `market`.`viewchecktales`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `market`.`viewchecktales`;
USE `market`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `market`.`viewchecktales` AS select `viewauthors`.`id` AS `id`,`viewauthors`.`surname` AS `surname`,`viewauthors`.`name` AS `name`,`viewauthors`.`title` AS `title`,`viewauthors`.`price` AS `price`,(case when (`viewauthors`.`title` like '%сказки%') then 'Да' else 'Нет' end) AS `has_tales` from `market`.`viewauthors`;

-- -----------------------------------------------------
-- View `market`.`viewdelivers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `market`.`viewdelivers`;
USE `market`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `market`.`viewdelivers` AS select `market`.`orders`.`id` AS `id`,`market`.`orders`.`order_date` AS `order_date`,`market`.`orders`.`customers_id` AS `customers_id`,`market`.`customers`.`login` AS `login`,`market`.`customers`.`surname` AS `surname`,`market`.`customers`.`name` AS `name` from (`market`.`customers` join `market`.`orders` on((`market`.`customers`.`id` = `market`.`orders`.`customers_id`))) where (year(`market`.`orders`.`order_date`) = year(now()));

-- -----------------------------------------------------
-- View `market`.`viewlistbooks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `market`.`viewlistbooks`;
USE `market`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `market`.`viewlistbooks` AS select `market`.`authors`.`surname` AS `surname`,`market`.`authors`.`name` AS `name`,group_concat(`market`.`book`.`title` separator ';') AS `book_titles` from (`market`.`authors` join `market`.`book` on((`market`.`authors`.`id` = `market`.`book`.`author_id`))) group by `market`.`authors`.`id`,`market`.`authors`.`surname`,`market`.`authors`.`name`;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
