# Aggregates the contents of the `hits` table into 4 objects resembling schema used by Chart.js to draw bar charts

CREATE OR REPLACE VIEW `charts` AS
SELECT
  json_object(
           'title', 'Operating Systems',
           'labels', cast(concat('[', group_concat(json_quote(`label`) SEPARATOR ','), ']') AS JSON),
           'datasets', json_array(
               json_object('label', 'Testing',
                           'data', cast(concat('[', group_concat(`testing` SEPARATOR ','), ']') AS JSON)),
               json_object('label', 'Production',
                           'data', cast(concat('[', group_concat(`production` SEPARATOR ','), ']') AS JSON))
           )
       ) AS `options`,
  'Operating Systems' AS `description`
FROM (SELECT
        (CASE json_unquote(json_extract(`os`, '$.name'))
         WHEN 'Mac OS' THEN 'Apple'
         WHEN 'iOS' THEN 'Apple'
         WHEN 'Android' THEN 'Android'
         WHEN 'Windows' THEN 'Windows'
         WHEN 'Chromium OS' THEN 'Chromium OS'
         WHEN 'Firefox OS' THEN 'Firefox OS'
         ELSE 'Linux' END)      AS `label`,
        sum(`stage` = 'stage')  AS `testing`,
        sum(`stage` = 'prod')   AS `production`
      FROM `hits`
      GROUP BY `label`
      ORDER BY `testing` DESC) `n1`
UNION
SELECT
  json_object(
      'title', 'Browsers',
      'labels', cast(concat('[', group_concat(json_quote(`label`) SEPARATOR ','), ']') AS JSON),
      'datasets', json_array(
          json_object('label', 'Testing',
                      'data', cast(concat('[', group_concat(`testing` SEPARATOR ','), ']') AS JSON)),
          json_object('label', 'Production',
                      'data', cast(concat('[', group_concat(`production` SEPARATOR ','), ']') AS JSON))
      )
  ) AS `options`,
  'Browsers' AS `description`
FROM (SELECT
        (CASE json_unquote(json_extract(`browser`, '$.name'))
         WHEN 'Chrome' THEN 'Chrome'
         WHEN 'Chromium' THEN 'Chrome'
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
         ELSE '?' END)          AS `label`,
        sum(`stage` = 'stage')  AS `testing`,
        sum(`stage` = 'prod')   AS `production`
      FROM `hits`
      GROUP BY `label`
      ORDER BY `testing` DESC) `n1`
UNION
SELECT
  json_object(
      'title', 'Devices',
      'labels', cast(concat('[', group_concat(json_quote(`label`) SEPARATOR ','), ']') AS JSON),
      'datasets', json_array(
          json_object('label', 'Testing',
                      'data', cast(concat('[', group_concat(`testing` SEPARATOR ','), ']') AS JSON)),
          json_object('label', 'Production',
                      'data', cast(concat('[', group_concat(`production` SEPARATOR ','), ']') AS JSON))
      )
  ) AS `options`,
  'Devices' AS `description`
FROM (SELECT
        (CASE `viewer_type`
         WHEN 'Desktop' THEN 'Laptop'
         WHEN 'Mobile' THEN 'Mobile'
         WHEN 'Tablet' THEN 'Tablet'
         WHEN 'TV' THEN 'TV'
         ELSE 'Desktop' END)    AS `label`,
        sum(`stage` = 'stage')  AS `testing`,
        sum(`stage` = 'prod')   AS `production`
      FROM `hits`
      GROUP BY `label`
      ORDER BY `testing` DESC) `n1`
UNION
SELECT
  json_object(
      'title', 'Networks',
      'labels', cast(concat('[', group_concat(json_quote(`label`) SEPARATOR ','), ']') AS JSON),
      'datasets', json_array(
          json_object('label', 'Testing',
                      'data', cast(concat('[', group_concat(`testing` SEPARATOR ','), ']') AS JSON)),
          json_object('label', 'Production',
                      'data', cast(concat('[', group_concat(`production` SEPARATOR ','), ']') AS JSON))
      )
  ) AS `options`,
  'Networks' AS `description`
FROM (SELECT
        (CASE `ip`
         WHEN '127.0.0.0' THEN 'Home'
         WHEN '240.0.0.0' THEN 'School'
         WHEN '255.255.255.254' THEN 'Work'
         ELSE 'Earth' END)      AS `label`,
        sum(`stage` = 'stage')  AS `testing`,
        sum(`stage` = 'prod')   AS `production`
      FROM `hits`
      GROUP BY `label`
      ORDER BY `testing` DESC) `n1`;
