USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

	SELECT table_name, table_rows
	FROM information_schema.tables
	WHERE table_schema = 'imdb';
	
	
	
	+------------------+------------+
	| TABLE_NAME       | TABLE_ROWS |
	+------------------+------------+
	| director_mapping |       3867 |
	| genre            |      14662 |
	| movie            |       6803 |
	| names            |      30434 |
	| ratings          |       7927 |
	| role_mapping     |      14840 |
	+------------------+------------+
	


-- Q2. Which columns in the movie table have null values?
-- Type your code below:


	DELIMITER $$

	CREATE PROCEDURE  null_columns_check(IN schema_val VARCHAR(64), IN table_val VARCHAR(64))
	BEGIN
	  DECLARE col_name VARCHAR(64);
	  DECLARE done INT DEFAULT 0;
	  
	  DECLARE cur CURSOR FOR 
	    SELECT COLUMN_NAME as col_name
	    FROM INFORMATION_SCHEMA.COLUMNS
	    WHERE TABLE_SCHEMA = schema_val
	      AND TABLE_NAME = table_val;
	
	  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
	  OPEN cur;
	  
	  drop table if exists null_col_detail;
	  create temporary table null_col_detail (col_name VARCHAR(64), null_count INT DEFAULT 0);
	  
	  read_loop: LOOP
	    FETCH cur INTO col_name;
	    IF done = 1 THEN
	      LEAVE read_loop;
	    END IF;
	    
	    insert into test select CONCAT('INSERT INTO null_col_detail (col_name, null_count) SELECT "', col_name, '", COUNT(*) FROM ', schema_val, '.', table_val, ' WHERE ', col_name, ' IS NULL;');
	    
	    SET @query = CONCAT('INSERT INTO null_col_detail (col_name, null_count) SELECT "', col_name, '", COUNT(*) FROM ', schema_val, '.', table_val, ' WHERE ', col_name, ' IS NULL;');
	    PREPARE stmt FROM @query;
	    EXECUTE stmt;
	    DEALLOCATE PREPARE stmt;
	  END LOOP;
	
	  CLOSE cur;
	
	  SELECT * FROM null_col_detail;
	  
	  DROP TEMPORARY TABLE null_col_detail;
	END $$
	
	DELIMITER ;
	
	
	CALL null_columns_check('imdb', 'movie');
	
	+-----------------------+------------+
	| col_name              | null_count |
	+-----------------------+------------+
	| country               |         20 |
	| date_published        |          0 |
	| duration              |          0 |
	| id                    |          0 |
	| languages             |        194 |
	| production_company    |        528 |
	| title                 |          0 |
	| worlwide_gross_income |       3724 |
	| year                  |          0 |
	+-----------------------+------------+
	9 rows in set (0.05 sec)
	
	-- columns country, languages, production_company , worlwide_gross_income has null data. The above approach is generic and can be used for all tables



-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


	SELECT YEAR(date_published) AS Year , COUNT(*) AS number_of_movies  FROM movie 
	GROUP BY 1 ORDER BY number_of_movies DESC
	
	
	+------+------------------+
	| Year | number_of_movies |
	+------+------------------+
	| 2017 |             3052 |
	| 2018 |             2944 |
	| 2019 |             2001 |
	+------+------------------+
	3 rows in set (0.01 sec)
	
	-- maximum moves released on 2017 and decreased year on year.
	
	SELECT MONTH(date_published) AS month_num , COUNT(*) AS number_of_movies  FROM movie 
	GROUP BY 1 ORDER BY number_of_movies DESC
	
	+-----------+------------------+
	| month_num | number_of_movies |
	+-----------+------------------+
	|         3 |              824 |
	|         9 |              809 |
	|         1 |              804 |
	|        10 |              801 |
	|         4 |              680 |
	|         8 |              678 |
	|         2 |              640 |
	|        11 |              625 |
	|         5 |              625 |
	|         6 |              580 |
	|         7 |              493 |
	|        12 |              438 |
	+-----------+------------------+
	12 rows in set (0.01 sec)
	

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:



	SELECT count(*)  FROM movie 
	WHERE (country like '%USA%' or country like '%India%') AND YEAR(date_published) = 2019

	+----------+
	| count(*) |
	+----------+
	|     1059 |
	+----------+
	1 row in set (0.01 sec)

	-- 1059 movies were produced in the USA or India in the year 2019



