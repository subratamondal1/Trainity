-- A) Marketing: The marketing team wants to launch some campaigns, and they need your help with the following

-- Rewarding Most Loyal Users: People who have been using the platform for the longest time.
-- Your Task: Find the 5 oldest users of the Instagram from the database provided

-- Remind Inactive Users to Start Posting: By sending them promotional emails to post their 1st photo.
-- Your Task: Find the users who have never posted a single photo on Instagram

-- Declaring Contest Winner: The team started a contest and the user who gets the most likes on a single photo will win the contest now they wish to declare the winner.
-- Your Task: Identify the winner of the contest and provide their details to the team

-- Hashtag Researching: A partner brand wants to know, which hashtags to use in the post to reach the most people on the platform.
-- Your Task: Identify and suggest the top 5 most commonly used hashtags on the platform

-- Launch AD Campaign: The team wants to know, which day would be the best day to launch ADs.
-- Your Task: What day of the week do most users register on? Provide insights on when to schedule an ad campaign


-- B) Investor Metrics: Our investors want to know if Instagram is performing well and is not becoming redundant like Facebook, they want to assess the app on the following grounds

-- User Engagement: Are users still as active and post on Instagram or they are making fewer posts
-- Your Task: Provide how many times does average user posts on Instagram. Also, provide the total number of photos on Instagram/total number of users

-- Bots & Fake Accounts: The investors want to know if the platform is crowded with fake and dummy accounts
-- Your Task: Provide data on users (bots) who have liked every single photo on the site (since any normal user would not be able to do this).


# SOLUTION
-- A) Marketing: The marketing team wants to launch some campaigns, and they need your help with the following

-- Rewarding Most Loyal Users: People who have been using the platform for the longest time.
-- Your Task: Find the 5 oldest users of the Instagram from the database provided
use ig_clone;
SELECT 
    id,
    username,
    created_at,
    DATEDIFF(NOW(), created_at) AS duration
FROM
    users
ORDER BY created_at
LIMIT 5;

-- Remind Inactive Users to Start Posting: By sending them promotional emails to post their 1st photo.
-- Your Task: Find the users who have never posted a single photo on Instagram
-- select * from photos;
-- select * from users;

-- select count(distinct id) as total_user from users;
-- select count(distinct user_id) as user_uploaded_photo from photos;

with inactive_users as (
select
	users.id,
    photos.user_id
from 
	users
left join photos
	on users.id = photos.user_id
where photos.user_id is null) 

select username
from users
where id in (select id from inactive_users);

-- Declaring Contest Winner: The team started a contest and the user who gets the most likes on a single photo will win the contest now they wish to declare the winner.
-- Your Task: Identify the winner of the contest and provide their details to the team

-- select * from likes;
-- select * from tags;

with contest_winner_photo as(
	SELECT 
		likes.photo_id as likes_photo_id, 
		count(likes.created_at) as likes_total_likes
	FROM
		likes
	GROUP BY photo_id
	order by likes_total_likes desc
    limit 1
),

contest_winner_user as (
	select 
		user_id,
        likes_photo_id,
        likes_total_likes,
        created_dat as photo_upload_date
	from photos
	inner join contest_winner_photo
		on photos.id = contest_winner_photo.likes_photo_id
)

select 
	user_id,
    users.username,
	likes_photo_id,
	likes_total_likes,
	photo_upload_date,
    users.created_at as user_account_creation_date
from users
inner join contest_winner_user
	on users.id = contest_winner_user.user_id;

-- Hashtag Researching: A partner brand wants to know, which hashtags to use in the post to reach the most people on the platform.
-- Your Task: Identify and suggest the top 5 most commonly used hashtags on the platform

with top_5_tag_count as (
select tag_id, count(tag_id) as tag_count
from photo_tags
group by tag_id
order by tag_count desc
limit 5)

select tags.id, tag_name,tag_count
from tags
inner join top_5_tag_count
	on tags.id = top_5_tag_count.tag_id;


-- Launch AD Campaign: The team wants to know, which day would be the best day to launch ADs.
-- Your Task: What day of the week do most users register on? Provide insights on when to schedule an ad campaign

select 
	dayname(created_at) as dayname, 
    count(id) as total_users_registered 
from users
group by dayname
order by total_users_registered desc;

-- User Engagement: Are users still as active and post on Instagram or they are making fewer posts
-- Your Task: Provide how many times does average user posts on Instagram. Also, provide the total number of photos on Instagram/total number of users

-- select * from photos;
-- select * from users;

with total_posts_per_user as (
select 
	user_id, 
    count(id) as total_posts
from photos
group by user_id)

select 
	(select avg(total_posts) from total_posts_per_user) as avg_posts,
	count(id) as total_photos, 
    (select count(id) from users) as total_users
from photos;


-- Bots & Fake Accounts: The investors want to know if the platform is crowded with fake and dummy accounts
-- Your Task: Provide data on users (bots) who have liked every single photo on the site (since any normal user would not be able to do this).

-- select * from users;
-- select * from likes;

with liked_photos as (
select 
	user_id, 
    count(created_at) as liked
from likes
group by user_id),

result as (
	select 
	user_id,
    liked,
    count(user_id) over(order by user_id) as bot_count
	from 
	liked_photos
	where liked = (select count(id) from photos)
)

select user_id, username, liked, bot_count
from result
inner join users
on result.user_id = users.id
;

















