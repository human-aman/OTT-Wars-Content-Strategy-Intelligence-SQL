--Import Data

select COUNT (*) from netflix_titles;

drop table netflix_titles ;

create table netflix_titles (
show_id VARCHAR (10),
type VARCHAR(20),
title VARCHAR (200),
director VARCHAR (200),
"cast" TEXT,
country VARCHAR (200),
date_added VARCHAR (200),
release_year INTEGER,
rating VARCHAR (20),
duration VARCHAR (20),
listed_in VARCHAR (20),
description TEXT
);

COPY netflix_titles 
FROM 'D:\SQL\Streaming Wars\netflix_titles.csv'
DELIMITER ','
CSV HEADER;

alter table netflix_titles
alter column listed_in type VARCHAR (500);

alter table netflix_titles
alter column "cast" type TEXT;

alter table netflix_titles
alter column description type TEXT;

alter table netflix_titles
alter column title type VARCHAR (500);

alter table netflix_titles
alter column director type VARCHAR (500);

alter table netflix_titles
alter column country type VARCHAR (500);

COPY netflix_titles 
FROM 'D:\SQL\Streaming Wars\netflix_titles.csv'
DELIMITER ','
CSV HEADER;

select COUNT (*) from netflix_titles;

create table amazon_titles (
show_id VARCHAR (10),
type VARCHAR (20),
title VARCHAR (500),
director VARCHAR (500),
"cast" TEXT,
country VARCHAR (500),
date_added VARCHAR (50),
release_year INTEGER,
rating VARCHAR (20),
duration VARCHAR (20),
listed_in VARCHAR (500),
description TEXT);

copy amazon_titles
from 'D:\SQL\Streaming Wars\amazon_prime_titles.csv'
delimiter ','
csv header;

alter table amazon_titles
alter column director type TEXT;

copy amazon_titles
from 'D:\SQL\Streaming Wars\amazon_prime_titles.csv'
delimiter ','
csv header;

select COUNT(*) from amazon_titles;

create table disney_titles (
show_id VARCHAR (10),
type VARCHAR (20),
title VARCHAR (500),
director VARCHAR (500),
"cast" TEXT,
country VARCHAR (500),
date_added VARCHAR (50),
release_year INTEGER,
rating VARCHAR (20),
duration VARCHAR (20),
listed_in VARCHAR (500),
description TEXT
);

copy disney_titles
from 'D:\SQL\Streaming Wars\disney_plus_titles.csv'
delimiter ','
csv header;

select COUNT(*) from disney_titles;

create table hulu_titles (
show_id VARCHAR(10),
type VARCHAR (20),
title VARCHAR (500),
director VARCHAR (500),
"cast" TEXT,
country VARCHAR (500),
date_added VARCHAR (50),
release_year INTEGER,
rating VARCHAR (20),
duration VARCHAR (20),
listed_in VARCHAR (500),
description TEXT
);

copy hulu_titles
from 'D:\SQL\Streaming Wars\hulu_titles.csv'
delimiter ','
csv header;

select COUNT(*) from hulu_titles;


--Exploring the platform wise type of content available
select 'NETFLIX' as platform, "type", COUNT(*) 
from netflix_titles
group by "type"
union all
select 'AMAZON', "type", COUNT(*)
from amazon_titles
group by "type"
union all
select 'DISNEY', "type", COUNT(*)
from disney_titles
group by "type"
union all
select 'HULU', "type", COUNT(*)
from hulu_titles
group by "type" 
order by platform, "type";

--EXploring range of release years per platform type wise
select 'NETFLIX' as platform, "type", MIN(release_year), Max(release_year)
from netflix_titles
group by "type"
union all
select 'AMAZON', "type", Min(release_year), MAX(release_year)
from amazon_titles
group by "type"
union all
select 'DISNEY', "type", Min(release_year), MAX(release_year)
from disney_titles
group by "type"
union all
select 'HULU', "type", MIN(Release_year), MAX(release_year)
from hulu_titles
group by "type"
order by platform, "type";

--Checking data in table
select * from netflix_titles
limit 10;

