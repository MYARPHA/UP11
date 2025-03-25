-- 5
SELECT *,
MATCH (Genres) AGAINST ('RPG') AS relevance
FROM video_games
WHERE MATCH (Genres) AGAINST ('RPG') ORDER BY relevance DESC;

-- 6
SELECT *,
MATCH (Genres) AGAINST ('Action -RPG' IN BOOLEAN MODE) AS relevance
FROM video_games
WHERE MATCH (Genres) AGAINST ('Action -RPG' IN BOOLEAN MODE);

-- 7
SELECT *,
MATCH (Genres) AGAINST ('Simulation +Action' IN BOOLEAN MODE) AS relevance
FROM video_games
WHERE MATCH (Genres) AGAINST ('Simulation +Action' IN BOOLEAN MODE);

-- 8
SELECT *,
MATCH (Genres) AGAINST ('Action +Simulation -Sports' IN BOOLEAN MODE) AS relevance
FROM video_games
WHERE MATCH (Genres) AGAINST ('Action +Simulation -Sports' IN BOOLEAN MODE);