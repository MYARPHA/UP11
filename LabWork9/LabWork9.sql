SHOW PROCESSLIST;
SET GLOBAL event_scheduler = ON;

CREATE TABLE myEventTable (
	id INT auto_increment primary key,
    eventTime DATETIME NOT NULL,
    eventName VARCHAR(50) NOT NULL);
    
CREATE EVENT event1
ON SCHEDULE EVERY 10 SECOND
STARTS NOW()
ENDS NOW() + INTERVAL 5 minute
DO
INSERT INTO myeventtable (eventTime, eventName)
VALUES (NOW(), 'event1');

-- 2
CREATE EVENT event2
ON SCHEDULE EVERY 2 MINUTE 
STARTS NOW()
ENDS NOW() + INTERVAL 1 DAY
DO
INSERT INTO myeventtable (eventTime, eventName)
VALUES (NOW(), 'event2');

CREATE EVENT event2_30s
ON SCHEDULE EVERY 30 SECOND 
STARTS NOW()
ENDS NOW() + INTERVAL 1 DAY
DO
INSERT INTO myeventtable (eventTime, eventName)
VALUES (NOW(), 'event2_30s');

-- 3
CREATE EVENT event3
ON SCHEDULE AT TIMESTAMPADD(DAY, 1, CURRENT_DATE()) + INTERVAL 12 hour
DO
INSERT INTO myeventtable (eventTime, eventName)
VALUES (NOW(), 'event3')

-- 4
CREATE EVENT eventAuthor
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE() + INTERVAL 15 hour
DO
BEGIN
	INSERT INTO myeventtable (eventTime, eventName)
	VALUES (NOW(), 'eventAthor')
    
    DELETE FROM Authors
    WHERE id NOT IN (SELECT DISTINCT author_id FROM book)
END;

-- 5
SELECT * 
FROM information_schema.EVENTS;

