-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Мар 27 2025 г., 11:17
-- Версия сервера: 8.0.19
-- Версия PHP: 7.1.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `market`
--
CREATE DATABASE IF NOT EXISTS `market` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `market`;

-- --------------------------------------------------------

--
-- Структура таблицы `authors`
--

CREATE TABLE `authors` (
  `id` int UNSIGNED NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `country` varchar(30) NOT NULL DEFAULT 'Россия'
) ;

--
-- Дамп данных таблицы `authors`
--

INSERT INTO `authors` (`id`, `surname`, `name`, `country`) VALUES
(17, 'Оруэлл', 'Джордж', 'Англия'),
(18, 'Фицджеральд', 'Фрэнсис Скотт', 'США'),
(19, 'Хемингуэй', 'Эрнест', 'США');

-- --------------------------------------------------------

--
-- Структура таблицы `book`
--

CREATE TABLE `book` (
  `id` int UNSIGNED NOT NULL,
  `author_id` int UNSIGNED NOT NULL,
  `title` varchar(50) NOT NULL,
  `genre` enum('проза','поэзия','другое') NOT NULL DEFAULT 'проза',
  `price` decimal(6,2) UNSIGNED NOT NULL,
  `weight` decimal(4,3) UNSIGNED NOT NULL,
  `year_publication` smallint UNSIGNED DEFAULT NULL,
  `pages` smallint DEFAULT NULL,
  `count` int DEFAULT '100'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `book`
--

INSERT INTO `book` (`id`, `author_id`, `title`, `genre`, `price`, `weight`, `year_publication`, `pages`, `count`) VALUES
(15, 18, 'Преступление и наказание', 'проза', '650.00', '0.500', 1866, 500, 50),
(16, 19, 'Новое название', 'проза', '24.99', '0.450', 1868, 600, 50),
(18, 19, 'Анна Каренина', 'проза', '24.49', '0.700', 1877, 864, 50),
(19, 18, '1984', 'проза', '18.37', '0.300', 1949, 328, 50),
(21, 17, 'Старик и море', 'другое', '138.04', '0.200', 1952, 127, 50),
(23, 19, 'linux компьютер', 'проза', '1.22', '1.000', 2000, 456, 50),
(31, 19, 'linux компьютер', 'проза', '1.22', '1.000', 1, NULL, 50),
(76, 18, 'Преступление и наказание', 'проза', '19.99', '0.500', 1866, 500, 50),
(78, 17, 'оч дорогая книг', 'другое', '5000.00', '1.500', 2023, 350, 50),
(81, 17, 'Книга 1', 'другое', '500.00', '1.200', 2020, 350, 10),
(82, 17, 'Книга 2', 'другое', '300.00', '1.000', 2021, 250, 5),
(83, 17, 'Книга 2', 'другое', '20.00', '1.500', 2023, 300, 100);

--
-- Триггеры `book`
--
DELIMITER $$
CREATE TRIGGER `after_delete_books` AFTER DELETE ON `book` FOR EACH ROW BEGIN
   INSERT INTO Logs (table_name, operation, user_name)
    VALUES ('Книги', 'DELETE', CURRENT_USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_books` AFTER INSERT ON `book` FOR EACH ROW BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('book', 'INSERT', NOW(),CURRENT_USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_books` AFTER UPDATE ON `book` FOR EACH ROW BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('book', 'UPDATE', NOW(), USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_books` BEFORE INSERT ON `book` FOR EACH ROW BEGIN
    IF NEW.price > 5000 THEN
        SET NEW.price = 5000;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `booksinfo`
--

CREATE TABLE `booksinfo` (
  `id` int NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `price` decimal(6,2) DEFAULT '0.00',
  `year_publication` year DEFAULT NULL,
  `arrival_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `composition`
--

CREATE TABLE `composition` (
  `order_id` int UNSIGNED NOT NULL,
  `book_id` int UNSIGNED NOT NULL,
  `count` tinyint UNSIGNED NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `composition`
--

INSERT INTO `composition` (`order_id`, `book_id`, `count`) VALUES
(17, 15, 2),
(18, 16, 1),
(21, 16, 4);

--
-- Триггеры `composition`
--
DELIMITER $$
CREATE TRIGGER `after_insert_composition` AFTER INSERT ON `composition` FOR EACH ROW BEGIN
    SET @orderCost = (
        SELECT SUM(composition.count * book.price) 
        FROM composition
        JOIN book ON composition.book_id = book.id
        WHERE composition.order_id = NEW.order_id
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_composition` BEFORE INSERT ON `composition` FOR EACH ROW BEGIN
    -- Уменьшаем количество экземпляров книги
    UPDATE book
    SET count = count - composition.count  -- Предполагается, что в таблице composition есть поле quantity
    WHERE id = NEW.book_id;

    -- Проверяем, чтобы количество не стало отрицательным
    IF (SELECT count FROM book WHERE id = composition.book_id) < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Недостаточно экземпляров книги для заказа';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `customers`
--

CREATE TABLE `customers` (
  `id` int UNSIGNED NOT NULL,
  `login` varchar(20) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `phone` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `customers`
--

INSERT INTO `customers` (`id`, `login`, `surname`, `name`, `address`, `phone`) VALUES
(4, 'ivanov', 'Иванов', 'Иван', 'ул. Ленина, д. 10', '89991112233'),
(5, 'petrova', 'Петрова', 'Мария', 'пр. Победы, д. 5', '89990001122'),
(7, 'adc', 'Путин', 'Владимир', 'ул.Красная Площадь', NULL),
(9, 'GooDLike', 'мой кисик', 'Артёмочка', 'Цигломень', '+22914881377'),
(13, 'test_user4', 'Test', 'User', 'Test Address', '1234567890'),
(14, 'john_doe', 'Doe', 'John', '123 Elm Street', '0987654321'),
(15, 'mary_smith', 'Smith', 'Mary', '456 Oak Road', '1122334455'),
(16, 'alice_jones', 'Jones', 'Alice', '789 Pine Avenue', '9988776655'),
(17, 'bob_brown', 'Brown', 'Bob', '101 Maple Lane', '6677889900');

--
-- Триггеры `customers`
--
DELIMITER $$
CREATE TRIGGER `before_delete_customers` BEFORE DELETE ON `customers` FOR EACH ROW BEGIN
    DELETE FROM composition WHERE order_id IN (SELECT id FROM orders WHERE customers_id = OLD.id);
    
    DELETE FROM orders WHERE customers_id = OLD.id;
    
    INSERT INTO logs (table_name, operation, operation_time, user_name)
    VALUES ('customers', 'BEFORE', NOW(), USER());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `deleted_customers`
--

CREATE TABLE `deleted_customers` (
  `id` int NOT NULL,
  `login` varchar(20) DEFAULT NULL,
  `surname` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `deletion_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `deleted_customers`
--

INSERT INTO `deleted_customers` (`id`, `login`, `surname`, `name`, `address`, `phone`, `deletion_date`) VALUES
(0, 'sidorov', 'Сидоров', 'Алексей', 'ул. Мира, д. 2', '89998887766', '2025-03-27');

-- --------------------------------------------------------

--
-- Структура таблицы `games`
--

CREATE TABLE `games` (
  `idGame` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `price` decimal(18,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `games`
--

INSERT INTO `games` (`idGame`, `name`, `description`, `category`, `price`) VALUES
(1, 'SimCity', 'Градостроительный симулятор снова с вами! Создайте город своей мечты', 'Симулятор', '1499.00'),
(2, 'TITANFALL', 'Эта игра перенесет вас во вселенную, где малое противопоставляется большому, природа – индустрии, а человек – машине', 'Шутер', '2299.00'),
(3, 'Battlefield 4', 'Battlefield 4 – это определяющий для жанра, полный экшена боевик, известный своей разрушаемостью, равных которой нет', 'Шутер', '899.40'),
(4, 'The Sims 4', 'В реальности каждому человеку дано прожить лишь одну жизнь. Но с помощью The Sims 4 это ограничение можно снять! Вам решать — где, как и с кем жить, чем заниматься, чем украшать и обустраивать свой дом', 'Симулятор', '15.00'),
(5, 'Dark Souls 2', 'Продолжение знаменитого ролевого экшена вновь заставит игроков пройти через сложнейшие испытания. Dark Souls II предложит нового героя, новую историю и новый мир. Лишь одно неизменно – выжить в мрачной вселенной Dark Souls очень непросто.', 'RPG', '949.00'),
(6, 'The Elder Scrolls V: Skyrim', 'После убийства короля Скайрима империя оказалась на грани катастрофы. Вокруг претендентов на престол сплотились новые союзы, и разгорелся конфликт. К тому же, как предсказывали древние свитки, в мир вернулись жестокие и беспощадные драконы. Теперь будущее Скайрима и всей империи зависит от драконорожденного — человека, в жилах которого течет кровь легендарных существ.', 'RPG', '1399.00'),
(7, 'FIFA 14', 'Достоверный, красивый, эмоциональный футбол! Проверенный временем геймплей FIFA стал ещё лучше благодаря инновациям, поощряющим творческую игру в центре поля и позволяющим задавать её темп.', 'Симулятор', '699.00'),
(8, 'Need for Speed Rivals', 'Забудьте про стандартные режимы игры. Сотрите грань между одиночным и многопользовательским режимом в постоянном соперничестве между гонщиками и полицией. Свободно войдите в мир, в котором ваши друзья уже участвуют в гонках и погонях. ', 'Симулятор', '15.00'),
(9, 'Crysis 3', 'Действие игры разворачивается в 2047 году, а вам предстоит выступить в роли Пророка.', 'Шутер', '1299.00'),
(10, 'Dead Space 3', 'В Dead Space 3 Айзек Кларк и суровый солдат Джон Карвер отправляются в космическое путешествие, чтобы узнать о происхождении некроморфов.', 'Шутер', '499.00'),
(11, 'The Sims', 'AAAAAAAA', 'Симулятор', '200.00');

-- --------------------------------------------------------

--
-- Структура таблицы `logs`
--

CREATE TABLE `logs` (
  `id` int NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `operation` varchar(10) DEFAULT NULL,
  `operation_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `user_name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `logs`
--

INSERT INTO `logs` (`id`, `table_name`, `operation`, `operation_time`, `user_name`) VALUES
(1, 'book', 'INSERT', '2025-03-27 09:39:46', 'root@127.0.0.1'),
(2, 'book', 'UPDATE', '2025-03-27 09:45:59', 'root@localhost'),
(3, 'book', 'DELETE', '2025-03-27 09:47:14', 'root@127.0.0.1'),
(4, 'orders', 'INSERT', '2025-03-27 09:48:26', 'root@localhost'),
(5, 'orders', 'UPDATE', '2025-03-27 09:52:58', 'root@localhost'),
(6, 'ordes', 'DELETE', '2025-03-27 09:53:39', 'root@127.0.0.1'),
(7, 'book', 'UPDATE', '2025-03-27 10:05:19', 'root@localhost'),
(8, 'book', 'INSERT', '2025-03-27 10:22:12', 'root@127.0.0.1'),
(9, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(10, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(11, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(12, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(13, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(14, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(15, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(16, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(17, 'book', 'UPDATE', '2025-03-27 10:25:11', 'root@localhost'),
(18, 'book', 'INSERT', '2025-03-27 10:28:39', 'root@127.0.0.1'),
(19, 'book', 'INSERT', '2025-03-27 10:28:39', 'root@127.0.0.1'),
(20, 'orders', 'INSERT', '2025-03-27 10:29:07', 'root@localhost'),
(21, 'orders', 'INSERT', '2025-03-27 10:29:07', 'root@localhost'),
(22, 'orders', 'INSERT', '2025-03-27 10:46:19', 'userTask3@localhost'),
(23, 'book', 'INSERT', '2025-03-27 11:04:29', 'root@127.0.0.1');

-- --------------------------------------------------------

--
-- Структура таблицы `myeventtable`
--

CREATE TABLE `myeventtable` (
  `id` int NOT NULL,
  `eventTime` datetime NOT NULL,
  `eventName` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `myeventtable`
--

INSERT INTO `myeventtable` (`id`, `eventTime`, `eventName`) VALUES
(1, '2025-03-24 11:36:10', 'event1'),
(2, '2025-03-24 11:36:20', 'event1'),
(3, '2025-03-24 11:36:30', 'event1'),
(4, '2025-03-24 11:36:40', 'event1'),
(5, '2025-03-24 11:36:50', 'event1'),
(6, '2025-03-24 11:37:00', 'event1'),
(7, '2025-03-24 11:37:10', 'event1'),
(8, '2025-03-24 11:37:20', 'event1'),
(9, '2025-03-24 11:37:30', 'event1'),
(10, '2025-03-24 11:37:40', 'event1'),
(11, '2025-03-24 11:37:50', 'event1'),
(12, '2025-03-24 11:38:00', 'event1'),
(13, '2025-03-24 11:38:10', 'event1'),
(14, '2025-03-24 11:38:20', 'event1'),
(15, '2025-03-24 11:38:30', 'event1'),
(16, '2025-03-24 11:38:40', 'event1'),
(17, '2025-03-24 11:38:50', 'event1'),
(18, '2025-03-24 11:39:00', 'event1'),
(19, '2025-03-24 11:39:10', 'event1'),
(20, '2025-03-24 11:39:20', 'event1'),
(21, '2025-03-24 11:39:30', 'event1'),
(22, '2025-03-24 11:39:40', 'event1'),
(23, '2025-03-24 11:39:50', 'event1'),
(24, '2025-03-24 11:40:00', 'event1'),
(25, '2025-03-24 11:40:10', 'event1'),
(26, '2025-03-24 11:40:20', 'event1'),
(27, '2025-03-24 11:40:30', 'event1'),
(28, '2025-03-24 11:40:39', 'event2_30s'),
(29, '2025-03-24 11:40:40', 'event1'),
(30, '2025-03-24 11:40:50', 'event1'),
(31, '2025-03-24 11:40:51', 'event2'),
(32, '2025-03-24 11:41:00', 'event1'),
(33, '2025-03-24 11:41:09', 'event2_30s'),
(34, '2025-03-24 11:41:10', 'event1'),
(35, '2025-03-24 11:41:39', 'event2_30s'),
(36, '2025-03-24 11:42:09', 'event2_30s'),
(37, '2025-03-24 11:42:39', 'event2_30s'),
(38, '2025-03-24 11:42:51', 'event2'),
(39, '2025-03-24 11:43:09', 'event2_30s'),
(40, '2025-03-24 11:43:39', 'event2_30s'),
(41, '2025-03-24 11:44:09', 'event2_30s'),
(42, '2025-03-24 11:44:39', 'event2_30s'),
(43, '2025-03-24 11:44:51', 'event2'),
(44, '2025-03-24 11:45:09', 'event2_30s'),
(45, '2025-03-24 11:45:39', 'event2_30s'),
(46, '2025-03-24 11:46:09', 'event2_30s'),
(47, '2025-03-24 11:46:39', 'event2_30s'),
(48, '2025-03-24 11:46:51', 'event2'),
(49, '2025-03-24 11:47:09', 'event2_30s'),
(50, '2025-03-24 11:47:39', 'event2_30s'),
(51, '2025-03-24 11:48:09', 'event2_30s'),
(52, '2025-03-24 11:48:39', 'event2_30s'),
(53, '2025-03-24 11:48:51', 'event2'),
(54, '2025-03-24 11:49:09', 'event2_30s'),
(55, '2025-03-24 11:49:39', 'event2_30s'),
(56, '2025-03-24 11:50:09', 'event2_30s'),
(57, '2025-03-24 11:50:40', 'event2_30s'),
(58, '2025-03-24 11:50:51', 'event2'),
(59, '2025-03-24 11:51:09', 'event2_30s'),
(60, '2025-03-24 11:51:39', 'event2_30s'),
(61, '2025-03-24 11:52:09', 'event2_30s'),
(62, '2025-03-24 11:52:39', 'event2_30s'),
(63, '2025-03-24 11:52:51', 'event2'),
(64, '2025-03-24 11:53:09', 'event2_30s'),
(65, '2025-03-24 11:53:39', 'event2_30s'),
(66, '2025-03-24 11:54:09', 'event2_30s'),
(67, '2025-03-24 11:54:39', 'event2_30s'),
(68, '2025-03-24 11:54:51', 'event2'),
(69, '2025-03-24 11:55:09', 'event2_30s'),
(70, '2025-03-24 11:55:39', 'event2_30s'),
(71, '2025-03-24 11:56:09', 'event2_30s'),
(72, '2025-03-24 11:56:39', 'event2_30s'),
(73, '2025-03-24 11:56:51', 'event2'),
(74, '2025-03-24 11:57:09', 'event2_30s'),
(75, '2025-03-24 11:57:39', 'event2_30s'),
(76, '2025-03-24 11:58:09', 'event2_30s'),
(77, '2025-03-24 11:58:39', 'event2_30s'),
(78, '2025-03-24 11:58:51', 'event2'),
(79, '2025-03-24 11:59:09', 'event2_30s'),
(80, '2025-03-24 11:59:39', 'event2_30s'),
(81, '2025-03-24 12:00:09', 'event2_30s'),
(82, '2025-03-24 12:00:39', 'event2_30s'),
(83, '2025-03-24 12:00:51', 'event2'),
(84, '2025-03-24 12:01:09', 'event2_30s'),
(85, '2025-03-24 12:01:39', 'event2_30s'),
(86, '2025-03-24 12:02:09', 'event2_30s'),
(87, '2025-03-24 12:02:39', 'event2_30s'),
(88, '2025-03-24 12:02:51', 'event2'),
(89, '2025-03-24 12:03:09', 'event2_30s'),
(90, '2025-03-24 12:03:39', 'event2_30s'),
(91, '2025-03-24 12:04:09', 'event2_30s'),
(92, '2025-03-24 12:04:39', 'event2_30s'),
(93, '2025-03-24 12:04:51', 'event2'),
(94, '2025-03-24 12:05:09', 'event2_30s'),
(95, '2025-03-24 12:05:39', 'event2_30s'),
(96, '2025-03-24 12:06:09', 'event2_30s'),
(97, '2025-03-24 12:06:39', 'event2_30s'),
(98, '2025-03-24 12:06:51', 'event2'),
(99, '2025-03-24 12:07:09', 'event2_30s'),
(100, '2025-03-24 12:07:39', 'event2_30s'),
(101, '2025-03-24 12:08:09', 'event2_30s'),
(102, '2025-03-24 12:08:39', 'event2_30s'),
(103, '2025-03-24 12:08:51', 'event2'),
(104, '2025-03-24 12:09:09', 'event2_30s'),
(105, '2025-03-24 12:09:39', 'event2_30s'),
(106, '2025-03-24 12:10:09', 'event2_30s'),
(107, '2025-03-24 12:10:39', 'event2_30s'),
(108, '2025-03-24 12:10:51', 'event2'),
(109, '2025-03-24 12:11:09', 'event2_30s'),
(110, '2025-03-24 12:11:39', 'event2_30s'),
(111, '2025-03-24 12:12:09', 'event2_30s'),
(112, '2025-03-24 12:12:39', 'event2_30s'),
(113, '2025-03-24 12:12:51', 'event2'),
(114, '2025-03-24 12:13:09', 'event2_30s'),
(115, '2025-03-24 12:13:39', 'event2_30s'),
(116, '2025-03-24 12:14:10', 'event2_30s'),
(117, '2025-03-24 12:14:39', 'event2_30s'),
(118, '2025-03-24 12:14:51', 'event2'),
(119, '2025-03-24 12:15:09', 'event2_30s'),
(120, '2025-03-24 12:15:39', 'event2_30s'),
(121, '2025-03-24 12:16:09', 'event2_30s'),
(122, '2025-03-24 12:16:39', 'event2_30s'),
(123, '2025-03-24 12:16:51', 'event2'),
(124, '2025-03-24 12:17:09', 'event2_30s'),
(125, '2025-03-24 12:17:39', 'event2_30s'),
(126, '2025-03-24 12:18:09', 'event2_30s'),
(127, '2025-03-24 12:18:39', 'event2_30s'),
(128, '2025-03-24 12:18:51', 'event2'),
(129, '2025-03-24 12:19:09', 'event2_30s'),
(130, '2025-03-24 12:19:39', 'event2_30s'),
(131, '2025-03-24 12:20:09', 'event2_30s'),
(132, '2025-03-24 12:20:39', 'event2_30s'),
(133, '2025-03-24 12:20:51', 'event2'),
(134, '2025-03-24 12:21:09', 'event2_30s'),
(135, '2025-03-24 12:21:39', 'event2_30s'),
(136, '2025-03-24 12:22:09', 'event2_30s'),
(137, '2025-03-24 12:22:39', 'event2_30s'),
(138, '2025-03-24 12:22:51', 'event2'),
(139, '2025-03-24 12:23:09', 'event2_30s'),
(140, '2025-03-24 12:23:39', 'event2_30s'),
(141, '2025-03-24 12:24:09', 'event2_30s'),
(142, '2025-03-24 12:24:39', 'event2_30s'),
(143, '2025-03-24 12:24:51', 'event2'),
(144, '2025-03-24 12:25:09', 'event2_30s'),
(145, '2025-03-24 12:25:39', 'event2_30s'),
(146, '2025-03-24 12:26:09', 'event2_30s'),
(147, '2025-03-24 12:26:39', 'event2_30s'),
(148, '2025-03-24 12:26:51', 'event2'),
(149, '2025-03-25 08:04:51', 'event2'),
(150, '2025-03-25 08:05:09', 'event2_30s'),
(151, '2025-03-25 08:05:39', 'event2_30s'),
(152, '2025-03-25 08:06:10', 'event2_30s'),
(153, '2025-03-25 08:06:39', 'event2_30s'),
(154, '2025-03-25 08:06:51', 'event2'),
(155, '2025-03-25 08:07:09', 'event2_30s'),
(156, '2025-03-25 08:07:39', 'event2_30s'),
(157, '2025-03-25 08:08:09', 'event2_30s'),
(158, '2025-03-25 08:08:39', 'event2_30s'),
(159, '2025-03-25 08:08:51', 'event2'),
(160, '2025-03-25 08:09:09', 'event2_30s'),
(161, '2025-03-25 08:09:39', 'event2_30s'),
(162, '2025-03-25 08:10:09', 'event2_30s'),
(163, '2025-03-25 08:10:39', 'event2_30s'),
(164, '2025-03-25 08:10:51', 'event2'),
(165, '2025-03-25 08:11:09', 'event2_30s'),
(166, '2025-03-25 08:11:39', 'event2_30s'),
(167, '2025-03-25 08:12:09', 'event2_30s'),
(168, '2025-03-25 08:12:39', 'event2_30s'),
(169, '2025-03-25 08:12:51', 'event2'),
(170, '2025-03-25 08:13:09', 'event2_30s'),
(171, '2025-03-25 08:13:39', 'event2_30s'),
(172, '2025-03-25 08:14:09', 'event2_30s'),
(173, '2025-03-25 08:14:39', 'event2_30s'),
(174, '2025-03-25 08:14:51', 'event2'),
(175, '2025-03-25 08:15:09', 'event2_30s'),
(176, '2025-03-25 08:15:39', 'event2_30s'),
(177, '2025-03-25 08:16:09', 'event2_30s'),
(178, '2025-03-25 08:16:39', 'event2_30s'),
(179, '2025-03-25 08:16:51', 'event2'),
(180, '2025-03-25 08:17:09', 'event2_30s'),
(181, '2025-03-25 08:17:39', 'event2_30s'),
(182, '2025-03-25 08:18:09', 'event2_30s'),
(183, '2025-03-25 08:18:39', 'event2_30s'),
(184, '2025-03-25 08:18:51', 'event2'),
(185, '2025-03-25 08:19:09', 'event2_30s'),
(186, '2025-03-25 08:19:39', 'event2_30s'),
(187, '2025-03-25 08:20:09', 'event2_30s'),
(188, '2025-03-25 08:20:39', 'event2_30s'),
(189, '2025-03-25 08:20:51', 'event2'),
(190, '2025-03-25 08:21:09', 'event2_30s'),
(191, '2025-03-25 08:21:39', 'event2_30s'),
(192, '2025-03-25 08:22:09', 'event2_30s'),
(193, '2025-03-25 08:22:39', 'event2_30s'),
(194, '2025-03-25 08:22:51', 'event2'),
(195, '2025-03-25 08:23:09', 'event2_30s'),
(196, '2025-03-25 08:23:39', 'event2_30s'),
(197, '2025-03-25 08:24:09', 'event2_30s'),
(198, '2025-03-25 08:24:39', 'event2_30s'),
(199, '2025-03-25 08:24:51', 'event2'),
(200, '2025-03-25 08:25:09', 'event2_30s'),
(201, '2025-03-25 08:25:39', 'event2_30s'),
(202, '2025-03-25 08:26:09', 'event2_30s'),
(203, '2025-03-25 08:26:39', 'event2_30s'),
(204, '2025-03-25 08:26:51', 'event2'),
(205, '2025-03-25 08:27:09', 'event2_30s'),
(206, '2025-03-25 08:27:39', 'event2_30s'),
(207, '2025-03-25 08:28:09', 'event2_30s'),
(208, '2025-03-25 08:28:39', 'event2_30s'),
(209, '2025-03-25 08:28:51', 'event2'),
(210, '2025-03-25 08:29:10', 'event2_30s'),
(211, '2025-03-25 08:29:39', 'event2_30s'),
(212, '2025-03-25 08:30:09', 'event2_30s'),
(213, '2025-03-25 08:30:39', 'event2_30s'),
(214, '2025-03-25 08:30:51', 'event2'),
(215, '2025-03-25 08:31:09', 'event2_30s'),
(216, '2025-03-25 08:31:39', 'event2_30s'),
(217, '2025-03-25 08:32:09', 'event2_30s'),
(218, '2025-03-25 08:32:39', 'event2_30s'),
(219, '2025-03-25 08:32:51', 'event2'),
(220, '2025-03-25 08:33:09', 'event2_30s'),
(221, '2025-03-25 08:33:39', 'event2_30s'),
(222, '2025-03-25 08:34:09', 'event2_30s'),
(223, '2025-03-25 08:34:39', 'event2_30s'),
(224, '2025-03-25 08:34:51', 'event2'),
(225, '2025-03-25 08:35:09', 'event2_30s'),
(226, '2025-03-25 08:35:39', 'event2_30s'),
(227, '2025-03-25 08:36:09', 'event2_30s'),
(228, '2025-03-25 08:36:39', 'event2_30s'),
(229, '2025-03-25 08:36:51', 'event2'),
(230, '2025-03-25 08:37:09', 'event2_30s'),
(231, '2025-03-25 08:37:39', 'event2_30s'),
(232, '2025-03-25 08:38:09', 'event2_30s'),
(233, '2025-03-25 08:38:39', 'event2_30s'),
(234, '2025-03-25 08:38:51', 'event2'),
(235, '2025-03-25 08:39:09', 'event2_30s'),
(236, '2025-03-25 08:39:39', 'event2_30s'),
(237, '2025-03-25 08:40:09', 'event2_30s'),
(238, '2025-03-25 08:40:39', 'event2_30s'),
(239, '2025-03-25 08:40:51', 'event2'),
(240, '2025-03-25 08:41:09', 'event2_30s'),
(241, '2025-03-25 08:41:39', 'event2_30s'),
(242, '2025-03-25 08:42:09', 'event2_30s'),
(243, '2025-03-25 08:42:39', 'event2_30s'),
(244, '2025-03-25 08:42:51', 'event2'),
(245, '2025-03-25 08:43:09', 'event2_30s'),
(246, '2025-03-25 08:43:39', 'event2_30s'),
(247, '2025-03-25 08:44:09', 'event2_30s'),
(248, '2025-03-25 08:44:39', 'event2_30s'),
(249, '2025-03-25 08:44:51', 'event2'),
(250, '2025-03-25 08:45:09', 'event2_30s'),
(251, '2025-03-25 08:45:39', 'event2_30s'),
(252, '2025-03-25 08:46:09', 'event2_30s'),
(253, '2025-03-25 08:46:39', 'event2_30s'),
(254, '2025-03-25 08:46:51', 'event2'),
(255, '2025-03-25 08:47:09', 'event2_30s'),
(256, '2025-03-25 08:47:39', 'event2_30s'),
(257, '2025-03-25 08:48:09', 'event2_30s'),
(258, '2025-03-25 08:48:39', 'event2_30s'),
(259, '2025-03-25 08:48:51', 'event2'),
(260, '2025-03-25 08:49:09', 'event2_30s'),
(261, '2025-03-25 08:49:39', 'event2_30s'),
(262, '2025-03-25 08:50:09', 'event2_30s'),
(263, '2025-03-25 08:50:39', 'event2_30s'),
(264, '2025-03-25 08:50:51', 'event2'),
(265, '2025-03-25 08:51:09', 'event2_30s'),
(266, '2025-03-25 08:51:39', 'event2_30s'),
(267, '2025-03-25 08:52:09', 'event2_30s'),
(268, '2025-03-25 08:52:39', 'event2_30s'),
(269, '2025-03-25 08:52:51', 'event2'),
(270, '2025-03-25 08:53:09', 'event2_30s'),
(271, '2025-03-25 08:53:40', 'event2_30s'),
(272, '2025-03-25 08:54:09', 'event2_30s'),
(273, '2025-03-25 08:54:39', 'event2_30s'),
(274, '2025-03-25 08:54:51', 'event2'),
(275, '2025-03-25 08:55:09', 'event2_30s'),
(276, '2025-03-25 08:55:39', 'event2_30s'),
(277, '2025-03-25 08:56:09', 'event2_30s'),
(278, '2025-03-25 08:56:39', 'event2_30s'),
(279, '2025-03-25 08:56:51', 'event2'),
(280, '2025-03-25 08:57:09', 'event2_30s'),
(281, '2025-03-25 08:57:39', 'event2_30s'),
(282, '2025-03-25 08:58:09', 'event2_30s'),
(283, '2025-03-25 08:58:39', 'event2_30s'),
(284, '2025-03-25 08:58:51', 'event2'),
(285, '2025-03-25 08:59:09', 'event2_30s'),
(286, '2025-03-25 08:59:39', 'event2_30s'),
(287, '2025-03-25 09:00:09', 'event2_30s'),
(288, '2025-03-25 09:00:39', 'event2_30s'),
(289, '2025-03-25 09:00:51', 'event2'),
(290, '2025-03-25 09:01:09', 'event2_30s'),
(291, '2025-03-25 09:01:39', 'event2_30s'),
(292, '2025-03-25 09:02:09', 'event2_30s'),
(293, '2025-03-25 09:02:39', 'event2_30s'),
(294, '2025-03-25 09:02:51', 'event2'),
(295, '2025-03-25 09:03:09', 'event2_30s'),
(296, '2025-03-25 09:03:39', 'event2_30s'),
(297, '2025-03-25 09:04:09', 'event2_30s'),
(298, '2025-03-25 09:04:39', 'event2_30s'),
(299, '2025-03-25 09:04:51', 'event2'),
(300, '2025-03-25 09:05:09', 'event2_30s'),
(301, '2025-03-25 09:05:39', 'event2_30s'),
(302, '2025-03-25 09:06:09', 'event2_30s'),
(303, '2025-03-25 09:06:39', 'event2_30s'),
(304, '2025-03-25 09:06:51', 'event2'),
(305, '2025-03-25 09:07:09', 'event2_30s'),
(306, '2025-03-25 09:07:39', 'event2_30s'),
(307, '2025-03-25 09:08:09', 'event2_30s'),
(308, '2025-03-25 09:08:40', 'event2_30s'),
(309, '2025-03-25 09:08:51', 'event2'),
(310, '2025-03-25 09:09:09', 'event2_30s'),
(311, '2025-03-25 09:09:39', 'event2_30s'),
(312, '2025-03-25 09:10:09', 'event2_30s'),
(313, '2025-03-25 09:10:39', 'event2_30s'),
(314, '2025-03-25 09:10:51', 'event2'),
(315, '2025-03-25 09:11:09', 'event2_30s'),
(316, '2025-03-25 09:11:39', 'event2_30s'),
(317, '2025-03-25 09:12:09', 'event2_30s'),
(318, '2025-03-25 09:12:39', 'event2_30s'),
(319, '2025-03-25 09:12:51', 'event2'),
(320, '2025-03-25 09:13:09', 'event2_30s'),
(321, '2025-03-25 09:13:39', 'event2_30s'),
(322, '2025-03-25 09:14:09', 'event2_30s'),
(323, '2025-03-25 09:14:39', 'event2_30s'),
(324, '2025-03-25 09:14:51', 'event2'),
(325, '2025-03-25 09:15:09', 'event2_30s'),
(326, '2025-03-25 09:15:39', 'event2_30s'),
(327, '2025-03-25 09:16:09', 'event2_30s'),
(328, '2025-03-25 09:16:39', 'event2_30s'),
(329, '2025-03-25 09:16:51', 'event2'),
(330, '2025-03-25 09:17:09', 'event2_30s'),
(331, '2025-03-25 09:17:39', 'event2_30s'),
(332, '2025-03-25 09:18:09', 'event2_30s'),
(333, '2025-03-25 09:18:39', 'event2_30s'),
(334, '2025-03-25 09:18:51', 'event2'),
(335, '2025-03-25 09:19:09', 'event2_30s'),
(336, '2025-03-25 09:19:39', 'event2_30s'),
(337, '2025-03-25 09:20:09', 'event2_30s'),
(338, '2025-03-25 09:20:39', 'event2_30s'),
(339, '2025-03-25 09:20:51', 'event2'),
(340, '2025-03-25 09:21:09', 'event2_30s'),
(341, '2025-03-25 09:21:39', 'event2_30s'),
(342, '2025-03-25 09:22:09', 'event2_30s'),
(343, '2025-03-25 09:22:39', 'event2_30s'),
(344, '2025-03-25 09:22:51', 'event2'),
(345, '2025-03-25 09:23:09', 'event2_30s'),
(346, '2025-03-25 09:23:40', 'event2_30s'),
(347, '2025-03-25 09:24:09', 'event2_30s'),
(348, '2025-03-25 09:24:39', 'event2_30s'),
(349, '2025-03-25 09:24:51', 'event2'),
(350, '2025-03-25 09:25:09', 'event2_30s'),
(351, '2025-03-25 09:25:39', 'event2_30s'),
(352, '2025-03-25 09:26:09', 'event2_30s'),
(353, '2025-03-25 09:26:39', 'event2_30s'),
(354, '2025-03-25 09:26:51', 'event2'),
(355, '2025-03-25 09:27:09', 'event2_30s'),
(356, '2025-03-25 09:27:39', 'event2_30s'),
(357, '2025-03-25 09:28:09', 'event2_30s'),
(358, '2025-03-25 09:28:39', 'event2_30s'),
(359, '2025-03-25 09:28:51', 'event2'),
(360, '2025-03-25 09:29:09', 'event2_30s'),
(361, '2025-03-25 09:29:39', 'event2_30s'),
(362, '2025-03-25 09:30:09', 'event2_30s'),
(363, '2025-03-25 09:30:39', 'event2_30s'),
(364, '2025-03-25 09:30:51', 'event2'),
(365, '2025-03-25 09:31:09', 'event2_30s'),
(366, '2025-03-25 09:31:39', 'event2_30s'),
(367, '2025-03-25 09:32:09', 'event2_30s'),
(368, '2025-03-25 09:32:39', 'event2_30s'),
(369, '2025-03-25 09:32:51', 'event2'),
(370, '2025-03-25 09:33:09', 'event2_30s'),
(371, '2025-03-25 09:33:39', 'event2_30s'),
(372, '2025-03-25 09:34:09', 'event2_30s'),
(373, '2025-03-25 09:34:39', 'event2_30s'),
(374, '2025-03-25 09:34:51', 'event2'),
(375, '2025-03-25 09:35:09', 'event2_30s'),
(376, '2025-03-25 09:35:39', 'event2_30s'),
(377, '2025-03-25 09:36:09', 'event2_30s'),
(378, '2025-03-25 09:36:39', 'event2_30s'),
(379, '2025-03-25 09:36:51', 'event2'),
(380, '2025-03-25 09:37:09', 'event2_30s'),
(381, '2025-03-25 09:37:39', 'event2_30s'),
(382, '2025-03-25 09:38:09', 'event2_30s'),
(383, '2025-03-25 09:38:39', 'event2_30s'),
(384, '2025-03-25 09:38:51', 'event2'),
(385, '2025-03-25 09:39:09', 'event2_30s'),
(386, '2025-03-25 09:39:39', 'event2_30s'),
(387, '2025-03-25 09:40:09', 'event2_30s'),
(388, '2025-03-25 09:40:39', 'event2_30s'),
(389, '2025-03-25 09:40:51', 'event2'),
(390, '2025-03-25 09:41:09', 'event2_30s'),
(391, '2025-03-25 09:41:39', 'event2_30s'),
(392, '2025-03-25 09:42:09', 'event2_30s'),
(393, '2025-03-25 09:42:39', 'event2_30s'),
(394, '2025-03-25 09:42:51', 'event2'),
(395, '2025-03-25 09:43:10', 'event2_30s'),
(396, '2025-03-25 09:43:39', 'event2_30s'),
(397, '2025-03-25 09:44:09', 'event2_30s'),
(398, '2025-03-25 09:44:39', 'event2_30s'),
(399, '2025-03-25 09:44:51', 'event2'),
(400, '2025-03-25 09:45:09', 'event2_30s'),
(401, '2025-03-25 09:45:39', 'event2_30s'),
(402, '2025-03-25 09:46:09', 'event2_30s'),
(403, '2025-03-25 09:46:39', 'event2_30s'),
(404, '2025-03-25 09:46:51', 'event2'),
(405, '2025-03-25 09:47:09', 'event2_30s'),
(406, '2025-03-25 09:47:39', 'event2_30s'),
(407, '2025-03-25 09:48:09', 'event2_30s'),
(408, '2025-03-25 09:48:39', 'event2_30s'),
(409, '2025-03-25 09:48:51', 'event2'),
(410, '2025-03-25 09:49:09', 'event2_30s'),
(411, '2025-03-25 09:49:39', 'event2_30s'),
(412, '2025-03-25 09:50:09', 'event2_30s'),
(413, '2025-03-25 09:50:39', 'event2_30s'),
(414, '2025-03-25 09:50:51', 'event2'),
(415, '2025-03-25 09:51:09', 'event2_30s'),
(416, '2025-03-25 09:51:39', 'event2_30s'),
(417, '2025-03-25 09:52:09', 'event2_30s'),
(418, '2025-03-25 09:52:39', 'event2_30s'),
(419, '2025-03-25 09:52:51', 'event2'),
(420, '2025-03-25 09:53:09', 'event2_30s'),
(421, '2025-03-25 09:53:39', 'event2_30s'),
(422, '2025-03-25 09:54:09', 'event2_30s'),
(423, '2025-03-25 09:54:39', 'event2_30s'),
(424, '2025-03-25 09:54:51', 'event2'),
(425, '2025-03-25 09:55:09', 'event2_30s'),
(426, '2025-03-25 09:55:39', 'event2_30s'),
(427, '2025-03-25 09:56:09', 'event2_30s'),
(428, '2025-03-25 09:56:39', 'event2_30s'),
(429, '2025-03-25 09:56:51', 'event2'),
(430, '2025-03-25 09:57:09', 'event2_30s'),
(431, '2025-03-25 09:57:39', 'event2_30s'),
(432, '2025-03-25 09:58:09', 'event2_30s'),
(433, '2025-03-25 09:58:39', 'event2_30s'),
(434, '2025-03-25 09:58:51', 'event2'),
(435, '2025-03-25 09:59:09', 'event2_30s'),
(436, '2025-03-25 09:59:40', 'event2_30s'),
(437, '2025-03-25 10:00:09', 'event2_30s'),
(438, '2025-03-25 10:00:39', 'event2_30s'),
(439, '2025-03-25 10:00:51', 'event2'),
(440, '2025-03-25 10:01:09', 'event2_30s'),
(441, '2025-03-25 10:01:39', 'event2_30s'),
(442, '2025-03-25 10:02:09', 'event2_30s'),
(443, '2025-03-25 10:02:39', 'event2_30s'),
(444, '2025-03-25 10:02:51', 'event2'),
(445, '2025-03-25 10:03:09', 'event2_30s'),
(446, '2025-03-25 10:03:39', 'event2_30s'),
(447, '2025-03-25 10:04:09', 'event2_30s'),
(448, '2025-03-25 10:04:39', 'event2_30s'),
(449, '2025-03-25 10:04:51', 'event2'),
(450, '2025-03-25 10:05:09', 'event2_30s'),
(451, '2025-03-25 10:05:39', 'event2_30s'),
(452, '2025-03-25 10:06:09', 'event2_30s'),
(453, '2025-03-25 10:06:39', 'event2_30s'),
(454, '2025-03-25 10:06:51', 'event2'),
(455, '2025-03-25 10:07:09', 'event2_30s'),
(456, '2025-03-25 10:07:39', 'event2_30s'),
(457, '2025-03-25 10:08:09', 'event2_30s'),
(458, '2025-03-25 10:08:39', 'event2_30s'),
(459, '2025-03-25 10:08:51', 'event2'),
(460, '2025-03-25 10:09:09', 'event2_30s'),
(461, '2025-03-25 10:09:39', 'event2_30s'),
(462, '2025-03-25 10:10:09', 'event2_30s'),
(463, '2025-03-25 10:10:39', 'event2_30s'),
(464, '2025-03-25 10:10:51', 'event2'),
(465, '2025-03-25 10:11:09', 'event2_30s'),
(466, '2025-03-25 10:11:39', 'event2_30s'),
(467, '2025-03-25 10:12:09', 'event2_30s'),
(468, '2025-03-25 10:12:39', 'event2_30s'),
(469, '2025-03-25 10:12:51', 'event2'),
(470, '2025-03-25 10:13:09', 'event2_30s'),
(471, '2025-03-27 08:10:36', 'event3');

-- --------------------------------------------------------

--
-- Структура таблицы `orders`
--

CREATE TABLE `orders` (
  `id` int UNSIGNED NOT NULL,
  `customers_id` int UNSIGNED NOT NULL,
  `order_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `orders`
--

INSERT INTO `orders` (`id`, `customers_id`, `order_date`) VALUES
(17, 4, '2023-10-01 00:00:00'),
(18, 5, '2023-10-01 00:00:00'),
(21, 9, '2025-03-27 08:50:53'),
(22, 7, '2025-03-27 09:12:32'),
(27, 7, '2025-03-01 00:00:00'),
(28, 7, '2025-03-02 00:00:00'),
(30, 13, '2025-03-01 00:00:00');

--
-- Триггеры `orders`
--
DELIMITER $$
CREATE TRIGGER `after_insert_orders` AFTER INSERT ON `orders` FOR EACH ROW BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('orders', 'INSERT', NOW(), USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_orders` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO Logs (table_name, operation, operation_time, user_name)
    VALUES ('orders', 'UPDATE', NOW(), USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_orders` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    IF NEW.order_date IS NULL THEN
        SET NEW.order_date = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `tempbooks`
--

CREATE TABLE `tempbooks` (
  `id` int NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `price` decimal(6,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `video_games`
--

CREATE TABLE `video_games` (
  `Title` varchar(200) DEFAULT NULL,
  `MaxPlayers` tinyint DEFAULT NULL,
  `Genres` varchar(100) DEFAULT NULL,
  `Release Console` varchar(100) DEFAULT NULL,
  `ReleaseYear` smallint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `video_games`
--

INSERT INTO `video_games` (`Title`, `MaxPlayers`, `Genres`, `Release Console`, `ReleaseYear`) VALUES
('Super Mario 64 DS', 1, 'Action', 'Nintendo DS', 2004),
('Lumines: Puzzle Fusion', 1, 'Strategy', 'Sony PSP', 2004),
('WarioWare Touched!', 2, 'Action,Racing / Driving,Sports', 'Nintendo DS', 2004),
('Hot Shots Golf: Open Tee', 1, 'Sports', 'Sony PSP', 2004),
('Spider-Man 2', 1, 'Action', 'Nintendo DS', 2004),
('The Urbz: Sims in the City', 1, 'Simulation', 'Nintendo DS', 2004),
('Ridge Racer', 1, 'Racing / Driving', 'Sony PSP', 2004),
('Metal Gear Ac!d', 1, 'Strategy', 'Sony PSP', 2004),
('Madden NFL 2005', 1, 'Sports', 'Nintendo DS', 2004),
('Pokmon Dash', 1, 'Racing / Driving', 'Nintendo DS', 2004),
('Dynasty Warriors', 1, 'Action,Adventure,Role-Playing (RPG)', 'Sony PSP', 2004),
('Feel the Magic XY/XX', 1, 'Action,Adventure,Racing / Driving,Sports', 'Nintendo DS', 2004),
('Ridge Racer DS', 1, 'Racing / Driving', 'Nintendo DS', 2004),
('Darkstalkers Chronicle: The Chaos Tower', 1, 'Action', 'Sony PSP', 2004),
('Ape Escape Academy', 4, 'Action,Sports', 'Sony PSP', 2004),
('Polarium', 1, 'Strategy', 'Nintendo DS', 2004),
('Asphalt: Urban GT', 1, 'Racing / Driving,Simulation', 'Nintendo DS', 2004),
('Zoo Keeper', 1, 'Action', 'Nintendo DS', 2004),
('Mr. DRILLER: Drill Spirits', 1, 'Action', 'Nintendo DS', 2004),
('Sprung', 1, 'Adventure', 'Nintendo DS', 2004),
('Armored Core: Formula Front - Extreme Battle', 1, 'Action,Strategy', 'Sony PSP', 2004),
('Puyo Pop Fever', 1, 'Action,Strategy', 'Nintendo DS', 2004),
('Mario Kart DS', 1, 'Racing / Driving', 'Nintendo DS', 2005),
('Nintendogs', 1, 'Simulation', 'Nintendo DS', 2005),
('Brain Age: Train Your Brain in Minutes a Day!', 1, 'Action', 'Nintendo DS', 2005),
('Brain Agey: More Training in Minutes a Day!', 1, 'Action', 'Nintendo DS', 2005),
('Grand Theft Auto: Liberty City Stories', 1, 'Action,Racing / Driving', 'Sony PSP', 2005),
('Animal Crossing: Wild World', 1, 'Simulation', 'Nintendo DS', 2005),
('Big Brain Academy', 1, 'Action', 'Nintendo DS', 2005),
('Call of Duty 2', 4, 'Action', 'X360', 2005),
('Midnight Club 3: DUB Edition', 1, 'Racing / Driving', 'Sony PSP', 2005),
('Need for Speed: Most Wanted 5-1-0', 1, 'Racing / Driving', 'Sony PSP', 2005),
('Pokmon Mystery Dungeon: Blue Rescue Team', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2005),
('Sonic Rush', 1, 'Action', 'Nintendo DS', 2005),
('Star Wars: Battlefront II', 1, 'Action', 'Sony PSP', 2005),
('SOCOM: U.S. Navy SEALs - Fireteam Bravo', 1, 'Action', 'Sony PSP', 2005),
('Need for Speed: Most Wanted', 2, 'Racing / Driving', 'X360', 2005),
('Zoo Tycoon DS', 1, 'Simulation,Strategy', 'Nintendo DS', 2005),
('The Sims 2', 1, 'Role-Playing (RPG),Simulation', 'Nintendo DS', 2005),
('Mario & Luigi: Partners in Time', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2005),
('Madden NFL 06', 1, 'Sports', 'Sony PSP', 2005),
('Need for Speed Underground: Rivals', 4, 'Racing / Driving', 'Sony PSP', 2005),
('Twisted Metal: Head-On', 1, 'Action,Racing / Driving', 'Sony PSP', 2005),
('Perfect Dark Zero', 4, 'Action', 'X360', 2005),
('Super Monkey Ball: Touch & Roll', 1, 'Action', 'Nintendo DS', 2005),
('Super Princess Peach', 1, 'Action', 'Nintendo DS', 2005),
('Burnout Legends', 1, 'Action,Racing / Driving', 'Sony PSP', 2005),
('Madden NFL 06', 2, 'Sports', 'X360', 2005),
('Clubhouse Games', 1, 'Strategy', 'Nintendo DS', 2005),
('ATV Offroad Fury: Blazin\' Trails', 4, 'Racing / Driving,Sports', 'Sony PSP', 2005),
('Untold Legends: Brotherhood of the Blade', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2005),
('Tony Hawk\'s Underground 2: Remix', 1, 'Sports', 'Sony PSP', 2005),
('The Sims 2', 1, 'Simulation,Strategy', 'Sony PSP', 2005),
('WipEout Pure', 1, 'Action,Racing / Driving', 'Sony PSP', 2005),
('NBA Live 06', 1, 'Sports', 'Sony PSP', 2005),
('WWE Smackdown vs. Raw 2006', 4, 'Action,Sports', 'Sony PSP', 2005),
('Dead or Alive 4', 4, 'Action', 'X360', 2005),
('Phoenix Wright: Ace Attorney', 1, 'Adventure,Simulation', 'Nintendo DS', 2005),
('Spider-Man 2', 1, 'Action', 'Sony PSP', 2005),
('NFL Street 2', 4, 'Sports', 'Sony PSP', 2005),
('Kirby: Canvas Curse', 1, 'Action', 'Nintendo DS', 2005),
('Battlefield 2: Modern Combat', 4, 'Action', 'X360', 2005),
('Yoshi Touch & Go', 1, 'Action', 'Nintendo DS', 2005),
('Tiger Woods PGA Tour 06', 4, 'Sports', 'X360', 2005),
('Condemned: Criminal Origins', 1, 'Action,Adventure', 'X360', 2005),
('Peter Jackson\'s King Kong: The Official Game of...', 2, 'Action', 'X360', 2005),
('Castlevania: Dawn of Sorrow', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2005),
('SpongeBob SquarePants: The Yellow Avenger', 1, 'Action', 'Nintendo DS', 2005),
('Marvel Nemesis: Rise of the Imperfects ', 1, 'Action', 'Sony PSP', 2005),
('Kameo: Elements of Power', 1, 'Action', 'X360', 2005),
('Advance Wars: Dual Strike', 1, 'Strategy', 'Nintendo DS', 2005),
('Trauma Center: Under the Knife', 1, 'Action,Simulation', 'Nintendo DS', 2005),
('Coded Arms', 1, 'Action', 'Sony PSP', 2005),
('NBA LIVE 06 ', 1, 'Sports', 'X360', 2005),
('Tony Hawk\'s American Wasteland', 1, 'Sports', 'X360', 2005),
('Star Wars: Episode III - Revenge of the Sith', 1, 'Action', 'Nintendo DS', 2005),
('Capcom Classics Collection Remixed', 1, 'Action', 'Sony PSP', 2005),
('Madagascar', 1, 'Adventure', 'Nintendo DS', 2005),
('X-Men: Legends II - Rise of Apocalypse', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2005),
('Quake 4', 1, 'Action', 'X360', 2005),
('Pokmon Trozei!', 1, 'Strategy', 'Nintendo DS', 2005),
('Need for Speed: Most Wanted', 1, 'Racing / Driving', 'Nintendo DS', 2005),
('Mega Man Maverick Hunter X', 1, 'Action', 'Sony PSP', 2005),
('Metroid Prime Pinball', 1, 'Action,Simulation', 'Nintendo DS', 2005),
('NBA 06', 1, 'Sports', 'Sony PSP', 2005),
('GUN ', 1, 'Action,Racing / Driving,Role-Playing (RPG)', 'X360', 2005),
('NBA 2K6 ', 1, 'Sports', 'X360', 2005),
('Pinball Hall of Fame: The Gottlieb Collection', 4, 'Action', 'Sony PSP', 2005),
('Harry Potter and the Goblet of Fire', 1, 'Action', 'Nintendo DS', 2005),
('Tony Hawk\'s American Sk8land', 1, 'Sports', 'Nintendo DS', 2005),
('MVP Baseball', 1, 'Sports', 'Sony PSP', 2005),
('Tiger Woods PGA Tour', 1, 'Sports', 'Sony PSP', 2005),
('World Series of Poker', 1, 'Sports,Strategy', 'Sony PSP', 2005),
('SSX on Tour', 1, 'Sports', 'Sony PSP', 2005),
('Tiger Woods PGA Tour 06', 1, 'Sports', 'Sony PSP', 2005),
('Death Jr.', 1, 'Action', 'Sony PSP', 2005),
('Harry Potter and the Goblet of Fire', 1, 'Action', 'Sony PSP', 2005),
('MediEvil Resurrection', 1, 'Action', 'Sony PSP', 2005),
('The Chronicles of Narnia: The Lion, the Witch a...', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2005),
('Shrek SuperSlam', 1, 'Action', 'Nintendo DS', 2005),
('Virtua Tennis: World Tour', 1, 'Sports', 'Sony PSP', 2005),
('Prince of Persia: Revelations', 1, 'Action', 'Sony PSP', 2005),
('Burnout Legends', 1, 'Action,Racing / Driving', 'Nintendo DS', 2005),
('Meteos', 1, 'Strategy', 'Nintendo DS', 2005),
('Spyro: Shadow Legacy', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2005),
('The Con', 1, 'Action', 'Sony PSP', 2005),
('Infected', 1, 'Action', 'Sony PSP', 2005),
('Pursuit Force', 1, 'Action,Racing / Driving', 'Sony PSP', 2005),
('Kingdom of Paradise', 2, 'Action,Role-Playing (RPG)', 'Sony PSP', 2005),
('Dragon Ball Z: Supersonic Warriors 2', 1, 'Action', 'Nintendo DS', 2005),
('Dragon Quest Heroes: Rocket Slime', 1, 'Action', 'Nintendo DS', 2005),
('Dead to Rights: Reckoning', 1, 'Action', 'Sony PSP', 2005),
('Amped 3', 1, 'Sports', 'X360', 2005),
('Break \'em All', 1, 'Action', 'Nintendo DS', 2005),
('Lunar: Dragon Song', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2005),
('Madden NFL 06', 1, 'Sports', 'Nintendo DS', 2005),
('Retro Atari Classics', 1, 'Action,Racing / Driving,Simulation', 'Nintendo DS', 2005),
('True Swing Golf', 1, 'Sports', 'Nintendo DS', 2005),
('FIFA Soccer', 1, 'Sports', 'Sony PSP', 2005),
('Metal Gear Ac!d 2', 1, 'Strategy', 'Sony PSP', 2005),
('ATV Quad Frenzy', 1, 'Racing / Driving,Sports', 'Nintendo DS', 2005),
('Bomberman', 1, 'Strategy', 'Nintendo DS', 2005),
('GoldenEye: Rogue Agent', 1, 'Action', 'Nintendo DS', 2005),
('Need for Speed Underground 2', 1, 'Racing / Driving', 'Nintendo DS', 2005),
('Frogger: Helmet Chaos', 1, 'Action', 'Sony PSP', 2005),
('The Lord of the Rings: Tactics', 1, 'Role-Playing (RPG),Strategy', 'Sony PSP', 2005),
('Rengoku: The Tower of Purgatory', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2005),
('Gretzky NHL', 2, 'Sports', 'Sony PSP', 2005),
('Ridge Racer 6', 2, 'Racing / Driving', 'X360', 2005),
('Ford Racing 3', 1, 'Action,Racing / Driving', 'Nintendo DS', 2005),
('NHL 2K6 ', 1, 'Sports', 'X360', 2005),
('Bust-a-Move DS', 1, 'Action,Strategy', 'Nintendo DS', 2005),
('Battles of Prince of Persia', 1, 'Strategy', 'Nintendo DS', 2005),
('GripShift', 1, 'Racing / Driving', 'Sony PSP', 2005),
('Marvel Nemesis: Rise of the Imperfects ', 1, 'Action', 'Nintendo DS', 2005),
('Scooby-Doo! Unmasked', 1, 'Action', 'Nintendo DS', 2005),
('Viewtiful Joe: Double Trouble!', 1, 'Action', 'Nintendo DS', 2005),
('The Legend of Heroes: A Tear of Vermillion', 1, 'Role-Playing (RPG)', 'Sony PSP', 2005),
('PQ: Practical Intelligence Quotient', 1, 'Strategy', 'Sony PSP', 2005),
('Lost in Blue', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2005),
('Ghost in the Shell: Stand Alone Complex', 1, 'Action', 'Sony PSP', 2005),
('Dig Dug: Digging Strike', 1, 'Action', 'Nintendo DS', 2005),
('Frogger: Helmet Chaos', 1, 'Action', 'Nintendo DS', 2005),
('Mega Man Battle Network 5: Double Team DS', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2005),
('Nanostray', 1, 'Action', 'Nintendo DS', 2005),
('Sega Casino', 1, 'Simulation', 'Nintendo DS', 2005),
('Teenage Mutant Ninja Turtles 3: Mutant Nightmare', 1, 'Action,Adventure', 'Nintendo DS', 2005),
('Pac-Man World 3', 1, 'Action', 'Sony PSP', 2005),
('Tokobot', 1, 'Strategy', 'Sony PSP', 2005),
('Fullmetal Alchemist: Dual Sympathy', 1, 'Action', 'Nintendo DS', 2005),
('Exit', 1, 'Action', 'Sony PSP', 2005),
('Bubble Bobble Revolution', 1, 'Action', 'Nintendo DS', 2005),
('The Rub Rabbits!', 2, 'Action,Adventure', 'Nintendo DS', 2005),
('Electroplankton', 1, 'Simulation', 'Nintendo DS', 2005),
('LifeSigns: Surgical Unit', 1, 'Simulation,Strategy', 'Nintendo DS', 2005),
('Space Invaders Revolution', 1, 'Action', 'Nintendo DS', 2005),
('Wii Play', 2, 'Action,Sports', 'Nintendo Wii', 2006),
('New Super Mario Bros.', 1, 'Action', 'Nintendo DS', 2006),
('Pokmon Diamond', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Pokmon Pearl', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Gears of War', 2, 'Action', 'X360', 2006),
('The Legend of Zelda: Twilight Princess', 1, 'Action,Role-Playing (RPG)', 'Nintendo Wii', 2006),
('Cooking Mama', 1, 'Simulation', 'Nintendo DS', 2006),
('Marvel Ultimate Alliance', 4, 'Action,Role-Playing (RPG)', 'X360', 2006),
('Daxter', 1, 'Action', 'Sony PSP', 2006),
('The Elder Scrolls IV: Oblivion', 1, 'Action,Role-Playing (RPG)', 'X360', 2006),
('Madden NFL 07', 2, 'Sports', 'X360', 2006),
('Grand Theft Auto: Vice City Stories', 1, 'Action,Racing / Driving', 'Sony PSP', 2006),
('Resistance: Fall of Man', 4, 'Action', 'PlayStation 3', 2006),
('MotorStorm', 1, 'Action,Racing / Driving,Sports', 'PlayStation 3', 2006),
('Call of Duty 3', 2, 'Action', 'X360', 2006),
('Yoshi\'s Island DS', 1, 'Action', 'Nintendo DS', 2006),
('Tom Clancy\'s Ghost Recon: Advanced Warfighter', 4, 'Action', 'X360', 2006),
('Fight Night Round 3', 2, 'Action,Sports', 'X360', 2006),
('Pokmon Ranger', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Rayman Raving Rabbids', 4, 'Action', 'Nintendo Wii', 2006),
('Saints Row', 1, 'Action,Racing / Driving', 'X360', 2006),
('Tom Clancy\'s Rainbow Six: Vegas', 2, 'Action', 'X360', 2006),
('Dead Rising', 1, 'Action', 'X360', 2006),
('Call of Duty 3', 1, 'Action', 'Nintendo Wii', 2006),
('Lost Planet: Extreme Condition', 1, 'Action', 'X360', 2006),
('Mario Hoops 3 on 3', 1, 'Sports', 'Nintendo DS', 2006),
('LEGO Star Wars II: The Original Trilogy', 1, 'Action', 'Nintendo DS', 2006),
('Super Monkey Ball: Banana Blitz', 4, 'Action', 'Nintendo Wii', 2006),
('The Sims 2: Pets', 1, 'Simulation', 'Nintendo DS', 2006),
('Need for Speed: Carbon - Own the City', 1, 'Racing / Driving', 'Sony PSP', 2006),
('WarioWare: Smooth Moves', 6, 'Action,Racing / Driving,Sports', 'Nintendo Wii', 2006),
('Fight Night Round 3', 2, 'Action,Sports', 'PlayStation 3', 2006),
('Final Fantasy III', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('SOCOM: U.S. Navy SEALs - Fireteam Bravo 2', 1, 'Action', 'Sony PSP', 2006),
('Madden NFL 07', 1, 'Sports', 'Sony PSP', 2006),
('Monster 4x4: World Circuit', 4, 'Racing / Driving', 'Nintendo Wii', 2006),
('Kirby: Squeak Squad', 1, 'Action', 'Nintendo DS', 2006),
('Pokmon Battle Revolution', 4, 'Action,Strategy', 'Nintendo Wii', 2006),
('Medal of Honor: Heroes', 1, 'Action', 'Sony PSP', 2006),
('Tekken: Dark Resurrection', 1, 'Action', 'Sony PSP', 2006),
('Need for Speed: Carbon', 2, 'Racing / Driving', 'X360', 2006),
('Mario vs. Donkey Kong 2: March of the Minis', 1, 'Action', 'Nintendo DS', 2006),
('Sonic Rivals', 1, 'Action,Racing / Driving', 'Sony PSP', 2006),
('NCAA Football 07', 2, 'Sports', 'X360', 2006),
('Mortal Kombat: Unchained', 2, 'Action', 'Sony PSP', 2006),
('Tom Clancy\'s Splinter Cell: Double Agent', 1, 'Action', 'X360', 2006),
('Tetris DS', 1, 'Strategy', 'Nintendo DS', 2006),
('LEGO Star Wars II: The Original Trilogy', 2, 'Action', 'Sony PSP', 2006),
('Red Steel', 4, 'Action', 'Nintendo Wii', 2006),
('Metroid Prime: Hunters', 1, 'Action', 'Nintendo DS', 2006),
('LEGO Star Wars II: The Original Trilogy', 2, 'Action', 'X360', 2006),
('NBA 2K7 ', 1, 'Sports', 'X360', 2006),
('SEGA Genesis Collection', 2, 'Action,Racing / Driving,Role-Playing (RPG),Strategy', 'Sony PSP', 2006),
('Call of Duty 3', 1, 'Action', 'PlayStation 3', 2006),
('NBA Live 07', 1, 'Sports', 'Sony PSP', 2006),
('Madden NFL 07', 2, 'Sports', 'PlayStation 3', 2006),
('SpongeBob SquarePants: The Yellow Avenger', 1, 'Action', 'Sony PSP', 2006),
('Madden NFL 07', 4, 'Sports', 'Nintendo Wii', 2006),
('Fight Night Round 3', 2, 'Action,Simulation,Sports', 'Sony PSP', 2006),
('Need for Speed: Carbon', 2, 'Racing / Driving', 'PlayStation 3', 2006),
('Need for Speed: Carbon', 2, 'Racing / Driving', 'Nintendo Wii', 2006),
('WWE SmackDown vs. Raw 2007', 4, 'Sports', 'X360', 2006),
('Tiger Woods PGA Tour 07', 1, 'Sports', 'X360', 2006),
('Viva Pi$?ata', 4, 'Simulation,Strategy', 'X360', 2006),
('SpongeBob Squarepants: Creature from the Krusty Krab', 1, 'Action,Adventure', 'Nintendo Wii', 2006),
('Tony Hawk\'s Project 8', 2, 'Sports', 'Sony PSP', 2006),
('Tony Hawk\'s Project 8', 2, 'Sports', 'X360', 2006),
('NBA LIVE 07 ', 1, 'Sports', 'X360', 2006),
('Excite Truck', 2, 'Racing / Driving', 'Nintendo Wii', 2006),
('Harvest Moon DS', 1, 'Role-Playing (RPG),Simulation', 'Nintendo DS', 2006),
('Star Fox Command', 1, 'Action', 'Nintendo DS', 2006),
('Metal Gear Solid: Portable Ops', 1, 'Action,Strategy', 'Sony PSP', 2006),
('Marvel Ultimate Alliance', 4, 'Action,Role-Playing (RPG)', 'Nintendo Wii', 2006),
('Blazing Angels: Squadrons of WWII', 2, 'Action', 'X360', 2006),
('Major League Baseball 2K6', 2, 'Sports', 'X360', 2006),
('NCAA Football 07', 1, 'Sports', 'Sony PSP', 2006),
('MLB 06: The Show', 2, 'Sports', 'Sony PSP', 2006),
('Blazing Angels: Squadrons of WWII', 2, 'Action', 'PlayStation 3', 2006),
('WWE SmackDown vs. Raw 2007', 4, 'Sports', 'Sony PSP', 2006),
('Rune Factory: A Fantasy Harvest Moon', 1, 'Role-Playing (RPG),Simulation', 'Nintendo DS', 2006),
('Marvel Ultimate Alliance', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2006),
('Marvel Ultimate Alliance', 4, 'Action,Role-Playing (RPG)', 'PlayStation 3', 2006),
('Tiger Woods PGA Tour 07', 4, 'Sports', 'PlayStation 3', 2006),
('Ace Combat X: Skies of Deception', 1, 'Action,Simulation', 'Sony PSP', 2006),
('Killzone: Liberation', 1, 'Action,Strategy', 'Sony PSP', 2006),
('F.E.A.R.: First Encounter Assault Recon', 1, 'Action', 'X360', 2006),
('NBA 2K7', 7, 'Sports', 'PlayStation 3', 2006),
('Tony Hawk\'s Project 8', 2, 'Sports', 'PlayStation 3', 2006),
('Avatar: The Last Airbender', 1, 'Action', 'Nintendo DS', 2006),
('Castlevania: Portrait of Ruin', 1, 'Action', 'Nintendo DS', 2006),
('Hitman: Blood Money', 1, 'Action', 'X360', 2006),
('Rockstar Games presents Table Tennis', 2, 'Sports', 'X360', 2006),
('Trauma Center: Second Opinion', 1, 'Action,Simulation', 'Nintendo Wii', 2006),
('Tenchu Z', 1, 'Action', 'X360', 2006),
('Elite Beat Agents', 1, 'Action', 'Nintendo DS', 2006),
('Street Fighter Alpha 3 MAX', 1, 'Action', 'Sony PSP', 2006),
('Blue Dragon', 1, 'Role-Playing (RPG)', 'X360', 2006),
('The Lord of the Rings: The Battle for Middle Ea...', 1, 'Strategy', 'X360', 2006),
('Prey', 1, 'Action', 'X360', 2006),
('Over the Hedge', 1, 'Adventure', 'Nintendo DS', 2006),
('Capcom Classics Collection Reloaded', 1, 'Action', 'Sony PSP', 2006),
('Pirates of the Caribbean: Dead Man\'s Chest', 1, 'Action', 'Sony PSP', 2006),
('NHL 07 ', 1, 'Sports', 'X360', 2006),
('Monster Hunter Freedom', 1, 'Action,Strategy', 'Sony PSP', 2006),
('Chromehounds', 1, 'Action,Simulation,Strategy', 'X360', 2006),
('Test Drive Unlimited', 1, 'Racing / Driving', 'X360', 2006),
('Dragon Ball Z: Budokai Tenkaichi 2', 2, 'Action', 'Nintendo Wii', 2006),
('Dragon Quest Monsters: Joker', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Pirates of the Caribbean: Dead Man\'s Chest', 1, 'Action', 'Nintendo DS', 2006),
('NFL Street 3', 1, 'Action,Sports', 'Sony PSP', 2006),
('Syphon Filter: Dark Mirror', 1, 'Action', 'Sony PSP', 2006),
('NBA 07', 4, 'Sports', 'PlayStation 3', 2006),
('Ridge Racer 7', 2, 'Racing / Driving', 'PlayStation 3', 2006),
('The Outfit', 2, 'Action', 'X360', 2006),
('Elebits', 4, 'Action', 'Nintendo Wii', 2006),
('Tony Hawk\'s Downhill Jam', 1, 'Racing / Driving,Sports', 'Nintendo DS', 2006),
('The Sims 2: Pets', 1, 'Simulation', 'Sony PSP', 2006),
('Tiger Woods PGA Tour 07', 1, 'Sports', 'Sony PSP', 2006),
('Thrillville', 1, 'Simulation,Strategy', 'Sony PSP', 2006),
('The Godfather: The Game', 1, 'Action', 'X360', 2006),
('Rampage: Total Destruction', 4, 'Action', 'Nintendo Wii', 2006),
('College Hoops 2K7', 4, 'Sports', 'X360', 2006),
('Far Cry: Instincts - Predator', 4, 'Action', 'X360', 2006),
('Full Auto', 2, 'Action,Racing / Driving', 'X360', 2006),
('Age of Empires: The Age of Kings', 1, 'Strategy', 'Nintendo DS', 2006),
('Need for Speed: Carbon - Own the City', 1, 'Action,Racing / Driving', 'Nintendo DS', 2006),
('Brothers in Arms: D-Day', 1, 'Action', 'Sony PSP', 2006),
('Family Guy Video Game!', 1, 'Action', 'Sony PSP', 2006),
('Superman Returns', 1, 'Action', 'X360', 2006),
('Over G Fighters', 2, 'Simulation', 'X360', 2006),
('Final Fantasy XI Online', 1, 'Action,Role-Playing (RPG)', 'X360', 2006),
('Mystery Dungeon: Shiren the Wanderer', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2006),
('Phoenix Wright: Ace Attorney - Justice for All', 1, 'Adventure,Simulation', 'Nintendo DS', 2006),
('Justice League Heroes', 1, 'Action', 'Sony PSP', 2006),
('Valhalla Knights', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2006),
('Genji: Days of the Blade', 1, 'Action,Role-Playing (RPG)', 'PlayStation 3', 2006),
('Top Spin 2', 4, 'Sports', 'X360', 2006),
('Field Commander', 2, 'Strategy', 'Sony PSP', 2006),
('Children of Mana', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2006),
('Valkyrie Profile: Lenneth', 1, 'Role-Playing (RPG)', 'Sony PSP', 2006),
('Monster House', 1, 'Action', 'Nintendo DS', 2006),
('Enchanted Arms', 1, 'Role-Playing (RPG)', 'X360', 2006),
('NHL 07', 4, 'Sports', 'Sony PSP', 2006),
('Bust-a-Move Deluxe', 2, 'Strategy', 'Sony PSP', 2006),
('Full Auto 2: Battlelines', 2, 'Action,Racing / Driving', 'PlayStation 3', 2006),
('Blitz: The League', 2, 'Sports', 'X360', 2006),
('Star Trek Legacy', 2, 'Action,Strategy', 'X360', 2006),
('Eragon', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2006),
('Master of Illusion', 1, 'Strategy', 'Nintendo DS', 2006),
('Mega Man ZX', 1, 'Action', 'Nintendo DS', 2006),
('Untold Legends: The Warrior\'s Code', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2006),
('Super Swing Golf', 1, 'Sports', 'Nintendo Wii', 2006),
('X-Men: The Official Game', 1, 'Action', 'X360', 2006),
('Untold Legends: Dark Kingdom', 2, 'Action,Role-Playing (RPG)', 'PlayStation 3', 2006),
('Happy Feet', 2, 'Action', 'Nintendo Wii', 2006),
('Open Season', 1, 'Action', 'Nintendo DS', 2006),
('Dungeon Siege: Throne of Agony', 1, 'Role-Playing (RPG)', 'Sony PSP', 2006),
('LocoRoco', 1, 'Action,Strategy', 'Sony PSP', 2006),
('Dead or Alive: Xtreme 2', 1, 'Racing / Driving,Sports', 'X360', 2006),
('Fuzion Frenzy 2', 4, 'Action,Sports', 'X360', 2006),
('MotoGP \'06', 4, 'Racing / Driving,Simulation,Sports', 'X360', 2006),
('Lumines II', 2, 'Strategy', 'Sony PSP', 2006),
('Major League Baseball 2K6', 1, 'Sports', 'Sony PSP', 2006),
('Star Wars: Lethal Alliance', 1, 'Action', 'Sony PSP', 2006),
('Worms: Open Warfare', 1, 'Action,Strategy', 'Sony PSP', 2006),
('Eragon', 4, 'Action', 'Sony PSP', 2006),
('Metal Slug Anthology', 4, 'Action', 'Nintendo Wii', 2006),
('Open Season', 4, 'Action', 'X360', 2006),
('Tom Clancy\'s Splinter Cell: Double Agent', 2, 'Action', 'Nintendo Wii', 2006),
('Avatar: The Last Airbender', 1, 'Action', 'Sony PSP', 2006),
('Lemmings', 1, 'Strategy', 'Sony PSP', 2006),
('Mega Man Powered Up', 1, 'Action', 'Sony PSP', 2006),
('College Hoops 2K6', 1, 'Sports', 'X360', 2006),
('Dynasty Warriors 5: Empires', 2, 'Action,Role-Playing (RPG),Strategy', 'X360', 2006),
('Magical Starsign', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Resident Evil: Deadly Silence', 1, 'Action', 'Nintendo DS', 2006),
('X-Men: The Official Game', 1, 'Action', 'Nintendo DS', 2006),
('Cabela\'s African Safari', 1, 'Sports', 'X360', 2006),
('Cabela\'s Alaskan Adventures', 1, 'Sports', 'X360', 2006),
('Armored Core 4', 2, 'Action', 'PlayStation 3', 2006),
('Eragon', 2, 'Action', 'X360', 2006),
('LostMagic', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2006),
('Magnetica', 1, 'Action,Strategy', 'Nintendo DS', 2006),
('Def Jam Fight for NY: The Takeover', 1, 'Action', 'Sony PSP', 2006),
('NASCAR 07', 1, 'Racing / Driving,Simulation', 'Sony PSP', 2006),
('The Ant Bully', 1, 'Action', 'Nintendo Wii', 2006),
('Just Cause', 1, 'Action,Racing / Driving', 'X360', 2006),
('Onechanbara: Bikini Samurai Squad', 1, 'Action', 'X360', 2006),
('Phantasy Star Universe', 1, 'Role-Playing (RPG)', 'X360', 2006),
('Project Sylpheed: Arc of Deception', 1, 'Action', 'X360', 2006),
('Winning Eleven: Pro Evolution Soccer 2007', 6, 'Sports', 'X360', 2006),
('Kororinpa: Marble Mania', 2, 'Action,Strategy', 'Nintendo Wii', 2006),
('Digimon World DS', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Justice League Heroes', 1, 'Action', 'Nintendo DS', 2006),
('Innocent Life: A Futuristic Harvest Moon', 1, 'Role-Playing (RPG),Simulation,Strategy', 'Sony PSP', 2006),
('Power Stone Collection', 1, 'Action', 'Sony PSP', 2006),
('EA Replay', 4, 'Action,Role-Playing (RPG),Simulation,Sports,Strategy', 'Sony PSP', 2006),
('Open Season', 4, 'Action', 'Nintendo Wii', 2006),
('Samurai Warriors 2', 4, 'Action', 'X360', 2006),
('Far Cry: Vengeance', 2, 'Action', 'Nintendo Wii', 2006),
('Import Tuner Challenge', 2, 'Racing / Driving', 'X360', 2006),
('Contact', 1, 'Adventure,Role-Playing (RPG)', 'Nintendo DS', 2006),
('Touch Detective', 1, 'Adventure', 'Nintendo DS', 2006),
('FIFA Street 2', 1, 'Sports', 'Sony PSP', 2006),
('007: From Russia with Love', 1, 'Action,Racing / Driving', 'Sony PSP', 2006),
('PaRappa the Rapper', 1, 'Action', 'Sony PSP', 2006),
('Riviera: The Promised Land', 1, 'Role-Playing (RPG)', 'Sony PSP', 2006),
('Samurai Warriors: State of War', 1, 'Action', 'Sony PSP', 2006),
('Viewtiful Joe: Red Hot Rumble', 1, 'Action', 'Sony PSP', 2006),
('Ice Age 2: The Meltdown', 1, 'Action', 'Nintendo Wii', 2006),
('Rumble Roses XX', 4, 'Action,Sports', 'X360', 2006),
('Bionicle Heroes', 1, 'Action', 'Nintendo DS', 2006),
('Deep Labyrinth', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Blade Dancer: Lineage of Light', 1, 'Role-Playing (RPG)', 'Sony PSP', 2006),
('Every Extend Extra', 1, 'Action', 'Sony PSP', 2006),
('Ultimate Ghosts \'N\' Goblins', 1, 'Action', 'Sony PSP', 2006),
('Xiaolin Showdown', 1, 'Action', 'Sony PSP', 2006),
('Bionicle Heroes', 1, 'Action', 'X360', 2006),
('Bullet Witch', 1, 'Action', 'X360', 2006),
('Death Jr. II: Root of Evil', 2, 'Action', 'Sony PSP', 2006),
('Alex Rider: Stormbreaker', 1, 'Action,Adventure', 'Nintendo DS', 2006),
('Cartoon Network Racing', 1, 'Racing / Driving', 'Nintendo DS', 2006),
('Guilty Gear: Dust Strikers', 1, 'Action', 'Nintendo DS', 2006),
('Gunpey DS', 1, 'Strategy', 'Nintendo DS', 2006),
('Lara Croft Tomb Raider: Legend', 1, 'Action,Racing / Driving', 'Nintendo DS', 2006),
('Worms: Open Warfare', 1, 'Action,Strategy', 'Nintendo DS', 2006),
('Mercury Meltdown', 1, 'Strategy', 'Sony PSP', 2006),
('MTX Mototrax', 1, 'Racing / Driving,Sports', 'Sony PSP', 2006),
('Snoopy vs. the Red Baron', 1, 'Action', 'Sony PSP', 2006),
('Super Monkey Ball Adventure', 1, 'Action,Racing / Driving', 'Sony PSP', 2006),
('Ys VI: The Ark of Napishtim', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2006),
('Bomberman Land Touch!', 1, 'Action', 'Nintendo DS', 2006),
('Point Blank DS', 1, 'Action', 'Nintendo DS', 2006),
('Scurge: Hive', 1, 'Action', 'Nintendo DS', 2006),
('Star Trek: Tactical Assault', 1, 'Action,Strategy', 'Nintendo DS', 2006),
('Tao\'s Adventure: Curse of the Demon Seal', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2006),
('Ford Bold Moves Street Racing', 1, 'Racing / Driving', 'Sony PSP', 2006),
('Gitaroo Man Lives!', 1, 'Simulation', 'Sony PSP', 2006),
('Gradius Collection', 1, 'Action', 'Sony PSP', 2006),
('The Legend of Heroes II: Prophecy of the Moonli...', 1, 'Role-Playing (RPG)', 'Sony PSP', 2006),
('Pac-Man World Rally', 1, 'Action,Racing / Driving', 'Sony PSP', 2006),
('Bomberman: Act Zero', 1, 'Action', 'X360', 2006),
('Earth Defense Force 2017', 2, 'Action', 'X360', 2006),
('WarTech: Senko no Ronde', 2, 'Action', 'X360', 2006),
('MechAssault: Phantom War', 1, 'Action', 'Nintendo DS', 2006),
('Astonishia Story', 1, 'Role-Playing (RPG),Strategy', 'Sony PSP', 2006),
('B-Boy', 1, 'Action', 'Sony PSP', 2006),
('BattleZone', 1, 'Action', 'Sony PSP', 2006),
('Bounty Hounds', 1, 'Action,Strategy', 'Sony PSP', 2006),
('Bubble Bobble Evolution', 1, 'Action', 'Sony PSP', 2006),
('MotoGP', 1, 'Racing / Driving,Sports', 'Sony PSP', 2006),
('OutRun 2006: Coast 2 Coast', 1, 'Racing / Driving', 'Sony PSP', 2006),
('Warhammer: Battle for Atluma', 1, 'Strategy', 'Sony PSP', 2006),
('SBK: Snowboard Kids', 1, 'Action,Sports', 'Nintendo DS', 2006),
('Tenchu: Dark Secret', 1, 'Action', 'Nintendo DS', 2006),
('Dungeon Maker: Hunting Ground', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2006),
('Metal Gear Solid: Digital Graphic Novel', 1, 'Adventure', 'Sony PSP', 2006),
('Star Trek: Tactical Assault', 1, 'Action,Strategy', 'Sony PSP', 2006),
('Micro Machines V4', 2, 'Action,Racing / Driving', 'Sony PSP', 2006),
('Platypus', 2, 'Action', 'Sony PSP', 2006),
('Custom Robo Arena', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2006),
('Gurumin: A Monstrous Adventure', 1, 'Action', 'Sony PSP', 2006),
('Spider-Man 3', 1, 'Action', 'Sony PSP', 2006),
('Wii Fit', 1, 'Educational,Sports', 'Nintendo Wii', 2007),
('Halo 3', 4, 'Action', 'X360', 2007),
('Call of Duty 4: Modern Warfare', 4, 'Action', 'X360', 2007),
('Super Mario Galaxy', 2, 'Action', 'Nintendo Wii', 2007),
('Mario Party DS', 1, 'Action,Strategy', 'Nintendo DS', 2007),
('Mario Party 8', 4, 'Action,Strategy', 'Nintendo Wii', 2007),
('Guitar Hero III: Legends of Rock', 2, 'Action,Simulation', 'X360', 2007),
('Link\'s Crossbow Training', 1, 'Action', 'Nintendo Wii', 2007),
('Guitar Hero III: Legends of Rock', 2, 'Action,Simulation', 'Nintendo Wii', 2007),
('Assassin\'s Creed', 1, 'Action', 'X360', 2007),
('LEGO Star Wars: The Complete Saga', 2, 'Action', 'Nintendo Wii', 2007),
('Call of Duty 4: Modern Warfare', 4, 'Action', 'PlayStation 3', 2007),
('Mario & Sonic at the Olympic Games', 4, 'Action,Sports', 'Nintendo Wii', 2007),
('LEGO Star Wars: The Complete Saga', 1, 'Action,Racing / Driving', 'Nintendo DS', 2007),
('Forza Motorsport 2', 2, 'Racing / Driving', 'X360', 2007),
('Madden NFL 08', 4, 'Sports', 'X360', 2007),
('Guitar Hero II', 2, 'Action,Simulation', 'X360', 2007),
('Rock Band', 4, 'Action,Simulation', 'X360', 2007),
('The Legend of Zelda: Phantom Hourglass', 1, 'Action', 'Nintendo DS', 2007),
('Pokmon Mystery Dungeon: Explorers of Darkness', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2007),
('Pokmon Mystery Dungeon: Explorers of Time', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2007),
('Assassin\'s Creed', 1, 'Action', 'PlayStation 3', 2007),
('Uncharted: Drake\'s Fortune', 1, 'Action', 'PlayStation 3', 2007),
('Mass Effect', 1, 'Action,Role-Playing (RPG)', 'X360', 2007),
('Cooking Mama 2: Dinner with Friends', 1, 'Simulation', 'Nintendo DS', 2007),
('BioShock', 1, 'Action', 'X360', 2007),
('Super Paper Mario', 1, 'Action,Role-Playing (RPG)', 'Nintendo Wii', 2007),
('Game Party', 4, 'Action', 'Nintendo Wii', 2007),
('Ratchet & Clank: Size Matters', 1, 'Action', 'Sony PSP', 2007),
('Dance Dance Revolution Hottest Party', 4, 'Action', 'Nintendo Wii', 2007),
('Cooking Mama: Cook Off', 2, 'Simulation', 'Nintendo Wii', 2007),
('Gran Turismo 5: Prologue', 2, 'Racing / Driving,Simulation', 'PlayStation 3', 2007),
('Professor Layton and the Curious Village', 1, 'Adventure,Educational,Strategy', 'Nintendo DS', 2007),
('Resident Evil 4', 1, 'Action', 'Nintendo Wii', 2007),
('The Elder Scrolls IV: Oblivion', 1, 'Action,Role-Playing (RPG)', 'PlayStation 3', 2007),
('Transformers: Autobots', 1, 'Action,Racing / Driving', 'Nintendo DS', 2007),
('Transformers: Decepticons', 1, 'Action,Racing / Driving', 'Nintendo DS', 2007),
('Diddy Kong Racing DS', 1, 'Racing / Driving,Sports', 'Nintendo DS', 2007),
('Big Brain Academy: Wii Degree', 8, 'Action', 'Nintendo Wii', 2007),
('Need for Speed: ProStreet', 2, 'Racing / Driving', 'X360', 2007),
('Deal or No Deal', 1, 'Strategy', 'Nintendo DS', 2007),
('LEGO Star Wars: The Complete Saga', 2, 'Action', 'X360', 2007),
('Sonic and the Secret Rings', 4, 'Action', 'Nintendo Wii', 2007),
('The Orange Box', 1, 'Action', 'X360', 2007),
('Crackdown', 1, 'Action,Racing / Driving,Role-Playing (RPG)', 'X360', 2007),
('Rock Band', 4, 'Action,Simulation', 'PlayStation 3', 2007),
('Tiger Woods PGA Tour 08', 4, 'Sports', 'Nintendo Wii', 2007),
('WWE Smackdown vs. Raw 2008', 4, 'Sports', 'X360', 2007),
('Madden NFL 08', 4, 'Sports', 'PlayStation 3', 2007),
('Call of Duty 4: Modern Warfare', 1, 'Action', 'Nintendo DS', 2007),
('MySims', 1, 'Simulation,Strategy', 'Nintendo Wii', 2007),
('Mario Strikers Charged', 4, 'Action,Sports', 'Nintendo Wii', 2007),
('Star Wars Battlefront: Renegade Squadron', 1, 'Action', 'Sony PSP', 2007),
('Flash Focus: Vision Training in Minutes a Day', 1, 'Action', 'Nintendo DS', 2007),
('Metroid Prime 3: Corruption', 1, 'Action', 'Nintendo Wii', 2007),
('Tom Clancy\'s Ghost Recon: Advanced Warfighter 2...', 1, 'Action', 'X360', 2007),
('Madden NFL 08', 4, 'Sports', 'Nintendo Wii', 2007),
('Ratchet & Clank Future: Tools of Destruction', 1, 'Action', 'PlayStation 3', 2007),
('LEGO Star Wars: The Complete Saga', 2, 'Action', 'PlayStation 3', 2007),
('Rayman Raving Rabbids 2', 4, 'Action', 'Nintendo Wii', 2007),
('NBA 2K8 ', 1, 'Sports', 'X360', 2007),
('Namco Museum DS', 1, 'Action', 'Nintendo DS', 2007),
('Need for Speed: ProStreet', 2, 'Racing / Driving', 'PlayStation 3', 2007),
('Blazing Angels: Squadrons of WWII', 2, 'Action', 'Nintendo Wii', 2007),
('Drawn to Life', 1, 'Action', 'Nintendo DS', 2007),
('EA Playground', 4, 'Action,Racing / Driving,Sports', 'Nintendo Wii', 2007),
('Major League Baseball 2K7', 2, 'Sports', 'X360', 2007),
('Resident Evil: The Umbrella Chronicles', 2, 'Action', 'Nintendo Wii', 2007),
('NCAA Football 08', 2, 'Sports', 'X360', 2007),
('Spectrobes', 1, 'Action,Strategy', 'Nintendo DS', 2007),
('The Sims 2: Castaway', 1, 'Simulation', 'Nintendo DS', 2007),
('WWE Smackdown vs. Raw 2008', 6, 'Sports', 'PlayStation 3', 2007),
('Madden NFL 08', 1, 'Sports', 'Sony PSP', 2007),
('NBA Live 08', 4, 'Sports', 'PlayStation 3', 2007),
('The Simpsons Game', 1, 'Action', 'Nintendo DS', 2007),
('Ace Combat 6: Fires of Liberation', 1, 'Action,Simulation', 'X360', 2007),
('Heavenly Sword', 1, 'Action', 'PlayStation 3', 2007),
('Ninja Gaiden Sigma', 1, 'Action', 'PlayStation 3', 2007),
('Ben 10: Protector of the Earth', 1, 'Action', 'Nintendo Wii', 2007),
('The Simpsons Game', 2, 'Action', 'X360', 2007),
('CrossworDS', 1, 'Educational,Strategy', 'Nintendo DS', 2007),
('Sonic Rush Adventure', 1, 'Action,Sports', 'Nintendo DS', 2007),
('Tiger Woods PGA Tour 08', 4, 'Sports', 'X360', 2007),
('Tony Hawk\'s Proving Ground', 2, 'Sports', 'X360', 2007),
('Call of Duty: Roads to Victory', 1, 'Action', 'Sony PSP', 2007),
('Transformers: The Game', 1, 'Action', 'X360', 2007),
('NBA 2K8', 7, 'Sports', 'PlayStation 3', 2007),
('Medal of Honor: Heroes 2', 1, 'Action', 'Sony PSP', 2007),
('Spider-Man 3', 1, 'Action', 'X360', 2007),
('Tom Clancy\'s Rainbow Six: Vegas', 2, 'Action', 'PlayStation 3', 2007),
('Need for Speed: ProStreet', 2, 'Racing / Driving', 'Nintendo Wii', 2007),
('NBA LIVE 08 ', 1, 'Sports', 'X360', 2007),
('Dance Dance Revolution Universe 2', 4, 'Action', 'X360', 2007),
('MX vs. ATV Untamed', 2, 'Racing / Driving', 'X360', 2007),
('Final Fantasy IV', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2007),
('NBA Street Homecourt', 4, 'Sports', 'X360', 2007),
('The Simpsons Game', 2, 'Action', 'Nintendo Wii', 2007),
('Winter Sports: The Ultimate Challenge', 1, 'Racing / Driving,Sports', 'Nintendo Wii', 2007),
('WWE Smackdown vs. Raw 2008', 4, 'Sports', 'Sony PSP', 2007),
('Tiger Woods PGA Tour 07', 4, 'Sports', 'Nintendo Wii', 2007),
('Crash of the Titans', 1, 'Action', 'Nintendo DS', 2007),
('Sonic Rivals 2', 1, 'Action', 'Sony PSP', 2007),
('Boogie', 2, 'Action', 'Nintendo Wii', 2007),
('Medal of Honor: Airborne', 2, 'Action', 'X360', 2007),
('The Sims 2: Castaway', 1, 'Simulation', 'Nintendo Wii', 2007),
('Spider-Man 3', 1, 'Action', 'Nintendo Wii', 2007),
('Lost Odyssey', 1, 'Role-Playing (RPG)', 'X360', 2007),
('Bee Movie Game', 1, 'Adventure', 'Nintendo DS', 2007),
('Spider-Man 3', 1, 'Action', 'Nintendo DS', 2007),
('Final Fantasy Tactics', 1, 'Role-Playing (RPG),Strategy', 'Sony PSP', 2007),
('Endless Ocean', 1, 'Simulation', 'Nintendo Wii', 2007),
('SingStar', 6, 'Simulation', 'PlayStation 3', 2007),
('Ratatouille', 1, 'Action', 'Nintendo Wii', 2007),
('The Sims 2: Pets', 1, 'Simulation', 'Nintendo Wii', 2007),
('Two Worlds', 1, 'Action,Role-Playing (RPG)', 'X360', 2007),
('Crash of the Titans', 2, 'Action', 'Nintendo Wii', 2007),
('Sonic the Hedgehog', 2, 'Action', 'X360', 2007),
('Mega Man Star Force: Dragon', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2007),
('Sonic the Hedgehog', 2, 'Action', 'PlayStation 3', 2007),
('Harry Potter and the Order of the Phoenix', 1, 'Action', 'Nintendo Wii', 2007),
('Nicktoons: Attack of the Toybots', 1, 'Action', 'Nintendo Wii', 2007),
('WWE Smackdown vs. Raw 2008', 4, 'Sports', 'Nintendo Wii', 2007),
('The Simpsons Game', 2, 'Action', 'PlayStation 3', 2007),
('DiRT', 1, 'Racing / Driving,Simulation,Sports', 'X360', 2007),
('Kane & Lynch: Dead Men', 2, 'Action', 'X360', 2007),
('Jam Sessions', 1, 'Educational,Simulation', 'Nintendo DS', 2007),
('Monster Hunter Freedom 2', 1, 'Action,Strategy', 'Sony PSP', 2007),
('Shadowrun', 1, 'Action', 'X360', 2007),
('Thrillville: Off the Rails', 4, 'Simulation,Strategy', 'Nintendo Wii', 2007),
('Tony Hawk\'s Proving Ground', 2, 'Sports', 'PlayStation 3', 2007),
('My Word Coach', 1, 'Educational', 'Nintendo DS', 2007),
('The World Ends With You', 1, 'Action,Adventure,Role-Playing (RPG)', 'Nintendo DS', 2007),
('The BIGS', 4, 'Action,Simulation,Sports', 'Nintendo Wii', 2007),
('NCAA Football 08', 2, 'Sports', 'PlayStation 3', 2007),
('Final Fantasy Tactics A2: Grimoire of the Rift', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2007),
('Beowulf: The Game', 1, 'Action', 'X360', 2007),
('The Darkness', 1, 'Action', 'X360', 2007),
('Tom Clancy\'s Ghost Recon: Advanced Warfighter 2...', 4, 'Action', 'PlayStation 3', 2007),
('Final Fantasy', 1, 'Role-Playing (RPG)', 'Sony PSP', 2007),
('Lair', 1, 'Action', 'PlayStation 3', 2007),
('Transformers: The Game', 1, 'Action', 'Nintendo Wii', 2007),
('Command & Conquer 3: Tiberium Wars', 1, 'Strategy', 'X360', 2007),
('Overlord', 1, 'Action,Strategy', 'X360', 2007),
('Diner Dash', 1, 'Action', 'Nintendo DS', 2007),
('Medal of Honor: Heroes 2', 1, 'Action', 'Nintendo Wii', 2007),
('MX vs. ATV Untamed', 2, 'Racing / Driving', 'PlayStation 3', 2007),
('Time Crisis 4', 2, 'Action', 'PlayStation 3', 2007),
('Dragon Ball Z: Budokai Tenkaichi 3', 2, 'Action', 'Nintendo Wii', 2007),
('Final Fantasy XII: Revenant Wings', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2007),
('SOCOM: U.S. Navy SEALs - Tactical Strike', 1, 'Action,Strategy', 'Sony PSP', 2007),
('Unreal Tournament III', 1, 'Action', 'PlayStation 3', 2007),
('Bee Movie Game', 2, 'Action', 'Nintendo Wii', 2007),
('Def Jam: Icon', 2, 'Action', 'X360', 2007),
('Transformers: The Game', 1, 'Action', 'PlayStation 3', 2007),
('TimeShift', 1, 'Action', 'X360', 2007),
('SSX Blur', 4, 'Sports', 'Nintendo Wii', 2007),
('Bleach: The Blade of Fate', 1, 'Action', 'Nintendo DS', 2007),
('EA Playground', 1, 'Racing / Driving,Sports', 'Nintendo DS', 2007),
('Final Fantasy II', 1, 'Role-Playing (RPG)', 'Sony PSP', 2007),
('The Eye of Judgment', 2, 'Strategy', 'PlayStation 3', 2007),
('MLB 07: The Show', 2, 'Sports', 'PlayStation 3', 2007),
('Virtua Fighter 5', 2, 'Action', 'PlayStation 3', 2007),
('NiGHTS: Journey of Dreams', 2, 'Action', 'Nintendo Wii', 2007),
('Puzzle Quest: Challenge of the Warlords', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2007),
('NBA Live 08', 1, 'Sports', 'Sony PSP', 2007),
('Kane & Lynch: Dead Men', 2, 'Action', 'PlayStation 3', 2007),
('Crash of the Titans', 2, 'Action', 'X360', 2007),
('Harry Potter and the Order of the Phoenix', 1, 'Action', 'Nintendo DS', 2007),
('SimCity DS', 1, 'Simulation', 'Nintendo DS', 2007),
('Wario: Master of Disguise', 1, 'Action', 'Nintendo DS', 2007),
('No More Heroes', 1, 'Action,Racing / Driving', 'Nintendo Wii', 2007),
('BlackSite: Area 51', 1, 'Action', 'X360', 2007),
('Shrek the Third', 2, 'Action', 'X360', 2007),
('Shrek the Third', 1, 'Adventure', 'Nintendo DS', 2007),
('Surf\'s Up', 1, 'Racing / Driving,Sports', 'Nintendo DS', 2007),
('MLB 07: The Show', 1, 'Sports', 'Sony PSP', 2007),
('TMNT', 1, 'Action', 'X360', 2007),
('Spider-Man: Friend or Foe', 2, 'Action', 'X360', 2007),
('Contra 4', 1, 'Action', 'Nintendo DS', 2007),
('Phoenix Wright: Ace Attorney - Trials and Tribu...', 1, 'Adventure,Simulation', 'Nintendo DS', 2007),
('Disney Pirates of the Caribbean: At World\'s End', 1, 'Action', 'Nintendo DS', 2007),
('Dragon Ball Z: Shin Budokai - Another Road', 1, 'Action', 'Sony PSP', 2007),
('Spider-Man 3', 1, 'Action', 'PlayStation 3', 2007),
('The Golden Compass', 1, 'Action', 'X360', 2007),
('Stuntman: Ignition', 4, 'Action,Racing / Driving', 'X360', 2007),
('Chicken Shoot', 2, 'Action', 'Nintendo Wii', 2007),
('Shrek the Third', 2, 'Action', 'Nintendo Wii', 2007),
('DK: Jungle Climber', 1, 'Action,Strategy', 'Nintendo DS', 2007),
('Dragon Quest IV: Chapters of the Chosen', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2007),
('300: March to Glory', 1, 'Action', 'Sony PSP', 2007),
('Fire Emblem: Radiant Dawn', 1, 'Role-Playing (RPG),Strategy', 'Nintendo Wii', 2007),
('The Golden Compass', 1, 'Action', 'Nintendo Wii', 2007),
('Manhunt 2', 1, 'Action', 'Nintendo Wii', 2007),
('NASCAR 08', 1, 'Racing / Driving,Sports', 'X360', 2007),
('Virtua Tennis 3', 4, 'Sports', 'PlayStation 3', 2007),
('All-Pro Football 2K8', 4, 'Sports', 'X360', 2007),
('Major League Baseball 2K7', 2, 'Sports', 'PlayStation 3', 2007),
('The Warriors', 1, 'Action', 'Sony PSP', 2007),
('Ghost Rider', 4, 'Action', 'Sony PSP', 2007),
('Tony Hawk\'s Proving Ground', 2, 'Sports', 'Nintendo Wii', 2007),
('Juiced 2: Hot Import Nights', 2, 'Racing / Driving', 'X360', 2007),
('Juiced 2: Hot Import Nights', 1, 'Racing / Driving', 'Nintendo DS', 2007),
('The Simpsons Game', 1, 'Action', 'Sony PSP', 2007),
('Syphon Filter: Logan\'s Shadow', 1, 'Action,Strategy', 'Sony PSP', 2007),
('Tiger Woods PGA Tour 08', 4, 'Sports', 'PlayStation 3', 2007),
('Ratatouille', 4, 'Action', 'X360', 2007),
('Trauma Center: New Blood', 2, 'Action,Simulation', 'Nintendo Wii', 2007),
('Hotel Dusk: Room 215', 1, 'Adventure', 'Nintendo DS', 2007),
('Mega Man ZX Advent', 1, 'Action', 'Nintendo DS', 2007),
('Silent Hill: 0rigins', 1, 'Action', 'Sony PSP', 2007),
('Harry Potter and the Order of the Phoenix', 1, 'Action', 'X360', 2007),
('NHL 08 ', 1, 'Sports', 'X360', 2007),
('Castlevania: The Dracula X Chronicles', 2, 'Action', 'Sony PSP', 2007),
('Tony Hawk\'s Proving Ground', 1, 'Sports', 'Nintendo DS', 2007),
('Jeanne d\'Arc', 1, 'Role-Playing (RPG),Strategy', 'Sony PSP', 2007),
('BWii: Battalion Wars 2', 1, 'Action,Simulation,Strategy', 'Nintendo Wii', 2007),
('Battlestations: Midway', 1, 'Action,Strategy', 'X360', 2007),
('Dragon Ball Z: Harukanaru Densetsu', 1, 'Strategy', 'Nintendo DS', 2007),
('Touch the Dead', 1, 'Action', 'Nintendo DS', 2007),
('The Darkness', 1, 'Action', 'PlayStation 3', 2007),
('Donkey Kong Barrel Blast', 4, 'Racing / Driving', 'Nintendo Wii', 2007),
('The BIGS', 4, 'Action,Simulation,Sports', 'X360', 2007),
('Armored Core 4', 2, 'Action', 'X360', 2007),
('Etrian Odyssey', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2007),
('Ben 10: Protector of the Earth', 1, 'Action', 'Sony PSP', 2007),
('Tom Clancy\'s Splinter Cell: Double Agent', 1, 'Action,Strategy', 'PlayStation 3', 2007),
('Looney Tunes: Acme Arsenal', 1, 'Action', 'Nintendo Wii', 2007),
('Zack & Wiki: Quest for Barbaros\' Treasure', 1, 'Adventure', 'Nintendo Wii', 2007),
('Monster Jam', 4, 'Sports', 'X360', 2007),
('Virtua Fighter 5', 2, 'Action', 'X360', 2007),
('Lunar Knights', 1, 'Action', 'Nintendo DS', 2007),
('Enchanted Arms', 1, 'Role-Playing (RPG)', 'PlayStation 3', 2007),
('F.E.A.R.: First Encounter Assault Recon', 1, 'Action', 'PlayStation 3', 2007),
('Folklore', 1, 'Action,Role-Playing (RPG)', 'PlayStation 3', 2007),
('Juiced 2: Hot Import Nights', 1, 'Racing / Driving', 'PlayStation 3', 2007),
('The Elder Scrolls IV: Shivering Isles', 1, 'Action,Role-Playing (RPG)', 'X360', 2007),
('NHL 08', 7, 'Sports', 'PlayStation 3', 2007),
('NCAA 07 March Madness', 4, 'Sports', 'X360', 2007),
('Rayman Raving Rabbids', 4, 'Action', 'X360', 2007),
('Viva Pi$?ata: Party Animals', 4, 'Racing / Driving', 'X360', 2007),
('Warriors Orochi', 2, 'Action,Role-Playing (RPG)', 'X360', 2007),
('Luminous Arc', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2007),
('Picross DS', 1, 'Strategy', 'Nintendo DS', 2007),
('Harry Potter and the Order of the Phoenix', 1, 'Action', 'PlayStation 3', 2007),
('College Hoops 2K7', 6, 'Sports', 'PlayStation 3', 2007),
('The BIGS', 4, 'Action,Simulation,Sports', 'PlayStation 3', 2007),
('Stuntman: Ignition', 4, 'Action,Racing / Driving', 'PlayStation 3', 2007),
('Mortal Kombat: Armageddon', 4, 'Action,Racing / Driving', 'Nintendo Wii', 2007),
('Def Jam: Icon', 2, 'Action', 'PlayStation 3', 2007),
('Soulcalibur Legends', 2, 'Action', 'Nintendo Wii', 2007),
('Surf\'s Up', 2, 'Sports', 'Nintendo Wii', 2007),
('Planet Puzzle League', 1, 'Strategy', 'Nintendo DS', 2007),
('DiRT', 1, 'Racing / Driving,Simulation,Sports', 'PlayStation 3', 2007),
('TMNT', 1, 'Action', 'Nintendo Wii', 2007),
('Soldier of Fortune: Payback', 1, 'Action', 'X360', 2007),
('Dynasty Warriors: Gundam', 2, 'Action', 'PlayStation 3', 2007),
('Disney Pirates of the Caribbean: At World\'s End', 2, 'Action', 'PlayStation 3', 2007),
('Bee Movie Game', 2, 'Action', 'X360', 2007),
('Dynasty Warriors: Gundam', 2, 'Action', 'X360', 2007),
('Golden Axe', 2, 'Action', 'X360', 2007),
('Dementium: The Ward', 1, 'Action', 'Nintendo DS', 2007),
('Rondo of Swords', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2007),
('Disgaea: Afternoon of Darkness', 1, 'Role-Playing (RPG),Strategy', 'Sony PSP', 2007),
('NASCAR 08', 1, 'Racing / Driving,Sports', 'PlayStation 3', 2007),
('Dragon Quest Swords: The Masked Queen and the T...', 1, 'Action', 'Nintendo Wii', 2007),
('Call of Juarez', 1, 'Action', 'X360', 2007),
('College Hoops 2K8', 1, 'Sports', 'X360', 2007),
('Eternal Sonata', 1, 'Role-Playing (RPG)', 'X360', 2007),
('Kingdom Under Fire: Circle of Doom', 1, 'Action,Role-Playing (RPG)', 'X360', 2007),
('Vampire Rain', 1, 'Action', 'X360', 2007),
('All-Pro Football 2K8', 6, 'Sports', 'PlayStation 3', 2007),
('Mercury Meltdown', 2, 'Strategy', 'Nintendo Wii', 2007),
('Conan', 1, 'Action,Adventure', 'PlayStation 3', 2007),
('Godzilla: Unleashed', 1, 'Action', 'Nintendo Wii', 2007),
('NBA Live 08', 1, 'Sports', 'Nintendo Wii', 2007),
('Conan', 1, 'Action,Adventure', 'X360', 2007),
('Spider-Man: Friend or Foe', 2, 'Action', 'Nintendo Wii', 2007),
('College Hoops 2K8', 7, 'Sports', 'PlayStation 3', 2007),
('NBA 08', 4, 'Sports', 'PlayStation 3', 2007),
('Thrillville: Off the Rails', 4, 'Simulation,Strategy', 'X360', 2007),
('Geometry Wars: Galaxies', 1, 'Action', 'Nintendo DS', 2007),
('Rayman Raving Rabbids', 1, 'Action', 'Nintendo DS', 2007),
('WordJong', 1, 'Strategy', 'Nintendo DS', 2007),
('Warhammer 40,000: Squad Command', 1, 'Strategy', 'Sony PSP', 2007),
('Beowulf: The Game', 1, 'Action', 'PlayStation 3', 2007),
('The Golden Compass', 1, 'Action', 'PlayStation 3', 2007),
('Scarface: The World is Yours', 1, 'Action,Racing / Driving', 'Nintendo Wii', 2007),
('Hot Wheels: Beat That!', 1, 'Action,Racing / Driving', 'X360', 2007),
('NHL 2K8 ', 1, 'Sports', 'X360', 2007),
('NBA Street Homecourt', 4, 'Sports', 'PlayStation 3', 2007),
('Geometry Wars: Galaxies', 2, 'Action', 'Nintendo Wii', 2007),
('Final Fantasy: Crystal Chronicles - Echoes of Time', 1, 'Action', 'Nintendo DS', 2007),
('Godzilla Unleashed: Double Smash', 1, 'Action', 'Nintendo DS', 2007),
('MX vs. ATV Untamed', 1, 'Racing / Driving', 'Nintendo DS', 2007),
('WWE SmackDown vs. Raw 2008', 1, 'Sports', 'Nintendo DS', 2007),
('The BIGS', 1, 'Action,Simulation,Sports', 'Sony PSP', 2007),
('Brave Story: New Traveler', 1, 'Role-Playing (RPG)', 'Sony PSP', 2007),
('WipEout Pulse', 1, 'Action,Racing / Driving', 'Sony PSP', 2007),
('TimeShift', 1, 'Action', 'PlayStation 3', 2007),
('Star Trek: Conquest', 1, 'Action,Strategy', 'Nintendo Wii', 2007),
('Beautiful Katamari', 1, 'Action', 'X360', 2007),
('Hour of Victory', 1, 'Action', 'X360', 2007),
('Fantastic Four: Rise of the Silver Surfer', 4, 'Action', 'PlayStation 3', 2007),
('SEGA Rally Revo', 2, 'Racing / Driving,Simulation', 'X360', 2007),
('7 Wonders of the Ancient World', 1, 'Strategy', 'Nintendo DS', 2007),
('Draglade', 1, 'Action', 'Nintendo DS', 2007),
('Final Fantasy Fables: Chocobo Tales', 1, 'Action', 'Nintendo DS', 2007),
('Marvel Trading Card Game', 1, 'Strategy', 'Nintendo DS', 2007),
('Crazy Taxi: Fare Wars', 1, 'Action,Racing / Driving', 'Sony PSP', 2007),
('The Golden Compass', 1, 'Action', 'Sony PSP', 2007),
('Harry Potter and the Order of the Phoenix', 1, 'Action', 'Sony PSP', 2007),
('Bladestorm: The Hundred Years\' War', 1, 'Action,Role-Playing (RPG),Strategy', 'PlayStation 3', 2007),
('Surf\'s Up', 4, 'Sports', 'X360', 2007),
('Blazing Angels 2: Secret Missions of WWII', 2, 'Action', 'X360', 2007),
('InuYasha: Secret of the Divine Jewel', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2007),
('The Settlers', 1, 'Strategy', 'Nintendo DS', 2007),
('Shrek the Third', 1, 'Action', 'Sony PSP', 2007),
('Ratatouille', 1, 'Action', 'PlayStation 3', 2007),
('Soldier of Fortune: Payback', 1, 'Action', 'PlayStation 3', 2007),
('Heatseeker', 1, 'Action', 'Nintendo Wii', 2007),
('NHL 2K8', 7, 'Sports', 'PlayStation 3', 2007),
('NCAA March Madness 08', 4, 'Sports', 'PlayStation 3', 2007),
('Fantastic Four: Rise of the Silver Surfer', 4, 'Action', 'X360', 2007),
('Monster Madness: Battle for Suburbia', 4, 'Action', 'X360', 2007),
('Pro Evolution Soccer 2008', 4, 'Sports', 'X360', 2007),
('Blazing Angels 2: Secret Missions of WWII', 2, 'Action', 'PlayStation 3', 2007),
('Cake Mania', 1, 'Action', 'Nintendo DS', 2007),
('River King: Mystic Valley', 1, 'Adventure,Simulation,Sports', 'Nintendo DS', 2007),
('Touch Detective 2 1/2', 1, 'Adventure', 'Nintendo DS', 2007),
('7 Wonders of the Ancient World', 1, 'Strategy', 'Sony PSP', 2007),
('Brooktown High', 1, 'Simulation', 'Sony PSP', 2007),
('Crush', 1, 'Action', 'Sony PSP', 2007),
('Jackass: The Game', 1, 'Action', 'Sony PSP', 2007),
('The Sims 2: Castaway', 1, 'Simulation', 'Sony PSP', 2007),
('Test Drive Unlimited', 1, 'Racing / Driving', 'Sony PSP', 2007),
('Thrillville: Off the Rails', 1, 'Simulation,Strategy', 'Sony PSP', 2007),
('Victorious Boxers: Revolution', 1, 'Action,Simulation,Sports', 'Nintendo Wii', 2007),
('Bladestorm: The Hundred Years\' War', 1, 'Action,Role-Playing (RPG),Strategy', 'X360', 2007),
('Looney Tunes: Acme Arsenal', 4, 'Action', 'X360', 2007),
('SEGA Rally Revo', 2, 'Racing / Driving,Simulation', 'PlayStation 3', 2007),
('Death Jr. and the Science Fair of Doom', 1, 'Action', 'Nintendo DS', 2007),
('Indianapolis 500 Legends', 1, 'Racing / Driving', 'Nintendo DS', 2007),
('Worms: Open Warfare 2', 1, 'Action,Strategy', 'Nintendo DS', 2007),
('Alien Syndrome', 1, 'Action', 'Sony PSP', 2007),
('BlackSite: Area 51', 1, 'Action', 'PlayStation 3', 2007),
('Code Lyoko: Quest for Infinity', 1, 'Action', 'Nintendo Wii', 2007),
('Super Swing Golf Season 2', 1, 'Sports', 'Nintendo Wii', 2007),
('FlatOut: Ultimate Carnage', 1, 'Racing / Driving', 'X360', 2007),
('Zoids Assault', 1, 'Role-Playing (RPG),Strategy', 'X360', 2007),
('Alien Syndrome', 4, 'Action', 'Nintendo Wii', 2007),
('Tetris Evolution', 4, 'Strategy', 'X360', 2007),
('Heroes of Mana', 1, 'Strategy', 'Nintendo DS', 2007),
('Myst', 1, 'Adventure', 'Nintendo DS', 2007),
('Coded Arms: Contagion', 1, 'Action', 'Sony PSP', 2007),
('King of Clubs', 1, 'Sports', 'Nintendo Wii', 2007),
('F.E.A.R. Files', 1, 'Action', 'X360', 2007),
('Ontamarama', 1, 'Action', 'Nintendo DS', 2007),
('Retro Game Challenge', 1, 'Action,Racing / Driving,Role-Playing (RPG)', 'Nintendo DS', 2007),
('Ultimate Mortal Kombat 3', 1, 'Action', 'Nintendo DS', 2007),
('Warhammer 40,000: Squad Command', 1, 'Strategy', 'Nintendo DS', 2007),
('Juiced 2: Hot Import Nights', 1, 'Racing / Driving', 'Sony PSP', 2007),
('Pursuit Force: Extreme Justice', 1, 'Action,Racing / Driving', 'Sony PSP', 2007),
('Medal of Honor: Vanguard', 1, 'Action', 'Nintendo Wii', 2007),
('World Series of Poker 2008: Battle for the Brac...', 1, 'Simulation', 'X360', 2007),
('Pro Evolution Soccer 2008', 7, 'Sports', 'PlayStation 3', 2007),
('Worms: Open Warfare 2', 4, 'Action,Strategy', 'Sony PSP', 2007),
('Surf\'s Up', 4, 'Sports', 'PlayStation 3', 2007),
('Fantastic Four: Rise of the Silver Surfer', 4, 'Action', 'Nintendo Wii', 2007),
('Brothers in Arms DS', 1, 'Action', 'Nintendo DS', 2007),
('Bubble Bobble Double Shot', 1, 'Action', 'Nintendo DS', 2007),
('Fantastic Four: Rise of the Silver Surfer', 1, 'Action', 'Nintendo DS', 2007),
('Zendoku', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2007),
('Heatseeker', 1, 'Action', 'Sony PSP', 2007),
('Manhunt 2', 1, 'Action', 'Sony PSP', 2007);
INSERT INTO `video_games` (`Title`, `MaxPlayers`, `Genres`, `Release Console`, `ReleaseYear`) VALUES
('SWAT: Target Liberty', 1, 'Action,Strategy', 'Sony PSP', 2007),
('Anubis II', 1, 'Action', 'Nintendo Wii', 2007),
('Barnyard', 1, 'Action,Adventure', 'Nintendo Wii', 2007),
('Escape from Bug Island', 1, 'Action', 'Nintendo Wii', 2007),
('Octomania', 1, 'Action,Strategy', 'Nintendo Wii', 2007),
('Cabela\'s Big Game Hunter', 1, 'Simulation,Sports', 'X360', 2007),
('UEFA Champions League 2006-2007', 4, 'Sports', 'X360', 2007),
('Aliens Vs Predator: Requiem', 2, 'Action', 'Sony PSP', 2007),
('NBA 08', 2, 'Sports', 'Sony PSP', 2007),
('Guilty Gear XX ? Core', 2, 'Action', 'Nintendo Wii', 2007),
('Arkanoid DS', 1, 'Strategy', 'Nintendo DS', 2007),
('Code Lyoko', 1, 'Action,Adventure', 'Nintendo DS', 2007),
('Dynasty Warriors DS: Fighter\'s Battle', 1, 'Action,Strategy', 'Nintendo DS', 2007),
('Orcs & Elves', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2007),
('Prism: Light the Way', 1, 'Action,Strategy', 'Nintendo DS', 2007),
('Dead Head Fred', 1, 'Action', 'Sony PSP', 2007),
('Hot Pixel', 1, 'Action', 'Sony PSP', 2007),
('The Legend of Heroes III: Song of the Ocean', 1, 'Role-Playing (RPG)', 'Sony PSP', 2007),
('SEGA Rally Revo', 1, 'Racing / Driving,Simulation', 'Sony PSP', 2007),
('Bionicle Heroes', 1, 'Action', 'Nintendo Wii', 2007),
('Burnout Dominator', 4, 'Action,Racing / Driving', 'Sony PSP', 2007),
('Samurai Warriors 2: Empires', 2, 'Action,Role-Playing (RPG),Strategy', 'X360', 2007),
('Meteos: Disney Magic', 1, 'Strategy', 'Nintendo DS', 2007),
('Turn It Around', 1, 'Racing / Driving,Sports', 'Nintendo DS', 2007),
('Cube', 1, 'Strategy', 'Sony PSP', 2007),
('Dragoneer\'s Aria', 1, 'Role-Playing (RPG)', 'Sony PSP', 2007),
('The Fast and the Furious', 1, 'Racing / Driving', 'Sony PSP', 2007),
('R-Type Command', 1, 'Strategy', 'Sony PSP', 2007),
('Virtua Tennis 3', 1, 'Sports', 'Sony PSP', 2007),
('Virtua Tennis 3', 4, 'Sports', 'X360', 2007),
('Front Mission', 1, 'Strategy', 'Nintendo DS', 2007),
('Lost in Blue 2', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2007),
('Nervous Brickdown', 1, 'Action', 'Nintendo DS', 2007),
('Sea Monsters: A Prehistoric Adventure', 1, 'Action,Educational', 'Nintendo DS', 2007),
('After Burner: Black Falcon', 1, 'Action', 'Sony PSP', 2007),
('Capcom Puzzle World', 1, 'Strategy', 'Sony PSP', 2007),
('Puzzle Quest: Challenge of the Warlords', 1, 'Role-Playing (RPG),Strategy', 'Sony PSP', 2007),
('Smash Court Tennis 3', 1, 'Sports', 'Sony PSP', 2007),
('UEFA Champions League 2006-2007', 1, 'Sports', 'Sony PSP', 2007),
('Driver: Parallel Lines', 1, 'Action,Racing / Driving', 'Nintendo Wii', 2007),
('Mario Kart Wii', 4, 'Racing / Driving', 'Nintendo Wii', 2008),
('Grand Theft Auto IV', 1, 'Action,Racing / Driving', 'X360', 2008),
('Super Smash Bros.: Brawl', 6, 'Action', 'Nintendo Wii', 2008),
('Call of Duty: World at War', 4, 'Action', 'X360', 2008),
('Grand Theft Auto IV', 1, 'Action,Racing / Driving', 'PlayStation 3', 2008),
('Gears of War 2', 2, 'Action', 'X360', 2008),
('Pokmon: Platinum Version', 1, 'Adventure,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Metal Gear Solid 4: Guns of the Patriots', 1, 'Action', 'PlayStation 3', 2008),
('Fable II', 1, 'Role-Playing (RPG)', 'X360', 2008),
('Call of Duty: World at War', 4, 'Action', 'PlayStation 3', 2008),
('Guitar Hero: World Tour', 4, 'Action,Simulation', 'Nintendo Wii', 2008),
('LittleBigPlanet', 4, 'Action', 'PlayStation 3', 2008),
('Fallout 3', 1, 'Action,Role-Playing (RPG)', 'X360', 2008),
('LEGO Indiana Jones: The Original Adventures', 2, 'Action', 'X360', 2008),
('Left 4 Dead', 2, 'Action', 'X360', 2008),
('Madden NFL 09', 4, 'Sports', 'X360', 2008),
('Guitar Hero: On Tour', 1, 'Action,Simulation', 'Nintendo DS', 2008),
('Kung Fu Panda', 4, 'Action', 'X360', 2008),
('Rock Band 2', 4, 'Action,Simulation', 'X360', 2008),
('Sega Superstars Tennis', 4, 'Sports', 'X360', 2008),
('Guitar Hero: World Tour', 4, 'Action,Simulation', 'X360', 2008),
('Animal Crossing: City Folk', 1, 'Simulation', 'Nintendo Wii', 2008),
('Mario & Sonic at the Olympic Games', 1, 'Action,Sports', 'Nintendo DS', 2008),
('Madden NFL 09', 4, 'Sports', 'PlayStation 3', 2008),
('LEGO Batman: The Videogame', 2, 'Action', 'X360', 2008),
('Tom Clancy\'s Rainbow Six: Vegas 2', 2, 'Action', 'X360', 2008),
('Kirby Super Star Ultra', 1, 'Action', 'Nintendo DS', 2008),
('Star Wars: The Force Unleashed', 1, 'Action', 'X360', 2008),
('God of War: Chains of Olympus', 1, 'Action', 'Sony PSP', 2008),
('Fallout 3', 1, 'Action,Role-Playing (RPG)', 'PlayStation 3', 2008),
('Pure', 1, 'Racing / Driving,Sports', 'X360', 2008),
('LEGO Indiana Jones: The Original Adventures', 2, 'Action', 'Nintendo Wii', 2008),
('Rock Band', 2, 'Action,Simulation', 'Nintendo Wii', 2008),
('LEGO Batman: The Videogame', 1, 'Action,Racing / Driving', 'Nintendo DS', 2008),
('Saints Row 2', 1, 'Action,Racing / Driving', 'X360', 2008),
('LEGO Batman: The Videogame', 2, 'Action', 'Nintendo Wii', 2008),
('Call of Duty: World at War', 2, 'Action', 'Nintendo Wii', 2008),
('Midnight Club: Los Angeles', 1, 'Racing / Driving', 'X360', 2008),
('Mortal Kombat vs. DC Universe', 2, 'Action', 'PlayStation 3', 2008),
('Army of Two', 2, 'Action', 'X360', 2008),
('Resistance 2', 2, 'Action', 'PlayStation 3', 2008),
('Rock Band 2', 1, 'Action,Simulation', 'PlayStation 3', 2008),
('Midnight Club: Los Angeles', 1, 'Racing / Driving', 'PlayStation 3', 2008),
('Sonic Unleashed', 1, 'Action', 'Nintendo Wii', 2008),
('NBA 2K9 ', 1, 'Sports', 'X360', 2008),
('Guitar Hero: World Tour', 4, 'Action,Simulation', 'PlayStation 3', 2008),
('Guitar Hero: Aerosmith', 1, 'Action,Simulation', 'Nintendo Wii', 2008),
('Star Wars: The Force Unleashed', 2, 'Action', 'Nintendo Wii', 2008),
('Burnout Paradise', 1, 'Action,Racing / Driving', 'PlayStation 3', 2008),
('Pokmon Ranger: Shadows of Almia', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Mortal Kombat vs. DC Universe', 2, 'Action', 'X360', 2008),
('Dead Space', 1, 'Action', 'PlayStation 3', 2008),
('Shaun White Snowboarding: Road Trip', 1, 'Sports', 'Nintendo Wii', 2008),
('Star Wars: The Force Unleashed', 1, 'Action', 'PlayStation 3', 2008),
('Guitar Hero: Aerosmith', 2, 'Action,Simulation', 'X360', 2008),
('SOCOM: U.S. Navy SEALs - Confrontation', 1, 'Action', 'PlayStation 3', 2008),
('SoulCalibur IV', 2, 'Action', 'X360', 2008),
('Battlefield: Bad Company', 1, 'Action', 'X360', 2008),
('Saints Row 2', 1, 'Action,Racing / Driving', 'PlayStation 3', 2008),
('Guitar Hero: On Tour - Decades', 1, 'Action,Simulation', 'Nintendo DS', 2008),
('Devil May Cry 4', 1, 'Action', 'X360', 2008),
('Mystery Case Files: MillionHeir', 1, 'Adventure', 'Nintendo DS', 2008),
('Battlefield: Bad Company', 1, 'Action', 'PlayStation 3', 2008),
('Army of Two', 2, 'Action', 'PlayStation 3', 2008),
('Rayman Raving Rabbids TV Party', 4, 'Action,Racing / Driving,Sports,Strategy', 'Nintendo Wii', 2008),
('The House of the Dead 2 & 3 Return', 2, 'Action', 'Nintendo Wii', 2008),
('Far Cry 2', 1, 'Action', 'X360', 2008),
('Boom Blox', 4, 'Action,Strategy', 'Nintendo Wii', 2008),
('Spore Creatures', 1, 'Adventure,Simulation', 'Nintendo DS', 2008),
('Madden NFL 09', 4, 'Sports', 'Sony PSP', 2008),
('NCAA Football 09', 4, 'Sports', 'X360', 2008),
('MLB 08: The Show', 2, 'Sports', 'PlayStation 3', 2008),
('Tom Clancy\'s Rainbow Six: Vegas 2', 2, 'Action', 'PlayStation 3', 2008),
('Mercenaries 2: World in Flames', 1, 'Action', 'X360', 2008),
('Need for Speed: Undercover', 1, 'Racing / Driving', 'X360', 2008),
('Guitar Hero: Aerosmith', 2, 'Action,Simulation', 'PlayStation 3', 2008),
('SoulCalibur IV', 2, 'Action', 'PlayStation 3', 2008),
('Valkyria Chronicles', 1, 'Action,Role-Playing (RPG),Strategy', 'PlayStation 3', 2008),
('Harvest Moon: Tree of Tranquility', 1, 'Role-Playing (RPG),Simulation', 'Nintendo Wii', 2008),
('Star Wars: The Clone Wars - Jedi Alliance', 1, 'Action,Adventure', 'Nintendo DS', 2008),
('Need for Speed: Undercover', 1, 'Racing / Driving', 'PlayStation 3', 2008),
('Wario Land: Shake It!', 1, 'Action', 'Nintendo Wii', 2008),
('NBA 2K9', 7, 'Sports', 'PlayStation 3', 2008),
('Major League Baseball 2K9', 1, 'Sports', 'X360', 2008),
('NCAA Football 09', 4, 'Sports', 'PlayStation 3', 2008),
('Kung Fu Panda', 1, 'Action', 'Nintendo DS', 2008),
('Devil May Cry 4', 1, 'Action', 'PlayStation 3', 2008),
('Tom Clancy\'s EndWar', 1, 'Strategy', 'X360', 2008),
('LEGO Batman: The Videogame', 1, 'Action', 'Sony PSP', 2008),
('BioShock', 1, 'Action', 'PlayStation 3', 2008),
('Bully: Scholarship Edition', 1, 'Action,Adventure', 'X360', 2008),
('Prince of Persia', 1, 'Action', 'X360', 2008),
('Kung Fu Panda', 4, 'Action', 'Nintendo Wii', 2008),
('Sonic Chronicles: The Dark Brotherhood', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Chrono Trigger', 2, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Tomb Raider: Underworld', 1, 'Action', 'X360', 2008),
('skate it', 4, 'Action,Sports', 'Nintendo Wii', 2008),
('The Legendary Starfy', 1, 'Action,Adventure', 'Nintendo DS', 2008),
('Mirror\'s Edge', 1, 'Action', 'X360', 2008),
('Haze', 2, 'Action', 'PlayStation 3', 2008),
('Dissidia: Final Fantasy', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2008),
('Sid Meier\'s Civilization: Revolution', 1, 'Strategy', 'X360', 2008),
('Wall-E', 4, 'Action', 'Nintendo Wii', 2008),
('Prince of Persia', 1, 'Action', 'PlayStation 3', 2008),
('NHL 09 ', 1, 'Sports', 'X360', 2008),
('Brothers in Arms: Hell\'s Highway', 1, 'Action', 'X360', 2008),
('Shaun White Snowboarding', 1, 'Sports', 'X360', 2008),
('Turok', 1, 'Action', 'X360', 2008),
('Iron Man', 1, 'Action', 'Sony PSP', 2008),
('De Blob', 4, 'Action', 'Nintendo Wii', 2008),
('Sonic Riders: Zero Gravity', 4, 'Racing / Driving', 'Nintendo Wii', 2008),
('Rhythm Heaven', 1, 'Action', 'Nintendo DS', 2008),
('Tomb Raider: Underworld', 1, 'Action', 'PlayStation 3', 2008),
('Advance Wars: Days of Ruin', 4, 'Strategy', 'Nintendo DS', 2008),
('LEGO Batman: The Videogame', 2, 'Action', 'PlayStation 3', 2008),
('Far Cry 2', 1, 'Action', 'PlayStation 3', 2008),
('Harvest Moon: Island of Happiness', 1, 'Simulation,Strategy', 'Nintendo DS', 2008),
('Brothers in Arms: Hell\'s Highway', 1, 'Action', 'PlayStation 3', 2008),
('Sonic Unleashed', 1, 'Action,Adventure', 'PlayStation 3', 2008),
('Pinball Hall of Fame: The Williams Collection', 1, 'Simulation', 'Nintendo Wii', 2008),
('Sonic Unleashed', 1, 'Action,Adventure', 'X360', 2008),
('Samba de Amigo', 2, 'Action', 'Nintendo Wii', 2008),
('?kami', 1, 'Action', 'Nintendo Wii', 2008),
('LEGO Indiana Jones: The Original Adventures', 2, 'Action', 'PlayStation 3', 2008),
('MotorStorm: Pacific Rift', 4, 'Action,Racing / Driving,Sports', 'PlayStation 3', 2008),
('Tiger Woods PGA Tour 09', 4, 'Sports', 'X360', 2008),
('SimCity Creator', 1, 'Simulation', 'Nintendo Wii', 2008),
('Tiger Woods PGA Tour 09', 4, 'Sports', 'PlayStation 3', 2008),
('Sid Meier\'s Civilization: Revolution', 1, 'Simulation,Strategy', 'Nintendo DS', 2008),
('Pure', 1, 'Racing / Driving,Sports', 'PlayStation 3', 2008),
('Turok', 1, 'Action', 'PlayStation 3', 2008),
('Crash: Mind over Mutant', 1, 'Action', 'Nintendo Wii', 2008),
('Spider-Man: Web of Shadows', 1, 'Action', 'X360', 2008),
('Frontlines: Fuel of War', 1, 'Action', 'X360', 2008),
('GRID', 1, 'Racing / Driving,Simulation,Sports', 'X360', 2008),
('Too Human', 1, 'Action,Role-Playing (RPG)', 'X360', 2008),
('Speed Racer: The Videogame', 2, 'Racing / Driving', 'Nintendo Wii', 2008),
('LEGO Indiana Jones: The Original Adventures', 1, 'Action', 'Sony PSP', 2008),
('SEGA Bass Fishing', 1, 'Sports', 'Nintendo Wii', 2008),
('The Chronicles of Narnia: Prince Caspian', 2, 'Action,Role-Playing (RPG)', 'Nintendo Wii', 2008),
('Iron Man', 1, 'Action', 'Nintendo DS', 2008),
('The Sims 2: Apartment Pets', 1, 'Simulation', 'Nintendo DS', 2008),
('MLB 08: The Show', 1, 'Sports', 'Sony PSP', 2008),
('Iron Man', 1, 'Action', 'PlayStation 3', 2008),
('Madagascar: Escape 2 Africa', 1, 'Action,Adventure', 'Nintendo DS', 2008),
('GRID', 1, 'Racing / Driving,Simulation,Sports', 'PlayStation 3', 2008),
('NHL 09', 1, 'Sports', 'PlayStation 3', 2008),
('Banjo-Kazooie: Nuts & Bolts', 1, 'Action,Adventure,Racing / Driving,Sports', 'X360', 2008),
('Hot Shots Golf: Out of Bounds', 4, 'Sports', 'PlayStation 3', 2008),
('Rune Factory 2: A Fantasy Harvest Moon', 1, 'Action,Role-Playing (RPG),Simulation', 'Nintendo DS', 2008),
('SimCity Creator', 1, 'Simulation', 'Nintendo DS', 2008),
('Patapon', 1, 'Action,Strategy', 'Sony PSP', 2008),
('Shaun White Snowboarding', 1, 'Sports', 'PlayStation 3', 2008),
('Iron Man', 1, 'Action', 'Nintendo Wii', 2008),
('Sega Superstars Tennis', 1, 'Sports', 'Nintendo DS', 2008),
('Lost Planet: Extreme Condition', 1, 'Action', 'PlayStation 3', 2008),
('Mirror\'s Edge', 1, 'Action', 'PlayStation 3', 2008),
('The Incredible Hulk', 1, 'Action', 'Nintendo Wii', 2008),
('Condemned 2: Bloodshot', 1, 'Action,Adventure', 'X360', 2008),
('Sega Superstars Tennis', 4, 'Sports', 'Nintendo Wii', 2008),
('Speed Racer: The Videogame', 1, 'Racing / Driving', 'Nintendo DS', 2008),
('Viva Pi$?ata: Pocket Paradise', 1, 'Simulation,Strategy', 'Nintendo DS', 2008),
('Tom Clancy\'s EndWar', 1, 'Strategy', 'PlayStation 3', 2008),
('Iron Man', 1, 'Action', 'X360', 2008),
('Need for Speed: Undercover', 4, 'Racing / Driving', 'Nintendo Wii', 2008),
('Wall-E', 4, 'Action', 'X360', 2008),
('Spectrobes: Beyond the Portals', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2008),
('MX vs. ATV Untamed', 1, 'Educational', 'Sony PSP', 2008),
('Mercenaries 2: World in Flames', 1, 'Action', 'PlayStation 3', 2008),
('Infinite Undiscovery', 1, 'Action,Role-Playing (RPG)', 'X360', 2008),
('TNA iMPACT!', 4, 'Sports', 'X360', 2008),
('Enemy Territory: Quake Wars', 1, 'Action', 'X360', 2008),
('Fire Emblem: Shadow Dragon', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2008),
('Neopets Puzzle Adventure', 1, 'Adventure,Role-Playing (RPG),Strategy', 'Nintendo DS', 2008),
('Tales of Vesperia', 1, 'Adventure,Role-Playing (RPG)', 'X360', 2008),
('SingStar ABBA', 8, 'Action', 'PlayStation 3', 2008),
('Dragon Ball Z: Burst Limit', 2, 'Action', 'X360', 2008),
('Apollo Justice: Ace Attorney', 1, 'Adventure,Simulation', 'Nintendo DS', 2008),
('Castlevania: Order of Ecclesia', 1, 'Action,Adventure,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Mega Man Star Force 2: Zerker X Ninja', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Enemy Territory: Quake Wars', 1, 'Action', 'PlayStation 3', 2008),
('Namco Museum: Virtual Arcade', 1, 'Action,Racing / Driving', 'X360', 2008),
('NASCAR 09', 1, 'Racing / Driving,Sports', 'X360', 2008),
('Turning Point: Fall of Liberty', 1, 'Action', 'X360', 2008),
('Summer Athletics 2009', 4, 'Sports', 'Nintendo Wii', 2008),
('Unreal Tournament III', 2, 'Action', 'X360', 2008),
('Shaun White Snowboarding', 1, 'Racing / Driving,Sports', 'Nintendo DS', 2008),
('Dark Sector', 1, 'Action', 'PlayStation 3', 2008),
('The Last Remnant', 1, 'Role-Playing (RPG)', 'X360', 2008),
('Dragon Ball Z: Burst Limit', 2, 'Action', 'PlayStation 3', 2008),
('NASCAR 09', 1, 'Racing / Driving,Sports', 'PlayStation 3', 2008),
('Turning Point: Fall of Liberty', 1, 'Action', 'PlayStation 3', 2008),
('MX vs. ATV Untamed', 1, 'Racing / Driving', 'Nintendo Wii', 2008),
('Crash: Mind over Mutant', 1, 'Action', 'X360', 2008),
('The Incredible Hulk', 1, 'Action', 'X360', 2008),
('Silent Hill: Homecoming', 1, 'Action', 'X360', 2008),
('TNA iMPACT!', 4, 'Sports', 'PlayStation 3', 2008),
('The Incredible Hulk', 1, 'Action', 'PlayStation 3', 2008),
('Kung Fu Panda', 1, 'Action', 'PlayStation 3', 2008),
('Dark Sector', 1, 'Action', 'X360', 2008),
('Tales of Symphonia: Dawn of the New World', 4, 'Role-Playing (RPG)', 'Nintendo Wii', 2008),
('Valkyrie Profile: Covenant of the Plume', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2008),
('Spider-Man: Web of Shadows', 1, 'Action', 'PlayStation 3', 2008),
('TV Show King', 4, 'Strategy', 'Nintendo Wii', 2008),
('AC/DC Live: Rock Band - Track Pack', 4, 'Action,Simulation', 'X360', 2008),
('The Chronicles of Narnia: Prince Caspian', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Hot Shots Golf: Open Tee 2', 1, 'Sports', 'Sony PSP', 2008),
('AC/DC Live: Rock Band - Track Pack', 1, 'Action,Simulation', 'PlayStation 3', 2008),
('Harvest Moon: Magical Melody', 4, 'Role-Playing (RPG),Simulation', 'Nintendo Wii', 2008),
('Dynasty Warriors 6', 2, 'Action,Strategy', 'PlayStation 3', 2008),
('Order Up!', 1, 'Action,Simulation', 'Nintendo Wii', 2008),
('NBA Ballers: Chosen One', 4, 'Sports', 'X360', 2008),
('Age of Empires: Mythologies', 1, 'Strategy', 'Nintendo DS', 2008),
('LocoRoco 2', 1, 'Action,Strategy', 'Sony PSP', 2008),
('Star Ocean: First Departure', 1, 'Action,Role-Playing (RPG)', 'Sony PSP', 2008),
('Lost: Via Domus', 1, 'Action,Adventure', 'PlayStation 3', 2008),
('Tetris Party', 4, 'Strategy', 'Nintendo Wii', 2008),
('Bully: Scholarship Edition', 2, 'Action,Adventure', 'Nintendo Wii', 2008),
('The Spiderwick Chronicles', 2, 'Action,Adventure', 'Nintendo Wii', 2008),
('Dynasty Warriors 6', 2, 'Action,Strategy', 'X360', 2008),
('Facebreaker', 2, 'Sports', 'X360', 2008),
('Ninja Gaiden: Dragon Sword', 1, 'Action', 'Nintendo DS', 2008),
('Condemned 2: Bloodshot', 1, 'Action,Adventure', 'PlayStation 3', 2008),
('Silent Hill: Homecoming', 1, 'Action', 'PlayStation 3', 2008),
('Command & Conquer: Red Alert 3', 1, 'Strategy', 'X360', 2008),
('Viking: Battle for Asgard', 1, 'Action', 'X360', 2008),
('Beijing 2008', 4, 'Sports', 'X360', 2008),
('Don King Presents: Prizefighter', 2, 'Sports', 'X360', 2008),
('Bomberman', 1, 'Action,Strategy', 'Sony PSP', 2008),
('Ferrari Challenge Trofeo Pirelli', 1, 'Racing / Driving', 'PlayStation 3', 2008),
('Command & Conquer 3: Kane\'s Wrath', 1, 'Strategy', 'X360', 2008),
('Lost: Via Domus', 1, 'Action,Adventure', 'X360', 2008),
('NHL 2K9 ', 1, 'Sports', 'X360', 2008),
('Eternal Sonata', 2, 'Role-Playing (RPG)', 'PlayStation 3', 2008),
('Viva Pi$?ata: Trouble in Paradise', 2, 'Racing / Driving,Simulation,Strategy', 'X360', 2008),
('FlatOut: Head On', 1, 'Racing / Driving,Sports', 'Sony PSP', 2008),
('Viking: Battle for Asgard', 1, 'Action', 'PlayStation 3', 2008),
('Neopets Puzzle Adventure', 1, 'Role-Playing (RPG),Strategy', 'Nintendo Wii', 2008),
('TNA iMPACT!', 1, 'Sports', 'Nintendo Wii', 2008),
('Tomb Raider: Underworld', 1, 'Action', 'Nintendo Wii', 2008),
('The Club', 4, 'Action', 'X360', 2008),
('The Chronicles of Narnia: Prince Caspian', 2, 'Action,Role-Playing (RPG)', 'X360', 2008),
('Cabela\'s Dangerous Hunts 2009', 1, 'Sports', 'X360', 2008),
('Dark Messiah of Might and Magic: Elements', 1, 'Action,Role-Playing (RPG)', 'X360', 2008),
('Fracture', 1, 'Action', 'X360', 2008),
('Bomberman Land', 4, 'Action', 'Nintendo Wii', 2008),
('Nitrobike', 4, 'Action,Racing / Driving,Sports', 'Nintendo Wii', 2008),
('Culdcept Saga', 4, 'Strategy', 'X360', 2008),
('Facebreaker', 2, 'Sports', 'PlayStation 3', 2008),
('MLB Power Pros 2008', 2, 'Sports', 'Nintendo Wii', 2008),
('Mushroom Men: The Spore Wars', 2, 'Action', 'Nintendo Wii', 2008),
('Dragon Quest V: Hand of the Heavenly Bride', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Ninjatown', 1, 'Strategy', 'Nintendo DS', 2008),
('Super Dodgeball Brawlers', 1, 'Action,Sports', 'Nintendo DS', 2008),
('Dokapon Kingdom', 1, 'Role-Playing (RPG),Strategy', 'Nintendo Wii', 2008),
('Alone in the Dark', 1, 'Action,Adventure,Racing / Driving', 'X360', 2008),
('NBA 09: The Inside', 4, 'Sports', 'PlayStation 3', 2008),
('Sega Superstars Tennis', 4, 'Sports', 'PlayStation 3', 2008),
('Baja: Edge of Control', 4, 'Racing / Driving,Simulation,Sports', 'X360', 2008),
('Destroy All Humans! Big Willy Unleashed', 2, 'Adventure', 'Nintendo Wii', 2008),
('Space Invaders Extreme', 1, 'Action', 'Nintendo DS', 2008),
('Ultimate Band', 1, 'Action,Simulation', 'Nintendo DS', 2008),
('The Club', 4, 'Action', 'PlayStation 3', 2008),
('Madagascar: Escape 2 Africa', 4, 'Action', 'PlayStation 3', 2008),
('NBA Ballers: Chosen One', 4, 'Sports', 'PlayStation 3', 2008),
('Dream Pinball 3D', 4, 'Simulation', 'Nintendo Wii', 2008),
('Madagascar: Escape 2 Africa', 4, 'Action', 'X360', 2008),
('Pro Evolution Soccer 2008', 2, 'Sports', 'Nintendo Wii', 2008),
('Avalon Code', 1, 'Action,Adventure,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Disgaea DS', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2008),
('Guitar Rock Tour', 1, 'Simulation', 'Nintendo DS', 2008),
('Lost in Blue 3', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Syberia', 1, 'Adventure', 'Nintendo DS', 2008),
('Afrika', 1, 'Adventure,Simulation', 'PlayStation 3', 2008),
('NFL Head Coach 09', 1, 'Simulation,Sports,Strategy', 'PlayStation 3', 2008),
('NHL 2K9', 1, 'Sports', 'PlayStation 3', 2008),
('Brothers in Arms: Double Time', 1, 'Action,Strategy', 'Nintendo Wii', 2008),
('ObsCure: The Aftermath', 1, 'Action', 'Nintendo Wii', 2008),
('MotoGP 08', 1, 'Racing / Driving,Simulation,Sports', 'X360', 2008),
('NFL Head Coach 09', 1, 'Simulation,Sports,Strategy', 'X360', 2008),
('NFL Tour', 1, 'Action,Sports', 'X360', 2008),
('Pinball Hall of Fame: The Williams Collection', 4, 'Simulation', 'Sony PSP', 2008),
('Baja: Edge of Control', 4, 'Racing / Driving,Simulation,Sports', 'PlayStation 3', 2008),
('NFL Tour', 4, 'Action,Sports', 'PlayStation 3', 2008),
('Wall-E', 4, 'Action', 'PlayStation 3', 2008),
('Ninja Reflex', 4, 'Action', 'Nintendo Wii', 2008),
('Conflict: Denied Ops', 4, 'Action', 'X360', 2008),
('Top Spin 3', 4, 'Sports', 'X360', 2008),
('Blitz: The League II', 2, 'Action,Sports', 'PlayStation 3', 2008),
('Hellboy: The Science of Evil', 2, 'Action,Adventure', 'PlayStation 3', 2008),
('Castlevania Judgment', 2, 'Action', 'Nintendo Wii', 2008),
('Death Jr. II: Root of Evil', 2, 'Action', 'Nintendo Wii', 2008),
('Raiden IV', 2, 'Action', 'X360', 2008),
('Metal Slug 7', 1, 'Action', 'Nintendo DS', 2008),
('Spider-Man: Web of Shadows', 1, 'Action', 'Nintendo DS', 2008),
('Trauma Center: Under The Knife 2', 1, 'Action,Simulation', 'Nintendo DS', 2008),
('Fracture', 1, 'Action', 'PlayStation 3', 2008),
('Alone in the Dark', 1, 'Action,Adventure,Racing / Driving', 'Nintendo Wii', 2008),
('Final Fantasy Fables: Chocobo\'s Dungeon', 1, 'Action,Role-Playing (RPG)', 'Nintendo Wii', 2008),
('The King of Fighters Collection: The Orochi Saga', 1, 'Action', 'Nintendo Wii', 2008),
('Klonoa: Door to Phantomile', 1, 'Action', 'Nintendo Wii', 2008),
('Samurai Warriors: Katana', 1, 'Action', 'Nintendo Wii', 2008),
('Battle of the Bands', 2, 'Action,Simulation', 'Nintendo Wii', 2008),
('Hellboy: The Science of Evil', 2, 'Action,Adventure', 'X360', 2008),
('Dragon Ball: Origins', 1, 'Action,Adventure', 'Nintendo DS', 2008),
('Ninja Reflex', 1, 'Action', 'Nintendo DS', 2008),
('Space Bust-A-Move', 1, 'Strategy', 'Nintendo DS', 2008),
('Top Spin 3', 1, 'Sports', 'PlayStation 3', 2008),
('UEFA Euro 2008', 7, 'Sports', 'PlayStation 3', 2008),
('Blast Works: Build, Trade, Destroy', 4, 'Action', 'Nintendo Wii', 2008),
('FIFA Street 3', 4, 'Sports', 'X360', 2008),
('Blitz: The League II', 2, 'Action,Sports', 'X360', 2008),
('Space Chimps', 2, 'Action,Adventure', 'X360', 2008),
('The Spiderwick Chronicles', 2, 'Action,Adventure', 'X360', 2008),
('Etrian Odyssey II: Heroes of Lagaard', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Line Rider 2: Unbound', 1, 'Simulation,Sports', 'Nintendo DS', 2008),
('The King of Fighters Collection: The Orochi Saga', 1, 'Action', 'Sony PSP', 2008),
('Target: Terror', 1, 'Action', 'Nintendo Wii', 2008),
('Legendary', 1, 'Action', 'X360', 2008),
('Universe at War: Earth Assault', 1, 'Action,Strategy', 'X360', 2008),
('Smash Court Tennis 3', 4, 'Simulation,Sports', 'X360', 2008),
('Code Lyoko: Fall of X.A.N.A', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Knights in the Nightmare', 1, 'Role-Playing (RPG),Strategy', 'Nintendo DS', 2008),
('Lock\'s Quest', 1, 'Action,Adventure,Strategy', 'Nintendo DS', 2008),
('Master of the Monster Lair', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('N+', 1, 'Action', 'Nintendo DS', 2008),
('Pipe Mania', 1, 'Strategy', 'Nintendo DS', 2008),
('The Spiderwick Chronicles', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Summon Night: Twin Age', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Wild Arms XF', 1, 'Role-Playing (RPG)', 'Sony PSP', 2008),
('FIFA Street 3', 1, 'Sports', 'PlayStation 3', 2008),
('MotoGP 08', 1, 'Racing / Driving,Simulation,Sports', 'PlayStation 3', 2008),
('Harvey Birdman: Attorney at Law', 1, 'Adventure', 'Nintendo Wii', 2008),
('Let\'s Tap', 1, 'Simulation', 'Nintendo Wii', 2008),
('NHL 2K9', 1, 'Sports', 'Nintendo Wii', 2008),
('Conflict: Denied Ops', 4, 'Action', 'PlayStation 3', 2008),
('Worms: A Space Oddity', 4, 'Action,Strategy', 'Nintendo Wii', 2008),
('UEFA Euro 2008', 4, 'Sports', 'X360', 2008),
('Overlord: Raising Hell', 2, 'Action,Strategy', 'PlayStation 3', 2008),
('Battle Fantasia', 2, 'Action,Role-Playing (RPG)', 'X360', 2008),
('Bangai-O Spirits', 1, 'Action', 'Nintendo DS', 2008),
('Dungeon Explorer: Warriors of Ancient Arts', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2008),
('From the Abyss', 1, 'Action,Role-Playing (RPG)', 'Nintendo DS', 2008),
('New International Track & Field', 1, 'Action,Sports', 'Nintendo DS', 2008),
('Soul Bubbles', 1, 'Strategy', 'Nintendo DS', 2008),
('Tropix!', 1, 'Action', 'Nintendo DS', 2008),
('Unsolved Crimes', 1, 'Action,Adventure,Racing / Driving', 'Nintendo DS', 2008),
('Zubo', 1, 'Adventure,Role-Playing (RPG),Strategy', 'Nintendo DS', 2008),
('Ford Racing Off Road', 1, 'Racing / Driving', 'Sony PSP', 2008),
('Harvey Birdman: Attorney at Law', 1, 'Adventure', 'Sony PSP', 2008),
('Secret Agent Clank', 1, 'Action', 'Sony PSP', 2008),
('Space Invaders Extreme', 1, 'Action', 'Sony PSP', 2008),
('Armored Core: For Answer', 1, 'Action', 'PlayStation 3', 2008),
('Legendary', 1, 'Action', 'PlayStation 3', 2008),
('Agatha Christie: Evil Under the Sun', 1, 'Adventure', 'Nintendo Wii', 2008),
('Agatha Christie: And Then There Were None', 1, 'Adventure', 'Nintendo Wii', 2008),
('Armored Core: For Answer', 1, 'Action', 'X360', 2008),
('Cradle of Rome', 1, 'Strategy', 'Nintendo DS', 2008),
('The Dark Spire', 1, 'Adventure,Role-Playing (RPG)', 'Nintendo DS', 2008),
('Flower, Sun and Rain', 1, 'Adventure', 'Nintendo DS', 2008),
('Insecticide', 1, 'Action,Adventure', 'Nintendo DS', 2008),
('Izuna 2: The Unemployed Ninja Returns', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Looney Tunes: Cartoon Conductor', 1, 'Action', 'Nintendo DS', 2008),
('Nanostray 2', 1, 'Action', 'Nintendo DS', 2008),
('Hellboy: The Science of Evil', 1, 'Action', 'Sony PSP', 2008),
('Pipe Mania', 1, 'Strategy', 'Sony PSP', 2008),
('UEFA Euro 2008', 1, 'Sports', 'Sony PSP', 2008),
('Vampire Rain', 1, 'Action', 'PlayStation 3', 2008),
('Baroque', 1, 'Action,Role-Playing (RPG)', 'Nintendo Wii', 2008),
('Supreme Commander', 1, 'Strategy', 'X360', 2008),
('Hail to the Chimp', 4, 'Action,Strategy', 'X360', 2008),
('Assassin\'s Creed: Altar\'s Chronicles', 1, 'Action', 'Nintendo DS', 2008),
('The Legend of Kage 2', 1, 'Action', 'Nintendo DS', 2008),
('Rhapsody: A Musical Adventure', 1, 'Role-Playing (RPG)', 'Nintendo DS', 2008),
('Secret Files: Tunguska', 1, 'Adventure', 'Nintendo DS', 2008),
('Fading Shadows', 1, 'Action,Adventure', 'Sony PSP', 2008),
('Hail to the Chimp', 1, 'Action,Strategy', 'PlayStation 3', 2008),
('Secret Files: Tunguska', 2, 'Adventure', 'Nintendo Wii', 2008),
('Chicken Hunter', 1, 'Action', 'Nintendo DS', 2008);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `viewauthors`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `viewauthors` (
`id` int unsigned
,`surname` varchar(50)
,`name` varchar(50)
,`title` varchar(50)
,`price` decimal(6,2) unsigned
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `viewauthorspricecategory`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `viewauthorspricecategory` (
`id` int unsigned
,`surname` varchar(50)
,`name` varchar(50)
,`title` varchar(50)
,`price` decimal(6,2) unsigned
,`category` varchar(7)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `viewchecktales`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `viewchecktales` (
`id` int unsigned
,`surname` varchar(50)
,`name` varchar(50)
,`title` varchar(50)
,`price` decimal(6,2) unsigned
,`has_tales` varchar(3)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `viewdelivers`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `viewdelivers` (
`id` int unsigned
,`order_date` datetime
,`customers_id` int unsigned
,`login` varchar(20)
,`surname` varchar(50)
,`name` varchar(50)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `viewlistbooks`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `viewlistbooks` (
`surname` varchar(50)
,`name` varchar(50)
,`book_titles` text
);

-- --------------------------------------------------------

--
-- Структура для представления `viewauthors`
--
DROP TABLE IF EXISTS `viewauthors`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `viewauthors`  AS SELECT `book`.`id` AS `id`, `authors`.`surname` AS `surname`, `authors`.`name` AS `name`, `book`.`title` AS `title`, `book`.`price` AS `price` FROM (`book` join `authors` on((`book`.`author_id` = `authors`.`id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `viewauthorspricecategory`
--
DROP TABLE IF EXISTS `viewauthorspricecategory`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `viewauthorspricecategory`  AS SELECT `viewauthors`.`id` AS `id`, `viewauthors`.`surname` AS `surname`, `viewauthors`.`name` AS `name`, `viewauthors`.`title` AS `title`, `viewauthors`.`price` AS `price`, (case when (`viewauthors`.`price` < 1000) then 'Дешёвая' when (`viewauthors`.`price` between 1000 and 5000) then 'Средняя' else 'Дорогая' end) AS `category` FROM `viewauthors` ;

-- --------------------------------------------------------

--
-- Структура для представления `viewchecktales`
--
DROP TABLE IF EXISTS `viewchecktales`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `viewchecktales`  AS SELECT `viewauthors`.`id` AS `id`, `viewauthors`.`surname` AS `surname`, `viewauthors`.`name` AS `name`, `viewauthors`.`title` AS `title`, `viewauthors`.`price` AS `price`, (case when (`viewauthors`.`title` like '%сказки%') then 'Да' else 'Нет' end) AS `has_tales` FROM `viewauthors` ;

-- --------------------------------------------------------

--
-- Структура для представления `viewdelivers`
--
DROP TABLE IF EXISTS `viewdelivers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `viewdelivers`  AS SELECT `orders`.`id` AS `id`, `orders`.`order_date` AS `order_date`, `orders`.`customers_id` AS `customers_id`, `customers`.`login` AS `login`, `customers`.`surname` AS `surname`, `customers`.`name` AS `name` FROM (`customers` join `orders` on((`customers`.`id` = `orders`.`customers_id`))) WHERE (year(`orders`.`order_date`) = year(now())) ;

-- --------------------------------------------------------

--
-- Структура для представления `viewlistbooks`
--
DROP TABLE IF EXISTS `viewlistbooks`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `viewlistbooks`  AS SELECT `authors`.`surname` AS `surname`, `authors`.`name` AS `name`, group_concat(`book`.`title` separator ';') AS `book_titles` FROM (`authors` join `book` on((`authors`.`id` = `book`.`author_id`))) GROUP BY `authors`.`id`, `authors`.`surname`, `authors`.`name` ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `authors`
--
ALTER TABLE `authors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_author_surname` (`surname`);

--
-- Индексы таблицы `book`
--
ALTER TABLE `book`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_author_id_idx` (`author_id`);

--
-- Индексы таблицы `booksinfo`
--
ALTER TABLE `booksinfo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UQ_BooksInfo_Title` (`title`),
  ADD UNIQUE KEY `UQ_BooksInfo_Name` (`name`),
  ADD UNIQUE KEY `UQ_BooksInfo_Surname` (`surname`);

--
-- Индексы таблицы `composition`
--
ALTER TABLE `composition`
  ADD PRIMARY KEY (`order_id`,`book_id`),
  ADD KEY `fk_book_id_idx` (`book_id`);

--
-- Индексы таблицы `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_customers_login` (`login`);

--
-- Индексы таблицы `deleted_customers`
--
ALTER TABLE `deleted_customers`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `games`
--
ALTER TABLE `games`
  ADD PRIMARY KEY (`idGame`);
ALTER TABLE `games` ADD FULLTEXT KEY `idx_description` (`description`);
ALTER TABLE `games` ADD FULLTEXT KEY `idx_name_description` (`name`,`description`);

--
-- Индексы таблицы `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `myeventtable`
--
ALTER TABLE `myeventtable`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customers_id_idx` (`customers_id`);

--
-- Индексы таблицы `tempbooks`
--
ALTER TABLE `tempbooks`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `video_games`
--
ALTER TABLE `video_games` ADD FULLTEXT KEY `idx_genre` (`Genres`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `authors`
--
ALTER TABLE `authors`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `book`
--
ALTER TABLE `book`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;

--
-- AUTO_INCREMENT для таблицы `booksinfo`
--
ALTER TABLE `booksinfo`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT для таблицы `games`
--
ALTER TABLE `games`
  MODIFY `idGame` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT для таблицы `logs`
--
ALTER TABLE `logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT для таблицы `myeventtable`
--
ALTER TABLE `myeventtable`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=472;

--
-- AUTO_INCREMENT для таблицы `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT для таблицы `tempbooks`
--
ALTER TABLE `tempbooks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `book`
--
ALTER TABLE `book`
  ADD CONSTRAINT `fk_author_id` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `composition`
--
ALTER TABLE `composition`
  ADD CONSTRAINT `fk_book_id` FOREIGN KEY (`book_id`) REFERENCES `book` (`id`),
  ADD CONSTRAINT `fk_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Ограничения внешнего ключа таблицы `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_customers` FOREIGN KEY (`customers_id`) REFERENCES `customers` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
