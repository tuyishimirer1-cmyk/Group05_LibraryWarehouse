-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 06, 2026 at 06:58 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `library_analytics_dw`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `cs_department_view`
-- (See below for the actual view)
--
CREATE TABLE `cs_department_view` (
`masked_student_id` varchar(11)
,`department_standardized` varchar(50)
,`loan_count` int(11)
,`download_count` int(11)
,`booking_count` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `dim_date`
--

CREATE TABLE `dim_date` (
  `date_key` int(11) NOT NULL,
  `full_date` date NOT NULL,
  `day` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `month_name` varchar(20) DEFAULT NULL,
  `quarter` int(11) DEFAULT NULL,
  `quarter_name` varchar(10) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `day_of_week` varchar(20) DEFAULT NULL,
  `is_weekend` tinyint(1) DEFAULT NULL,
  `is_holiday` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dim_date`
--

INSERT INTO `dim_date` (`date_key`, `full_date`, `day`, `month`, `month_name`, `quarter`, `quarter_name`, `year`, `day_of_week`, `is_weekend`, `is_holiday`) VALUES
(20240104, '2024-01-04', 4, 1, 'January', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240105, '2024-01-05', 5, 1, 'January', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240106, '2024-01-06', 6, 1, 'January', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240107, '2024-01-07', 7, 1, 'January', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240108, '2024-01-08', 8, 1, 'January', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240109, '2024-01-09', 9, 1, 'January', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240110, '2024-01-10', 10, 1, 'January', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240111, '2024-01-11', 11, 1, 'January', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240112, '2024-01-12', 12, 1, 'January', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240113, '2024-01-13', 13, 1, 'January', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240114, '2024-01-14', 14, 1, 'January', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240115, '2024-01-15', 15, 1, 'January', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240116, '2024-01-16', 16, 1, 'January', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240117, '2024-01-17', 17, 1, 'January', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240118, '2024-01-18', 18, 1, 'January', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240119, '2024-01-19', 19, 1, 'January', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240120, '2024-01-20', 20, 1, 'January', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240121, '2024-01-21', 21, 1, 'January', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240122, '2024-01-22', 22, 1, 'January', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240123, '2024-01-23', 23, 1, 'January', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240124, '2024-01-24', 24, 1, 'January', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240125, '2024-01-25', 25, 1, 'January', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240126, '2024-01-26', 26, 1, 'January', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240127, '2024-01-27', 27, 1, 'January', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240128, '2024-01-28', 28, 1, 'January', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240129, '2024-01-29', 29, 1, 'January', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240130, '2024-01-30', 30, 1, 'January', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240131, '2024-01-31', 31, 1, 'January', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240201, '2024-02-01', 1, 2, 'February', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240202, '2024-02-02', 2, 2, 'February', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240203, '2024-02-03', 3, 2, 'February', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240204, '2024-02-04', 4, 2, 'February', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240205, '2024-02-05', 5, 2, 'February', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240206, '2024-02-06', 6, 2, 'February', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240207, '2024-02-07', 7, 2, 'February', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240208, '2024-02-08', 8, 2, 'February', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240209, '2024-02-09', 9, 2, 'February', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240210, '2024-02-10', 10, 2, 'February', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240211, '2024-02-11', 11, 2, 'February', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240212, '2024-02-12', 12, 2, 'February', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240213, '2024-02-13', 13, 2, 'February', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240214, '2024-02-14', 14, 2, 'February', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240215, '2024-02-15', 15, 2, 'February', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240216, '2024-02-16', 16, 2, 'February', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240217, '2024-02-17', 17, 2, 'February', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240218, '2024-02-18', 18, 2, 'February', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240219, '2024-02-19', 19, 2, 'February', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240220, '2024-02-20', 20, 2, 'February', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240221, '2024-02-21', 21, 2, 'February', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240222, '2024-02-22', 22, 2, 'February', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240223, '2024-02-23', 23, 2, 'February', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240224, '2024-02-24', 24, 2, 'February', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240225, '2024-02-25', 25, 2, 'February', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240226, '2024-02-26', 26, 2, 'February', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240227, '2024-02-27', 27, 2, 'February', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240228, '2024-02-28', 28, 2, 'February', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240229, '2024-02-29', 29, 2, 'February', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240301, '2024-03-01', 1, 3, 'March', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240302, '2024-03-02', 2, 3, 'March', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240303, '2024-03-03', 3, 3, 'March', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240304, '2024-03-04', 4, 3, 'March', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240305, '2024-03-05', 5, 3, 'March', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240306, '2024-03-06', 6, 3, 'March', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240307, '2024-03-07', 7, 3, 'March', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240308, '2024-03-08', 8, 3, 'March', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240309, '2024-03-09', 9, 3, 'March', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240310, '2024-03-10', 10, 3, 'March', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240311, '2024-03-11', 11, 3, 'March', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240312, '2024-03-12', 12, 3, 'March', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240313, '2024-03-13', 13, 3, 'March', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240314, '2024-03-14', 14, 3, 'March', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240315, '2024-03-15', 15, 3, 'March', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240316, '2024-03-16', 16, 3, 'March', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240317, '2024-03-17', 17, 3, 'March', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240318, '2024-03-18', 18, 3, 'March', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240319, '2024-03-19', 19, 3, 'March', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240320, '2024-03-20', 20, 3, 'March', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240321, '2024-03-21', 21, 3, 'March', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240322, '2024-03-22', 22, 3, 'March', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240323, '2024-03-23', 23, 3, 'March', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240324, '2024-03-24', 24, 3, 'March', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240325, '2024-03-25', 25, 3, 'March', 1, 'Q1', 2024, 'Monday', 0, 0),
(20240326, '2024-03-26', 26, 3, 'March', 1, 'Q1', 2024, 'Tuesday', 0, 0),
(20240327, '2024-03-27', 27, 3, 'March', 1, 'Q1', 2024, 'Wednesday', 0, 0),
(20240328, '2024-03-28', 28, 3, 'March', 1, 'Q1', 2024, 'Thursday', 0, 0),
(20240329, '2024-03-29', 29, 3, 'March', 1, 'Q1', 2024, 'Friday', 0, 0),
(20240330, '2024-03-30', 30, 3, 'March', 1, 'Q1', 2024, 'Saturday', 1, 0),
(20240331, '2024-03-31', 31, 3, 'March', 1, 'Q1', 2024, 'Sunday', 1, 0),
(20240401, '2024-04-01', 1, 4, 'April', 2, 'Q2', 2024, 'Monday', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `dim_location`
--

CREATE TABLE `dim_location` (
  `location_key` int(11) NOT NULL,
  `room_number_standardized` varchar(10) DEFAULT NULL,
  `room_type` varchar(20) DEFAULT NULL,
  `building` varchar(50) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dim_location`
--

INSERT INTO `dim_location` (`location_key`, `room_number_standardized`, `room_type`, `building`, `capacity`) VALUES
(109, 'UNKNOWN', 'Unknown', 'Unknown', 0),
(110, 'R101', 'Study Room', 'Main Library', 10),
(111, 'R-102', 'Study Room', 'Main Library', 10),
(112, 'Room201', 'Study Room', 'Main Library', 10),
(113, 'Room101', 'Study Room', 'Main Library', 10),
(114, 'R201', 'Study Room', 'Main Library', 10),
(115, 'R-201', 'Study Room', 'Main Library', 10),
(116, 'R102', 'Study Room', 'Main Library', 10),
(117, 'R-101', 'Study Room', 'Main Library', 10),
(118, 'Room102', 'Study Room', 'Main Library', 10),
(119, 'R-202', 'Study Room', 'Main Library', 10);

-- --------------------------------------------------------

--
-- Table structure for table `dim_resource`
--

CREATE TABLE `dim_resource` (
  `resource_key` int(11) NOT NULL,
  `resource_id` varchar(50) DEFAULT NULL,
  `resource_type` varchar(20) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `is_digital` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dim_resource`
--

INSERT INTO `dim_resource` (`resource_key`, `resource_id`, `resource_type`, `category`, `title`, `is_digital`) VALUES
(149, 'UNKNOWN', 'Unknown', 'Unknown', 'Unknown Resource', 0),
(150, '978-0134685991', 'Physical Book', 'Textbook', 'Book 978-0134685991', 0),
(151, '978-0133970777', 'Physical Book', 'Textbook', 'Book 978-0133970777', 0),
(152, '978-0262033848', 'Physical Book', 'Textbook', 'Book 978-0262033848', 0),
(153, '978-1982100551', 'Physical Book', 'Fiction', 'Book 978-1982100551', 0),
(154, '978-1234567890', 'Physical Book', 'Reference', 'Book 978-1234567890', 0),
(155, '978-0451524935', 'Physical Book', 'Fiction', 'Book 978-0451524935', 0),
(156, '978-0141439518', 'Physical Book', 'Literature', 'Book 978-0141439518', 0),
(157, '978-0590353403', 'Physical Book', 'Fiction', 'Book 978-0590353403', 0),
(158, '978-0439064873', 'Physical Book', 'Fiction', 'Book 978-0439064873', 0),
(159, '978-0743273565', 'Physical Book', 'Biography', 'Book 978-0743273565', 0),
(160, '978-0316769174', 'Physical Book', 'Literature', 'Book 978-0316769174', 0),
(161, 'DIG-001', 'E-book', 'Digital', 'E-book Resource', 1),
(162, 'DIG-002', 'Journal', 'Digital', 'Journal Resource', 1),
(163, 'DIG-003', 'Article', 'Digital', 'Article Resource', 1);

-- --------------------------------------------------------

--
-- Table structure for table `dim_student`
--

CREATE TABLE `dim_student` (
  `student_key` int(11) NOT NULL,
  `student_id` varchar(20) DEFAULT NULL,
  `department_standardized` varchar(50) DEFAULT NULL,
  `student_level` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dim_student`
--

INSERT INTO `dim_student` (`student_key`, `student_id`, `department_standardized`, `student_level`, `is_active`) VALUES
(196, 'FAC-2024-001', 'Computer Science', 'Undergraduate', 1),
(197, 'FAC-2024-002', 'Engineering', 'Undergraduate', 1),
(198, 'STU-2024-001', 'Computer Science', 'Undergraduate', 1),
(199, 'STU-2024-002', 'Computer Science', 'Undergraduate', 1),
(200, 'STU-2024-003', 'Computer Science', 'Undergraduate', 1),
(201, 'STU-2024-004', 'Engineering', 'Undergraduate', 1),
(202, 'STU-2024-005', 'Engineering', 'Undergraduate', 1),
(203, 'STU-2024-006', 'Business', 'Undergraduate', 1),
(204, 'STU-2024-007', 'Business', 'Undergraduate', 1),
(205, 'STU-2024-008', 'Computer Science', 'Undergraduate', 1),
(206, 'STU-2024-009', 'Computer Science', 'Undergraduate', 1),
(207, 'STU-2024-010', 'Business', 'Undergraduate', 1),
(208, 'STU-2024-011', 'Engineering', 'Undergraduate', 1),
(209, 'STU-2024-012', 'Business', 'Undergraduate', 1);

-- --------------------------------------------------------

--
-- Table structure for table `dim_time_slot`
--

CREATE TABLE `dim_time_slot` (
  `time_slot_key` int(11) NOT NULL,
  `time_slot_standardized` varchar(20) DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dim_time_slot`
--

INSERT INTO `dim_time_slot` (`time_slot_key`, `time_slot_standardized`, `start_time`, `end_time`) VALUES
(69, 'UNKNOWN', '00:00:00', '00:00:00'),
(70, 'Morning', '00:00:00', '00:00:00'),
(71, '8AM-10AM', '00:00:08', '00:00:10'),
(72, 'Evening', '00:00:00', '00:00:00'),
(73, '12PM-2PM', '00:00:12', '00:00:02'),
(74, 'Night', '00:00:00', '00:00:00'),
(75, 'Afternoon', '00:00:00', '00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `fact_library_usage`
--

CREATE TABLE `fact_library_usage` (
  `usage_key` bigint(20) NOT NULL,
  `date_key` int(11) NOT NULL,
  `student_key` int(11) DEFAULT NULL,
  `resource_key` int(11) DEFAULT NULL,
  `location_key` int(11) DEFAULT NULL,
  `time_slot_key` int(11) DEFAULT NULL,
  `loan_count` int(11) DEFAULT 0,
  `download_count` int(11) DEFAULT 0,
  `booking_count` int(11) DEFAULT 0,
  `loan_duration_days` int(11) DEFAULT NULL,
  `download_duration_minutes` int(11) DEFAULT NULL,
  `booking_duration_hours` decimal(5,2) DEFAULT NULL,
  `source_system` varchar(20) DEFAULT NULL,
  `original_transaction_id` varchar(50) DEFAULT NULL,
  `created_timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fact_library_usage`
--

INSERT INTO `fact_library_usage` (`usage_key`, `date_key`, `student_key`, `resource_key`, `location_key`, `time_slot_key`, `loan_count`, `download_count`, `booking_count`, `loan_duration_days`, `download_duration_minutes`, `booking_duration_hours`, `source_system`, `original_transaction_id`, `created_timestamp`) VALUES
(155, 20240115, 198, 150, 109, 69, 1, 0, 0, 14, NULL, NULL, 'BOOK', '1001', '2026-02-03 12:46:37'),
(156, 20240115, 199, 151, 109, 69, 1, 0, 0, 0, NULL, NULL, 'BOOK', '1002', '2026-02-03 12:46:37'),
(157, 20240116, 200, 152, 109, 69, 1, 0, 0, 21, NULL, NULL, 'BOOK', '1003', '2026-02-03 12:46:37'),
(158, 20240201, 201, 153, 109, 69, 1, 0, 0, 9, NULL, NULL, 'BOOK', '1004', '2026-02-03 12:46:37'),
(159, 20240205, 202, 154, 109, 69, 1, 0, 0, 7, NULL, NULL, 'BOOK', '1005', '2026-02-03 12:46:37'),
(160, 20240210, 203, 155, 109, 69, 1, 0, 0, 10, NULL, NULL, 'BOOK', '1006', '2026-02-03 12:46:37'),
(161, 20240215, 204, 156, 109, 69, 1, 0, 0, 0, NULL, NULL, 'BOOK', '1007', '2026-02-03 12:46:37'),
(162, 20240301, 198, 150, 109, 69, 1, 0, 0, 14, NULL, NULL, 'BOOK', '1008', '2026-02-03 12:46:37'),
(163, 20240305, 205, 157, 109, 69, 1, 0, 0, 7, NULL, NULL, 'BOOK', '1009', '2026-02-03 12:46:37'),
(164, 20240310, 206, 158, 109, 69, 1, 0, 0, 0, NULL, NULL, 'BOOK', '1010', '2026-02-03 12:46:37'),
(165, 20240104, 196, 151, 109, 69, 1, 0, 0, 30, NULL, NULL, 'BOOK', '1011', '2026-02-03 12:46:37'),
(166, 20240201, 197, 152, 109, 69, 1, 0, 0, 29, NULL, NULL, 'BOOK', '1012', '2026-02-03 12:46:37'),
(167, 20240315, 207, 159, 109, 69, 1, 0, 0, 7, NULL, NULL, 'BOOK', '1013', '2026-02-03 12:46:37'),
(168, 20240320, 208, 160, 109, 69, 1, 0, 0, 0, NULL, NULL, 'BOOK', '1014', '2026-02-03 12:46:37'),
(169, 20240325, 209, 155, 109, 69, 1, 0, 0, 7, NULL, NULL, 'BOOK', '1015', '2026-02-03 12:46:37'),
(170, 20240115, NULL, 161, 109, 69, 0, 1, 0, NULL, 45, NULL, 'DIGITAL', '2024-01-15-E-book-Student', '2026-02-03 12:46:37'),
(171, 20240116, NULL, 161, 109, 69, 0, 1, 0, NULL, 90, NULL, 'DIGITAL', '2024-01-16-e-Book-Graduate Student', '2026-02-03 12:46:37'),
(172, 20240210, NULL, 161, 109, 69, 0, 1, 0, NULL, NULL, NULL, 'DIGITAL', '02/10/2024-E-book-Student', '2026-02-03 12:46:37'),
(173, 20240220, NULL, 161, 109, 69, 0, 1, 0, NULL, 45, NULL, 'DIGITAL', '2024-02-20-E-book-Staff', '2026-02-03 12:46:37'),
(174, 20240301, NULL, 161, 109, 69, 0, 1, 0, NULL, 30, NULL, 'DIGITAL', '03/01/2024-e-Book-Student', '2026-02-03 12:46:37'),
(175, 20240315, NULL, 161, 109, 69, 0, 1, 0, NULL, 60, NULL, 'DIGITAL', 'Mar 15, 2024-E-book-Student', '2026-02-03 12:46:37'),
(176, 20240320, NULL, 161, 109, 69, 0, 1, 0, NULL, 90, NULL, 'DIGITAL', '2024-03-20-e-Book-Graduate Student', '2026-02-03 12:46:37'),
(177, 20240201, NULL, 162, 109, 69, 0, 3, 0, NULL, 120, NULL, 'DIGITAL', '2024-02-01-Journal-Student', '2026-02-03 12:46:37'),
(178, 20240115, NULL, 162, 109, 69, 0, 1, 0, NULL, 30, NULL, 'DIGITAL', 'Jan 15, 2024-Journal-Faculty', '2026-02-03 12:46:37'),
(179, 20240225, NULL, 162, 109, 69, 0, 2, 0, NULL, 90, NULL, 'DIGITAL', 'Feb 25, 2024-Journal-Graduate Student', '2026-02-03 12:46:37'),
(180, 20240310, NULL, 162, 109, 69, 0, 2, 0, NULL, NULL, NULL, 'DIGITAL', '2024-03-10-Journal-Student', '2026-02-03 12:46:37'),
(181, 20240325, NULL, 162, 109, 69, 0, 1, 0, NULL, 45, NULL, 'DIGITAL', '2024-03-25-Journal-Staff', '2026-02-03 12:46:37'),
(182, 20240305, NULL, 163, 109, 69, 0, 1, 0, NULL, 45, NULL, 'DIGITAL', '2024-03-05-Article-Faculty', '2026-02-03 12:46:37'),
(183, 20240315, 198, 149, 110, 70, 0, 0, 1, NULL, NULL, 2.00, 'ROOM', '5001', '2026-02-03 12:46:37'),
(184, 20240315, 199, 149, 111, 71, 0, 0, 1, NULL, NULL, 2.00, 'ROOM', '5002', '2026-02-03 12:46:37'),
(185, 20240320, 203, 149, 112, 72, 0, 0, 1, NULL, NULL, 4.00, 'ROOM', '5003', '2026-02-03 12:46:37'),
(186, 20240212, 198, 149, 110, 73, 0, 0, 1, NULL, NULL, 2.00, 'ROOM', '5004', '2026-02-03 12:46:37'),
(187, 20240315, 198, 149, 110, 70, 0, 0, 1, NULL, NULL, 2.00, 'ROOM', '5006', '2026-02-03 12:46:37'),
(188, 20240316, 200, 149, 111, 75, 0, 0, 1, NULL, NULL, 3.00, 'ROOM', '5007', '2026-02-03 12:46:37'),
(189, 20240317, 201, 149, 113, 72, 0, 0, 1, NULL, NULL, 2.50, 'ROOM', '5008', '2026-02-03 12:46:37'),
(190, 20240318, 202, 149, 114, 70, 0, 0, 1, NULL, NULL, 1.00, 'ROOM', '5009', '2026-02-03 12:46:37'),
(191, 20240319, 204, 149, 115, 75, 0, 0, 1, NULL, NULL, 4.00, 'ROOM', '5010', '2026-02-03 12:46:37'),
(192, 20240320, 205, 149, 116, 72, 0, 0, 1, NULL, NULL, 3.00, 'ROOM', '5011', '2026-02-03 12:46:37'),
(193, 20240322, 206, 149, 118, 70, 0, 0, 1, NULL, NULL, 1.50, 'ROOM', '5013', '2026-02-03 12:46:37'),
(194, 20240323, 207, 149, 114, 75, 0, 0, 1, NULL, NULL, 3.00, 'ROOM', '5014', '2026-02-03 12:46:37'),
(195, 20240324, 208, 149, 119, 72, 0, 0, 1, NULL, NULL, 2.00, 'ROOM', '5015', '2026-02-03 12:46:37');

-- --------------------------------------------------------

--
-- Stand-in structure for view `masked_student_data`
-- (See below for the actual view)
--
CREATE TABLE `masked_student_data` (
`masked_student_id` varchar(11)
,`department_standardized` varchar(50)
,`loan_count` int(11)
,`download_count` int(11)
,`booking_count` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `staging_book_transactions`
--

CREATE TABLE `staging_book_transactions` (
  `staging_id` int(11) NOT NULL,
  `TransactionID` int(11) DEFAULT NULL,
  `StudentID` varchar(20) DEFAULT NULL,
  `BookISBN` varchar(20) DEFAULT NULL,
  `CheckoutDate` varchar(50) DEFAULT NULL,
  `ReturnDate` varchar(50) DEFAULT NULL,
  `Department` varchar(50) DEFAULT NULL,
  `BookCategory` varchar(50) DEFAULT NULL,
  `load_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `source_file` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staging_book_transactions`
--

INSERT INTO `staging_book_transactions` (`staging_id`, `TransactionID`, `StudentID`, `BookISBN`, `CheckoutDate`, `ReturnDate`, `Department`, `BookCategory`, `load_timestamp`, `source_file`) VALUES
(1, 1001, 'STU-2024-001', '978-0134685991', '2024-01-15', '2024-01-29', 'Computer Science', 'Textbook', '2026-02-03 10:30:58', 'book_transactions.csv'),
(2, 1002, 'STU-2024-002', '978-0133970777', '2024-01-15', NULL, 'Computer Science', 'Textbook', '2026-02-03 10:30:58', 'book_transactions.csv'),
(3, 1003, 'STU-2024-003', '978-0262033848', '2024-01-16', '2024-02-06', 'Computer Science', 'Textbook', '2026-02-03 10:30:58', 'book_transactions.csv'),
(4, 1004, 'STU-2024-004', '978-1982100551', '2024-02-01', '2024-02-10', 'Engineering', 'Fiction', '2026-02-03 10:30:58', 'book_transactions.csv'),
(5, 1005, 'STU-2024-005', '978-1234567890', '2024-02-05', '2024-02-12', 'Engineering', 'Reference', '2026-02-03 10:30:58', 'book_transactions.csv'),
(6, 1006, 'STU-2024-006', '978-0451524935', '2024-02-10', '2024-02-20', 'Business', 'Fiction', '2026-02-03 10:30:58', 'book_transactions.csv'),
(7, 1007, 'STU-2024-007', '978-0141439518', '2024-02-15', NULL, 'Business', 'Literature', '2026-02-03 10:30:58', 'book_transactions.csv'),
(8, 1008, 'STU-2024-001', '978-0134685991', '2024-03-01', '2024-03-15', 'Computer Science', 'Textbook', '2026-02-03 10:30:58', 'book_transactions.csv'),
(9, 1009, 'STU-2024-008', '978-0590353403', '2024-03-05', '2024-03-12', 'Computer Science', 'Fiction', '2026-02-03 10:30:58', 'book_transactions.csv'),
(10, 1010, 'STU-2024-009', '978-0439064873', '2024-03-10', NULL, 'Computer Science', 'Fiction', '2026-02-03 10:30:58', 'book_transactions.csv'),
(11, 1011, 'FAC-2024-001', '978-0133970777', '2024-01-04', '2024-02-03', 'Computer Science', 'Textbook', '2026-02-03 10:30:58', 'book_transactions.csv'),
(12, 1012, 'FAC-2024-002', '978-0262033848', '2024-02-01', '2024-03-01', 'Engineering', 'Textbook', '2026-02-03 10:30:58', 'book_transactions.csv'),
(13, 1013, 'STU-2024-010', '978-0743273565', '2024-03-15', '2024-03-22', 'Business', 'Biography', '2026-02-03 10:30:58', 'book_transactions.csv'),
(14, 1014, 'STU-2024-011', '978-0316769174', '2024-03-20', NULL, 'Engineering', 'Literature', '2026-02-03 10:30:58', 'book_transactions.csv'),
(15, 1015, 'STU-2024-012', '978-0451524935', '2024-03-25', '2024-04-01', 'Business', 'Fiction', '2026-02-03 10:30:58', 'book_transactions.csv');

-- --------------------------------------------------------

--
-- Table structure for table `staging_digital_usage`
--

CREATE TABLE `staging_digital_usage` (
  `staging_id` int(11) NOT NULL,
  `Date` varchar(50) DEFAULT NULL,
  `UserType` varchar(50) DEFAULT NULL,
  `ResourceType` varchar(50) DEFAULT NULL,
  `Faculty` varchar(50) DEFAULT NULL,
  `DownloadCount` int(11) DEFAULT NULL,
  `Duration_Minutes` int(11) DEFAULT NULL,
  `load_timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staging_digital_usage`
--

INSERT INTO `staging_digital_usage` (`staging_id`, `Date`, `UserType`, `ResourceType`, `Faculty`, `DownloadCount`, `Duration_Minutes`, `load_timestamp`) VALUES
(1, '2024-01-15', 'Student', 'E-book', 'ENG', 1, 45, '2026-02-03 10:30:59'),
(2, '2024-01-16', 'Graduate Student', 'e-Book', 'Engineering', 1, 90, '2026-02-03 10:30:59'),
(3, '2024-02-01', 'Student', 'Journal', 'Engr', 3, 120, '2026-02-03 10:30:59'),
(4, 'Jan 15, 2024', 'Faculty', 'Journal', 'CS', 1, 30, '2026-02-03 10:30:59'),
(5, '02/10/2024', 'Student', 'E-book', 'CS', 1, NULL, '2026-02-03 10:30:59'),
(6, '2024-15-02', 'Student', 'Article', 'BUS', 2, 60, '2026-02-03 10:30:59'),
(7, '2024-02-20', 'Staff', 'E-book', 'CS', 1, 45, '2026-02-03 10:30:59'),
(8, 'Feb 25, 2024', 'Graduate Student', 'Journal', 'Engineering', 2, 90, '2026-02-03 10:30:59'),
(9, '03/01/2024', 'Student', 'e-Book', 'BUS', 1, 30, '2026-02-03 10:30:59'),
(10, '2024-03-05', 'Faculty', 'Article', 'ENG', 1, 45, '2026-02-03 10:30:59'),
(11, '2024-03-10', 'Student', 'Journal', 'Business', 2, NULL, '2026-02-03 10:30:59'),
(12, 'Mar 15, 2024', 'Student', 'E-book', 'CS', 1, 60, '2026-02-03 10:30:59'),
(13, '2024-03-20', 'Graduate Student', 'e-Book', 'ENG', 1, 90, '2026-02-03 10:30:59'),
(14, '2024-03-25', 'Staff', 'Journal', 'CS', 1, 45, '2026-02-03 10:30:59');

-- --------------------------------------------------------

--
-- Table structure for table `staging_room_bookings`
--

CREATE TABLE `staging_room_bookings` (
  `staging_id` int(11) NOT NULL,
  `BookingID` int(11) DEFAULT NULL,
  `RoomNumber` varchar(10) DEFAULT NULL,
  `BookingDate` varchar(50) DEFAULT NULL,
  `TimeSlot` varchar(20) DEFAULT NULL,
  `StudentID` varchar(20) DEFAULT NULL,
  `DurationHours` decimal(5,2) DEFAULT NULL,
  `Purpose` varchar(50) DEFAULT NULL,
  `load_timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staging_room_bookings`
--

INSERT INTO `staging_room_bookings` (`staging_id`, `BookingID`, `RoomNumber`, `BookingDate`, `TimeSlot`, `StudentID`, `DurationHours`, `Purpose`, `load_timestamp`) VALUES
(1, 5001, 'R101', '2024-03-15', 'Morning', 'STU-2024-001', 2.00, 'Study', '2026-02-03 10:30:59'),
(2, 5002, 'R102', '2024-03-15', '8AM-10AM', 'STU-2024-002', 2.00, 'Group Project', '2026-02-03 10:30:59'),
(3, 5003, 'R201', '2024-03-20', 'Evening', 'STU-2024-006', 4.00, 'Meeting', '2026-02-03 10:30:59'),
(4, 5004, 'R101', '2024-02-12', '12PM-2PM', 'STU-2024-001', 2.00, 'Study', '2026-02-03 10:30:59'),
(5, 5005, 'R101', '15-Mar-2024', 'Night', NULL, 1.50, 'Study', '2026-02-03 10:30:59'),
(6, 5006, 'R101', '2024-03-15', 'Morning', 'STU-2024-001', 2.00, 'Study', '2026-02-03 10:30:59'),
(7, 5007, 'R102', '2024-03-16', 'Afternoon', 'STU-2024-003', 3.00, 'Research', '2026-02-03 10:30:59'),
(8, 5008, 'R101', '2024-03-17', 'Evening', 'STU-2024-004', 2.50, 'Group Study', '2026-02-03 10:30:59'),
(9, 5009, 'R201', '2024-03-18', 'Morning', 'STU-2024-005', 1.00, 'Interview Prep', '2026-02-03 10:30:59'),
(10, 5010, 'R201', '2024-03-19', 'Afternoon', 'STU-2024-007', 4.00, 'Thesis Writing', '2026-02-03 10:30:59'),
(11, 5011, 'R102', '2024-03-20', 'Evening', 'STU-2024-008', 3.00, 'Study Group', '2026-02-03 10:30:59'),
(12, 5012, 'R101', '2024-03-21', 'Night', NULL, 2.00, 'Study', '2026-02-03 10:30:59'),
(13, 5013, 'R102', '2024-03-22', 'Morning', 'STU-2024-009', 1.50, 'Presentation Practice', '2026-02-03 10:30:59'),
(14, 5014, 'R201', '2024-03-23', 'Afternoon', 'STU-2024-010', 3.00, 'Project Meeting', '2026-02-03 10:30:59'),
(15, 5015, 'R202', '2024-03-24', 'Evening', 'STU-2024-011', 2.00, 'Study', '2026-02-03 10:30:59');

-- --------------------------------------------------------

--
-- Structure for view `cs_department_view`
--
DROP TABLE IF EXISTS `cs_department_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cs_department_view`  AS SELECT `masked_student_data`.`masked_student_id` AS `masked_student_id`, `masked_student_data`.`department_standardized` AS `department_standardized`, `masked_student_data`.`loan_count` AS `loan_count`, `masked_student_data`.`download_count` AS `download_count`, `masked_student_data`.`booking_count` AS `booking_count` FROM `masked_student_data` WHERE `masked_student_data`.`department_standardized` = 'Computer Science' ;

-- --------------------------------------------------------

--
-- Structure for view `masked_student_data`
--
DROP TABLE IF EXISTS `masked_student_data`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `masked_student_data`  AS SELECT concat('STU-XXX-',right(`dim_student`.`student_id`,3)) AS `masked_student_id`, `dim_student`.`department_standardized` AS `department_standardized`, `fact_library_usage`.`loan_count` AS `loan_count`, `fact_library_usage`.`download_count` AS `download_count`, `fact_library_usage`.`booking_count` AS `booking_count` FROM (`fact_library_usage` join `dim_student` on(`fact_library_usage`.`student_key` = `dim_student`.`student_key`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `dim_date`
--
ALTER TABLE `dim_date`
  ADD PRIMARY KEY (`date_key`),
  ADD KEY `idx_date_full` (`full_date`);

--
-- Indexes for table `dim_location`
--
ALTER TABLE `dim_location`
  ADD PRIMARY KEY (`location_key`);

--
-- Indexes for table `dim_resource`
--
ALTER TABLE `dim_resource`
  ADD PRIMARY KEY (`resource_key`),
  ADD KEY `idx_resource_id` (`resource_id`);

--
-- Indexes for table `dim_student`
--
ALTER TABLE `dim_student`
  ADD PRIMARY KEY (`student_key`),
  ADD UNIQUE KEY `student_id` (`student_id`),
  ADD KEY `idx_student_id` (`student_id`);

--
-- Indexes for table `dim_time_slot`
--
ALTER TABLE `dim_time_slot`
  ADD PRIMARY KEY (`time_slot_key`);

--
-- Indexes for table `fact_library_usage`
--
ALTER TABLE `fact_library_usage`
  ADD PRIMARY KEY (`usage_key`),
  ADD KEY `location_key` (`location_key`),
  ADD KEY `time_slot_key` (`time_slot_key`),
  ADD KEY `idx_fact_date` (`date_key`),
  ADD KEY `idx_fact_student` (`student_key`),
  ADD KEY `idx_fact_resource` (`resource_key`),
  ADD KEY `idx_fact_source` (`source_system`);

--
-- Indexes for table `staging_book_transactions`
--
ALTER TABLE `staging_book_transactions`
  ADD PRIMARY KEY (`staging_id`);

--
-- Indexes for table `staging_digital_usage`
--
ALTER TABLE `staging_digital_usage`
  ADD PRIMARY KEY (`staging_id`);

--
-- Indexes for table `staging_room_bookings`
--
ALTER TABLE `staging_room_bookings`
  ADD PRIMARY KEY (`staging_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `dim_location`
--
ALTER TABLE `dim_location`
  MODIFY `location_key` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=120;

--
-- AUTO_INCREMENT for table `dim_resource`
--
ALTER TABLE `dim_resource`
  MODIFY `resource_key` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=164;

--
-- AUTO_INCREMENT for table `dim_student`
--
ALTER TABLE `dim_student`
  MODIFY `student_key` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=211;

--
-- AUTO_INCREMENT for table `dim_time_slot`
--
ALTER TABLE `dim_time_slot`
  MODIFY `time_slot_key` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `fact_library_usage`
--
ALTER TABLE `fact_library_usage`
  MODIFY `usage_key` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=196;

--
-- AUTO_INCREMENT for table `staging_book_transactions`
--
ALTER TABLE `staging_book_transactions`
  MODIFY `staging_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `staging_digital_usage`
--
ALTER TABLE `staging_digital_usage`
  MODIFY `staging_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `staging_room_bookings`
--
ALTER TABLE `staging_room_bookings`
  MODIFY `staging_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `fact_library_usage`
--
ALTER TABLE `fact_library_usage`
  ADD CONSTRAINT `fact_library_usage_ibfk_1` FOREIGN KEY (`date_key`) REFERENCES `dim_date` (`date_key`),
  ADD CONSTRAINT `fact_library_usage_ibfk_2` FOREIGN KEY (`student_key`) REFERENCES `dim_student` (`student_key`),
  ADD CONSTRAINT `fact_library_usage_ibfk_3` FOREIGN KEY (`resource_key`) REFERENCES `dim_resource` (`resource_key`),
  ADD CONSTRAINT `fact_library_usage_ibfk_4` FOREIGN KEY (`location_key`) REFERENCES `dim_location` (`location_key`),
  ADD CONSTRAINT `fact_library_usage_ibfk_5` FOREIGN KEY (`time_slot_key`) REFERENCES `dim_time_slot` (`time_slot_key`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