--Movies and Shows Count - Platform by Category Pivot
--Splitting the listed in column into multiple rows to count all category values individually
select 'NETFLIX' as platform, title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from netflix_titles
order by 2,3
limit 20;
--Pivot Aggregating the category by type
--Netflix
select X.platform, X.category, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count
from(
select 'NETFLIX' as platform, title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from netflix_titles) X
group by 1,2 order by 4 desc;
--Amazon
select X.platform, X.category, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count
from(
select 'AMAZON' as platform, title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from amazon_titles) X
group by 1,2 order by 3 desc;
--Disney
select X.platform, X.category, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count
from(
select 'DISNEY' as platform, title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from disney_titles) X
group by 1,2 order by 3 desc;
--Hulu
select X.platform, X.category, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count
from(
select 'HULU' as platform, title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from hulu_titles) X
group by 1,2 order by 3 desc;
--Combined for all platforms
select X.platform, X.category, SUM(case when X.type= 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, COUNT(X.show_id) as total_count
from (
select 'Netflix' as platform, title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from netflix_titles
union all
select 'Amazon', title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from amazon_titles
union all
select 'Disney', title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from disney_titles
union all
select 'Hulu', title, REGEXP_SPLIT_TO_TABLE(listed_in, ',\s*') as category, "type", show_id
from hulu_titles
order by 2,3) X
group by 1,2 order by 5 desc;

--Actors apearance count on each platform by type
--Checking for null values in all platforms
select distinct "cast"
from netflix_titles
where "cast" = '' or "cast" is null
limit 5;
--Actor by platform and type
select X.actor, X.platform, SUM(case when "type" = 'Movie' then 1 else 0 end) as movie_count, SUM(case when "type" = 'TV Show' then 1 else 0 end) as series_count, count(X.show_id) as Total_appearnce
from (
select REGEXP_SPLIT_TO_TABLE("cast",',\s*') as actor, 'Netflix' as platform, "type", show_id
from netflix_titles
union all
select REGEXP_SPLIT_TO_TABLE("cast",',\s*'), 'Amazon', "type", show_id
from amazon_titles
union all
select regexp_split_to_table("cast",',\s'), 'Disney', "type", show_id
from disney_titles
union all
select REGEXP_SPLIT_TO_TABLE("cast",',\s*'), 'Hulu', "type", show_id
from hulu_titles) X
group by 1,2 order by 1,3 desc;

--Directors count on each platform
--Checking for double directors if any
select director
from netflix_titles
where director like '%,%'
limit 5;
--Checking for NULL
select director
from netflix_titles
where director = '' or director is null;
--Director by platform and type
select X.director_name, X.platform, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, Count(X.show_id)
from(
select REGEXP_SPLIT_TO_TABLE(director, ',\s*') as director_name, 'Netflix' as platform, "type", show_id
from netflix_titles
union all
select REGEXP_SPLIT_TO_TABLE(director, ',\s*'), 'Amazon', "type", show_id
from amazon_titles
union all
select REGEXP_SPLIT_TO_TABLE(director, ',\s*'), 'Disney', "type", show_id
from disney_titles
union all
select REGEXP_SPLIT_TO_TABLE(director, ',\s*'), 'Hulu', "type", show_id
from hulu_titles
) X
where X.director_name is not null
group by 1, 2 
union all
select 'No Director' as director_name, X.platform, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, COUNT(X.show_id)
from(
select director, 'Netflix' as platform, "type", show_id
from netflix_titles 
where director is null
union all
select director, 'Amazon', "type", show_id
from amazon_titles
where director is null
union all
select director, 'Disney', "type", show_id
from disney_titles
where director is null
union all
select director, 'Hulu', "type", show_id
from hulu_titles
where director is null
) X
group by 1,2 order by 5 desc;

--Country mapping of content origin by type and platform
--checking for double countries
select country
from netflix_titles
where country like '%,%'
limit 5;
--checking for null values
select country
from netflix_titles
where country = '' or country is null
limit 5;
--Country Mapping by type
select X.country_name, X.platform, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end), COUNT(X.show_id) as Total_count
from(
select 'Netflix' as platform, REGEXP_SPLIT_TO_TABLE(country, ',\s*') as country_name, "type", show_id
from netflix_titles
union all
select 'Amazon', REGEXP_SPLIT_TO_TABLE(country,',\s*') as country_name, "type", show_id
from amazon_titles
union all
select 'Disney', REGEXP_SPLIT_TO_TABLE(country,',\s*') as country_name, "type", show_id
from disney_titles
union all
select 'Hulu', REGEXP_SPLIT_TO_TABLE(country, ',\s*') as country_name, "type", show_id
from hulu_titles
)X
where country_name is not null and country_name != ''
group by 1,2
union all
select 'No Country' as country_name, X.platform, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, COUNT(X.show_id) as Total_count
from(
select 'Netflix' as platform, country, "type", show_id
from netflix_titles
where country is null or country = ''
union all
select 'Amazon', country, "type", show_id
from amazon_titles
where country is null or country = ''
union all
select 'Disney', country, "type", show_id
from disney_titles dt
where country is null or country = ''
union all
select 'Hulu', country, "type", show_id
from hulu_titles ht 
where country is null or country = ''
) X
group by 1,2
order by 5 desc;