/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:


	SELECT genre FROM genre group by 1 order by 1;
	
	+-----------+
	| genre     |
	+-----------+
	| Action    |
	| Adventure |
	| Comedy    |
	| Crime     |
	| Drama     |
	| Family    |
	| Fantasy   |
	| Horror    |
	| Mystery   |
	| Others    |
	| Romance   |
	| Sci-Fi    |
	| Thriller  |
	+-----------+
	13 rows in set (0.01 sec)







/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:




	SELECT a.genre,count(*) as movie_count FROM genre a inner join movie b on (a.movie_id = b.id) group by 1 order by 2 desc;
	
	+-----------+-------------+
	| genre     | movie_count |
	+-----------+-------------+
	| Drama     |        4285 |
	| Comedy    |        2412 |
	| Thriller  |        1484 |
	| Action    |        1289 |
	| Horror    |        1208 |
	| Romance   |         906 |
	| Crime     |         813 |
	| Adventure |         591 |
	| Mystery   |         555 |
	| Sci-Fi    |         375 |
	| Fantasy   |         342 |
	| Family    |         302 |
	| Others    |         100 |
	+-----------+-------------+
	13 rows in set (0.03 sec)

	-- Drama seems to have highest movies produced


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

	
	WITH movie_genre_cnt as
	(
		SELECT movie_id FROM genre group by 1 having count(distinct genre) =1
	)
	select count(*) from movie_genre_cnt;

	+----------+
	| count(*) |
	+----------+
	|     3289 |
	+----------+
	1 row in set (0.03 sec)

	-- 3289 belong to only one genre.

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

	SELECT a.genre as genre,avg(duration) as avg_duration FROM genre a inner join movie b on (a.movie_id = b.id) group by 1 order by 2 desc;

	| genre     | avg_duration |
	+-----------+--------------+
	| Action    |     112.8829 |
	| Romance   |     109.5342 |
	| Crime     |     107.0517 |
	| Drama     |     106.7746 |
	| Fantasy   |     105.1404 |
	| Comedy    |     102.6227 |
	| Adventure |     101.8714 |
	| Mystery   |     101.8000 |
	| Thriller  |     101.5761 |
	| Family    |     100.9669 |
	| Others    |     100.1600 |
	| Sci-Fi    |      97.9413 |
	| Horror    |      92.7243 |
	+-----------+--------------+
	13 rows in set (0.02 sec)

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:



	WITH genre_rank as
	(
	SELECT a.genre,count(*) as movie_count,rank() over(order by count(*) desc) as genre_rank FROM genre a inner join movie b on (a.movie_id = b.id) group by 1 
	)
	select * from genre_rank where genre='thriller';

	+----------+-------------+------------+
	| genre    | movie_count | genre_rank |
	+----------+-------------+------------+
	| Thriller |        1484 |          3 |
	+----------+-------------+------------+
	1 row in set (0.03 sec)

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

	SELECT 
		 MIN(avg_rating) AS min_avg_rating
		,MAX(avg_rating) AS max_avg_rating
		,MIN(total_votes) AS min_total_votes
		,MAX(total_votes) AS max_total_votes
		,MIN(median_rating) AS min_median_rating
		,MAX(median_rating) AS max_median_rating
	FROM ratings;

+----------------+----------------+-----------------+-----------------+-------------------+-------------------+
| min_avg_rating | max_avg_rating | min_total_votes | max_total_votes | min_median_rating | max_median_rating |
+----------------+----------------+-----------------+-----------------+-------------------+-------------------+
|            1.0 |           10.0 |             100 |          725138 |                 1 |                10 |
+----------------+----------------+-----------------+-----------------+-------------------+-------------------+
1 row in set (0.01 sec)
    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
	
	WITH movie_rating as
	(
		select title,avg_rating,dense_rank() over (order by avg_rating desc) as movie_rank
		from movie a inner join ratings b on (a.id = b.movie_id) 
	)
	select * from movie_rating where movie_rank <= 5 order by movie_rank
	

