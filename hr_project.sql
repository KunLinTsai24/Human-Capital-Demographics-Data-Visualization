create database project_hr;

use project_hr;

select * from hr;


-- data cleaning and preprocessing

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;


SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;


-- change the data format and datatype of hire_date column

UPDATE hr
SET hire_date = CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
        
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- change the date format and datatpye of termdate column
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

-- create age column --
alter table hr
add column age int;

update hr 
set age = timestampdiff(year,birthdate,curdate());

select min(age),max(age) from hr;

-- 1. what is the gender breakdown of employees in the company

select gender, count(*) as count
from hr
where termdate is null
group by gender;

-- 2. what is the race breakdown of employees in the company
select race, count(*) as count 
from hr 
where termdate is null
group by race;


-- 3. what is the age distribution of employees in the company
select 
	case
		when age>=18 and age<= 24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
		else '65+'
	end as age_group,
    count(*) as count
    from hr
    where termdate is null
    group by age_group
    order by age_group;
    
-- 4. how many employees work at HQ vs remote

select location, count(*) as count
from hr
where termdate is null
group by location;

-- 5. what is the average length of employement who have been terminated
SELECT ROUND(AVG(year(termdate) - year(hire_date)),0) AS length_of_emp
FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate();

-- 6. how does the gender distribution vary across dept. and job titles in employement who have been terminated
select department, jobtitle,gender,count(*) as count
from hr
where termdate is null
group by department, jobtitle, gender
order by department, jobtitle, gender;

SELECT department,gender,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY department,gender
ORDER BY department,gender;

-- 7. what is the distribution of jobtitle across the company
select jobtitle, count(*) as count
from hr
where termdate is null
group by jobtitle;

-- 8. which dept, gender, race, age, year has the higher turnover rate
select department,
	count(*) as total_count,
    count( case 
				when termdate is not null and termdate <= curdate() then 1
                end) as terminted_count,		
    round((count( case 
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100,2) as termination_rate
from hr
group by department
order by termination_rate desc;

select gender,
	count(*) as total_count,
    count( case 
				when termdate is not null and termdate <= curdate() then 1
                end) as terminted_count,		
    round((count( case 
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100,2) as termination_rate
from hr
group by gender
order by termination_rate desc;

select 
	case
		when age>=18 and age<= 24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
		else '65+'
	end as age_group,
	count(*) as total_count,
    count( case 
				when termdate is not null and termdate <= curdate() then 1
                end) as terminted_count,		
    round((count( case 
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100,2) as termination_rate
from hr
group by age_group
order by termination_rate desc;

select race,
	count(*) as total_count,
    count( case 
				when termdate is not null and termdate <= curdate() then 1
                end) as terminted_count,		
    round((count( case 
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100,2) as termination_rate
from hr
group by race
order by termination_rate desc;

select year(hire_date) as year,
	count(*) as total_count,
    count( case 
				when termdate is not null and termdate <= curdate() then 1
                end) as terminted_count,		
    round((count( case 
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100,2) as termination_rate
from hr
group by year
order by year ;


-- 9.what is the distribution of employees across location_state

select location_state, count(*) as count
from hr
where termdate is null
group by location_state;

SELECT location_city, COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY location_city;


-- 10. how is the companys employee count change over time based on hire and termination date

select year, 
	hires, 
	terminations, 
	hires-terminations as net_change 
from (
	select year(hire_date) as year,
		count(*) as hires,
        sum(case
				when termdate is not null and termdate <= curdate() then 1
			end) as terminations
	from hr
    group by year(hire_date)
    ) as sub
group by year
order by year;

-- 11. what is th tenure distribution for each department

select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate<= curdate()
group by department;