--Decade wise content release trend
--Check for null
select release_year
from disney_titles
where release_year is null
limit 5;
--Decade Trend by Type
select X.platform, X.release_decade, SUM(case when X.type = 'Movie' then 1 else 0 end) as movies_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, COUNT(show_id) as total_count
from(
select 'Netflix' as platform, CONCAT(release_year/10, '0s') as release_decade, "type", show_id
from netflix_titles
union all
select 'Amazon', Concat(release_year/10, '0s'), "type", show_id
from amazon_titles
union all
select 'Disney', CONCAT(release_year/10, '0s'), "type", show_id
from disney_titles
union all
select 'Hulu', CONCAT(release_year/10, '0s'), "type", show_id
from hulu_titles
) X
group by 1, 2 order by 5 desc;

--Seasonality Trend Platform by type
--Check for null
select date_added
from hulu_titles
where release_year is not null 
limit 10;
--Platform by type
select X.platform, X.year, X.month, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, COUNT(X.show_id) as total_count
from(
select 'Netflix' as platform, EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')) as "year", EXTRACT(month from TO_DATE(date_added, 'Month DD, YYYY')) as "month", "type", show_id
from netflix_titles
where date_added is not null and date_added != ''
union all
select 'Amazon', EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')), EXTRACT(month from TO_DATE(date_added, 'month DD, YYYY')), "type", show_id
from amazon_titles
where date_added is not null and date_added != ''
union all
select 'Disney', EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')), extract(month from TO_DATE(date_added, 'month DD, YYYY')), "type", show_id
from disney_titles
where date_added is not null and date_added != ''
union all
select 'Hulu', EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')), EXTRACT(month from TO_DATE(date_added, 'month DD, YYYY')), "type", show_id
from hulu_titles
where date_added is not null and date_added != ''
) X
group by 1,2,3 order by 6 desc;
--Amazin count verifying
SELECT COUNT(*) 
FROM amazon_titles 
WHERE date_added IS NOT NULL 
AND date_added != '';

