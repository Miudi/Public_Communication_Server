-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 13 Kwi 2024, 23:08
-- Wersja serwera: 10.4.20-MariaDB
-- Wersja PHP: 7.3.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `rozklad_jazdy`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddRoute` (IN `lin` INT, IN `przystanek_poczatkowy` VARCHAR(255), IN `przystanek_koncowy` VARCHAR(255), IN `godzina` INT, IN `minuty` INT)  BEGIN
    DECLARE kier INT;
    DECLARE przysta1 INT;
    DECLARE przysta2 INT;

    SELECT MAX(przystanek_id)+1 INTO przysta1 FROM przystanek;
    SELECT MAX(przystanek_id)+2 INTO przysta2 FROM przystanek;
    SELECT MAX(kierowca_id)+1 INTO kier FROM kierowca;

    INSERT INTO linia(linia_id) VALUES (lin);
    INSERT INTO przystanek(przystanek_id,nazwa,linia_id,przystanek_nr) VALUES (przysta1,przystanek_poczatkowy,lin,1);
    INSERT INTO przystanek(przystanek_id,nazwa,linia_id,przystanek_nr) VALUES (przysta2,przystanek_koncowy,lin,2);
    INSERT INTO kierowca(kierowca_id,linia_id,godzina_startu,minuta_startu) VALUES (kier,lin,godzina,minuty);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FindRoutes` (IN `przystanek_poczatkowy` VARCHAR(255), IN `przystanek_koncowy` VARCHAR(255), IN `godzina` INT, IN `minuty` INT)  BEGIN
    SELECT DISTINCT l.linia_id, p1.nazwa AS przystanek_poczatkowy, p2.nazwa AS przystanek_koncowy, k.godzina_startu*60 + k.minuta_startu AS czas_start, k.czas_do_przyj AS opoznienie, 
    (SELECT SUM(minuty_nast_przyst) FROM przystanek WHERE l.linia_id=linia_id AND przystanek_nr>=p1.przystanek_nr AND przystanek_nr<p2.przystanek_nr) + k.czas_do_przyj AS czas_podrozy,
    ((SELECT SUM(minuty_nast_przyst) FROM przystanek WHERE l.linia_id=linia_id AND przystanek_nr>=p1.przystanek_nr AND przystanek_nr<p2.przystanek_nr) + k.czas_do_przyj)+(k.godzina_startu*60 + k.minuta_startu) AS czas_koniec
    FROM LINIA l
    JOIN PRZYSTANEK p1 ON l.linia_id = p1.linia_id
    JOIN PRZYSTANEK p2 ON l.linia_id = p2.linia_id
    JOIN KIEROWCA k ON l.linia_id = k.linia_id
    WHERE LOWER(p1.nazwa) LIKE CONCAT('%', LOWER(przystanek_poczatkowy), '%')
      AND LOWER(p2.nazwa) LIKE CONCAT('%', LOWER(przystanek_koncowy), '%')
      AND k.godzina_startu*60+k.minuta_startu >= godzina*60+minuty
    HAVING czas_podrozy IS NOT NULL
    ORDER BY czas_koniec, czas_podrozy
    LIMIT 5;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `kierowca`
--

