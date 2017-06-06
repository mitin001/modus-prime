CREATE TABLE `technologies` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `os` enum('Apple','Android','Windows','Chromium OS','Firefox OS','Linux') NOT NULL DEFAULT 'Linux',
  `browser` enum('Chrome','Firefox','IE','Safari','Opera','Android','?') NOT NULL DEFAULT '?',
  `device` enum('Laptop','Mobile','Tablet','TV','Desktop') NOT NULL DEFAULT 'Desktop',
  `network` enum('Home','School','Work','Earth') NOT NULL DEFAULT 'Earth',
  `stage` enum('stage','prod') DEFAULT NULL,
  `apigw_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `apigw_id` (`apigw_id`),
  CONSTRAINT `technologies_ibfk_1` FOREIGN KEY (`apigw_id`) REFERENCES `apigw` (`id`)
);
