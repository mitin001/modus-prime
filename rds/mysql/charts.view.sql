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
      `os` AS `label`, 
      SUM(`stage` = 'stage')  AS `testing`,
      SUM(`stage` = 'prod')   AS `production` 
      FROM `technologies`
      GROUP BY `os`
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
      `browser` AS `label`, 
      SUM(`stage` = 'stage')  AS `testing`,
      SUM(`stage` = 'prod')   AS `production` 
      FROM `technologies`
      GROUP BY `browser`
      ORDER BY `browser` = '?', `testing` DESC) `n1`
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
      `device` AS `label`, 
      SUM(`stage` = 'stage')  AS `testing`,
      SUM(`stage` = 'prod')   AS `production` 
      FROM `technologies`
      GROUP BY `device`
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
      `network` AS `label`, 
      SUM(`stage` = 'stage')  AS `testing`,
      SUM(`stage` = 'prod')   AS `production` 
      FROM `technologies`
      GROUP BY `network`
      ORDER BY `network` = 'Earth', `testing` DESC) `n1`;
