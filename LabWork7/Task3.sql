SELECT *, 
MATCH(Description) AGAINST ('путин') AS relevance
FROM games

SELECT *,
MATCH(Description) AGAINST ('симулятор') AS relevance
FROM games

SELECT *,
MATCH(Description) AGAINST ('приключение') AS relevance
FROM games

SELECT *,
MATCH(Description) AGAINST ('Градостроительный симулятор') AS relevance
FROM games