--Duration Trend by Type
--check for null
select  duration
from netflix_titles
where duration is null
limit 20;
--Max, Min and Avg for Movie and TV Show
select X.platform, Max(movie_duration) as Max_duration, Min(movie_duration) as Min_duration, AVG(movie_duration)
from(
select'Netflix' as platform, case when "type" = 'Movie' then SPLIT_PART(duration,' ', 1)::INTEGER end as movie_duration, show_id
from netflix_titles
union all
select 'Amazon', case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end, show_id
from amazon_titles
union all
select 'Disney', case when "type" = 'Movie' then SPLIT_PART(duration,' ',1)::INTEGER end, show_id
from disney_titles
union all
select 'Hulu', case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end, show_id
from hulu_titles) X
where movie_duration is not null
group by 1;
--Platform and Series Interval Duration Pivot
select X.platform, SUM(case when X.series_duration = 1 then 1 else 0 end) as only_1, SUM(case when X.series_duration = 2 then 1 else 0 end) as Only_2, SUM(case when X.series_duration between 3 and 5 then 1 else 0 end) as Upto_5,
SUM(case when X.series_duration between 6 and 9 then 1 else 0 end) as Upto_8, SUM(case when X.series_duration between 9 and 10 then 1 else 0 end) as Upto_10, SUM(case when X.series_duration between 11 and 15 then 1 else 0 end) as Upto_15,
SUM(case when X.series_duration > 15 then 1 else 0 end) as More_than_15, COUNT(X.show_id) as total
from(
select'Netflix' as platform, case when "type" = 'TV Show' then SPLIT_PART(duration,' ', 1)::INTEGER end as series_duration, show_id
from netflix_titles
union all
select 'Amazon', case when "type" = 'TV Show' then SPLIT_PART(duration, ' ', 1)::INTEGER end, show_id
from amazon_titles
union all
select 'Disney', case when "type" = 'TV Show' then SPLIT_PART(duration,' ',1)::INTEGER end, show_id
from disney_titles
union all
select 'Hulu', case when "type" = 'TV Show' then SPLIT_PART(duration, ' ', 1)::INTEGER end, show_id
from hulu_titles) X
where series_duration is not null
group by 1;
--Platform and Movie Interval Duration Pivot
select X.platform, SUM(case when X.movie_duration <15 then 1 else 0 end) as Upto_15, SUM(case when X.movie_duration between 16 and 30 then 1 else 0 end) as Upto_30, SUM(case when X.movie_duration between 31 and 60 then 1 else 0 end) as Upto_60,
SUM(case when X.movie_duration between 61 and 90 then 1 else 0 end) as Upto_90, SUM(case when X.movie_duration between 91 and 105 then 1 else 0 end) as Upto_105, SUM(case when X.movie_duration between 106 and 120 then 1 else 0 end) as Upto_120,
SUM(case when X.movie_duration between 120 and 135 then 1 else 0 end) as More_than_135, SUM(case when X.movie_duration between 136 and 150 then 1 else 0 end) as Upto_150, SUM(case when X.movie_duration between 151 and 180 then 1 else 0 end) as Upto_180, 
SUM(case when X.movie_duration between 181 and 240 then 1 else 0 end) as Upto_240, SUM(case when X.movie_duration > 240 then 1 else 0 end) as more_than_240,  COUNT(X.show_id) as total
from(
select'Netflix' as platform, case when "type" = 'Movie' then SPLIT_PART(duration,' ', 1)::INTEGER end as movie_duration, show_id
from netflix_titles
union all
select 'Amazon', case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end, show_id
from amazon_titles
union all
select 'Disney', case when "type" = 'Movie' then SPLIT_PART(duration,' ',1)::INTEGER end, show_id
from disney_titles
union all
select 'Hulu', case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end, show_id
from hulu_titles) X
where movie_duration is not null
group by 1;

--Content sharing by Plaforms
--Content Shared by Platform's Count
select X.title, X."type", COUNT(X.platform) as platform_count
from(
select title, 'Netflix' as platform, "type"
from netflix_titles
union all
select title, 'Amanzon', "type"
from amazon_titles
union all
select title, 'Disney', "type"
from disney_titles
union all
select title, 'Hulu', "type"
from hulu_titles
) X
group by 1,2 order by 3 desc;
--Content Shared by Platform Name and type - Movie
select X.title, MAX(case when X.platform = 'Netflix' then 'Netflix' else '-' end) as Netflix, MAX(case when X.platform = 'Amazon' then 'Amazon' else '-' end) as Amazon,
MAX(case when X.platform = 'Disney' then 'Disney' else '-' end) as Disney, MAX(case when X.platform = 'Hulu'then 'Hulu' else '-' end) as Hulu,
Count(*) as Total_Platforms
from(
select title, 'Netflix' as platform, "type"
from netflix_titles
where "type" = 'Movie' 
union all
select title, 'Amazon', "type"
from amazon_titles
where "type" = 'Movie'
union all
select title, 'Disney', "type"
from disney_titles
where "type" = 'Movie'
union all
select title, 'Hulu', "type"
from hulu_titles
where "type" = 'Movie' ) X
group by 1
having Count(*) > 1
order by 2,3,4,5,6 asc;
--Content Shared by Platform Name and type - TV Show
select X.title, MAX(case when X.platform = 'Netflix' then 'Netflix' else '-' end) as Netflix, MAX(case when X.platform = 'Amazon' then 'Amazon' else '-' end) as Amazon,
MAX(case when X.platform = 'Disney' then 'Disney' else '-' end) as Disney, MAX(case when X.platform = 'Hulu'then 'Hulu' else '-' end) as Hulu,
Count(*) as Total_Platforms
from(
select title, 'Netflix' as platform, "type"
from netflix_titles
where "type" = 'TV Show' 
union all
select title, 'Amazon', "type"
from amazon_titles
where "type" = 'TV Show'
union all
select title, 'Disney', "type"
from disney_titles
where "type" = 'TV Show'
union all
select title, 'Hulu', "type"
from hulu_titles
where "type" = 'TV Show' ) X
group by 1
having Count(*) > 1
order by 2,3,4,5,6 asc;
--Alternate Method
SELECT title, 
STRING_AGG(platform, ', ' ORDER BY platform) as platforms,
COUNT(*) as platform_count
FROM (
SELECT title, 'Netflix' as platform
FROM netflix_titles
UNION ALL
SELECT title, 'Amazon'
FROM amazon_titles
UNION ALL
SELECT title, 'Disney'
FROM disney_titles
UNION ALL
SELECT title, 'Hulu'
FROM hulu_titles
) all_titles
GROUP BY title
HAVING COUNT(*) > 1
ORDER BY platform_count DESC, title;

