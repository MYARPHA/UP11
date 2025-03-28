-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: market
-- ------------------------------------------------------
-- Server version	8.0.19

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `author_id` int unsigned NOT NULL,
  `title` varchar(50) NOT NULL,
  `genre` enum('проза','поэзия','другое') NOT NULL DEFAULT 'проза',
  `price` decimal(6,2) unsigned NOT NULL,
  `weight` decimal(4,3) unsigned NOT NULL,
  `year_publication` smallint unsigned DEFAULT NULL,
  `pages` smallint DEFAULT NULL,
  `count` int DEFAULT '100',
  PRIMARY KEY (`id`),
  KEY `fk_author_id_idx` (`author_id`),
  CONSTRAINT `fk_author_id` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` VALUES (15,18,'Преступление и наказание','проза',650.00,0.500,1866,500,50),(16,19,'Новое название','проза',24.99,0.450,1868,600,50),(18,19,'Анна Каренина','проза',24.49,0.700,1877,864,50),(19,18,'1984','проза',18.37,0.300,1949,328,50),(21,17,'Старик и море','другое',138.04,0.200,1952,127,50),(23,19,'linux компьютер','проза',1.22,1.000,2000,456,50),(31,19,'linux компьютер','проза',1.22,1.000,1,NULL,50),(76,18,'Преступление и наказание','проза',19.99,0.500,1866,500,50),(78,17,'оч дорогая книг','другое',5000.00,1.500,2023,350,50),(81,17,'Книга 1','другое',500.00,1.200,2020,350,10),(82,17,'Книга 2','другое',300.00,1.000,2021,250,5),(83,17,'Книга 2','другое',20.00,1.500,2023,300,100);
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-03-28 12:30:45
