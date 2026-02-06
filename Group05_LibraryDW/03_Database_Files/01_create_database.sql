-- Database Creation for XAMPP
-- Simple version - just creates the database
DROP DATABASE IF EXISTS library_analytics_dw;
CREATE DATABASE library_analytics_dw;
USE library_analytics_dw;

-- Create schemas/user for access control
CREATE USER 'library_analyst'@'localhost' IDENTIFIED BY '12345';
GRANT SELECT, INSERT, UPDATE ON library_analytics_dw.* TO 'library_analyst'@'localhost';

CREATE USER 'library_admin'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON library_analytics_dw.* TO 'library_admin'@'localhost';