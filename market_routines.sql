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
-- Temporary view structure for view `viewlistbooks`
--

DROP TABLE IF EXISTS `viewlistbooks`;
/*!50001 DROP VIEW IF EXISTS `viewlistbooks`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `viewlistbooks` AS SELECT 
 1 AS `surname`,
 1 AS `name`,
 1 AS `book_titles`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `viewauthorspricecategory`
--

DROP TABLE IF EXISTS `viewauthorspricecategory`;
/*!50001 DROP VIEW IF EXISTS `viewauthorspricecategory`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `viewauthorspricecategory` AS SELECT 
 1 AS `id`,
 1 AS `surname`,
 1 AS `name`,
 1 AS `title`,
 1 AS `price`,
 1 AS `category`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `viewchecktales`
--

DROP TABLE IF EXISTS `viewchecktales`;
/*!50001 DROP VIEW IF EXISTS `viewchecktales`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `viewchecktales` AS SELECT 
 1 AS `id`,
 1 AS `surname`,
 1 AS `name`,
 1 AS `title`,
 1 AS `price`,
 1 AS `has_tales`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `viewauthors`
--

DROP TABLE IF EXISTS `viewauthors`;
/*!50001 DROP VIEW IF EXISTS `viewauthors`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `viewauthors` AS SELECT 
 1 AS `id`,
 1 AS `surname`,
 1 AS `name`,
 1 AS `title`,
 1 AS `price`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `viewdelivers`
--

DROP TABLE IF EXISTS `viewdelivers`;
/*!50001 DROP VIEW IF EXISTS `viewdelivers`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `viewdelivers` AS SELECT 
 1 AS `id`,
 1 AS `order_date`,
 1 AS `customers_id`,
 1 AS `login`,
 1 AS `surname`,
 1 AS `name`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `viewlistbooks`
--

/*!50001 DROP VIEW IF EXISTS `viewlistbooks`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER */
/*!50001 VIEW `viewlistbooks` AS select `authors`.`surname` AS `surname`,`authors`.`name` AS `name`,group_concat(`book`.`title` separator ';') AS `book_titles` from (`authors` join `book` on((`authors`.`id` = `book`.`author_id`))) group by `authors`.`id`,`authors`.`surname`,`authors`.`name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `viewauthorspricecategory`
--

/*!50001 DROP VIEW IF EXISTS `viewauthorspricecategory`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER */
/*!50001 VIEW `viewauthorspricecategory` AS select `viewauthors`.`id` AS `id`,`viewauthors`.`surname` AS `surname`,`viewauthors`.`name` AS `name`,`viewauthors`.`title` AS `title`,`viewauthors`.`price` AS `price`,(case when (`viewauthors`.`price` < 1000) then 'Дешёвая' when (`viewauthors`.`price` between 1000 and 5000) then 'Средняя' else 'Дорогая' end) AS `category` from `viewauthors` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `viewchecktales`
--

/*!50001 DROP VIEW IF EXISTS `viewchecktales`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER */
/*!50001 VIEW `viewchecktales` AS select `viewauthors`.`id` AS `id`,`viewauthors`.`surname` AS `surname`,`viewauthors`.`name` AS `name`,`viewauthors`.`title` AS `title`,`viewauthors`.`price` AS `price`,(case when (`viewauthors`.`title` like '%сказки%') then 'Да' else 'Нет' end) AS `has_tales` from `viewauthors` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `viewauthors`
--

/*!50001 DROP VIEW IF EXISTS `viewauthors`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER */
/*!50001 VIEW `viewauthors` AS select `book`.`id` AS `id`,`authors`.`surname` AS `surname`,`authors`.`name` AS `name`,`book`.`title` AS `title`,`book`.`price` AS `price` from (`book` join `authors` on((`book`.`author_id` = `authors`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `viewdelivers`
--

/*!50001 DROP VIEW IF EXISTS `viewdelivers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER */
/*!50001 VIEW `viewdelivers` AS select `orders`.`id` AS `id`,`orders`.`order_date` AS `order_date`,`orders`.`customers_id` AS `customers_id`,`customers`.`login` AS `login`,`customers`.`surname` AS `surname`,`customers`.`name` AS `name` from (`customers` join `orders` on((`customers`.`id` = `orders`.`customers_id`))) where (year(`orders`.`order_date`) = year(now())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-03-28 12:30:46
