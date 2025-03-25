SELECT *, 
MATCH(Name, Description) AGAINST ('путин') AS relevance
FROM games
ORDER BY MATCH (Name, Description) AGAINST ('путин') DESC;

SELECT *, 
MATCH(Name, Description) AGAINST ('симулятор') AS relevance
FROM games
ORDER BY MATCH (Name, Description) AGAINST ('симулятор') DESC;

SELECT *, 
MATCH(Name, Description) AGAINST ('The') AS relevance
FROM games
ORDER BY MATCH (Name, Description) AGAINST ('The') DESC;

-- только из описания
SELECT *, 
MATCH(Description) AGAINST ('Градостроительный симулятор') AS relevance
FROM games
ORDER BY MATCH (Description) AGAINST ('Градостроительный симулятор') DESC;

-- только из названия
SELECT *, 
MATCH(Name) AGAINST ('The Sims') AS relevance
FROM games
ORDER BY MATCH (Name) AGAINST ('The Sims') DESC;

SELECT *, 
MATCH(Name, Description) AGAINST ('The симулятор') AS relevance
FROM games
ORDER BY MATCH (Name, Description) AGAINST ('The симулятор') DESC;