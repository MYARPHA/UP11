-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Market
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema Market
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Market` DEFAULT CHARACTER SET utf8 ;
SHOW WARNINGS;
USE `Market` ;

-- -----------------------------------------------------
-- Table `Market`.`Authors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Market`.`Authors` (
  `id_author` INT NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `country` VARCHAR(30) NOT NULL DEFAULT 'Россия',
  PRIMARY KEY (`id_author`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Market`.`Books`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Market`.`Books` (
  `id_book` INT NOT NULL,
  `id_author` INT NOT NULL,
  `title` VARCHAR(50) NOT NULL,
  `genre` ENUM('проза', 'поэзия', 'другое') NOT NULL DEFAULT 'проза',
  `price` DECIMAL(6,2) NOT NULL DEFAULT 0,
  `weight` DECIMAL(4,3) NOT NULL DEFAULT 0,
  `pages` SMALLINT NOT NULL DEFAULT 0,
  `year_publication` YEAR(4) NULL,
  `FK_id_Author` INT NOT NULL,
  PRIMARY KEY (`id_book`),
  INDEX `fk_Books_Authors_idx` (`FK_id_Author` ASC) VISIBLE,
  CONSTRAINT `fk_Books_Authors`
    FOREIGN KEY (`FK_id_Author`)
    REFERENCES `Market`.`Authors` (`id_author`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Market`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Market`.`Customers` (
  `id_customer` INT NOT NULL,
  `login` VARCHAR(20) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `phone_number` VARCHAR(20) NULL,
  PRIMARY KEY (`id_customer`),
  UNIQUE INDEX `login_UNIQUE` (`login` ASC) VISIBLE)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Market`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Market`.`Orders` (
  `id_order` INT NOT NULL,
  `order_datetime` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `FK_customer_id` INT NOT NULL,
  PRIMARY KEY (`id_order`),
  INDEX `fk_Orders_Customers1_idx` (`FK_customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_Orders_Customers1`
    FOREIGN KEY (`FK_customer_id`)
    REFERENCES `Market`.`Customers` (`id_customer`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Market`.`Orders_Details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Market`.`Orders_Details` (
  `count` TINYINT NULL DEFAULT 1,
  `PK_FK_id_order` INT NOT NULL,
  `PK_FK_id_book` INT NOT NULL,
  PRIMARY KEY (`PK_FK_id_order`, `PK_FK_id_book`),
  INDEX `fk_Orders_Details_Orders1_idx` (`PK_FK_id_order` ASC) VISIBLE,
  INDEX `fk_Orders_Details_Books1_idx` (`PK_FK_id_book` ASC) VISIBLE,
  CONSTRAINT `fk_Orders_Details_Orders1`
    FOREIGN KEY (`PK_FK_id_order`)
    REFERENCES `Market`.`Orders` (`id_order`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_Details_Books1`
    FOREIGN KEY (`PK_FK_id_book`)
    REFERENCES `Market`.`Books` (`id_book`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
