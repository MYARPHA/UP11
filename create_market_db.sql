-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
SHOW WARNINGS;
-- -----------------------------------------------------
-- Schema market
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema market
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `market` DEFAULT CHARACTER SET utf8mb3 ;
SHOW WARNINGS;
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
AUTO_INCREMENT = 15
DEFAULT CHARACTER SET = utf8mb3;

SHOW WARNINGS;

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
  `year_publication` YEAR NULL DEFAULT NULL,
  `pages` SMALLINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_author_id_idx` (`author_id` ASC) VISIBLE,
  CONSTRAINT `fk_author_id`
    FOREIGN KEY (`author_id`)
    REFERENCES `market`.`authors` (`id`)
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 8
DEFAULT CHARACTER SET = utf8mb3;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `market`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`orders` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customers_id` INT UNSIGNED NOT NULL,
  `order_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `customers_id_idx` (`customers_id` ASC) VISIBLE,
  CONSTRAINT `customers_id`
    FOREIGN KEY (`customers_id`)
    REFERENCES `market`.`сustomers` (`id`)
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb3;

SHOW WARNINGS;

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
DEFAULT CHARACTER SET = utf8mb3;

SHOW WARNINGS;

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
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb3;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `market`.`tempbooks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `market`.`tempbooks` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `surname` VARCHAR(50) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `titlle` VARCHAR(50) NOT NULL,
  `price` DECIMAL(6,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