+--------------------------------+------------+------------+
| title                          | avg_rating | movie_rank |
+--------------------------------+------------+------------+
| Kirket                         |       10.0 |          1 |
| Love in Kilnerry               |       10.0 |          1 |
| Gini Helida Kathe              |        9.8 |          2 |
| Runam                          |        9.7 |          3 |
| Fan                            |        9.6 |          4 |
| Android Kunjappan Version 5.25 |        9.6 |          4 |
| Yeh Suhaagraat Impossible      |        9.5 |          5 |
| Safe                           |        9.5 |          5 |
| The Brighton Miracle           |        9.5 |          5 |
+--------------------------------+------------+------------+
9 rows in set (0.04 sec)






/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have



	select median_rating , count(movie_id) as movie_count from ratings group by 1 order by 1,2
	
	+---------------+-------------+
	| median_rating | movie_count |
	+---------------+-------------+
	|             1 |          94 |
	|             2 |         119 |
	|             3 |         283 |
	|             4 |         479 |
	|             5 |         985 |
	|             6 |        1975 |
	|             7 |        2257 |
	|             8 |        1030 |
	|             9 |         429 |
	|            10 |         346 |
	+---------------+-------------+
	10 rows in set (0.01 sec)






/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:


	WITH production_rating 
	AS
	(
		select production_company , count(*) as movie_count , dense_rank() over(order by count(*) desc) as prod_company_rank
		from movie a inner join ratings b on (a.id  = b.movie_id)
		where avg_rating > 8 and production_company is not null
		group by 1 
	)
	select * from production_rating where prod_company_rank =1;
	
	+------------------------+-------------+-------------------+
	| production_company     | movie_count | prod_company_rank |
	+------------------------+-------------+-------------------+
	| Dream Warrior Pictures |           3 |                 1 |
	| National Theatre Live  |           3 |                 1 |
	+------------------------+-------------+-------------------+
	2 rows in set (0.01 sec)



-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

	select b.genre , count(*) as movie_count
	from movie a inner join genre b on (a.id = b.movie_id)
	inner join ratings c on (a.id = c.movie_id)
	where year(date_published) = 2017 and monthname(date_published) = 'March' and country='USA' and total_votes>1000
	group by 1 order by movie_count desc
	
	+----------+-------------+
	| genre    | movie_count |
	+----------+-------------+
	| Drama    |          16 |
	| Comedy   |           8 |
	| Crime    |           5 |
	| Horror   |           5 |
	| Action   |           4 |
	| Sci-Fi   |           4 |
	| Thriller |           4 |
	| Romance  |           3 |
	| Fantasy  |           2 |
	| Mystery  |           2 |
	| Family   |           1 |
	+----------+-------------+
	11 rows in set (0.01 sec)


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

	select a.title ,c.avg_rating,b.genre 
	from movie a inner join genre b on (a.id = b.movie_id)
	inner join ratings c on (a.id = c.movie_id)
	where substring(title,1,3) ='The' and c.avg_rating>8
	order by 2 desc,1,3;


	+--------------------------------------+------------+----------+
	| title                                | avg_rating | genre    |
	+--------------------------------------+------------+----------+
	| The Brighton Miracle                 |        9.5 | Drama    |
	| The Colour of Darkness               |        9.1 | Drama    |
	| The Blue Elephant 2                  |        8.8 | Drama    |
	| The Blue Elephant 2                  |        8.8 | Horror   |
	| The Blue Elephant 2                  |        8.8 | Mystery  |
	| The Irishman                         |        8.7 | Crime    |
	| The Irishman                         |        8.7 | Drama    |
	| The Mystery of Godliness: The Sequel |        8.5 | Drama    |
	| The Gambinos                         |        8.4 | Crime    |
	| The Gambinos                         |        8.4 | Drama    |
	| Theeran Adhigaaram Ondru             |        8.3 | Action   |
	| Theeran Adhigaaram Ondru             |        8.3 | Crime    |
	| Theeran Adhigaaram Ondru             |        8.3 | Thriller |
	| The King and I                       |        8.2 | Drama    |
	| The King and I                       |        8.2 | Romance  |
	+--------------------------------------+------------+----------+
	15 rows in set (0.01 sec)