CREATE TABLE `kierowca` (
  `kierowca_id` int(5) NOT NULL,
  `czas_do_przyj` int(5) DEFAULT NULL,
  `linia_id` int(5) DEFAULT NULL,
  `godzina_startu` int(5) DEFAULT NULL,
  `minuta_startu` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `kierowca`
--

INSERT INTO `kierowca` (`kierowca_id`, `czas_do_przyj`, `linia_id`, `godzina_startu`, `minuta_startu`) VALUES
(1, 0, 1, 4, 17),
(2, 0, 1, 5, 40),
(3, 0, 1, 7, 3),
(4, 0, 1, 8, 26),
(5, 0, 1, 9, 49),
(6, 0, 1, 11, 12),
(7, 0, 1, 12, 35),
(8, 0, 1, 13, 58),
(9, 0, 1, 15, 21),
(10, 0, 1, 16, 44),
(11, 0, 1, 18, 7),
(12, 0, 1, 19, 30),
(13, 0, 1, 20, 53),
(14, 0, 1, 22, 16),
(15, 0, 2, 4, 13),
(16, 0, 2, 5, 26),
(17, 0, 2, 6, 39),
(18, 0, 2, 7, 52),
(19, 0, 2, 9, 5),
(20, 0, 2, 10, 18),
(21, 0, 2, 11, 31),
(22, 0, 2, 12, 44),
(23, 0, 2, 13, 57),
(24, 0, 2, 15, 10),
(25, 0, 2, 16, 23),
(26, 0, 2, 17, 39),
(27, 0, 2, 18, 52),
(28, 0, 2, 20, 5),
(29, 0, 2, 21, 18),
(30, 0, 4, 4, 4),
(31, 0, 4, 5, 11),
(32, 0, 4, 6, 18),
(33, 0, 4, 7, 25),
(34, 0, 4, 8, 32),
(35, 0, 4, 9, 39),
(36, 0, 4, 10, 46),
(37, 0, 4, 11, 53),
(38, 0, 4, 13, 0),
(39, 0, 4, 14, 7),
(40, 0, 4, 15, 14),
(41, 0, 4, 16, 21),
(42, 0, 4, 17, 28),
(43, 0, 4, 18, 35),
(44, 0, 4, 19, 42),
(45, 0, 4, 20, 49),
(46, 0, 4, 21, 56),
(47, 0, 5, 4, 31),
(48, 0, 5, 5, 40),
(49, 0, 5, 6, 49),
(50, 0, 5, 7, 58),
(51, 0, 5, 9, 7),
(52, 0, 5, 10, 16),
(53, 0, 5, 11, 25),
(54, 0, 5, 12, 34),
(55, 0, 5, 13, 43),
(56, 0, 5, 14, 52),
(57, 0, 5, 16, 1),
(58, 0, 5, 17, 10),
(59, 0, 5, 18, 19),
(60, 0, 5, 19, 28),
(61, 0, 5, 20, 37),
(62, 0, 5, 21, 46),
(63, 0, 5, 22, 55),
(64, 0, 7, 4, 28),
(65, 0, 7, 5, 31),
(66, 0, 7, 6, 34),
(67, 0, 7, 7, 37),
(68, 0, 7, 8, 40),
(69, 0, 7, 9, 43),
(70, 0, 7, 10, 46),
(71, 0, 7, 11, 49),
(72, 0, 7, 12, 52),
(73, 0, 7, 13, 55),
(74, 0, 7, 14, 58),
(75, 0, 7, 16, 1),
(76, 0, 7, 17, 4),
(77, 0, 7, 18, 7),
(78, 0, 7, 19, 10),
(79, 0, 7, 20, 13),
(80, 0, 7, 21, 16),
(81, 0, 8, 4, 5),
(82, 0, 8, 5, 5),
(83, 0, 8, 6, 5),
(84, 0, 8, 7, 5),
(85, 0, 8, 8, 5),
(86, 0, 8, 9, 5),
(87, 0, 8, 10, 5),
(88, 0, 8, 11, 5),
(89, 0, 8, 12, 5),
(90, 0, 8, 13, 5),
(91, 0, 8, 14, 5),
(92, 0, 8, 15, 5),
(93, 0, 8, 16, 5),
(94, 0, 8, 17, 5),
(95, 0, 8, 18, 5),
(96, 0, 8, 19, 5),
(97, 0, 8, 20, 5),
(98, 0, 8, 21, 5),
(99, 0, 8, 22, 5),
(100, 0, 9, 3, 27),
(101, 0, 9, 4, 54),
(102, 0, 9, 6, 21),
(103, 0, 9, 7, 48),
(104, 0, 9, 9, 15),
(105, 0, 9, 10, 42),
(106, 0, 9, 12, 9),
(107, 0, 9, 13, 36),
(108, 0, 9, 15, 3),
(109, 0, 9, 17, 30),
(110, 0, 9, 18, 57),
(111, 0, 9, 19, 24),
(112, 0, 9, 20, 51),
(113, 0, 9, 22, 18),
(114, 0, 10, 4, 43),
(115, 0, 10, 5, 43),
(116, 0, 10, 6, 43),
(117, 0, 10, 7, 43),
(118, 0, 10, 8, 43),
(119, 0, 10, 9, 43),
(120, 0, 10, 10, 43),
(121, 0, 10, 11, 43),
(122, 0, 10, 12, 43),
(123, 0, 10, 13, 43),
(124, 0, 10, 14, 43),
(125, 0, 10, 15, 43),
(126, 0, 10, 16, 43),
(127, 0, 10, 17, 43),
(128, 0, 10, 18, 43),
(129, 0, 10, 19, 43),
(130, 0, 10, 20, 43),
(131, 0, 10, 21, 43),
(132, 0, 10, 22, 43),
(133, 0, 12, 4, 28),
(134, 0, 12, 5, 31),
(135, 0, 12, 6, 34),
(136, 0, 12, 7, 37),
(137, 0, 12, 8, 40),
(138, 0, 12, 9, 43),
(139, 0, 12, 10, 46),
(140, 0, 12, 11, 49),
(141, 0, 12, 12, 52),
(142, 0, 12, 13, 55),
(143, 0, 12, 14, 58),
(144, 0, 12, 16, 1),
(145, 0, 12, 17, 4),
(146, 0, 12, 18, 7),
(147, 0, 12, 19, 10),
(148, 0, 12, 20, 13),
(149, 0, 12, 21, 16),
(150, 0, 13, 4, 1),
(151, 0, 13, 4, 41),
(152, 0, 13, 5, 21),
(153, 0, 13, 5, 1),
(154, 0, 13, 5, 41),
(155, 0, 13, 6, 21),
(156, 0, 13, 7, 1),
(157, 0, 13, 7, 41),
(158, 0, 13, 8, 21),
(159, 0, 13, 9, 1),
(160, 0, 13, 9, 41),
(161, 0, 13, 10, 21),
(162, 0, 13, 11, 1),
(163, 0, 13, 11, 41),
(164, 0, 13, 12, 21),
(165, 0, 13, 13, 1),
(166, 0, 13, 13, 41),
(167, 0, 13, 14, 21),
(168, 0, 13, 15, 1),
(169, 0, 13, 15, 41),
(170, 0, 13, 16, 21),
(171, 0, 13, 17, 1),
(172, 0, 13, 17, 41),
(173, 0, 13, 18, 21),
(174, 0, 13, 19, 1),
(175, 0, 13, 19, 41),
(176, 0, 13, 20, 21),
(177, 0, 13, 21, 1),
(178, 0, 13, 21, 41),
(179, 0, 13, 22, 21),
(180, 0, 13, 23, 1),
(181, 0, 14, 4, 44),
(182, 0, 14, 5, 28),
(183, 0, 14, 7, 12),
(184, 0, 14, 7, 56),
(185, 0, 14, 9, 40),
(186, 0, 14, 10, 24),
(187, 0, 14, 11, 8),
(188, 0, 14, 11, 52),
(189, 0, 14, 12, 36),
(190, 0, 14, 13, 20),
(191, 0, 14, 14, 4),
(192, 0, 14, 14, 48),
(193, 0, 14, 15, 32),
(194, 0, 14, 16, 16),
(195, 0, 14, 17, 0),
(196, 0, 14, 17, 44),
(197, 0, 14, 18, 28),
(198, 0, 14, 19, 12),
(199, 0, 14, 20, 56),
(200, 0, 14, 21, 40),
(201, 0, 18, 2, 0),
(202, 0, 18, 2, 30),
(203, 0, 18, 3, 0),
(204, 0, 18, 3, 30),
(205, 0, 18, 4, 0),
(206, 0, 18, 4, 30),
(207, 0, 18, 5, 0),
(208, 0, 18, 5, 30),
(209, 0, 18, 6, 0),
(210, 0, 18, 6, 30),
(211, 0, 18, 7, 0),
(212, 0, 18, 7, 30),
(213, 0, 18, 8, 0),
(214, 0, 18, 8, 30),
(215, 0, 18, 9, 0),
(216, 0, 18, 9, 30),
(217, 0, 18, 10, 0),
(218, 0, 18, 10, 30),
(219, 0, 18, 11, 0),
(220, 0, 18, 11, 30),
(221, 0, 18, 12, 0),
(222, 0, 18, 12, 30),
(223, 0, 18, 13, 0),
(224, 0, 18, 13, 30),
(225, 0, 18, 14, 0),
(226, 0, 18, 14, 30),
(227, 0, 18, 15, 0),
(228, 0, 18, 15, 30),
(229, 0, 18, 16, 0),
(230, 0, 18, 16, 30),
(231, 0, 18, 17, 0),
(232, 0, 18, 17, 30),
(233, 0, 18, 18, 0),
(234, 0, 18, 18, 30),
(235, 0, 18, 19, 0),
(236, 0, 18, 19, 30),
(237, 0, 18, 20, 0),
(238, 0, 18, 20, 30),
(239, 0, 18, 21, 0),
(240, 0, 18, 21, 30),
(241, 0, 18, 22, 0),
(242, 0, 18, 22, 30),
(243, 0, 18, 23, 0),
(244, 0, 19, 5, 8),
(245, 0, 19, 6, 8),
(246, 0, 19, 7, 8),
(247, 0, 19, 8, 8),
(248, 0, 19, 9, 8),
(249, 0, 19, 10, 8),
(250, 0, 19, 11, 8),
(251, 0, 19, 12, 8),
(252, 0, 19, 13, 8),
(253, 0, 19, 14, 8),
(254, 0, 19, 15, 8),
(255, 0, 19, 16, 8),
(256, 0, 19, 17, 8),
(257, 0, 19, 18, 8),
(258, 0, 19, 19, 8),
(259, 0, 19, 20, 8),
(260, 0, 19, 21, 8),
(261, 0, 19, 22, 8);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `linia`
--

CREATE TABLE `linia` (
  `linia_id` int(5) NOT NULL,
  `czas_calosc` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `linia`
--

INSERT INTO `linia` (`linia_id`, `czas_calosc`) VALUES
(1, 68),
(2, 58),
(4, 52),
(5, 51),
(7, 29),
(8, 40),
(9, 62),
(10, 52),
(12, 48),
(13, 22),
(14, 27),
(18, 9),
(19, 48),
(27, NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `przystanek`
--

CREATE TABLE `przystanek` (
  `przystanek_id` int(5) NOT NULL,
  `nazwa` varchar(255) NOT NULL,
  `linia_id` int(5) DEFAULT NULL,
  `minuty_nast_przyst` int(5) DEFAULT NULL,
  `przystanek_nr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `przystanek`
--

INSERT INTO `przystanek` (`przystanek_id`, `nazwa`, `linia_id`, `minuty_nast_przyst`, `przystanek_nr`) VALUES
(1, 'Bukówka', 1, 3, 1),
(2, 'Wojska Polskiego1', 1, 2, 2),
(3, 'Pileckiego1', 1, 3, 3),
(4, 'Tarnowska1', 1, 7, 4),
(5, 'Seminaryjska1', 1, 3, 5),
(6, 'Żytnia1', 1, 5, 6),
(7, 'Grunwaldzka1', 1, 5, 7),
(8, 'Jagielońska1', 1, 3, 8),
(9, 'Krakowska1', 1, 1, 9),
(10, 'Fabryczna1', 1, 2, 10),
(11, 'Dobromyśl', 1, 2, 11),
(12, 'Fabryczna2', 1, 1, 12),
(13, 'Krakowska2', 1, 3, 13),
(14, 'Jagielońska2', 1, 5, 14),
(15, 'Grunwaldzka2', 1, 5, 15),
(16, 'Żytnia2', 1, 3, 16),
(17, 'Seminaryjska2', 1, 7, 17),
(18, 'Tarnowska2', 1, 3, 18),
(19, 'Pileckiego2', 1, 2, 19),
(20, 'Wojska Polskiego2', 1, 3, 20),
(21, 'Kolberga', 2, 3, 1),
(22, 'Hoża2', 2, 3, 2),
(23, 'Jagielońska2', 2, 4, 3),
(24, 'Grunwaldzka2', 2, 5, 4),
(25, 'Żytnia2', 2, 8, 5),
(26, 'Ściegiennego2', 2, 3, 6),
(27, 'Leśniówka2', 2, 2, 7),
(28, 'Krakowska2', 2, 1, 8),
(29, 'Chorzowska', 2, 1, 9),
(30, 'Krakowska1', 2, 2, 10),
(31, 'Leśniówka1', 2, 3, 11),
(32, 'Ściegiennego1', 2, 8, 12),
(33, 'Żytnia1', 2, 5, 13),
(34, 'Grunwaldzka1', 2, 4, 14),
(35, 'Jagielońska1', 2, 3, 15),
(36, 'Hoża1', 2, 3, 16),
(37, 'Stadion', 4, 1, 1),
(38, 'Szczepaniaka2', 4, 3, 2),
(39, 'Pakosz2', 4, 2, 3),
(40, 'Osobna2', 4, 4, 4),
(41, 'Krakowska2', 4, 6, 5),
(42, 'Jana Pawła II_2', 4, 3, 6),
(43, 'Seminaryjska2', 4, 2, 7),
(44, 'Tarnowska2', 4, 4, 8),
(45, 'Zagnańska2', 4, 1, 9),
(46, 'Sieje', 4, 1, 10),
(47, 'Zagnańska1', 4, 4, 11),
(48, 'Tarnowska1', 4, 2, 12),
(49, 'Seminaryjska1', 4, 3, 13),
(50, 'Jana Pawła II_1', 4, 6, 14),
(51, 'Krakowska1', 4, 4, 15),
(52, 'Osobna1', 4, 2, 16),
(53, 'Pakosz1', 4, 3, 17),
(54, 'Szczepaniaka1', 4, 1, 18),
(55, 'Pilotów', 5, 2, 1),
(57, 'Warszawska1', 5, 5, 2),
(58, 'Sikorskiego1', 5, 6, 3),
(59, 'Grunwaldzka1', 5, 3, 4),
(60, 'Zagnańska1', 5, 10, 5),
(61, 'Zalesie', 5, 10, 6),
(62, 'Zagnańska2', 5, 3, 7),
(63, 'Grunwaldzka2', 5, 6, 8),
(64, 'Sikorskiego2', 5, 5, 9),
(65, 'Warszawska2', 5, 1, 10),
(67, 'Dworzec', 7, 2, 1),
(70, 'Zagnańska1', 7, 2, 2),
(72, 'Fabryczna1', 7, 5, 3),
(73, 'Dąbrowa1', 7, 2, 4),
(75, 'Samsonów', 7, 1, 5),
(77, 'Dąbrowa2', 7, 7, 6),
(78, 'Fabryczna2', 7, 5, 7),
(80, 'Zagnańska2', 7, 5, 8),
(83, 'Bukówka', 8, 2, 1),
(84, 'Wojska Polskiego1', 8, 2, 2),
(85, 'Pileckiego1', 8, 4, 3),
(86, 'Tarnowska1', 8, 5, 4),
(87, 'Seminaryjska1', 8, 7, 5),
(88, 'Jana Pawła II_1', 8, 7, 6),
(89, 'Seminaryjska2', 8, 5, 7),
(90, 'Tarnowska2', 8, 4, 8),
(91, 'Pileckiego2', 8, 2, 9),
(92, 'Wojska Polskiego2', 8, 2, 10),
(93, 'Kolberga', 9, 3, 1),
(94, 'Hoża2', 9, 3, 2),
(95, 'Jagielońska2', 9, 4, 3),
(96, 'Grunwaldzka2', 9, 5, 4),
(97, 'Żytnia2', 9, 5, 5),
(98, 'Seminaryjska2', 9, 3, 6),
(99, 'Tarnowska2', 9, 1, 7),
(100, 'Pileckiego2', 9, 3, 8),
(101, 'Wojska Polskiego2', 9, 2, 9),
(102, 'Bukówka', 9, 2, 10),
(103, 'Wojska Polskiego1', 9, 3, 11),
(104, 'Pileckiego1', 9, 7, 12),
(105, 'Tarnowska1', 9, 1, 13),
(106, 'Seminaryjska1', 9, 5, 14),
(107, 'Żytnia1', 9, 5, 15),
(108, 'Grunwaldzka1', 9, 4, 16),
(109, 'Jagielońska1', 9, 3, 17),
(110, 'Hoża1', 9, 3, 18),
(111, 'Kolberga', 10, 3, 1),
(112, 'Hoża2', 10, 3, 2),
(113, 'Jagielońska2', 10, 4, 3),
(114, 'Grunwaldzka2', 10, 5, 4),
(115, 'Żytnia2', 10, 5, 5),
(116, 'Ściegiennego2', 10, 3, 6),
(117, 'Leśniówka2', 10, 1, 7),
(118, 'Krakowska2', 10, 2, 8),
(119, 'Chorzowska', 10, 2, 9),
(120, 'Krakowska1', 10, 1, 10),
(121, 'Leśniówka1', 10, 3, 11),
(122, 'Ściegiennego1', 10, 5, 12),
(123, 'Żytnia1', 10, 5, 13),
(124, 'Grunwaldzka1', 10, 4, 14),
(125, 'Jagielońska1', 10, 3, 15),
(126, 'Hoża1', 10, 3, 16),
(127, 'Bukówka', 12, 3, 1),
(128, 'Wojska Polskiego1', 12, 2, 2),
(129, 'Pileckiego1', 12, 4, 3),
(130, 'Tarnowska1', 12, 5, 4),
(131, 'Zagnańska2', 12, 10, 5),
(132, 'Sieje', 12, 10, 6),
(133, 'Zagnańska1', 12, 5, 7),
(134, 'Tarnowska2', 12, 4, 8),
(135, 'Pileckiego2', 12, 2, 9),
(136, 'Wojska Polskiego2', 12, 3, 10),
(137, 'Stadion', 13, 1, 1),
(138, 'Szczepaniaka2', 13, 3, 2),
(139, 'Pakosz2', 13, 2, 3),
(140, 'Osobna2', 13, 4, 4),
(141, 'Krakowska2', 13, 1, 5),
(142, 'Chorzowska', 13, 1, 6),
(143, 'Krakowska1', 13, 4, 7),
(144, 'Osobna1', 13, 2, 8),
(145, 'Pakosz1', 13, 3, 9),
(146, 'Szczepaniaka1', 13, 1, 10),
(147, 'Kolberga', 14, 3, 1),
(148, 'Hoża2', 14, 3, 2),
(149, 'Jagielońska2', 14, 4, 3),
(150, 'Grunwaldzka2', 14, 5, 4),
(151, 'Żytnia2', 14, 1, 5),
(152, 'Grunwaldzka1', 14, 4, 6),
(153, 'Jagielońska1', 14, 3, 7),
(154, 'Hoża1', 14, 3, 8),
(155, 'Chorzowska', 18, 1, 1),
(156, 'Krakowska1', 18, 1, 2),
(157, 'Leśniówka1', 18, 2, 3),
(158, 'Ściegiennego1', 18, 1, 4),
(159, 'Żytnia1', 14, 1, 5),
(160, 'Ściegiennego2', 18, 2, 6),
(161, 'Leśniówka2', 18, 1, 7),
(162, 'Krakowska2', 18, 1, 8),
(163, 'Pilotów', 19, 2, 1),
(164, 'Dywizjonu 303_1', 19, 1, 2),
(165, 'Warszawska1', 19, 5, 3),
(166, 'Sikorskiego1', 19, 6, 4),
(167, 'Jaworskiego1', 19, 3, 5),
(168, 'Zagnańska1', 19, 7, 6),
(169, 'Zalesie', 19, 7, 7),
(170, 'Zagnańska2', 19, 3, 8),
(171, 'Jaworskiego2', 19, 6, 9),
(172, 'Sikorskiego2', 19, 5, 10),
(173, 'Warszawska2', 19, 1, 11),
(174, 'Dywizjonu 303_2', 19, 2, 12);

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `kierowca`
--
ALTER TABLE `kierowca`
  ADD PRIMARY KEY (`kierowca_id`),
  ADD KEY `linia_id` (`linia_id`);

--
-- Indeksy dla tabeli `linia`
--
ALTER TABLE `linia`
  ADD PRIMARY KEY (`linia_id`);

--
-- Indeksy dla tabeli `przystanek`
--
ALTER TABLE `przystanek`
  ADD PRIMARY KEY (`przystanek_id`),
  ADD KEY `linia_id` (`linia_id`);

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `kierowca`
--
ALTER TABLE `kierowca`
  ADD CONSTRAINT `kierowca_ibfk_1` FOREIGN KEY (`linia_id`) REFERENCES `linia` (`linia_id`);

--
-- Ograniczenia dla tabeli `przystanek`
--
ALTER TABLE `przystanek`
  ADD CONSTRAINT `przystanek_ibfk_1` FOREIGN KEY (`linia_id`) REFERENCES `linia` (`linia_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
