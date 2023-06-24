### CASE STUDY 1 ###

# A
-- Number of jobs reviewed: Amount of jobs reviewed over time.
-- Your task: Calculate the number of jobs reviewed per hour per day for November 2020?

use operations_analytics_metric_spike;

select * from job_data_t;

drop view if exists job_data_view;

create view job_data_view as
(SELECT  
	job_id,
    actor_id,
    event,
    language,
    CAST(time_spent AS time) as time_spent,
    org,
	DATE_FORMAT(STR_TO_DATE(ds, '%d/%m/%y'), '%Y/%m/%d') as ds
from job_data_t
);

select * from job_data_view;

select 
	day(ds) as day,
	date_format(time_spent, '%H') AS hour,
    count(job_id) as jobs_reviewed
from job_data_view
WHERE date(ds) BETWEEN '2020-11-01' AND '2020-11-30'
group by hour, day
;

# B
-- Throughput: It is the no. of events happening per second.
-- Your task: Let’s say the above metric is called throughput. Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?

select * from job_data_view;

WITH temp_table as (
SELECT 
	ds, 
    COUNT(job_id) AS jobs, 
    SUM(time_spent) AS times
FROM job_data_view
GROUP BY ds)

SELECT 
	ds, 
    SUM(jobs) OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) / SUM(times) OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS throughput_7d_rolling_avg
FROM temp_table
order by ds;

# The above query will calculate the number of jobs and the total time spent per day, and then 
# use a window function to compute the ratio of jobs to time over a 7 day period for each day.

# What do you prefer daily metric or 7-day rolling? 
# - I would prefer a 7-day rolling metric over a daily metric because it can smooth out the fluctuations and outliers 
# that may occur on a single day. 
# - A 7-day rolling metric can also capture the trends and patterns over a longer time span and reduce the noise in the data. 
# However, a daily metric may be more useful if we want to monitor the immediate performance or identify specific issues 
# that may affect the throughput on a given day.


# C
-- Percentage share of each language: Share of each language for different contents.
-- Your task: Calculate the percentage share of each language in the last 30 days?
with lang_share as(
select 
language,
(count(language) over(partition by language) / count(language) over()) * 100  as lang_count,
ds
from job_data_view
where ds >= (select max(ds) from job_data_view) - INTERVAL '30' DAY)

select 
	language,
    lang_count
from lang_share
group by language, lang_count
order by lang_count desc;

# D
-- Duplicate rows: Rows that have the same value present in them.
-- Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?

WITH CTE AS (
  SELECT 
	job_id, 
    actor_id, 
    event, 
    language, 
    time_spent, 
    org, 
    ds,
  COUNT(*) OVER (PARTITION BY job_id, actor_id, event, language, time_spent, org, ds) AS cnt
  FROM job_data_view
)
SELECT *
FROM CTE
WHERE cnt > 1;


### CASE STUDY 2 ###

# A
-- User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
-- Your task: Calculate the weekly user engagement?
select * from users_t;

### number of events per user per week
WITH user_week_events AS (
  SELECT
    user_id,
    DATE_FORMAT(occurred_at, '%Y-%u') AS week, 
    # if the created_at value is ‘2021-10-30’, then DATE_FORMAT(created_at, ‘%Y-%u’) will return ‘2021-43’
    COUNT(*) AS event_count
  FROM events_t
  GROUP BY user_id, week
)

-- calculate the average number of events per user per week
SELECT
  AVG(event_count) AS avg_events_per_user_per_week
FROM user_week_events;


# B
-- User Growth: Amount of users growing over time for a product.
-- Your task: Calculate the user growth for product?

### number of new users per week
WITH new_users_per_week AS (
  SELECT
    DATE_FORMAT(created_at, '%Y-%u') AS week,
    COUNT(*) AS new_user_count
  FROM users_t
  GROUP BY week
)


-- select the week and the new user count
SELECT
  week,
  new_user_count
FROM new_users_per_week
order by week;


# C
-- Weekly Retention: Users getting retained weekly after signing-up for a product.
-- Your task: Calculate the weekly retention of users-sign up cohort?

### percentage of users who logged in at least once in a week after signing up
-- create a temporary table that counts the number of users who signed up for each week
WITH sign_up_cohort AS (
  SELECT
    DATE_FORMAT(created_at, '%Y-%u') AS sign_up_week,
    COUNT(*) AS sign_up_count
  FROM users_t
  GROUP BY sign_up_week
),

-- create a CTE(Common Table Expression) that counts the number of users who logged in for each week
login_cohort AS (
  SELECT
    user_id,
    DATE_FORMAT(occurred_at, '%Y-%u') AS login_week
  FROM events_t
  WHERE event_name = 'login'
  GROUP BY user_id, login_week
)

-- join the sign up cohort and the login cohort on user_id and calculate the retention rate for each week
SELECT
  s.sign_up_week,
  l.login_week,
  COUNT(DISTINCT l.user_id) / s.sign_up_count * 100 AS retention_rate
FROM sign_up_cohort s
JOIN login_cohort l
ON s.sign_up_week = l.login_week
GROUP BY s.sign_up_week, l.login_week
order by sign_up_week;

# D
-- Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
-- Your task: Calculate the weekly engagement per device?

### number of events per device per week
-- create a temporary table that counts the number of events for each device and week
WITH device_week_events AS (
  SELECT
	DATE_FORMAT(occurred_at, '%Y-%u') AS week,
    device,
    COUNT(*) AS event_count
  FROM events_t
  GROUP BY device, week
  order by week
)

-- select the device, the week and the event count
SELECT
	device,
	week,
	event_count
FROM device_week_events
order by week;

# E
-- Email Engagement: Users engaging with the email service.
-- Your task: Calculate the email engagement metrics?

### email open rate per week, which is the percentage of users who opened an email out of the total number of users who received an email

-- create a CTE(Common Table Expression) that counts the number of users who received an email for each week
WITH email_received AS (
  SELECT
    DATE_FORMAT(occurred_at, '%Y-%u') AS week,
    COUNT(DISTINCT user_id) AS received_count
  FROM email_events
  WHERE action = 'sent_weekly_digest'
  GROUP BY week
),

-- create a CTE(Common Table Expression) that counts the number of users who opened an email for each week
email_opened AS (
  SELECT
    DATE_FORMAT(occurred_at, '%Y-%u') AS week,
    COUNT(DISTINCT user_id) AS opened_count
  FROM email_events
  WHERE action = 'email_open'
  GROUP BY week
)

-- join the two tables on week and calculate the open rate for each week

SELECT
  r.week,
  o.opened_count / r.received_count * 100 AS open_rate
FROM email_received r
JOIN email_opened o
ON r.week = o.week
order by r.week;


 