--Theme Identification through Description words
select X.platform, X.word, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, COUNT(X.word) as Total_count
from (
select 'netflix' as platform, REGEXP_REPLACE(LOWER(REGEXP_SPLIT_TO_TABLE(description, '\s+')), '[^a-z]', '', 'g') as word, "type"
from netflix_titles
union all
select 'Amazon', REGEXP_REPLACE(LOWER(REGEXP_SPLIT_TO_TABLE(description, '\s+')), '[^a-z]', '', 'g'), "type"
from amazon_titles
union all
select 'Disney', REGEXP_REPLACE(LOWER(REGEXP_SPLIT_TO_TABLE(description, '\s+')), '[^a-z]', '', 'g'), "type"
from disney_titles
union all
select 'Hulu', REGEXP_REPLACE(LOWER(REGEXP_SPLIT_TO_TABLE(description, '\s+')), '[^a-z]', '', 'g'), "type"
from hulu_titles
) X
where length(X.word) >= 4 and X.word not in ('details', 'advisory', 'with', 'from', 'that', 'this', 'their', 'have', 'when', 'will', 'after', 'into', 'also', 'more', 'than', 'about', 'they', 'must', 'gets', 'them', 'what', 'your', 'just', 'like', 'been', 'some', 'there', 'even', 'both', 'many', 'every', 'each')
group by 1,2 order by 5 desc
limit 200;
--running for disney separate as it is not in top 200
select X.platform, X.word, SUM(case when X.type = 'Movie' then 1 else 0 end) as movie_count, SUM(case when X.type = 'TV Show' then 1 else 0 end) as series_count, COUNT(X.word) as Total_count
from (
select 'disney' as platform, REGEXP_REPLACE(LOWER(REGEXP_SPLIT_TO_TABLE(description, '\s+')), '[^a-z]', '', 'g') as word, "type"
from disney_titles) X
where length(X.word) >= 4 and X.word not in ('details', 'advisory', 'with', 'from', 'that', 'this', 'their', 'have', 'when', 'will', 'after', 'into', 'also', 'more', 'than', 'about', 'they', 'must', 'gets', 'them', 'what', 'your', 'just', 'like', 'been', 'some', 'there', 'even', 'both', 'many', 'every', 'each')
group by 1,2 order by 5 desc
limit 50;

----------Layer 2 Queries

--Length of Movie content increasing decreasing by years
select X.platform, X."year", Avg(X.length) as avg_duration
from(
select 'Netflix' as platform, extract(year from TO_DATE(date_added, 'month DD, YYYY')) as "year", case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end as length
from netflix_titles
union all
select 'Amazon', extract(year from TO_DATE(date_added, 'month DD, YYYY')), case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end
from amazon_titles
union all
select 'Disney', extract ( year from TO_DATE(date_added, 'month DD, YYYY')), case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end
from disney_titles
union all
select 'Hulu', extract ( year from TO_DATE(date_added, 'month DD, YYYY')), case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end
from hulu_titles
) X
where X."year" is not null and X.length is not null
group by 1,2 order by 1, 2 asc;

