DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(208),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);
SELECT*FROM netflix;

SELECT COUNT(*) AS total_content FROM netflix;

SELECT DISTINCT type FROM netflix;

--QUERIES
-- 1. Count the number of Movies and TV shows
SELECT 
type,
COUNT(*) AS total_content
FROM netflix
GROUP BY type;

--2. Find the most common rating for movie and TV shows
SELECT
type,rating
FROM
(
SELECT 
type,
rating,
COUNT(*),
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix 
GROUP BY (type,rating)
)
WHERE ranking=1; 

--3.List all movies released in a specific year (e.g..2020)
SELECT * FROM netflix 
WHERE type='Movie'
AND 
release_year=2020;

--4.Find the top 5 countries with the most content on Netflix
SELECT 
UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--5.Identify the longest movie duration
SELECT * FROM netflix 
WHERE type='Movie'
AND 
duration=(SELECT MAX(duration) FROM netflix);

--6.Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month,DD,YYYY')>=CURRENT_DATE-INTERVAL '5 years';

--7.Find all the movies/Tv shows by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director ILIKE'%Rajiv Chilaka%'; --in case 2 director ho toh naam nhi aaega uss movie ka agr like nhi kiya toh
--ILIKE is case insensitive it believes in pattern matching
--8.Find all Tv shows with more than 5 seasons
SELECT * FROM netflix
WHERE type='TV Show' 
AND
SPLIT_PART(DURATION,' ',1)::numeric>5;

--9.count the number of content items in each genre
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
COUNT(show_id)
FROM netflix
GROUP BY 1;


--10.Find the average release year for content produced in a specific country (e.g..India)
--return top 5 years
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::numeric / 
        (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 
        2
    ) AS avg_content
FROM netflix
WHERE country = 'India'
GROUP BY 1;

--11.List all the movies that are documentaries
SELECT*FROM netflix
WHERE listed_in ILIKE'%Documentaries%'

--12.Find all content without a director
SELECT*FROM netflix
WHERE director IS NULL;

--13.Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT * FROM netflix
WHERE casts ILIKE'%Salman khan%'
AND
release_year> EXTRACT(YEAR FROM CURRENT_DATE)-10;


--14.Find the top 10 actors who have appeared in the highest number of movies produced in india
SELECT 
UNNEST(STRING_TO_ARRAY(casts,','))as actors,
COUNT(*) AS total_content
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'voilence' in 
--the description field.Label the content containing these keywords as 'Bad' and all other
--content as 'Good'.Count how many items falls into each category
WITH new_table
AS(
SELECT *,
CASE
	WHEN description ILIKE '%kill%'
	OR
		description ILIKE '%voilence%'
	THEN 'Bad'
	ELSE 'Good'
	END category
FROM netflix
)
SELECT category,COUNT(*) AS total_count
FROM new_table
GROUP BY 1;

--16.Most Popular Genres Globally
SELECT  
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,  
    COUNT(show_id) AS genre_count  
FROM netflix  
GROUP BY genre  
ORDER BY genre_count DESC
LIMIT 1;

--17.Find which month has the highest number of content additions over the years
SELECT 
    EXTRACT(MONTH FROM TO_DATE(date_added, 'Month DD, YYYY')) AS month, 
    COUNT(*) AS total_content
FROM netflix
GROUP BY month
ORDER BY total_content DESC;


--18.Identify the most popular genre for each year
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS genre_count
FROM netflix
GROUP BY year, genre
ORDER BY genre_count DESC;

--19.Analyze the proportion of Movies vs. TV Shows added every year.
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    type,
    COUNT(*) AS show_type_count
FROM netflix
GROUP BY year, type
ORDER BY year, show_type_count DESC;

--20.Categorize movies into buckets based on their duration and analyze their count
SELECT 
    CASE
        WHEN SPLIT_PART(duration, ' ', 1)::int < 60 THEN 'Short (< 1 hour)'
        WHEN SPLIT_PART(duration, ' ', 1)::int BETWEEN 60 AND 120 THEN 'Medium (1-2 hours)'
        ELSE 'Long (> 2 hours)'
    END AS duration_category,
    COUNT(*) AS total_content
FROM netflix
WHERE type = 'Movie'
GROUP BY duration_category
ORDER BY duration_category;

--21.Track the trends of content addition by rating year by year.
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    rating, 
    COUNT(*) AS content_count
FROM netflix
GROUP BY year, rating
ORDER BY year, content_count DESC;

--22.Create a matrix of the number of titles by genre and country.
SELECT 
    genre,
    country,
    COUNT(*) AS content_count
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix
) AS genres_countries
GROUP BY genre, country
ORDER BY content_count DESC;


--23.Find the top pairs of actors who frequently appear together.
WITH actor_pairs AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor1,
        UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor2
    FROM netflix
    WHERE casts IS NOT NULL
)
SELECT 
    actor1,
    actor2,
    COUNT(*) AS collaboration_count
FROM actor_pairs
WHERE actor1 < actor2
GROUP BY actor1, actor2
ORDER BY collaboration_count DESC
LIMIT 10;


--24.Track the trends of content addition by rating year by year.
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    rating,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year, rating
ORDER BY year ASC, total_content DESC;








