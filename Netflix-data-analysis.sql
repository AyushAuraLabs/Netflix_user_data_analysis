--Netflix Project 
DROP TABLE IF EXISTS NETFLIX;
Create Table Netflix
(
	show_id VARCHAR(7),
	type VARCHAR(15),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(800),
	country VARCHAR(150),
	date_added VARCHAR(25), 
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(300)
	);

	SELECT COUNT (*) fROM NETFLIX;
SELECT * fROM NETFLIX;

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
--2. Find the most common rating for movies and TV shows
--3. List all movies released in a specific year (e.g., 2020)
--4. Find the top 5 countries with the most content on Netflix
--5. Identify the longest movie
--6. Find content added in the last 5 years
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'
--8. List all TV shows with more than 5 seasons
--9. Count the number of content items in each genre
--10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
--11. List all movies that are documentaries
--12. Find all content without a director
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.


--SOLUTIONS

--1. Count the number of Movies vs TV Shows
SELECT Type, COUNT (*) as total_content From NETFLIX 
group by type;

--2. Find the most common rating for movies and TV shows
SELECT type, rating
FROM (
    SELECT
        type,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY type
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM netflix
    GROUP BY type, rating
) t
WHERE rn = 1;

--3. List all movies released in a specific year (e.g., 2020)

SELECT type, release_year, Title
From Netflix
Where release_year = '2021' And Type = 'Movie'

--4. Find the top 5 countries with the most content on Netflix

Select * From Netflix

SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY country_name
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5

-- 9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

--11. List all movies that are documentaries

SELECT TYPE, TITLE, LISTED_IN FROM NETFLIX 
WHERE TYPE = 'Movie' AND LISTED_IN LIKE '%Documentaries%'

--12. Find all content without a director

SELECT * FROM NETFLIX 
WHERE DIRECTOR IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM NETFLIX 
WHERE CASTS LIKE '%Salman Khan%' AND RELEASE_YEAR > 2015


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2