-- 创建数据库
DROP database IF EXISTS `docker_test_database`;
create database `docker_test_database` default character set utf8 collate utf8_general_ci;
-- 切换到test_data数据库
use docker_test_database;
-- 建表
DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
	`id` bigint(20) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) DEFAULT NULL,
	`age` bigint(20) NOT NULL,
	PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
-- 插入数据
INSERT INTO `person` (`name`,`age` )
VALUES
   ('打啊打',18);