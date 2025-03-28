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
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(50) DEFAULT NULL,
  `operation` varchar(10) DEFAULT NULL,
  `operation_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `user_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
INSERT INTO `logs` VALUES (1,'book','INSERT','2025-03-27 09:39:46','root@127.0.0.1'),(2,'book','UPDATE','2025-03-27 09:45:59','root@localhost'),(3,'book','DELETE','2025-03-27 09:47:14','root@127.0.0.1'),(4,'orders','INSERT','2025-03-27 09:48:26','root@localhost'),(5,'orders','UPDATE','2025-03-27 09:52:58','root@localhost'),(6,'ordes','DELETE','2025-03-27 09:53:39','root@127.0.0.1'),(7,'book','UPDATE','2025-03-27 10:05:19','root@localhost'),(8,'book','INSERT','2025-03-27 10:22:12','root@127.0.0.1'),(9,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(10,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(11,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(12,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(13,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(14,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(15,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(16,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(17,'book','UPDATE','2025-03-27 10:25:11','root@localhost'),(18,'book','INSERT','2025-03-27 10:28:39','root@127.0.0.1'),(19,'book','INSERT','2025-03-27 10:28:39','root@127.0.0.1'),(20,'orders','INSERT','2025-03-27 10:29:07','root@localhost'),(21,'orders','INSERT','2025-03-27 10:29:07','root@localhost'),(22,'orders','INSERT','2025-03-27 10:46:19','userTask3@localhost'),(23,'book','INSERT','2025-03-27 11:04:29','root@127.0.0.1');
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
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
