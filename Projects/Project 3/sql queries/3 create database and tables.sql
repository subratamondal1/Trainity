show databases;
use operations_analytics_metric_spike;

# job data
# create an empty table job_data_t with structure same as the .csv file
drop table if exists job_data_t;
CREATE TABLE job_data_t (
  job_id INT,
  actor_id INT,
  event VARCHAR(10) NOT NULL,
  language VARCHAR(20) NOT NULL,
  time_spent INT NOT NULL,
  org VARCHAR(50) NOT NULL,
  ds VARCHAR(10) NOT NULL
);

# check the table
select * from job_data_t;

# populate the table with the appropriate .csv file data
load data infile 'SQL Project-1 Table job_data - Sheet1.csv' into table job_data_t
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

# users
# Note: 
# 1. faced issue with the blank rows in activated_at column so imputed those rows with NULL while loading them in mysql db

# create an empty table users_t with the structure same as the .csv file
create table users_t(
	user_id double primary key,
    created_at datetime,
    company_id int,
    language varchar(20),
    activated_at datetime,
    state varchar(20)
);

# check the table
select * from users_t;
select count(*) from users_t;

# populate the table with the appropriate .csv file data
LOAD DATA INFILE 'Table-1 users.csv' INTO TABLE users_t
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(user_id, created_at, company_id, language, @activated_at, state)
SET activated_at = IF(@activated_at = '', NULL, @activated_at);

# events
# Note: 
# 1. faced issue with the date format so converted it into YYYY-MM-DD HH:MM:SS in the excel itself before loading them in mysql db
# 2. faced issue with the blank rows in user_type column so imputed those rows with 0 in the excel itself before loading them in mysql db

drop table if exists events_t;

# create an empty table users_t with the structure same as the .csv file
create table events_t (
	user_id int,
    occurred_at datetime,
    event_type varchar(50),
    event_name varchar(50),
    location varchar(50),
    device varchar(50),
    user_type int null
);

# check the table
select * from events_t;
select count(*) from events_t;

# populate the table with the appropriate .csv file data
load data infile 'Table-2 events.csv' into table events_t
fields terminated by ","
ignore 1 lines;

# email events
# Note: 
# 1. faced issue with the date format so converted it into YYYY-MM-DD HH:MM:SS in the excel itself before loading them in mysql db
drop table if exists email_events;

# create an empty table users_t with the structure same as the .csv file
create table if not exists email_events (
	user_id int,
    occurred_at datetime,
    action varchar(50),
    user_type int
);

# check the table
select * from email_events;
select count(*) from email_events;

# populate the table with the appropriate .csv file data
load data infile 'Table-3 email_events.csv' into table email_events
fields terminated by ","
ignore 1 lines;











 