-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

   select count(*) as median_rating_count
   from movie a inner join ratings b on (a.id = b.movie_id)
   where date_published between '2018-04-01' and '2019-04-01' and median_rating = 8;

	+---------------------+
	| median_rating_count |
	+---------------------+
	|                 361 |
	+---------------------+
	1 row in set (0.02 sec)
	

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


	select 'German' as lang , sum(total_votes) as total_votes
	from movie a inner join ratings b on (a.id = b.movie_id)
	where languages like '%German%' 
	union
	select 'Italian' as lang , sum(total_votes) as total_votes
	from movie a inner join ratings b on (a.id = b.movie_id)
	where languages like '%Italian%' ;

	+---------+-------------+
	| lang    | total_votes |
	+---------+-------------+
	| German  |     4421525 |
	| Italian |     2559540 |
	+---------+-------------+
	2 rows in set (0.02 sec)

	-- Do German movies get more votes than Italian movies? - yes

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

	-- below proc created in question 2
	CALL null_columns_check('imdb', 'names');

	+------------------+------------+
	| col_name         | null_count |
	+------------------+------------+
	| date_of_birth    |      13431 |
	| height           |      17335 |
	| id               |          0 |
	| known_for_movies |      15226 |
	| name             |          0 |
	+------------------+------------+
	5 rows in set (0.06 sec)


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

	
WITH genre_counts
as
(

	select id ,genre,dense_rank() over(order by cnt desc) as rn
	from
	(
		select a.id,b.genre,count(a.id) over(partition by b.genre) as cnt 
		from movie a inner join genre b on (a.id = b.movie_id)
		inner join ratings c on (a.id = c.movie_id)
		where c.avg_rating>8 group by 1,2 
	)x
),
genre_top_3 as
(
	select id from genre_counts where rn<=3 group by 1
),
director_data as
(
	select name as director_name,count(*) as movie_count , rank() over(order by count(*) desc) as rn from genre_top_3 a inner join director_mapping b on (a.id = b.movie_id)
	inner join names c on (b.name_id = c.id) group by 1 
)
select * from director_data where rn<=3;


+------------------+-------------+----+
| director_name    | movie_count | rn |
+------------------+-------------+----+
| James Mangold    |           2 |  1 |
| Marianne Elliott |           2 |  1 |
| Anthony Russo    |           2 |  1 |
| Joe Russo        |           2 |  1 |
+------------------+-------------+----+
4 rows in set (0.02 sec)



/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

with actor_data
as
(
	select name,count(*) as cnt,dense_rank() over(order by count(*) desc) as rn from ratings a inner join role_mapping b on (a.movie_id = b.movie_id)
	inner join names c on (b. name_id = c.id)
	where median_rating>=8
	group by 1 
)
select * from actor_data where rn<=2;


+-----------+-----+----+
| name      | cnt | rn |
+-----------+-----+----+
| Mammootty |   8 |  1 |
| Mohanlal  |   5 |  2 |
+-----------+-----+----+
2 rows in set (0.03 sec)



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


WITH prod_data
AS
(
SELECT mc.production_company AS production_company, SUM(r.total_votes) AS vote_count, RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
FROM movie mc
INNER JOIN ratings r ON mc.id = r.movie_id
WHERE mc.production_company IS NOT NULL
GROUP BY mc.production_company
)
SELECT production_company,vote_count,prod_comp_rank
FROM prod_data WHERE  prod_comp_rank<=3

| production_company    | vote_count | prod_comp_rank |
+-----------------------+------------+----------------+
| Marvel Studios        |    2656967 |              1 |
| Twentieth Century Fox |    2411163 |              2 |
| Warner Bros.          |    2396057 |              3 |
+-----------------------+------------+----------------+
3 rows in set (0.02 sec)


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