--Length of Series content increasing decreasing by years
select X.platform, X.release_year, Avg(X.length) as avg_duration
from(
select 'Netflix' as platform, release_year, case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end as length
from netflix_titles
union all
select 'Amazon', release_year, case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end
from amazon_titles
union all
select 'Disney', release_year, case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end
from disney_titles
union all
select 'Hulu', release_year, case when "type" = 'Movie' then SPLIT_PART(duration, ' ', 1)::INTEGER end
from hulu_titles
) X
where X.release_year is not null
group by 1,2 order by 1, 2 asc;

--Length of TV SHows - Mini series dominating?
select X.platform, X.year_added, SUM(case when X.seasons = 1 then 1 else 0 end) as One, SUM(case when X.seasons = 2 then 1 else 0 end) as Two, SUM(case when X.seasons between 3 and 5 then 1 else 0 end) as Three_to_Five,
SUM(case when X.seasons between 6 and 8 then 1 else 0 end) as Seven_Eight, SUM(case when X.seasons between 9 and 10 then 1 else 0 end) as Nine_Ten, SUM(case when X.seasons > 10 then 1 else 0 end) Eleven_and_Above
from(
select 'Netflix' as platform, EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')) as year_added, SPLIT_PART(duration, ' ', 1)::INTEGER as seasons 
from netflix_titles
where "type" = 'TV Show'
union all
select 'Amazon' as platform, EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')) as year_added, SPLIT_PART(duration, ' ', 1)::INTEGER as seasons 
from amazon_titles
where "type" = 'TV Show'
union all
select 'Disney' as platform, EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')) as year_added, SPLIT_PART(duration, ' ', 1)::INTEGER as seasons 
from disney_titles
where "type" = 'TV Show'
union all
select 'Hulu' as platform, EXTRACT(year from TO_DATE(date_added, 'month DD, YYYY')) as year_added, SPLIT_PART(duration, ' ', 1)::INTEGER as seasons 
from hulu_titles
where "type" = 'TV Show'
) X
where X.year_added is not null and X.seasons is not null
group by 1, 2 order by 1, 2;


--Country-wise YoY Content Addition Trend
select X.country_name, SUM(case when X.year = 2021 then 1 else 0 end) as Y2021, SUM(case when X.year = 2020 then 1 else 0 end) as Y2020, SUM(case when X.year = 2019 then 1 else 0 end) as Y2019,
SUM(case when X.year = 2018 then 1 else 0 end) as Y2018, SUM(case when X.year = 2017 then 1 else 0 end) as Y2017
from(
select regexp_split_to_table(country, ',\s*') as country_name, extract(year from TO_DATE(date_added, 'month DD, YYYY')) as year, "type"
from netflix_titles) X
--where X."type" = 'Movie'
group by X.country_name order by 2 desc
;

--Cateogry Growth/Decline over time using CTE
WITH X as (
select regexp_split_to_table(listed_in, ',\s*') as category, extract(year from To_Date(date_added, 'month DD, YYYY')) as year, "type"
from netflix_titles
where "type" = 'TV Show')
select category, SUM(case when X.year = 2021 then 1 else 0 end) as Y2021, SUM(case when X.year = 2020 then 1 else 0 end) as Y2020, SUM(case when X.year = 2019 then 1 else 0 end) as Y2019,
SUM(case when X.year = 2018 then 1 else 0 end) as Y2018, SUM(case when X.year = 2017 then 1 else 0 end) as Y2017
from X
group by X.category order by 2 desc;


