CREATE TABLE `apigw` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `event` json DEFAULT NULL,
  `context` json DEFAULT NULL,
  `ua` json DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8
  COMMENT='Records AWS Lambda events when triggered by API Gateway, their contexts, and user agents parsed out of the events by Lambda. Assigns an auto-incremented ID and a timestamp of the INSERT operation to each event.';