SELECT n.name AS actor_name, SUM(r.total_votes) AS total_votes, COUNT(DISTINCT mc.id) AS movie_count, SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actor_avg_rating, RANK() OVER (ORDER BY SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) DESC, SUM(r.total_votes) DESC) AS actor_rank
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN movie mc ON rm.movie_id = mc.id
JOIN ratings r ON mc.id = r.movie_id
WHERE mc.country = 'India' AND rm.category = 'actor'
GROUP BY n.id
HAVING COUNT(DISTINCT mc.id) >= 5
ORDER BY actor_rank;

+--------------------+-------------+-------------+------------------+------------+
| actor_name         | total_votes | movie_count | actor_avg_rating | actor_rank |
+--------------------+-------------+-------------+------------------+------------+
| Vijay Sethupathi   |       23114 |           5 |          8.41673 |          1 |
| Fahadh Faasil      |       13557 |           5 |          7.98604 |          2 |
| Yogi Babu          |        8500 |          11 |          7.83018 |          3 |
| Joju George        |        3926 |           5 |          7.57967 |          4 |
| Ammy Virk          |        2504 |           6 |          7.55383 |          5 |
| Dileesh Pothan     |        6235 |           5 |          7.52133 |          6 |
| Kunchacko Boban    |        5628 |           6 |          7.48351 |          7 |
| Pankaj Tripathi    |       40728 |           5 |          7.43706 |          8 |
| Rajkummar Rao      |       42560 |           6 |          7.36701 |          9 |
| Dulquer Salmaan    |       17666 |           5 |          7.30087 |         10 |
| Amit Sadh          |       13355 |           5 |          7.21306 |         11 |
| Tovino Thomas      |       11596 |           8 |          7.14540 |         12 |
| Mammootty          |       12613 |           8 |          7.04208 |         13 |
| Nassar             |        4016 |           5 |          7.03312 |         14 |
| Karamjit Anmol     |        1970 |           6 |          6.90863 |         15 |
| Hareesh Kanaran    |        3196 |           5 |          6.57747 |         16 |
| Naseeruddin Shah   |       12604 |           5 |          6.53622 |         17 |
| Anandraj           |        2750 |           6 |          6.53571 |         18 |
| Mohanlal           |       17244 |           6 |          6.50840 |         19 |
| Aju Varghese       |        2237 |           5 |          6.43375 |         20 |
| Siddique           |        5953 |           7 |          6.42565 |         21 |
| Prakash Raj        |        8548 |           6 |          6.37126 |         22 |
| Jimmy Sheirgill    |        3826 |           6 |          6.28772 |         23 |
| Mahesh Achanta     |        2716 |           6 |          6.21141 |         24 |
| Biju Menon         |        1916 |           5 |          6.21091 |         25 |
| Suraj Venjaramoodu |        4284 |           6 |          6.18625 |         26 |
| Abir Chatterjee    |        1413 |           5 |          5.80078 |         27 |
| Sunny Deol         |        4594 |           5 |          5.70509 |         28 |
| Radha Ravi         |        1483 |           5 |          5.70223 |         29 |
| Prabhu Deva        |        2044 |           5 |          5.68014 |         30 |
+--------------------+-------------+-------------+------------------+------------+


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT n.name AS actress_name, SUM(r.total_votes) AS total_votes, COUNT(DISTINCT mc.id) AS movie_count,
 round(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes),2) AS actress_avg_rating, 
 RANK() OVER (ORDER BY SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) DESC, SUM(r.total_votes) DESC) AS actress_rank
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN movie mc ON rm.movie_id = mc.id
JOIN ratings r ON mc.id = r.movie_id
WHERE mc.country = 'India' AND rm.category = 'actress' and mc.languages='Hindi'
GROUP BY n.id
HAVING COUNT(DISTINCT mc.id) >= 3
ORDER BY actress_rank;

+-----------------+-------------+-------------+--------------------+--------------+
| actress_name    | total_votes | movie_count | actress_avg_rating | actress_rank |
+-----------------+-------------+-------------+--------------------+--------------+
| Taapsee Pannu   |       18061 |           3 |               7.74 |            1 |
| Divya Dutta     |        8579 |           3 |               6.88 |            2 |
| Kriti Kharbanda |        2549 |           3 |               4.80 |            3 |
| Sonakshi Sinha  |        4025 |           4 |               4.18 |            4 |
+-----------------+-------------+-------------+--------------------+--------------+
4 rows in set (0.03 sec)


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT 
CASE
    WHEN r.avg_rating > 8 THEN 'Superhit movies'
    WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
    WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
    ELSE 'Flop movies'