--Category Growth/Decline Percentage over time with CTE w/o Window Function
with X as (
select regexp_split_to_table(listed_in, ',\s*') as category, extract(year from To_Date(date_added, 'month DD, YYYY')) as year, "type"
from netflix_titles
where "type" = 'TV Show'),
Y as (
select X.category, SUM(case when X.year = 2021 then 1 else 0 end) as Y2021, SUM(case when X.year = 2020 then 1 else 0 end) as Y2020, SUM(case when X.year = 2019 then 1 else 0 end) as Y2019,
SUM(case when X.year = 2018 then 1 else 0 end) as Y2018, SUM(case when X.year = 2017 then 1 else 0 end) as Y2017
from X
group by X.category order by 2 desc)
select category, Round((Y2021-Y2020)*100.0/nullif(Y2020,0)) as Y21_Y20, Round((Y2020-Y2019)*100.0/nullif(Y2019,0)) as Y20_Y19, Round((Y2019-Y2018)*100.0/nullif(Y2018,0)) as Y19_Y18, Round((Y2018-Y2017)*100.0/nullif(Y2017,0)) as Y18_Y17
from Y;

--Same query just using Window function to learn
with X as (
select regexp_split_to_table(listed_in, ',\s*') as category,  extract(year from To_date(date_added, ('month DD, YYYY'))) as year, "type"
from netflix_titles
where "type" = 'TV Show'),
Y as (
select X.category, X.year, count(*) as total_count
from X
group by X.category, year order by 2 desc)
select Y.category, Y.year, Y.total_count, LAG(Y.total_count) over (partition by Y.category order by Y.year) as previous_year_count, ROUND((total_count - LAG(total_count) over (partition by Y.category order by year))*100.0/nullif(lag(Y.total_count) over (partition by Y.category order by year),0),1) as growth_pct 
from Y
order by Y.category, Y.year;

--Which categories added more recently?
with X as (
select regexp_split_to_table(listed_in, ',\s*') as category, extract(year from TO_DATE(date_added, 'month DD, YYYY')) as year, "type"
from netflix_titles
where "type" = 'TV Show')
select X.category, count(*), SUM(case when X.year < 2019 then 1 else 0 end) as Pre_2019, SUM(case when X.year >= 2019 then 1 else 0 end) as From_2019, ROUND(SUM(case when X.year >= 2019 then 1 else 0 end)*100.0/NULLIF(count(*),0),1)
from X
group by 1 order by 5 desc;


--Overlap of new additions in the same year
with X as (
select 'Netflix' as platform, title, extract(year from TO_Date(date_added, 'month DD, YYYY')) as year, "type", show_id
from netflix_titles
where "type" = 'Movie'
union all
select 'Disney', title, extract(year from TO_DATE(date_added, 'month DD, YYYY')), "type", show_id
from disney_titles
where "type" = 'Movie'
union all
select 'Hulu', title, extract(year from TO_DATE(date_added, 'month DD, YYYY')), "type", show_id
from hulu_titles
where "type" = 'Movie'),
Y as (
select X.title, X.year
from X
group by 1,2
having Count (distinct platform) > 1
),
Z as (
select year, Count(distinct X.title) as tot_count
from X
group by 1)
select Y.year, Count(Y.title) as overlap_titles, Z.tot_count, ROUND(COUNT(Y.title)*100.0/Nullif(Z.tot_count,0),1) as Pct_Overlap
from Y
left join Z
on Y.year = Z."year"
group by 1,3 order by 2;

--Description wise Themes per decade
with X as (
select 'Netflix' as platform, "type", release_year, description, show_id
from netflix_titles
where "type" = 'Movie'
union all
select 'Amazon', "type", release_year, description, show_id
from amazon_titles
where "type" = 'Movie'
union all
select 'Disney', "type", release_year, description, show_id
from disney_titles
where "type" = 'Movie'
union all
select 'Hulu', "type", release_year, description, show_id
from hulu_titles
where "type" = 'Movie'
),
Y as (
select X.platform, CONCAT((release_year/10)*10, 's') as decade, REGEXP_REPLACE(Lower(REGEXP_SPLIT_TO_TABLE(description, '\s+')), '[^a-z]', '', 'g') as word
from X
),
Z as (
select Y.platform, Y.decade, Y.word, COUNT(*) as word_count
from Y
where length (Y.word) > 2 and Y.word not in ('details', 'advisory', 'with', 'from', 'that', 'this', 'their', 'have', 'when', 'will', 'after', 'into', 'also', 'more', 'than', 'about', 'they', 'must', 'gets', 'them', 'what', 'your', 'just', 'like', 'been', 'some', 'there', 'even', 'both', 'many', 'every', 'each',
'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'her', 'was', 'one', 'our', 'out', 'him', 'his', 'has', 'had', 'she', 'who', 'its', 'how', 'two', 'now', 'new', 'get', 'use', 'man', 'men', 'way', 'may', 'say', 'find', 'only', 'over', 'such', 'take', 'then', 'well', 'made', 'make', 'know', 'most', 'come', 'when', 'time',
'back', 'down', 'day', 'did', 'let', 'put', 'too', 'old', 'set', 'own', 'off', 'try', 'act', 'far', 'few', 'got')
group by Y.platform, Y.decade, Y.word
),
A as (select Z.platform, Z.decade, Z.word, Z.word_count, RANK() over (partition by Z.platform, Z.decade order by Z.word_count desc) as rank
from Z)
select A.platform, A.decade, A.word, A.word_count, A.rank
from A
where rank <= 10
order by A.platform, A.decade, A."rank";
;

