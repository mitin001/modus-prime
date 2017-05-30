CREATE TABLE `hits` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `apigw_id` int(11) unsigned DEFAULT NULL,
  `country` varchar(16) DEFAULT NULL,
  `ip` varchar(127) DEFAULT NULL,
  `viewer_type` enum('Mobile','Tablet','Desktop','TV') DEFAULT NULL,
  `stage` enum('stage','prod') DEFAULT NULL,
  `body` json DEFAULT NULL,
  `os` json DEFAULT NULL,
  `cpu` json DEFAULT NULL,
  `device` json DEFAULT NULL,
  `engine` json DEFAULT NULL,
  `browser` json DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `invoke_id` char(36) DEFAULT NULL,
  `log_stream_name` char(52) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `apigw_id` (`apigw_id`),
  CONSTRAINT `hits_ibfk_1` FOREIGN KEY (`apigw_id`) REFERENCES `apigw` (`id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8
  COMMENT='Stores analytical information extracted from table `apigw` such as which country the hit came from, which technology was used, the request payload, etc.';