END AS movie_category , count(*)
FROM ratings r 
INNER JOIN genre g ON r.movie_id = g.movie_id
WHERE g.genre = 'Thriller'
GROUP BY 1
ORDER BY count(*) DESC;

+-----------------------+----------+
| movie_category        | count(*) |
+-----------------------+----------+
| One-time-watch movies |      786 |
| Flop movies           |      493 |
| Hit movies            |      166 |
| Superhit movies       |       39 |
+-----------------------+----------+
4 rows in set (0.02 sec)


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


WITH BASE_DATA AS
(
	SELECT
	    b.genre,
	    ROUND(AVG(a.duration)) AS average_duration,
	    ROW_NUMBER() OVER (ORDER BY AVG(a.duration)) AS row_num
	  FROM
	    movie a inner join genre b on a.id = b.movie_id
	  GROUP BY
	    b.genre
)
SELECT genre, average_duration,SUM(average_duration) OVER(ORDER BY row_num) AS running_total_duration , AVG(average_duration) OVER (ORDER BY row_num ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS moving_avg_duration
FROM BASE_DATA 

+-----------+------------------+------------------------+---------------------+
| genre     | average_duration | running_total_duration | moving_avg_duration |
+-----------+------------------+------------------------+---------------------+
| Horror    |               93 |                     93 |             93.0000 |
| Sci-Fi    |               98 |                    191 |             95.5000 |
| Others    |              100 |                    291 |             99.0000 |
| Family    |              101 |                    392 |            100.5000 |
| Thriller  |              102 |                    494 |            101.5000 |
| Mystery   |              102 |                    596 |            102.0000 |
| Adventure |              102 |                    698 |            102.0000 |
| Comedy    |              103 |                    801 |            102.5000 |
| Fantasy   |              105 |                    906 |            104.0000 |
| Drama     |              107 |                   1013 |            106.0000 |
| Crime     |              107 |                   1120 |            107.0000 |
| Romance   |              110 |                   1230 |            108.5000 |
| Action    |              113 |                   1343 |            111.5000 |
+-----------+------------------+------------------------+---------------------+
13 rows in set (0.03 sec)

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH genre_ranks AS
(
	SELECT g.genre, count(*) AS movie_cnt,dense_rank() OVER(order by count(*) desc) as rn
	FROM movie m
	JOIN genre g ON m.id = g.movie_id
	WHERE worlwide_gross_income IS NOT NULL
	GROUP BY g.genre
),
income_rank AS
(
	select g.genre,YEAR(m.date_published) AS year_published,m.title AS movie_name, worlwide_gross_income,
	dense_rank() over(partition by g.genre,YEAR(m.date_published) order by (case when worlwide_gross_income like '%INR%' then cast(trim(REGEXP_REPLACE(worlwide_gross_income, '[^0-9]+', '')) as UNSIGNED) * 0.012 else cast(trim(REGEXP_REPLACE(worlwide_gross_income, '[^0-9]+', '')) as UNSIGNED) end) desc) as rn
	from movie m
	INNER JOIN genre g ON m.id = g.movie_id
	INNER JOIN genre_ranks h ON (g.genre=h.genre)
	WHERE worlwide_gross_income IS NOT NULL AND h.rn<=3
)
select genre,year_published,movie_name,worlwide_gross_income from income_rank 
where rn<=5; 

/* have converted INR to USD*/

+--------+----------------+-----------------------------------------+-----------------------+
| genre  | year_published | movie_name                              | worlwide_gross_income |
+--------+----------------+-----------------------------------------+-----------------------+
| Action |           2017 | Star Wars: Episode VIII - The Last Jedi | $ 1332539889          |
| Action |           2017 | The Fate of the Furious                 | $ 1236005118          |
| Action |           2017 | Jumanji: Welcome to the Jungle          | $ 962102237           |
| Action |           2017 | Spider-Man: Homecoming                  | $ 880166924           |
| Action |           2017 | Zhan lang II                            | $ 870325439           |
| Action |           2018 | Avengers: Infinity War                  | $ 2048359754          |
| Action |           2018 | Black Panther                           | $ 1346913161          |
| Action |           2018 | Jurassic World: Fallen Kingdom          | $ 1308467944          |
| Action |           2018 | Incredibles 2                           | $ 1242805359          |
| Action |           2018 | Aquaman                                 | $ 1148161807          |
| Action |           2019 | Avengers: Endgame                       | $ 2797800564          |
| Action |           2019 | Spider-Man: Far from Home               | $ 1131845802          |
| Action |           2019 | Captain Marvel                          | $ 1128274794          |
| Action |           2019 | Fast & Furious Presents: Hobbs & Shaw   | $ 758910100           |
| Action |           2019 | Liu lang di qiu                         | $ 699760773           |
| Comedy |           2017 | Despicable Me 3                         | $ 1034799409          |
| Comedy |           2017 | Jumanji: Welcome to the Jungle          | $ 962102237           |
| Comedy |           2017 | Guardians of the Galaxy Vol. 2          | $ 863756051           |
| Comedy |           2017 | Thor: Ragnarok                          | $ 853977126           |
| Comedy |           2017 | Sing                                    | $ 634151679           |
| Comedy |           2018 | Deadpool 2                              | $ 785046920           |
| Comedy |           2018 | Ant-Man and the Wasp                    | $ 622674139           |
| Comedy |           2018 | Tang ren jie tan an 2                   | $ 544061916           |
| Comedy |           2018 | Ralph Breaks the Internet               | $ 529323962           |
| Comedy |           2018 | Hotel Transylvania 3: Summer Vacation   | $ 528583774           |
| Comedy |           2019 | Toy Story 4                             | $ 1073168585          |
| Comedy |           2019 | Pokémon Detective Pikachu               | $ 431705346           |
| Comedy |           2019 | The Secret Life of Pets 2               | $ 429434163           |
| Comedy |           2019 | Once Upon a Time... in Hollywood        | $ 371207970           |
| Comedy |           2019 | Shazam!                                 | $ 364571656           |
| Drama  |           2017 | Zhan lang II                            | $ 870325439           |
| Drama  |           2017 | Logan                                   | $ 619021436           |
| Drama  |           2017 | Dunkirk                                 | $ 526940665           |
| Drama  |           2017 | War for the Planet of the Apes          | $ 490719763           |
| Drama  |           2017 | La La Land                              | $ 446092357           |
| Drama  |           2018 | Bohemian Rhapsody                       | $ 903655259           |
| Drama  |           2018 | Hong hai xing dong                      | $ 579220560           |
| Drama  |           2018 | Wo bu shi yao shen                      | $ 451183391           |
| Drama  |           2018 | A Star Is Born                          | $ 434888866           |
| Drama  |           2018 | Fifty Shades Freed                      | $ 371985018           |
| Drama  |           2019 | Avengers: Endgame                       | $ 2797800564          |
| Drama  |           2019 | The Lion King                           | $ 1655156910          |
| Drama  |           2019 | Joker                                   | $ 995064593           |
| Drama  |           2019 | Liu lang di qiu                         | $ 699760773           |
| Drama  |           2019 | It Chapter Two                          | $ 463326885           |
+--------+----------------+-----------------------------------------+-----------------------+
45 rows in set (0.05 sec)

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH base_data
as
(
select production_company, count(*) as movie_count,dense_rank() over(order by count(*) desc) as prod_comp_rank 
from movie a inner join ratings b on(a.id = b.movie_id)
where POSITION(',' IN languages)>0  and production_company IS NOT NULL and b.median_rating>=8
group by 1 
)
select * from base_data where prod_comp_rank<=2

+-----------------------+-------------+----------------+
| production_company    | movie_count | prod_comp_rank |
+-----------------------+-------------+----------------+
| Star Cinema           |           7 |              1 |
| Twentieth Century Fox |           4 |              2 |
+-----------------------+-------------+----------------+
2 rows in set (0.03 sec)


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH Base_data
as
(
	SELECT n.name AS actress_name, SUM(r.total_votes) AS total_votes, COUNT(rm.movie_id) AS movie_count, ROUND(AVG(r.avg_rating), 2) AS actress_avg_rating, RANK() OVER (ORDER BY COUNT(rm.movie_id) DESC , ROUND(AVG(r.avg_rating), 2) desc ) AS actress_rank
	FROM role_mapping rm
	JOIN genre g ON rm.movie_id = g.movie_id
	JOIN ratings r ON r.movie_id = g.movie_id
	JOIN names n ON rm.name_id = n.id
	WHERE g.genre = 'Drama' AND r.avg_rating > 8 AND rm.category = 'Actress'
	GROUP BY n.name
	ORDER BY actress_rank
)
select * from Base_data where actress_rank<=3


+-----------------+-------------+-------------+--------------------+--------------+
| actress_name    | total_votes | movie_count | actress_avg_rating | actress_rank |
+-----------------+-------------+-------------+--------------------+--------------+
| Susan Brown     |         656 |           2 |               8.95 |            1 |
| Amanda Lawrence |         656 |           2 |               8.95 |            1 |
| Denise Gough    |         656 |           2 |               8.95 |            1 |
+-----------------+-------------+-------------+--------------------+--------------+
3 rows in set (0.03 sec)


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

  
WITH base_data
as
(
SELECT dm.name_id AS director_id, n.name AS director_name, m.id AS movie_id,  date_published ,  coalesce(LAG(date_published) OVER (PARTITION BY dm.name_id ORDER BY date_published),date_published) as prev_date_published, r.avg_rating AS avg_rating, r.total_votes AS total_votes, m.duration AS duration
FROM director_mapping dm
JOIN movie m ON dm. movie_id = m.id
JOIN names n ON dm.name_id = n.id
JOIN ratings r ON m.id = r.movie_id
),
director_ranking
AS
(
select director_id , director_name,count(movie_id) as number_of_movies,round(AVG(datediff(date_published,prev_date_published))) as avg_inter_movie_days,round(AVG(avg_rating),2) as avg_rating,SUM(total_votes) as total_votes,min(avg_rating) as min_rating ,max(avg_rating) as max_rating ,SUM(duration) as total_duration , RANK() over(order by count(movie_id) desc) as rn
from base_data
group by 1,2
)
select director_id,director_name,number_of_movies,avg_inter_movie_days,avg_rating,total_votes,min_rating,max_rating,total_duration
from director_ranking where rn<=9

+-------------+-------------------+------------------+----------------------+------------+-------------+------------+------------+----------------+
| director_id | director_name     | number_of_movies | avg_inter_movie_days | avg_rating | total_votes | min_rating | max_rating | total_duration |
+-------------+-------------------+------------------+----------------------+------------+-------------+------------+------------+----------------+
| nm1777967   | A.L. Vijay        |                5 |                  141 |       5.42 |        1754 |        3.7 |        6.9 |            613 |
| nm2096009   | Andrew Jones      |                5 |                  153 |       3.02 |        1989 |        2.7 |        3.2 |            432 |
| nm0001752   | Steven Soderbergh |                4 |                  191 |       6.48 |      171684 |        6.2 |        7.0 |            401 |
| nm0425364   | Jesse V. Johnson  |                4 |                  224 |       5.45 |       14778 |        4.2 |        6.5 |            383 |
| nm0515005   | Sam Liu           |                4 |                  195 |       6.23 |       28557 |        5.8 |        6.7 |            312 |
| nm0814469   | Sion Sono         |                4 |                  248 |       6.03 |        2972 |        5.4 |        6.4 |            502 |
| nm0831321   | Chris Stokes      |                4 |                  149 |       4.33 |        3664 |        4.0 |        4.6 |            352 |
| nm2691863   | Justin Price      |                4 |                  236 |       4.50 |        5343 |        3.0 |        5.8 |            346 |
| nm6356309   | Özgür Bakar       |                4 |                   84 |       3.75 |        1092 |        3.1 |        4.9 |            374 |
+-------------+-------------------+------------------+----------------------+------------+-------------+------------+------------+----------------+
9 rows in set (0.07 sec)

