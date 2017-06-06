# Parses the contents of a row of the `hits` table after insert and stores the result in a row of the `technologies` table

CREATE TRIGGER `hits_ait`
AFTER INSERT ON `hits`
FOR EACH ROW
INSERT INTO `technologies` (`os`,`browser`,`device`,`network`,`stage`,`apigw_id`)
SELECT
  (CASE json_unquote(json_extract(NEW.os, '$.name'))
   WHEN 'Mac OS' THEN 'Apple'
   WHEN 'iOS' THEN 'Apple'
   WHEN 'Android' THEN 'Android'
   WHEN 'Windows' THEN 'Windows'
   WHEN 'Chromium OS' THEN 'Chromium OS'
   WHEN 'Firefox OS' THEN 'Firefox OS'
   ELSE 'Linux' END) AS `os`,
  (CASE json_unquote(json_extract(NEW.browser, '$.name'))
   WHEN 'Chrome' THEN 'Chrome'
   WHEN 'Chromium' THEN 'Chrome'
   WHEN 'Android Browser' THEN 'Android'
   WHEN 'Firefox' THEN 'Firefox'
   WHEN 'Mozilla' THEN 'Firefox'
   WHEN 'IE Mobile' THEN 'IE'
   WHEN 'IE' THEN 'IE'
   WHEN 'Mobile Safari' THEN 'Safari'
   WHEN 'Safari' THEN 'Safari'
   WHEN 'Opera' THEN 'Opera'
   WHEN 'Opera Mini' THEN 'Opera'
   WHEN 'Opera Mobi' THEN 'Opera'
   WHEN 'Opera Tablet' THEN 'Opera'
   ELSE '?' END) AS `browser`,
  (CASE NEW.viewer_type
   WHEN 'Desktop' THEN 'Laptop'
   WHEN 'Mobile' THEN 'Mobile'
   WHEN 'Tablet' THEN 'Tablet'
   WHEN 'TV' THEN 'TV'
   ELSE 'Desktop' END) AS `device`,
  (CASE NEW.ip
   WHEN '127.0.0.0' THEN 'Home'
   WHEN '240.0.0.0' THEN 'School'
   WHEN '255.255.255.254' THEN 'Work'
   ELSE 'Earth' END) AS `network`,
  NEW.stage AS `stage`,
  NEW.apigw_id AS `apigw_id`;
