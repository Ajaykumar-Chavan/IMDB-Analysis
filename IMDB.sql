create database IMDB

create table Movie (Id varchar(max),Title varchar(max),Year int,Date_Published date,Duration int,Country varchar(max),Worldwide_Gross_Income varchar(max),Languages varchar(max),[Production Companey] varchar(max))	

create table Genre (Movie_Id varchar(max),Genre varchar(max))

create table Director_Mapping (Movie_Id varchar(max),Name_Id varchar(max))

create table Role_Mapping (Movie_Id varchar(max),Name_Id varchar(max),Category varchar(max))

create table Names (Id varchar(max),Name varchar(max),Height int,Date_of_Birth date,Known_for_Movies varchar(max))

create table Ratings (Movie_Id varchar(max),Avg_Rating float,Total_Votes int,Median_Rating int)

--Q1. Find the total number of rows in each table ?

select * from movie
select * from genre
select * from Director_Mapping
select * from Role_Mapping
select * from Names
select * from Ratings

--Q2. Which columns in the movie table have null values?

select 'id',count(*) as null_count from movie 
where Id is null
union
select 'title',count(*) as null_count from movie 
where Id is null
union
select 'year',count(*) as null_count from movie 
where Id is null
union
select 'date_published',count(*) as null_count from movie 
where Id is null
union
select 'duration',count(*) as null_count from movie 
where Id is null
union
select 'country',count(*) as null_count from movie 
where Id is null
union
select 'worldwide_gross_income',count(*) as null_count from movie 
where Id is null
union
select 'language',count(*) as null_count from movie 
where Id is null
union
select 'prodution companey',count(*) as null_count from movie 
where Id is null

--Q3. Find the total number of movies released each year? How does the trend look month wise?

select YEAR,count(title) as Total_number_of_movies
from Movie
group by year 
order by year asc

select month(date_published)'month', count(title) as Total_number_of_movie
from movie
group by month(date_published) 
order by count(title) desc

--Q4. How many movies were produced in the USA or India in the year 2019?

select year,count(title) as Number_of_movie
from movie
where year=2019 and (country like '%USA%' or country like '%India%')
group by year
 
--Q5. Find the unique list of the genres present in the data set?

select distinct genre from Genre

-- Q6.Which genre had the highest number of movies produced overall?

select genre, count(genre) as Total
from Genre
group by genre
order by count(genre) desc 
limit 1

-- Q7. How many movies belong to only one genre?

select count(*) as movie_count
from (select movie_id
	from genre
	group by Movie_Id
	having count(*)=1) as counts

--Q8.What is the average duration of movies in each genre? 

select g.genre, avg(m.duration) as avg_total
from movie m
inner join genre g
on g.Movie_Id = m.Id
group by g.genre
order by avg(m.duration) desc

--Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

with genre_rank as(
select genre,count(movie_id) as movie_count,
rank() over(order by count(movie_id) desc)
as ranks from genre
group by genre)
select * from genre_rank
where genre = 'thriller'

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

select min(avg_rating) as min_rating,
max (avg_rating) as max_rating,
min (total_votes) as min_votes,
max (total_votes) as max_votes,
min (median_rating) as min_median_rating, 
max (median_rating) as max_median_rating
from ratings

--Q11. Which are the top 10 movies based on average rating?

select top 10 m.title,r.avg_rating,
rank() over (order by avg_rating desc) as ranks
from Ratings r
inner join Movie m
on r.Movie_Id = m.Id

--Q12. Summarise the ratings table based on the movie counts by median ratings.

select median_rating, count(movie_id) as counts
from Ratings
group by Median_Rating
order by count(movie_id) desc

--Q13. Which production house has produced the most number of hit movies (average rating > 8)??

with hit_movie as(
	select m.[Production Companey],count(m.id) as counts
	from movie m
	inner join Ratings r
	on m.Id = r.Movie_Id
	where r.avg_rating >8
	group by m.[Production Companey])
select top 2 [production companey],counts
from hit_movie
order by counts desc

--Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

select g. genre, count(m.title) as movie_count
from movie m
inner join Genre g
on m.Id = g.Movie_Id
inner join Ratings r
on g.Movie_Id = r.Movie_Id
where m.Year = 2017 and m.Country = 'USA' and r.Total_Votes >1000 and  Month(DATE_PUBLISHED) = 3
group by g.Genre
order by count(m.title) desc

--Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

select m.title, g.genre, r.Avg_Rating
from Movie m
inner join Genre g
on m.Id = g.Movie_Id 
inner join Ratings r
on g.Movie_Id = r.Movie_Id
where lower(m.Title) like 'The%' and r.Avg_Rating > 8
order by r.Avg_Rating desc

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

select Median_Rating, count(m.title) as movie_count
 from Ratings r
 inner join movie m
 on m.Id = r.Movie_Id
 where r.Median_Rating =8 and m.Date_Published between '01-03-2018' and '01-03-2019'
 group by r.Median_Rating
 
-- Q17. Do German movies get more votes than Italian movies? 

select 'German' as country,sum(r.total_votes) as votes
from Movie m
inner join Ratings r
on m.Id = r.Movie_Id
where m.Country = 'germany'
union
select 'Italian' as country,sum(r.total_votes) as votes
from Movie m 
inner join Ratings r
on  m.Id = r.Movie_Id
where m.Country = 'italy'

-- Q18. Which columns in the names table have null values??

select count(*)-count(id) as id_null,
count(*)-count(name) as name_null,
count(*)-count(Height) as height_null,
count(*)-count(date_of_birth) as date_of_birth_null,
count(*)-count(Known_for_Movies) as known_for_movies_null
from Names

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

with top_3 as
(select top 3 g.genre from genre g
inner join Movie m
on m.Id = g.Movie_Id
inner join Ratings r
on g.Movie_Id = r.Movie_Id
where Avg_Rating > 8
group by g.genre
order by count(g.genre) desc)
select name as director_name,count(name) as movie_count
from Ratings r
inner join Movie m
on m.Id = r.Movie_Id
inner join genre g
on g.Movie_Id = m.Id
inner join Director_Mapping d
on d.Movie_Id = g.Movie_Id
inner join Names n
on n.Id = d.Movie_Id
where genre in(select * from top_3)
and Avg_Rating > 8
group by name 
order by count(name) desc

-- Q20. Who are the top two actors whose movies have a median rating >= 8?

select top 2 name ,count(name) as movie_count
from Names n
inner join Role_Mapping rm
on n.Id = rm.Movie_Id
inner join Ratings r
on rm.Movie_Id = r.Movie_Id
where Median_Rating >= 8 and Category = 'actor'
group by name
order by count(name) desc

-- Q21. Which are the top three production houses based on the number of votes received by their movies?

select top 2 [Production Companey],sum(total_votes) as vote_count, 
rank() over (order by sum(total_votes) desc) as prod_com_rank
from Movie m
inner join Ratings r
on m.Id = r.Movie_Id
group by [Production Companey]

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?

with actors as
(select name,count(total_votes) as total_votes,count(name) as movie_count,
round(sum(avg_rating * total_votes)/sum(total_votes),2) as actors_avg_rating
from Names n
inner join Ratings r
on n.Id = r.Movie_Id
inner join Movie m
on m.Id = n.Id
inner join Role_Mapping rm
on rm.Movie_Id = r.Movie_Id
where Country ='india' and Category ='actor'
group by name)
select  * , rank() over(order by actors_avg_rating desc, total_votes desc) as actor_rank
from actors

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings?

with actress as
(select name,count(total_votes) as total_votes,count(name) as movie_count,
round(sum(avg_rating * total_votes)/sum(total_votes),2) as actress_avg_rating
from Names n
inner join Ratings r
on n.Id = r.Movie_Id
inner join Movie m
on m.Id = n.Id
inner join Role_Mapping rm
on rm.Movie_Id = r.Movie_Id
where Country ='india' and Category ='actress' and Languages='hindi'
group by name)
select  * , rank() over(order by actress_avg_rating desc, total_votes desc) as actress_rank
from actress

/*Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies                 */

select title, avg_rating,
case 
when avg_rating > 8 then 'Superhit movies'
when avg_rating between 7 and 8 then 'Hit movies'
when avg_rating between 5 and 7 then 'One-time-watch movies'
when avg_rating < 5 then 'Flop movies'
end as 'avg rating category'
from Movie m
inner join Ratings r
on m.Id = r.Movie_Id
inner join Genre g
on g.Movie_Id = r.Movie_Id
where Genre = 'thriller'

