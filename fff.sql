CREATE TABLE IF NOT EXISTS `market`.`BooksInfo` (
    `id` INT NOT NULL,
    `surname` VARCHAR(50) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `title` VARCHAR(50) NOT NULL,
    `price` DECIMAL(6,2) DEFAULT 0,   
    `pages` SMALLINT DEFAULT 0,
    `year_publication` YEAR,
    PRIMARY KEY (`id`)
);

ALTER TABLE `market`.`BooksInfo` 
MODIFY `id` INT NOT NULL AUTO_INCREMENT;

ALTER TABLE `market`.`BooksInfo` 
ADD CONSTRAINT UQ_BooksInfo_Title UNIQUE (`title`,`name`,`surname`);

ALTER TABLE BooksInfo 
ADD arrival_date DATE;

ALTER TABLE booksinfo 
DROP column pages;

