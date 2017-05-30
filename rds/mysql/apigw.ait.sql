# Parses the contents of a row of the `apigw` table after insert and stores the result in a row of the `hits` table

CREATE TRIGGER `apigw_ait`
AFTER INSERT ON `apigw`
FOR EACH ROW
INSERT INTO `hits` (
  `apigw_id`,
  `body`,
  `stage`,
  `country`,
  `viewer_type`,
  `ip`,
  `invoke_id`,
  `log_stream_name`,
  `os`,
  `cpu`,
  `device`,
  `engine`,
  `browser`
) SELECT
   NEW.id AS `apigw_id`,
   NEW.event->>'$.body' AS `body`,
   NEW.event->>'$.requestContext.stage' as `stage`,
   NEW.event->>'$.headers."CloudFront-Viewer-Country"' AS `country`,
   IF(NEW.event->>'$.headers."CloudFront-Is-Mobile-Viewer"' = 'true', 'mobile',
      IF(NEW.event->>'$.headers."CloudFront-Is-Tablet-Viewer"' = 'true', 'tablet',
         IF(NEW.event->>'$.headers."CloudFront-Is-Desktop-Viewer"' = 'true', 'desktop',
            IF(NEW.event->>'$.headers."CloudFront-Is-SmartTV-Viewer"' = 'true', 'tv',
               NULL)))) AS `viewer_type`,
   NEW.event->>'$.requestContext.identity.sourceIp' AS `ip`,
   NEW.context->>'$.invokeid' AS `invoke_id`,
   NEW.context->>'$.logStreamName' AS `log_stream_name`,
   NEW.ua->>'$.os' AS `os`,
   NEW.ua->>'$.cpu' AS `cpu`,
   NEW.ua->>'$.device' AS `device`,
   NEW.ua->>'$.engine' AS `engine`,
   NEW.ua->>'$.browser' AS `browser`;