--Description wise UNIQUE themes per decade
with X as (
select 'Netflix' as platform, "type", description, release_year
from netflix_titles
where "type" = 'Movie' and description is not null
union all
select 'Amazon', "type", description, release_year
from amazon_titles
where "type" = 'Movie'
union all
select 'Disney', "type", description, release_year
from disney_titles
where "type" = 'Movie'
union all
select 'Hulu', "type", description, release_year
from hulu_titles
where "type" = 'Movie'
),
Y as (
select K.platform, K.decade, K.word    ------ Introduced subquery to reduce number of rows in Y, else leads to millions of rows in Z calculation
from (
select X.platform, CONCAT((release_year/10)*10,'s') as decade, REGEXP_REPLACE(LOWER(REGEXP_SPLIT_TO_TABLE(description, '\s+')), '[^a-z]', '', 'g') as word
from X
where release_year is not null and release_year > 0) K
where length(K.word) > 2 and K.word != ''
and K.word not in ('details', 'advisory', 'with', 'from', 'that', 'this', 'their', 'have', 'when', 'will', 'after', 'into', 'also', 'more', 'than', 'about', 'they', 'must', 'gets', 'them', 'what', 'your', 'just', 'like', 'been', 'some', 'there', 'even', 'both', 'many', 'every', 'each',
'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'her', 'was', 'one', 'our', 'out', 'him', 'his', 'has', 'had', 'she', 'who', 'its', 'how', 'two', 'now', 'new', 'get', 'use', 'man', 'men', 'way', 'may', 'say', 'find', 'only', 'over', 'such', 'take', 'then', 'well', 'made', 'make', 'know', 'most', 'come', 'when', 'time',
'back', 'down', 'day', 'did', 'let', 'put', 'too', 'old', 'set', 'own', 'off', 'try', 'act', 'far', 'few', 'got')
),
Z as (
select Y.platform, Y.decade, Y.word, COUNT(*) as word_count
from Y
group by Y.platform, Y.decade, Y.word),
pivot as (
select Z.decade, Z.word, sum(case when Z.platform = 'Netflix' then Z.word_count else 0 end) as netflix, sum(case when Z.platform = 'Amazon' then Z.word_count else 0 end) as amazon, sum(case when Z.platform = 'Disney' then Z.word_count else 0 end) as disney, sum(case when Z.platform = 'Hulu' then Z.word_count else 0 end) as hulu, Sum(Word_count) as total
from Z
group by Z.decade, Z.word),
decade_count as(
select word, count(distinct Z.decade) as decade_appeared
from Z
group by Z.word)
select pivot.decade, pivot.word, pivot.netflix, pivot.amazon, pivot.disney, pivot.hulu, decade_count.decade_appeared
from pivot
left join decade_count
on decade_count.word = pivot.word
where decade_count.decade_appeared = 1 and pivot.total>5
order by pivot.decade, pivot.total desc;

--For gap analysis between themes, would be done with python.
--A as (
--select B.platform, B.decade, B.word, B.dec, Lag(B.dec) over (partition by B.word order by B.dec) as prev_dec, B.dec - Lag(B.dec) over (partition by B.word order by B.dec) as gap
--from(
--select Z.platform,Z.decade, Z.word, REGEXP_REPLACE(Z.decade,'[^0-9]', '', 'g')::INTEGER as dec
--from Z) B
--)